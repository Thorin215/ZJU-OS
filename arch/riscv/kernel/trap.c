#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "defs.h"
#include "proc.h"
void trap_handler(uint64_t scause, uint64_t sepc) {
    // 通过 `scause` 判断 trap 类型
    if(scause == 0x8000000000000005){
        LogRED("Timer Interrupt");
        LogPURPLE("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
        clock_set_next_event();
        do_timer();
    }else if(scause == 0x000000000000000c){
        LogRED("Instruction Page Fault");
        LogPURPLE("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
        if(sepc < VM_START){
            LogGREEN("[Physical Address: 0x%llx] -> [Virtual Address: 0x%llx]", sepc, sepc + 0xffffffdf80000000);
            csr_write(sepc, sepc + 0xffffffdf80000000);

            return;
        }
    }else if(scause == 0x000000000000000f){
        LogRED("Store/AMO Page Fault");
        LogPURPLE("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
    }else if(scause == 0x000000000000000d){
        LogRED("Load Page Fault");
        LogPURPLE("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
    }
    if (scause & 0x8000000000000000) {
        csr_write(sepc, sepc);
    } else {
        csr_write(sepc, sepc + 4);
    }
    // LogGREEN("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
}

void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
    // printk("sscratch: 0x%lx\n", csr_read(sscratch));
    csr_write(sscratch, value);
    // printk("sstatus: 0x%lx\n", csr_read(sstatus));
    // printk("sscratch: 0x%lx\n", csr_read(sscratch));
}