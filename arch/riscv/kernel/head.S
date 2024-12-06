    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top

    # set stvec = _traps
    la t0, _traps
    csrw stvec, t0
    # set sie[STIE] = 1
    addi t0, zero, 0x20
    csrw sie, t0
    # set first time interrupt
    rdtime t0
    li t1, 10000000
    add t0, t0, t1
    add a0, zero, t0
    addi a1, zero, 0
    addi a2, zero, 0
    addi a3, zero, 0
    addi a4, zero, 0
    addi a5, zero, 0
    li a7, 0x54494d45
    addi a6, zero, 0
    ecall
    # set sstatus[SIE] = 1
    csrwi sstatus, 0x2

    jal start_kernel

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096

    .globl boot_stack_top
boot_stack_top: