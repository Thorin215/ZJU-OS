#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "defs.h"
void trap_handler(uint64_t scause, uint64_t sepc) {
    // 通过 `scause` 判断 trap 类型
    if(scause == 0x8000000000000005){
        printk("timer interrupt\n");
        clock_set_next_event();
    }
    // 如果是 interrupt 判断是否是 timer interrupt
    
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    
    // `clock_set_next_event()` 见 4.3.4 节
    
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
    printk((scause & 0x8000000000000000) > 0 ? "Interrupt: " : "Exception: ");
    printk("scause: 0x%lx\n", scause);
    printk("sepc: 0x%lx\n", sepc);

}

void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
    printk("sscratch: 0x%lx\n", csr_read(sscratch));
    csr_write(sscratch, value);
    printk("sstatus: 0x%lx\n", csr_read(sstatus));
    printk("sscratch: 0x%lx\n", csr_read(sscratch));
}