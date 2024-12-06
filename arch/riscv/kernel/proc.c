#include "mm.h"
#include "defs.h"
#include "proc.h"
#include "stdlib.h"
#include "printk.h"
#include "elf.h"

extern void __dummy();
extern void __switch_to(struct task_struct *prev, struct task_struct *next);

#define VA2PA(x) ((x - (uint64_t)PA2VA_OFFSET))
#define PA2VA(x) ((x + (uint64_t)PA2VA_OFFSET))
#define PFN2PHYS(x) (((uint64_t)(x) << 12) + PHY_START)
#define PHYS2PFN(x) ((((uint64_t)(x) - PHY_START) >> 12))

extern uint64_t swapper_pg_dir[];
extern char _sramdisk[], _eramdisk[];

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

// void task_init() {
//     srand(2024);

//     // 1. 调用 kalloc() 为 idle 分配一个物理页
//     idle = (struct task_struct*)kalloc();
//     // 2. 设置 state 为 TASK_RUNNING;
//     idle->state = TASK_RUNNING;
//     // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
//     idle->counter = 0;
//     idle->priority = 0;
//     // 4. 设置 idle 的 pid 为 0
//     idle->pid = 0;

//     // 5. 将 current 和 task[0] 指向 idle
//     current = idle;
//     task[0] = idle;

//     /* YOUR CODE HERE */

//     // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
//     for (int i = 1; i < NR_TASKS; i++){
//         struct task_struct *ptask = (struct task_struct*)kalloc();
//         // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
//         //     - counter  = 0;
//         //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
//         ptask->state = TASK_RUNNING;
//         ptask->counter = 0;
//         ptask->priority = (uint64_t)rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
//         // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
//         //     - ra 设置为 __dummy（见 4.2.2）的地址
//         //     - sp 设置为该线程申请的物理页的高地址
//         ptask->pid = i;
//         ptask->thread.ra = (uint64_t)__dummy;
//         ptask->thread.sp = (uint64_t)ptask + PGSIZE;

//         /*Lab4*/
//         ptask->thread.sepc = (uint64_t)USER_START;
        
//         uint64_t _sstatus = ptask->thread.sstatus;
//         //csr_write(sstatus, _sstatus);
//         _sstatus &= ~(1 << 8);
//         _sstatus |= (1 << 5);
//         _sstatus |= (1 << 18); 
//         ptask->thread.sstatus = _sstatus;

//         ptask->thread.sscratch = (uint64_t)USER_END;


//         uint64_t va = USER_START;
//         uint64_t pa = VA2PA((uint64_t)(_sramdisk));
//         // uint64_t * pgtbl = (uint64_t*)kalloc();
//         ptask->pgd = (uint64_t*)alloc_page();
//         // PAGE_COPY(swapper_pg_dir, pgtbl);
//         for(uint64_t i = 0; i < PGSIZE; i++){
//             // char *cpgtbl = (char*)pgtbl;
//             char *cpgtbl = (char*)ptask->pgd;
//             char *cearly_pgtbl = (char*)swapper_pg_dir;
//             cpgtbl[i] = cearly_pgtbl[i];
//             if (cpgtbl[i] != cearly_pgtbl[i]) LogRED("cpgtbl[%d] = cearly_pgtbl[%d] = %c", i, i, cpgtbl[i]);
//         }
//         LogGREEN("_sramdisk = %p, _eramdisk = %p", _sramdisk, _eramdisk);

//         uint64_t* uapp = (uint64_t*)alloc_pages(((uint64_t)_eramdisk - (uint64_t)_sramdisk + PGSIZE - 1)/PGSIZE);
//         for(uint64_t i = 0; i < ((uint64_t)_eramdisk - (uint64_t)_sramdisk + PGSIZE - 1)/PGSIZE; i++){
//             // PAGE_COPY((uint64_t*)_sramdisk + i * PGSIZE, uapp + i * PGSIZE);
//             char *cupp = (char*)uapp + i * PGSIZE;
//             char *csramdisk = (char*)_sramdisk + i * PGSIZE;
//             for(uint64_t j = 0; j < PGSIZE; j++){
//                 cupp[j] = csramdisk[j];
//                 // LogBLUE("cupp[%d] = csramdisk[%d] = %c", j, j, cupp[j]);
//             }
//             LogGREEN("uapp = 0x%llx, *_sramdisk = 0x%llx", *((uint64_t*)uapp + i * PGSIZE/8), *((uint64_t*)_sramdisk + i * PGSIZE/8));
//         }
//         create_mapping(ptask->pgd, va, VA2PA((uint64_t)uapp), (uint64_t)_eramdisk - (uint64_t)_sramdisk, PTE_R | PTE_W | PTE_X | PTE_U | PTE_V);
//         uint64_t usp = (uint64_t)alloc_page();
//         va = USER_END - PGSIZE;
//         create_mapping(ptask->pgd, va, VA2PA(usp), PGSIZE, PTE_R | PTE_W | PTE_U | PTE_V);
//         LogGREEN("[S-MODE] SET PID = %d, PGD = 0x%llx, PRIORITY = %d", ptask->pid, ptask->pgd, ptask->priority);
                
//         task[i] = ptask;
//     }
//     /* YOUR CODE HERE */

//     printk("...task_init done!\n");
// }

#if TEST_SCHED
#define MAX_OUTPUT ((NR_TASKS - 1) * 10)
char tasks_output[MAX_OUTPUT];
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    uint64_t MOD = 1000000007;
    uint64_t auto_inc_local_var = 0;
    int last_counter = -1;
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
            if (current->counter == 1) {
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
            if (tasks_output_index == MAX_OUTPUT) {
                for (int i = 0; i < MAX_OUTPUT; ++i) {
                    if (tasks_output[i] != expected_output[i]) {
                        printk("\033[31mTest failed!\033[0m\n");
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
            }
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
    if(current == next) {
        return;
    }else{
        printk("switch_to: %d -> %d\n", current->pid, next->pid);
        struct task_struct *prev = current;
        current = next;
        printk("switch ing\n");
        __switch_to(prev, next);
        printk("switch done\n");
    }
}

void do_timer() {
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    printk("do_timer: current->pid = %d\n", current->pid);
    // YOUR CODE HERE
    if (current == idle || current->counter == 0) {
        printk("do_timer: schedule\n");
        schedule();
    } else {
        current->counter --;
        if (current->counter == 0) {
            printk("do_timer: schedule2\n");
            schedule();
        }
    }
}

void schedule() {
    // YOUR CODE HERE
    int maxCounter = -1;
    int index = -1;
    for (int i = 1; i < NR_TASKS; ++i) {
        printk("schedule: %d -> %d\n", task[i]->pid, task[i] -> counter);
        if (task[i]->state == TASK_RUNNING && (int)task[i]->counter > maxCounter) {
            printk("mamba\n");
            maxCounter = task[i]->counter;
            index = i;
        }
    }

    if (maxCounter == 0) {
        for (int i = 1; i < NR_TASKS; ++i) {
            if (task[i]->state == TASK_RUNNING) {
                task[i]->counter = task[i]->priority;
            }
            printk("schedule2: %d -> %d\n", task[i]->pid, task[i] -> counter);
        }
        schedule();
    } else {
        switch_to(task[index]);
    }
}

void load_program(struct task_struct *task) {
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;

    LogGREEN("ehdr->e_ident = 0x%llx", *((uint64_t*)ehdr->e_ident));
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
    for (int i = 0; i < ehdr->e_phnum; ++i) {
        Elf64_Phdr *phdr = phdrs + i;
        if (phdr->p_type == PT_LOAD) {
            // alloc space and copy content
            uint64_t _ssegment = (uint64_t)_sramdisk + phdr->p_offset;
            uint64_t* segment = (uint64_t*)alloc_pages((phdr->p_memsz + (phdr->p_vaddr & 0xfff) + PGSIZE - 1) / PGSIZE);
            
            char *csegment = (char*)segment + (phdr->p_vaddr & 0xfff);
            char *_csegment = (char*)_ssegment;
            for(uint64_t i = 0; i < (uint64_t)phdr->p_filesz; i++){
                csegment[i] = _csegment[i];
            }
            memset((char*)segment + phdr->p_filesz + (phdr->p_vaddr & 0xfff), 0, phdr->p_memsz - phdr->p_filesz);

            // do mapping
            uint64_t perm = PTE_U | PTE_V | (phdr->p_flags & PF_X) << 3 | (phdr->p_flags & PF_W) << 1 | (phdr->p_flags & PF_R) >> 1;
            create_mapping(task->pgd, phdr->p_vaddr, VA2PA((uint64_t)segment), phdr->p_memsz + (phdr->p_vaddr & 0xfff), perm);
            LogBLUE("va: 0x%llx, pa: 0x%llx, size: 0x%llx, perm: 0x%llx", phdr->p_vaddr, VA2PA((uint64_t)segment), phdr->p_memsz + (phdr->p_vaddr & 0xfff), perm);
        }
    }
    uint64_t usp = (uint64_t)alloc_page();
    create_mapping(task->pgd, USER_END - PGSIZE, VA2PA(usp), PGSIZE, PTE_R | PTE_W | PTE_U | PTE_V);
    task->thread.sepc = ehdr->e_entry;
}

//7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00

/*ELF*/

void task_init() {
    srand(2024);

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
    idle->priority = 0;
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;

    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
    task[0] = idle;

    /* YOUR CODE HERE */

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    for (int i = 1; i < NR_TASKS; i++){
        struct task_struct *ptask = (struct task_struct*)kalloc();
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
        ptask->state = TASK_RUNNING;
        ptask->counter = 0;
        ptask->priority = (uint64_t)rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
        // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址
        ptask->pid = i;
        ptask->thread.ra = (uint64_t)__dummy;
        ptask->thread.sp = (uint64_t)ptask + PGSIZE;

        /*Lab4*/
        ptask->thread.sepc = (uint64_t)USER_START;
        
        uint64_t _sstatus = ptask->thread.sstatus;
        //csr_write(sstatus, _sstatus);
        _sstatus &= ~(1 << 8);
        _sstatus |= (1 << 5);
        _sstatus |= (1 << 18); 
        ptask->thread.sstatus = _sstatus;

        ptask->thread.sscratch = (uint64_t)USER_END;

        ptask->pgd = (uint64_t*)alloc_page();
        // PAGE_COPY(swapper_pg_dir, pgtbl);
        for(uint64_t i = 0; i < PGSIZE; i++){
            // char *cpgtbl = (char*)pgtbl;
            char *cpgtbl = (char*)ptask->pgd;
            char *cearly_pgtbl = (char*)swapper_pg_dir;
            cpgtbl[i] = cearly_pgtbl[i];
            if (cpgtbl[i] != cearly_pgtbl[i]) LogRED("cpgtbl[%d] = cearly_pgtbl[%d] = %c", i, i, cpgtbl[i]);
        }
        LogGREEN("_sramdisk = %p, _eramdisk = %p", _sramdisk, _eramdisk);

        load_program(ptask);
        LogGREEN("[S-MODE] SET PID = %d, PGD = 0x%llx, PRIORITY = %d", ptask->pid, ptask->pgd, ptask->priority);
                
        task[i] = ptask;
    }
    /* YOUR CODE HERE */

    printk("...task_init done!\n");
}