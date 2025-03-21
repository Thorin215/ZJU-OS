    .extern trap_handler
    .extern csr_change
    .section .text.entry
    .align 2
    .globl _traps 

_traps:
    # 1. save 32 registers and sepc to stack

    csrr t0, sscratch
    beq t0, x0, _traps_smode

_traps_umode:    # 切换用户态的栈
    csrw sscratch, sp
    add sp, t0, x0

_traps_smode:   # 切换内核态的栈
    addi sp, sp, -256
    sd x0, 0(sp)
    sd x1, 8(sp)
    sd x2, 16(sp)
    sd x3, 24(sp)
    sd x4, 32(sp)
    sd x5, 40(sp)
    sd x6, 48(sp)
    sd x7, 56(sp)
    sd x8, 64(sp)
    sd x9, 72(sp)
    sd x10, 80(sp)
    sd x11, 88(sp)
    sd x12, 96(sp)
    sd x13, 104(sp)
    sd x14, 112(sp)
    sd x15, 120(sp)
    sd x16, 128(sp)
    sd x17, 136(sp)
    sd x18, 144(sp)
    sd x19, 152(sp)
    sd x20, 160(sp)
    sd x21, 168(sp)
    sd x22, 176(sp)
    sd x23, 184(sp)
    sd x24, 192(sp)
    sd x25, 200(sp)
    sd x26, 208(sp)
    sd x27, 216(sp)
    sd x28, 224(sp)
    sd x29, 232(sp)
    sd x30, 240(sp)
    sd x31, 248(sp)

    csrr a0, scause
    csrr a1, sepc
    csrr a2, sstatus
    add a3, sp, x0
    call trap_handler

.globl __ret_from_fork
__ret_from_fork:

    ld x0, 0(sp)
    ld x1, 8(sp)

    ld x3, 24(sp)
    ld x4, 32(sp)
    ld x5, 40(sp)
    ld x6, 48(sp)
    ld x7, 56(sp)
    ld x8, 64(sp)
    ld x9, 72(sp)
    ld x10, 80(sp)
    ld x11, 88(sp)
    ld x12, 96(sp)
    ld x13, 104(sp)
    ld x14, 112(sp)
    ld x15, 120(sp)
    ld x16, 128(sp)
    ld x17, 136(sp)
    ld x18, 144(sp)
    ld x19, 152(sp)
    ld x20, 160(sp)
    ld x21, 168(sp)
    ld x22, 176(sp)
    ld x23, 184(sp)
    ld x24, 192(sp)
    ld x25, 200(sp)
    ld x26, 208(sp)
    ld x27, 216(sp)
    ld x28, 224(sp)
    ld x29, 232(sp)
    ld x30, 240(sp)
    ld x31, 248(sp)
    ld x2, 16(sp)
    addi sp, sp, 256
    # 4. return from trap

    csrr t0, sscratch
    beq t0, x0, _smode_ret

_umode_ret:

    csrw sscratch, sp
    add sp, t0, x0

_smode_ret:
    sret

    .extern dummy
    .globl __dummy
__dummy:
    csrr t0, sscratch
    csrw sscratch, sp
    add sp, t0, x0
    sret

    .globl __switch_to
__switch_to:
    # save state to prev process
    # YOUR CODE HERE    
    #保存当前线程的 ra，sp，s0~s11 到当前线程的 thread_struct 中
    sd ra, 32(a0)
    sd sp, 40(a0)
    sd s0, 48(a0)
    sd s1, 56(a0)
    sd s2, 64(a0)
    sd s3, 72(a0)
    sd s4, 80(a0)
    sd s5, 88(a0)
    sd s6, 96(a0)
    sd s7, 104(a0)
    sd s8, 112(a0)
    sd s9, 120(a0)
    sd s10, 128(a0)
    sd s11, 136(a0)

    /*Lab4*/
    csrr t0, sepc
    sd t0, 144(a0)
    csrr t0, sstatus
    sd t0, 152(a0)
    csrr t0, sscratch
    sd t0, 160(a0)

    ld ra, 32(a1)
    ld sp, 40(a1)
    ld s0, 48(a1)
    ld s1, 56(a1)
    ld s2, 64(a1)
    ld s3, 72(a1)
    ld s4, 80(a1)
    ld s5, 88(a1)
    ld s6, 96(a1)
    ld s7, 104(a1)
    ld s8, 112(a1)
    ld s9, 120(a1)
    ld s10, 128(a1)
    ld s11, 136(a1)

    /*Lab4*/
    ld t0, 144(a1)
    csrw sepc, t0
    ld t0, 152(a1)
    csrw sstatus, t0
    ld t0, 160(a1)
    csrw sscratch, t0

    ld t0, 168(a1)
    li t1, 0xffffffdf80000000
    sub t0, t0, t1
    srli t0, t0, 12
    li t2, 0x8000000000000000
    or t2, t2, t0
    csrw satp, t2

    sfence.vma zero, zero

    ret