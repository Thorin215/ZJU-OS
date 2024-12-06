#include "printk.h"

extern void test();

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

int start_kernel() {
    printk("2024");
    printk(" ZJU Operating System\n");
    schedule();

    test();
    return 0;
}
