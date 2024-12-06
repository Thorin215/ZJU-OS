#include "../../../user/syscall.h"
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "defs.h"
#include "proc.h"

extern struct task_struct *current;

void trap_handler(uint64_t scause, uint64_t sepc, uint64_t sstatus, struct pt_regs *regs) {
    // 通过 `scause` 判断 trap 类型
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
    }else if(scause == 0xf){
        LogRED("Store/AMO Page Fault");
    }else if(scause == 0xd){
        LogRED("Load Page Fault");
    }else if(scause == 0x8){
        LogRED("Environment Call from U-mode");
        syscall(regs);
    }

    if (scause & 0x8000000000000000) {
        csr_write(sepc, sepc);
    } else {
        csr_write(sepc, sepc + 4);
    }
    LogPURPLE("scause: 0x%llx, sstatus: 0x%llx, sepc: 0x%llx", scause, sstatus, sepc);
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
    } else {
        LogRED("Unsupported syscall: %d", syscall_num);
    }
    return;
}