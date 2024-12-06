#include "printk.h"

extern void test();

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

int start_kernel() {
    printk("2024");
    printk(" ZJU Operating System\n");
    LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);
    *_stext = 0x0;
    *_etext = 0x1;
    *_srodata = 0x0;
    *_erodata = 0x1;
    LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);
    test();
    return 0;
}
