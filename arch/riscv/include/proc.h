#ifndef __PROC_H__
#define __PROC_H__

#include "stdint.h"

#if TEST_SCHED
#define NR_TASKS (1 + 4)    // 测试时线程数量
#else
#define NR_TASKS (1 + 8)   // 用于控制最大线程数量（idle 线程 + 31 内核线程）
#endif

#define TASK_RUNNING 0      // 为了简化实验，所有的线程都只有一种状态

#define PRIORITY_MIN 1
#define PRIORITY_MAX 10

struct thread_struct {
    uint64_t ra;
    uint64_t sp;                     
    uint64_t s[12];
    uint64_t sepc, sstatus, sscratch; 
};

struct vm_area_struct {
    struct mm_struct *vm_mm;    // 所属的 mm_struct
    uint64_t vm_start;          // VMA 对应的用户态虚拟地址的开始
    uint64_t vm_end;            // VMA 对应的用户态虚拟地址的结束
    struct vm_area_struct *vm_next, *vm_prev;   // 链表指针
    uint64_t vm_flags;          // VMA 对应的 flags
    // struct file *vm_file;    // 对应的文件（目前还没实现，而且我们只有一个 uapp 所以暂不需要）
    uint64_t vm_pgoff;          // 如果对应了一个文件，那么这块 VMA 起始地址对应的文件内容相对文件起始位置的偏移量
    uint64_t vm_filesz;         // 对应的文件内容的长度
};

struct mm_struct {
    struct vm_area_struct *mmap;
};

struct task_struct {
    uint64_t state;
    uint64_t counter;
    uint64_t priority;
    uint64_t pid;

    struct thread_struct thread;
    uint64_t *pgd;  // 用户态页表
    struct mm_struct mm;
};

struct pt_regs
{
    uint64_t x[32];
};

/* 线程初始化，创建 NR_TASKS 个线程 */
void task_init();

/* 在时钟中断处理中被调用，用于判断是否需要进行调度 */
void do_timer();

/* 调度程序，选择出下一个运行的线程 */
void schedule();

/* 线程切换入口函数 */
void switch_to(struct task_struct *next);

/* dummy funciton: 一个循环程序，循环输出自己的 pid 以及一个自增的局部变量 */
void dummy();

/*
* @mm       : current thread's mm_struct
* @addr     : the va to look up
*
* @return   : the VMA if found or NULL if not found
*/
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr);

/*
* @mm       : current thread's mm_struct
* @addr     : the va to map
* @len      : memory size to map
* @vm_pgoff : phdr->p_offset
* @vm_filesz: phdr->p_filesz
* @flags    : flags for the new VMA
*
* @return   : start va
*/
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags);

void add_mmap(struct mm_struct *mm, struct vm_area_struct *new_vma);

int check_load(uint64_t *pgtbl, uint64_t addr);

uint64_t do_fork(struct pt_regs *regs);

uint64_t check_cow(uint64_t *pgtbl, uint64_t addr, struct mm_struct *mm);

uint64_t do_fork_cow(struct pt_regs *regs);

uint64_t pte_entry_ret(uint64_t *pgtbl, uint64_t addr);

// //返回true表示是COW，返回false表示不是COW
// uint64_t check_cow(uint64_t *pgtbl, uint64_t addr, struct mm_struct *mm);

void page_cow(uint64_t *pgtbl, uint64_t addr, uint64_t perm);

void change_perm(uint64_t *pgtbl, uint64_t addr);

#endif
