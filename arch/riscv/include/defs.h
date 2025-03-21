#ifndef __DEFS_H__
#define __DEFS_H__

#include "stdint.h"

#define PHY_START 0x0000000080000000
#define PHY_SIZE 128 * 1024 * 1024 // 128 MiB，QEMU 默认内存大小
#define PHY_END (PHY_START + PHY_SIZE)

#define VA2PA(x) ((x - (uint64_t)PA2VA_OFFSET))
#define PA2VA(x) ((x + (uint64_t)PA2VA_OFFSET))
#define PFN2PHYS(x) (((uint64_t)(x) << 12) + PHY_START)
#define PHYS2PFN(x) ((((uint64_t)(x) - PHY_START) >> 12))



#define PGSIZE 0x1000 // 4 KiB
#define PGROUNDUP(addr) ((addr + PGSIZE - 1) & (~(PGSIZE - 1)))
#define PGROUNDDOWN(addr) (addr & (~(PGSIZE - 1)))

#define OPENSBI_SIZE (0x200000)

#define VM_START (0xffffffe000000000)
#define VM_END (0xffffffff00000000)
#define VM_SIZE (VM_END - VM_START)

#define USER_START (0x0000000000000000) // user space start virtual address
#define USER_END (0x0000004000000000) // user space end virtual address

#define PA2VA_OFFSET (VM_START - PHY_START)

#define PTE_V  0x1
#define PTE_R  0x2
#define PTE_W  0x4
#define PTE_X  0x8
#define PTE_U  0x10

#define VM_ANON 0x1
#define VM_READ 0x2
#define VM_WRITE 0x4
#define VM_EXEC 0x8

#define csr_read(csr)                   \
  ({                                    \
    uint64_t __v;                       \
    asm volatile("csrr %0, " #csr : "=r"(__v) : : "memory"); \
    __v;                                \
  })

#define csr_write(csr, val)                                    \
  ({                                                           \
    uint64_t __v = (uint64_t)(val);                            \
    asm volatile("csrw " #csr ", %0" : : "r"(__v) : "memory"); \
  })

#endif
