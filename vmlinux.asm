
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .extern setup_vm
    .extern setup_vm_final
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
ffffffe000200000:	00009117          	auipc	sp,0x9
ffffffe000200004:	00010113          	mv	sp,sp
    
    call setup_vm
ffffffe000200008:	650020ef          	jal	ra,ffffffe000202658 <setup_vm>
    call relocate
ffffffe00020000c:	060000ef          	jal	ra,ffffffe00020006c <relocate>

    call mm_init
ffffffe000200010:	285000ef          	jal	ra,ffffffe000200a94 <mm_init>

    call setup_vm_final
ffffffe000200014:	770020ef          	jal	ra,ffffffe000202784 <setup_vm_final>

    call task_init
ffffffe000200018:	739000ef          	jal	ra,ffffffe000200f50 <task_init>

    # set stvec = _traps
    la t0, _traps
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	08428293          	addi	t0,t0,132 # ffffffe0002000a0 <_traps>
    csrw stvec, t0
ffffffe000200024:	10529073          	csrw	stvec,t0
    # set sie[STIE] = 1
    addi t0, zero, 0x20
ffffffe000200028:	02000293          	li	t0,32
    csrw sie, t0
ffffffe00020002c:	10429073          	csrw	sie,t0
    # set first time interrupt
    rdtime t0
ffffffe000200030:	c01022f3          	rdtime	t0
    li t1, 10000000
ffffffe000200034:	00989337          	lui	t1,0x989
ffffffe000200038:	6803031b          	addiw	t1,t1,1664 # 989680 <OPENSBI_SIZE+0x789680>
    add t0, t0, t1
ffffffe00020003c:	006282b3          	add	t0,t0,t1
    add a0, zero, t0
ffffffe000200040:	00500533          	add	a0,zero,t0
    addi a1, zero, 0
ffffffe000200044:	00000593          	li	a1,0
    addi a2, zero, 0
ffffffe000200048:	00000613          	li	a2,0
    addi a3, zero, 0
ffffffe00020004c:	00000693          	li	a3,0
    addi a4, zero, 0
ffffffe000200050:	00000713          	li	a4,0
    addi a5, zero, 0
ffffffe000200054:	00000793          	li	a5,0
    li a7, 0x54494d45
ffffffe000200058:	544958b7          	lui	a7,0x54495
ffffffe00020005c:	d458889b          	addiw	a7,a7,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
    addi a6, zero, 0
ffffffe000200060:	00000813          	li	a6,0
    ecall
ffffffe000200064:	00000073          	ecall
    # set sstatus[SIE] = 1
    # csrwi sstatus, 0x2

    jal start_kernel
ffffffe000200068:	331020ef          	jal	ra,ffffffe000202b98 <start_kernel>

ffffffe00020006c <relocate>:
    # jal _srodata

relocate:
    li t0, 0xffffffdf80000000
ffffffe00020006c:	fbf0029b          	addiw	t0,zero,-65
ffffffe000200070:	01f29293          	slli	t0,t0,0x1f
    # set ra = ra + PA2VA_OFFSET
    add ra, ra, t0
ffffffe000200074:	005080b3          	add	ra,ra,t0
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    add sp, sp, t0
ffffffe000200078:	00510133          	add	sp,sp,t0
    # la a0, _traps
    # add a0, a0, t0
    # csrw stvec, a0

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero
ffffffe00020007c:	12000073          	sfence.vma

    # set satp with early_pgtbl
    la t1, early_pgtbl
ffffffe000200080:	0000a317          	auipc	t1,0xa
ffffffe000200084:	f8030313          	addi	t1,t1,-128 # ffffffe00020a000 <early_pgtbl>
    
    # MODE = 0X8
    li t2, 0x8000000000000000
ffffffe000200088:	fff0039b          	addiw	t2,zero,-1
ffffffe00020008c:	03f39393          	slli	t2,t2,0x3f
    srli t1, t1, 12
ffffffe000200090:	00c35313          	srli	t1,t1,0xc
    add t1, t1, t2
ffffffe000200094:	00730333          	add	t1,t1,t2
    csrw satp, t1
ffffffe000200098:	18031073          	csrw	satp,t1
    # csrs satp, t2
    ###################### 
    #   YOUR CODE HERE   #
    ######################

    ret
ffffffe00020009c:	00008067          	ret

ffffffe0002000a0 <_traps>:
    .globl _traps 

_traps:
    # 1. save 32 registers and sepc to stack

    csrr t0, sscratch
ffffffe0002000a0:	140022f3          	csrr	t0,sscratch
    beq t0, x0, _traps_smode
ffffffe0002000a4:	00028663          	beqz	t0,ffffffe0002000b0 <_traps_smode>

ffffffe0002000a8 <_traps_umode>:

_traps_umode:    # 切换用户态的栈
    csrw sscratch, sp
ffffffe0002000a8:	14011073          	csrw	sscratch,sp
    add sp, t0, x0
ffffffe0002000ac:	00028133          	add	sp,t0,zero

ffffffe0002000b0 <_traps_smode>:

_traps_smode:   # 切换内核态的栈
    addi sp, sp, -256
ffffffe0002000b0:	f0010113          	addi	sp,sp,-256 # ffffffe000208f00 <_sbss+0xf00>
    sd x0, 0(sp)
ffffffe0002000b4:	00013023          	sd	zero,0(sp)
    sd x1, 8(sp)
ffffffe0002000b8:	00113423          	sd	ra,8(sp)
    sd x2, 16(sp)
ffffffe0002000bc:	00213823          	sd	sp,16(sp)
    sd x3, 24(sp)
ffffffe0002000c0:	00313c23          	sd	gp,24(sp)
    sd x4, 32(sp)
ffffffe0002000c4:	02413023          	sd	tp,32(sp)
    sd x5, 40(sp)
ffffffe0002000c8:	02513423          	sd	t0,40(sp)
    sd x6, 48(sp)
ffffffe0002000cc:	02613823          	sd	t1,48(sp)
    sd x7, 56(sp)
ffffffe0002000d0:	02713c23          	sd	t2,56(sp)
    sd x8, 64(sp)
ffffffe0002000d4:	04813023          	sd	s0,64(sp)
    sd x9, 72(sp)
ffffffe0002000d8:	04913423          	sd	s1,72(sp)
    sd x10, 80(sp)
ffffffe0002000dc:	04a13823          	sd	a0,80(sp)
    sd x11, 88(sp)
ffffffe0002000e0:	04b13c23          	sd	a1,88(sp)
    sd x12, 96(sp)
ffffffe0002000e4:	06c13023          	sd	a2,96(sp)
    sd x13, 104(sp)
ffffffe0002000e8:	06d13423          	sd	a3,104(sp)
    sd x14, 112(sp)
ffffffe0002000ec:	06e13823          	sd	a4,112(sp)
    sd x15, 120(sp)
ffffffe0002000f0:	06f13c23          	sd	a5,120(sp)
    sd x16, 128(sp)
ffffffe0002000f4:	09013023          	sd	a6,128(sp)
    sd x17, 136(sp)
ffffffe0002000f8:	09113423          	sd	a7,136(sp)
    sd x18, 144(sp)
ffffffe0002000fc:	09213823          	sd	s2,144(sp)
    sd x19, 152(sp)
ffffffe000200100:	09313c23          	sd	s3,152(sp)
    sd x20, 160(sp)
ffffffe000200104:	0b413023          	sd	s4,160(sp)
    sd x21, 168(sp)
ffffffe000200108:	0b513423          	sd	s5,168(sp)
    sd x22, 176(sp)
ffffffe00020010c:	0b613823          	sd	s6,176(sp)
    sd x23, 184(sp)
ffffffe000200110:	0b713c23          	sd	s7,184(sp)
    sd x24, 192(sp)
ffffffe000200114:	0d813023          	sd	s8,192(sp)
    sd x25, 200(sp)
ffffffe000200118:	0d913423          	sd	s9,200(sp)
    sd x26, 208(sp)
ffffffe00020011c:	0da13823          	sd	s10,208(sp)
    sd x27, 216(sp)
ffffffe000200120:	0db13c23          	sd	s11,216(sp)
    sd x28, 224(sp)
ffffffe000200124:	0fc13023          	sd	t3,224(sp)
    sd x29, 232(sp)
ffffffe000200128:	0fd13423          	sd	t4,232(sp)
    sd x30, 240(sp)
ffffffe00020012c:	0fe13823          	sd	t5,240(sp)
    sd x31, 248(sp)
ffffffe000200130:	0ff13c23          	sd	t6,248(sp)

    csrr a0, scause
ffffffe000200134:	14202573          	csrr	a0,scause
    csrr a1, sepc
ffffffe000200138:	141025f3          	csrr	a1,sepc
    csrr a2, sstatus
ffffffe00020013c:	10002673          	csrr	a2,sstatus
    add a3, sp, x0
ffffffe000200140:	000106b3          	add	a3,sp,zero
    call trap_handler
ffffffe000200144:	6b0010ef          	jal	ra,ffffffe0002017f4 <trap_handler>

ffffffe000200148 <__ret_from_fork>:

.globl __ret_from_fork
__ret_from_fork:

    ld x0, 0(sp)
ffffffe000200148:	00013003          	ld	zero,0(sp)
    ld x1, 8(sp)
ffffffe00020014c:	00813083          	ld	ra,8(sp)

    ld x3, 24(sp)
ffffffe000200150:	01813183          	ld	gp,24(sp)
    ld x4, 32(sp)
ffffffe000200154:	02013203          	ld	tp,32(sp)
    ld x5, 40(sp)
ffffffe000200158:	02813283          	ld	t0,40(sp)
    ld x6, 48(sp)
ffffffe00020015c:	03013303          	ld	t1,48(sp)
    ld x7, 56(sp)
ffffffe000200160:	03813383          	ld	t2,56(sp)
    ld x8, 64(sp)
ffffffe000200164:	04013403          	ld	s0,64(sp)
    ld x9, 72(sp)
ffffffe000200168:	04813483          	ld	s1,72(sp)
    ld x10, 80(sp)
ffffffe00020016c:	05013503          	ld	a0,80(sp)
    ld x11, 88(sp)
ffffffe000200170:	05813583          	ld	a1,88(sp)
    ld x12, 96(sp)
ffffffe000200174:	06013603          	ld	a2,96(sp)
    ld x13, 104(sp)
ffffffe000200178:	06813683          	ld	a3,104(sp)
    ld x14, 112(sp)
ffffffe00020017c:	07013703          	ld	a4,112(sp)
    ld x15, 120(sp)
ffffffe000200180:	07813783          	ld	a5,120(sp)
    ld x16, 128(sp)
ffffffe000200184:	08013803          	ld	a6,128(sp)
    ld x17, 136(sp)
ffffffe000200188:	08813883          	ld	a7,136(sp)
    ld x18, 144(sp)
ffffffe00020018c:	09013903          	ld	s2,144(sp)
    ld x19, 152(sp)
ffffffe000200190:	09813983          	ld	s3,152(sp)
    ld x20, 160(sp)
ffffffe000200194:	0a013a03          	ld	s4,160(sp)
    ld x21, 168(sp)
ffffffe000200198:	0a813a83          	ld	s5,168(sp)
    ld x22, 176(sp)
ffffffe00020019c:	0b013b03          	ld	s6,176(sp)
    ld x23, 184(sp)
ffffffe0002001a0:	0b813b83          	ld	s7,184(sp)
    ld x24, 192(sp)
ffffffe0002001a4:	0c013c03          	ld	s8,192(sp)
    ld x25, 200(sp)
ffffffe0002001a8:	0c813c83          	ld	s9,200(sp)
    ld x26, 208(sp)
ffffffe0002001ac:	0d013d03          	ld	s10,208(sp)
    ld x27, 216(sp)
ffffffe0002001b0:	0d813d83          	ld	s11,216(sp)
    ld x28, 224(sp)
ffffffe0002001b4:	0e013e03          	ld	t3,224(sp)
    ld x29, 232(sp)
ffffffe0002001b8:	0e813e83          	ld	t4,232(sp)
    ld x30, 240(sp)
ffffffe0002001bc:	0f013f03          	ld	t5,240(sp)
    ld x31, 248(sp)
ffffffe0002001c0:	0f813f83          	ld	t6,248(sp)
    ld x2, 16(sp)
ffffffe0002001c4:	01013103          	ld	sp,16(sp)
    addi sp, sp, 256
ffffffe0002001c8:	10010113          	addi	sp,sp,256
    # 4. return from trap

    csrr t0, sscratch
ffffffe0002001cc:	140022f3          	csrr	t0,sscratch
    beq t0, x0, _smode_ret
ffffffe0002001d0:	00028663          	beqz	t0,ffffffe0002001dc <_smode_ret>

ffffffe0002001d4 <_umode_ret>:

_umode_ret:

    csrw sscratch, sp
ffffffe0002001d4:	14011073          	csrw	sscratch,sp
    add sp, t0, x0
ffffffe0002001d8:	00028133          	add	sp,t0,zero

ffffffe0002001dc <_smode_ret>:

_smode_ret:
    sret
ffffffe0002001dc:	10200073          	sret

ffffffe0002001e0 <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:
    csrr t0, sscratch
ffffffe0002001e0:	140022f3          	csrr	t0,sscratch
    csrw sscratch, sp
ffffffe0002001e4:	14011073          	csrw	sscratch,sp
    add sp, t0, x0
ffffffe0002001e8:	00028133          	add	sp,t0,zero
    sret
ffffffe0002001ec:	10200073          	sret

ffffffe0002001f0 <__switch_to>:
    .globl __switch_to
__switch_to:
    # save state to prev process
    # YOUR CODE HERE    
    #保存当前线程的 ra，sp，s0~s11 到当前线程的 thread_struct 中
    sd ra, 32(a0)
ffffffe0002001f0:	02153023          	sd	ra,32(a0)
    sd sp, 40(a0)
ffffffe0002001f4:	02253423          	sd	sp,40(a0)
    sd s0, 48(a0)
ffffffe0002001f8:	02853823          	sd	s0,48(a0)
    sd s1, 56(a0)
ffffffe0002001fc:	02953c23          	sd	s1,56(a0)
    sd s2, 64(a0)
ffffffe000200200:	05253023          	sd	s2,64(a0)
    sd s3, 72(a0)
ffffffe000200204:	05353423          	sd	s3,72(a0)
    sd s4, 80(a0)
ffffffe000200208:	05453823          	sd	s4,80(a0)
    sd s5, 88(a0)
ffffffe00020020c:	05553c23          	sd	s5,88(a0)
    sd s6, 96(a0)
ffffffe000200210:	07653023          	sd	s6,96(a0)
    sd s7, 104(a0)
ffffffe000200214:	07753423          	sd	s7,104(a0)
    sd s8, 112(a0)
ffffffe000200218:	07853823          	sd	s8,112(a0)
    sd s9, 120(a0)
ffffffe00020021c:	07953c23          	sd	s9,120(a0)
    sd s10, 128(a0)
ffffffe000200220:	09a53023          	sd	s10,128(a0)
    sd s11, 136(a0)
ffffffe000200224:	09b53423          	sd	s11,136(a0)

    /*Lab4*/
    csrr t0, sepc
ffffffe000200228:	141022f3          	csrr	t0,sepc
    sd t0, 144(a0)
ffffffe00020022c:	08553823          	sd	t0,144(a0)
    csrr t0, sstatus
ffffffe000200230:	100022f3          	csrr	t0,sstatus
    sd t0, 152(a0)
ffffffe000200234:	08553c23          	sd	t0,152(a0)
    csrr t0, sscratch
ffffffe000200238:	140022f3          	csrr	t0,sscratch
    sd t0, 160(a0)
ffffffe00020023c:	0a553023          	sd	t0,160(a0)

    ld ra, 32(a1)
ffffffe000200240:	0205b083          	ld	ra,32(a1)
    ld sp, 40(a1)
ffffffe000200244:	0285b103          	ld	sp,40(a1)
    ld s0, 48(a1)
ffffffe000200248:	0305b403          	ld	s0,48(a1)
    ld s1, 56(a1)
ffffffe00020024c:	0385b483          	ld	s1,56(a1)
    ld s2, 64(a1)
ffffffe000200250:	0405b903          	ld	s2,64(a1)
    ld s3, 72(a1)
ffffffe000200254:	0485b983          	ld	s3,72(a1)
    ld s4, 80(a1)
ffffffe000200258:	0505ba03          	ld	s4,80(a1)
    ld s5, 88(a1)
ffffffe00020025c:	0585ba83          	ld	s5,88(a1)
    ld s6, 96(a1)
ffffffe000200260:	0605bb03          	ld	s6,96(a1)
    ld s7, 104(a1)
ffffffe000200264:	0685bb83          	ld	s7,104(a1)
    ld s8, 112(a1)
ffffffe000200268:	0705bc03          	ld	s8,112(a1)
    ld s9, 120(a1)
ffffffe00020026c:	0785bc83          	ld	s9,120(a1)
    ld s10, 128(a1)
ffffffe000200270:	0805bd03          	ld	s10,128(a1)
    ld s11, 136(a1)
ffffffe000200274:	0885bd83          	ld	s11,136(a1)

    /*Lab4*/
    ld t0, 144(a1)
ffffffe000200278:	0905b283          	ld	t0,144(a1)
    csrw sepc, t0
ffffffe00020027c:	14129073          	csrw	sepc,t0
    ld t0, 152(a1)
ffffffe000200280:	0985b283          	ld	t0,152(a1)
    csrw sstatus, t0
ffffffe000200284:	10029073          	csrw	sstatus,t0
    ld t0, 160(a1)
ffffffe000200288:	0a05b283          	ld	t0,160(a1)
    csrw sscratch, t0
ffffffe00020028c:	14029073          	csrw	sscratch,t0

    ld t0, 168(a1)
ffffffe000200290:	0a85b283          	ld	t0,168(a1)
    li t1, 0xffffffdf80000000
ffffffe000200294:	fbf0031b          	addiw	t1,zero,-65
ffffffe000200298:	01f31313          	slli	t1,t1,0x1f
    sub t0, t0, t1
ffffffe00020029c:	406282b3          	sub	t0,t0,t1
    srli t0, t0, 12
ffffffe0002002a0:	00c2d293          	srli	t0,t0,0xc
    li t2, 0x8000000000000000
ffffffe0002002a4:	fff0039b          	addiw	t2,zero,-1
ffffffe0002002a8:	03f39393          	slli	t2,t2,0x3f
    or t2, t2, t0
ffffffe0002002ac:	0053e3b3          	or	t2,t2,t0
    csrw satp, t2
ffffffe0002002b0:	18039073          	csrw	satp,t2

    sfence.vma zero, zero
ffffffe0002002b4:	12000073          	sfence.vma

ffffffe0002002b8:	00008067          	ret

ffffffe0002002bc <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe0002002bc:	fe010113          	addi	sp,sp,-32
ffffffe0002002c0:	00813c23          	sd	s0,24(sp)
ffffffe0002002c4:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    // #error Unimplemented
    uint64_t cycles;
    asm volatile("rdtime %0" : "=r"(cycles));
ffffffe0002002c8:	c01027f3          	rdtime	a5
ffffffe0002002cc:	fef43423          	sd	a5,-24(s0)
    return cycles;
ffffffe0002002d0:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002002d4:	00078513          	mv	a0,a5
ffffffe0002002d8:	01813403          	ld	s0,24(sp)
ffffffe0002002dc:	02010113          	addi	sp,sp,32
ffffffe0002002e0:	00008067          	ret

ffffffe0002002e4 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe0002002e4:	fe010113          	addi	sp,sp,-32
ffffffe0002002e8:	00113c23          	sd	ra,24(sp)
ffffffe0002002ec:	00813823          	sd	s0,16(sp)
ffffffe0002002f0:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe0002002f4:	fc9ff0ef          	jal	ra,ffffffe0002002bc <get_cycles>
ffffffe0002002f8:	00050713          	mv	a4,a0
ffffffe0002002fc:	00005797          	auipc	a5,0x5
ffffffe000200300:	d0478793          	addi	a5,a5,-764 # ffffffe000205000 <TIMECLOCK>
ffffffe000200304:	0007b783          	ld	a5,0(a5)
ffffffe000200308:	00f707b3          	add	a5,a4,a5
ffffffe00020030c:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe000200310:	fe843503          	ld	a0,-24(s0)
ffffffe000200314:	454010ef          	jal	ra,ffffffe000201768 <sbi_set_timer>
ffffffe000200318:	00000013          	nop
ffffffe00020031c:	01813083          	ld	ra,24(sp)
ffffffe000200320:	01013403          	ld	s0,16(sp)
ffffffe000200324:	02010113          	addi	sp,sp,32
ffffffe000200328:	00008067          	ret

ffffffe00020032c <fixsize>:
#define MAX(a, b) ((a) > (b) ? (a) : (b))

void *free_page_start = &_ekernel;
struct buddy buddy;

static uint64_t fixsize(uint64_t size) {
ffffffe00020032c:	fe010113          	addi	sp,sp,-32
ffffffe000200330:	00813c23          	sd	s0,24(sp)
ffffffe000200334:	02010413          	addi	s0,sp,32
ffffffe000200338:	fea43423          	sd	a0,-24(s0)
    size --;
ffffffe00020033c:	fe843783          	ld	a5,-24(s0)
ffffffe000200340:	fff78793          	addi	a5,a5,-1
ffffffe000200344:	fef43423          	sd	a5,-24(s0)
    size |= size >> 1;
ffffffe000200348:	fe843783          	ld	a5,-24(s0)
ffffffe00020034c:	0017d793          	srli	a5,a5,0x1
ffffffe000200350:	fe843703          	ld	a4,-24(s0)
ffffffe000200354:	00f767b3          	or	a5,a4,a5
ffffffe000200358:	fef43423          	sd	a5,-24(s0)
    size |= size >> 2;
ffffffe00020035c:	fe843783          	ld	a5,-24(s0)
ffffffe000200360:	0027d793          	srli	a5,a5,0x2
ffffffe000200364:	fe843703          	ld	a4,-24(s0)
ffffffe000200368:	00f767b3          	or	a5,a4,a5
ffffffe00020036c:	fef43423          	sd	a5,-24(s0)
    size |= size >> 4;
ffffffe000200370:	fe843783          	ld	a5,-24(s0)
ffffffe000200374:	0047d793          	srli	a5,a5,0x4
ffffffe000200378:	fe843703          	ld	a4,-24(s0)
ffffffe00020037c:	00f767b3          	or	a5,a4,a5
ffffffe000200380:	fef43423          	sd	a5,-24(s0)
    size |= size >> 8;
ffffffe000200384:	fe843783          	ld	a5,-24(s0)
ffffffe000200388:	0087d793          	srli	a5,a5,0x8
ffffffe00020038c:	fe843703          	ld	a4,-24(s0)
ffffffe000200390:	00f767b3          	or	a5,a4,a5
ffffffe000200394:	fef43423          	sd	a5,-24(s0)
    size |= size >> 16;
ffffffe000200398:	fe843783          	ld	a5,-24(s0)
ffffffe00020039c:	0107d793          	srli	a5,a5,0x10
ffffffe0002003a0:	fe843703          	ld	a4,-24(s0)
ffffffe0002003a4:	00f767b3          	or	a5,a4,a5
ffffffe0002003a8:	fef43423          	sd	a5,-24(s0)
    size |= size >> 32;
ffffffe0002003ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002003b0:	0207d793          	srli	a5,a5,0x20
ffffffe0002003b4:	fe843703          	ld	a4,-24(s0)
ffffffe0002003b8:	00f767b3          	or	a5,a4,a5
ffffffe0002003bc:	fef43423          	sd	a5,-24(s0)
    return size + 1;
ffffffe0002003c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002003c4:	00178793          	addi	a5,a5,1
}
ffffffe0002003c8:	00078513          	mv	a0,a5
ffffffe0002003cc:	01813403          	ld	s0,24(sp)
ffffffe0002003d0:	02010113          	addi	sp,sp,32
ffffffe0002003d4:	00008067          	ret

ffffffe0002003d8 <buddy_init>:

void buddy_init() {
ffffffe0002003d8:	fd010113          	addi	sp,sp,-48
ffffffe0002003dc:	02113423          	sd	ra,40(sp)
ffffffe0002003e0:	02813023          	sd	s0,32(sp)
ffffffe0002003e4:	03010413          	addi	s0,sp,48
    uint64_t buddy_size = (uint64_t)PHY_SIZE / PGSIZE;
ffffffe0002003e8:	000087b7          	lui	a5,0x8
ffffffe0002003ec:	fef43423          	sd	a5,-24(s0)

    if (!IS_POWER_OF_2(buddy_size))
ffffffe0002003f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002003f4:	fff78713          	addi	a4,a5,-1 # 7fff <PGSIZE+0x6fff>
ffffffe0002003f8:	fe843783          	ld	a5,-24(s0)
ffffffe0002003fc:	00f777b3          	and	a5,a4,a5
ffffffe000200400:	00078863          	beqz	a5,ffffffe000200410 <buddy_init+0x38>
        buddy_size = fixsize(buddy_size);
ffffffe000200404:	fe843503          	ld	a0,-24(s0)
ffffffe000200408:	f25ff0ef          	jal	ra,ffffffe00020032c <fixsize>
ffffffe00020040c:	fea43423          	sd	a0,-24(s0)

    buddy.size = buddy_size;
ffffffe000200410:	00009797          	auipc	a5,0x9
ffffffe000200414:	c1078793          	addi	a5,a5,-1008 # ffffffe000209020 <buddy>
ffffffe000200418:	fe843703          	ld	a4,-24(s0)
ffffffe00020041c:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe000200420:	00005797          	auipc	a5,0x5
ffffffe000200424:	be878793          	addi	a5,a5,-1048 # ffffffe000205008 <free_page_start>
ffffffe000200428:	0007b703          	ld	a4,0(a5)
ffffffe00020042c:	00009797          	auipc	a5,0x9
ffffffe000200430:	bf478793          	addi	a5,a5,-1036 # ffffffe000209020 <buddy>
ffffffe000200434:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe000200438:	00005797          	auipc	a5,0x5
ffffffe00020043c:	bd078793          	addi	a5,a5,-1072 # ffffffe000205008 <free_page_start>
ffffffe000200440:	0007b703          	ld	a4,0(a5)
ffffffe000200444:	00009797          	auipc	a5,0x9
ffffffe000200448:	bdc78793          	addi	a5,a5,-1060 # ffffffe000209020 <buddy>
ffffffe00020044c:	0007b783          	ld	a5,0(a5)
ffffffe000200450:	00479793          	slli	a5,a5,0x4
ffffffe000200454:	00f70733          	add	a4,a4,a5
ffffffe000200458:	00005797          	auipc	a5,0x5
ffffffe00020045c:	bb078793          	addi	a5,a5,-1104 # ffffffe000205008 <free_page_start>
ffffffe000200460:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe000200464:	00009797          	auipc	a5,0x9
ffffffe000200468:	bbc78793          	addi	a5,a5,-1092 # ffffffe000209020 <buddy>
ffffffe00020046c:	0087b703          	ld	a4,8(a5)
ffffffe000200470:	00009797          	auipc	a5,0x9
ffffffe000200474:	bb078793          	addi	a5,a5,-1104 # ffffffe000209020 <buddy>
ffffffe000200478:	0007b783          	ld	a5,0(a5)
ffffffe00020047c:	00479793          	slli	a5,a5,0x4
ffffffe000200480:	00078613          	mv	a2,a5
ffffffe000200484:	00000593          	li	a1,0
ffffffe000200488:	00070513          	mv	a0,a4
ffffffe00020048c:	758030ef          	jal	ra,ffffffe000203be4 <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe000200490:	00009797          	auipc	a5,0x9
ffffffe000200494:	b9078793          	addi	a5,a5,-1136 # ffffffe000209020 <buddy>
ffffffe000200498:	0007b783          	ld	a5,0(a5)
ffffffe00020049c:	00179793          	slli	a5,a5,0x1
ffffffe0002004a0:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe0002004a4:	fc043c23          	sd	zero,-40(s0)
ffffffe0002004a8:	0500006f          	j	ffffffe0002004f8 <buddy_init+0x120>
        if (IS_POWER_OF_2(i + 1))
ffffffe0002004ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002004b0:	00178713          	addi	a4,a5,1
ffffffe0002004b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002004b8:	00f777b3          	and	a5,a4,a5
ffffffe0002004bc:	00079863          	bnez	a5,ffffffe0002004cc <buddy_init+0xf4>
            node_size /= 2;
ffffffe0002004c0:	fe043783          	ld	a5,-32(s0)
ffffffe0002004c4:	0017d793          	srli	a5,a5,0x1
ffffffe0002004c8:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe0002004cc:	00009797          	auipc	a5,0x9
ffffffe0002004d0:	b5478793          	addi	a5,a5,-1196 # ffffffe000209020 <buddy>
ffffffe0002004d4:	0087b703          	ld	a4,8(a5)
ffffffe0002004d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002004dc:	00379793          	slli	a5,a5,0x3
ffffffe0002004e0:	00f707b3          	add	a5,a4,a5
ffffffe0002004e4:	fe043703          	ld	a4,-32(s0)
ffffffe0002004e8:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe0002004ec:	fd843783          	ld	a5,-40(s0)
ffffffe0002004f0:	00178793          	addi	a5,a5,1
ffffffe0002004f4:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002004f8:	00009797          	auipc	a5,0x9
ffffffe0002004fc:	b2878793          	addi	a5,a5,-1240 # ffffffe000209020 <buddy>
ffffffe000200500:	0007b783          	ld	a5,0(a5)
ffffffe000200504:	00179793          	slli	a5,a5,0x1
ffffffe000200508:	fff78793          	addi	a5,a5,-1
ffffffe00020050c:	fd843703          	ld	a4,-40(s0)
ffffffe000200510:	f8f76ee3          	bltu	a4,a5,ffffffe0002004ac <buddy_init+0xd4>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200514:	fc043823          	sd	zero,-48(s0)
ffffffe000200518:	0180006f          	j	ffffffe000200530 <buddy_init+0x158>
        buddy_alloc(1);
ffffffe00020051c:	00100513          	li	a0,1
ffffffe000200520:	1fc000ef          	jal	ra,ffffffe00020071c <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200524:	fd043783          	ld	a5,-48(s0)
ffffffe000200528:	00178793          	addi	a5,a5,1
ffffffe00020052c:	fcf43823          	sd	a5,-48(s0)
ffffffe000200530:	fd043783          	ld	a5,-48(s0)
ffffffe000200534:	00c79713          	slli	a4,a5,0xc
ffffffe000200538:	00100793          	li	a5,1
ffffffe00020053c:	01f79793          	slli	a5,a5,0x1f
ffffffe000200540:	00f70733          	add	a4,a4,a5
ffffffe000200544:	00005797          	auipc	a5,0x5
ffffffe000200548:	ac478793          	addi	a5,a5,-1340 # ffffffe000205008 <free_page_start>
ffffffe00020054c:	0007b783          	ld	a5,0(a5)
ffffffe000200550:	00078693          	mv	a3,a5
ffffffe000200554:	04100793          	li	a5,65
ffffffe000200558:	01f79793          	slli	a5,a5,0x1f
ffffffe00020055c:	00f687b3          	add	a5,a3,a5
ffffffe000200560:	faf76ee3          	bltu	a4,a5,ffffffe00020051c <buddy_init+0x144>
    }

    printk("...buddy_init done!\n");
ffffffe000200564:	00004517          	auipc	a0,0x4
ffffffe000200568:	aa450513          	addi	a0,a0,-1372 # ffffffe000204008 <__func__.1+0x8>
ffffffe00020056c:	558030ef          	jal	ra,ffffffe000203ac4 <printk>
    return;
ffffffe000200570:	00000013          	nop
}
ffffffe000200574:	02813083          	ld	ra,40(sp)
ffffffe000200578:	02013403          	ld	s0,32(sp)
ffffffe00020057c:	03010113          	addi	sp,sp,48
ffffffe000200580:	00008067          	ret

ffffffe000200584 <buddy_free>:

void buddy_free(uint64_t pfn) {
ffffffe000200584:	fc010113          	addi	sp,sp,-64
ffffffe000200588:	02813c23          	sd	s0,56(sp)
ffffffe00020058c:	04010413          	addi	s0,sp,64
ffffffe000200590:	fca43423          	sd	a0,-56(s0)
    uint64_t node_size, index = 0;
ffffffe000200594:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe000200598:	00100793          	li	a5,1
ffffffe00020059c:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe0002005a0:	00009797          	auipc	a5,0x9
ffffffe0002005a4:	a8078793          	addi	a5,a5,-1408 # ffffffe000209020 <buddy>
ffffffe0002005a8:	0007b703          	ld	a4,0(a5)
ffffffe0002005ac:	fc843783          	ld	a5,-56(s0)
ffffffe0002005b0:	00f707b3          	add	a5,a4,a5
ffffffe0002005b4:	fff78793          	addi	a5,a5,-1
ffffffe0002005b8:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe0002005bc:	02c0006f          	j	ffffffe0002005e8 <buddy_free+0x64>
        node_size *= 2;
ffffffe0002005c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002005c4:	00179793          	slli	a5,a5,0x1
ffffffe0002005c8:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe0002005cc:	fe043783          	ld	a5,-32(s0)
ffffffe0002005d0:	02078e63          	beqz	a5,ffffffe00020060c <buddy_free+0x88>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe0002005d4:	fe043783          	ld	a5,-32(s0)
ffffffe0002005d8:	00178793          	addi	a5,a5,1
ffffffe0002005dc:	0017d793          	srli	a5,a5,0x1
ffffffe0002005e0:	fff78793          	addi	a5,a5,-1
ffffffe0002005e4:	fef43023          	sd	a5,-32(s0)
ffffffe0002005e8:	00009797          	auipc	a5,0x9
ffffffe0002005ec:	a3878793          	addi	a5,a5,-1480 # ffffffe000209020 <buddy>
ffffffe0002005f0:	0087b703          	ld	a4,8(a5)
ffffffe0002005f4:	fe043783          	ld	a5,-32(s0)
ffffffe0002005f8:	00379793          	slli	a5,a5,0x3
ffffffe0002005fc:	00f707b3          	add	a5,a4,a5
ffffffe000200600:	0007b783          	ld	a5,0(a5)
ffffffe000200604:	fa079ee3          	bnez	a5,ffffffe0002005c0 <buddy_free+0x3c>
ffffffe000200608:	0080006f          	j	ffffffe000200610 <buddy_free+0x8c>
            break;
ffffffe00020060c:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe000200610:	00009797          	auipc	a5,0x9
ffffffe000200614:	a1078793          	addi	a5,a5,-1520 # ffffffe000209020 <buddy>
ffffffe000200618:	0087b703          	ld	a4,8(a5)
ffffffe00020061c:	fe043783          	ld	a5,-32(s0)
ffffffe000200620:	00379793          	slli	a5,a5,0x3
ffffffe000200624:	00f707b3          	add	a5,a4,a5
ffffffe000200628:	fe843703          	ld	a4,-24(s0)
ffffffe00020062c:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe000200630:	0d00006f          	j	ffffffe000200700 <buddy_free+0x17c>
        index = PARENT(index);
ffffffe000200634:	fe043783          	ld	a5,-32(s0)
ffffffe000200638:	00178793          	addi	a5,a5,1
ffffffe00020063c:	0017d793          	srli	a5,a5,0x1
ffffffe000200640:	fff78793          	addi	a5,a5,-1
ffffffe000200644:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe000200648:	fe843783          	ld	a5,-24(s0)
ffffffe00020064c:	00179793          	slli	a5,a5,0x1
ffffffe000200650:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe000200654:	00009797          	auipc	a5,0x9
ffffffe000200658:	9cc78793          	addi	a5,a5,-1588 # ffffffe000209020 <buddy>
ffffffe00020065c:	0087b703          	ld	a4,8(a5)
ffffffe000200660:	fe043783          	ld	a5,-32(s0)
ffffffe000200664:	00479793          	slli	a5,a5,0x4
ffffffe000200668:	00878793          	addi	a5,a5,8
ffffffe00020066c:	00f707b3          	add	a5,a4,a5
ffffffe000200670:	0007b783          	ld	a5,0(a5)
ffffffe000200674:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe000200678:	00009797          	auipc	a5,0x9
ffffffe00020067c:	9a878793          	addi	a5,a5,-1624 # ffffffe000209020 <buddy>
ffffffe000200680:	0087b703          	ld	a4,8(a5)
ffffffe000200684:	fe043783          	ld	a5,-32(s0)
ffffffe000200688:	00178793          	addi	a5,a5,1
ffffffe00020068c:	00479793          	slli	a5,a5,0x4
ffffffe000200690:	00f707b3          	add	a5,a4,a5
ffffffe000200694:	0007b783          	ld	a5,0(a5)
ffffffe000200698:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe00020069c:	fd843703          	ld	a4,-40(s0)
ffffffe0002006a0:	fd043783          	ld	a5,-48(s0)
ffffffe0002006a4:	00f707b3          	add	a5,a4,a5
ffffffe0002006a8:	fe843703          	ld	a4,-24(s0)
ffffffe0002006ac:	02f71463          	bne	a4,a5,ffffffe0002006d4 <buddy_free+0x150>
            buddy.bitmap[index] = node_size;
ffffffe0002006b0:	00009797          	auipc	a5,0x9
ffffffe0002006b4:	97078793          	addi	a5,a5,-1680 # ffffffe000209020 <buddy>
ffffffe0002006b8:	0087b703          	ld	a4,8(a5)
ffffffe0002006bc:	fe043783          	ld	a5,-32(s0)
ffffffe0002006c0:	00379793          	slli	a5,a5,0x3
ffffffe0002006c4:	00f707b3          	add	a5,a4,a5
ffffffe0002006c8:	fe843703          	ld	a4,-24(s0)
ffffffe0002006cc:	00e7b023          	sd	a4,0(a5)
ffffffe0002006d0:	0300006f          	j	ffffffe000200700 <buddy_free+0x17c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe0002006d4:	00009797          	auipc	a5,0x9
ffffffe0002006d8:	94c78793          	addi	a5,a5,-1716 # ffffffe000209020 <buddy>
ffffffe0002006dc:	0087b703          	ld	a4,8(a5)
ffffffe0002006e0:	fe043783          	ld	a5,-32(s0)
ffffffe0002006e4:	00379793          	slli	a5,a5,0x3
ffffffe0002006e8:	00f706b3          	add	a3,a4,a5
ffffffe0002006ec:	fd843703          	ld	a4,-40(s0)
ffffffe0002006f0:	fd043783          	ld	a5,-48(s0)
ffffffe0002006f4:	00e7f463          	bgeu	a5,a4,ffffffe0002006fc <buddy_free+0x178>
ffffffe0002006f8:	00070793          	mv	a5,a4
ffffffe0002006fc:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe000200700:	fe043783          	ld	a5,-32(s0)
ffffffe000200704:	f20798e3          	bnez	a5,ffffffe000200634 <buddy_free+0xb0>
    }
}
ffffffe000200708:	00000013          	nop
ffffffe00020070c:	00000013          	nop
ffffffe000200710:	03813403          	ld	s0,56(sp)
ffffffe000200714:	04010113          	addi	sp,sp,64
ffffffe000200718:	00008067          	ret

ffffffe00020071c <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe00020071c:	fc010113          	addi	sp,sp,-64
ffffffe000200720:	02113c23          	sd	ra,56(sp)
ffffffe000200724:	02813823          	sd	s0,48(sp)
ffffffe000200728:	04010413          	addi	s0,sp,64
ffffffe00020072c:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe000200730:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe000200734:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe000200738:	fc843783          	ld	a5,-56(s0)
ffffffe00020073c:	00079863          	bnez	a5,ffffffe00020074c <buddy_alloc+0x30>
        nrpages = 1;
ffffffe000200740:	00100793          	li	a5,1
ffffffe000200744:	fcf43423          	sd	a5,-56(s0)
ffffffe000200748:	0240006f          	j	ffffffe00020076c <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe00020074c:	fc843783          	ld	a5,-56(s0)
ffffffe000200750:	fff78713          	addi	a4,a5,-1
ffffffe000200754:	fc843783          	ld	a5,-56(s0)
ffffffe000200758:	00f777b3          	and	a5,a4,a5
ffffffe00020075c:	00078863          	beqz	a5,ffffffe00020076c <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe000200760:	fc843503          	ld	a0,-56(s0)
ffffffe000200764:	bc9ff0ef          	jal	ra,ffffffe00020032c <fixsize>
ffffffe000200768:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe00020076c:	00009797          	auipc	a5,0x9
ffffffe000200770:	8b478793          	addi	a5,a5,-1868 # ffffffe000209020 <buddy>
ffffffe000200774:	0087b703          	ld	a4,8(a5)
ffffffe000200778:	fe843783          	ld	a5,-24(s0)
ffffffe00020077c:	00379793          	slli	a5,a5,0x3
ffffffe000200780:	00f707b3          	add	a5,a4,a5
ffffffe000200784:	0007b783          	ld	a5,0(a5)
ffffffe000200788:	fc843703          	ld	a4,-56(s0)
ffffffe00020078c:	00e7f663          	bgeu	a5,a4,ffffffe000200798 <buddy_alloc+0x7c>
        return 0;
ffffffe000200790:	00000793          	li	a5,0
ffffffe000200794:	1480006f          	j	ffffffe0002008dc <buddy_alloc+0x1c0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200798:	00009797          	auipc	a5,0x9
ffffffe00020079c:	88878793          	addi	a5,a5,-1912 # ffffffe000209020 <buddy>
ffffffe0002007a0:	0007b783          	ld	a5,0(a5)
ffffffe0002007a4:	fef43023          	sd	a5,-32(s0)
ffffffe0002007a8:	05c0006f          	j	ffffffe000200804 <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe0002007ac:	00009797          	auipc	a5,0x9
ffffffe0002007b0:	87478793          	addi	a5,a5,-1932 # ffffffe000209020 <buddy>
ffffffe0002007b4:	0087b703          	ld	a4,8(a5)
ffffffe0002007b8:	fe843783          	ld	a5,-24(s0)
ffffffe0002007bc:	00479793          	slli	a5,a5,0x4
ffffffe0002007c0:	00878793          	addi	a5,a5,8
ffffffe0002007c4:	00f707b3          	add	a5,a4,a5
ffffffe0002007c8:	0007b783          	ld	a5,0(a5)
ffffffe0002007cc:	fc843703          	ld	a4,-56(s0)
ffffffe0002007d0:	00e7ec63          	bltu	a5,a4,ffffffe0002007e8 <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe0002007d4:	fe843783          	ld	a5,-24(s0)
ffffffe0002007d8:	00179793          	slli	a5,a5,0x1
ffffffe0002007dc:	00178793          	addi	a5,a5,1
ffffffe0002007e0:	fef43423          	sd	a5,-24(s0)
ffffffe0002007e4:	0140006f          	j	ffffffe0002007f8 <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe0002007e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002007ec:	00178793          	addi	a5,a5,1
ffffffe0002007f0:	00179793          	slli	a5,a5,0x1
ffffffe0002007f4:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe0002007f8:	fe043783          	ld	a5,-32(s0)
ffffffe0002007fc:	0017d793          	srli	a5,a5,0x1
ffffffe000200800:	fef43023          	sd	a5,-32(s0)
ffffffe000200804:	fe043703          	ld	a4,-32(s0)
ffffffe000200808:	fc843783          	ld	a5,-56(s0)
ffffffe00020080c:	faf710e3          	bne	a4,a5,ffffffe0002007ac <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe000200810:	00009797          	auipc	a5,0x9
ffffffe000200814:	81078793          	addi	a5,a5,-2032 # ffffffe000209020 <buddy>
ffffffe000200818:	0087b703          	ld	a4,8(a5)
ffffffe00020081c:	fe843783          	ld	a5,-24(s0)
ffffffe000200820:	00379793          	slli	a5,a5,0x3
ffffffe000200824:	00f707b3          	add	a5,a4,a5
ffffffe000200828:	0007b023          	sd	zero,0(a5)
    pfn = (index + 1) * node_size - buddy.size;
ffffffe00020082c:	fe843783          	ld	a5,-24(s0)
ffffffe000200830:	00178713          	addi	a4,a5,1
ffffffe000200834:	fe043783          	ld	a5,-32(s0)
ffffffe000200838:	02f70733          	mul	a4,a4,a5
ffffffe00020083c:	00008797          	auipc	a5,0x8
ffffffe000200840:	7e478793          	addi	a5,a5,2020 # ffffffe000209020 <buddy>
ffffffe000200844:	0007b783          	ld	a5,0(a5)
ffffffe000200848:	40f707b3          	sub	a5,a4,a5
ffffffe00020084c:	fcf43c23          	sd	a5,-40(s0)

    while (index) {
ffffffe000200850:	0800006f          	j	ffffffe0002008d0 <buddy_alloc+0x1b4>
        index = PARENT(index);
ffffffe000200854:	fe843783          	ld	a5,-24(s0)
ffffffe000200858:	00178793          	addi	a5,a5,1
ffffffe00020085c:	0017d793          	srli	a5,a5,0x1
ffffffe000200860:	fff78793          	addi	a5,a5,-1
ffffffe000200864:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe000200868:	00008797          	auipc	a5,0x8
ffffffe00020086c:	7b878793          	addi	a5,a5,1976 # ffffffe000209020 <buddy>
ffffffe000200870:	0087b703          	ld	a4,8(a5)
ffffffe000200874:	fe843783          	ld	a5,-24(s0)
ffffffe000200878:	00178793          	addi	a5,a5,1
ffffffe00020087c:	00479793          	slli	a5,a5,0x4
ffffffe000200880:	00f707b3          	add	a5,a4,a5
ffffffe000200884:	0007b603          	ld	a2,0(a5)
ffffffe000200888:	00008797          	auipc	a5,0x8
ffffffe00020088c:	79878793          	addi	a5,a5,1944 # ffffffe000209020 <buddy>
ffffffe000200890:	0087b703          	ld	a4,8(a5)
ffffffe000200894:	fe843783          	ld	a5,-24(s0)
ffffffe000200898:	00479793          	slli	a5,a5,0x4
ffffffe00020089c:	00878793          	addi	a5,a5,8
ffffffe0002008a0:	00f707b3          	add	a5,a4,a5
ffffffe0002008a4:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe0002008a8:	00008797          	auipc	a5,0x8
ffffffe0002008ac:	77878793          	addi	a5,a5,1912 # ffffffe000209020 <buddy>
ffffffe0002008b0:	0087b683          	ld	a3,8(a5)
ffffffe0002008b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002008b8:	00379793          	slli	a5,a5,0x3
ffffffe0002008bc:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe0002008c0:	00060793          	mv	a5,a2
ffffffe0002008c4:	00e7f463          	bgeu	a5,a4,ffffffe0002008cc <buddy_alloc+0x1b0>
ffffffe0002008c8:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe0002008cc:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe0002008d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002008d4:	f80790e3          	bnez	a5,ffffffe000200854 <buddy_alloc+0x138>
    }
    
    return pfn;
ffffffe0002008d8:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002008dc:	00078513          	mv	a0,a5
ffffffe0002008e0:	03813083          	ld	ra,56(sp)
ffffffe0002008e4:	03013403          	ld	s0,48(sp)
ffffffe0002008e8:	04010113          	addi	sp,sp,64
ffffffe0002008ec:	00008067          	ret

ffffffe0002008f0 <alloc_pages>:


void *alloc_pages(uint64_t nrpages) {
ffffffe0002008f0:	fd010113          	addi	sp,sp,-48
ffffffe0002008f4:	02113423          	sd	ra,40(sp)
ffffffe0002008f8:	02813023          	sd	s0,32(sp)
ffffffe0002008fc:	03010413          	addi	s0,sp,48
ffffffe000200900:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe000200904:	fd843503          	ld	a0,-40(s0)
ffffffe000200908:	e15ff0ef          	jal	ra,ffffffe00020071c <buddy_alloc>
ffffffe00020090c:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe000200910:	fe843783          	ld	a5,-24(s0)
ffffffe000200914:	00079663          	bnez	a5,ffffffe000200920 <alloc_pages+0x30>
        return 0;
ffffffe000200918:	00000793          	li	a5,0
ffffffe00020091c:	0180006f          	j	ffffffe000200934 <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe000200920:	fe843783          	ld	a5,-24(s0)
ffffffe000200924:	00c79713          	slli	a4,a5,0xc
ffffffe000200928:	fff00793          	li	a5,-1
ffffffe00020092c:	02579793          	slli	a5,a5,0x25
ffffffe000200930:	00f707b3          	add	a5,a4,a5
}
ffffffe000200934:	00078513          	mv	a0,a5
ffffffe000200938:	02813083          	ld	ra,40(sp)
ffffffe00020093c:	02013403          	ld	s0,32(sp)
ffffffe000200940:	03010113          	addi	sp,sp,48
ffffffe000200944:	00008067          	ret

ffffffe000200948 <alloc_page>:

void *alloc_page() {
ffffffe000200948:	ff010113          	addi	sp,sp,-16
ffffffe00020094c:	00113423          	sd	ra,8(sp)
ffffffe000200950:	00813023          	sd	s0,0(sp)
ffffffe000200954:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe000200958:	00100513          	li	a0,1
ffffffe00020095c:	f95ff0ef          	jal	ra,ffffffe0002008f0 <alloc_pages>
ffffffe000200960:	00050793          	mv	a5,a0
}
ffffffe000200964:	00078513          	mv	a0,a5
ffffffe000200968:	00813083          	ld	ra,8(sp)
ffffffe00020096c:	00013403          	ld	s0,0(sp)
ffffffe000200970:	01010113          	addi	sp,sp,16
ffffffe000200974:	00008067          	ret

ffffffe000200978 <free_pages>:

void free_pages(void *va) {
ffffffe000200978:	fe010113          	addi	sp,sp,-32
ffffffe00020097c:	00113c23          	sd	ra,24(sp)
ffffffe000200980:	00813823          	sd	s0,16(sp)
ffffffe000200984:	02010413          	addi	s0,sp,32
ffffffe000200988:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe00020098c:	fe843703          	ld	a4,-24(s0)
ffffffe000200990:	00100793          	li	a5,1
ffffffe000200994:	02579793          	slli	a5,a5,0x25
ffffffe000200998:	00f707b3          	add	a5,a4,a5
ffffffe00020099c:	00c7d793          	srli	a5,a5,0xc
ffffffe0002009a0:	00078513          	mv	a0,a5
ffffffe0002009a4:	be1ff0ef          	jal	ra,ffffffe000200584 <buddy_free>
}
ffffffe0002009a8:	00000013          	nop
ffffffe0002009ac:	01813083          	ld	ra,24(sp)
ffffffe0002009b0:	01013403          	ld	s0,16(sp)
ffffffe0002009b4:	02010113          	addi	sp,sp,32
ffffffe0002009b8:	00008067          	ret

ffffffe0002009bc <kalloc>:

void *kalloc() {
ffffffe0002009bc:	ff010113          	addi	sp,sp,-16
ffffffe0002009c0:	00113423          	sd	ra,8(sp)
ffffffe0002009c4:	00813023          	sd	s0,0(sp)
ffffffe0002009c8:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe0002009cc:	f7dff0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe0002009d0:	00050793          	mv	a5,a0
}
ffffffe0002009d4:	00078513          	mv	a0,a5
ffffffe0002009d8:	00813083          	ld	ra,8(sp)
ffffffe0002009dc:	00013403          	ld	s0,0(sp)
ffffffe0002009e0:	01010113          	addi	sp,sp,16
ffffffe0002009e4:	00008067          	ret

ffffffe0002009e8 <kfree>:

void kfree(void *addr) {
ffffffe0002009e8:	fe010113          	addi	sp,sp,-32
ffffffe0002009ec:	00113c23          	sd	ra,24(sp)
ffffffe0002009f0:	00813823          	sd	s0,16(sp)
ffffffe0002009f4:	02010413          	addi	s0,sp,32
ffffffe0002009f8:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe0002009fc:	fe843503          	ld	a0,-24(s0)
ffffffe000200a00:	f79ff0ef          	jal	ra,ffffffe000200978 <free_pages>

    return;
ffffffe000200a04:	00000013          	nop
}
ffffffe000200a08:	01813083          	ld	ra,24(sp)
ffffffe000200a0c:	01013403          	ld	s0,16(sp)
ffffffe000200a10:	02010113          	addi	sp,sp,32
ffffffe000200a14:	00008067          	ret

ffffffe000200a18 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200a18:	fd010113          	addi	sp,sp,-48
ffffffe000200a1c:	02113423          	sd	ra,40(sp)
ffffffe000200a20:	02813023          	sd	s0,32(sp)
ffffffe000200a24:	03010413          	addi	s0,sp,48
ffffffe000200a28:	fca43c23          	sd	a0,-40(s0)
ffffffe000200a2c:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200a30:	fd843703          	ld	a4,-40(s0)
ffffffe000200a34:	000017b7          	lui	a5,0x1
ffffffe000200a38:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200a3c:	00f70733          	add	a4,a4,a5
ffffffe000200a40:	fffff7b7          	lui	a5,0xfffff
ffffffe000200a44:	00f777b3          	and	a5,a4,a5
ffffffe000200a48:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200a4c:	01c0006f          	j	ffffffe000200a68 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200a50:	fe843503          	ld	a0,-24(s0)
ffffffe000200a54:	f95ff0ef          	jal	ra,ffffffe0002009e8 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200a58:	fe843703          	ld	a4,-24(s0)
ffffffe000200a5c:	000017b7          	lui	a5,0x1
ffffffe000200a60:	00f707b3          	add	a5,a4,a5
ffffffe000200a64:	fef43423          	sd	a5,-24(s0)
ffffffe000200a68:	fe843703          	ld	a4,-24(s0)
ffffffe000200a6c:	000017b7          	lui	a5,0x1
ffffffe000200a70:	00f70733          	add	a4,a4,a5
ffffffe000200a74:	fd043783          	ld	a5,-48(s0)
ffffffe000200a78:	fce7fce3          	bgeu	a5,a4,ffffffe000200a50 <kfreerange+0x38>
    }
}
ffffffe000200a7c:	00000013          	nop
ffffffe000200a80:	00000013          	nop
ffffffe000200a84:	02813083          	ld	ra,40(sp)
ffffffe000200a88:	02013403          	ld	s0,32(sp)
ffffffe000200a8c:	03010113          	addi	sp,sp,48
ffffffe000200a90:	00008067          	ret

ffffffe000200a94 <mm_init>:

void mm_init(void) {
ffffffe000200a94:	ff010113          	addi	sp,sp,-16
ffffffe000200a98:	00113423          	sd	ra,8(sp)
ffffffe000200a9c:	00813023          	sd	s0,0(sp)
ffffffe000200aa0:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200aa4:	935ff0ef          	jal	ra,ffffffe0002003d8 <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200aa8:	00003517          	auipc	a0,0x3
ffffffe000200aac:	57850513          	addi	a0,a0,1400 # ffffffe000204020 <__func__.1+0x20>
ffffffe000200ab0:	014030ef          	jal	ra,ffffffe000203ac4 <printk>
}
ffffffe000200ab4:	00000013          	nop
ffffffe000200ab8:	00813083          	ld	ra,8(sp)
ffffffe000200abc:	00013403          	ld	s0,0(sp)
ffffffe000200ac0:	01010113          	addi	sp,sp,16
ffffffe000200ac4:	00008067          	ret

ffffffe000200ac8 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe000200ac8:	fd010113          	addi	sp,sp,-48
ffffffe000200acc:	02113423          	sd	ra,40(sp)
ffffffe000200ad0:	02813023          	sd	s0,32(sp)
ffffffe000200ad4:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
ffffffe000200ad8:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000200adc:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe000200ae0:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000200ae4:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe000200ae8:	fff00793          	li	a5,-1
ffffffe000200aec:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200af0:	fe442783          	lw	a5,-28(s0)
ffffffe000200af4:	0007871b          	sext.w	a4,a5
ffffffe000200af8:	fff00793          	li	a5,-1
ffffffe000200afc:	00f70e63          	beq	a4,a5,ffffffe000200b18 <dummy+0x50>
ffffffe000200b00:	00008797          	auipc	a5,0x8
ffffffe000200b04:	51078793          	addi	a5,a5,1296 # ffffffe000209010 <current>
ffffffe000200b08:	0007b783          	ld	a5,0(a5)
ffffffe000200b0c:	0087b703          	ld	a4,8(a5)
ffffffe000200b10:	fe442783          	lw	a5,-28(s0)
ffffffe000200b14:	fcf70ee3          	beq	a4,a5,ffffffe000200af0 <dummy+0x28>
ffffffe000200b18:	00008797          	auipc	a5,0x8
ffffffe000200b1c:	4f878793          	addi	a5,a5,1272 # ffffffe000209010 <current>
ffffffe000200b20:	0007b783          	ld	a5,0(a5)
ffffffe000200b24:	0087b783          	ld	a5,8(a5)
ffffffe000200b28:	fc0784e3          	beqz	a5,ffffffe000200af0 <dummy+0x28>
            if (current->counter == 1) {
ffffffe000200b2c:	00008797          	auipc	a5,0x8
ffffffe000200b30:	4e478793          	addi	a5,a5,1252 # ffffffe000209010 <current>
ffffffe000200b34:	0007b783          	ld	a5,0(a5)
ffffffe000200b38:	0087b703          	ld	a4,8(a5)
ffffffe000200b3c:	00100793          	li	a5,1
ffffffe000200b40:	00f71e63          	bne	a4,a5,ffffffe000200b5c <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe000200b44:	00008797          	auipc	a5,0x8
ffffffe000200b48:	4cc78793          	addi	a5,a5,1228 # ffffffe000209010 <current>
ffffffe000200b4c:	0007b783          	ld	a5,0(a5)
ffffffe000200b50:	0087b703          	ld	a4,8(a5)
ffffffe000200b54:	fff70713          	addi	a4,a4,-1
ffffffe000200b58:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe000200b5c:	00008797          	auipc	a5,0x8
ffffffe000200b60:	4b478793          	addi	a5,a5,1204 # ffffffe000209010 <current>
ffffffe000200b64:	0007b783          	ld	a5,0(a5)
ffffffe000200b68:	0087b783          	ld	a5,8(a5)
ffffffe000200b6c:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe000200b70:	fe843783          	ld	a5,-24(s0)
ffffffe000200b74:	00178713          	addi	a4,a5,1
ffffffe000200b78:	fd843783          	ld	a5,-40(s0)
ffffffe000200b7c:	02f777b3          	remu	a5,a4,a5
ffffffe000200b80:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe000200b84:	00008797          	auipc	a5,0x8
ffffffe000200b88:	48c78793          	addi	a5,a5,1164 # ffffffe000209010 <current>
ffffffe000200b8c:	0007b783          	ld	a5,0(a5)
ffffffe000200b90:	0187b783          	ld	a5,24(a5)
ffffffe000200b94:	fe843603          	ld	a2,-24(s0)
ffffffe000200b98:	00078593          	mv	a1,a5
ffffffe000200b9c:	00003517          	auipc	a0,0x3
ffffffe000200ba0:	49c50513          	addi	a0,a0,1180 # ffffffe000204038 <__func__.1+0x38>
ffffffe000200ba4:	721020ef          	jal	ra,ffffffe000203ac4 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200ba8:	f49ff06f          	j	ffffffe000200af0 <dummy+0x28>

ffffffe000200bac <switch_to>:
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
ffffffe000200bac:	fd010113          	addi	sp,sp,-48
ffffffe000200bb0:	02113423          	sd	ra,40(sp)
ffffffe000200bb4:	02813023          	sd	s0,32(sp)
ffffffe000200bb8:	03010413          	addi	s0,sp,48
ffffffe000200bbc:	fca43c23          	sd	a0,-40(s0)
    if(current == next) {
ffffffe000200bc0:	00008797          	auipc	a5,0x8
ffffffe000200bc4:	45078793          	addi	a5,a5,1104 # ffffffe000209010 <current>
ffffffe000200bc8:	0007b783          	ld	a5,0(a5)
ffffffe000200bcc:	fd843703          	ld	a4,-40(s0)
ffffffe000200bd0:	06f70c63          	beq	a4,a5,ffffffe000200c48 <switch_to+0x9c>
        return;
    }else{
        printk("switch_to: %d -> %d\n", current->pid, next->pid);
ffffffe000200bd4:	00008797          	auipc	a5,0x8
ffffffe000200bd8:	43c78793          	addi	a5,a5,1084 # ffffffe000209010 <current>
ffffffe000200bdc:	0007b783          	ld	a5,0(a5)
ffffffe000200be0:	0187b703          	ld	a4,24(a5)
ffffffe000200be4:	fd843783          	ld	a5,-40(s0)
ffffffe000200be8:	0187b783          	ld	a5,24(a5)
ffffffe000200bec:	00078613          	mv	a2,a5
ffffffe000200bf0:	00070593          	mv	a1,a4
ffffffe000200bf4:	00003517          	auipc	a0,0x3
ffffffe000200bf8:	47450513          	addi	a0,a0,1140 # ffffffe000204068 <__func__.1+0x68>
ffffffe000200bfc:	6c9020ef          	jal	ra,ffffffe000203ac4 <printk>
        struct task_struct *prev = current;
ffffffe000200c00:	00008797          	auipc	a5,0x8
ffffffe000200c04:	41078793          	addi	a5,a5,1040 # ffffffe000209010 <current>
ffffffe000200c08:	0007b783          	ld	a5,0(a5)
ffffffe000200c0c:	fef43423          	sd	a5,-24(s0)
        current = next;
ffffffe000200c10:	00008797          	auipc	a5,0x8
ffffffe000200c14:	40078793          	addi	a5,a5,1024 # ffffffe000209010 <current>
ffffffe000200c18:	fd843703          	ld	a4,-40(s0)
ffffffe000200c1c:	00e7b023          	sd	a4,0(a5)
        printk("switch ing\n");
ffffffe000200c20:	00003517          	auipc	a0,0x3
ffffffe000200c24:	46050513          	addi	a0,a0,1120 # ffffffe000204080 <__func__.1+0x80>
ffffffe000200c28:	69d020ef          	jal	ra,ffffffe000203ac4 <printk>
        __switch_to(prev, next);
ffffffe000200c2c:	fd843583          	ld	a1,-40(s0)
ffffffe000200c30:	fe843503          	ld	a0,-24(s0)
ffffffe000200c34:	dbcff0ef          	jal	ra,ffffffe0002001f0 <__switch_to>
        printk("switch done\n");
ffffffe000200c38:	00003517          	auipc	a0,0x3
ffffffe000200c3c:	45850513          	addi	a0,a0,1112 # ffffffe000204090 <__func__.1+0x90>
ffffffe000200c40:	685020ef          	jal	ra,ffffffe000203ac4 <printk>
ffffffe000200c44:	0080006f          	j	ffffffe000200c4c <switch_to+0xa0>
        return;
ffffffe000200c48:	00000013          	nop
    }
}
ffffffe000200c4c:	02813083          	ld	ra,40(sp)
ffffffe000200c50:	02013403          	ld	s0,32(sp)
ffffffe000200c54:	03010113          	addi	sp,sp,48
ffffffe000200c58:	00008067          	ret

ffffffe000200c5c <do_timer>:

void do_timer() {
ffffffe000200c5c:	ff010113          	addi	sp,sp,-16
ffffffe000200c60:	00113423          	sd	ra,8(sp)
ffffffe000200c64:	00813023          	sd	s0,0(sp)
ffffffe000200c68:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    printk("do_timer: current->pid = %d\n", current->pid);
ffffffe000200c6c:	00008797          	auipc	a5,0x8
ffffffe000200c70:	3a478793          	addi	a5,a5,932 # ffffffe000209010 <current>
ffffffe000200c74:	0007b783          	ld	a5,0(a5)
ffffffe000200c78:	0187b783          	ld	a5,24(a5)
ffffffe000200c7c:	00078593          	mv	a1,a5
ffffffe000200c80:	00003517          	auipc	a0,0x3
ffffffe000200c84:	42050513          	addi	a0,a0,1056 # ffffffe0002040a0 <__func__.1+0xa0>
ffffffe000200c88:	63d020ef          	jal	ra,ffffffe000203ac4 <printk>
    // YOUR CODE HERE
    if (current == idle || current->counter == 0) {
ffffffe000200c8c:	00008797          	auipc	a5,0x8
ffffffe000200c90:	38478793          	addi	a5,a5,900 # ffffffe000209010 <current>
ffffffe000200c94:	0007b703          	ld	a4,0(a5)
ffffffe000200c98:	00008797          	auipc	a5,0x8
ffffffe000200c9c:	37078793          	addi	a5,a5,880 # ffffffe000209008 <idle>
ffffffe000200ca0:	0007b783          	ld	a5,0(a5)
ffffffe000200ca4:	00f70c63          	beq	a4,a5,ffffffe000200cbc <do_timer+0x60>
ffffffe000200ca8:	00008797          	auipc	a5,0x8
ffffffe000200cac:	36878793          	addi	a5,a5,872 # ffffffe000209010 <current>
ffffffe000200cb0:	0007b783          	ld	a5,0(a5)
ffffffe000200cb4:	0087b783          	ld	a5,8(a5)
ffffffe000200cb8:	00079c63          	bnez	a5,ffffffe000200cd0 <do_timer+0x74>
        printk("do_timer: schedule\n");
ffffffe000200cbc:	00003517          	auipc	a0,0x3
ffffffe000200cc0:	40450513          	addi	a0,a0,1028 # ffffffe0002040c0 <__func__.1+0xc0>
ffffffe000200cc4:	601020ef          	jal	ra,ffffffe000203ac4 <printk>
        schedule();
ffffffe000200cc8:	058000ef          	jal	ra,ffffffe000200d20 <schedule>
        if (current->counter == 0) {
            printk("do_timer: schedule2\n");
            schedule();
        }
    }
}
ffffffe000200ccc:	0400006f          	j	ffffffe000200d0c <do_timer+0xb0>
        current->counter --;
ffffffe000200cd0:	00008797          	auipc	a5,0x8
ffffffe000200cd4:	34078793          	addi	a5,a5,832 # ffffffe000209010 <current>
ffffffe000200cd8:	0007b783          	ld	a5,0(a5)
ffffffe000200cdc:	0087b703          	ld	a4,8(a5)
ffffffe000200ce0:	fff70713          	addi	a4,a4,-1
ffffffe000200ce4:	00e7b423          	sd	a4,8(a5)
        if (current->counter == 0) {
ffffffe000200ce8:	00008797          	auipc	a5,0x8
ffffffe000200cec:	32878793          	addi	a5,a5,808 # ffffffe000209010 <current>
ffffffe000200cf0:	0007b783          	ld	a5,0(a5)
ffffffe000200cf4:	0087b783          	ld	a5,8(a5)
ffffffe000200cf8:	00079a63          	bnez	a5,ffffffe000200d0c <do_timer+0xb0>
            printk("do_timer: schedule2\n");
ffffffe000200cfc:	00003517          	auipc	a0,0x3
ffffffe000200d00:	3dc50513          	addi	a0,a0,988 # ffffffe0002040d8 <__func__.1+0xd8>
ffffffe000200d04:	5c1020ef          	jal	ra,ffffffe000203ac4 <printk>
            schedule();
ffffffe000200d08:	018000ef          	jal	ra,ffffffe000200d20 <schedule>
}
ffffffe000200d0c:	00000013          	nop
ffffffe000200d10:	00813083          	ld	ra,8(sp)
ffffffe000200d14:	00013403          	ld	s0,0(sp)
ffffffe000200d18:	01010113          	addi	sp,sp,16
ffffffe000200d1c:	00008067          	ret

ffffffe000200d20 <schedule>:

void schedule() {
ffffffe000200d20:	fe010113          	addi	sp,sp,-32
ffffffe000200d24:	00113c23          	sd	ra,24(sp)
ffffffe000200d28:	00813823          	sd	s0,16(sp)
ffffffe000200d2c:	02010413          	addi	s0,sp,32
    // YOUR CODE HERE
    int maxCounter = -1;
ffffffe000200d30:	fff00793          	li	a5,-1
ffffffe000200d34:	fef42623          	sw	a5,-20(s0)
    int index = -1;
ffffffe000200d38:	fff00793          	li	a5,-1
ffffffe000200d3c:	fef42423          	sw	a5,-24(s0)
    for (int i = 1; i < nr_tasks; ++i) {
ffffffe000200d40:	00100793          	li	a5,1
ffffffe000200d44:	fef42223          	sw	a5,-28(s0)
ffffffe000200d48:	0dc0006f          	j	ffffffe000200e24 <schedule+0x104>
        printk("schedule: %d -> %d\n", task[i]->pid, task[i] -> counter);
ffffffe000200d4c:	00008717          	auipc	a4,0x8
ffffffe000200d50:	2e470713          	addi	a4,a4,740 # ffffffe000209030 <task>
ffffffe000200d54:	fe442783          	lw	a5,-28(s0)
ffffffe000200d58:	00379793          	slli	a5,a5,0x3
ffffffe000200d5c:	00f707b3          	add	a5,a4,a5
ffffffe000200d60:	0007b783          	ld	a5,0(a5)
ffffffe000200d64:	0187b683          	ld	a3,24(a5)
ffffffe000200d68:	00008717          	auipc	a4,0x8
ffffffe000200d6c:	2c870713          	addi	a4,a4,712 # ffffffe000209030 <task>
ffffffe000200d70:	fe442783          	lw	a5,-28(s0)
ffffffe000200d74:	00379793          	slli	a5,a5,0x3
ffffffe000200d78:	00f707b3          	add	a5,a4,a5
ffffffe000200d7c:	0007b783          	ld	a5,0(a5)
ffffffe000200d80:	0087b783          	ld	a5,8(a5)
ffffffe000200d84:	00078613          	mv	a2,a5
ffffffe000200d88:	00068593          	mv	a1,a3
ffffffe000200d8c:	00003517          	auipc	a0,0x3
ffffffe000200d90:	36450513          	addi	a0,a0,868 # ffffffe0002040f0 <__func__.1+0xf0>
ffffffe000200d94:	531020ef          	jal	ra,ffffffe000203ac4 <printk>
        if (task[i]->state == TASK_RUNNING && (int)task[i]->counter > maxCounter) {
ffffffe000200d98:	00008717          	auipc	a4,0x8
ffffffe000200d9c:	29870713          	addi	a4,a4,664 # ffffffe000209030 <task>
ffffffe000200da0:	fe442783          	lw	a5,-28(s0)
ffffffe000200da4:	00379793          	slli	a5,a5,0x3
ffffffe000200da8:	00f707b3          	add	a5,a4,a5
ffffffe000200dac:	0007b783          	ld	a5,0(a5)
ffffffe000200db0:	0007b783          	ld	a5,0(a5)
ffffffe000200db4:	06079263          	bnez	a5,ffffffe000200e18 <schedule+0xf8>
ffffffe000200db8:	00008717          	auipc	a4,0x8
ffffffe000200dbc:	27870713          	addi	a4,a4,632 # ffffffe000209030 <task>
ffffffe000200dc0:	fe442783          	lw	a5,-28(s0)
ffffffe000200dc4:	00379793          	slli	a5,a5,0x3
ffffffe000200dc8:	00f707b3          	add	a5,a4,a5
ffffffe000200dcc:	0007b783          	ld	a5,0(a5)
ffffffe000200dd0:	0087b783          	ld	a5,8(a5)
ffffffe000200dd4:	0007871b          	sext.w	a4,a5
ffffffe000200dd8:	fec42783          	lw	a5,-20(s0)
ffffffe000200ddc:	0007879b          	sext.w	a5,a5
ffffffe000200de0:	02e7dc63          	bge	a5,a4,ffffffe000200e18 <schedule+0xf8>
            printk("mamba\n");
ffffffe000200de4:	00003517          	auipc	a0,0x3
ffffffe000200de8:	32450513          	addi	a0,a0,804 # ffffffe000204108 <__func__.1+0x108>
ffffffe000200dec:	4d9020ef          	jal	ra,ffffffe000203ac4 <printk>
            maxCounter = task[i]->counter;
ffffffe000200df0:	00008717          	auipc	a4,0x8
ffffffe000200df4:	24070713          	addi	a4,a4,576 # ffffffe000209030 <task>
ffffffe000200df8:	fe442783          	lw	a5,-28(s0)
ffffffe000200dfc:	00379793          	slli	a5,a5,0x3
ffffffe000200e00:	00f707b3          	add	a5,a4,a5
ffffffe000200e04:	0007b783          	ld	a5,0(a5)
ffffffe000200e08:	0087b783          	ld	a5,8(a5)
ffffffe000200e0c:	fef42623          	sw	a5,-20(s0)
            index = i;
ffffffe000200e10:	fe442783          	lw	a5,-28(s0)
ffffffe000200e14:	fef42423          	sw	a5,-24(s0)
    for (int i = 1; i < nr_tasks; ++i) {
ffffffe000200e18:	fe442783          	lw	a5,-28(s0)
ffffffe000200e1c:	0017879b          	addiw	a5,a5,1
ffffffe000200e20:	fef42223          	sw	a5,-28(s0)
ffffffe000200e24:	fe442703          	lw	a4,-28(s0)
ffffffe000200e28:	00004797          	auipc	a5,0x4
ffffffe000200e2c:	1e878793          	addi	a5,a5,488 # ffffffe000205010 <nr_tasks>
ffffffe000200e30:	0007b783          	ld	a5,0(a5)
ffffffe000200e34:	f0f76ce3          	bltu	a4,a5,ffffffe000200d4c <schedule+0x2c>
        }
    }

    if (maxCounter == 0) {
ffffffe000200e38:	fec42783          	lw	a5,-20(s0)
ffffffe000200e3c:	0007879b          	sext.w	a5,a5
ffffffe000200e40:	0c079e63          	bnez	a5,ffffffe000200f1c <schedule+0x1fc>
        for (int i = 1; i < nr_tasks; ++i) {
ffffffe000200e44:	00100793          	li	a5,1
ffffffe000200e48:	fef42023          	sw	a5,-32(s0)
ffffffe000200e4c:	0b40006f          	j	ffffffe000200f00 <schedule+0x1e0>
            if (task[i]->state == TASK_RUNNING) {
ffffffe000200e50:	00008717          	auipc	a4,0x8
ffffffe000200e54:	1e070713          	addi	a4,a4,480 # ffffffe000209030 <task>
ffffffe000200e58:	fe042783          	lw	a5,-32(s0)
ffffffe000200e5c:	00379793          	slli	a5,a5,0x3
ffffffe000200e60:	00f707b3          	add	a5,a4,a5
ffffffe000200e64:	0007b783          	ld	a5,0(a5)
ffffffe000200e68:	0007b783          	ld	a5,0(a5)
ffffffe000200e6c:	02079e63          	bnez	a5,ffffffe000200ea8 <schedule+0x188>
                task[i]->counter = task[i]->priority;
ffffffe000200e70:	00008717          	auipc	a4,0x8
ffffffe000200e74:	1c070713          	addi	a4,a4,448 # ffffffe000209030 <task>
ffffffe000200e78:	fe042783          	lw	a5,-32(s0)
ffffffe000200e7c:	00379793          	slli	a5,a5,0x3
ffffffe000200e80:	00f707b3          	add	a5,a4,a5
ffffffe000200e84:	0007b703          	ld	a4,0(a5)
ffffffe000200e88:	00008697          	auipc	a3,0x8
ffffffe000200e8c:	1a868693          	addi	a3,a3,424 # ffffffe000209030 <task>
ffffffe000200e90:	fe042783          	lw	a5,-32(s0)
ffffffe000200e94:	00379793          	slli	a5,a5,0x3
ffffffe000200e98:	00f687b3          	add	a5,a3,a5
ffffffe000200e9c:	0007b783          	ld	a5,0(a5)
ffffffe000200ea0:	01073703          	ld	a4,16(a4)
ffffffe000200ea4:	00e7b423          	sd	a4,8(a5)
            }
            printk("schedule2: %d -> %d\n", task[i]->pid, task[i] -> counter);
ffffffe000200ea8:	00008717          	auipc	a4,0x8
ffffffe000200eac:	18870713          	addi	a4,a4,392 # ffffffe000209030 <task>
ffffffe000200eb0:	fe042783          	lw	a5,-32(s0)
ffffffe000200eb4:	00379793          	slli	a5,a5,0x3
ffffffe000200eb8:	00f707b3          	add	a5,a4,a5
ffffffe000200ebc:	0007b783          	ld	a5,0(a5)
ffffffe000200ec0:	0187b683          	ld	a3,24(a5)
ffffffe000200ec4:	00008717          	auipc	a4,0x8
ffffffe000200ec8:	16c70713          	addi	a4,a4,364 # ffffffe000209030 <task>
ffffffe000200ecc:	fe042783          	lw	a5,-32(s0)
ffffffe000200ed0:	00379793          	slli	a5,a5,0x3
ffffffe000200ed4:	00f707b3          	add	a5,a4,a5
ffffffe000200ed8:	0007b783          	ld	a5,0(a5)
ffffffe000200edc:	0087b783          	ld	a5,8(a5)
ffffffe000200ee0:	00078613          	mv	a2,a5
ffffffe000200ee4:	00068593          	mv	a1,a3
ffffffe000200ee8:	00003517          	auipc	a0,0x3
ffffffe000200eec:	22850513          	addi	a0,a0,552 # ffffffe000204110 <__func__.1+0x110>
ffffffe000200ef0:	3d5020ef          	jal	ra,ffffffe000203ac4 <printk>
        for (int i = 1; i < nr_tasks; ++i) {
ffffffe000200ef4:	fe042783          	lw	a5,-32(s0)
ffffffe000200ef8:	0017879b          	addiw	a5,a5,1
ffffffe000200efc:	fef42023          	sw	a5,-32(s0)
ffffffe000200f00:	fe042703          	lw	a4,-32(s0)
ffffffe000200f04:	00004797          	auipc	a5,0x4
ffffffe000200f08:	10c78793          	addi	a5,a5,268 # ffffffe000205010 <nr_tasks>
ffffffe000200f0c:	0007b783          	ld	a5,0(a5)
ffffffe000200f10:	f4f760e3          	bltu	a4,a5,ffffffe000200e50 <schedule+0x130>
        }
        schedule();
ffffffe000200f14:	e0dff0ef          	jal	ra,ffffffe000200d20 <schedule>
    } else {
        switch_to(task[index]);
    }
}
ffffffe000200f18:	0240006f          	j	ffffffe000200f3c <schedule+0x21c>
        switch_to(task[index]);
ffffffe000200f1c:	00008717          	auipc	a4,0x8
ffffffe000200f20:	11470713          	addi	a4,a4,276 # ffffffe000209030 <task>
ffffffe000200f24:	fe842783          	lw	a5,-24(s0)
ffffffe000200f28:	00379793          	slli	a5,a5,0x3
ffffffe000200f2c:	00f707b3          	add	a5,a4,a5
ffffffe000200f30:	0007b783          	ld	a5,0(a5)
ffffffe000200f34:	00078513          	mv	a0,a5
ffffffe000200f38:	c75ff0ef          	jal	ra,ffffffe000200bac <switch_to>
}
ffffffe000200f3c:	00000013          	nop
ffffffe000200f40:	01813083          	ld	ra,24(sp)
ffffffe000200f44:	01013403          	ld	s0,16(sp)
ffffffe000200f48:	02010113          	addi	sp,sp,32
ffffffe000200f4c:	00008067          	ret

ffffffe000200f50 <task_init>:

//7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00

/*ELF*/

void task_init() {
ffffffe000200f50:	fc010113          	addi	sp,sp,-64
ffffffe000200f54:	02113c23          	sd	ra,56(sp)
ffffffe000200f58:	02813823          	sd	s0,48(sp)
ffffffe000200f5c:	04010413          	addi	s0,sp,64
    srand(2024);
ffffffe000200f60:	7e800513          	li	a0,2024
ffffffe000200f64:	3e1020ef          	jal	ra,ffffffe000203b44 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
ffffffe000200f68:	a55ff0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe000200f6c:	00050713          	mv	a4,a0
ffffffe000200f70:	00008797          	auipc	a5,0x8
ffffffe000200f74:	09878793          	addi	a5,a5,152 # ffffffe000209008 <idle>
ffffffe000200f78:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe000200f7c:	00008797          	auipc	a5,0x8
ffffffe000200f80:	08c78793          	addi	a5,a5,140 # ffffffe000209008 <idle>
ffffffe000200f84:	0007b783          	ld	a5,0(a5)
ffffffe000200f88:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe000200f8c:	00008797          	auipc	a5,0x8
ffffffe000200f90:	07c78793          	addi	a5,a5,124 # ffffffe000209008 <idle>
ffffffe000200f94:	0007b783          	ld	a5,0(a5)
ffffffe000200f98:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe000200f9c:	00008797          	auipc	a5,0x8
ffffffe000200fa0:	06c78793          	addi	a5,a5,108 # ffffffe000209008 <idle>
ffffffe000200fa4:	0007b783          	ld	a5,0(a5)
ffffffe000200fa8:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe000200fac:	00008797          	auipc	a5,0x8
ffffffe000200fb0:	05c78793          	addi	a5,a5,92 # ffffffe000209008 <idle>
ffffffe000200fb4:	0007b783          	ld	a5,0(a5)
ffffffe000200fb8:	0007bc23          	sd	zero,24(a5)

    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe000200fbc:	00008797          	auipc	a5,0x8
ffffffe000200fc0:	04c78793          	addi	a5,a5,76 # ffffffe000209008 <idle>
ffffffe000200fc4:	0007b703          	ld	a4,0(a5)
ffffffe000200fc8:	00008797          	auipc	a5,0x8
ffffffe000200fcc:	04878793          	addi	a5,a5,72 # ffffffe000209010 <current>
ffffffe000200fd0:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000200fd4:	00008797          	auipc	a5,0x8
ffffffe000200fd8:	03478793          	addi	a5,a5,52 # ffffffe000209008 <idle>
ffffffe000200fdc:	0007b703          	ld	a4,0(a5)
ffffffe000200fe0:	00008797          	auipc	a5,0x8
ffffffe000200fe4:	05078793          	addi	a5,a5,80 # ffffffe000209030 <task>
ffffffe000200fe8:	00e7b023          	sd	a4,0(a5)

    /* YOUR CODE HERE */

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    for (int i = 1; i < nr_tasks; i++){
ffffffe000200fec:	00100793          	li	a5,1
ffffffe000200ff0:	fef42623          	sw	a5,-20(s0)
ffffffe000200ff4:	2040006f          	j	ffffffe0002011f8 <task_init+0x2a8>
        struct task_struct *ptask = (struct task_struct*)kalloc();
ffffffe000200ff8:	9c5ff0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe000200ffc:	fca43c23          	sd	a0,-40(s0)
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
        ptask->state = TASK_RUNNING;
ffffffe000201000:	fd843783          	ld	a5,-40(s0)
ffffffe000201004:	0007b023          	sd	zero,0(a5)
        ptask->counter = 0;
ffffffe000201008:	fd843783          	ld	a5,-40(s0)
ffffffe00020100c:	0007b423          	sd	zero,8(a5)
        ptask->priority = (uint64_t)rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
ffffffe000201010:	379020ef          	jal	ra,ffffffe000203b88 <rand>
ffffffe000201014:	00050793          	mv	a5,a0
ffffffe000201018:	00078713          	mv	a4,a5
ffffffe00020101c:	00a00793          	li	a5,10
ffffffe000201020:	02f777b3          	remu	a5,a4,a5
ffffffe000201024:	00178713          	addi	a4,a5,1
ffffffe000201028:	fd843783          	ld	a5,-40(s0)
ffffffe00020102c:	00e7b823          	sd	a4,16(a5)
        // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址
        ptask->pid = i;
ffffffe000201030:	fec42703          	lw	a4,-20(s0)
ffffffe000201034:	fd843783          	ld	a5,-40(s0)
ffffffe000201038:	00e7bc23          	sd	a4,24(a5)
        ptask->thread.ra = (uint64_t)__dummy;
ffffffe00020103c:	fffff717          	auipc	a4,0xfffff
ffffffe000201040:	1a470713          	addi	a4,a4,420 # ffffffe0002001e0 <__dummy>
ffffffe000201044:	fd843783          	ld	a5,-40(s0)
ffffffe000201048:	02e7b023          	sd	a4,32(a5)
        ptask->thread.sp = (uint64_t)ptask + PGSIZE;
ffffffe00020104c:	fd843703          	ld	a4,-40(s0)
ffffffe000201050:	000017b7          	lui	a5,0x1
ffffffe000201054:	00f70733          	add	a4,a4,a5
ffffffe000201058:	fd843783          	ld	a5,-40(s0)
ffffffe00020105c:	02e7b423          	sd	a4,40(a5) # 1028 <PGSIZE+0x28>

        /*Lab4*/
        ptask->thread.sepc = (uint64_t)USER_START;
ffffffe000201060:	fd843783          	ld	a5,-40(s0)
ffffffe000201064:	0807b823          	sd	zero,144(a5)
        
        uint64_t _sstatus = ptask->thread.sstatus;
ffffffe000201068:	fd843783          	ld	a5,-40(s0)
ffffffe00020106c:	0987b783          	ld	a5,152(a5)
ffffffe000201070:	fcf43823          	sd	a5,-48(s0)
        //csr_write(sstatus, _sstatus);
        _sstatus &= ~(1 << 8);
ffffffe000201074:	fd043783          	ld	a5,-48(s0)
ffffffe000201078:	eff7f793          	andi	a5,a5,-257
ffffffe00020107c:	fcf43823          	sd	a5,-48(s0)
        _sstatus |= (1 << 5);
ffffffe000201080:	fd043783          	ld	a5,-48(s0)
ffffffe000201084:	0207e793          	ori	a5,a5,32
ffffffe000201088:	fcf43823          	sd	a5,-48(s0)
        _sstatus |= (1 << 18); 
ffffffe00020108c:	fd043703          	ld	a4,-48(s0)
ffffffe000201090:	000407b7          	lui	a5,0x40
ffffffe000201094:	00f767b3          	or	a5,a4,a5
ffffffe000201098:	fcf43823          	sd	a5,-48(s0)
        ptask->thread.sstatus = _sstatus;
ffffffe00020109c:	fd843783          	ld	a5,-40(s0)
ffffffe0002010a0:	fd043703          	ld	a4,-48(s0)
ffffffe0002010a4:	08e7bc23          	sd	a4,152(a5) # 40098 <PGSIZE+0x3f098>

        ptask->thread.sscratch = (uint64_t)USER_END;
ffffffe0002010a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002010ac:	00100713          	li	a4,1
ffffffe0002010b0:	02671713          	slli	a4,a4,0x26
ffffffe0002010b4:	0ae7b023          	sd	a4,160(a5)

        ptask->pgd = (uint64_t*)alloc_page();
ffffffe0002010b8:	891ff0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe0002010bc:	00050713          	mv	a4,a0
ffffffe0002010c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002010c4:	0ae7b423          	sd	a4,168(a5)
        // PAGE_COPY(swapper_pg_dir, pgtbl);
        for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002010c8:	fe043023          	sd	zero,-32(s0)
ffffffe0002010cc:	0b00006f          	j	ffffffe00020117c <task_init+0x22c>
            // char *cpgtbl = (char*)pgtbl;
            char *cpgtbl = (char*)ptask->pgd;
ffffffe0002010d0:	fd843783          	ld	a5,-40(s0)
ffffffe0002010d4:	0a87b783          	ld	a5,168(a5)
ffffffe0002010d8:	fcf43423          	sd	a5,-56(s0)
            char *cearly_pgtbl = (char*)swapper_pg_dir;
ffffffe0002010dc:	0000a797          	auipc	a5,0xa
ffffffe0002010e0:	f2478793          	addi	a5,a5,-220 # ffffffe00020b000 <swapper_pg_dir>
ffffffe0002010e4:	fcf43023          	sd	a5,-64(s0)
            cpgtbl[i] = cearly_pgtbl[i];
ffffffe0002010e8:	fc043703          	ld	a4,-64(s0)
ffffffe0002010ec:	fe043783          	ld	a5,-32(s0)
ffffffe0002010f0:	00f70733          	add	a4,a4,a5
ffffffe0002010f4:	fc843683          	ld	a3,-56(s0)
ffffffe0002010f8:	fe043783          	ld	a5,-32(s0)
ffffffe0002010fc:	00f687b3          	add	a5,a3,a5
ffffffe000201100:	00074703          	lbu	a4,0(a4)
ffffffe000201104:	00e78023          	sb	a4,0(a5)
            if (cpgtbl[i] != cearly_pgtbl[i]) LogRED("cpgtbl[%d] = cearly_pgtbl[%d] = %c", i, i, cpgtbl[i]);
ffffffe000201108:	fc843703          	ld	a4,-56(s0)
ffffffe00020110c:	fe043783          	ld	a5,-32(s0)
ffffffe000201110:	00f707b3          	add	a5,a4,a5
ffffffe000201114:	0007c683          	lbu	a3,0(a5)
ffffffe000201118:	fc043703          	ld	a4,-64(s0)
ffffffe00020111c:	fe043783          	ld	a5,-32(s0)
ffffffe000201120:	00f707b3          	add	a5,a4,a5
ffffffe000201124:	0007c783          	lbu	a5,0(a5)
ffffffe000201128:	00068713          	mv	a4,a3
ffffffe00020112c:	04f70263          	beq	a4,a5,ffffffe000201170 <task_init+0x220>
ffffffe000201130:	fc843703          	ld	a4,-56(s0)
ffffffe000201134:	fe043783          	ld	a5,-32(s0)
ffffffe000201138:	00f707b3          	add	a5,a4,a5
ffffffe00020113c:	0007c783          	lbu	a5,0(a5)
ffffffe000201140:	0007879b          	sext.w	a5,a5
ffffffe000201144:	00078813          	mv	a6,a5
ffffffe000201148:	fe043783          	ld	a5,-32(s0)
ffffffe00020114c:	fe043703          	ld	a4,-32(s0)
ffffffe000201150:	00003697          	auipc	a3,0x3
ffffffe000201154:	11068693          	addi	a3,a3,272 # ffffffe000204260 <__func__.1>
ffffffe000201158:	12400613          	li	a2,292
ffffffe00020115c:	00003597          	auipc	a1,0x3
ffffffe000201160:	fcc58593          	addi	a1,a1,-52 # ffffffe000204128 <__func__.1+0x128>
ffffffe000201164:	00003517          	auipc	a0,0x3
ffffffe000201168:	fcc50513          	addi	a0,a0,-52 # ffffffe000204130 <__func__.1+0x130>
ffffffe00020116c:	159020ef          	jal	ra,ffffffe000203ac4 <printk>
        for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000201170:	fe043783          	ld	a5,-32(s0)
ffffffe000201174:	00178793          	addi	a5,a5,1
ffffffe000201178:	fef43023          	sd	a5,-32(s0)
ffffffe00020117c:	fe043703          	ld	a4,-32(s0)
ffffffe000201180:	000017b7          	lui	a5,0x1
ffffffe000201184:	f4f766e3          	bltu	a4,a5,ffffffe0002010d0 <task_init+0x180>
        }
        // LogGREEN("_sramdisk = %p, _eramdisk = %p", _sramdisk, _eramdisk);

        load_program(ptask);
ffffffe000201188:	fd843503          	ld	a0,-40(s0)
ffffffe00020118c:	20c000ef          	jal	ra,ffffffe000201398 <load_program>
        LogGREEN("[S-MODE] SET PID = %d, PGD = 0x%llx, PRIORITY = %d", ptask->pid, ptask->pgd, ptask->priority);
ffffffe000201190:	fd843783          	ld	a5,-40(s0)
ffffffe000201194:	0187b703          	ld	a4,24(a5) # 1018 <PGSIZE+0x18>
ffffffe000201198:	fd843783          	ld	a5,-40(s0)
ffffffe00020119c:	0a87b683          	ld	a3,168(a5)
ffffffe0002011a0:	fd843783          	ld	a5,-40(s0)
ffffffe0002011a4:	0107b783          	ld	a5,16(a5)
ffffffe0002011a8:	00078813          	mv	a6,a5
ffffffe0002011ac:	00068793          	mv	a5,a3
ffffffe0002011b0:	00003697          	auipc	a3,0x3
ffffffe0002011b4:	0b068693          	addi	a3,a3,176 # ffffffe000204260 <__func__.1>
ffffffe0002011b8:	12900613          	li	a2,297
ffffffe0002011bc:	00003597          	auipc	a1,0x3
ffffffe0002011c0:	f6c58593          	addi	a1,a1,-148 # ffffffe000204128 <__func__.1+0x128>
ffffffe0002011c4:	00003517          	auipc	a0,0x3
ffffffe0002011c8:	fac50513          	addi	a0,a0,-84 # ffffffe000204170 <__func__.1+0x170>
ffffffe0002011cc:	0f9020ef          	jal	ra,ffffffe000203ac4 <printk>
                
        task[i] = ptask;
ffffffe0002011d0:	00008717          	auipc	a4,0x8
ffffffe0002011d4:	e6070713          	addi	a4,a4,-416 # ffffffe000209030 <task>
ffffffe0002011d8:	fec42783          	lw	a5,-20(s0)
ffffffe0002011dc:	00379793          	slli	a5,a5,0x3
ffffffe0002011e0:	00f707b3          	add	a5,a4,a5
ffffffe0002011e4:	fd843703          	ld	a4,-40(s0)
ffffffe0002011e8:	00e7b023          	sd	a4,0(a5)
    for (int i = 1; i < nr_tasks; i++){
ffffffe0002011ec:	fec42783          	lw	a5,-20(s0)
ffffffe0002011f0:	0017879b          	addiw	a5,a5,1
ffffffe0002011f4:	fef42623          	sw	a5,-20(s0)
ffffffe0002011f8:	fec42703          	lw	a4,-20(s0)
ffffffe0002011fc:	00004797          	auipc	a5,0x4
ffffffe000201200:	e1478793          	addi	a5,a5,-492 # ffffffe000205010 <nr_tasks>
ffffffe000201204:	0007b783          	ld	a5,0(a5)
ffffffe000201208:	def768e3          	bltu	a4,a5,ffffffe000200ff8 <task_init+0xa8>
    }
    /* YOUR CODE HERE */

    printk("...task_init done!\n");
ffffffe00020120c:	00003517          	auipc	a0,0x3
ffffffe000201210:	fb450513          	addi	a0,a0,-76 # ffffffe0002041c0 <__func__.1+0x1c0>
ffffffe000201214:	0b1020ef          	jal	ra,ffffffe000203ac4 <printk>
}
ffffffe000201218:	00000013          	nop
ffffffe00020121c:	03813083          	ld	ra,56(sp)
ffffffe000201220:	03013403          	ld	s0,48(sp)
ffffffe000201224:	04010113          	addi	sp,sp,64
ffffffe000201228:	00008067          	ret

ffffffe00020122c <find_vma>:
* @mm       : current thread's mm_struct
* @addr     : the va to look up
*
* @return   : the VMA if found or NULL if not found
*/
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr){
ffffffe00020122c:	fd010113          	addi	sp,sp,-48
ffffffe000201230:	02813423          	sd	s0,40(sp)
ffffffe000201234:	03010413          	addi	s0,sp,48
ffffffe000201238:	fca43c23          	sd	a0,-40(s0)
ffffffe00020123c:	fcb43823          	sd	a1,-48(s0)
    struct vm_area_struct *vma = mm->mmap;
ffffffe000201240:	fd843783          	ld	a5,-40(s0)
ffffffe000201244:	0007b783          	ld	a5,0(a5)
ffffffe000201248:	fef43423          	sd	a5,-24(s0)
    while(vma){
ffffffe00020124c:	0380006f          	j	ffffffe000201284 <find_vma+0x58>
        if(vma->vm_start <= addr && addr < vma->vm_end){
ffffffe000201250:	fe843783          	ld	a5,-24(s0)
ffffffe000201254:	0087b783          	ld	a5,8(a5)
ffffffe000201258:	fd043703          	ld	a4,-48(s0)
ffffffe00020125c:	00f76e63          	bltu	a4,a5,ffffffe000201278 <find_vma+0x4c>
ffffffe000201260:	fe843783          	ld	a5,-24(s0)
ffffffe000201264:	0107b783          	ld	a5,16(a5)
ffffffe000201268:	fd043703          	ld	a4,-48(s0)
ffffffe00020126c:	00f77663          	bgeu	a4,a5,ffffffe000201278 <find_vma+0x4c>
            return vma;
ffffffe000201270:	fe843783          	ld	a5,-24(s0)
ffffffe000201274:	01c0006f          	j	ffffffe000201290 <find_vma+0x64>
        }
        vma = vma->vm_next;
ffffffe000201278:	fe843783          	ld	a5,-24(s0)
ffffffe00020127c:	0187b783          	ld	a5,24(a5)
ffffffe000201280:	fef43423          	sd	a5,-24(s0)
    while(vma){
ffffffe000201284:	fe843783          	ld	a5,-24(s0)
ffffffe000201288:	fc0794e3          	bnez	a5,ffffffe000201250 <find_vma+0x24>
    }
    return NULL;
ffffffe00020128c:	00000793          	li	a5,0
}
ffffffe000201290:	00078513          	mv	a0,a5
ffffffe000201294:	02813403          	ld	s0,40(sp)
ffffffe000201298:	03010113          	addi	sp,sp,48
ffffffe00020129c:	00008067          	ret

ffffffe0002012a0 <do_mmap>:
* @vm_filesz: phdr->p_filesz
* @flags    : flags for the new VMA
*
* @return   : start va
*/
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags){
ffffffe0002012a0:	fb010113          	addi	sp,sp,-80
ffffffe0002012a4:	04113423          	sd	ra,72(sp)
ffffffe0002012a8:	04813023          	sd	s0,64(sp)
ffffffe0002012ac:	05010413          	addi	s0,sp,80
ffffffe0002012b0:	fca43c23          	sd	a0,-40(s0)
ffffffe0002012b4:	fcb43823          	sd	a1,-48(s0)
ffffffe0002012b8:	fcc43423          	sd	a2,-56(s0)
ffffffe0002012bc:	fcd43023          	sd	a3,-64(s0)
ffffffe0002012c0:	fae43c23          	sd	a4,-72(s0)
ffffffe0002012c4:	faf43823          	sd	a5,-80(s0)
    struct vm_area_struct *new_vma = (struct vm_area_struct*)kalloc();
ffffffe0002012c8:	ef4ff0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe0002012cc:	fea43423          	sd	a0,-24(s0)
    
    new_vma->vm_mm = mm;
ffffffe0002012d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002012d4:	fd843703          	ld	a4,-40(s0)
ffffffe0002012d8:	00e7b023          	sd	a4,0(a5)
    struct vm_area_struct *prev =  mm->mmap;
ffffffe0002012dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002012e0:	0007b783          	ld	a5,0(a5)
ffffffe0002012e4:	fef43023          	sd	a5,-32(s0)
    if(!prev){
ffffffe0002012e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002012ec:	02079263          	bnez	a5,ffffffe000201310 <do_mmap+0x70>
        mm->mmap = new_vma;
ffffffe0002012f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002012f4:	fe843703          	ld	a4,-24(s0)
ffffffe0002012f8:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = NULL;
ffffffe0002012fc:	fe843783          	ld	a5,-24(s0)
ffffffe000201300:	0007bc23          	sd	zero,24(a5)
        new_vma->vm_prev = NULL;
ffffffe000201304:	fe843783          	ld	a5,-24(s0)
ffffffe000201308:	0207b023          	sd	zero,32(a5)
ffffffe00020130c:	0300006f          	j	ffffffe00020133c <do_mmap+0x9c>
    }else{
        mm->mmap = new_vma;
ffffffe000201310:	fd843783          	ld	a5,-40(s0)
ffffffe000201314:	fe843703          	ld	a4,-24(s0)
ffffffe000201318:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = prev;
ffffffe00020131c:	fe843783          	ld	a5,-24(s0)
ffffffe000201320:	fe043703          	ld	a4,-32(s0)
ffffffe000201324:	00e7bc23          	sd	a4,24(a5)
        new_vma->vm_prev = NULL;
ffffffe000201328:	fe843783          	ld	a5,-24(s0)
ffffffe00020132c:	0207b023          	sd	zero,32(a5)
        prev->vm_prev = new_vma;
ffffffe000201330:	fe043783          	ld	a5,-32(s0)
ffffffe000201334:	fe843703          	ld	a4,-24(s0)
ffffffe000201338:	02e7b023          	sd	a4,32(a5)
    }

    new_vma->vm_start = addr;
ffffffe00020133c:	fe843783          	ld	a5,-24(s0)
ffffffe000201340:	fd043703          	ld	a4,-48(s0)
ffffffe000201344:	00e7b423          	sd	a4,8(a5)
    new_vma->vm_end = addr + len;
ffffffe000201348:	fd043703          	ld	a4,-48(s0)
ffffffe00020134c:	fc843783          	ld	a5,-56(s0)
ffffffe000201350:	00f70733          	add	a4,a4,a5
ffffffe000201354:	fe843783          	ld	a5,-24(s0)
ffffffe000201358:	00e7b823          	sd	a4,16(a5)
    new_vma->vm_flags = flags;
ffffffe00020135c:	fe843783          	ld	a5,-24(s0)
ffffffe000201360:	fb043703          	ld	a4,-80(s0)
ffffffe000201364:	02e7b423          	sd	a4,40(a5)
    new_vma->vm_pgoff = vm_pgoff;
ffffffe000201368:	fe843783          	ld	a5,-24(s0)
ffffffe00020136c:	fc043703          	ld	a4,-64(s0)
ffffffe000201370:	02e7b823          	sd	a4,48(a5)
    new_vma->vm_filesz = vm_filesz;
ffffffe000201374:	fe843783          	ld	a5,-24(s0)
ffffffe000201378:	fb843703          	ld	a4,-72(s0)
ffffffe00020137c:	02e7bc23          	sd	a4,56(a5)

    return addr;
ffffffe000201380:	fd043783          	ld	a5,-48(s0)
}
ffffffe000201384:	00078513          	mv	a0,a5
ffffffe000201388:	04813083          	ld	ra,72(sp)
ffffffe00020138c:	04013403          	ld	s0,64(sp)
ffffffe000201390:	05010113          	addi	sp,sp,80
ffffffe000201394:	00008067          	ret

ffffffe000201398 <load_program>:
// #define VM_EXEC 0x8

// #define PF_X		(1 << 0)
// #define PF_W		(1 << 1)
// #define PF_R		(1 << 2)
void load_program(struct task_struct *task) {
ffffffe000201398:	fa010113          	addi	sp,sp,-96
ffffffe00020139c:	04113c23          	sd	ra,88(sp)
ffffffe0002013a0:	04813823          	sd	s0,80(sp)
ffffffe0002013a4:	06010413          	addi	s0,sp,96
ffffffe0002013a8:	faa43c23          	sd	a0,-72(s0)
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
ffffffe0002013ac:	00005797          	auipc	a5,0x5
ffffffe0002013b0:	c5478793          	addi	a5,a5,-940 # ffffffe000206000 <_sramdisk>
ffffffe0002013b4:	fef43023          	sd	a5,-32(s0)

    // LogGREEN("ehdr->e_ident = 0x%llx", *((uint64_t*)ehdr->e_ident));
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
ffffffe0002013b8:	fe043783          	ld	a5,-32(s0)
ffffffe0002013bc:	0207b703          	ld	a4,32(a5)
ffffffe0002013c0:	00005797          	auipc	a5,0x5
ffffffe0002013c4:	c4078793          	addi	a5,a5,-960 # ffffffe000206000 <_sramdisk>
ffffffe0002013c8:	00f707b3          	add	a5,a4,a5
ffffffe0002013cc:	fcf43c23          	sd	a5,-40(s0)
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe0002013d0:	fe042623          	sw	zero,-20(s0)
ffffffe0002013d4:	1300006f          	j	ffffffe000201504 <load_program+0x16c>
        Elf64_Phdr *phdr = phdrs + i;
ffffffe0002013d8:	fec42703          	lw	a4,-20(s0)
ffffffe0002013dc:	00070793          	mv	a5,a4
ffffffe0002013e0:	00379793          	slli	a5,a5,0x3
ffffffe0002013e4:	40e787b3          	sub	a5,a5,a4
ffffffe0002013e8:	00379793          	slli	a5,a5,0x3
ffffffe0002013ec:	00078713          	mv	a4,a5
ffffffe0002013f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002013f4:	00e787b3          	add	a5,a5,a4
ffffffe0002013f8:	fcf43823          	sd	a5,-48(s0)
        if (phdr->p_type == PT_LOAD) {
ffffffe0002013fc:	fd043783          	ld	a5,-48(s0)
ffffffe000201400:	0007a783          	lw	a5,0(a5)
ffffffe000201404:	00078713          	mv	a4,a5
ffffffe000201408:	00100793          	li	a5,1
ffffffe00020140c:	0ef71663          	bne	a4,a5,ffffffe0002014f8 <load_program+0x160>
            uint64_t perm = (phdr->p_flags & PF_X) << 3 | (phdr->p_flags & PF_R) >> 1 | (phdr->p_flags & PF_W) << 1;
ffffffe000201410:	fd043783          	ld	a5,-48(s0)
ffffffe000201414:	0047a783          	lw	a5,4(a5)
ffffffe000201418:	0037979b          	slliw	a5,a5,0x3
ffffffe00020141c:	0007879b          	sext.w	a5,a5
ffffffe000201420:	0087f793          	andi	a5,a5,8
ffffffe000201424:	0007871b          	sext.w	a4,a5
ffffffe000201428:	fd043783          	ld	a5,-48(s0)
ffffffe00020142c:	0047a783          	lw	a5,4(a5)
ffffffe000201430:	0017d79b          	srliw	a5,a5,0x1
ffffffe000201434:	0007879b          	sext.w	a5,a5
ffffffe000201438:	0027f793          	andi	a5,a5,2
ffffffe00020143c:	0007879b          	sext.w	a5,a5
ffffffe000201440:	00f767b3          	or	a5,a4,a5
ffffffe000201444:	0007871b          	sext.w	a4,a5
ffffffe000201448:	fd043783          	ld	a5,-48(s0)
ffffffe00020144c:	0047a783          	lw	a5,4(a5)
ffffffe000201450:	0017979b          	slliw	a5,a5,0x1
ffffffe000201454:	0007879b          	sext.w	a5,a5
ffffffe000201458:	0047f793          	andi	a5,a5,4
ffffffe00020145c:	0007879b          	sext.w	a5,a5
ffffffe000201460:	00f767b3          	or	a5,a4,a5
ffffffe000201464:	0007879b          	sext.w	a5,a5
ffffffe000201468:	02079793          	slli	a5,a5,0x20
ffffffe00020146c:	0207d793          	srli	a5,a5,0x20
ffffffe000201470:	fcf43423          	sd	a5,-56(s0)
            LogYELLOW("phdr->p_vaddr = 0x%llx, phdr->p_memsz = 0x%llx, phdr->p_offset = 0x%llx, phdr->p_filesz = 0x%llx, perm = 0x%llx", phdr->p_vaddr, phdr->p_memsz, phdr->p_offset, phdr->p_filesz, perm);
ffffffe000201474:	fd043783          	ld	a5,-48(s0)
ffffffe000201478:	0107b703          	ld	a4,16(a5)
ffffffe00020147c:	fd043783          	ld	a5,-48(s0)
ffffffe000201480:	0287b683          	ld	a3,40(a5)
ffffffe000201484:	fd043783          	ld	a5,-48(s0)
ffffffe000201488:	0087b603          	ld	a2,8(a5)
ffffffe00020148c:	fd043783          	ld	a5,-48(s0)
ffffffe000201490:	0207b583          	ld	a1,32(a5)
ffffffe000201494:	fc843783          	ld	a5,-56(s0)
ffffffe000201498:	00f13023          	sd	a5,0(sp)
ffffffe00020149c:	00058893          	mv	a7,a1
ffffffe0002014a0:	00060813          	mv	a6,a2
ffffffe0002014a4:	00068793          	mv	a5,a3
ffffffe0002014a8:	00003697          	auipc	a3,0x3
ffffffe0002014ac:	dc868693          	addi	a3,a3,-568 # ffffffe000204270 <__func__.0>
ffffffe0002014b0:	17700613          	li	a2,375
ffffffe0002014b4:	00003597          	auipc	a1,0x3
ffffffe0002014b8:	c7458593          	addi	a1,a1,-908 # ffffffe000204128 <__func__.1+0x128>
ffffffe0002014bc:	00003517          	auipc	a0,0x3
ffffffe0002014c0:	d1c50513          	addi	a0,a0,-740 # ffffffe0002041d8 <__func__.1+0x1d8>
ffffffe0002014c4:	600020ef          	jal	ra,ffffffe000203ac4 <printk>
            do_mmap(&(task->mm), phdr->p_paddr, phdr->p_memsz, phdr->p_offset, phdr->p_filesz, perm);
ffffffe0002014c8:	fb843783          	ld	a5,-72(s0)
ffffffe0002014cc:	0b078513          	addi	a0,a5,176
ffffffe0002014d0:	fd043783          	ld	a5,-48(s0)
ffffffe0002014d4:	0187b583          	ld	a1,24(a5)
ffffffe0002014d8:	fd043783          	ld	a5,-48(s0)
ffffffe0002014dc:	0287b603          	ld	a2,40(a5)
ffffffe0002014e0:	fd043783          	ld	a5,-48(s0)
ffffffe0002014e4:	0087b683          	ld	a3,8(a5)
ffffffe0002014e8:	fd043783          	ld	a5,-48(s0)
ffffffe0002014ec:	0207b703          	ld	a4,32(a5)
ffffffe0002014f0:	fc843783          	ld	a5,-56(s0)
ffffffe0002014f4:	dadff0ef          	jal	ra,ffffffe0002012a0 <do_mmap>
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe0002014f8:	fec42783          	lw	a5,-20(s0)
ffffffe0002014fc:	0017879b          	addiw	a5,a5,1
ffffffe000201500:	fef42623          	sw	a5,-20(s0)
ffffffe000201504:	fe043783          	ld	a5,-32(s0)
ffffffe000201508:	0387d783          	lhu	a5,56(a5)
ffffffe00020150c:	0007871b          	sext.w	a4,a5
ffffffe000201510:	fec42783          	lw	a5,-20(s0)
ffffffe000201514:	0007879b          	sext.w	a5,a5
ffffffe000201518:	ece7c0e3          	blt	a5,a4,ffffffe0002013d8 <load_program+0x40>
        }
    }
    do_mmap(&(task->mm), USER_END - PGSIZE, PGSIZE, 0, PGSIZE, VM_READ | VM_ANON | VM_WRITE);
ffffffe00020151c:	fb843783          	ld	a5,-72(s0)
ffffffe000201520:	0b078513          	addi	a0,a5,176
ffffffe000201524:	00700793          	li	a5,7
ffffffe000201528:	00001737          	lui	a4,0x1
ffffffe00020152c:	00000693          	li	a3,0
ffffffe000201530:	00001637          	lui	a2,0x1
ffffffe000201534:	040005b7          	lui	a1,0x4000
ffffffe000201538:	fff58593          	addi	a1,a1,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe00020153c:	00c59593          	slli	a1,a1,0xc
ffffffe000201540:	d61ff0ef          	jal	ra,ffffffe0002012a0 <do_mmap>
    task->thread.sepc = ehdr->e_entry;
ffffffe000201544:	fe043783          	ld	a5,-32(s0)
ffffffe000201548:	0187b703          	ld	a4,24(a5)
ffffffe00020154c:	fb843783          	ld	a5,-72(s0)
ffffffe000201550:	08e7b823          	sd	a4,144(a5)
}
ffffffe000201554:	00000013          	nop
ffffffe000201558:	05813083          	ld	ra,88(sp)
ffffffe00020155c:	05013403          	ld	s0,80(sp)
ffffffe000201560:	06010113          	addi	sp,sp,96
ffffffe000201564:	00008067          	ret

ffffffe000201568 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000201568:	f8010113          	addi	sp,sp,-128
ffffffe00020156c:	06813c23          	sd	s0,120(sp)
ffffffe000201570:	06913823          	sd	s1,112(sp)
ffffffe000201574:	07213423          	sd	s2,104(sp)
ffffffe000201578:	07313023          	sd	s3,96(sp)
ffffffe00020157c:	08010413          	addi	s0,sp,128
ffffffe000201580:	faa43c23          	sd	a0,-72(s0)
ffffffe000201584:	fab43823          	sd	a1,-80(s0)
ffffffe000201588:	fac43423          	sd	a2,-88(s0)
ffffffe00020158c:	fad43023          	sd	a3,-96(s0)
ffffffe000201590:	f8e43c23          	sd	a4,-104(s0)
ffffffe000201594:	f8f43823          	sd	a5,-112(s0)
ffffffe000201598:	f9043423          	sd	a6,-120(s0)
ffffffe00020159c:	f9143023          	sd	a7,-128(s0)
    
    struct sbiret sbiRet;

    asm volatile (
ffffffe0002015a0:	fb843e03          	ld	t3,-72(s0)
ffffffe0002015a4:	fb043e83          	ld	t4,-80(s0)
ffffffe0002015a8:	fa843f03          	ld	t5,-88(s0)
ffffffe0002015ac:	fa043f83          	ld	t6,-96(s0)
ffffffe0002015b0:	f9843283          	ld	t0,-104(s0)
ffffffe0002015b4:	f9043483          	ld	s1,-112(s0)
ffffffe0002015b8:	f8843903          	ld	s2,-120(s0)
ffffffe0002015bc:	f8043983          	ld	s3,-128(s0)
ffffffe0002015c0:	01c008b3          	add	a7,zero,t3
ffffffe0002015c4:	01d00833          	add	a6,zero,t4
ffffffe0002015c8:	01e00533          	add	a0,zero,t5
ffffffe0002015cc:	01f005b3          	add	a1,zero,t6
ffffffe0002015d0:	00500633          	add	a2,zero,t0
ffffffe0002015d4:	009006b3          	add	a3,zero,s1
ffffffe0002015d8:	01200733          	add	a4,zero,s2
ffffffe0002015dc:	013007b3          	add	a5,zero,s3
ffffffe0002015e0:	00000073          	ecall
ffffffe0002015e4:	00050e93          	mv	t4,a0
ffffffe0002015e8:	00058e13          	mv	t3,a1
ffffffe0002015ec:	fdd43023          	sd	t4,-64(s0)
ffffffe0002015f0:	fdc43423          	sd	t3,-56(s0)
        : "=r"(sbiRet.error), "=r"(sbiRet.value)
        : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );

    return sbiRet;
ffffffe0002015f4:	fc043783          	ld	a5,-64(s0)
ffffffe0002015f8:	fcf43823          	sd	a5,-48(s0)
ffffffe0002015fc:	fc843783          	ld	a5,-56(s0)
ffffffe000201600:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201604:	fd043703          	ld	a4,-48(s0)
ffffffe000201608:	fd843783          	ld	a5,-40(s0)
ffffffe00020160c:	00070313          	mv	t1,a4
ffffffe000201610:	00078393          	mv	t2,a5
ffffffe000201614:	00030713          	mv	a4,t1
ffffffe000201618:	00038793          	mv	a5,t2
}
ffffffe00020161c:	00070513          	mv	a0,a4
ffffffe000201620:	00078593          	mv	a1,a5
ffffffe000201624:	07813403          	ld	s0,120(sp)
ffffffe000201628:	07013483          	ld	s1,112(sp)
ffffffe00020162c:	06813903          	ld	s2,104(sp)
ffffffe000201630:	06013983          	ld	s3,96(sp)
ffffffe000201634:	08010113          	addi	sp,sp,128
ffffffe000201638:	00008067          	ret

ffffffe00020163c <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe00020163c:	fc010113          	addi	sp,sp,-64
ffffffe000201640:	02113c23          	sd	ra,56(sp)
ffffffe000201644:	02813823          	sd	s0,48(sp)
ffffffe000201648:	03213423          	sd	s2,40(sp)
ffffffe00020164c:	03313023          	sd	s3,32(sp)
ffffffe000201650:	04010413          	addi	s0,sp,64
ffffffe000201654:	00050793          	mv	a5,a0
ffffffe000201658:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
ffffffe00020165c:	fcf44603          	lbu	a2,-49(s0)
ffffffe000201660:	00000893          	li	a7,0
ffffffe000201664:	00000813          	li	a6,0
ffffffe000201668:	00000793          	li	a5,0
ffffffe00020166c:	00000713          	li	a4,0
ffffffe000201670:	00000693          	li	a3,0
ffffffe000201674:	00200593          	li	a1,2
ffffffe000201678:	44424537          	lui	a0,0x44424
ffffffe00020167c:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000201680:	ee9ff0ef          	jal	ra,ffffffe000201568 <sbi_ecall>
ffffffe000201684:	00050713          	mv	a4,a0
ffffffe000201688:	00058793          	mv	a5,a1
ffffffe00020168c:	fce43823          	sd	a4,-48(s0)
ffffffe000201690:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201694:	fd043703          	ld	a4,-48(s0)
ffffffe000201698:	fd843783          	ld	a5,-40(s0)
ffffffe00020169c:	00070913          	mv	s2,a4
ffffffe0002016a0:	00078993          	mv	s3,a5
ffffffe0002016a4:	00090713          	mv	a4,s2
ffffffe0002016a8:	00098793          	mv	a5,s3
}
ffffffe0002016ac:	00070513          	mv	a0,a4
ffffffe0002016b0:	00078593          	mv	a1,a5
ffffffe0002016b4:	03813083          	ld	ra,56(sp)
ffffffe0002016b8:	03013403          	ld	s0,48(sp)
ffffffe0002016bc:	02813903          	ld	s2,40(sp)
ffffffe0002016c0:	02013983          	ld	s3,32(sp)
ffffffe0002016c4:	04010113          	addi	sp,sp,64
ffffffe0002016c8:	00008067          	ret

ffffffe0002016cc <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe0002016cc:	fc010113          	addi	sp,sp,-64
ffffffe0002016d0:	02113c23          	sd	ra,56(sp)
ffffffe0002016d4:	02813823          	sd	s0,48(sp)
ffffffe0002016d8:	03213423          	sd	s2,40(sp)
ffffffe0002016dc:	03313023          	sd	s3,32(sp)
ffffffe0002016e0:	04010413          	addi	s0,sp,64
ffffffe0002016e4:	00050793          	mv	a5,a0
ffffffe0002016e8:	00058713          	mv	a4,a1
ffffffe0002016ec:	fcf42623          	sw	a5,-52(s0)
ffffffe0002016f0:	00070793          	mv	a5,a4
ffffffe0002016f4:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe0002016f8:	fcc46603          	lwu	a2,-52(s0)
ffffffe0002016fc:	fc846683          	lwu	a3,-56(s0)
ffffffe000201700:	00000893          	li	a7,0
ffffffe000201704:	00000813          	li	a6,0
ffffffe000201708:	00000793          	li	a5,0
ffffffe00020170c:	00000713          	li	a4,0
ffffffe000201710:	00000593          	li	a1,0
ffffffe000201714:	53525537          	lui	a0,0x53525
ffffffe000201718:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe00020171c:	e4dff0ef          	jal	ra,ffffffe000201568 <sbi_ecall>
ffffffe000201720:	00050713          	mv	a4,a0
ffffffe000201724:	00058793          	mv	a5,a1
ffffffe000201728:	fce43823          	sd	a4,-48(s0)
ffffffe00020172c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201730:	fd043703          	ld	a4,-48(s0)
ffffffe000201734:	fd843783          	ld	a5,-40(s0)
ffffffe000201738:	00070913          	mv	s2,a4
ffffffe00020173c:	00078993          	mv	s3,a5
ffffffe000201740:	00090713          	mv	a4,s2
ffffffe000201744:	00098793          	mv	a5,s3
}
ffffffe000201748:	00070513          	mv	a0,a4
ffffffe00020174c:	00078593          	mv	a1,a5
ffffffe000201750:	03813083          	ld	ra,56(sp)
ffffffe000201754:	03013403          	ld	s0,48(sp)
ffffffe000201758:	02813903          	ld	s2,40(sp)
ffffffe00020175c:	02013983          	ld	s3,32(sp)
ffffffe000201760:	04010113          	addi	sp,sp,64
ffffffe000201764:	00008067          	ret

ffffffe000201768 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe000201768:	fc010113          	addi	sp,sp,-64
ffffffe00020176c:	02113c23          	sd	ra,56(sp)
ffffffe000201770:	02813823          	sd	s0,48(sp)
ffffffe000201774:	03213423          	sd	s2,40(sp)
ffffffe000201778:	03313023          	sd	s3,32(sp)
ffffffe00020177c:	04010413          	addi	s0,sp,64
ffffffe000201780:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
ffffffe000201784:	00000893          	li	a7,0
ffffffe000201788:	00000813          	li	a6,0
ffffffe00020178c:	00000793          	li	a5,0
ffffffe000201790:	00000713          	li	a4,0
ffffffe000201794:	00000693          	li	a3,0
ffffffe000201798:	fc843603          	ld	a2,-56(s0)
ffffffe00020179c:	00000593          	li	a1,0
ffffffe0002017a0:	54495537          	lui	a0,0x54495
ffffffe0002017a4:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe0002017a8:	dc1ff0ef          	jal	ra,ffffffe000201568 <sbi_ecall>
ffffffe0002017ac:	00050713          	mv	a4,a0
ffffffe0002017b0:	00058793          	mv	a5,a1
ffffffe0002017b4:	fce43823          	sd	a4,-48(s0)
ffffffe0002017b8:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002017bc:	fd043703          	ld	a4,-48(s0)
ffffffe0002017c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002017c4:	00070913          	mv	s2,a4
ffffffe0002017c8:	00078993          	mv	s3,a5
ffffffe0002017cc:	00090713          	mv	a4,s2
ffffffe0002017d0:	00098793          	mv	a5,s3
ffffffe0002017d4:	00070513          	mv	a0,a4
ffffffe0002017d8:	00078593          	mv	a1,a5
ffffffe0002017dc:	03813083          	ld	ra,56(sp)
ffffffe0002017e0:	03013403          	ld	s0,48(sp)
ffffffe0002017e4:	02813903          	ld	s2,40(sp)
ffffffe0002017e8:	02013983          	ld	s3,32(sp)
ffffffe0002017ec:	04010113          	addi	sp,sp,64
ffffffe0002017f0:	00008067          	ret

ffffffe0002017f4 <trap_handler>:
extern char _sramdisk[], _eramdisk[];
extern uint64_t nr_tasks;
extern struct task_struct *task[];
extern void __ret_from_fork();
extern uint64_t swapper_pg_dir[];
void trap_handler(uint64_t scause, uint64_t sepc, uint64_t sstatus, struct pt_regs *regs) {
ffffffe0002017f4:	f9010113          	addi	sp,sp,-112
ffffffe0002017f8:	06113423          	sd	ra,104(sp)
ffffffe0002017fc:	06813023          	sd	s0,96(sp)
ffffffe000201800:	07010413          	addi	s0,sp,112
ffffffe000201804:	faa43423          	sd	a0,-88(s0)
ffffffe000201808:	fab43023          	sd	a1,-96(s0)
ffffffe00020180c:	f8c43c23          	sd	a2,-104(s0)
ffffffe000201810:	f8d43823          	sd	a3,-112(s0)
    // 通过 `scause` 判断 trap 类型
    uint64_t _stvac = csr_read(stval);
ffffffe000201814:	143027f3          	csrr	a5,stval
ffffffe000201818:	fef43423          	sd	a5,-24(s0)
ffffffe00020181c:	fe843783          	ld	a5,-24(s0)
ffffffe000201820:	fef43023          	sd	a5,-32(s0)
    LogPURPLE("scause: 0x%llx, sstatus: 0x%llx, sepc: 0x%llx, stvac: 0x%llx", scause, sstatus, sepc, _stvac);
ffffffe000201824:	fe043883          	ld	a7,-32(s0)
ffffffe000201828:	fa043803          	ld	a6,-96(s0)
ffffffe00020182c:	f9843783          	ld	a5,-104(s0)
ffffffe000201830:	fa843703          	ld	a4,-88(s0)
ffffffe000201834:	00003697          	auipc	a3,0x3
ffffffe000201838:	dd468693          	addi	a3,a3,-556 # ffffffe000204608 <__func__.2>
ffffffe00020183c:	01200613          	li	a2,18
ffffffe000201840:	00003597          	auipc	a1,0x3
ffffffe000201844:	a4058593          	addi	a1,a1,-1472 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201848:	00003517          	auipc	a0,0x3
ffffffe00020184c:	a4050513          	addi	a0,a0,-1472 # ffffffe000204288 <__func__.0+0x18>
ffffffe000201850:	274020ef          	jal	ra,ffffffe000203ac4 <printk>
    // if (scause == 0x1) Err("_*stvac = 0x%llx", *(uint64_t*)_stvac);
    if(scause == 0x8000000000000005){
ffffffe000201854:	fa843703          	ld	a4,-88(s0)
ffffffe000201858:	fff00793          	li	a5,-1
ffffffe00020185c:	03f79793          	slli	a5,a5,0x3f
ffffffe000201860:	00578793          	addi	a5,a5,5
ffffffe000201864:	02f71863          	bne	a4,a5,ffffffe000201894 <trap_handler+0xa0>
        LogRED("Timer Interrupt");
ffffffe000201868:	00003697          	auipc	a3,0x3
ffffffe00020186c:	da068693          	addi	a3,a3,-608 # ffffffe000204608 <__func__.2>
ffffffe000201870:	01500613          	li	a2,21
ffffffe000201874:	00003597          	auipc	a1,0x3
ffffffe000201878:	a0c58593          	addi	a1,a1,-1524 # ffffffe000204280 <__func__.0+0x10>
ffffffe00020187c:	00003517          	auipc	a0,0x3
ffffffe000201880:	a6450513          	addi	a0,a0,-1436 # ffffffe0002042e0 <__func__.0+0x70>
ffffffe000201884:	240020ef          	jal	ra,ffffffe000203ac4 <printk>
        clock_set_next_event();
ffffffe000201888:	a5dfe0ef          	jal	ra,ffffffe0002002e4 <clock_set_next_event>
        do_timer();
ffffffe00020188c:	bd0ff0ef          	jal	ra,ffffffe000200c5c <do_timer>
ffffffe000201890:	1840006f          	j	ffffffe000201a14 <trap_handler+0x220>
    }else if(scause == 0xc){
ffffffe000201894:	fa843703          	ld	a4,-88(s0)
ffffffe000201898:	00c00793          	li	a5,12
ffffffe00020189c:	0af71a63          	bne	a4,a5,ffffffe000201950 <trap_handler+0x15c>
        LogRED("Instruction Page Fault");
ffffffe0002018a0:	00003697          	auipc	a3,0x3
ffffffe0002018a4:	d6868693          	addi	a3,a3,-664 # ffffffe000204608 <__func__.2>
ffffffe0002018a8:	01900613          	li	a2,25
ffffffe0002018ac:	00003597          	auipc	a1,0x3
ffffffe0002018b0:	9d458593          	addi	a1,a1,-1580 # ffffffe000204280 <__func__.0+0x10>
ffffffe0002018b4:	00003517          	auipc	a0,0x3
ffffffe0002018b8:	a5450513          	addi	a0,a0,-1452 # ffffffe000204308 <__func__.0+0x98>
ffffffe0002018bc:	208020ef          	jal	ra,ffffffe000203ac4 <printk>
        if(sepc < VM_START && sepc > USER_END){
ffffffe0002018c0:	fa043703          	ld	a4,-96(s0)
ffffffe0002018c4:	fff00793          	li	a5,-1
ffffffe0002018c8:	02579793          	slli	a5,a5,0x25
ffffffe0002018cc:	06f77463          	bgeu	a4,a5,ffffffe000201934 <trap_handler+0x140>
ffffffe0002018d0:	fa043703          	ld	a4,-96(s0)
ffffffe0002018d4:	00100793          	li	a5,1
ffffffe0002018d8:	02679793          	slli	a5,a5,0x26
ffffffe0002018dc:	04e7fc63          	bgeu	a5,a4,ffffffe000201934 <trap_handler+0x140>
            LogGREEN("[Physical Address: 0x%llx] -> [Virtual Address: 0x%llx]", sepc, sepc + 0xffffffdf80000000);
ffffffe0002018e0:	fa043703          	ld	a4,-96(s0)
ffffffe0002018e4:	fbf00793          	li	a5,-65
ffffffe0002018e8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002018ec:	00f707b3          	add	a5,a4,a5
ffffffe0002018f0:	fa043703          	ld	a4,-96(s0)
ffffffe0002018f4:	00003697          	auipc	a3,0x3
ffffffe0002018f8:	d1468693          	addi	a3,a3,-748 # ffffffe000204608 <__func__.2>
ffffffe0002018fc:	01b00613          	li	a2,27
ffffffe000201900:	00003597          	auipc	a1,0x3
ffffffe000201904:	98058593          	addi	a1,a1,-1664 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201908:	00003517          	auipc	a0,0x3
ffffffe00020190c:	a3050513          	addi	a0,a0,-1488 # ffffffe000204338 <__func__.0+0xc8>
ffffffe000201910:	1b4020ef          	jal	ra,ffffffe000203ac4 <printk>
            csr_write(sepc, sepc + 0xffffffdf80000000);
ffffffe000201914:	fa043703          	ld	a4,-96(s0)
ffffffe000201918:	fbf00793          	li	a5,-65
ffffffe00020191c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201920:	00f707b3          	add	a5,a4,a5
ffffffe000201924:	fcf43423          	sd	a5,-56(s0)
ffffffe000201928:	fc843783          	ld	a5,-56(s0)
ffffffe00020192c:	14179073          	csrw	sepc,a5
            return;
ffffffe000201930:	1140006f          	j	ffffffe000201a44 <trap_handler+0x250>
        }
        do_page_fault(regs);
ffffffe000201934:	f9043503          	ld	a0,-112(s0)
ffffffe000201938:	308000ef          	jal	ra,ffffffe000201c40 <do_page_fault>
        csr_write(sepc, sepc);
ffffffe00020193c:	fa043783          	ld	a5,-96(s0)
ffffffe000201940:	fcf43023          	sd	a5,-64(s0)
ffffffe000201944:	fc043783          	ld	a5,-64(s0)
ffffffe000201948:	14179073          	csrw	sepc,a5
        return;
ffffffe00020194c:	0f80006f          	j	ffffffe000201a44 <trap_handler+0x250>
    }else if(scause == 0xf){
ffffffe000201950:	fa843703          	ld	a4,-88(s0)
ffffffe000201954:	00f00793          	li	a5,15
ffffffe000201958:	04f71063          	bne	a4,a5,ffffffe000201998 <trap_handler+0x1a4>
        LogRED("Store/AMO Page Fault");
ffffffe00020195c:	00003697          	auipc	a3,0x3
ffffffe000201960:	cac68693          	addi	a3,a3,-852 # ffffffe000204608 <__func__.2>
ffffffe000201964:	02300613          	li	a2,35
ffffffe000201968:	00003597          	auipc	a1,0x3
ffffffe00020196c:	91858593          	addi	a1,a1,-1768 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201970:	00003517          	auipc	a0,0x3
ffffffe000201974:	a1850513          	addi	a0,a0,-1512 # ffffffe000204388 <__func__.0+0x118>
ffffffe000201978:	14c020ef          	jal	ra,ffffffe000203ac4 <printk>
        do_page_fault(regs);
ffffffe00020197c:	f9043503          	ld	a0,-112(s0)
ffffffe000201980:	2c0000ef          	jal	ra,ffffffe000201c40 <do_page_fault>
        csr_write(sepc, sepc);
ffffffe000201984:	fa043783          	ld	a5,-96(s0)
ffffffe000201988:	fcf43823          	sd	a5,-48(s0)
ffffffe00020198c:	fd043783          	ld	a5,-48(s0)
ffffffe000201990:	14179073          	csrw	sepc,a5
        return;
ffffffe000201994:	0b00006f          	j	ffffffe000201a44 <trap_handler+0x250>
    }else if(scause == 0xd){
ffffffe000201998:	fa843703          	ld	a4,-88(s0)
ffffffe00020199c:	00d00793          	li	a5,13
ffffffe0002019a0:	04f71063          	bne	a4,a5,ffffffe0002019e0 <trap_handler+0x1ec>
        LogRED("Load Page Fault");
ffffffe0002019a4:	00003697          	auipc	a3,0x3
ffffffe0002019a8:	c6468693          	addi	a3,a3,-924 # ffffffe000204608 <__func__.2>
ffffffe0002019ac:	02800613          	li	a2,40
ffffffe0002019b0:	00003597          	auipc	a1,0x3
ffffffe0002019b4:	8d058593          	addi	a1,a1,-1840 # ffffffe000204280 <__func__.0+0x10>
ffffffe0002019b8:	00003517          	auipc	a0,0x3
ffffffe0002019bc:	a0050513          	addi	a0,a0,-1536 # ffffffe0002043b8 <__func__.0+0x148>
ffffffe0002019c0:	104020ef          	jal	ra,ffffffe000203ac4 <printk>
        do_page_fault(regs);
ffffffe0002019c4:	f9043503          	ld	a0,-112(s0)
ffffffe0002019c8:	278000ef          	jal	ra,ffffffe000201c40 <do_page_fault>
        csr_write(sepc, sepc);
ffffffe0002019cc:	fa043783          	ld	a5,-96(s0)
ffffffe0002019d0:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002019d4:	fd843783          	ld	a5,-40(s0)
ffffffe0002019d8:	14179073          	csrw	sepc,a5
        return;
ffffffe0002019dc:	0680006f          	j	ffffffe000201a44 <trap_handler+0x250>
    }else if(scause == 0x8){
ffffffe0002019e0:	fa843703          	ld	a4,-88(s0)
ffffffe0002019e4:	00800793          	li	a5,8
ffffffe0002019e8:	02f71663          	bne	a4,a5,ffffffe000201a14 <trap_handler+0x220>
        LogRED("Environment Call from U-mode");
ffffffe0002019ec:	00003697          	auipc	a3,0x3
ffffffe0002019f0:	c1c68693          	addi	a3,a3,-996 # ffffffe000204608 <__func__.2>
ffffffe0002019f4:	02d00613          	li	a2,45
ffffffe0002019f8:	00003597          	auipc	a1,0x3
ffffffe0002019fc:	88858593          	addi	a1,a1,-1912 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201a00:	00003517          	auipc	a0,0x3
ffffffe000201a04:	9e050513          	addi	a0,a0,-1568 # ffffffe0002043e0 <__func__.0+0x170>
ffffffe000201a08:	0bc020ef          	jal	ra,ffffffe000203ac4 <printk>
        syscall(regs);
ffffffe000201a0c:	f9043503          	ld	a0,-112(s0)
ffffffe000201a10:	07c000ef          	jal	ra,ffffffe000201a8c <syscall>
    }

    if (scause & 0x8000000000000000) {
ffffffe000201a14:	fa843783          	ld	a5,-88(s0)
ffffffe000201a18:	0007dc63          	bgez	a5,ffffffe000201a30 <trap_handler+0x23c>
        csr_write(sepc, sepc);
ffffffe000201a1c:	fa043783          	ld	a5,-96(s0)
ffffffe000201a20:	faf43823          	sd	a5,-80(s0)
ffffffe000201a24:	fb043783          	ld	a5,-80(s0)
ffffffe000201a28:	14179073          	csrw	sepc,a5
ffffffe000201a2c:	0180006f          	j	ffffffe000201a44 <trap_handler+0x250>
    } else {
        csr_write(sepc, sepc + 4);
ffffffe000201a30:	fa043783          	ld	a5,-96(s0)
ffffffe000201a34:	00478793          	addi	a5,a5,4
ffffffe000201a38:	faf43c23          	sd	a5,-72(s0)
ffffffe000201a3c:	fb843783          	ld	a5,-72(s0)
ffffffe000201a40:	14179073          	csrw	sepc,a5
    }
}
ffffffe000201a44:	06813083          	ld	ra,104(sp)
ffffffe000201a48:	06013403          	ld	s0,96(sp)
ffffffe000201a4c:	07010113          	addi	sp,sp,112
ffffffe000201a50:	00008067          	ret

ffffffe000201a54 <csr_change>:


void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
ffffffe000201a54:	fc010113          	addi	sp,sp,-64
ffffffe000201a58:	02813c23          	sd	s0,56(sp)
ffffffe000201a5c:	04010413          	addi	s0,sp,64
ffffffe000201a60:	fca43c23          	sd	a0,-40(s0)
ffffffe000201a64:	fcb43823          	sd	a1,-48(s0)
ffffffe000201a68:	fcc43423          	sd	a2,-56(s0)
    csr_write(sscratch, value);
ffffffe000201a6c:	fc843783          	ld	a5,-56(s0)
ffffffe000201a70:	fef43423          	sd	a5,-24(s0)
ffffffe000201a74:	fe843783          	ld	a5,-24(s0)
ffffffe000201a78:	14079073          	csrw	sscratch,a5
}
ffffffe000201a7c:	00000013          	nop
ffffffe000201a80:	03813403          	ld	s0,56(sp)
ffffffe000201a84:	04010113          	addi	sp,sp,64
ffffffe000201a88:	00008067          	ret

ffffffe000201a8c <syscall>:

void syscall(struct pt_regs *regs) {
ffffffe000201a8c:	fb010113          	addi	sp,sp,-80
ffffffe000201a90:	04113423          	sd	ra,72(sp)
ffffffe000201a94:	04813023          	sd	s0,64(sp)
ffffffe000201a98:	05010413          	addi	s0,sp,80
ffffffe000201a9c:	faa43c23          	sd	a0,-72(s0)
    uint64_t syscall_num = regs->x[17];
ffffffe000201aa0:	fb843783          	ld	a5,-72(s0)
ffffffe000201aa4:	0887b783          	ld	a5,136(a5)
ffffffe000201aa8:	fef43023          	sd	a5,-32(s0)
    if (syscall_num == (uint64_t)SYS_WRITE) {
ffffffe000201aac:	fe043703          	ld	a4,-32(s0)
ffffffe000201ab0:	04000793          	li	a5,64
ffffffe000201ab4:	0af71463          	bne	a4,a5,ffffffe000201b5c <syscall+0xd0>
        uint64_t fd = regs->x[10];
ffffffe000201ab8:	fb843783          	ld	a5,-72(s0)
ffffffe000201abc:	0507b783          	ld	a5,80(a5)
ffffffe000201ac0:	fcf43823          	sd	a5,-48(s0)
        uint64_t i = 0;
ffffffe000201ac4:	fe043423          	sd	zero,-24(s0)
        if (fd == 1) {
ffffffe000201ac8:	fd043703          	ld	a4,-48(s0)
ffffffe000201acc:	00100793          	li	a5,1
ffffffe000201ad0:	04f71c63          	bne	a4,a5,ffffffe000201b28 <syscall+0x9c>
            char *buf = (char *)regs->x[11];
ffffffe000201ad4:	fb843783          	ld	a5,-72(s0)
ffffffe000201ad8:	0587b783          	ld	a5,88(a5)
ffffffe000201adc:	fcf43423          	sd	a5,-56(s0)
            for (i = 0; i < regs->x[12]; i++) {
ffffffe000201ae0:	fe043423          	sd	zero,-24(s0)
ffffffe000201ae4:	0340006f          	j	ffffffe000201b18 <syscall+0x8c>
                printk("%c", buf[i]);
ffffffe000201ae8:	fc843703          	ld	a4,-56(s0)
ffffffe000201aec:	fe843783          	ld	a5,-24(s0)
ffffffe000201af0:	00f707b3          	add	a5,a4,a5
ffffffe000201af4:	0007c783          	lbu	a5,0(a5)
ffffffe000201af8:	0007879b          	sext.w	a5,a5
ffffffe000201afc:	00078593          	mv	a1,a5
ffffffe000201b00:	00003517          	auipc	a0,0x3
ffffffe000201b04:	91850513          	addi	a0,a0,-1768 # ffffffe000204418 <__func__.0+0x1a8>
ffffffe000201b08:	7bd010ef          	jal	ra,ffffffe000203ac4 <printk>
            for (i = 0; i < regs->x[12]; i++) {
ffffffe000201b0c:	fe843783          	ld	a5,-24(s0)
ffffffe000201b10:	00178793          	addi	a5,a5,1
ffffffe000201b14:	fef43423          	sd	a5,-24(s0)
ffffffe000201b18:	fb843783          	ld	a5,-72(s0)
ffffffe000201b1c:	0607b783          	ld	a5,96(a5)
ffffffe000201b20:	fe843703          	ld	a4,-24(s0)
ffffffe000201b24:	fcf762e3          	bltu	a4,a5,ffffffe000201ae8 <syscall+0x5c>
            }
        }
        regs->x[10] = i;
ffffffe000201b28:	fb843783          	ld	a5,-72(s0)
ffffffe000201b2c:	fe843703          	ld	a4,-24(s0)
ffffffe000201b30:	04e7b823          	sd	a4,80(a5)
        LogDEEPGREEN("Write: %d", i);
ffffffe000201b34:	fe843703          	ld	a4,-24(s0)
ffffffe000201b38:	00002697          	auipc	a3,0x2
ffffffe000201b3c:	4c868693          	addi	a3,a3,1224 # ffffffe000204000 <__func__.1>
ffffffe000201b40:	04900613          	li	a2,73
ffffffe000201b44:	00002597          	auipc	a1,0x2
ffffffe000201b48:	73c58593          	addi	a1,a1,1852 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201b4c:	00003517          	auipc	a0,0x3
ffffffe000201b50:	8d450513          	addi	a0,a0,-1836 # ffffffe000204420 <__func__.0+0x1b0>
ffffffe000201b54:	771010ef          	jal	ra,ffffffe000203ac4 <printk>
        uint64_t pid = do_fork(regs);
        LogYELLOW("[FORK] Parent PID = %d, Child PID = %d", current->pid, pid);
    } else {
        LogRED("Unsupported syscall: %d", syscall_num);
    }
    return;
ffffffe000201b58:	0d80006f          	j	ffffffe000201c30 <syscall+0x1a4>
    } else if (syscall_num == (uint64_t)SYS_GETPID) {
ffffffe000201b5c:	fe043703          	ld	a4,-32(s0)
ffffffe000201b60:	0ac00793          	li	a5,172
ffffffe000201b64:	04f71a63          	bne	a4,a5,ffffffe000201bb8 <syscall+0x12c>
        regs->x[10] = current->pid;
ffffffe000201b68:	00007797          	auipc	a5,0x7
ffffffe000201b6c:	4a878793          	addi	a5,a5,1192 # ffffffe000209010 <current>
ffffffe000201b70:	0007b783          	ld	a5,0(a5)
ffffffe000201b74:	0187b703          	ld	a4,24(a5)
ffffffe000201b78:	fb843783          	ld	a5,-72(s0)
ffffffe000201b7c:	04e7b823          	sd	a4,80(a5)
        LogDEEPGREEN("Getpid: %d", current->pid);
ffffffe000201b80:	00007797          	auipc	a5,0x7
ffffffe000201b84:	49078793          	addi	a5,a5,1168 # ffffffe000209010 <current>
ffffffe000201b88:	0007b783          	ld	a5,0(a5)
ffffffe000201b8c:	0187b783          	ld	a5,24(a5)
ffffffe000201b90:	00078713          	mv	a4,a5
ffffffe000201b94:	00002697          	auipc	a3,0x2
ffffffe000201b98:	46c68693          	addi	a3,a3,1132 # ffffffe000204000 <__func__.1>
ffffffe000201b9c:	04c00613          	li	a2,76
ffffffe000201ba0:	00002597          	auipc	a1,0x2
ffffffe000201ba4:	6e058593          	addi	a1,a1,1760 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201ba8:	00003517          	auipc	a0,0x3
ffffffe000201bac:	8a050513          	addi	a0,a0,-1888 # ffffffe000204448 <__func__.0+0x1d8>
ffffffe000201bb0:	715010ef          	jal	ra,ffffffe000203ac4 <printk>
    return;
ffffffe000201bb4:	07c0006f          	j	ffffffe000201c30 <syscall+0x1a4>
    } else if (syscall_num == (uint64_t)SYS_CLONE){
ffffffe000201bb8:	fe043703          	ld	a4,-32(s0)
ffffffe000201bbc:	0dc00793          	li	a5,220
ffffffe000201bc0:	04f71463          	bne	a4,a5,ffffffe000201c08 <syscall+0x17c>
        uint64_t pid = do_fork(regs);
ffffffe000201bc4:	fb843503          	ld	a0,-72(s0)
ffffffe000201bc8:	56c000ef          	jal	ra,ffffffe000202134 <do_fork>
ffffffe000201bcc:	fca43c23          	sd	a0,-40(s0)
        LogYELLOW("[FORK] Parent PID = %d, Child PID = %d", current->pid, pid);
ffffffe000201bd0:	00007797          	auipc	a5,0x7
ffffffe000201bd4:	44078793          	addi	a5,a5,1088 # ffffffe000209010 <current>
ffffffe000201bd8:	0007b783          	ld	a5,0(a5)
ffffffe000201bdc:	0187b703          	ld	a4,24(a5)
ffffffe000201be0:	fd843783          	ld	a5,-40(s0)
ffffffe000201be4:	00002697          	auipc	a3,0x2
ffffffe000201be8:	41c68693          	addi	a3,a3,1052 # ffffffe000204000 <__func__.1>
ffffffe000201bec:	04f00613          	li	a2,79
ffffffe000201bf0:	00002597          	auipc	a1,0x2
ffffffe000201bf4:	69058593          	addi	a1,a1,1680 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201bf8:	00003517          	auipc	a0,0x3
ffffffe000201bfc:	87850513          	addi	a0,a0,-1928 # ffffffe000204470 <__func__.0+0x200>
ffffffe000201c00:	6c5010ef          	jal	ra,ffffffe000203ac4 <printk>
    return;
ffffffe000201c04:	02c0006f          	j	ffffffe000201c30 <syscall+0x1a4>
        LogRED("Unsupported syscall: %d", syscall_num);
ffffffe000201c08:	fe043703          	ld	a4,-32(s0)
ffffffe000201c0c:	00002697          	auipc	a3,0x2
ffffffe000201c10:	3f468693          	addi	a3,a3,1012 # ffffffe000204000 <__func__.1>
ffffffe000201c14:	05100613          	li	a2,81
ffffffe000201c18:	00002597          	auipc	a1,0x2
ffffffe000201c1c:	66858593          	addi	a1,a1,1640 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201c20:	00003517          	auipc	a0,0x3
ffffffe000201c24:	89050513          	addi	a0,a0,-1904 # ffffffe0002044b0 <__func__.0+0x240>
ffffffe000201c28:	69d010ef          	jal	ra,ffffffe000203ac4 <printk>
    return;
ffffffe000201c2c:	00000013          	nop
}
ffffffe000201c30:	04813083          	ld	ra,72(sp)
ffffffe000201c34:	04013403          	ld	s0,64(sp)
ffffffe000201c38:	05010113          	addi	sp,sp,80
ffffffe000201c3c:	00008067          	ret

ffffffe000201c40 <do_page_fault>:
// #define VM_READ 0x2
// #define VM_WRITE 0x4
// #define VM_EXEC 0x8


void do_page_fault(struct pt_regs *regs) {
ffffffe000201c40:	f3010113          	addi	sp,sp,-208
ffffffe000201c44:	0c113423          	sd	ra,200(sp)
ffffffe000201c48:	0c813023          	sd	s0,192(sp)
ffffffe000201c4c:	0d010413          	addi	s0,sp,208
ffffffe000201c50:	f2a43c23          	sd	a0,-200(s0)
    uint64_t _stval = csr_read(stval);
ffffffe000201c54:	143027f3          	csrr	a5,stval
ffffffe000201c58:	fcf43423          	sd	a5,-56(s0)
ffffffe000201c5c:	fc843783          	ld	a5,-56(s0)
ffffffe000201c60:	fcf43023          	sd	a5,-64(s0)
    uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
ffffffe000201c64:	fc043703          	ld	a4,-64(s0)
ffffffe000201c68:	fffff7b7          	lui	a5,0xfffff
ffffffe000201c6c:	00f777b3          	and	a5,a4,a5
ffffffe000201c70:	faf43c23          	sd	a5,-72(s0)
    struct vm_area_struct *vma = find_vma(&current->mm, _stval);
ffffffe000201c74:	00007797          	auipc	a5,0x7
ffffffe000201c78:	39c78793          	addi	a5,a5,924 # ffffffe000209010 <current>
ffffffe000201c7c:	0007b783          	ld	a5,0(a5)
ffffffe000201c80:	0b078793          	addi	a5,a5,176
ffffffe000201c84:	fc043583          	ld	a1,-64(s0)
ffffffe000201c88:	00078513          	mv	a0,a5
ffffffe000201c8c:	da0ff0ef          	jal	ra,ffffffe00020122c <find_vma>
ffffffe000201c90:	faa43823          	sd	a0,-80(s0)
    if (!vma){
ffffffe000201c94:	fb043783          	ld	a5,-80(s0)
ffffffe000201c98:	02079663          	bnez	a5,ffffffe000201cc4 <do_page_fault+0x84>
        Err("No VMA found at 0x%llx", _stval);
ffffffe000201c9c:	fc043703          	ld	a4,-64(s0)
ffffffe000201ca0:	00003697          	auipc	a3,0x3
ffffffe000201ca4:	97868693          	addi	a3,a3,-1672 # ffffffe000204618 <__func__.0>
ffffffe000201ca8:	06600613          	li	a2,102
ffffffe000201cac:	00002597          	auipc	a1,0x2
ffffffe000201cb0:	5d458593          	addi	a1,a1,1492 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201cb4:	00003517          	auipc	a0,0x3
ffffffe000201cb8:	82c50513          	addi	a0,a0,-2004 # ffffffe0002044e0 <__func__.0+0x270>
ffffffe000201cbc:	609010ef          	jal	ra,ffffffe000203ac4 <printk>
ffffffe000201cc0:	0000006f          	j	ffffffe000201cc0 <do_page_fault+0x80>
        return;
    }

    uint64_t _scause = csr_read(scause);
ffffffe000201cc4:	142027f3          	csrr	a5,scause
ffffffe000201cc8:	faf43423          	sd	a5,-88(s0)
ffffffe000201ccc:	fa843783          	ld	a5,-88(s0)
ffffffe000201cd0:	faf43023          	sd	a5,-96(s0)
    if ((_scause == 0xc && !(vma->vm_flags & VM_EXEC) ) || // Instruction Fault 但是不可以执行
ffffffe000201cd4:	fa043703          	ld	a4,-96(s0)
ffffffe000201cd8:	00c00793          	li	a5,12
ffffffe000201cdc:	00f71a63          	bne	a4,a5,ffffffe000201cf0 <do_page_fault+0xb0>
ffffffe000201ce0:	fb043783          	ld	a5,-80(s0)
ffffffe000201ce4:	0287b783          	ld	a5,40(a5)
ffffffe000201ce8:	0087f793          	andi	a5,a5,8
ffffffe000201cec:	02078e63          	beqz	a5,ffffffe000201d28 <do_page_fault+0xe8>
ffffffe000201cf0:	fa043703          	ld	a4,-96(s0)
ffffffe000201cf4:	00d00793          	li	a5,13
ffffffe000201cf8:	00f71a63          	bne	a4,a5,ffffffe000201d0c <do_page_fault+0xcc>
        (_scause == 0xd && !(vma->vm_flags & VM_READ)) || // Load Fault 但是不可以读
ffffffe000201cfc:	fb043783          	ld	a5,-80(s0)
ffffffe000201d00:	0287b783          	ld	a5,40(a5)
ffffffe000201d04:	0027f793          	andi	a5,a5,2
ffffffe000201d08:	02078063          	beqz	a5,ffffffe000201d28 <do_page_fault+0xe8>
ffffffe000201d0c:	fa043703          	ld	a4,-96(s0)
ffffffe000201d10:	00f00793          	li	a5,15
ffffffe000201d14:	04f71e63          	bne	a4,a5,ffffffe000201d70 <do_page_fault+0x130>
        (_scause == 0xf && !(vma->vm_flags & VM_WRITE))){ // Store Fault 但是不可以写
ffffffe000201d18:	fb043783          	ld	a5,-80(s0)
ffffffe000201d1c:	0287b783          	ld	a5,40(a5)
ffffffe000201d20:	0047f793          	andi	a5,a5,4
ffffffe000201d24:	04079663          	bnez	a5,ffffffe000201d70 <do_page_fault+0x130>
        LogDEEPGREEN("Permission Denied");
ffffffe000201d28:	00003697          	auipc	a3,0x3
ffffffe000201d2c:	8f068693          	addi	a3,a3,-1808 # ffffffe000204618 <__func__.0>
ffffffe000201d30:	06e00613          	li	a2,110
ffffffe000201d34:	00002597          	auipc	a1,0x2
ffffffe000201d38:	54c58593          	addi	a1,a1,1356 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201d3c:	00002517          	auipc	a0,0x2
ffffffe000201d40:	7d450513          	addi	a0,a0,2004 # ffffffe000204510 <__func__.0+0x2a0>
ffffffe000201d44:	581010ef          	jal	ra,ffffffe000203ac4 <printk>
        Err("Permission Denied at 0x%llx", _stval);
ffffffe000201d48:	fc043703          	ld	a4,-64(s0)
ffffffe000201d4c:	00003697          	auipc	a3,0x3
ffffffe000201d50:	8cc68693          	addi	a3,a3,-1844 # ffffffe000204618 <__func__.0>
ffffffe000201d54:	06f00613          	li	a2,111
ffffffe000201d58:	00002597          	auipc	a1,0x2
ffffffe000201d5c:	52858593          	addi	a1,a1,1320 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201d60:	00002517          	auipc	a0,0x2
ffffffe000201d64:	7e050513          	addi	a0,a0,2016 # ffffffe000204540 <__func__.0+0x2d0>
ffffffe000201d68:	55d010ef          	jal	ra,ffffffe000203ac4 <printk>
ffffffe000201d6c:	0000006f          	j	ffffffe000201d6c <do_page_fault+0x12c>
        return;
    }

    uint64_t perm = (vma->vm_flags & VM_READ) | (vma->vm_flags & VM_EXEC) | (vma->vm_flags & VM_WRITE) | PTE_U | PTE_V; 
ffffffe000201d70:	fb043783          	ld	a5,-80(s0)
ffffffe000201d74:	0287b783          	ld	a5,40(a5)
ffffffe000201d78:	00e7f793          	andi	a5,a5,14
ffffffe000201d7c:	0117e793          	ori	a5,a5,17
ffffffe000201d80:	f8f43c23          	sd	a5,-104(s0)
    if (vma->vm_flags & VM_ANON){
ffffffe000201d84:	fb043783          	ld	a5,-80(s0)
ffffffe000201d88:	0287b783          	ld	a5,40(a5)
ffffffe000201d8c:	0017f793          	andi	a5,a5,1
ffffffe000201d90:	06078663          	beqz	a5,ffffffe000201dfc <do_page_fault+0x1bc>
        LogDEEPGREEN("ANON");
ffffffe000201d94:	00003697          	auipc	a3,0x3
ffffffe000201d98:	88468693          	addi	a3,a3,-1916 # ffffffe000204618 <__func__.0>
ffffffe000201d9c:	07500613          	li	a2,117
ffffffe000201da0:	00002597          	auipc	a1,0x2
ffffffe000201da4:	4e058593          	addi	a1,a1,1248 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201da8:	00002517          	auipc	a0,0x2
ffffffe000201dac:	7d050513          	addi	a0,a0,2000 # ffffffe000204578 <__func__.0+0x308>
ffffffe000201db0:	515010ef          	jal	ra,ffffffe000203ac4 <printk>
        // uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
        uint64_t pa = VA2PA((uint64_t)alloc_page());
ffffffe000201db4:	b95fe0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe000201db8:	00050793          	mv	a5,a0
ffffffe000201dbc:	00078713          	mv	a4,a5
ffffffe000201dc0:	04100793          	li	a5,65
ffffffe000201dc4:	01f79793          	slli	a5,a5,0x1f
ffffffe000201dc8:	00f707b3          	add	a5,a4,a5
ffffffe000201dcc:	f4f43423          	sd	a5,-184(s0)
        create_mapping(current->pgd, va, pa, PGSIZE, perm);
ffffffe000201dd0:	00007797          	auipc	a5,0x7
ffffffe000201dd4:	24078793          	addi	a5,a5,576 # ffffffe000209010 <current>
ffffffe000201dd8:	0007b783          	ld	a5,0(a5)
ffffffe000201ddc:	0a87b783          	ld	a5,168(a5)
ffffffe000201de0:	f9843703          	ld	a4,-104(s0)
ffffffe000201de4:	000016b7          	lui	a3,0x1
ffffffe000201de8:	f4843603          	ld	a2,-184(s0)
ffffffe000201dec:	fb843583          	ld	a1,-72(s0)
ffffffe000201df0:	00078513          	mv	a0,a5
ffffffe000201df4:	355000ef          	jal	ra,ffffffe000202948 <create_mapping>
ffffffe000201df8:	32c0006f          	j	ffffffe000202124 <do_page_fault+0x4e4>
    }else{
        LogDEEPGREEN("FILE");
ffffffe000201dfc:	00003697          	auipc	a3,0x3
ffffffe000201e00:	81c68693          	addi	a3,a3,-2020 # ffffffe000204618 <__func__.0>
ffffffe000201e04:	07a00613          	li	a2,122
ffffffe000201e08:	00002597          	auipc	a1,0x2
ffffffe000201e0c:	47858593          	addi	a1,a1,1144 # ffffffe000204280 <__func__.0+0x10>
ffffffe000201e10:	00002517          	auipc	a0,0x2
ffffffe000201e14:	78850513          	addi	a0,a0,1928 # ffffffe000204598 <__func__.0+0x328>
ffffffe000201e18:	4ad010ef          	jal	ra,ffffffe000203ac4 <printk>
        // uint64_t va = PGROUNDDOWN(_stval); 
        // LogBLUE("vm_start = 0x%llx, vm_pgoff = 0x%llx, vm_filesz = 0x%llx", vma->vm_start, vma->vm_pgoff, vma->vm_filesz);
        uint64_t *uapp = (uint64_t*)alloc_page();
ffffffe000201e1c:	b2dfe0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe000201e20:	00050793          	mv	a5,a0
ffffffe000201e24:	f8f43823          	sd	a5,-112(s0)
        if (PGROUNDDOWN(vma->vm_filesz) < PGSIZE){ // 整个uapp小于一页
ffffffe000201e28:	fb043783          	ld	a5,-80(s0)
ffffffe000201e2c:	0387b703          	ld	a4,56(a5)
ffffffe000201e30:	fffff7b7          	lui	a5,0xfffff
ffffffe000201e34:	00f77733          	and	a4,a4,a5
ffffffe000201e38:	000017b7          	lui	a5,0x1
ffffffe000201e3c:	08f77263          	bgeu	a4,a5,ffffffe000201ec0 <do_page_fault+0x280>
            
            char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
ffffffe000201e40:	fb043783          	ld	a5,-80(s0)
ffffffe000201e44:	0087b703          	ld	a4,8(a5) # 1008 <PGSIZE+0x8>
ffffffe000201e48:	000017b7          	lui	a5,0x1
ffffffe000201e4c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201e50:	00f777b3          	and	a5,a4,a5
ffffffe000201e54:	f9043703          	ld	a4,-112(s0)
ffffffe000201e58:	00f707b3          	add	a5,a4,a5
ffffffe000201e5c:	f4f43c23          	sd	a5,-168(s0)
            char *celf = (char*)_sramdisk + vma->vm_pgoff;
ffffffe000201e60:	fb043783          	ld	a5,-80(s0)
ffffffe000201e64:	0307b703          	ld	a4,48(a5)
ffffffe000201e68:	00004797          	auipc	a5,0x4
ffffffe000201e6c:	19878793          	addi	a5,a5,408 # ffffffe000206000 <_sramdisk>
ffffffe000201e70:	00f707b3          	add	a5,a4,a5
ffffffe000201e74:	f4f43823          	sd	a5,-176(s0)
            for(uint64_t i = 0; i < vma->vm_filesz; i++) cuapp[i] = celf[i];
ffffffe000201e78:	fe043423          	sd	zero,-24(s0)
ffffffe000201e7c:	0300006f          	j	ffffffe000201eac <do_page_fault+0x26c>
ffffffe000201e80:	f5043703          	ld	a4,-176(s0)
ffffffe000201e84:	fe843783          	ld	a5,-24(s0)
ffffffe000201e88:	00f70733          	add	a4,a4,a5
ffffffe000201e8c:	f5843683          	ld	a3,-168(s0)
ffffffe000201e90:	fe843783          	ld	a5,-24(s0)
ffffffe000201e94:	00f687b3          	add	a5,a3,a5
ffffffe000201e98:	00074703          	lbu	a4,0(a4) # 1000 <PGSIZE>
ffffffe000201e9c:	00e78023          	sb	a4,0(a5)
ffffffe000201ea0:	fe843783          	ld	a5,-24(s0)
ffffffe000201ea4:	00178793          	addi	a5,a5,1
ffffffe000201ea8:	fef43423          	sd	a5,-24(s0)
ffffffe000201eac:	fb043783          	ld	a5,-80(s0)
ffffffe000201eb0:	0387b783          	ld	a5,56(a5)
ffffffe000201eb4:	fe843703          	ld	a4,-24(s0)
ffffffe000201eb8:	fcf764e3          	bltu	a4,a5,ffffffe000201e80 <do_page_fault+0x240>
ffffffe000201ebc:	2340006f          	j	ffffffe0002020f0 <do_page_fault+0x4b0>
        }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start)){ // 从头开始
ffffffe000201ec0:	fb043783          	ld	a5,-80(s0)
ffffffe000201ec4:	0087b703          	ld	a4,8(a5)
ffffffe000201ec8:	fb843783          	ld	a5,-72(s0)
ffffffe000201ecc:	00f74733          	xor	a4,a4,a5
ffffffe000201ed0:	fffff7b7          	lui	a5,0xfffff
ffffffe000201ed4:	00f777b3          	and	a5,a4,a5
ffffffe000201ed8:	08079a63          	bnez	a5,ffffffe000201f6c <do_page_fault+0x32c>
            char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
ffffffe000201edc:	fb043783          	ld	a5,-80(s0)
ffffffe000201ee0:	0087b703          	ld	a4,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe000201ee4:	000017b7          	lui	a5,0x1
ffffffe000201ee8:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201eec:	00f777b3          	and	a5,a4,a5
ffffffe000201ef0:	f9043703          	ld	a4,-112(s0)
ffffffe000201ef4:	00f707b3          	add	a5,a4,a5
ffffffe000201ef8:	f6f43423          	sd	a5,-152(s0)
            char *celf = (char*)_sramdisk + vma->vm_pgoff;
ffffffe000201efc:	fb043783          	ld	a5,-80(s0)
ffffffe000201f00:	0307b703          	ld	a4,48(a5)
ffffffe000201f04:	00004797          	auipc	a5,0x4
ffffffe000201f08:	0fc78793          	addi	a5,a5,252 # ffffffe000206000 <_sramdisk>
ffffffe000201f0c:	00f707b3          	add	a5,a4,a5
ffffffe000201f10:	f6f43023          	sd	a5,-160(s0)
            int i;
            // LogBLUE("0x%llx", PGSIZE - vma->vm_start & 0x1ff);
            for(i = 0; i < (PGSIZE - vma->vm_start & 0xfff); i++) {
ffffffe000201f14:	fe042223          	sw	zero,-28(s0)
ffffffe000201f18:	0300006f          	j	ffffffe000201f48 <do_page_fault+0x308>
                cuapp[i] = celf[i];
ffffffe000201f1c:	fe442783          	lw	a5,-28(s0)
ffffffe000201f20:	f6043703          	ld	a4,-160(s0)
ffffffe000201f24:	00f70733          	add	a4,a4,a5
ffffffe000201f28:	fe442783          	lw	a5,-28(s0)
ffffffe000201f2c:	f6843683          	ld	a3,-152(s0)
ffffffe000201f30:	00f687b3          	add	a5,a3,a5
ffffffe000201f34:	00074703          	lbu	a4,0(a4)
ffffffe000201f38:	00e78023          	sb	a4,0(a5)
            for(i = 0; i < (PGSIZE - vma->vm_start & 0xfff); i++) {
ffffffe000201f3c:	fe442783          	lw	a5,-28(s0)
ffffffe000201f40:	0017879b          	addiw	a5,a5,1
ffffffe000201f44:	fef42223          	sw	a5,-28(s0)
ffffffe000201f48:	fe442703          	lw	a4,-28(s0)
ffffffe000201f4c:	fb043783          	ld	a5,-80(s0)
ffffffe000201f50:	0087b783          	ld	a5,8(a5)
ffffffe000201f54:	40f006b3          	neg	a3,a5
ffffffe000201f58:	000017b7          	lui	a5,0x1
ffffffe000201f5c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201f60:	00f6f7b3          	and	a5,a3,a5
ffffffe000201f64:	faf76ce3          	bltu	a4,a5,ffffffe000201f1c <do_page_fault+0x2dc>
ffffffe000201f68:	1880006f          	j	ffffffe0002020f0 <do_page_fault+0x4b0>
                //LogBLUE("[0x%llx] cuapp = 0x%llx, celf = 0x%llx", i, cuapp[i], celf[i]);
            }
            // LogBLUE("[0x%llx] cuapp = 0x%llx, celf = 0x%llx", i, cuapp[i], celf[i]);
        }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start + vma->vm_filesz - 1)){ // 最后一页
ffffffe000201f6c:	fb043783          	ld	a5,-80(s0)
ffffffe000201f70:	0087b703          	ld	a4,8(a5)
ffffffe000201f74:	fb043783          	ld	a5,-80(s0)
ffffffe000201f78:	0387b783          	ld	a5,56(a5)
ffffffe000201f7c:	00f707b3          	add	a5,a4,a5
ffffffe000201f80:	fff78713          	addi	a4,a5,-1
ffffffe000201f84:	fb843783          	ld	a5,-72(s0)
ffffffe000201f88:	00f74733          	xor	a4,a4,a5
ffffffe000201f8c:	fffff7b7          	lui	a5,0xfffff
ffffffe000201f90:	00f777b3          	and	a5,a4,a5
ffffffe000201f94:	0a079063          	bnez	a5,ffffffe000202034 <do_page_fault+0x3f4>
            char *cuapp = (char*)uapp;
ffffffe000201f98:	f9043783          	ld	a5,-112(s0)
ffffffe000201f9c:	f6f43c23          	sd	a5,-136(s0)
            char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(vma->vm_pgoff + va - vma->vm_start));
ffffffe000201fa0:	fb043783          	ld	a5,-80(s0)
ffffffe000201fa4:	0307b703          	ld	a4,48(a5) # fffffffffffff030 <VM_END+0xfffff030>
ffffffe000201fa8:	fb843783          	ld	a5,-72(s0)
ffffffe000201fac:	00f70733          	add	a4,a4,a5
ffffffe000201fb0:	fb043783          	ld	a5,-80(s0)
ffffffe000201fb4:	0087b783          	ld	a5,8(a5)
ffffffe000201fb8:	40f70733          	sub	a4,a4,a5
ffffffe000201fbc:	fffff7b7          	lui	a5,0xfffff
ffffffe000201fc0:	00f77733          	and	a4,a4,a5
ffffffe000201fc4:	00004797          	auipc	a5,0x4
ffffffe000201fc8:	03c78793          	addi	a5,a5,60 # ffffffe000206000 <_sramdisk>
ffffffe000201fcc:	00f707b3          	add	a5,a4,a5
ffffffe000201fd0:	f6f43823          	sd	a5,-144(s0)
            for(uint64_t i = 0; i <= ((vma->vm_start + vma->vm_filesz) & 0xfff); i++) cuapp[i] = celf[i];
ffffffe000201fd4:	fc043c23          	sd	zero,-40(s0)
ffffffe000201fd8:	0300006f          	j	ffffffe000202008 <do_page_fault+0x3c8>
ffffffe000201fdc:	f7043703          	ld	a4,-144(s0)
ffffffe000201fe0:	fd843783          	ld	a5,-40(s0)
ffffffe000201fe4:	00f70733          	add	a4,a4,a5
ffffffe000201fe8:	f7843683          	ld	a3,-136(s0)
ffffffe000201fec:	fd843783          	ld	a5,-40(s0)
ffffffe000201ff0:	00f687b3          	add	a5,a3,a5
ffffffe000201ff4:	00074703          	lbu	a4,0(a4)
ffffffe000201ff8:	00e78023          	sb	a4,0(a5)
ffffffe000201ffc:	fd843783          	ld	a5,-40(s0)
ffffffe000202000:	00178793          	addi	a5,a5,1
ffffffe000202004:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202008:	fb043783          	ld	a5,-80(s0)
ffffffe00020200c:	0087b703          	ld	a4,8(a5)
ffffffe000202010:	fb043783          	ld	a5,-80(s0)
ffffffe000202014:	0387b783          	ld	a5,56(a5)
ffffffe000202018:	00f70733          	add	a4,a4,a5
ffffffe00020201c:	000017b7          	lui	a5,0x1
ffffffe000202020:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202024:	00f777b3          	and	a5,a4,a5
ffffffe000202028:	fd843703          	ld	a4,-40(s0)
ffffffe00020202c:	fae7f8e3          	bgeu	a5,a4,ffffffe000201fdc <do_page_fault+0x39c>
ffffffe000202030:	0c00006f          	j	ffffffe0002020f0 <do_page_fault+0x4b0>
            // ! 这里要考虑漏掉一个字节的情况
        }else{ // 中间或mem-
            LogBLUE("vm_start = 0x%llx, vm_end = 0x%llx, vm_filesz = 0x%llx", vma->vm_start, vma->vm_end, vma->vm_filesz);
ffffffe000202034:	fb043783          	ld	a5,-80(s0)
ffffffe000202038:	0087b703          	ld	a4,8(a5)
ffffffe00020203c:	fb043783          	ld	a5,-80(s0)
ffffffe000202040:	0107b683          	ld	a3,16(a5)
ffffffe000202044:	fb043783          	ld	a5,-80(s0)
ffffffe000202048:	0387b783          	ld	a5,56(a5)
ffffffe00020204c:	00078813          	mv	a6,a5
ffffffe000202050:	00068793          	mv	a5,a3
ffffffe000202054:	00002697          	auipc	a3,0x2
ffffffe000202058:	5c468693          	addi	a3,a3,1476 # ffffffe000204618 <__func__.0>
ffffffe00020205c:	09300613          	li	a2,147
ffffffe000202060:	00002597          	auipc	a1,0x2
ffffffe000202064:	22058593          	addi	a1,a1,544 # ffffffe000204280 <__func__.0+0x10>
ffffffe000202068:	00002517          	auipc	a0,0x2
ffffffe00020206c:	55050513          	addi	a0,a0,1360 # ffffffe0002045b8 <__func__.0+0x348>
ffffffe000202070:	255010ef          	jal	ra,ffffffe000203ac4 <printk>
            char *cuapp = (char*)uapp;
ffffffe000202074:	f9043783          	ld	a5,-112(s0)
ffffffe000202078:	f8f43423          	sd	a5,-120(s0)
            char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(vma->vm_pgoff + va - vma->vm_start));
ffffffe00020207c:	fb043783          	ld	a5,-80(s0)
ffffffe000202080:	0307b703          	ld	a4,48(a5)
ffffffe000202084:	fb843783          	ld	a5,-72(s0)
ffffffe000202088:	00f70733          	add	a4,a4,a5
ffffffe00020208c:	fb043783          	ld	a5,-80(s0)
ffffffe000202090:	0087b783          	ld	a5,8(a5)
ffffffe000202094:	40f70733          	sub	a4,a4,a5
ffffffe000202098:	fffff7b7          	lui	a5,0xfffff
ffffffe00020209c:	00f77733          	and	a4,a4,a5
ffffffe0002020a0:	00004797          	auipc	a5,0x4
ffffffe0002020a4:	f6078793          	addi	a5,a5,-160 # ffffffe000206000 <_sramdisk>
ffffffe0002020a8:	00f707b3          	add	a5,a4,a5
ffffffe0002020ac:	f8f43023          	sd	a5,-128(s0)
            for(uint64_t i = 0; i < PGSIZE; i++) cuapp[i] = celf[i];
ffffffe0002020b0:	fc043823          	sd	zero,-48(s0)
ffffffe0002020b4:	0300006f          	j	ffffffe0002020e4 <do_page_fault+0x4a4>
ffffffe0002020b8:	f8043703          	ld	a4,-128(s0)
ffffffe0002020bc:	fd043783          	ld	a5,-48(s0)
ffffffe0002020c0:	00f70733          	add	a4,a4,a5
ffffffe0002020c4:	f8843683          	ld	a3,-120(s0)
ffffffe0002020c8:	fd043783          	ld	a5,-48(s0)
ffffffe0002020cc:	00f687b3          	add	a5,a3,a5
ffffffe0002020d0:	00074703          	lbu	a4,0(a4)
ffffffe0002020d4:	00e78023          	sb	a4,0(a5)
ffffffe0002020d8:	fd043783          	ld	a5,-48(s0)
ffffffe0002020dc:	00178793          	addi	a5,a5,1
ffffffe0002020e0:	fcf43823          	sd	a5,-48(s0)
ffffffe0002020e4:	fd043703          	ld	a4,-48(s0)
ffffffe0002020e8:	000017b7          	lui	a5,0x1
ffffffe0002020ec:	fcf766e3          	bltu	a4,a5,ffffffe0002020b8 <do_page_fault+0x478>
        }

        create_mapping(current->pgd, va, VA2PA((uint64_t)uapp), PGSIZE, perm);
ffffffe0002020f0:	00007797          	auipc	a5,0x7
ffffffe0002020f4:	f2078793          	addi	a5,a5,-224 # ffffffe000209010 <current>
ffffffe0002020f8:	0007b783          	ld	a5,0(a5)
ffffffe0002020fc:	0a87b503          	ld	a0,168(a5)
ffffffe000202100:	f9043703          	ld	a4,-112(s0)
ffffffe000202104:	04100793          	li	a5,65
ffffffe000202108:	01f79793          	slli	a5,a5,0x1f
ffffffe00020210c:	00f707b3          	add	a5,a4,a5
ffffffe000202110:	f9843703          	ld	a4,-104(s0)
ffffffe000202114:	000016b7          	lui	a3,0x1
ffffffe000202118:	00078613          	mv	a2,a5
ffffffe00020211c:	fb843583          	ld	a1,-72(s0)
ffffffe000202120:	029000ef          	jal	ra,ffffffe000202948 <create_mapping>
    }
}
ffffffe000202124:	0c813083          	ld	ra,200(sp)
ffffffe000202128:	0c013403          	ld	s0,192(sp)
ffffffe00020212c:	0d010113          	addi	sp,sp,208
ffffffe000202130:	00008067          	ret

ffffffe000202134 <do_fork>:

uint64_t do_fork(struct pt_regs *regs){
ffffffe000202134:	f3010113          	addi	sp,sp,-208
ffffffe000202138:	0c113423          	sd	ra,200(sp)
ffffffe00020213c:	0c813023          	sd	s0,192(sp)
ffffffe000202140:	0d010413          	addi	s0,sp,208
ffffffe000202144:	f2a43c23          	sd	a0,-200(s0)
    struct task_struct *ptask = (struct task_struct*)kalloc();
ffffffe000202148:	875fe0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe00020214c:	00050793          	mv	a5,a0
ffffffe000202150:	faf43c23          	sd	a5,-72(s0)
    // _sstatus |= (1 << 5);
    // _sstatus |= (1 << 18); 
    // ptask->thread.sstatus = _sstatus;

    // ptask->thread.sscratch = (uint64_t)USER_END;
    char *ccurrent_task = (char*)current;
ffffffe000202154:	00007797          	auipc	a5,0x7
ffffffe000202158:	ebc78793          	addi	a5,a5,-324 # ffffffe000209010 <current>
ffffffe00020215c:	0007b783          	ld	a5,0(a5)
ffffffe000202160:	faf43823          	sd	a5,-80(s0)
    char *cptask = (char*)ptask;
ffffffe000202164:	fb843783          	ld	a5,-72(s0)
ffffffe000202168:	faf43423          	sd	a5,-88(s0)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe00020216c:	fe043423          	sd	zero,-24(s0)
ffffffe000202170:	0300006f          	j	ffffffe0002021a0 <do_fork+0x6c>
        cptask[i] = ccurrent_task[i];
ffffffe000202174:	fb043703          	ld	a4,-80(s0)
ffffffe000202178:	fe843783          	ld	a5,-24(s0)
ffffffe00020217c:	00f70733          	add	a4,a4,a5
ffffffe000202180:	fa843683          	ld	a3,-88(s0)
ffffffe000202184:	fe843783          	ld	a5,-24(s0)
ffffffe000202188:	00f687b3          	add	a5,a3,a5
ffffffe00020218c:	00074703          	lbu	a4,0(a4)
ffffffe000202190:	00e78023          	sb	a4,0(a5)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202194:	fe843783          	ld	a5,-24(s0)
ffffffe000202198:	00178793          	addi	a5,a5,1
ffffffe00020219c:	fef43423          	sd	a5,-24(s0)
ffffffe0002021a0:	fe843703          	ld	a4,-24(s0)
ffffffe0002021a4:	000017b7          	lui	a5,0x1
ffffffe0002021a8:	fcf766e3          	bltu	a4,a5,ffffffe000202174 <do_fork+0x40>
    }
    ptask->pid = nr_tasks;
ffffffe0002021ac:	00003797          	auipc	a5,0x3
ffffffe0002021b0:	e6478793          	addi	a5,a5,-412 # ffffffe000205010 <nr_tasks>
ffffffe0002021b4:	0007b703          	ld	a4,0(a5)
ffffffe0002021b8:	fb843783          	ld	a5,-72(s0)
ffffffe0002021bc:	00e7bc23          	sd	a4,24(a5)
    ptask->thread.ra = __ret_from_fork;
ffffffe0002021c0:	ffffe717          	auipc	a4,0xffffe
ffffffe0002021c4:	f8870713          	addi	a4,a4,-120 # ffffffe000200148 <__ret_from_fork>
ffffffe0002021c8:	fb843783          	ld	a5,-72(s0)
ffffffe0002021cc:	02e7b023          	sd	a4,32(a5)
    ptask->thread.sp = (uint64_t)ptask + (uint64_t)regs - PGROUNDDOWN((uint64_t)regs); // ??
ffffffe0002021d0:	fb843703          	ld	a4,-72(s0)
ffffffe0002021d4:	f3843783          	ld	a5,-200(s0)
ffffffe0002021d8:	00f70733          	add	a4,a4,a5
ffffffe0002021dc:	f3843683          	ld	a3,-200(s0)
ffffffe0002021e0:	fffff7b7          	lui	a5,0xfffff
ffffffe0002021e4:	00f6f7b3          	and	a5,a3,a5
ffffffe0002021e8:	40f70733          	sub	a4,a4,a5
ffffffe0002021ec:	fb843783          	ld	a5,-72(s0)
ffffffe0002021f0:	02e7b423          	sd	a4,40(a5) # fffffffffffff028 <VM_END+0xfffff028>
    //ptask sscratch
    // LogBLUE("ptask->thread.sscratch = 0x%llx", ptask->thread.sscratch);
    // uint64_t _sscratch = csr_read(sscratch);
    // LogBLUE("sscratch = 0x%llx", _sscratch);
    ptask->thread.sscratch = csr_read(sscratch);
ffffffe0002021f4:	140027f3          	csrr	a5,sscratch
ffffffe0002021f8:	faf43023          	sd	a5,-96(s0)
ffffffe0002021fc:	fa043703          	ld	a4,-96(s0)
ffffffe000202200:	fb843783          	ld	a5,-72(s0)
ffffffe000202204:	0ae7b023          	sd	a4,160(a5)
    ptask->thread.sepc = csr_read(sepc) + 4;
ffffffe000202208:	141027f3          	csrr	a5,sepc
ffffffe00020220c:	f8f43c23          	sd	a5,-104(s0)
ffffffe000202210:	f9843783          	ld	a5,-104(s0)
ffffffe000202214:	00478713          	addi	a4,a5,4
ffffffe000202218:	fb843783          	ld	a5,-72(s0)
ffffffe00020221c:	08e7b823          	sd	a4,144(a5)
    
    struct pt_regs *ptregs = (struct pt_regs*)((uint64_t)regs - (uint64_t)current + (uint64_t)ptask);
ffffffe000202220:	f3843783          	ld	a5,-200(s0)
ffffffe000202224:	00007717          	auipc	a4,0x7
ffffffe000202228:	dec70713          	addi	a4,a4,-532 # ffffffe000209010 <current>
ffffffe00020222c:	00073703          	ld	a4,0(a4)
ffffffe000202230:	40e78733          	sub	a4,a5,a4
ffffffe000202234:	fb843783          	ld	a5,-72(s0)
ffffffe000202238:	00f707b3          	add	a5,a4,a5
ffffffe00020223c:	f8f43823          	sd	a5,-112(s0)
    ptregs->x[10] = 0;  
ffffffe000202240:	f9043783          	ld	a5,-112(s0)
ffffffe000202244:	0407b823          	sd	zero,80(a5)
    ptregs->x[2] = ptask->thread.sp;
ffffffe000202248:	fb843783          	ld	a5,-72(s0)
ffffffe00020224c:	0287b703          	ld	a4,40(a5)
ffffffe000202250:	f9043783          	ld	a5,-112(s0)
ffffffe000202254:	00e7b823          	sd	a4,16(a5)
    

    ptask->pgd = (uint64_t*)alloc_page();
ffffffe000202258:	ef0fe0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe00020225c:	00050793          	mv	a5,a0
ffffffe000202260:	00078713          	mv	a4,a5
ffffffe000202264:	fb843783          	ld	a5,-72(s0)
ffffffe000202268:	0ae7b423          	sd	a4,168(a5)
    char *cpgtbl = (char*)ptask->pgd;
ffffffe00020226c:	fb843783          	ld	a5,-72(s0)
ffffffe000202270:	0a87b783          	ld	a5,168(a5)
ffffffe000202274:	f8f43423          	sd	a5,-120(s0)
    char *cearly_pgtbl = (char*)swapper_pg_dir;
ffffffe000202278:	00009797          	auipc	a5,0x9
ffffffe00020227c:	d8878793          	addi	a5,a5,-632 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000202280:	f8f43023          	sd	a5,-128(s0)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202284:	fe043023          	sd	zero,-32(s0)
ffffffe000202288:	0300006f          	j	ffffffe0002022b8 <do_fork+0x184>
        cpgtbl[i] = cearly_pgtbl[i];
ffffffe00020228c:	f8043703          	ld	a4,-128(s0)
ffffffe000202290:	fe043783          	ld	a5,-32(s0)
ffffffe000202294:	00f70733          	add	a4,a4,a5
ffffffe000202298:	f8843683          	ld	a3,-120(s0)
ffffffe00020229c:	fe043783          	ld	a5,-32(s0)
ffffffe0002022a0:	00f687b3          	add	a5,a3,a5
ffffffe0002022a4:	00074703          	lbu	a4,0(a4)
ffffffe0002022a8:	00e78023          	sb	a4,0(a5)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002022ac:	fe043783          	ld	a5,-32(s0)
ffffffe0002022b0:	00178793          	addi	a5,a5,1
ffffffe0002022b4:	fef43023          	sd	a5,-32(s0)
ffffffe0002022b8:	fe043703          	ld	a4,-32(s0)
ffffffe0002022bc:	000017b7          	lui	a5,0x1
ffffffe0002022c0:	fcf766e3          	bltu	a4,a5,ffffffe00020228c <do_fork+0x158>
    }

    /*DEEP COPY*/
    ptask->mm.mmap = NULL;
ffffffe0002022c4:	fb843783          	ld	a5,-72(s0)
ffffffe0002022c8:	0a07b823          	sd	zero,176(a5) # 10b0 <PGSIZE+0xb0>
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
ffffffe0002022cc:	00007797          	auipc	a5,0x7
ffffffe0002022d0:	d4478793          	addi	a5,a5,-700 # ffffffe000209010 <current>
ffffffe0002022d4:	0007b783          	ld	a5,0(a5)
ffffffe0002022d8:	0b07b783          	ld	a5,176(a5)
ffffffe0002022dc:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002022e0:	17c0006f          	j	ffffffe00020245c <do_fork+0x328>
        struct vm_area_struct *new_vma = (struct vm_area_struct*)kalloc();
ffffffe0002022e4:	ed8fe0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe0002022e8:	00050793          	mv	a5,a0
ffffffe0002022ec:	f6f43c23          	sd	a5,-136(s0)
        char *cvma = (char*)vma;
ffffffe0002022f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002022f4:	f6f43823          	sd	a5,-144(s0)
        char *cnew_vma = (char*)new_vma;
ffffffe0002022f8:	f7843783          	ld	a5,-136(s0)
ffffffe0002022fc:	f6f43423          	sd	a5,-152(s0)
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
ffffffe000202300:	fc043823          	sd	zero,-48(s0)
ffffffe000202304:	0300006f          	j	ffffffe000202334 <do_fork+0x200>
            cnew_vma[i] = cvma[i];
ffffffe000202308:	f7043703          	ld	a4,-144(s0)
ffffffe00020230c:	fd043783          	ld	a5,-48(s0)
ffffffe000202310:	00f70733          	add	a4,a4,a5
ffffffe000202314:	f6843683          	ld	a3,-152(s0)
ffffffe000202318:	fd043783          	ld	a5,-48(s0)
ffffffe00020231c:	00f687b3          	add	a5,a3,a5
ffffffe000202320:	00074703          	lbu	a4,0(a4)
ffffffe000202324:	00e78023          	sb	a4,0(a5)
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
ffffffe000202328:	fd043783          	ld	a5,-48(s0)
ffffffe00020232c:	00178793          	addi	a5,a5,1
ffffffe000202330:	fcf43823          	sd	a5,-48(s0)
ffffffe000202334:	fd043703          	ld	a4,-48(s0)
ffffffe000202338:	03f00793          	li	a5,63
ffffffe00020233c:	fce7f6e3          	bgeu	a5,a4,ffffffe000202308 <do_fork+0x1d4>
        }
        // LogBLUE("new_vma->vm_start = 0x%llx, new_vma->vm_end = 0x%llx", new_vma->vm_start, new_vma->vm_end);
        // LogBLUE("vma->vm_start = 0x%llx, vma->vm_end = 0x%llx", vma->vm_start, vma->vm_end);
        add_mmap(&ptask->mm, new_vma);
ffffffe000202340:	fb843783          	ld	a5,-72(s0)
ffffffe000202344:	0b078793          	addi	a5,a5,176
ffffffe000202348:	f7843583          	ld	a1,-136(s0)
ffffffe00020234c:	00078513          	mv	a0,a5
ffffffe000202350:	278000ef          	jal	ra,ffffffe0002025c8 <add_mmap>

        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
ffffffe000202354:	fd843783          	ld	a5,-40(s0)
ffffffe000202358:	0087b703          	ld	a4,8(a5)
ffffffe00020235c:	fffff7b7          	lui	a5,0xfffff
ffffffe000202360:	00f777b3          	and	a5,a4,a5
ffffffe000202364:	fcf43423          	sd	a5,-56(s0)
ffffffe000202368:	0d00006f          	j	ffffffe000202438 <do_fork+0x304>
            uint64_t perm = check_load(current->pgd, addr);
ffffffe00020236c:	00007797          	auipc	a5,0x7
ffffffe000202370:	ca478793          	addi	a5,a5,-860 # ffffffe000209010 <current>
ffffffe000202374:	0007b783          	ld	a5,0(a5)
ffffffe000202378:	0a87b783          	ld	a5,168(a5)
ffffffe00020237c:	fc843583          	ld	a1,-56(s0)
ffffffe000202380:	00078513          	mv	a0,a5
ffffffe000202384:	13c000ef          	jal	ra,ffffffe0002024c0 <check_load>
ffffffe000202388:	00050793          	mv	a5,a0
ffffffe00020238c:	f6f43023          	sd	a5,-160(s0)
            if (!perm) continue;
ffffffe000202390:	f6043783          	ld	a5,-160(s0)
ffffffe000202394:	08078863          	beqz	a5,ffffffe000202424 <do_fork+0x2f0>

            uint64_t *new_page = (uint64_t*)alloc_page();
ffffffe000202398:	db0fe0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe00020239c:	00050793          	mv	a5,a0
ffffffe0002023a0:	f4f43c23          	sd	a5,-168(s0)
            char *cnew_page = (char*)new_page;
ffffffe0002023a4:	f5843783          	ld	a5,-168(s0)
ffffffe0002023a8:	f4f43823          	sd	a5,-176(s0)
            char *cpage = (char*)addr;
ffffffe0002023ac:	fc843783          	ld	a5,-56(s0)
ffffffe0002023b0:	f4f43423          	sd	a5,-184(s0)
            for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002023b4:	fc043023          	sd	zero,-64(s0)
ffffffe0002023b8:	0300006f          	j	ffffffe0002023e8 <do_fork+0x2b4>
                cnew_page[i] = cpage[i];
ffffffe0002023bc:	f4843703          	ld	a4,-184(s0)
ffffffe0002023c0:	fc043783          	ld	a5,-64(s0)
ffffffe0002023c4:	00f70733          	add	a4,a4,a5
ffffffe0002023c8:	f5043683          	ld	a3,-176(s0)
ffffffe0002023cc:	fc043783          	ld	a5,-64(s0)
ffffffe0002023d0:	00f687b3          	add	a5,a3,a5
ffffffe0002023d4:	00074703          	lbu	a4,0(a4)
ffffffe0002023d8:	00e78023          	sb	a4,0(a5)
            for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002023dc:	fc043783          	ld	a5,-64(s0)
ffffffe0002023e0:	00178793          	addi	a5,a5,1
ffffffe0002023e4:	fcf43023          	sd	a5,-64(s0)
ffffffe0002023e8:	fc043703          	ld	a4,-64(s0)
ffffffe0002023ec:	000017b7          	lui	a5,0x1
ffffffe0002023f0:	fcf766e3          	bltu	a4,a5,ffffffe0002023bc <do_fork+0x288>
            }
            create_mapping(ptask->pgd, addr, VA2PA((uint64_t)new_page), PGSIZE, perm);
ffffffe0002023f4:	fb843783          	ld	a5,-72(s0)
ffffffe0002023f8:	0a87b503          	ld	a0,168(a5) # 10a8 <PGSIZE+0xa8>
ffffffe0002023fc:	f5843703          	ld	a4,-168(s0)
ffffffe000202400:	04100793          	li	a5,65
ffffffe000202404:	01f79793          	slli	a5,a5,0x1f
ffffffe000202408:	00f707b3          	add	a5,a4,a5
ffffffe00020240c:	f6043703          	ld	a4,-160(s0)
ffffffe000202410:	000016b7          	lui	a3,0x1
ffffffe000202414:	00078613          	mv	a2,a5
ffffffe000202418:	fc843583          	ld	a1,-56(s0)
ffffffe00020241c:	52c000ef          	jal	ra,ffffffe000202948 <create_mapping>
ffffffe000202420:	0080006f          	j	ffffffe000202428 <do_fork+0x2f4>
            if (!perm) continue;
ffffffe000202424:	00000013          	nop
        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
ffffffe000202428:	fc843703          	ld	a4,-56(s0)
ffffffe00020242c:	000017b7          	lui	a5,0x1
ffffffe000202430:	00f707b3          	add	a5,a4,a5
ffffffe000202434:	fcf43423          	sd	a5,-56(s0)
ffffffe000202438:	fd843783          	ld	a5,-40(s0)
ffffffe00020243c:	0107b703          	ld	a4,16(a5) # 1010 <PGSIZE+0x10>
ffffffe000202440:	fffff7b7          	lui	a5,0xfffff
ffffffe000202444:	00f777b3          	and	a5,a4,a5
ffffffe000202448:	fc843703          	ld	a4,-56(s0)
ffffffe00020244c:	f2e7f0e3          	bgeu	a5,a4,ffffffe00020236c <do_fork+0x238>
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
ffffffe000202450:	fd843783          	ld	a5,-40(s0)
ffffffe000202454:	0187b783          	ld	a5,24(a5) # fffffffffffff018 <VM_END+0xfffff018>
ffffffe000202458:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020245c:	fd843783          	ld	a5,-40(s0)
ffffffe000202460:	e80792e3          	bnez	a5,ffffffe0002022e4 <do_fork+0x1b0>
        }
    }


    // load_program(ptask);
    task[nr_tasks] = ptask;
ffffffe000202464:	00003797          	auipc	a5,0x3
ffffffe000202468:	bac78793          	addi	a5,a5,-1108 # ffffffe000205010 <nr_tasks>
ffffffe00020246c:	0007b783          	ld	a5,0(a5)
ffffffe000202470:	00007717          	auipc	a4,0x7
ffffffe000202474:	bc070713          	addi	a4,a4,-1088 # ffffffe000209030 <task>
ffffffe000202478:	00379793          	slli	a5,a5,0x3
ffffffe00020247c:	00f707b3          	add	a5,a4,a5
ffffffe000202480:	fb843703          	ld	a4,-72(s0)
ffffffe000202484:	00e7b023          	sd	a4,0(a5)
    nr_tasks++;
ffffffe000202488:	00003797          	auipc	a5,0x3
ffffffe00020248c:	b8878793          	addi	a5,a5,-1144 # ffffffe000205010 <nr_tasks>
ffffffe000202490:	0007b783          	ld	a5,0(a5)
ffffffe000202494:	00178713          	addi	a4,a5,1
ffffffe000202498:	00003797          	auipc	a5,0x3
ffffffe00020249c:	b7878793          	addi	a5,a5,-1160 # ffffffe000205010 <nr_tasks>
ffffffe0002024a0:	00e7b023          	sd	a4,0(a5)
    return ptask->pid;
ffffffe0002024a4:	fb843783          	ld	a5,-72(s0)
ffffffe0002024a8:	0187b783          	ld	a5,24(a5)
}
ffffffe0002024ac:	00078513          	mv	a0,a5
ffffffe0002024b0:	0c813083          	ld	ra,200(sp)
ffffffe0002024b4:	0c013403          	ld	s0,192(sp)
ffffffe0002024b8:	0d010113          	addi	sp,sp,208
ffffffe0002024bc:	00008067          	ret

ffffffe0002024c0 <check_load>:

int check_load(uint64_t *pgtbl, uint64_t addr){
ffffffe0002024c0:	fb010113          	addi	sp,sp,-80
ffffffe0002024c4:	04813423          	sd	s0,72(sp)
ffffffe0002024c8:	05010413          	addi	s0,sp,80
ffffffe0002024cc:	faa43c23          	sd	a0,-72(s0)
ffffffe0002024d0:	fab43823          	sd	a1,-80(s0)
    uint64_t pgd_entry = *(pgtbl + ((addr >> 30) & 0x1ff));
ffffffe0002024d4:	fb043783          	ld	a5,-80(s0)
ffffffe0002024d8:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002024dc:	1ff7f793          	andi	a5,a5,511
ffffffe0002024e0:	00379793          	slli	a5,a5,0x3
ffffffe0002024e4:	fb843703          	ld	a4,-72(s0)
ffffffe0002024e8:	00f707b3          	add	a5,a4,a5
ffffffe0002024ec:	0007b783          	ld	a5,0(a5)
ffffffe0002024f0:	fef43423          	sd	a5,-24(s0)
    if (!(pgd_entry & PTE_V)) return 0;
ffffffe0002024f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002024f8:	0017f793          	andi	a5,a5,1
ffffffe0002024fc:	00079663          	bnez	a5,ffffffe000202508 <check_load+0x48>
ffffffe000202500:	00000793          	li	a5,0
ffffffe000202504:	0b40006f          	j	ffffffe0002025b8 <check_load+0xf8>
    uint64_t *pmd = (uint64_t*)(PA2VA((uint64_t)((pgd_entry >> 10) << 12)));
ffffffe000202508:	fe843783          	ld	a5,-24(s0)
ffffffe00020250c:	00a7d793          	srli	a5,a5,0xa
ffffffe000202510:	00c79713          	slli	a4,a5,0xc
ffffffe000202514:	fbf00793          	li	a5,-65
ffffffe000202518:	01f79793          	slli	a5,a5,0x1f
ffffffe00020251c:	00f707b3          	add	a5,a4,a5
ffffffe000202520:	fef43023          	sd	a5,-32(s0)
    uint64_t pmd_entry = *(pmd + ((addr >> 21) & 0x1ff));
ffffffe000202524:	fb043783          	ld	a5,-80(s0)
ffffffe000202528:	0157d793          	srli	a5,a5,0x15
ffffffe00020252c:	1ff7f793          	andi	a5,a5,511
ffffffe000202530:	00379793          	slli	a5,a5,0x3
ffffffe000202534:	fe043703          	ld	a4,-32(s0)
ffffffe000202538:	00f707b3          	add	a5,a4,a5
ffffffe00020253c:	0007b783          	ld	a5,0(a5)
ffffffe000202540:	fcf43c23          	sd	a5,-40(s0)
    if (!(pmd_entry & PTE_V)) return 0;
ffffffe000202544:	fd843783          	ld	a5,-40(s0)
ffffffe000202548:	0017f793          	andi	a5,a5,1
ffffffe00020254c:	00079663          	bnez	a5,ffffffe000202558 <check_load+0x98>
ffffffe000202550:	00000793          	li	a5,0
ffffffe000202554:	0640006f          	j	ffffffe0002025b8 <check_load+0xf8>
    uint64_t *pte = (uint64_t*)(PA2VA((uint64_t)((pmd_entry >> 10) << 12)));
ffffffe000202558:	fd843783          	ld	a5,-40(s0)
ffffffe00020255c:	00a7d793          	srli	a5,a5,0xa
ffffffe000202560:	00c79713          	slli	a4,a5,0xc
ffffffe000202564:	fbf00793          	li	a5,-65
ffffffe000202568:	01f79793          	slli	a5,a5,0x1f
ffffffe00020256c:	00f707b3          	add	a5,a4,a5
ffffffe000202570:	fcf43823          	sd	a5,-48(s0)
    uint64_t pte_entry = *(pte + ((addr >> 12) & 0x1ff));
ffffffe000202574:	fb043783          	ld	a5,-80(s0)
ffffffe000202578:	00c7d793          	srli	a5,a5,0xc
ffffffe00020257c:	1ff7f793          	andi	a5,a5,511
ffffffe000202580:	00379793          	slli	a5,a5,0x3
ffffffe000202584:	fd043703          	ld	a4,-48(s0)
ffffffe000202588:	00f707b3          	add	a5,a4,a5
ffffffe00020258c:	0007b783          	ld	a5,0(a5)
ffffffe000202590:	fcf43423          	sd	a5,-56(s0)
    if (!(pte_entry & PTE_V)) return 0;
ffffffe000202594:	fc843783          	ld	a5,-56(s0)
ffffffe000202598:	0017f793          	andi	a5,a5,1
ffffffe00020259c:	00079663          	bnez	a5,ffffffe0002025a8 <check_load+0xe8>
ffffffe0002025a0:	00000793          	li	a5,0
ffffffe0002025a4:	0140006f          	j	ffffffe0002025b8 <check_load+0xf8>
    // return (pte_entry & PTE_R) | (pte_entry & PTE_X) | (pte_entry & PTE_W) | PTE_V | PTE_U; 
    return pte_entry & 0XFF;
ffffffe0002025a8:	fc843783          	ld	a5,-56(s0)
ffffffe0002025ac:	0007879b          	sext.w	a5,a5
ffffffe0002025b0:	0ff7f793          	zext.b	a5,a5
ffffffe0002025b4:	0007879b          	sext.w	a5,a5
}
ffffffe0002025b8:	00078513          	mv	a0,a5
ffffffe0002025bc:	04813403          	ld	s0,72(sp)
ffffffe0002025c0:	05010113          	addi	sp,sp,80
ffffffe0002025c4:	00008067          	ret

ffffffe0002025c8 <add_mmap>:

void add_mmap(struct mm_struct *mm, struct vm_area_struct *new_vma){
ffffffe0002025c8:	fd010113          	addi	sp,sp,-48
ffffffe0002025cc:	02813423          	sd	s0,40(sp)
ffffffe0002025d0:	03010413          	addi	s0,sp,48
ffffffe0002025d4:	fca43c23          	sd	a0,-40(s0)
ffffffe0002025d8:	fcb43823          	sd	a1,-48(s0)
    new_vma->vm_mm = mm;
ffffffe0002025dc:	fd043783          	ld	a5,-48(s0)
ffffffe0002025e0:	fd843703          	ld	a4,-40(s0)
ffffffe0002025e4:	00e7b023          	sd	a4,0(a5)
    struct vm_area_struct *prev =  mm->mmap;
ffffffe0002025e8:	fd843783          	ld	a5,-40(s0)
ffffffe0002025ec:	0007b783          	ld	a5,0(a5)
ffffffe0002025f0:	fef43423          	sd	a5,-24(s0)
    if(!prev){
ffffffe0002025f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002025f8:	02079263          	bnez	a5,ffffffe00020261c <add_mmap+0x54>
        mm->mmap = new_vma;
ffffffe0002025fc:	fd843783          	ld	a5,-40(s0)
ffffffe000202600:	fd043703          	ld	a4,-48(s0)
ffffffe000202604:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = NULL;
ffffffe000202608:	fd043783          	ld	a5,-48(s0)
ffffffe00020260c:	0007bc23          	sd	zero,24(a5)
        new_vma->vm_prev = NULL;
ffffffe000202610:	fd043783          	ld	a5,-48(s0)
ffffffe000202614:	0207b023          	sd	zero,32(a5)
        new_vma->vm_next = prev;
        new_vma->vm_prev = NULL;
        prev->vm_prev = new_vma;
    }
    // return mm->mmap;
}
ffffffe000202618:	0300006f          	j	ffffffe000202648 <add_mmap+0x80>
        mm->mmap = new_vma;
ffffffe00020261c:	fd843783          	ld	a5,-40(s0)
ffffffe000202620:	fd043703          	ld	a4,-48(s0)
ffffffe000202624:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = prev;
ffffffe000202628:	fd043783          	ld	a5,-48(s0)
ffffffe00020262c:	fe843703          	ld	a4,-24(s0)
ffffffe000202630:	00e7bc23          	sd	a4,24(a5)
        new_vma->vm_prev = NULL;
ffffffe000202634:	fd043783          	ld	a5,-48(s0)
ffffffe000202638:	0207b023          	sd	zero,32(a5)
        prev->vm_prev = new_vma;
ffffffe00020263c:	fe843783          	ld	a5,-24(s0)
ffffffe000202640:	fd043703          	ld	a4,-48(s0)
ffffffe000202644:	02e7b023          	sd	a4,32(a5)
}
ffffffe000202648:	00000013          	nop
ffffffe00020264c:	02813403          	ld	s0,40(sp)
ffffffe000202650:	03010113          	addi	sp,sp,48
ffffffe000202654:	00008067          	ret

ffffffe000202658 <setup_vm>:
#include "printk.h"

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe000202658:	fd010113          	addi	sp,sp,-48
ffffffe00020265c:	02113423          	sd	ra,40(sp)
ffffffe000202660:	02813023          	sd	s0,32(sp)
ffffffe000202664:	03010413          	addi	s0,sp,48
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
    memset(early_pgtbl, 0x0, PGSIZE);
ffffffe000202668:	00001637          	lui	a2,0x1
ffffffe00020266c:	00000593          	li	a1,0
ffffffe000202670:	00008517          	auipc	a0,0x8
ffffffe000202674:	99050513          	addi	a0,a0,-1648 # ffffffe00020a000 <early_pgtbl>
ffffffe000202678:	56c010ef          	jal	ra,ffffffe000203be4 <memset>
    uint64_t va = VM_START;
ffffffe00020267c:	fff00793          	li	a5,-1
ffffffe000202680:	02579793          	slli	a5,a5,0x25
ffffffe000202684:	fef43423          	sd	a5,-24(s0)
    uint64_t pa = PHY_START;
ffffffe000202688:	00100793          	li	a5,1
ffffffe00020268c:	01f79793          	slli	a5,a5,0x1f
ffffffe000202690:	fef43023          	sd	a5,-32(s0)
    LogGREEN("early_pgtbl: 0x%llx\n", early_pgtbl);
ffffffe000202694:	00008717          	auipc	a4,0x8
ffffffe000202698:	96c70713          	addi	a4,a4,-1684 # ffffffe00020a000 <early_pgtbl>
ffffffe00020269c:	00002697          	auipc	a3,0x2
ffffffe0002026a0:	0c468693          	addi	a3,a3,196 # ffffffe000204760 <__func__.2>
ffffffe0002026a4:	01300613          	li	a2,19
ffffffe0002026a8:	00002597          	auipc	a1,0x2
ffffffe0002026ac:	f8058593          	addi	a1,a1,-128 # ffffffe000204628 <__func__.0+0x10>
ffffffe0002026b0:	00002517          	auipc	a0,0x2
ffffffe0002026b4:	f8050513          	addi	a0,a0,-128 # ffffffe000204630 <__func__.0+0x18>
ffffffe0002026b8:	40c010ef          	jal	ra,ffffffe000203ac4 <printk>
    uint64_t index = (pa >> 30) & 0x1ff;
ffffffe0002026bc:	fe043783          	ld	a5,-32(s0)
ffffffe0002026c0:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002026c4:	1ff7f793          	andi	a5,a5,511
ffffffe0002026c8:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe0002026cc:	fd843583          	ld	a1,-40(s0)
ffffffe0002026d0:	00002517          	auipc	a0,0x2
ffffffe0002026d4:	f9050513          	addi	a0,a0,-112 # ffffffe000204660 <__func__.0+0x48>
ffffffe0002026d8:	3ec010ef          	jal	ra,ffffffe000203ac4 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe0002026dc:	fe043783          	ld	a5,-32(s0)
ffffffe0002026e0:	0027d713          	srli	a4,a5,0x2
ffffffe0002026e4:	040007b7          	lui	a5,0x4000
ffffffe0002026e8:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe0002026ec:	01c79793          	slli	a5,a5,0x1c
ffffffe0002026f0:	00f777b3          	and	a5,a4,a5
ffffffe0002026f4:	00f7e713          	ori	a4,a5,15
ffffffe0002026f8:	00008697          	auipc	a3,0x8
ffffffe0002026fc:	90868693          	addi	a3,a3,-1784 # ffffffe00020a000 <early_pgtbl>
ffffffe000202700:	fd843783          	ld	a5,-40(s0)
ffffffe000202704:	00379793          	slli	a5,a5,0x3
ffffffe000202708:	00f687b3          	add	a5,a3,a5
ffffffe00020270c:	00e7b023          	sd	a4,0(a5)

    index = (va >> 30) & 0x1ff;
ffffffe000202710:	fe843783          	ld	a5,-24(s0)
ffffffe000202714:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202718:	1ff7f793          	andi	a5,a5,511
ffffffe00020271c:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe000202720:	fd843583          	ld	a1,-40(s0)
ffffffe000202724:	00002517          	auipc	a0,0x2
ffffffe000202728:	f3c50513          	addi	a0,a0,-196 # ffffffe000204660 <__func__.0+0x48>
ffffffe00020272c:	398010ef          	jal	ra,ffffffe000203ac4 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe000202730:	fe043783          	ld	a5,-32(s0)
ffffffe000202734:	0027d713          	srli	a4,a5,0x2
ffffffe000202738:	040007b7          	lui	a5,0x4000
ffffffe00020273c:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000202740:	01c79793          	slli	a5,a5,0x1c
ffffffe000202744:	00f777b3          	and	a5,a4,a5
ffffffe000202748:	00f7e713          	ori	a4,a5,15
ffffffe00020274c:	00008697          	auipc	a3,0x8
ffffffe000202750:	8b468693          	addi	a3,a3,-1868 # ffffffe00020a000 <early_pgtbl>
ffffffe000202754:	fd843783          	ld	a5,-40(s0)
ffffffe000202758:	00379793          	slli	a5,a5,0x3
ffffffe00020275c:	00f687b3          	add	a5,a3,a5
ffffffe000202760:	00e7b023          	sd	a4,0(a5)

    printk("setup_vm done...\n");
ffffffe000202764:	00002517          	auipc	a0,0x2
ffffffe000202768:	f0c50513          	addi	a0,a0,-244 # ffffffe000204670 <__func__.0+0x58>
ffffffe00020276c:	358010ef          	jal	ra,ffffffe000203ac4 <printk>
}
ffffffe000202770:	00000013          	nop
ffffffe000202774:	02813083          	ld	ra,40(sp)
ffffffe000202778:	02013403          	ld	s0,32(sp)
ffffffe00020277c:	03010113          	addi	sp,sp,48
ffffffe000202780:	00008067          	ret

ffffffe000202784 <setup_vm_final>:
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

void setup_vm_final() {
ffffffe000202784:	fc010113          	addi	sp,sp,-64
ffffffe000202788:	02113c23          	sd	ra,56(sp)
ffffffe00020278c:	02813823          	sd	s0,48(sp)
ffffffe000202790:	04010413          	addi	s0,sp,64
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000202794:	00001637          	lui	a2,0x1
ffffffe000202798:	00000593          	li	a1,0
ffffffe00020279c:	00009517          	auipc	a0,0x9
ffffffe0002027a0:	86450513          	addi	a0,a0,-1948 # ffffffe00020b000 <swapper_pg_dir>
ffffffe0002027a4:	440010ef          	jal	ra,ffffffe000203be4 <memset>
    LogYELLOW("_stext: %p, _etext: %p, _srodata: %p, _erodata: %p, _sdata: %p, _edata: %p, _sbss: %p, _ebss: %p\n", _stext, _etext, _srodata, _erodata, _sdata, _edata, _sbss, _ebss);
ffffffe0002027a8:	0000a797          	auipc	a5,0xa
ffffffe0002027ac:	85878793          	addi	a5,a5,-1960 # ffffffe00020c000 <_ebss>
ffffffe0002027b0:	00f13c23          	sd	a5,24(sp)
ffffffe0002027b4:	00006797          	auipc	a5,0x6
ffffffe0002027b8:	84c78793          	addi	a5,a5,-1972 # ffffffe000208000 <_sbss>
ffffffe0002027bc:	00f13823          	sd	a5,16(sp)
ffffffe0002027c0:	00003797          	auipc	a5,0x3
ffffffe0002027c4:	85878793          	addi	a5,a5,-1960 # ffffffe000205018 <_edata>
ffffffe0002027c8:	00f13423          	sd	a5,8(sp)
ffffffe0002027cc:	00003797          	auipc	a5,0x3
ffffffe0002027d0:	83478793          	addi	a5,a5,-1996 # ffffffe000205000 <TIMECLOCK>
ffffffe0002027d4:	00f13023          	sd	a5,0(sp)
ffffffe0002027d8:	00002897          	auipc	a7,0x2
ffffffe0002027dc:	04888893          	addi	a7,a7,72 # ffffffe000204820 <_erodata>
ffffffe0002027e0:	00002817          	auipc	a6,0x2
ffffffe0002027e4:	82080813          	addi	a6,a6,-2016 # ffffffe000204000 <__func__.1>
ffffffe0002027e8:	00001797          	auipc	a5,0x1
ffffffe0002027ec:	46c78793          	addi	a5,a5,1132 # ffffffe000203c54 <_etext>
ffffffe0002027f0:	ffffe717          	auipc	a4,0xffffe
ffffffe0002027f4:	81070713          	addi	a4,a4,-2032 # ffffffe000200000 <_skernel>
ffffffe0002027f8:	00002697          	auipc	a3,0x2
ffffffe0002027fc:	f7868693          	addi	a3,a3,-136 # ffffffe000204770 <__func__.1>
ffffffe000202800:	02700613          	li	a2,39
ffffffe000202804:	00002597          	auipc	a1,0x2
ffffffe000202808:	e2458593          	addi	a1,a1,-476 # ffffffe000204628 <__func__.0+0x10>
ffffffe00020280c:	00002517          	auipc	a0,0x2
ffffffe000202810:	e7c50513          	addi	a0,a0,-388 # ffffffe000204688 <__func__.0+0x70>
ffffffe000202814:	2b0010ef          	jal	ra,ffffffe000203ac4 <printk>

    // No OpenSBI mapping required
    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, _stext, _stext - PA2VA_OFFSET, _srodata - _stext, PTE_X | PTE_R | PTE_V);;
ffffffe000202818:	ffffd597          	auipc	a1,0xffffd
ffffffe00020281c:	7e858593          	addi	a1,a1,2024 # ffffffe000200000 <_skernel>
ffffffe000202820:	ffffd717          	auipc	a4,0xffffd
ffffffe000202824:	7e070713          	addi	a4,a4,2016 # ffffffe000200000 <_skernel>
ffffffe000202828:	04100793          	li	a5,65
ffffffe00020282c:	01f79793          	slli	a5,a5,0x1f
ffffffe000202830:	00f707b3          	add	a5,a4,a5
ffffffe000202834:	00078613          	mv	a2,a5
ffffffe000202838:	00001717          	auipc	a4,0x1
ffffffe00020283c:	7c870713          	addi	a4,a4,1992 # ffffffe000204000 <__func__.1>
ffffffe000202840:	ffffd797          	auipc	a5,0xffffd
ffffffe000202844:	7c078793          	addi	a5,a5,1984 # ffffffe000200000 <_skernel>
ffffffe000202848:	40f707b3          	sub	a5,a4,a5
ffffffe00020284c:	00b00713          	li	a4,11
ffffffe000202850:	00078693          	mv	a3,a5
ffffffe000202854:	00008517          	auipc	a0,0x8
ffffffe000202858:	7ac50513          	addi	a0,a0,1964 # ffffffe00020b000 <swapper_pg_dir>
ffffffe00020285c:	0ec000ef          	jal	ra,ffffffe000202948 <create_mapping>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, _srodata, _srodata - PA2VA_OFFSET, _sdata - _srodata, PTE_R | PTE_V);
ffffffe000202860:	00001597          	auipc	a1,0x1
ffffffe000202864:	7a058593          	addi	a1,a1,1952 # ffffffe000204000 <__func__.1>
ffffffe000202868:	00001717          	auipc	a4,0x1
ffffffe00020286c:	79870713          	addi	a4,a4,1944 # ffffffe000204000 <__func__.1>
ffffffe000202870:	04100793          	li	a5,65
ffffffe000202874:	01f79793          	slli	a5,a5,0x1f
ffffffe000202878:	00f707b3          	add	a5,a4,a5
ffffffe00020287c:	00078613          	mv	a2,a5
ffffffe000202880:	00002717          	auipc	a4,0x2
ffffffe000202884:	78070713          	addi	a4,a4,1920 # ffffffe000205000 <TIMECLOCK>
ffffffe000202888:	00001797          	auipc	a5,0x1
ffffffe00020288c:	77878793          	addi	a5,a5,1912 # ffffffe000204000 <__func__.1>
ffffffe000202890:	40f707b3          	sub	a5,a4,a5
ffffffe000202894:	00300713          	li	a4,3
ffffffe000202898:	00078693          	mv	a3,a5
ffffffe00020289c:	00008517          	auipc	a0,0x8
ffffffe0002028a0:	76450513          	addi	a0,a0,1892 # ffffffe00020b000 <swapper_pg_dir>
ffffffe0002028a4:	0a4000ef          	jal	ra,ffffffe000202948 <create_mapping>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir, _sdata, _sdata - PA2VA_OFFSET, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V);
ffffffe0002028a8:	00002597          	auipc	a1,0x2
ffffffe0002028ac:	75858593          	addi	a1,a1,1880 # ffffffe000205000 <TIMECLOCK>
ffffffe0002028b0:	00002717          	auipc	a4,0x2
ffffffe0002028b4:	75070713          	addi	a4,a4,1872 # ffffffe000205000 <TIMECLOCK>
ffffffe0002028b8:	04100793          	li	a5,65
ffffffe0002028bc:	01f79793          	slli	a5,a5,0x1f
ffffffe0002028c0:	00f707b3          	add	a5,a4,a5
ffffffe0002028c4:	00078613          	mv	a2,a5
ffffffe0002028c8:	00002717          	auipc	a4,0x2
ffffffe0002028cc:	73870713          	addi	a4,a4,1848 # ffffffe000205000 <TIMECLOCK>
ffffffe0002028d0:	ffffd797          	auipc	a5,0xffffd
ffffffe0002028d4:	73078793          	addi	a5,a5,1840 # ffffffe000200000 <_skernel>
ffffffe0002028d8:	40f707b3          	sub	a5,a4,a5
ffffffe0002028dc:	08000737          	lui	a4,0x8000
ffffffe0002028e0:	40f707b3          	sub	a5,a4,a5
ffffffe0002028e4:	00700713          	li	a4,7
ffffffe0002028e8:	00078693          	mv	a3,a5
ffffffe0002028ec:	00008517          	auipc	a0,0x8
ffffffe0002028f0:	71450513          	addi	a0,a0,1812 # ffffffe00020b000 <swapper_pg_dir>
ffffffe0002028f4:	054000ef          	jal	ra,ffffffe000202948 <create_mapping>

    uint64_t _satp = ((((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12) | (uint64_t)0x8 << 60);
ffffffe0002028f8:	00008717          	auipc	a4,0x8
ffffffe0002028fc:	70870713          	addi	a4,a4,1800 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000202900:	04100793          	li	a5,65
ffffffe000202904:	01f79793          	slli	a5,a5,0x1f
ffffffe000202908:	00f707b3          	add	a5,a4,a5
ffffffe00020290c:	00c7d713          	srli	a4,a5,0xc
ffffffe000202910:	fff00793          	li	a5,-1
ffffffe000202914:	03f79793          	slli	a5,a5,0x3f
ffffffe000202918:	00f767b3          	or	a5,a4,a5
ffffffe00020291c:	fef43423          	sd	a5,-24(s0)

    // set satp with swapper_pg_dir
    csr_write(satp, _satp);
ffffffe000202920:	fe843783          	ld	a5,-24(s0)
ffffffe000202924:	fef43023          	sd	a5,-32(s0)
ffffffe000202928:	fe043783          	ld	a5,-32(s0)
ffffffe00020292c:	18079073          	csrw	satp,a5
    // *_erodata = 0x0;
    // LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);

    // YOUR CODE HERE
    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000202930:	12000073          	sfence.vma
    return;
ffffffe000202934:	00000013          	nop
}
ffffffe000202938:	03813083          	ld	ra,56(sp)
ffffffe00020293c:	03013403          	ld	s0,48(sp)
ffffffe000202940:	04010113          	addi	sp,sp,64
ffffffe000202944:	00008067          	ret

ffffffe000202948 <create_mapping>:


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000202948:	f7010113          	addi	sp,sp,-144
ffffffe00020294c:	08113423          	sd	ra,136(sp)
ffffffe000202950:	08813023          	sd	s0,128(sp)
ffffffe000202954:	09010413          	addi	s0,sp,144
ffffffe000202958:	faa43423          	sd	a0,-88(s0)
ffffffe00020295c:	fab43023          	sd	a1,-96(s0)
ffffffe000202960:	f8c43c23          	sd	a2,-104(s0)
ffffffe000202964:	f8d43823          	sd	a3,-112(s0)
ffffffe000202968:	f8e43423          	sd	a4,-120(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    // printk("Come into the create_mapping\n");
    LogBLUE("root: 0x%llx, [0x%llx, 0x%llx) -> [0x%llx, 0x%llx), perm: 0x%llx", pgtbl, pa, pa + sz, va, va + sz, perm);
ffffffe00020296c:	f9843703          	ld	a4,-104(s0)
ffffffe000202970:	f9043783          	ld	a5,-112(s0)
ffffffe000202974:	00f706b3          	add	a3,a4,a5
ffffffe000202978:	fa043703          	ld	a4,-96(s0)
ffffffe00020297c:	f9043783          	ld	a5,-112(s0)
ffffffe000202980:	00f707b3          	add	a5,a4,a5
ffffffe000202984:	f8843703          	ld	a4,-120(s0)
ffffffe000202988:	00e13423          	sd	a4,8(sp)
ffffffe00020298c:	00f13023          	sd	a5,0(sp)
ffffffe000202990:	fa043883          	ld	a7,-96(s0)
ffffffe000202994:	00068813          	mv	a6,a3
ffffffe000202998:	f9843783          	ld	a5,-104(s0)
ffffffe00020299c:	fa843703          	ld	a4,-88(s0)
ffffffe0002029a0:	00002697          	auipc	a3,0x2
ffffffe0002029a4:	de068693          	addi	a3,a3,-544 # ffffffe000204780 <__func__.0>
ffffffe0002029a8:	05300613          	li	a2,83
ffffffe0002029ac:	00002597          	auipc	a1,0x2
ffffffe0002029b0:	c7c58593          	addi	a1,a1,-900 # ffffffe000204628 <__func__.0+0x10>
ffffffe0002029b4:	00002517          	auipc	a0,0x2
ffffffe0002029b8:	d5450513          	addi	a0,a0,-684 # ffffffe000204708 <__func__.0+0xf0>
ffffffe0002029bc:	108010ef          	jal	ra,ffffffe000203ac4 <printk>
    uint64_t vlimit = va + sz;
ffffffe0002029c0:	fa043703          	ld	a4,-96(s0)
ffffffe0002029c4:	f9043783          	ld	a5,-112(s0)
ffffffe0002029c8:	00f707b3          	add	a5,a4,a5
ffffffe0002029cc:	fcf43c23          	sd	a5,-40(s0)
    uint64_t *pgd, *pmd, *pte;
    pgd = pgtbl;
ffffffe0002029d0:	fa843783          	ld	a5,-88(s0)
ffffffe0002029d4:	fcf43823          	sd	a5,-48(s0)

    while(va < vlimit){
ffffffe0002029d8:	19c0006f          	j	ffffffe000202b74 <create_mapping+0x22c>
        uint64_t pgd_entry = *(pgd + ((va >> 30) & 0x1ff));
ffffffe0002029dc:	fa043783          	ld	a5,-96(s0)
ffffffe0002029e0:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002029e4:	1ff7f793          	andi	a5,a5,511
ffffffe0002029e8:	00379793          	slli	a5,a5,0x3
ffffffe0002029ec:	fd043703          	ld	a4,-48(s0)
ffffffe0002029f0:	00f707b3          	add	a5,a4,a5
ffffffe0002029f4:	0007b783          	ld	a5,0(a5)
ffffffe0002029f8:	fef43423          	sd	a5,-24(s0)
        if (!(pgd_entry & PTE_V)) {
ffffffe0002029fc:	fe843783          	ld	a5,-24(s0)
ffffffe000202a00:	0017f793          	andi	a5,a5,1
ffffffe000202a04:	06079063          	bnez	a5,ffffffe000202a64 <create_mapping+0x11c>
            uint64_t ppmd = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppmd是PMD页表的物理地址
ffffffe000202a08:	fb5fd0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe000202a0c:	00050793          	mv	a5,a0
ffffffe000202a10:	00078713          	mv	a4,a5
ffffffe000202a14:	04100793          	li	a5,65
ffffffe000202a18:	01f79793          	slli	a5,a5,0x1f
ffffffe000202a1c:	00f707b3          	add	a5,a4,a5
ffffffe000202a20:	fcf43423          	sd	a5,-56(s0)
            // LogBLUE("ppmd: 0x%llx", ppmd);
            *(pgd + ((va >> 30) & 0x1ff)) = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe000202a24:	fc843783          	ld	a5,-56(s0)
ffffffe000202a28:	00c7d793          	srli	a5,a5,0xc
ffffffe000202a2c:	00a79713          	slli	a4,a5,0xa
ffffffe000202a30:	fa043783          	ld	a5,-96(s0)
ffffffe000202a34:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202a38:	1ff7f793          	andi	a5,a5,511
ffffffe000202a3c:	00379793          	slli	a5,a5,0x3
ffffffe000202a40:	fd043683          	ld	a3,-48(s0)
ffffffe000202a44:	00f687b3          	add	a5,a3,a5
ffffffe000202a48:	00176713          	ori	a4,a4,1
ffffffe000202a4c:	00e7b023          	sd	a4,0(a5)
            pgd_entry = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe000202a50:	fc843783          	ld	a5,-56(s0)
ffffffe000202a54:	00c7d793          	srli	a5,a5,0xc
ffffffe000202a58:	00a79793          	slli	a5,a5,0xa
ffffffe000202a5c:	0017e793          	ori	a5,a5,1
ffffffe000202a60:	fef43423          	sd	a5,-24(s0)
        }
    
        pmd = (uint64_t*) (((pgd_entry >> 10) << 12) + PA2VA_OFFSET); // pmd此时是PMD页表的虚拟地址
ffffffe000202a64:	fe843783          	ld	a5,-24(s0)
ffffffe000202a68:	00a7d793          	srli	a5,a5,0xa
ffffffe000202a6c:	00c79713          	slli	a4,a5,0xc
ffffffe000202a70:	fbf00793          	li	a5,-65
ffffffe000202a74:	01f79793          	slli	a5,a5,0x1f
ffffffe000202a78:	00f707b3          	add	a5,a4,a5
ffffffe000202a7c:	fcf43023          	sd	a5,-64(s0)
        uint64_t pmd_entry = *(pmd + ((va >> 21) & 0x1ff));
ffffffe000202a80:	fa043783          	ld	a5,-96(s0)
ffffffe000202a84:	0157d793          	srli	a5,a5,0x15
ffffffe000202a88:	1ff7f793          	andi	a5,a5,511
ffffffe000202a8c:	00379793          	slli	a5,a5,0x3
ffffffe000202a90:	fc043703          	ld	a4,-64(s0)
ffffffe000202a94:	00f707b3          	add	a5,a4,a5
ffffffe000202a98:	0007b783          	ld	a5,0(a5)
ffffffe000202a9c:	fef43023          	sd	a5,-32(s0)
        if (!(pmd_entry & PTE_V)) {
ffffffe000202aa0:	fe043783          	ld	a5,-32(s0)
ffffffe000202aa4:	0017f793          	andi	a5,a5,1
ffffffe000202aa8:	06079063          	bnez	a5,ffffffe000202b08 <create_mapping+0x1c0>
            uint64_t ppte = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppte是PTE页表的物理地址
ffffffe000202aac:	f11fd0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe000202ab0:	00050793          	mv	a5,a0
ffffffe000202ab4:	00078713          	mv	a4,a5
ffffffe000202ab8:	04100793          	li	a5,65
ffffffe000202abc:	01f79793          	slli	a5,a5,0x1f
ffffffe000202ac0:	00f707b3          	add	a5,a4,a5
ffffffe000202ac4:	faf43c23          	sd	a5,-72(s0)
            // LogBLUE("ppte: 0x%llx", ppte);
            *(pmd + ((va >> 21) & 0x1ff)) = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000202ac8:	fb843783          	ld	a5,-72(s0)
ffffffe000202acc:	00c7d793          	srli	a5,a5,0xc
ffffffe000202ad0:	00a79713          	slli	a4,a5,0xa
ffffffe000202ad4:	fa043783          	ld	a5,-96(s0)
ffffffe000202ad8:	0157d793          	srli	a5,a5,0x15
ffffffe000202adc:	1ff7f793          	andi	a5,a5,511
ffffffe000202ae0:	00379793          	slli	a5,a5,0x3
ffffffe000202ae4:	fc043683          	ld	a3,-64(s0)
ffffffe000202ae8:	00f687b3          	add	a5,a3,a5
ffffffe000202aec:	00176713          	ori	a4,a4,1
ffffffe000202af0:	00e7b023          	sd	a4,0(a5)
            pmd_entry = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000202af4:	fb843783          	ld	a5,-72(s0)
ffffffe000202af8:	00c7d793          	srli	a5,a5,0xc
ffffffe000202afc:	00a79793          	slli	a5,a5,0xa
ffffffe000202b00:	0017e793          	ori	a5,a5,1
ffffffe000202b04:	fef43023          	sd	a5,-32(s0)
        }
        
        pte = (uint64_t*) (((pmd_entry >> 10) << 12) + PA2VA_OFFSET); // pte此时是PTE页表的虚拟地址
ffffffe000202b08:	fe043783          	ld	a5,-32(s0)
ffffffe000202b0c:	00a7d793          	srli	a5,a5,0xa
ffffffe000202b10:	00c79713          	slli	a4,a5,0xc
ffffffe000202b14:	fbf00793          	li	a5,-65
ffffffe000202b18:	01f79793          	slli	a5,a5,0x1f
ffffffe000202b1c:	00f707b3          	add	a5,a4,a5
ffffffe000202b20:	faf43823          	sd	a5,-80(s0)
        *(pte + ((va >> 12) & 0x1ff)) = ((pa >> 12) << 10) | perm ;
ffffffe000202b24:	f9843783          	ld	a5,-104(s0)
ffffffe000202b28:	00c7d793          	srli	a5,a5,0xc
ffffffe000202b2c:	00a79693          	slli	a3,a5,0xa
ffffffe000202b30:	fa043783          	ld	a5,-96(s0)
ffffffe000202b34:	00c7d793          	srli	a5,a5,0xc
ffffffe000202b38:	1ff7f793          	andi	a5,a5,511
ffffffe000202b3c:	00379793          	slli	a5,a5,0x3
ffffffe000202b40:	fb043703          	ld	a4,-80(s0)
ffffffe000202b44:	00f707b3          	add	a5,a4,a5
ffffffe000202b48:	f8843703          	ld	a4,-120(s0)
ffffffe000202b4c:	00e6e733          	or	a4,a3,a4
ffffffe000202b50:	00e7b023          	sd	a4,0(a5)


        // if(va <= 0xffffffe000209000)LogBLUE("va: 0x%llx, pa: 0x%llx, perm: 0x%llx", va, pa, perm);
        va += PGSIZE;
ffffffe000202b54:	fa043703          	ld	a4,-96(s0)
ffffffe000202b58:	000017b7          	lui	a5,0x1
ffffffe000202b5c:	00f707b3          	add	a5,a4,a5
ffffffe000202b60:	faf43023          	sd	a5,-96(s0)
        pa += PGSIZE;
ffffffe000202b64:	f9843703          	ld	a4,-104(s0)
ffffffe000202b68:	000017b7          	lui	a5,0x1
ffffffe000202b6c:	00f707b3          	add	a5,a4,a5
ffffffe000202b70:	f8f43c23          	sd	a5,-104(s0)
    while(va < vlimit){
ffffffe000202b74:	fa043703          	ld	a4,-96(s0)
ffffffe000202b78:	fd843783          	ld	a5,-40(s0)
ffffffe000202b7c:	e6f760e3          	bltu	a4,a5,ffffffe0002029dc <create_mapping+0x94>
    }
    
}
ffffffe000202b80:	00000013          	nop
ffffffe000202b84:	00000013          	nop
ffffffe000202b88:	08813083          	ld	ra,136(sp)
ffffffe000202b8c:	08013403          	ld	s0,128(sp)
ffffffe000202b90:	09010113          	addi	sp,sp,144
ffffffe000202b94:	00008067          	ret

ffffffe000202b98 <start_kernel>:
extern void test();

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

int start_kernel() {
ffffffe000202b98:	ff010113          	addi	sp,sp,-16
ffffffe000202b9c:	00113423          	sd	ra,8(sp)
ffffffe000202ba0:	00813023          	sd	s0,0(sp)
ffffffe000202ba4:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000202ba8:	00002517          	auipc	a0,0x2
ffffffe000202bac:	be850513          	addi	a0,a0,-1048 # ffffffe000204790 <__func__.0+0x10>
ffffffe000202bb0:	715000ef          	jal	ra,ffffffe000203ac4 <printk>
    printk(" ZJU Operating System\n");
ffffffe000202bb4:	00002517          	auipc	a0,0x2
ffffffe000202bb8:	be450513          	addi	a0,a0,-1052 # ffffffe000204798 <__func__.0+0x18>
ffffffe000202bbc:	709000ef          	jal	ra,ffffffe000203ac4 <printk>
    schedule();
ffffffe000202bc0:	960fe0ef          	jal	ra,ffffffe000200d20 <schedule>

    test();
ffffffe000202bc4:	01c000ef          	jal	ra,ffffffe000202be0 <test>
    return 0;
ffffffe000202bc8:	00000793          	li	a5,0
}
ffffffe000202bcc:	00078513          	mv	a0,a5
ffffffe000202bd0:	00813083          	ld	ra,8(sp)
ffffffe000202bd4:	00013403          	ld	s0,0(sp)
ffffffe000202bd8:	01010113          	addi	sp,sp,16
ffffffe000202bdc:	00008067          	ret

ffffffe000202be0 <test>:
#include "printk.h"

void test() {
ffffffe000202be0:	fe010113          	addi	sp,sp,-32
ffffffe000202be4:	00113c23          	sd	ra,24(sp)
ffffffe000202be8:	00813823          	sd	s0,16(sp)
ffffffe000202bec:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe000202bf0:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000202bf4:	fec42783          	lw	a5,-20(s0)
ffffffe000202bf8:	0017879b          	addiw	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe000202bfc:	fef42623          	sw	a5,-20(s0)
ffffffe000202c00:	fec42783          	lw	a5,-20(s0)
ffffffe000202c04:	00078713          	mv	a4,a5
ffffffe000202c08:	05f5e7b7          	lui	a5,0x5f5e
ffffffe000202c0c:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe000202c10:	02f767bb          	remw	a5,a4,a5
ffffffe000202c14:	0007879b          	sext.w	a5,a5
ffffffe000202c18:	fc079ee3          	bnez	a5,ffffffe000202bf4 <test+0x14>
            printk("kernel is running!\n");
ffffffe000202c1c:	00002517          	auipc	a0,0x2
ffffffe000202c20:	b9450513          	addi	a0,a0,-1132 # ffffffe0002047b0 <__func__.0+0x30>
ffffffe000202c24:	6a1000ef          	jal	ra,ffffffe000203ac4 <printk>
            i = 0;
ffffffe000202c28:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000202c2c:	fc9ff06f          	j	ffffffe000202bf4 <test+0x14>

ffffffe000202c30 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe000202c30:	fe010113          	addi	sp,sp,-32
ffffffe000202c34:	00113c23          	sd	ra,24(sp)
ffffffe000202c38:	00813823          	sd	s0,16(sp)
ffffffe000202c3c:	02010413          	addi	s0,sp,32
ffffffe000202c40:	00050793          	mv	a5,a0
ffffffe000202c44:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000202c48:	fec42783          	lw	a5,-20(s0)
ffffffe000202c4c:	0ff7f793          	zext.b	a5,a5
ffffffe000202c50:	00078513          	mv	a0,a5
ffffffe000202c54:	9e9fe0ef          	jal	ra,ffffffe00020163c <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000202c58:	fec42783          	lw	a5,-20(s0)
ffffffe000202c5c:	0ff7f793          	zext.b	a5,a5
ffffffe000202c60:	0007879b          	sext.w	a5,a5
}
ffffffe000202c64:	00078513          	mv	a0,a5
ffffffe000202c68:	01813083          	ld	ra,24(sp)
ffffffe000202c6c:	01013403          	ld	s0,16(sp)
ffffffe000202c70:	02010113          	addi	sp,sp,32
ffffffe000202c74:	00008067          	ret

ffffffe000202c78 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000202c78:	fe010113          	addi	sp,sp,-32
ffffffe000202c7c:	00813c23          	sd	s0,24(sp)
ffffffe000202c80:	02010413          	addi	s0,sp,32
ffffffe000202c84:	00050793          	mv	a5,a0
ffffffe000202c88:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000202c8c:	fec42783          	lw	a5,-20(s0)
ffffffe000202c90:	0007871b          	sext.w	a4,a5
ffffffe000202c94:	02000793          	li	a5,32
ffffffe000202c98:	02f70263          	beq	a4,a5,ffffffe000202cbc <isspace+0x44>
ffffffe000202c9c:	fec42783          	lw	a5,-20(s0)
ffffffe000202ca0:	0007871b          	sext.w	a4,a5
ffffffe000202ca4:	00800793          	li	a5,8
ffffffe000202ca8:	00e7de63          	bge	a5,a4,ffffffe000202cc4 <isspace+0x4c>
ffffffe000202cac:	fec42783          	lw	a5,-20(s0)
ffffffe000202cb0:	0007871b          	sext.w	a4,a5
ffffffe000202cb4:	00d00793          	li	a5,13
ffffffe000202cb8:	00e7c663          	blt	a5,a4,ffffffe000202cc4 <isspace+0x4c>
ffffffe000202cbc:	00100793          	li	a5,1
ffffffe000202cc0:	0080006f          	j	ffffffe000202cc8 <isspace+0x50>
ffffffe000202cc4:	00000793          	li	a5,0
}
ffffffe000202cc8:	00078513          	mv	a0,a5
ffffffe000202ccc:	01813403          	ld	s0,24(sp)
ffffffe000202cd0:	02010113          	addi	sp,sp,32
ffffffe000202cd4:	00008067          	ret

ffffffe000202cd8 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000202cd8:	fb010113          	addi	sp,sp,-80
ffffffe000202cdc:	04113423          	sd	ra,72(sp)
ffffffe000202ce0:	04813023          	sd	s0,64(sp)
ffffffe000202ce4:	05010413          	addi	s0,sp,80
ffffffe000202ce8:	fca43423          	sd	a0,-56(s0)
ffffffe000202cec:	fcb43023          	sd	a1,-64(s0)
ffffffe000202cf0:	00060793          	mv	a5,a2
ffffffe000202cf4:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000202cf8:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000202cfc:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000202d00:	fc843783          	ld	a5,-56(s0)
ffffffe000202d04:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000202d08:	0100006f          	j	ffffffe000202d18 <strtol+0x40>
        p++;
ffffffe000202d0c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d10:	00178793          	addi	a5,a5,1
ffffffe000202d14:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000202d18:	fd843783          	ld	a5,-40(s0)
ffffffe000202d1c:	0007c783          	lbu	a5,0(a5)
ffffffe000202d20:	0007879b          	sext.w	a5,a5
ffffffe000202d24:	00078513          	mv	a0,a5
ffffffe000202d28:	f51ff0ef          	jal	ra,ffffffe000202c78 <isspace>
ffffffe000202d2c:	00050793          	mv	a5,a0
ffffffe000202d30:	fc079ee3          	bnez	a5,ffffffe000202d0c <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000202d34:	fd843783          	ld	a5,-40(s0)
ffffffe000202d38:	0007c783          	lbu	a5,0(a5)
ffffffe000202d3c:	00078713          	mv	a4,a5
ffffffe000202d40:	02d00793          	li	a5,45
ffffffe000202d44:	00f71e63          	bne	a4,a5,ffffffe000202d60 <strtol+0x88>
        neg = true;
ffffffe000202d48:	00100793          	li	a5,1
ffffffe000202d4c:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe000202d50:	fd843783          	ld	a5,-40(s0)
ffffffe000202d54:	00178793          	addi	a5,a5,1
ffffffe000202d58:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202d5c:	0240006f          	j	ffffffe000202d80 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000202d60:	fd843783          	ld	a5,-40(s0)
ffffffe000202d64:	0007c783          	lbu	a5,0(a5)
ffffffe000202d68:	00078713          	mv	a4,a5
ffffffe000202d6c:	02b00793          	li	a5,43
ffffffe000202d70:	00f71863          	bne	a4,a5,ffffffe000202d80 <strtol+0xa8>
        p++;
ffffffe000202d74:	fd843783          	ld	a5,-40(s0)
ffffffe000202d78:	00178793          	addi	a5,a5,1
ffffffe000202d7c:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000202d80:	fbc42783          	lw	a5,-68(s0)
ffffffe000202d84:	0007879b          	sext.w	a5,a5
ffffffe000202d88:	06079c63          	bnez	a5,ffffffe000202e00 <strtol+0x128>
        if (*p == '0') {
ffffffe000202d8c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d90:	0007c783          	lbu	a5,0(a5)
ffffffe000202d94:	00078713          	mv	a4,a5
ffffffe000202d98:	03000793          	li	a5,48
ffffffe000202d9c:	04f71e63          	bne	a4,a5,ffffffe000202df8 <strtol+0x120>
            p++;
ffffffe000202da0:	fd843783          	ld	a5,-40(s0)
ffffffe000202da4:	00178793          	addi	a5,a5,1
ffffffe000202da8:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000202dac:	fd843783          	ld	a5,-40(s0)
ffffffe000202db0:	0007c783          	lbu	a5,0(a5)
ffffffe000202db4:	00078713          	mv	a4,a5
ffffffe000202db8:	07800793          	li	a5,120
ffffffe000202dbc:	00f70c63          	beq	a4,a5,ffffffe000202dd4 <strtol+0xfc>
ffffffe000202dc0:	fd843783          	ld	a5,-40(s0)
ffffffe000202dc4:	0007c783          	lbu	a5,0(a5)
ffffffe000202dc8:	00078713          	mv	a4,a5
ffffffe000202dcc:	05800793          	li	a5,88
ffffffe000202dd0:	00f71e63          	bne	a4,a5,ffffffe000202dec <strtol+0x114>
                base = 16;
ffffffe000202dd4:	01000793          	li	a5,16
ffffffe000202dd8:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000202ddc:	fd843783          	ld	a5,-40(s0)
ffffffe000202de0:	00178793          	addi	a5,a5,1
ffffffe000202de4:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202de8:	0180006f          	j	ffffffe000202e00 <strtol+0x128>
            } else {
                base = 8;
ffffffe000202dec:	00800793          	li	a5,8
ffffffe000202df0:	faf42e23          	sw	a5,-68(s0)
ffffffe000202df4:	00c0006f          	j	ffffffe000202e00 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000202df8:	00a00793          	li	a5,10
ffffffe000202dfc:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000202e00:	fd843783          	ld	a5,-40(s0)
ffffffe000202e04:	0007c783          	lbu	a5,0(a5)
ffffffe000202e08:	00078713          	mv	a4,a5
ffffffe000202e0c:	02f00793          	li	a5,47
ffffffe000202e10:	02e7f863          	bgeu	a5,a4,ffffffe000202e40 <strtol+0x168>
ffffffe000202e14:	fd843783          	ld	a5,-40(s0)
ffffffe000202e18:	0007c783          	lbu	a5,0(a5)
ffffffe000202e1c:	00078713          	mv	a4,a5
ffffffe000202e20:	03900793          	li	a5,57
ffffffe000202e24:	00e7ee63          	bltu	a5,a4,ffffffe000202e40 <strtol+0x168>
            digit = *p - '0';
ffffffe000202e28:	fd843783          	ld	a5,-40(s0)
ffffffe000202e2c:	0007c783          	lbu	a5,0(a5)
ffffffe000202e30:	0007879b          	sext.w	a5,a5
ffffffe000202e34:	fd07879b          	addiw	a5,a5,-48
ffffffe000202e38:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202e3c:	0800006f          	j	ffffffe000202ebc <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe000202e40:	fd843783          	ld	a5,-40(s0)
ffffffe000202e44:	0007c783          	lbu	a5,0(a5)
ffffffe000202e48:	00078713          	mv	a4,a5
ffffffe000202e4c:	06000793          	li	a5,96
ffffffe000202e50:	02e7f863          	bgeu	a5,a4,ffffffe000202e80 <strtol+0x1a8>
ffffffe000202e54:	fd843783          	ld	a5,-40(s0)
ffffffe000202e58:	0007c783          	lbu	a5,0(a5)
ffffffe000202e5c:	00078713          	mv	a4,a5
ffffffe000202e60:	07a00793          	li	a5,122
ffffffe000202e64:	00e7ee63          	bltu	a5,a4,ffffffe000202e80 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000202e68:	fd843783          	ld	a5,-40(s0)
ffffffe000202e6c:	0007c783          	lbu	a5,0(a5)
ffffffe000202e70:	0007879b          	sext.w	a5,a5
ffffffe000202e74:	fa97879b          	addiw	a5,a5,-87
ffffffe000202e78:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202e7c:	0400006f          	j	ffffffe000202ebc <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000202e80:	fd843783          	ld	a5,-40(s0)
ffffffe000202e84:	0007c783          	lbu	a5,0(a5)
ffffffe000202e88:	00078713          	mv	a4,a5
ffffffe000202e8c:	04000793          	li	a5,64
ffffffe000202e90:	06e7f863          	bgeu	a5,a4,ffffffe000202f00 <strtol+0x228>
ffffffe000202e94:	fd843783          	ld	a5,-40(s0)
ffffffe000202e98:	0007c783          	lbu	a5,0(a5)
ffffffe000202e9c:	00078713          	mv	a4,a5
ffffffe000202ea0:	05a00793          	li	a5,90
ffffffe000202ea4:	04e7ee63          	bltu	a5,a4,ffffffe000202f00 <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000202ea8:	fd843783          	ld	a5,-40(s0)
ffffffe000202eac:	0007c783          	lbu	a5,0(a5)
ffffffe000202eb0:	0007879b          	sext.w	a5,a5
ffffffe000202eb4:	fc97879b          	addiw	a5,a5,-55
ffffffe000202eb8:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000202ebc:	fd442783          	lw	a5,-44(s0)
ffffffe000202ec0:	00078713          	mv	a4,a5
ffffffe000202ec4:	fbc42783          	lw	a5,-68(s0)
ffffffe000202ec8:	0007071b          	sext.w	a4,a4
ffffffe000202ecc:	0007879b          	sext.w	a5,a5
ffffffe000202ed0:	02f75663          	bge	a4,a5,ffffffe000202efc <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe000202ed4:	fbc42703          	lw	a4,-68(s0)
ffffffe000202ed8:	fe843783          	ld	a5,-24(s0)
ffffffe000202edc:	02f70733          	mul	a4,a4,a5
ffffffe000202ee0:	fd442783          	lw	a5,-44(s0)
ffffffe000202ee4:	00f707b3          	add	a5,a4,a5
ffffffe000202ee8:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000202eec:	fd843783          	ld	a5,-40(s0)
ffffffe000202ef0:	00178793          	addi	a5,a5,1
ffffffe000202ef4:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000202ef8:	f09ff06f          	j	ffffffe000202e00 <strtol+0x128>
            break;
ffffffe000202efc:	00000013          	nop
    }

    if (endptr) {
ffffffe000202f00:	fc043783          	ld	a5,-64(s0)
ffffffe000202f04:	00078863          	beqz	a5,ffffffe000202f14 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe000202f08:	fc043783          	ld	a5,-64(s0)
ffffffe000202f0c:	fd843703          	ld	a4,-40(s0)
ffffffe000202f10:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000202f14:	fe744783          	lbu	a5,-25(s0)
ffffffe000202f18:	0ff7f793          	zext.b	a5,a5
ffffffe000202f1c:	00078863          	beqz	a5,ffffffe000202f2c <strtol+0x254>
ffffffe000202f20:	fe843783          	ld	a5,-24(s0)
ffffffe000202f24:	40f007b3          	neg	a5,a5
ffffffe000202f28:	0080006f          	j	ffffffe000202f30 <strtol+0x258>
ffffffe000202f2c:	fe843783          	ld	a5,-24(s0)
}
ffffffe000202f30:	00078513          	mv	a0,a5
ffffffe000202f34:	04813083          	ld	ra,72(sp)
ffffffe000202f38:	04013403          	ld	s0,64(sp)
ffffffe000202f3c:	05010113          	addi	sp,sp,80
ffffffe000202f40:	00008067          	ret

ffffffe000202f44 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000202f44:	fd010113          	addi	sp,sp,-48
ffffffe000202f48:	02113423          	sd	ra,40(sp)
ffffffe000202f4c:	02813023          	sd	s0,32(sp)
ffffffe000202f50:	03010413          	addi	s0,sp,48
ffffffe000202f54:	fca43c23          	sd	a0,-40(s0)
ffffffe000202f58:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000202f5c:	fd043783          	ld	a5,-48(s0)
ffffffe000202f60:	00079863          	bnez	a5,ffffffe000202f70 <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe000202f64:	00002797          	auipc	a5,0x2
ffffffe000202f68:	86478793          	addi	a5,a5,-1948 # ffffffe0002047c8 <__func__.0+0x48>
ffffffe000202f6c:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000202f70:	fd043783          	ld	a5,-48(s0)
ffffffe000202f74:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000202f78:	0240006f          	j	ffffffe000202f9c <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000202f7c:	fe843783          	ld	a5,-24(s0)
ffffffe000202f80:	00178713          	addi	a4,a5,1
ffffffe000202f84:	fee43423          	sd	a4,-24(s0)
ffffffe000202f88:	0007c783          	lbu	a5,0(a5)
ffffffe000202f8c:	0007871b          	sext.w	a4,a5
ffffffe000202f90:	fd843783          	ld	a5,-40(s0)
ffffffe000202f94:	00070513          	mv	a0,a4
ffffffe000202f98:	000780e7          	jalr	a5
    while (*p) {
ffffffe000202f9c:	fe843783          	ld	a5,-24(s0)
ffffffe000202fa0:	0007c783          	lbu	a5,0(a5)
ffffffe000202fa4:	fc079ce3          	bnez	a5,ffffffe000202f7c <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000202fa8:	fe843703          	ld	a4,-24(s0)
ffffffe000202fac:	fd043783          	ld	a5,-48(s0)
ffffffe000202fb0:	40f707b3          	sub	a5,a4,a5
ffffffe000202fb4:	0007879b          	sext.w	a5,a5
}
ffffffe000202fb8:	00078513          	mv	a0,a5
ffffffe000202fbc:	02813083          	ld	ra,40(sp)
ffffffe000202fc0:	02013403          	ld	s0,32(sp)
ffffffe000202fc4:	03010113          	addi	sp,sp,48
ffffffe000202fc8:	00008067          	ret

ffffffe000202fcc <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000202fcc:	f9010113          	addi	sp,sp,-112
ffffffe000202fd0:	06113423          	sd	ra,104(sp)
ffffffe000202fd4:	06813023          	sd	s0,96(sp)
ffffffe000202fd8:	07010413          	addi	s0,sp,112
ffffffe000202fdc:	faa43423          	sd	a0,-88(s0)
ffffffe000202fe0:	fab43023          	sd	a1,-96(s0)
ffffffe000202fe4:	00060793          	mv	a5,a2
ffffffe000202fe8:	f8d43823          	sd	a3,-112(s0)
ffffffe000202fec:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000202ff0:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202ff4:	0ff7f793          	zext.b	a5,a5
ffffffe000202ff8:	02078663          	beqz	a5,ffffffe000203024 <print_dec_int+0x58>
ffffffe000202ffc:	fa043703          	ld	a4,-96(s0)
ffffffe000203000:	fff00793          	li	a5,-1
ffffffe000203004:	03f79793          	slli	a5,a5,0x3f
ffffffe000203008:	00f71e63          	bne	a4,a5,ffffffe000203024 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe00020300c:	00001597          	auipc	a1,0x1
ffffffe000203010:	7c458593          	addi	a1,a1,1988 # ffffffe0002047d0 <__func__.0+0x50>
ffffffe000203014:	fa843503          	ld	a0,-88(s0)
ffffffe000203018:	f2dff0ef          	jal	ra,ffffffe000202f44 <puts_wo_nl>
ffffffe00020301c:	00050793          	mv	a5,a0
ffffffe000203020:	2a00006f          	j	ffffffe0002032c0 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000203024:	f9043783          	ld	a5,-112(s0)
ffffffe000203028:	00c7a783          	lw	a5,12(a5)
ffffffe00020302c:	00079a63          	bnez	a5,ffffffe000203040 <print_dec_int+0x74>
ffffffe000203030:	fa043783          	ld	a5,-96(s0)
ffffffe000203034:	00079663          	bnez	a5,ffffffe000203040 <print_dec_int+0x74>
        return 0;
ffffffe000203038:	00000793          	li	a5,0
ffffffe00020303c:	2840006f          	j	ffffffe0002032c0 <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000203040:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000203044:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203048:	0ff7f793          	zext.b	a5,a5
ffffffe00020304c:	02078063          	beqz	a5,ffffffe00020306c <print_dec_int+0xa0>
ffffffe000203050:	fa043783          	ld	a5,-96(s0)
ffffffe000203054:	0007dc63          	bgez	a5,ffffffe00020306c <print_dec_int+0xa0>
        neg = true;
ffffffe000203058:	00100793          	li	a5,1
ffffffe00020305c:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000203060:	fa043783          	ld	a5,-96(s0)
ffffffe000203064:	40f007b3          	neg	a5,a5
ffffffe000203068:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe00020306c:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000203070:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203074:	0ff7f793          	zext.b	a5,a5
ffffffe000203078:	02078863          	beqz	a5,ffffffe0002030a8 <print_dec_int+0xdc>
ffffffe00020307c:	fef44783          	lbu	a5,-17(s0)
ffffffe000203080:	0ff7f793          	zext.b	a5,a5
ffffffe000203084:	00079e63          	bnez	a5,ffffffe0002030a0 <print_dec_int+0xd4>
ffffffe000203088:	f9043783          	ld	a5,-112(s0)
ffffffe00020308c:	0057c783          	lbu	a5,5(a5)
ffffffe000203090:	00079863          	bnez	a5,ffffffe0002030a0 <print_dec_int+0xd4>
ffffffe000203094:	f9043783          	ld	a5,-112(s0)
ffffffe000203098:	0047c783          	lbu	a5,4(a5)
ffffffe00020309c:	00078663          	beqz	a5,ffffffe0002030a8 <print_dec_int+0xdc>
ffffffe0002030a0:	00100793          	li	a5,1
ffffffe0002030a4:	0080006f          	j	ffffffe0002030ac <print_dec_int+0xe0>
ffffffe0002030a8:	00000793          	li	a5,0
ffffffe0002030ac:	fcf40ba3          	sb	a5,-41(s0)
ffffffe0002030b0:	fd744783          	lbu	a5,-41(s0)
ffffffe0002030b4:	0017f793          	andi	a5,a5,1
ffffffe0002030b8:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe0002030bc:	fa043703          	ld	a4,-96(s0)
ffffffe0002030c0:	00a00793          	li	a5,10
ffffffe0002030c4:	02f777b3          	remu	a5,a4,a5
ffffffe0002030c8:	0ff7f713          	zext.b	a4,a5
ffffffe0002030cc:	fe842783          	lw	a5,-24(s0)
ffffffe0002030d0:	0017869b          	addiw	a3,a5,1
ffffffe0002030d4:	fed42423          	sw	a3,-24(s0)
ffffffe0002030d8:	0307071b          	addiw	a4,a4,48
ffffffe0002030dc:	0ff77713          	zext.b	a4,a4
ffffffe0002030e0:	ff078793          	addi	a5,a5,-16
ffffffe0002030e4:	008787b3          	add	a5,a5,s0
ffffffe0002030e8:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe0002030ec:	fa043703          	ld	a4,-96(s0)
ffffffe0002030f0:	00a00793          	li	a5,10
ffffffe0002030f4:	02f757b3          	divu	a5,a4,a5
ffffffe0002030f8:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe0002030fc:	fa043783          	ld	a5,-96(s0)
ffffffe000203100:	fa079ee3          	bnez	a5,ffffffe0002030bc <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000203104:	f9043783          	ld	a5,-112(s0)
ffffffe000203108:	00c7a783          	lw	a5,12(a5)
ffffffe00020310c:	00078713          	mv	a4,a5
ffffffe000203110:	fff00793          	li	a5,-1
ffffffe000203114:	02f71063          	bne	a4,a5,ffffffe000203134 <print_dec_int+0x168>
ffffffe000203118:	f9043783          	ld	a5,-112(s0)
ffffffe00020311c:	0037c783          	lbu	a5,3(a5)
ffffffe000203120:	00078a63          	beqz	a5,ffffffe000203134 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000203124:	f9043783          	ld	a5,-112(s0)
ffffffe000203128:	0087a703          	lw	a4,8(a5)
ffffffe00020312c:	f9043783          	ld	a5,-112(s0)
ffffffe000203130:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000203134:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000203138:	f9043783          	ld	a5,-112(s0)
ffffffe00020313c:	0087a703          	lw	a4,8(a5)
ffffffe000203140:	fe842783          	lw	a5,-24(s0)
ffffffe000203144:	fcf42823          	sw	a5,-48(s0)
ffffffe000203148:	f9043783          	ld	a5,-112(s0)
ffffffe00020314c:	00c7a783          	lw	a5,12(a5)
ffffffe000203150:	fcf42623          	sw	a5,-52(s0)
ffffffe000203154:	fd042783          	lw	a5,-48(s0)
ffffffe000203158:	00078593          	mv	a1,a5
ffffffe00020315c:	fcc42783          	lw	a5,-52(s0)
ffffffe000203160:	00078613          	mv	a2,a5
ffffffe000203164:	0006069b          	sext.w	a3,a2
ffffffe000203168:	0005879b          	sext.w	a5,a1
ffffffe00020316c:	00f6d463          	bge	a3,a5,ffffffe000203174 <print_dec_int+0x1a8>
ffffffe000203170:	00058613          	mv	a2,a1
ffffffe000203174:	0006079b          	sext.w	a5,a2
ffffffe000203178:	40f707bb          	subw	a5,a4,a5
ffffffe00020317c:	0007871b          	sext.w	a4,a5
ffffffe000203180:	fd744783          	lbu	a5,-41(s0)
ffffffe000203184:	0007879b          	sext.w	a5,a5
ffffffe000203188:	40f707bb          	subw	a5,a4,a5
ffffffe00020318c:	fef42023          	sw	a5,-32(s0)
ffffffe000203190:	0280006f          	j	ffffffe0002031b8 <print_dec_int+0x1ec>
        putch(' ');
ffffffe000203194:	fa843783          	ld	a5,-88(s0)
ffffffe000203198:	02000513          	li	a0,32
ffffffe00020319c:	000780e7          	jalr	a5
        ++written;
ffffffe0002031a0:	fe442783          	lw	a5,-28(s0)
ffffffe0002031a4:	0017879b          	addiw	a5,a5,1
ffffffe0002031a8:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002031ac:	fe042783          	lw	a5,-32(s0)
ffffffe0002031b0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002031b4:	fef42023          	sw	a5,-32(s0)
ffffffe0002031b8:	fe042783          	lw	a5,-32(s0)
ffffffe0002031bc:	0007879b          	sext.w	a5,a5
ffffffe0002031c0:	fcf04ae3          	bgtz	a5,ffffffe000203194 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe0002031c4:	fd744783          	lbu	a5,-41(s0)
ffffffe0002031c8:	0ff7f793          	zext.b	a5,a5
ffffffe0002031cc:	04078463          	beqz	a5,ffffffe000203214 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe0002031d0:	fef44783          	lbu	a5,-17(s0)
ffffffe0002031d4:	0ff7f793          	zext.b	a5,a5
ffffffe0002031d8:	00078663          	beqz	a5,ffffffe0002031e4 <print_dec_int+0x218>
ffffffe0002031dc:	02d00793          	li	a5,45
ffffffe0002031e0:	01c0006f          	j	ffffffe0002031fc <print_dec_int+0x230>
ffffffe0002031e4:	f9043783          	ld	a5,-112(s0)
ffffffe0002031e8:	0057c783          	lbu	a5,5(a5)
ffffffe0002031ec:	00078663          	beqz	a5,ffffffe0002031f8 <print_dec_int+0x22c>
ffffffe0002031f0:	02b00793          	li	a5,43
ffffffe0002031f4:	0080006f          	j	ffffffe0002031fc <print_dec_int+0x230>
ffffffe0002031f8:	02000793          	li	a5,32
ffffffe0002031fc:	fa843703          	ld	a4,-88(s0)
ffffffe000203200:	00078513          	mv	a0,a5
ffffffe000203204:	000700e7          	jalr	a4
        ++written;
ffffffe000203208:	fe442783          	lw	a5,-28(s0)
ffffffe00020320c:	0017879b          	addiw	a5,a5,1
ffffffe000203210:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000203214:	fe842783          	lw	a5,-24(s0)
ffffffe000203218:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020321c:	0280006f          	j	ffffffe000203244 <print_dec_int+0x278>
        putch('0');
ffffffe000203220:	fa843783          	ld	a5,-88(s0)
ffffffe000203224:	03000513          	li	a0,48
ffffffe000203228:	000780e7          	jalr	a5
        ++written;
ffffffe00020322c:	fe442783          	lw	a5,-28(s0)
ffffffe000203230:	0017879b          	addiw	a5,a5,1
ffffffe000203234:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000203238:	fdc42783          	lw	a5,-36(s0)
ffffffe00020323c:	0017879b          	addiw	a5,a5,1
ffffffe000203240:	fcf42e23          	sw	a5,-36(s0)
ffffffe000203244:	f9043783          	ld	a5,-112(s0)
ffffffe000203248:	00c7a703          	lw	a4,12(a5)
ffffffe00020324c:	fd744783          	lbu	a5,-41(s0)
ffffffe000203250:	0007879b          	sext.w	a5,a5
ffffffe000203254:	40f707bb          	subw	a5,a4,a5
ffffffe000203258:	0007871b          	sext.w	a4,a5
ffffffe00020325c:	fdc42783          	lw	a5,-36(s0)
ffffffe000203260:	0007879b          	sext.w	a5,a5
ffffffe000203264:	fae7cee3          	blt	a5,a4,ffffffe000203220 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203268:	fe842783          	lw	a5,-24(s0)
ffffffe00020326c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203270:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203274:	03c0006f          	j	ffffffe0002032b0 <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000203278:	fd842783          	lw	a5,-40(s0)
ffffffe00020327c:	ff078793          	addi	a5,a5,-16
ffffffe000203280:	008787b3          	add	a5,a5,s0
ffffffe000203284:	fc87c783          	lbu	a5,-56(a5)
ffffffe000203288:	0007871b          	sext.w	a4,a5
ffffffe00020328c:	fa843783          	ld	a5,-88(s0)
ffffffe000203290:	00070513          	mv	a0,a4
ffffffe000203294:	000780e7          	jalr	a5
        ++written;
ffffffe000203298:	fe442783          	lw	a5,-28(s0)
ffffffe00020329c:	0017879b          	addiw	a5,a5,1
ffffffe0002032a0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002032a4:	fd842783          	lw	a5,-40(s0)
ffffffe0002032a8:	fff7879b          	addiw	a5,a5,-1
ffffffe0002032ac:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002032b0:	fd842783          	lw	a5,-40(s0)
ffffffe0002032b4:	0007879b          	sext.w	a5,a5
ffffffe0002032b8:	fc07d0e3          	bgez	a5,ffffffe000203278 <print_dec_int+0x2ac>
    }

    return written;
ffffffe0002032bc:	fe442783          	lw	a5,-28(s0)
}
ffffffe0002032c0:	00078513          	mv	a0,a5
ffffffe0002032c4:	06813083          	ld	ra,104(sp)
ffffffe0002032c8:	06013403          	ld	s0,96(sp)
ffffffe0002032cc:	07010113          	addi	sp,sp,112
ffffffe0002032d0:	00008067          	ret

ffffffe0002032d4 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe0002032d4:	f4010113          	addi	sp,sp,-192
ffffffe0002032d8:	0a113c23          	sd	ra,184(sp)
ffffffe0002032dc:	0a813823          	sd	s0,176(sp)
ffffffe0002032e0:	0c010413          	addi	s0,sp,192
ffffffe0002032e4:	f4a43c23          	sd	a0,-168(s0)
ffffffe0002032e8:	f4b43823          	sd	a1,-176(s0)
ffffffe0002032ec:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe0002032f0:	f8043023          	sd	zero,-128(s0)
ffffffe0002032f4:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe0002032f8:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe0002032fc:	7a40006f          	j	ffffffe000203aa0 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000203300:	f8044783          	lbu	a5,-128(s0)
ffffffe000203304:	72078e63          	beqz	a5,ffffffe000203a40 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000203308:	f5043783          	ld	a5,-176(s0)
ffffffe00020330c:	0007c783          	lbu	a5,0(a5)
ffffffe000203310:	00078713          	mv	a4,a5
ffffffe000203314:	02300793          	li	a5,35
ffffffe000203318:	00f71863          	bne	a4,a5,ffffffe000203328 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe00020331c:	00100793          	li	a5,1
ffffffe000203320:	f8f40123          	sb	a5,-126(s0)
ffffffe000203324:	7700006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe000203328:	f5043783          	ld	a5,-176(s0)
ffffffe00020332c:	0007c783          	lbu	a5,0(a5)
ffffffe000203330:	00078713          	mv	a4,a5
ffffffe000203334:	03000793          	li	a5,48
ffffffe000203338:	00f71863          	bne	a4,a5,ffffffe000203348 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe00020333c:	00100793          	li	a5,1
ffffffe000203340:	f8f401a3          	sb	a5,-125(s0)
ffffffe000203344:	7500006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe000203348:	f5043783          	ld	a5,-176(s0)
ffffffe00020334c:	0007c783          	lbu	a5,0(a5)
ffffffe000203350:	00078713          	mv	a4,a5
ffffffe000203354:	06c00793          	li	a5,108
ffffffe000203358:	04f70063          	beq	a4,a5,ffffffe000203398 <vprintfmt+0xc4>
ffffffe00020335c:	f5043783          	ld	a5,-176(s0)
ffffffe000203360:	0007c783          	lbu	a5,0(a5)
ffffffe000203364:	00078713          	mv	a4,a5
ffffffe000203368:	07a00793          	li	a5,122
ffffffe00020336c:	02f70663          	beq	a4,a5,ffffffe000203398 <vprintfmt+0xc4>
ffffffe000203370:	f5043783          	ld	a5,-176(s0)
ffffffe000203374:	0007c783          	lbu	a5,0(a5)
ffffffe000203378:	00078713          	mv	a4,a5
ffffffe00020337c:	07400793          	li	a5,116
ffffffe000203380:	00f70c63          	beq	a4,a5,ffffffe000203398 <vprintfmt+0xc4>
ffffffe000203384:	f5043783          	ld	a5,-176(s0)
ffffffe000203388:	0007c783          	lbu	a5,0(a5)
ffffffe00020338c:	00078713          	mv	a4,a5
ffffffe000203390:	06a00793          	li	a5,106
ffffffe000203394:	00f71863          	bne	a4,a5,ffffffe0002033a4 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000203398:	00100793          	li	a5,1
ffffffe00020339c:	f8f400a3          	sb	a5,-127(s0)
ffffffe0002033a0:	6f40006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe0002033a4:	f5043783          	ld	a5,-176(s0)
ffffffe0002033a8:	0007c783          	lbu	a5,0(a5)
ffffffe0002033ac:	00078713          	mv	a4,a5
ffffffe0002033b0:	02b00793          	li	a5,43
ffffffe0002033b4:	00f71863          	bne	a4,a5,ffffffe0002033c4 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe0002033b8:	00100793          	li	a5,1
ffffffe0002033bc:	f8f402a3          	sb	a5,-123(s0)
ffffffe0002033c0:	6d40006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe0002033c4:	f5043783          	ld	a5,-176(s0)
ffffffe0002033c8:	0007c783          	lbu	a5,0(a5)
ffffffe0002033cc:	00078713          	mv	a4,a5
ffffffe0002033d0:	02000793          	li	a5,32
ffffffe0002033d4:	00f71863          	bne	a4,a5,ffffffe0002033e4 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe0002033d8:	00100793          	li	a5,1
ffffffe0002033dc:	f8f40223          	sb	a5,-124(s0)
ffffffe0002033e0:	6b40006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe0002033e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002033e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002033ec:	00078713          	mv	a4,a5
ffffffe0002033f0:	02a00793          	li	a5,42
ffffffe0002033f4:	00f71e63          	bne	a4,a5,ffffffe000203410 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe0002033f8:	f4843783          	ld	a5,-184(s0)
ffffffe0002033fc:	00878713          	addi	a4,a5,8
ffffffe000203400:	f4e43423          	sd	a4,-184(s0)
ffffffe000203404:	0007a783          	lw	a5,0(a5)
ffffffe000203408:	f8f42423          	sw	a5,-120(s0)
ffffffe00020340c:	6880006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000203410:	f5043783          	ld	a5,-176(s0)
ffffffe000203414:	0007c783          	lbu	a5,0(a5)
ffffffe000203418:	00078713          	mv	a4,a5
ffffffe00020341c:	03000793          	li	a5,48
ffffffe000203420:	04e7f663          	bgeu	a5,a4,ffffffe00020346c <vprintfmt+0x198>
ffffffe000203424:	f5043783          	ld	a5,-176(s0)
ffffffe000203428:	0007c783          	lbu	a5,0(a5)
ffffffe00020342c:	00078713          	mv	a4,a5
ffffffe000203430:	03900793          	li	a5,57
ffffffe000203434:	02e7ec63          	bltu	a5,a4,ffffffe00020346c <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe000203438:	f5043783          	ld	a5,-176(s0)
ffffffe00020343c:	f5040713          	addi	a4,s0,-176
ffffffe000203440:	00a00613          	li	a2,10
ffffffe000203444:	00070593          	mv	a1,a4
ffffffe000203448:	00078513          	mv	a0,a5
ffffffe00020344c:	88dff0ef          	jal	ra,ffffffe000202cd8 <strtol>
ffffffe000203450:	00050793          	mv	a5,a0
ffffffe000203454:	0007879b          	sext.w	a5,a5
ffffffe000203458:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe00020345c:	f5043783          	ld	a5,-176(s0)
ffffffe000203460:	fff78793          	addi	a5,a5,-1
ffffffe000203464:	f4f43823          	sd	a5,-176(s0)
ffffffe000203468:	62c0006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe00020346c:	f5043783          	ld	a5,-176(s0)
ffffffe000203470:	0007c783          	lbu	a5,0(a5)
ffffffe000203474:	00078713          	mv	a4,a5
ffffffe000203478:	02e00793          	li	a5,46
ffffffe00020347c:	06f71863          	bne	a4,a5,ffffffe0002034ec <vprintfmt+0x218>
                fmt++;
ffffffe000203480:	f5043783          	ld	a5,-176(s0)
ffffffe000203484:	00178793          	addi	a5,a5,1
ffffffe000203488:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe00020348c:	f5043783          	ld	a5,-176(s0)
ffffffe000203490:	0007c783          	lbu	a5,0(a5)
ffffffe000203494:	00078713          	mv	a4,a5
ffffffe000203498:	02a00793          	li	a5,42
ffffffe00020349c:	00f71e63          	bne	a4,a5,ffffffe0002034b8 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe0002034a0:	f4843783          	ld	a5,-184(s0)
ffffffe0002034a4:	00878713          	addi	a4,a5,8
ffffffe0002034a8:	f4e43423          	sd	a4,-184(s0)
ffffffe0002034ac:	0007a783          	lw	a5,0(a5)
ffffffe0002034b0:	f8f42623          	sw	a5,-116(s0)
ffffffe0002034b4:	5e00006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe0002034b8:	f5043783          	ld	a5,-176(s0)
ffffffe0002034bc:	f5040713          	addi	a4,s0,-176
ffffffe0002034c0:	00a00613          	li	a2,10
ffffffe0002034c4:	00070593          	mv	a1,a4
ffffffe0002034c8:	00078513          	mv	a0,a5
ffffffe0002034cc:	80dff0ef          	jal	ra,ffffffe000202cd8 <strtol>
ffffffe0002034d0:	00050793          	mv	a5,a0
ffffffe0002034d4:	0007879b          	sext.w	a5,a5
ffffffe0002034d8:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe0002034dc:	f5043783          	ld	a5,-176(s0)
ffffffe0002034e0:	fff78793          	addi	a5,a5,-1
ffffffe0002034e4:	f4f43823          	sd	a5,-176(s0)
ffffffe0002034e8:	5ac0006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002034ec:	f5043783          	ld	a5,-176(s0)
ffffffe0002034f0:	0007c783          	lbu	a5,0(a5)
ffffffe0002034f4:	00078713          	mv	a4,a5
ffffffe0002034f8:	07800793          	li	a5,120
ffffffe0002034fc:	02f70663          	beq	a4,a5,ffffffe000203528 <vprintfmt+0x254>
ffffffe000203500:	f5043783          	ld	a5,-176(s0)
ffffffe000203504:	0007c783          	lbu	a5,0(a5)
ffffffe000203508:	00078713          	mv	a4,a5
ffffffe00020350c:	05800793          	li	a5,88
ffffffe000203510:	00f70c63          	beq	a4,a5,ffffffe000203528 <vprintfmt+0x254>
ffffffe000203514:	f5043783          	ld	a5,-176(s0)
ffffffe000203518:	0007c783          	lbu	a5,0(a5)
ffffffe00020351c:	00078713          	mv	a4,a5
ffffffe000203520:	07000793          	li	a5,112
ffffffe000203524:	30f71263          	bne	a4,a5,ffffffe000203828 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000203528:	f5043783          	ld	a5,-176(s0)
ffffffe00020352c:	0007c783          	lbu	a5,0(a5)
ffffffe000203530:	00078713          	mv	a4,a5
ffffffe000203534:	07000793          	li	a5,112
ffffffe000203538:	00f70663          	beq	a4,a5,ffffffe000203544 <vprintfmt+0x270>
ffffffe00020353c:	f8144783          	lbu	a5,-127(s0)
ffffffe000203540:	00078663          	beqz	a5,ffffffe00020354c <vprintfmt+0x278>
ffffffe000203544:	00100793          	li	a5,1
ffffffe000203548:	0080006f          	j	ffffffe000203550 <vprintfmt+0x27c>
ffffffe00020354c:	00000793          	li	a5,0
ffffffe000203550:	faf403a3          	sb	a5,-89(s0)
ffffffe000203554:	fa744783          	lbu	a5,-89(s0)
ffffffe000203558:	0017f793          	andi	a5,a5,1
ffffffe00020355c:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000203560:	fa744783          	lbu	a5,-89(s0)
ffffffe000203564:	0ff7f793          	zext.b	a5,a5
ffffffe000203568:	00078c63          	beqz	a5,ffffffe000203580 <vprintfmt+0x2ac>
ffffffe00020356c:	f4843783          	ld	a5,-184(s0)
ffffffe000203570:	00878713          	addi	a4,a5,8
ffffffe000203574:	f4e43423          	sd	a4,-184(s0)
ffffffe000203578:	0007b783          	ld	a5,0(a5)
ffffffe00020357c:	01c0006f          	j	ffffffe000203598 <vprintfmt+0x2c4>
ffffffe000203580:	f4843783          	ld	a5,-184(s0)
ffffffe000203584:	00878713          	addi	a4,a5,8
ffffffe000203588:	f4e43423          	sd	a4,-184(s0)
ffffffe00020358c:	0007a783          	lw	a5,0(a5)
ffffffe000203590:	02079793          	slli	a5,a5,0x20
ffffffe000203594:	0207d793          	srli	a5,a5,0x20
ffffffe000203598:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe00020359c:	f8c42783          	lw	a5,-116(s0)
ffffffe0002035a0:	02079463          	bnez	a5,ffffffe0002035c8 <vprintfmt+0x2f4>
ffffffe0002035a4:	fe043783          	ld	a5,-32(s0)
ffffffe0002035a8:	02079063          	bnez	a5,ffffffe0002035c8 <vprintfmt+0x2f4>
ffffffe0002035ac:	f5043783          	ld	a5,-176(s0)
ffffffe0002035b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002035b4:	00078713          	mv	a4,a5
ffffffe0002035b8:	07000793          	li	a5,112
ffffffe0002035bc:	00f70663          	beq	a4,a5,ffffffe0002035c8 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe0002035c0:	f8040023          	sb	zero,-128(s0)
ffffffe0002035c4:	4d00006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe0002035c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002035cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002035d0:	00078713          	mv	a4,a5
ffffffe0002035d4:	07000793          	li	a5,112
ffffffe0002035d8:	00f70a63          	beq	a4,a5,ffffffe0002035ec <vprintfmt+0x318>
ffffffe0002035dc:	f8244783          	lbu	a5,-126(s0)
ffffffe0002035e0:	00078a63          	beqz	a5,ffffffe0002035f4 <vprintfmt+0x320>
ffffffe0002035e4:	fe043783          	ld	a5,-32(s0)
ffffffe0002035e8:	00078663          	beqz	a5,ffffffe0002035f4 <vprintfmt+0x320>
ffffffe0002035ec:	00100793          	li	a5,1
ffffffe0002035f0:	0080006f          	j	ffffffe0002035f8 <vprintfmt+0x324>
ffffffe0002035f4:	00000793          	li	a5,0
ffffffe0002035f8:	faf40323          	sb	a5,-90(s0)
ffffffe0002035fc:	fa644783          	lbu	a5,-90(s0)
ffffffe000203600:	0017f793          	andi	a5,a5,1
ffffffe000203604:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000203608:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe00020360c:	f5043783          	ld	a5,-176(s0)
ffffffe000203610:	0007c783          	lbu	a5,0(a5)
ffffffe000203614:	00078713          	mv	a4,a5
ffffffe000203618:	05800793          	li	a5,88
ffffffe00020361c:	00f71863          	bne	a4,a5,ffffffe00020362c <vprintfmt+0x358>
ffffffe000203620:	00001797          	auipc	a5,0x1
ffffffe000203624:	1c878793          	addi	a5,a5,456 # ffffffe0002047e8 <upperxdigits.1>
ffffffe000203628:	00c0006f          	j	ffffffe000203634 <vprintfmt+0x360>
ffffffe00020362c:	00001797          	auipc	a5,0x1
ffffffe000203630:	1d478793          	addi	a5,a5,468 # ffffffe000204800 <lowerxdigits.0>
ffffffe000203634:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000203638:	fe043783          	ld	a5,-32(s0)
ffffffe00020363c:	00f7f793          	andi	a5,a5,15
ffffffe000203640:	f9843703          	ld	a4,-104(s0)
ffffffe000203644:	00f70733          	add	a4,a4,a5
ffffffe000203648:	fdc42783          	lw	a5,-36(s0)
ffffffe00020364c:	0017869b          	addiw	a3,a5,1
ffffffe000203650:	fcd42e23          	sw	a3,-36(s0)
ffffffe000203654:	00074703          	lbu	a4,0(a4)
ffffffe000203658:	ff078793          	addi	a5,a5,-16
ffffffe00020365c:	008787b3          	add	a5,a5,s0
ffffffe000203660:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000203664:	fe043783          	ld	a5,-32(s0)
ffffffe000203668:	0047d793          	srli	a5,a5,0x4
ffffffe00020366c:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe000203670:	fe043783          	ld	a5,-32(s0)
ffffffe000203674:	fc0792e3          	bnez	a5,ffffffe000203638 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000203678:	f8c42783          	lw	a5,-116(s0)
ffffffe00020367c:	00078713          	mv	a4,a5
ffffffe000203680:	fff00793          	li	a5,-1
ffffffe000203684:	02f71663          	bne	a4,a5,ffffffe0002036b0 <vprintfmt+0x3dc>
ffffffe000203688:	f8344783          	lbu	a5,-125(s0)
ffffffe00020368c:	02078263          	beqz	a5,ffffffe0002036b0 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe000203690:	f8842703          	lw	a4,-120(s0)
ffffffe000203694:	fa644783          	lbu	a5,-90(s0)
ffffffe000203698:	0007879b          	sext.w	a5,a5
ffffffe00020369c:	0017979b          	slliw	a5,a5,0x1
ffffffe0002036a0:	0007879b          	sext.w	a5,a5
ffffffe0002036a4:	40f707bb          	subw	a5,a4,a5
ffffffe0002036a8:	0007879b          	sext.w	a5,a5
ffffffe0002036ac:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002036b0:	f8842703          	lw	a4,-120(s0)
ffffffe0002036b4:	fa644783          	lbu	a5,-90(s0)
ffffffe0002036b8:	0007879b          	sext.w	a5,a5
ffffffe0002036bc:	0017979b          	slliw	a5,a5,0x1
ffffffe0002036c0:	0007879b          	sext.w	a5,a5
ffffffe0002036c4:	40f707bb          	subw	a5,a4,a5
ffffffe0002036c8:	0007871b          	sext.w	a4,a5
ffffffe0002036cc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002036d0:	f8f42a23          	sw	a5,-108(s0)
ffffffe0002036d4:	f8c42783          	lw	a5,-116(s0)
ffffffe0002036d8:	f8f42823          	sw	a5,-112(s0)
ffffffe0002036dc:	f9442783          	lw	a5,-108(s0)
ffffffe0002036e0:	00078593          	mv	a1,a5
ffffffe0002036e4:	f9042783          	lw	a5,-112(s0)
ffffffe0002036e8:	00078613          	mv	a2,a5
ffffffe0002036ec:	0006069b          	sext.w	a3,a2
ffffffe0002036f0:	0005879b          	sext.w	a5,a1
ffffffe0002036f4:	00f6d463          	bge	a3,a5,ffffffe0002036fc <vprintfmt+0x428>
ffffffe0002036f8:	00058613          	mv	a2,a1
ffffffe0002036fc:	0006079b          	sext.w	a5,a2
ffffffe000203700:	40f707bb          	subw	a5,a4,a5
ffffffe000203704:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203708:	0280006f          	j	ffffffe000203730 <vprintfmt+0x45c>
                    putch(' ');
ffffffe00020370c:	f5843783          	ld	a5,-168(s0)
ffffffe000203710:	02000513          	li	a0,32
ffffffe000203714:	000780e7          	jalr	a5
                    ++written;
ffffffe000203718:	fec42783          	lw	a5,-20(s0)
ffffffe00020371c:	0017879b          	addiw	a5,a5,1
ffffffe000203720:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000203724:	fd842783          	lw	a5,-40(s0)
ffffffe000203728:	fff7879b          	addiw	a5,a5,-1
ffffffe00020372c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203730:	fd842783          	lw	a5,-40(s0)
ffffffe000203734:	0007879b          	sext.w	a5,a5
ffffffe000203738:	fcf04ae3          	bgtz	a5,ffffffe00020370c <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe00020373c:	fa644783          	lbu	a5,-90(s0)
ffffffe000203740:	0ff7f793          	zext.b	a5,a5
ffffffe000203744:	04078463          	beqz	a5,ffffffe00020378c <vprintfmt+0x4b8>
                    putch('0');
ffffffe000203748:	f5843783          	ld	a5,-168(s0)
ffffffe00020374c:	03000513          	li	a0,48
ffffffe000203750:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000203754:	f5043783          	ld	a5,-176(s0)
ffffffe000203758:	0007c783          	lbu	a5,0(a5)
ffffffe00020375c:	00078713          	mv	a4,a5
ffffffe000203760:	05800793          	li	a5,88
ffffffe000203764:	00f71663          	bne	a4,a5,ffffffe000203770 <vprintfmt+0x49c>
ffffffe000203768:	05800793          	li	a5,88
ffffffe00020376c:	0080006f          	j	ffffffe000203774 <vprintfmt+0x4a0>
ffffffe000203770:	07800793          	li	a5,120
ffffffe000203774:	f5843703          	ld	a4,-168(s0)
ffffffe000203778:	00078513          	mv	a0,a5
ffffffe00020377c:	000700e7          	jalr	a4
                    written += 2;
ffffffe000203780:	fec42783          	lw	a5,-20(s0)
ffffffe000203784:	0027879b          	addiw	a5,a5,2
ffffffe000203788:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe00020378c:	fdc42783          	lw	a5,-36(s0)
ffffffe000203790:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203794:	0280006f          	j	ffffffe0002037bc <vprintfmt+0x4e8>
                    putch('0');
ffffffe000203798:	f5843783          	ld	a5,-168(s0)
ffffffe00020379c:	03000513          	li	a0,48
ffffffe0002037a0:	000780e7          	jalr	a5
                    ++written;
ffffffe0002037a4:	fec42783          	lw	a5,-20(s0)
ffffffe0002037a8:	0017879b          	addiw	a5,a5,1
ffffffe0002037ac:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe0002037b0:	fd442783          	lw	a5,-44(s0)
ffffffe0002037b4:	0017879b          	addiw	a5,a5,1
ffffffe0002037b8:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002037bc:	f8c42703          	lw	a4,-116(s0)
ffffffe0002037c0:	fd442783          	lw	a5,-44(s0)
ffffffe0002037c4:	0007879b          	sext.w	a5,a5
ffffffe0002037c8:	fce7c8e3          	blt	a5,a4,ffffffe000203798 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe0002037cc:	fdc42783          	lw	a5,-36(s0)
ffffffe0002037d0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002037d4:	fcf42823          	sw	a5,-48(s0)
ffffffe0002037d8:	03c0006f          	j	ffffffe000203814 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe0002037dc:	fd042783          	lw	a5,-48(s0)
ffffffe0002037e0:	ff078793          	addi	a5,a5,-16
ffffffe0002037e4:	008787b3          	add	a5,a5,s0
ffffffe0002037e8:	f807c783          	lbu	a5,-128(a5)
ffffffe0002037ec:	0007871b          	sext.w	a4,a5
ffffffe0002037f0:	f5843783          	ld	a5,-168(s0)
ffffffe0002037f4:	00070513          	mv	a0,a4
ffffffe0002037f8:	000780e7          	jalr	a5
                    ++written;
ffffffe0002037fc:	fec42783          	lw	a5,-20(s0)
ffffffe000203800:	0017879b          	addiw	a5,a5,1
ffffffe000203804:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000203808:	fd042783          	lw	a5,-48(s0)
ffffffe00020380c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203810:	fcf42823          	sw	a5,-48(s0)
ffffffe000203814:	fd042783          	lw	a5,-48(s0)
ffffffe000203818:	0007879b          	sext.w	a5,a5
ffffffe00020381c:	fc07d0e3          	bgez	a5,ffffffe0002037dc <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe000203820:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000203824:	2700006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000203828:	f5043783          	ld	a5,-176(s0)
ffffffe00020382c:	0007c783          	lbu	a5,0(a5)
ffffffe000203830:	00078713          	mv	a4,a5
ffffffe000203834:	06400793          	li	a5,100
ffffffe000203838:	02f70663          	beq	a4,a5,ffffffe000203864 <vprintfmt+0x590>
ffffffe00020383c:	f5043783          	ld	a5,-176(s0)
ffffffe000203840:	0007c783          	lbu	a5,0(a5)
ffffffe000203844:	00078713          	mv	a4,a5
ffffffe000203848:	06900793          	li	a5,105
ffffffe00020384c:	00f70c63          	beq	a4,a5,ffffffe000203864 <vprintfmt+0x590>
ffffffe000203850:	f5043783          	ld	a5,-176(s0)
ffffffe000203854:	0007c783          	lbu	a5,0(a5)
ffffffe000203858:	00078713          	mv	a4,a5
ffffffe00020385c:	07500793          	li	a5,117
ffffffe000203860:	08f71063          	bne	a4,a5,ffffffe0002038e0 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000203864:	f8144783          	lbu	a5,-127(s0)
ffffffe000203868:	00078c63          	beqz	a5,ffffffe000203880 <vprintfmt+0x5ac>
ffffffe00020386c:	f4843783          	ld	a5,-184(s0)
ffffffe000203870:	00878713          	addi	a4,a5,8
ffffffe000203874:	f4e43423          	sd	a4,-184(s0)
ffffffe000203878:	0007b783          	ld	a5,0(a5)
ffffffe00020387c:	0140006f          	j	ffffffe000203890 <vprintfmt+0x5bc>
ffffffe000203880:	f4843783          	ld	a5,-184(s0)
ffffffe000203884:	00878713          	addi	a4,a5,8
ffffffe000203888:	f4e43423          	sd	a4,-184(s0)
ffffffe00020388c:	0007a783          	lw	a5,0(a5)
ffffffe000203890:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000203894:	fa843583          	ld	a1,-88(s0)
ffffffe000203898:	f5043783          	ld	a5,-176(s0)
ffffffe00020389c:	0007c783          	lbu	a5,0(a5)
ffffffe0002038a0:	0007871b          	sext.w	a4,a5
ffffffe0002038a4:	07500793          	li	a5,117
ffffffe0002038a8:	40f707b3          	sub	a5,a4,a5
ffffffe0002038ac:	00f037b3          	snez	a5,a5
ffffffe0002038b0:	0ff7f793          	zext.b	a5,a5
ffffffe0002038b4:	f8040713          	addi	a4,s0,-128
ffffffe0002038b8:	00070693          	mv	a3,a4
ffffffe0002038bc:	00078613          	mv	a2,a5
ffffffe0002038c0:	f5843503          	ld	a0,-168(s0)
ffffffe0002038c4:	f08ff0ef          	jal	ra,ffffffe000202fcc <print_dec_int>
ffffffe0002038c8:	00050793          	mv	a5,a0
ffffffe0002038cc:	fec42703          	lw	a4,-20(s0)
ffffffe0002038d0:	00f707bb          	addw	a5,a4,a5
ffffffe0002038d4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002038d8:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe0002038dc:	1b80006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe0002038e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002038e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002038e8:	00078713          	mv	a4,a5
ffffffe0002038ec:	06e00793          	li	a5,110
ffffffe0002038f0:	04f71c63          	bne	a4,a5,ffffffe000203948 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe0002038f4:	f8144783          	lbu	a5,-127(s0)
ffffffe0002038f8:	02078463          	beqz	a5,ffffffe000203920 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe0002038fc:	f4843783          	ld	a5,-184(s0)
ffffffe000203900:	00878713          	addi	a4,a5,8
ffffffe000203904:	f4e43423          	sd	a4,-184(s0)
ffffffe000203908:	0007b783          	ld	a5,0(a5)
ffffffe00020390c:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000203910:	fec42703          	lw	a4,-20(s0)
ffffffe000203914:	fb043783          	ld	a5,-80(s0)
ffffffe000203918:	00e7b023          	sd	a4,0(a5)
ffffffe00020391c:	0240006f          	j	ffffffe000203940 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000203920:	f4843783          	ld	a5,-184(s0)
ffffffe000203924:	00878713          	addi	a4,a5,8
ffffffe000203928:	f4e43423          	sd	a4,-184(s0)
ffffffe00020392c:	0007b783          	ld	a5,0(a5)
ffffffe000203930:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000203934:	fb843783          	ld	a5,-72(s0)
ffffffe000203938:	fec42703          	lw	a4,-20(s0)
ffffffe00020393c:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000203940:	f8040023          	sb	zero,-128(s0)
ffffffe000203944:	1500006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000203948:	f5043783          	ld	a5,-176(s0)
ffffffe00020394c:	0007c783          	lbu	a5,0(a5)
ffffffe000203950:	00078713          	mv	a4,a5
ffffffe000203954:	07300793          	li	a5,115
ffffffe000203958:	02f71e63          	bne	a4,a5,ffffffe000203994 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe00020395c:	f4843783          	ld	a5,-184(s0)
ffffffe000203960:	00878713          	addi	a4,a5,8
ffffffe000203964:	f4e43423          	sd	a4,-184(s0)
ffffffe000203968:	0007b783          	ld	a5,0(a5)
ffffffe00020396c:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000203970:	fc043583          	ld	a1,-64(s0)
ffffffe000203974:	f5843503          	ld	a0,-168(s0)
ffffffe000203978:	dccff0ef          	jal	ra,ffffffe000202f44 <puts_wo_nl>
ffffffe00020397c:	00050793          	mv	a5,a0
ffffffe000203980:	fec42703          	lw	a4,-20(s0)
ffffffe000203984:	00f707bb          	addw	a5,a4,a5
ffffffe000203988:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe00020398c:	f8040023          	sb	zero,-128(s0)
ffffffe000203990:	1040006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000203994:	f5043783          	ld	a5,-176(s0)
ffffffe000203998:	0007c783          	lbu	a5,0(a5)
ffffffe00020399c:	00078713          	mv	a4,a5
ffffffe0002039a0:	06300793          	li	a5,99
ffffffe0002039a4:	02f71e63          	bne	a4,a5,ffffffe0002039e0 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe0002039a8:	f4843783          	ld	a5,-184(s0)
ffffffe0002039ac:	00878713          	addi	a4,a5,8
ffffffe0002039b0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002039b4:	0007a783          	lw	a5,0(a5)
ffffffe0002039b8:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe0002039bc:	fcc42703          	lw	a4,-52(s0)
ffffffe0002039c0:	f5843783          	ld	a5,-168(s0)
ffffffe0002039c4:	00070513          	mv	a0,a4
ffffffe0002039c8:	000780e7          	jalr	a5
                ++written;
ffffffe0002039cc:	fec42783          	lw	a5,-20(s0)
ffffffe0002039d0:	0017879b          	addiw	a5,a5,1
ffffffe0002039d4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002039d8:	f8040023          	sb	zero,-128(s0)
ffffffe0002039dc:	0b80006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe0002039e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002039e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002039e8:	00078713          	mv	a4,a5
ffffffe0002039ec:	02500793          	li	a5,37
ffffffe0002039f0:	02f71263          	bne	a4,a5,ffffffe000203a14 <vprintfmt+0x740>
                putch('%');
ffffffe0002039f4:	f5843783          	ld	a5,-168(s0)
ffffffe0002039f8:	02500513          	li	a0,37
ffffffe0002039fc:	000780e7          	jalr	a5
                ++written;
ffffffe000203a00:	fec42783          	lw	a5,-20(s0)
ffffffe000203a04:	0017879b          	addiw	a5,a5,1
ffffffe000203a08:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203a0c:	f8040023          	sb	zero,-128(s0)
ffffffe000203a10:	0840006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000203a14:	f5043783          	ld	a5,-176(s0)
ffffffe000203a18:	0007c783          	lbu	a5,0(a5)
ffffffe000203a1c:	0007871b          	sext.w	a4,a5
ffffffe000203a20:	f5843783          	ld	a5,-168(s0)
ffffffe000203a24:	00070513          	mv	a0,a4
ffffffe000203a28:	000780e7          	jalr	a5
                ++written;
ffffffe000203a2c:	fec42783          	lw	a5,-20(s0)
ffffffe000203a30:	0017879b          	addiw	a5,a5,1
ffffffe000203a34:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203a38:	f8040023          	sb	zero,-128(s0)
ffffffe000203a3c:	0580006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000203a40:	f5043783          	ld	a5,-176(s0)
ffffffe000203a44:	0007c783          	lbu	a5,0(a5)
ffffffe000203a48:	00078713          	mv	a4,a5
ffffffe000203a4c:	02500793          	li	a5,37
ffffffe000203a50:	02f71063          	bne	a4,a5,ffffffe000203a70 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000203a54:	f8043023          	sd	zero,-128(s0)
ffffffe000203a58:	f8043423          	sd	zero,-120(s0)
ffffffe000203a5c:	00100793          	li	a5,1
ffffffe000203a60:	f8f40023          	sb	a5,-128(s0)
ffffffe000203a64:	fff00793          	li	a5,-1
ffffffe000203a68:	f8f42623          	sw	a5,-116(s0)
ffffffe000203a6c:	0280006f          	j	ffffffe000203a94 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000203a70:	f5043783          	ld	a5,-176(s0)
ffffffe000203a74:	0007c783          	lbu	a5,0(a5)
ffffffe000203a78:	0007871b          	sext.w	a4,a5
ffffffe000203a7c:	f5843783          	ld	a5,-168(s0)
ffffffe000203a80:	00070513          	mv	a0,a4
ffffffe000203a84:	000780e7          	jalr	a5
            ++written;
ffffffe000203a88:	fec42783          	lw	a5,-20(s0)
ffffffe000203a8c:	0017879b          	addiw	a5,a5,1
ffffffe000203a90:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000203a94:	f5043783          	ld	a5,-176(s0)
ffffffe000203a98:	00178793          	addi	a5,a5,1
ffffffe000203a9c:	f4f43823          	sd	a5,-176(s0)
ffffffe000203aa0:	f5043783          	ld	a5,-176(s0)
ffffffe000203aa4:	0007c783          	lbu	a5,0(a5)
ffffffe000203aa8:	84079ce3          	bnez	a5,ffffffe000203300 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000203aac:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203ab0:	00078513          	mv	a0,a5
ffffffe000203ab4:	0b813083          	ld	ra,184(sp)
ffffffe000203ab8:	0b013403          	ld	s0,176(sp)
ffffffe000203abc:	0c010113          	addi	sp,sp,192
ffffffe000203ac0:	00008067          	ret

ffffffe000203ac4 <printk>:

int printk(const char* s, ...) {
ffffffe000203ac4:	f9010113          	addi	sp,sp,-112
ffffffe000203ac8:	02113423          	sd	ra,40(sp)
ffffffe000203acc:	02813023          	sd	s0,32(sp)
ffffffe000203ad0:	03010413          	addi	s0,sp,48
ffffffe000203ad4:	fca43c23          	sd	a0,-40(s0)
ffffffe000203ad8:	00b43423          	sd	a1,8(s0)
ffffffe000203adc:	00c43823          	sd	a2,16(s0)
ffffffe000203ae0:	00d43c23          	sd	a3,24(s0)
ffffffe000203ae4:	02e43023          	sd	a4,32(s0)
ffffffe000203ae8:	02f43423          	sd	a5,40(s0)
ffffffe000203aec:	03043823          	sd	a6,48(s0)
ffffffe000203af0:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000203af4:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000203af8:	04040793          	addi	a5,s0,64
ffffffe000203afc:	fcf43823          	sd	a5,-48(s0)
ffffffe000203b00:	fd043783          	ld	a5,-48(s0)
ffffffe000203b04:	fc878793          	addi	a5,a5,-56
ffffffe000203b08:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000203b0c:	fe043783          	ld	a5,-32(s0)
ffffffe000203b10:	00078613          	mv	a2,a5
ffffffe000203b14:	fd843583          	ld	a1,-40(s0)
ffffffe000203b18:	fffff517          	auipc	a0,0xfffff
ffffffe000203b1c:	11850513          	addi	a0,a0,280 # ffffffe000202c30 <putc>
ffffffe000203b20:	fb4ff0ef          	jal	ra,ffffffe0002032d4 <vprintfmt>
ffffffe000203b24:	00050793          	mv	a5,a0
ffffffe000203b28:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000203b2c:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203b30:	00078513          	mv	a0,a5
ffffffe000203b34:	02813083          	ld	ra,40(sp)
ffffffe000203b38:	02013403          	ld	s0,32(sp)
ffffffe000203b3c:	07010113          	addi	sp,sp,112
ffffffe000203b40:	00008067          	ret

ffffffe000203b44 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000203b44:	fe010113          	addi	sp,sp,-32
ffffffe000203b48:	00813c23          	sd	s0,24(sp)
ffffffe000203b4c:	02010413          	addi	s0,sp,32
ffffffe000203b50:	00050793          	mv	a5,a0
ffffffe000203b54:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000203b58:	fec42783          	lw	a5,-20(s0)
ffffffe000203b5c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203b60:	0007879b          	sext.w	a5,a5
ffffffe000203b64:	02079713          	slli	a4,a5,0x20
ffffffe000203b68:	02075713          	srli	a4,a4,0x20
ffffffe000203b6c:	00005797          	auipc	a5,0x5
ffffffe000203b70:	4ac78793          	addi	a5,a5,1196 # ffffffe000209018 <seed>
ffffffe000203b74:	00e7b023          	sd	a4,0(a5)
}
ffffffe000203b78:	00000013          	nop
ffffffe000203b7c:	01813403          	ld	s0,24(sp)
ffffffe000203b80:	02010113          	addi	sp,sp,32
ffffffe000203b84:	00008067          	ret

ffffffe000203b88 <rand>:

int rand(void) {
ffffffe000203b88:	ff010113          	addi	sp,sp,-16
ffffffe000203b8c:	00813423          	sd	s0,8(sp)
ffffffe000203b90:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000203b94:	00005797          	auipc	a5,0x5
ffffffe000203b98:	48478793          	addi	a5,a5,1156 # ffffffe000209018 <seed>
ffffffe000203b9c:	0007b703          	ld	a4,0(a5)
ffffffe000203ba0:	00001797          	auipc	a5,0x1
ffffffe000203ba4:	c7878793          	addi	a5,a5,-904 # ffffffe000204818 <lowerxdigits.0+0x18>
ffffffe000203ba8:	0007b783          	ld	a5,0(a5)
ffffffe000203bac:	02f707b3          	mul	a5,a4,a5
ffffffe000203bb0:	00178713          	addi	a4,a5,1
ffffffe000203bb4:	00005797          	auipc	a5,0x5
ffffffe000203bb8:	46478793          	addi	a5,a5,1124 # ffffffe000209018 <seed>
ffffffe000203bbc:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000203bc0:	00005797          	auipc	a5,0x5
ffffffe000203bc4:	45878793          	addi	a5,a5,1112 # ffffffe000209018 <seed>
ffffffe000203bc8:	0007b783          	ld	a5,0(a5)
ffffffe000203bcc:	0217d793          	srli	a5,a5,0x21
ffffffe000203bd0:	0007879b          	sext.w	a5,a5
}
ffffffe000203bd4:	00078513          	mv	a0,a5
ffffffe000203bd8:	00813403          	ld	s0,8(sp)
ffffffe000203bdc:	01010113          	addi	sp,sp,16
ffffffe000203be0:	00008067          	ret

ffffffe000203be4 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000203be4:	fc010113          	addi	sp,sp,-64
ffffffe000203be8:	02813c23          	sd	s0,56(sp)
ffffffe000203bec:	04010413          	addi	s0,sp,64
ffffffe000203bf0:	fca43c23          	sd	a0,-40(s0)
ffffffe000203bf4:	00058793          	mv	a5,a1
ffffffe000203bf8:	fcc43423          	sd	a2,-56(s0)
ffffffe000203bfc:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000203c00:	fd843783          	ld	a5,-40(s0)
ffffffe000203c04:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203c08:	fe043423          	sd	zero,-24(s0)
ffffffe000203c0c:	0280006f          	j	ffffffe000203c34 <memset+0x50>
        s[i] = c;
ffffffe000203c10:	fe043703          	ld	a4,-32(s0)
ffffffe000203c14:	fe843783          	ld	a5,-24(s0)
ffffffe000203c18:	00f707b3          	add	a5,a4,a5
ffffffe000203c1c:	fd442703          	lw	a4,-44(s0)
ffffffe000203c20:	0ff77713          	zext.b	a4,a4
ffffffe000203c24:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203c28:	fe843783          	ld	a5,-24(s0)
ffffffe000203c2c:	00178793          	addi	a5,a5,1
ffffffe000203c30:	fef43423          	sd	a5,-24(s0)
ffffffe000203c34:	fe843703          	ld	a4,-24(s0)
ffffffe000203c38:	fc843783          	ld	a5,-56(s0)
ffffffe000203c3c:	fcf76ae3          	bltu	a4,a5,ffffffe000203c10 <memset+0x2c>
    }
    return dest;
ffffffe000203c40:	fd843783          	ld	a5,-40(s0)
}
ffffffe000203c44:	00078513          	mv	a0,a5
ffffffe000203c48:	03813403          	ld	s0,56(sp)
ffffffe000203c4c:	04010113          	addi	sp,sp,64
ffffffe000203c50:	00008067          	ret
