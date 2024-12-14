#include "../../../user/syscall.h"
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "defs.h"
#include "proc.h"
#include "vm.h"

extern struct task_struct *current;
extern char _sramdisk[], _eramdisk[];
extern uint64_t nr_tasks;
extern struct task_struct *task[];
extern void __ret_from_fork();
extern uint64_t swapper_pg_dir[];
void trap_handler(uint64_t scause, uint64_t sepc, uint64_t sstatus, struct pt_regs *regs) {
    // 通过 `scause` 判断 trap 类型
    uint64_t _stvac = csr_read(stval);
    LogPURPLE("scause: 0x%llx, sstatus: 0x%llx, sepc: 0x%llx, stvac: 0x%llx", scause, sstatus, sepc, _stvac);
    // if (scause == 0x1) Err("_*stvac = 0x%llx", *(uint64_t*)_stvac);
    if(scause == 0x8000000000000005){
        LogRED("Timer Interrupt");
        clock_set_next_event();
        do_timer();
    }else if(scause == 0xc){
        LogRED("Instruction Page Fault");
        if(sepc < VM_START && sepc > USER_END){
            LogGREEN("[Physical Address: 0x%llx] -> [Virtual Address: 0x%llx]", sepc, sepc + 0xffffffdf80000000);
            csr_write(sepc, sepc + 0xffffffdf80000000);
            return;
        }
        do_page_fault(regs);
        csr_write(sepc, sepc);
        return;
    }else if(scause == 0xf){
        LogRED("Store/AMO Page Fault");
        do_page_fault(regs);
        csr_write(sepc, sepc);
        return;
    }else if(scause == 0xd){
        LogRED("Load Page Fault");
        do_page_fault(regs);
        csr_write(sepc, sepc);
        return;
    }else if(scause == 0x8){
        LogRED("Environment Call from U-mode");
        syscall(regs);
    }

    if (scause & 0x8000000000000000) {
        csr_write(sepc, sepc);
    } else {
        csr_write(sepc, sepc + 4);
    }
}


void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
    csr_write(sscratch, value);
}

void syscall(struct pt_regs *regs) {
    uint64_t syscall_num = regs->x[17];
    if (syscall_num == (uint64_t)SYS_WRITE) {
        uint64_t fd = regs->x[10];
        uint64_t i = 0;
        if (fd == 1) {
            char *buf = (char *)regs->x[11];
            for (i = 0; i < regs->x[12]; i++) {
                printk("%c", buf[i]);
            }
        }
        regs->x[10] = i;
        LogDEEPGREEN("Write: %d", i);
    } else if (syscall_num == (uint64_t)SYS_GETPID) {
        regs->x[10] = current->pid;
        LogDEEPGREEN("Getpid: %d", current->pid);
    } else if (syscall_num == (uint64_t)SYS_CLONE){
        uint64_t pid = do_fork(regs);
        LogYELLOW("[FORK] Parent PID = %d, Child PID = %d", current->pid, pid);
    } else {
        LogRED("Unsupported syscall: %d", syscall_num);
    }
    return;
}
// #define PTE_V  0x1
// #define PTE_R  0x2
// #define PTE_W  0x4
// #define PTE_X  0x8
// #define PTE_U  0x10

// #define VM_ANON 0x1
// #define VM_READ 0x2
// #define VM_WRITE 0x4
// #define VM_EXEC 0x8


void do_page_fault(struct pt_regs *regs) {
    uint64_t _stval = csr_read(stval);
    uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
    struct vm_area_struct *vma = find_vma(&current->mm, _stval);
    if (!vma){
        Err("No VMA found at 0x%llx", _stval);
        return;
    }

    uint64_t _scause = csr_read(scause);
    if ((_scause == 0xc && !(vma->vm_flags & VM_EXEC) ) || // Instruction Fault 但是不可以执行
        (_scause == 0xd && !(vma->vm_flags & VM_READ)) || // Load Fault 但是不可以读
        (_scause == 0xf && !(vma->vm_flags & VM_WRITE))){ // Store Fault 但是不可以写
        LogDEEPGREEN("Permission Denied");
        Err("Permission Denied at 0x%llx", _stval);
        return;
    }

    uint64_t perm = (vma->vm_flags & VM_READ) | (vma->vm_flags & VM_EXEC) | (vma->vm_flags & VM_WRITE) | PTE_U | PTE_V; 
    if (vma->vm_flags & VM_ANON){
        LogDEEPGREEN("ANON");
        // uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
        uint64_t pa = VA2PA((uint64_t)alloc_page());
        create_mapping(current->pgd, va, pa, PGSIZE, perm);
    }else{
        LogDEEPGREEN("FILE");
        // uint64_t va = PGROUNDDOWN(_stval); 
        // LogBLUE("vm_start = 0x%llx, vm_pgoff = 0x%llx, vm_filesz = 0x%llx", vma->vm_start, vma->vm_pgoff, vma->vm_filesz);
        uint64_t *uapp = (uint64_t*)alloc_page();
        if (PGROUNDDOWN(vma->vm_filesz) < PGSIZE){ // 整个uapp小于一页
            
            char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
            char *celf = (char*)_sramdisk + vma->vm_pgoff;
            for(uint64_t i = 0; i < vma->vm_filesz; i++) cuapp[i] = celf[i];
        }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start)){ // 从头开始
            char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
            char *celf = (char*)_sramdisk + vma->vm_pgoff;
            int i;
            // LogBLUE("0x%llx", PGSIZE - vma->vm_start & 0x1ff);
            for(i = 0; i < (PGSIZE - vma->vm_start & 0xfff); i++) {
                cuapp[i] = celf[i];
                //LogBLUE("[0x%llx] cuapp = 0x%llx, celf = 0x%llx", i, cuapp[i], celf[i]);
            }
            // LogBLUE("[0x%llx] cuapp = 0x%llx, celf = 0x%llx", i, cuapp[i], celf[i]);
        }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start + vma->vm_filesz - 1)){ // 最后一页
            char *cuapp = (char*)uapp;
            char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(vma->vm_pgoff + va - vma->vm_start));
            for(uint64_t i = 0; i <= ((vma->vm_start + vma->vm_filesz) & 0xfff); i++) cuapp[i] = celf[i];
            // ! 这里要考虑漏掉一个字节的情况
        }else{ // 中间或mem-
            LogBLUE("vm_start = 0x%llx, vm_end = 0x%llx, vm_filesz = 0x%llx", vma->vm_start, vma->vm_end, vma->vm_filesz);
            char *cuapp = (char*)uapp;
            char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(vma->vm_pgoff + va - vma->vm_start));
            for(uint64_t i = 0; i < PGSIZE; i++) cuapp[i] = celf[i];
        }

        create_mapping(current->pgd, va, VA2PA((uint64_t)uapp), PGSIZE, perm);
    }
}

uint64_t do_fork(struct pt_regs *regs){
    struct task_struct *ptask = (struct task_struct*)kalloc();
    // ptask->state = current->state;
    // ptask->counter = current->counter;
    // ptask->priority = current->priority;
    // ptask->pid = nr_tasks;
    // ptask->thread.ra = current->thread.ra; // fork之后返回的是0
    // ptask->thread.sp = (uint64_t)ptask + PGSIZE;

    // ptask->thread.sepc = (uint64_t)USER_START;
    
    // uint64_t _sstatus = ptask->thread.sstatus;
    // //csr_write(sstatus, _sstatus);
    // _sstatus &= ~(1 << 8);
    // _sstatus |= (1 << 5);
    // _sstatus |= (1 << 18); 
    // ptask->thread.sstatus = _sstatus;

    // ptask->thread.sscratch = (uint64_t)USER_END;
    char *ccurrent_task = (char*)current;
    char *cptask = (char*)ptask;
    for(uint64_t i = 0; i < PGSIZE; i++){
        cptask[i] = ccurrent_task[i];
    }
    ptask->pid = nr_tasks;
    ptask->thread.ra = __ret_from_fork;
    ptask->thread.sp = (uint64_t)ptask + (uint64_t)regs - PGROUNDDOWN((uint64_t)regs); // ??
    //ptask sscratch
    // LogBLUE("ptask->thread.sscratch = 0x%llx", ptask->thread.sscratch);
    // uint64_t _sscratch = csr_read(sscratch);
    // LogBLUE("sscratch = 0x%llx", _sscratch);
    ptask->thread.sscratch = csr_read(sscratch);
    ptask->thread.sepc = csr_read(sepc) + 4;
    
    struct pt_regs *ptregs = (struct pt_regs*)((uint64_t)regs - (uint64_t)current + (uint64_t)ptask);
    ptregs->x[10] = 0;  
    ptregs->x[2] = ptask->thread.sp;
    

    ptask->pgd = (uint64_t*)alloc_page();
    char *cpgtbl = (char*)ptask->pgd;
    char *cearly_pgtbl = (char*)swapper_pg_dir;
    for(uint64_t i = 0; i < PGSIZE; i++){
        cpgtbl[i] = cearly_pgtbl[i];
    }

    /*DEEP COPY*/
    ptask->mm.mmap = NULL;
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
        struct vm_area_struct *new_vma = (struct vm_area_struct*)kalloc();
        char *cvma = (char*)vma;
        char *cnew_vma = (char*)new_vma;
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
            cnew_vma[i] = cvma[i];
        }
        // LogBLUE("new_vma->vm_start = 0x%llx, new_vma->vm_end = 0x%llx", new_vma->vm_start, new_vma->vm_end);
        // LogBLUE("vma->vm_start = 0x%llx, vma->vm_end = 0x%llx", vma->vm_start, vma->vm_end);
        add_mmap(&ptask->mm, new_vma);

        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
            uint64_t perm = check_load(current->pgd, addr);
            if (!perm) continue;

            uint64_t *new_page = (uint64_t*)alloc_page();
            char *cnew_page = (char*)new_page;
            char *cpage = (char*)addr;
            for(uint64_t i = 0; i < PGSIZE; i++){
                cnew_page[i] = cpage[i];
            }
            create_mapping(ptask->pgd, addr, VA2PA((uint64_t)new_page), PGSIZE, perm);
        }
    }


    // load_program(ptask);
    task[nr_tasks] = ptask;
    nr_tasks++;
    return ptask->pid;
}

int check_load(uint64_t *pgtbl, uint64_t addr){
    uint64_t pgd_entry = *(pgtbl + ((addr >> 30) & 0x1ff));
    if (!(pgd_entry & PTE_V)) return 0;
    uint64_t *pmd = (uint64_t*)(PA2VA((uint64_t)((pgd_entry >> 10) << 12)));
    uint64_t pmd_entry = *(pmd + ((addr >> 21) & 0x1ff));
    if (!(pmd_entry & PTE_V)) return 0;
    uint64_t *pte = (uint64_t*)(PA2VA((uint64_t)((pmd_entry >> 10) << 12)));
    uint64_t pte_entry = *(pte + ((addr >> 12) & 0x1ff));
    if (!(pte_entry & PTE_V)) return 0;
    // return (pte_entry & PTE_R) | (pte_entry & PTE_X) | (pte_entry & PTE_W) | PTE_V | PTE_U; 
    return pte_entry & 0XFF;
}

void add_mmap(struct mm_struct *mm, struct vm_area_struct *new_vma){
    new_vma->vm_mm = mm;
    struct vm_area_struct *prev =  mm->mmap;
    if(!prev){
        mm->mmap = new_vma;
        new_vma->vm_next = NULL;
        new_vma->vm_prev = NULL;
    }else{
        mm->mmap = new_vma;
        new_vma->vm_next = prev;
        new_vma->vm_prev = NULL;
        prev->vm_prev = new_vma;
    }
    // return mm->mmap;
}

