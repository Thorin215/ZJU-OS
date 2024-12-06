    .extern start_kernel
    .extern _srodata
    .extern task_init
    .extern mm_init
    .extern setup_vm
    .extern setup_vm_final
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
    
    call setup_vm
    call relocate

    call mm_init

    call setup_vm_final

    call task_init

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
    # csrwi sstatus, 0x2

    jal start_kernel
    # jal _srodata

relocate:
    li t0, 0xffffffdf80000000
    # set ra = ra + PA2VA_OFFSET
    add ra, ra, t0
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    add sp, sp, t0

    ###################### 
    #   YOUR CODE HERE   #
    ######################

    # la a0, _traps
    # add a0, a0, t0
    # csrw stvec, a0

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero

    # set satp with early_pgtbl
    la t1, early_pgtbl
    
    # MODE = 0X8
    li t2, 0x8000000000000000
    srli t1, t1, 12
    add t1, t1, t2
    csrw satp, t1
    # csrs satp, t2
    ###################### 
    #   YOUR CODE HERE   #
    ######################

    ret

    .section .bss.stack
    .globl boot_stack
boot_stack:
    .space 4096

    .globl boot_stack_top
boot_stack_top: