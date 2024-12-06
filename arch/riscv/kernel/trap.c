#include "../../../user/syscall.h"
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "defs.h"
#include "proc.h"
#include "vm.h"
#include "mm.h"
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
        // uint64_t check = get_page_refcnt((void*)_stvac);
        // uint64_t exist = check_load(current->pgd, _stvac);
        // LogBLUE("exist = %d", exist);
        // uint64_t entry = pte_entry_ret(&(current->pgd), _stvac);
        // uint64_t check = get_page_refcnt((void *)(((entry >> 10) << 12) | (_stvac & 0xfff)));
        // // uint64_t check = check_load(current->pgd, _stvac);
        // if(!check) 
        do_page_fault(regs);
        // else{
        //     uint64_t perm  = check_cow(current->pgd, _stvac, &(current->mm));
        //     if(perm & perm != 0xfff){
        //         LogYELLOW("[COW]");
        //         page_cow(current->pgd, _stvac, perm);
        //     }
        // }
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
        uint64_t pid = do_fork_cow(regs);
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


// vma 没有
// vma 有 但是 pgd没有
// vma 有 pgd 有 （检查权限冲突 若是则为cow）
void do_page_fault(struct pt_regs *regs) {
    uint64_t _stval = csr_read(stval);
    uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
    struct vm_area_struct *vma = find_vma(&current->mm, _stval);
    if (!vma){  // vma 里面没有
        Err("No VMA found at 0x%llx", _stval);
        return;
    }
    uint64_t check = check_load(current->pgd, va);
    if (!check){
        uint64_t perm = (vma->vm_flags & VM_READ) | (vma->vm_flags & VM_EXEC) | (vma->vm_flags & VM_WRITE) | PTE_U | PTE_V; 
        if (vma->vm_flags & VM_ANON){
            LogDEEPGREEN("ANON");
            // uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
            uint64_t pa = VA2PA((uint64_t)alloc_page());
            create_mapping(current->pgd, va, pa, PGSIZE, perm);
        }else{
            LogDEEPGREEN("FILE");
            // uint64_t va = PGROUNDDOWN(_stval); 
            uint64_t *uapp = (uint64_t*)alloc_page();
            // LogBLUE("pa = 0x%llx, va = 0x%llx", VA2PA((uint64_t)uapp), _stval);
            if (PGROUNDDOWN(vma->vm_filesz) < PGSIZE){ // 整个uapp小于一页
                char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
                char *celf = (char*)_sramdisk + (vma->vm_start & 0xfff);
                for(uint64_t i = 0; i < vma->vm_filesz; i++) cuapp[i] = celf[i];
            }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start)){ // 从头开始
                char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
                char *celf = (char*)_sramdisk + (vma->vm_start & 0xfff);
                int i;
                // LogBLUE("0x%llx", PGSIZE - vma->vm_start & 0x1ff);
                for(i = 0; i < (PGSIZE - vma->vm_start & 0xfff); i++) {
                    cuapp[i] = celf[i];
                    //LogBLUE("[0x%llx] cuapp = 0x%llx, celf = 0x%llx", i, cuapp[i], celf[i]);
                }
                // LogBLUE("[0x%llx] cuapp = 0x%llx, celf = 0x%llx", i, cuapp[i], celf[i]);
            }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start + vma->vm_filesz - 1)){ // 最后一页
                char *cuapp = (char*)uapp;
                char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(va) - PGROUNDDOWN(vma->vm_start));
                for(uint64_t i = 0; i <= ((vma->vm_start + vma->vm_filesz) & 0xfff); i++) cuapp[i] = celf[i];
                // ! 这里要考虑漏掉一个字节的情况
            }else{ // 中间
                char *cuapp = (char*)uapp;
                char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(va) - PGROUNDDOWN(vma->vm_start));
                for(uint64_t i = 0; i < PGSIZE; i++) cuapp[i] = celf[i];
            }

            create_mapping(current->pgd, va, VA2PA((uint64_t)uapp), PGSIZE, perm);
        }
        return;
    }
    // LogYELLOW("check = 0x%llx", check);
    if ((vma->vm_flags & VM_WRITE) && !(check & PTE_W)){
        // uint64_t perm = check_cow(current->pgd, va, &current->mm);
        // if (perm & perm != 0xfff){
        //     LogYELLOW("[COW]");
        //     page_cow(current->pgd, va, perm);
        // }
        // LogYELLOW("[COW]");
        uint64_t entry = pte_entry_ret(current->pgd, va);
        // LogBLUE("pa = 0x%llx, va = 0x%llx", ((entry >> 10) << 12) | (_stval & 0xfff), _stval);
        uint64_t num = get_page_refcnt(PA2VA(((entry >> 10) << 12)));
        if (num == 1){
            LogYELLOW("[COW] PID = %d JUST CHANGE PERM", current->pid);
            // page_cow(current->pgd, va, check);
            change_perm(current->pgd, _stval);
        }else{
            LogYELLOW("[COW] PID = %d COPY PAGE", current->pid);
            // change_perm(current->pgd, _stval);
            // char *new_page = (char*)alloc_page();
            // LogBLUE("pa = 0x%llx, va = 0x%llx", VA2PA((uint64_t*)new_page), _stval);
            page_cow(current->pgd, va, check | PTE_W);
        }
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
    struct pt_regs *ptregs = (struct pt_regs*)((uint64_t)regs - (uint64_t)current + (uint64_t)ptask);
    ptregs->x[10] = 0;  
    ptregs->x[2] = ptask->thread.sp;
    ptask->thread.sepc = csr_read(sepc) + 4;

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
            create_mapping(ptask->pgd, addr, VA2PA((uint64_t*)new_page), PGSIZE, perm);
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

uint64_t do_fork_cow(struct pt_regs *regs){
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
    struct pt_regs *ptregs = (struct pt_regs*)((uint64_t)regs - (uint64_t)current + (uint64_t)ptask);
    ptregs->x[10] = 0;  
    ptregs->x[2] = ptask->thread.sp;
    ptask->thread.sepc = csr_read(sepc) + 4;

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
            uint64_t pte_entry = pte_entry_ret(current->pgd, addr); // 已经改了write bit
            // LogBLUE("pte_entry = 0x%llx, va = 0x%llx", pte_entry, addr);
            // LogBLUE("pa = 0x%llx", ((pte_entry >> 10) << 12) | (addr & 0xfff));
            // uint64_t *new_page = (uint64_t*)alloc_page();
            // char *cnew_page = (char*)new_page;
            // char *cpage = (char*)addr;
            // for(uint64_t i = 0; i < PGSIZE; i++){
            //     cnew_page[i] = cpage[i];
            // }
            
            get_page((PA2VA(((pte_entry >> 10) << 12))));
            create_mapping(ptask->pgd, addr, ((pte_entry >> 10) << 12), PGSIZE, (pte_entry&0xff));
        }
    }


    // load_program(ptask);
    task[nr_tasks] = ptask;
    nr_tasks++;
    asm volatile("sfence.vma zero, zero");
    return ptask->pid;
}

uint64_t pte_entry_ret(uint64_t *pgtbl, uint64_t addr){
    uint64_t pgd_entry = *(pgtbl + ((addr >> 30) & 0x1ff));
    uint64_t *pmd = (uint64_t*)(PA2VA((uint64_t)((pgd_entry >> 10) << 12)));
    uint64_t pmd_entry = *(pmd + ((addr >> 21) & 0x1ff));
    uint64_t *pte = (uint64_t*)(PA2VA((uint64_t)((pmd_entry >> 10) << 12)));
    uint64_t pte_entry = *(pte + ((addr >> 12) & 0x1ff));
    *(pte + ((addr >> 12) & 0x1ff)) = pte_entry & (~(1 << 2)); // clear wirte bit
    // asm volatile("sfence.vma zero, zero");
    return pte_entry & (~(1 << 2));
}

//返回true表示是COW，返回false表示不是COW
uint64_t check_cow(uint64_t *pgtbl, uint64_t addr, struct mm_struct *mm){
    struct vm_area_struct *vma = find_vma(mm, addr);
    if (!vma){
        Err("No VMA found at 0x%llx", addr);
        return 0;
    }

    uint64_t perm = check_load(pgtbl, addr);

    if (perm & PTE_W){
        return 0;
    }else if (vma->vm_flags & VM_WRITE){
        uint64_t entry = pte_entry_ret(pgtbl, addr);
        if(get_page_refcnt((void *)PA2VA((((entry >> 10) << 12) | (addr & 0xfff)))) == 1){
            change_perm(pgtbl, addr);
            return 0xFFF;
        }
        return perm | PTE_W;
    }
}

void page_cow(uint64_t *pgtbl, uint64_t addr, uint64_t perm){
    char *new_page = (char*)alloc_page();

    char *cpage = (char*)addr;
    LogBLUE("addr = 0x%llx, new_page = 0x%llx", addr, new_page);
    // char *cnewpage = (char*)new_page;
    for (uint64_t i = 0; i < PGSIZE; i++){
        new_page[i] = cpage[i];
    }
    uint64_t entry = pte_entry_ret(pgtbl, addr);
    put_page(PA2VA(((entry >> 10) << 12)));
    
    create_mapping(pgtbl, addr, VA2PA((uint64_t)new_page), PGSIZE, perm);
    asm volatile("sfence.vma zero, zero");
    
}

void change_perm(uint64_t *pgtbl, uint64_t addr){
    uint64_t pgd_entry = *(pgtbl + ((addr >> 30) & 0x1ff));
    uint64_t *pmd = (uint64_t*)(PA2VA((uint64_t)((pgd_entry >> 10) << 12)));
    uint64_t pmd_entry = *(pmd + ((addr >> 21) & 0x1ff));
    uint64_t *pte = (uint64_t*)(PA2VA((uint64_t)((pmd_entry >> 10) << 12)));
    uint64_t pte_entry = *(pte + ((addr >> 12) & 0x1ff));
    *(pte + ((addr >> 12) & 0x1ff)) = pte_entry | (1 << 2); // clear wirte bit
    asm volatile("sfence.vma zero, zero");
    return pte_entry | (1 << 2);
}