
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
ffffffe000200008:	60c020ef          	jal	ra,ffffffe000202614 <setup_vm>
    call relocate
ffffffe00020000c:	060000ef          	jal	ra,ffffffe00020006c <relocate>

    call mm_init
ffffffe000200010:	285000ef          	jal	ra,ffffffe000200a94 <mm_init>

    call setup_vm_final
ffffffe000200014:	72c020ef          	jal	ra,ffffffe000202740 <setup_vm_final>

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
ffffffe000200068:	2ed020ef          	jal	ra,ffffffe000202b54 <start_kernel>

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
ffffffe000200144:	65c010ef          	jal	ra,ffffffe0002017a0 <trap_handler>

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
ffffffe000200314:	400010ef          	jal	ra,ffffffe000201714 <sbi_set_timer>
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
ffffffe00020048c:	714030ef          	jal	ra,ffffffe000203ba0 <memset>

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
ffffffe00020056c:	514030ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200ab0:	7d1020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200ba4:	6dd020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200bfc:	685020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200c28:	659020ef          	jal	ra,ffffffe000203a80 <printk>
        __switch_to(prev, next);
ffffffe000200c2c:	fd843583          	ld	a1,-40(s0)
ffffffe000200c30:	fe843503          	ld	a0,-24(s0)
ffffffe000200c34:	dbcff0ef          	jal	ra,ffffffe0002001f0 <__switch_to>
        printk("switch done\n");
ffffffe000200c38:	00003517          	auipc	a0,0x3
ffffffe000200c3c:	45850513          	addi	a0,a0,1112 # ffffffe000204090 <__func__.1+0x90>
ffffffe000200c40:	641020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200c88:	5f9020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200cc4:	5bd020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200d04:	57d020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200d94:	4ed020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200dec:	495020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200ef0:	391020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000200f64:	39d020ef          	jal	ra,ffffffe000203b00 <srand>

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
ffffffe000201010:	335020ef          	jal	ra,ffffffe000203b44 <rand>
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
ffffffe000201154:	08868693          	addi	a3,a3,136 # ffffffe0002041d8 <__func__.0>
ffffffe000201158:	12400613          	li	a2,292
ffffffe00020115c:	00003597          	auipc	a1,0x3
ffffffe000201160:	fcc58593          	addi	a1,a1,-52 # ffffffe000204128 <__func__.1+0x128>
ffffffe000201164:	00003517          	auipc	a0,0x3
ffffffe000201168:	fcc50513          	addi	a0,a0,-52 # ffffffe000204130 <__func__.1+0x130>
ffffffe00020116c:	115020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe0002011b4:	02868693          	addi	a3,a3,40 # ffffffe0002041d8 <__func__.0>
ffffffe0002011b8:	12900613          	li	a2,297
ffffffe0002011bc:	00003597          	auipc	a1,0x3
ffffffe0002011c0:	f6c58593          	addi	a1,a1,-148 # ffffffe000204128 <__func__.1+0x128>
ffffffe0002011c4:	00003517          	auipc	a0,0x3
ffffffe0002011c8:	fac50513          	addi	a0,a0,-84 # ffffffe000204170 <__func__.1+0x170>
ffffffe0002011cc:	0b5020ef          	jal	ra,ffffffe000203a80 <printk>
                
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
ffffffe000201214:	06d020ef          	jal	ra,ffffffe000203a80 <printk>
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
ffffffe000201398:	fb010113          	addi	sp,sp,-80
ffffffe00020139c:	04113423          	sd	ra,72(sp)
ffffffe0002013a0:	04813023          	sd	s0,64(sp)
ffffffe0002013a4:	05010413          	addi	s0,sp,80
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
ffffffe0002013d4:	0dc0006f          	j	ffffffe0002014b0 <load_program+0x118>
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
ffffffe00020140c:	08f71c63          	bne	a4,a5,ffffffe0002014a4 <load_program+0x10c>
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
            do_mmap(&(task->mm), phdr->p_paddr, phdr->p_memsz, phdr->p_offset, phdr->p_filesz, perm);
ffffffe000201474:	fb843783          	ld	a5,-72(s0)
ffffffe000201478:	0b078513          	addi	a0,a5,176
ffffffe00020147c:	fd043783          	ld	a5,-48(s0)
ffffffe000201480:	0187b583          	ld	a1,24(a5)
ffffffe000201484:	fd043783          	ld	a5,-48(s0)
ffffffe000201488:	0287b603          	ld	a2,40(a5)
ffffffe00020148c:	fd043783          	ld	a5,-48(s0)
ffffffe000201490:	0087b683          	ld	a3,8(a5)
ffffffe000201494:	fd043783          	ld	a5,-48(s0)
ffffffe000201498:	0207b703          	ld	a4,32(a5)
ffffffe00020149c:	fc843783          	ld	a5,-56(s0)
ffffffe0002014a0:	e01ff0ef          	jal	ra,ffffffe0002012a0 <do_mmap>
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe0002014a4:	fec42783          	lw	a5,-20(s0)
ffffffe0002014a8:	0017879b          	addiw	a5,a5,1
ffffffe0002014ac:	fef42623          	sw	a5,-20(s0)
ffffffe0002014b0:	fe043783          	ld	a5,-32(s0)
ffffffe0002014b4:	0387d783          	lhu	a5,56(a5)
ffffffe0002014b8:	0007871b          	sext.w	a4,a5
ffffffe0002014bc:	fec42783          	lw	a5,-20(s0)
ffffffe0002014c0:	0007879b          	sext.w	a5,a5
ffffffe0002014c4:	f0e7cae3          	blt	a5,a4,ffffffe0002013d8 <load_program+0x40>
        }
    }
    do_mmap(&(task->mm), USER_END - PGSIZE, PGSIZE, 0, PGSIZE, VM_READ | VM_ANON | VM_WRITE);
ffffffe0002014c8:	fb843783          	ld	a5,-72(s0)
ffffffe0002014cc:	0b078513          	addi	a0,a5,176
ffffffe0002014d0:	00700793          	li	a5,7
ffffffe0002014d4:	00001737          	lui	a4,0x1
ffffffe0002014d8:	00000693          	li	a3,0
ffffffe0002014dc:	00001637          	lui	a2,0x1
ffffffe0002014e0:	040005b7          	lui	a1,0x4000
ffffffe0002014e4:	fff58593          	addi	a1,a1,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe0002014e8:	00c59593          	slli	a1,a1,0xc
ffffffe0002014ec:	db5ff0ef          	jal	ra,ffffffe0002012a0 <do_mmap>
    task->thread.sepc = ehdr->e_entry;
ffffffe0002014f0:	fe043783          	ld	a5,-32(s0)
ffffffe0002014f4:	0187b703          	ld	a4,24(a5)
ffffffe0002014f8:	fb843783          	ld	a5,-72(s0)
ffffffe0002014fc:	08e7b823          	sd	a4,144(a5)
}
ffffffe000201500:	00000013          	nop
ffffffe000201504:	04813083          	ld	ra,72(sp)
ffffffe000201508:	04013403          	ld	s0,64(sp)
ffffffe00020150c:	05010113          	addi	sp,sp,80
ffffffe000201510:	00008067          	ret

ffffffe000201514 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000201514:	f8010113          	addi	sp,sp,-128
ffffffe000201518:	06813c23          	sd	s0,120(sp)
ffffffe00020151c:	06913823          	sd	s1,112(sp)
ffffffe000201520:	07213423          	sd	s2,104(sp)
ffffffe000201524:	07313023          	sd	s3,96(sp)
ffffffe000201528:	08010413          	addi	s0,sp,128
ffffffe00020152c:	faa43c23          	sd	a0,-72(s0)
ffffffe000201530:	fab43823          	sd	a1,-80(s0)
ffffffe000201534:	fac43423          	sd	a2,-88(s0)
ffffffe000201538:	fad43023          	sd	a3,-96(s0)
ffffffe00020153c:	f8e43c23          	sd	a4,-104(s0)
ffffffe000201540:	f8f43823          	sd	a5,-112(s0)
ffffffe000201544:	f9043423          	sd	a6,-120(s0)
ffffffe000201548:	f9143023          	sd	a7,-128(s0)
    
    struct sbiret sbiRet;

    asm volatile (
ffffffe00020154c:	fb843e03          	ld	t3,-72(s0)
ffffffe000201550:	fb043e83          	ld	t4,-80(s0)
ffffffe000201554:	fa843f03          	ld	t5,-88(s0)
ffffffe000201558:	fa043f83          	ld	t6,-96(s0)
ffffffe00020155c:	f9843283          	ld	t0,-104(s0)
ffffffe000201560:	f9043483          	ld	s1,-112(s0)
ffffffe000201564:	f8843903          	ld	s2,-120(s0)
ffffffe000201568:	f8043983          	ld	s3,-128(s0)
ffffffe00020156c:	01c008b3          	add	a7,zero,t3
ffffffe000201570:	01d00833          	add	a6,zero,t4
ffffffe000201574:	01e00533          	add	a0,zero,t5
ffffffe000201578:	01f005b3          	add	a1,zero,t6
ffffffe00020157c:	00500633          	add	a2,zero,t0
ffffffe000201580:	009006b3          	add	a3,zero,s1
ffffffe000201584:	01200733          	add	a4,zero,s2
ffffffe000201588:	013007b3          	add	a5,zero,s3
ffffffe00020158c:	00000073          	ecall
ffffffe000201590:	00050e93          	mv	t4,a0
ffffffe000201594:	00058e13          	mv	t3,a1
ffffffe000201598:	fdd43023          	sd	t4,-64(s0)
ffffffe00020159c:	fdc43423          	sd	t3,-56(s0)
        : "=r"(sbiRet.error), "=r"(sbiRet.value)
        : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );

    return sbiRet;
ffffffe0002015a0:	fc043783          	ld	a5,-64(s0)
ffffffe0002015a4:	fcf43823          	sd	a5,-48(s0)
ffffffe0002015a8:	fc843783          	ld	a5,-56(s0)
ffffffe0002015ac:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002015b0:	fd043703          	ld	a4,-48(s0)
ffffffe0002015b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002015b8:	00070313          	mv	t1,a4
ffffffe0002015bc:	00078393          	mv	t2,a5
ffffffe0002015c0:	00030713          	mv	a4,t1
ffffffe0002015c4:	00038793          	mv	a5,t2
}
ffffffe0002015c8:	00070513          	mv	a0,a4
ffffffe0002015cc:	00078593          	mv	a1,a5
ffffffe0002015d0:	07813403          	ld	s0,120(sp)
ffffffe0002015d4:	07013483          	ld	s1,112(sp)
ffffffe0002015d8:	06813903          	ld	s2,104(sp)
ffffffe0002015dc:	06013983          	ld	s3,96(sp)
ffffffe0002015e0:	08010113          	addi	sp,sp,128
ffffffe0002015e4:	00008067          	ret

ffffffe0002015e8 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe0002015e8:	fc010113          	addi	sp,sp,-64
ffffffe0002015ec:	02113c23          	sd	ra,56(sp)
ffffffe0002015f0:	02813823          	sd	s0,48(sp)
ffffffe0002015f4:	03213423          	sd	s2,40(sp)
ffffffe0002015f8:	03313023          	sd	s3,32(sp)
ffffffe0002015fc:	04010413          	addi	s0,sp,64
ffffffe000201600:	00050793          	mv	a5,a0
ffffffe000201604:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
ffffffe000201608:	fcf44603          	lbu	a2,-49(s0)
ffffffe00020160c:	00000893          	li	a7,0
ffffffe000201610:	00000813          	li	a6,0
ffffffe000201614:	00000793          	li	a5,0
ffffffe000201618:	00000713          	li	a4,0
ffffffe00020161c:	00000693          	li	a3,0
ffffffe000201620:	00200593          	li	a1,2
ffffffe000201624:	44424537          	lui	a0,0x44424
ffffffe000201628:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe00020162c:	ee9ff0ef          	jal	ra,ffffffe000201514 <sbi_ecall>
ffffffe000201630:	00050713          	mv	a4,a0
ffffffe000201634:	00058793          	mv	a5,a1
ffffffe000201638:	fce43823          	sd	a4,-48(s0)
ffffffe00020163c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201640:	fd043703          	ld	a4,-48(s0)
ffffffe000201644:	fd843783          	ld	a5,-40(s0)
ffffffe000201648:	00070913          	mv	s2,a4
ffffffe00020164c:	00078993          	mv	s3,a5
ffffffe000201650:	00090713          	mv	a4,s2
ffffffe000201654:	00098793          	mv	a5,s3
}
ffffffe000201658:	00070513          	mv	a0,a4
ffffffe00020165c:	00078593          	mv	a1,a5
ffffffe000201660:	03813083          	ld	ra,56(sp)
ffffffe000201664:	03013403          	ld	s0,48(sp)
ffffffe000201668:	02813903          	ld	s2,40(sp)
ffffffe00020166c:	02013983          	ld	s3,32(sp)
ffffffe000201670:	04010113          	addi	sp,sp,64
ffffffe000201674:	00008067          	ret

ffffffe000201678 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000201678:	fc010113          	addi	sp,sp,-64
ffffffe00020167c:	02113c23          	sd	ra,56(sp)
ffffffe000201680:	02813823          	sd	s0,48(sp)
ffffffe000201684:	03213423          	sd	s2,40(sp)
ffffffe000201688:	03313023          	sd	s3,32(sp)
ffffffe00020168c:	04010413          	addi	s0,sp,64
ffffffe000201690:	00050793          	mv	a5,a0
ffffffe000201694:	00058713          	mv	a4,a1
ffffffe000201698:	fcf42623          	sw	a5,-52(s0)
ffffffe00020169c:	00070793          	mv	a5,a4
ffffffe0002016a0:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe0002016a4:	fcc46603          	lwu	a2,-52(s0)
ffffffe0002016a8:	fc846683          	lwu	a3,-56(s0)
ffffffe0002016ac:	00000893          	li	a7,0
ffffffe0002016b0:	00000813          	li	a6,0
ffffffe0002016b4:	00000793          	li	a5,0
ffffffe0002016b8:	00000713          	li	a4,0
ffffffe0002016bc:	00000593          	li	a1,0
ffffffe0002016c0:	53525537          	lui	a0,0x53525
ffffffe0002016c4:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe0002016c8:	e4dff0ef          	jal	ra,ffffffe000201514 <sbi_ecall>
ffffffe0002016cc:	00050713          	mv	a4,a0
ffffffe0002016d0:	00058793          	mv	a5,a1
ffffffe0002016d4:	fce43823          	sd	a4,-48(s0)
ffffffe0002016d8:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002016dc:	fd043703          	ld	a4,-48(s0)
ffffffe0002016e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002016e4:	00070913          	mv	s2,a4
ffffffe0002016e8:	00078993          	mv	s3,a5
ffffffe0002016ec:	00090713          	mv	a4,s2
ffffffe0002016f0:	00098793          	mv	a5,s3
}
ffffffe0002016f4:	00070513          	mv	a0,a4
ffffffe0002016f8:	00078593          	mv	a1,a5
ffffffe0002016fc:	03813083          	ld	ra,56(sp)
ffffffe000201700:	03013403          	ld	s0,48(sp)
ffffffe000201704:	02813903          	ld	s2,40(sp)
ffffffe000201708:	02013983          	ld	s3,32(sp)
ffffffe00020170c:	04010113          	addi	sp,sp,64
ffffffe000201710:	00008067          	ret

ffffffe000201714 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe000201714:	fc010113          	addi	sp,sp,-64
ffffffe000201718:	02113c23          	sd	ra,56(sp)
ffffffe00020171c:	02813823          	sd	s0,48(sp)
ffffffe000201720:	03213423          	sd	s2,40(sp)
ffffffe000201724:	03313023          	sd	s3,32(sp)
ffffffe000201728:	04010413          	addi	s0,sp,64
ffffffe00020172c:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
ffffffe000201730:	00000893          	li	a7,0
ffffffe000201734:	00000813          	li	a6,0
ffffffe000201738:	00000793          	li	a5,0
ffffffe00020173c:	00000713          	li	a4,0
ffffffe000201740:	00000693          	li	a3,0
ffffffe000201744:	fc843603          	ld	a2,-56(s0)
ffffffe000201748:	00000593          	li	a1,0
ffffffe00020174c:	54495537          	lui	a0,0x54495
ffffffe000201750:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000201754:	dc1ff0ef          	jal	ra,ffffffe000201514 <sbi_ecall>
ffffffe000201758:	00050713          	mv	a4,a0
ffffffe00020175c:	00058793          	mv	a5,a1
ffffffe000201760:	fce43823          	sd	a4,-48(s0)
ffffffe000201764:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201768:	fd043703          	ld	a4,-48(s0)
ffffffe00020176c:	fd843783          	ld	a5,-40(s0)
ffffffe000201770:	00070913          	mv	s2,a4
ffffffe000201774:	00078993          	mv	s3,a5
ffffffe000201778:	00090713          	mv	a4,s2
ffffffe00020177c:	00098793          	mv	a5,s3
ffffffe000201780:	00070513          	mv	a0,a4
ffffffe000201784:	00078593          	mv	a1,a5
ffffffe000201788:	03813083          	ld	ra,56(sp)
ffffffe00020178c:	03013403          	ld	s0,48(sp)
ffffffe000201790:	02813903          	ld	s2,40(sp)
ffffffe000201794:	02013983          	ld	s3,32(sp)
ffffffe000201798:	04010113          	addi	sp,sp,64
ffffffe00020179c:	00008067          	ret

ffffffe0002017a0 <trap_handler>:
extern char _sramdisk[], _eramdisk[];
extern uint64_t nr_tasks;
extern struct task_struct *task[];
extern void __ret_from_fork();
extern uint64_t swapper_pg_dir[];
void trap_handler(uint64_t scause, uint64_t sepc, uint64_t sstatus, struct pt_regs *regs) {
ffffffe0002017a0:	f9010113          	addi	sp,sp,-112
ffffffe0002017a4:	06113423          	sd	ra,104(sp)
ffffffe0002017a8:	06813023          	sd	s0,96(sp)
ffffffe0002017ac:	07010413          	addi	s0,sp,112
ffffffe0002017b0:	faa43423          	sd	a0,-88(s0)
ffffffe0002017b4:	fab43023          	sd	a1,-96(s0)
ffffffe0002017b8:	f8c43c23          	sd	a2,-104(s0)
ffffffe0002017bc:	f8d43823          	sd	a3,-112(s0)
    // 通过 `scause` 判断 trap 类型
    uint64_t _stvac = csr_read(stval);
ffffffe0002017c0:	143027f3          	csrr	a5,stval
ffffffe0002017c4:	fef43423          	sd	a5,-24(s0)
ffffffe0002017c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002017cc:	fef43023          	sd	a5,-32(s0)
    LogPURPLE("scause: 0x%llx, sstatus: 0x%llx, sepc: 0x%llx, stvac: 0x%llx", scause, sstatus, sepc, _stvac);
ffffffe0002017d0:	fe043883          	ld	a7,-32(s0)
ffffffe0002017d4:	fa043803          	ld	a6,-96(s0)
ffffffe0002017d8:	f9843783          	ld	a5,-104(s0)
ffffffe0002017dc:	fa843703          	ld	a4,-88(s0)
ffffffe0002017e0:	00003697          	auipc	a3,0x3
ffffffe0002017e4:	d9068693          	addi	a3,a3,-624 # ffffffe000204570 <__func__.2>
ffffffe0002017e8:	01200613          	li	a2,18
ffffffe0002017ec:	00003597          	auipc	a1,0x3
ffffffe0002017f0:	9fc58593          	addi	a1,a1,-1540 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe0002017f4:	00003517          	auipc	a0,0x3
ffffffe0002017f8:	9fc50513          	addi	a0,a0,-1540 # ffffffe0002041f0 <__func__.0+0x18>
ffffffe0002017fc:	284020ef          	jal	ra,ffffffe000203a80 <printk>
    // if (scause == 0x1) Err("_*stvac = 0x%llx", *(uint64_t*)_stvac);
    if(scause == 0x8000000000000005){
ffffffe000201800:	fa843703          	ld	a4,-88(s0)
ffffffe000201804:	fff00793          	li	a5,-1
ffffffe000201808:	03f79793          	slli	a5,a5,0x3f
ffffffe00020180c:	00578793          	addi	a5,a5,5
ffffffe000201810:	02f71863          	bne	a4,a5,ffffffe000201840 <trap_handler+0xa0>
        LogRED("Timer Interrupt");
ffffffe000201814:	00003697          	auipc	a3,0x3
ffffffe000201818:	d5c68693          	addi	a3,a3,-676 # ffffffe000204570 <__func__.2>
ffffffe00020181c:	01500613          	li	a2,21
ffffffe000201820:	00003597          	auipc	a1,0x3
ffffffe000201824:	9c858593          	addi	a1,a1,-1592 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201828:	00003517          	auipc	a0,0x3
ffffffe00020182c:	a2050513          	addi	a0,a0,-1504 # ffffffe000204248 <__func__.0+0x70>
ffffffe000201830:	250020ef          	jal	ra,ffffffe000203a80 <printk>
        clock_set_next_event();
ffffffe000201834:	ab1fe0ef          	jal	ra,ffffffe0002002e4 <clock_set_next_event>
        do_timer();
ffffffe000201838:	c24ff0ef          	jal	ra,ffffffe000200c5c <do_timer>
ffffffe00020183c:	1840006f          	j	ffffffe0002019c0 <trap_handler+0x220>
    }else if(scause == 0xc){
ffffffe000201840:	fa843703          	ld	a4,-88(s0)
ffffffe000201844:	00c00793          	li	a5,12
ffffffe000201848:	0af71a63          	bne	a4,a5,ffffffe0002018fc <trap_handler+0x15c>
        LogRED("Instruction Page Fault");
ffffffe00020184c:	00003697          	auipc	a3,0x3
ffffffe000201850:	d2468693          	addi	a3,a3,-732 # ffffffe000204570 <__func__.2>
ffffffe000201854:	01900613          	li	a2,25
ffffffe000201858:	00003597          	auipc	a1,0x3
ffffffe00020185c:	99058593          	addi	a1,a1,-1648 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201860:	00003517          	auipc	a0,0x3
ffffffe000201864:	a1050513          	addi	a0,a0,-1520 # ffffffe000204270 <__func__.0+0x98>
ffffffe000201868:	218020ef          	jal	ra,ffffffe000203a80 <printk>
        if(sepc < VM_START && sepc > USER_END){
ffffffe00020186c:	fa043703          	ld	a4,-96(s0)
ffffffe000201870:	fff00793          	li	a5,-1
ffffffe000201874:	02579793          	slli	a5,a5,0x25
ffffffe000201878:	06f77463          	bgeu	a4,a5,ffffffe0002018e0 <trap_handler+0x140>
ffffffe00020187c:	fa043703          	ld	a4,-96(s0)
ffffffe000201880:	00100793          	li	a5,1
ffffffe000201884:	02679793          	slli	a5,a5,0x26
ffffffe000201888:	04e7fc63          	bgeu	a5,a4,ffffffe0002018e0 <trap_handler+0x140>
            LogGREEN("[Physical Address: 0x%llx] -> [Virtual Address: 0x%llx]", sepc, sepc + 0xffffffdf80000000);
ffffffe00020188c:	fa043703          	ld	a4,-96(s0)
ffffffe000201890:	fbf00793          	li	a5,-65
ffffffe000201894:	01f79793          	slli	a5,a5,0x1f
ffffffe000201898:	00f707b3          	add	a5,a4,a5
ffffffe00020189c:	fa043703          	ld	a4,-96(s0)
ffffffe0002018a0:	00003697          	auipc	a3,0x3
ffffffe0002018a4:	cd068693          	addi	a3,a3,-816 # ffffffe000204570 <__func__.2>
ffffffe0002018a8:	01b00613          	li	a2,27
ffffffe0002018ac:	00003597          	auipc	a1,0x3
ffffffe0002018b0:	93c58593          	addi	a1,a1,-1732 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe0002018b4:	00003517          	auipc	a0,0x3
ffffffe0002018b8:	9ec50513          	addi	a0,a0,-1556 # ffffffe0002042a0 <__func__.0+0xc8>
ffffffe0002018bc:	1c4020ef          	jal	ra,ffffffe000203a80 <printk>
            csr_write(sepc, sepc + 0xffffffdf80000000);
ffffffe0002018c0:	fa043703          	ld	a4,-96(s0)
ffffffe0002018c4:	fbf00793          	li	a5,-65
ffffffe0002018c8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002018cc:	00f707b3          	add	a5,a4,a5
ffffffe0002018d0:	fcf43423          	sd	a5,-56(s0)
ffffffe0002018d4:	fc843783          	ld	a5,-56(s0)
ffffffe0002018d8:	14179073          	csrw	sepc,a5
            return;
ffffffe0002018dc:	1140006f          	j	ffffffe0002019f0 <trap_handler+0x250>
        }
        do_page_fault(regs);
ffffffe0002018e0:	f9043503          	ld	a0,-112(s0)
ffffffe0002018e4:	308000ef          	jal	ra,ffffffe000201bec <do_page_fault>
        csr_write(sepc, sepc);
ffffffe0002018e8:	fa043783          	ld	a5,-96(s0)
ffffffe0002018ec:	fcf43023          	sd	a5,-64(s0)
ffffffe0002018f0:	fc043783          	ld	a5,-64(s0)
ffffffe0002018f4:	14179073          	csrw	sepc,a5
        return;
ffffffe0002018f8:	0f80006f          	j	ffffffe0002019f0 <trap_handler+0x250>
    }else if(scause == 0xf){
ffffffe0002018fc:	fa843703          	ld	a4,-88(s0)
ffffffe000201900:	00f00793          	li	a5,15
ffffffe000201904:	04f71063          	bne	a4,a5,ffffffe000201944 <trap_handler+0x1a4>
        LogRED("Store/AMO Page Fault");
ffffffe000201908:	00003697          	auipc	a3,0x3
ffffffe00020190c:	c6868693          	addi	a3,a3,-920 # ffffffe000204570 <__func__.2>
ffffffe000201910:	02300613          	li	a2,35
ffffffe000201914:	00003597          	auipc	a1,0x3
ffffffe000201918:	8d458593          	addi	a1,a1,-1836 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe00020191c:	00003517          	auipc	a0,0x3
ffffffe000201920:	9d450513          	addi	a0,a0,-1580 # ffffffe0002042f0 <__func__.0+0x118>
ffffffe000201924:	15c020ef          	jal	ra,ffffffe000203a80 <printk>
        do_page_fault(regs);
ffffffe000201928:	f9043503          	ld	a0,-112(s0)
ffffffe00020192c:	2c0000ef          	jal	ra,ffffffe000201bec <do_page_fault>
        csr_write(sepc, sepc);
ffffffe000201930:	fa043783          	ld	a5,-96(s0)
ffffffe000201934:	fcf43823          	sd	a5,-48(s0)
ffffffe000201938:	fd043783          	ld	a5,-48(s0)
ffffffe00020193c:	14179073          	csrw	sepc,a5
        return;
ffffffe000201940:	0b00006f          	j	ffffffe0002019f0 <trap_handler+0x250>
    }else if(scause == 0xd){
ffffffe000201944:	fa843703          	ld	a4,-88(s0)
ffffffe000201948:	00d00793          	li	a5,13
ffffffe00020194c:	04f71063          	bne	a4,a5,ffffffe00020198c <trap_handler+0x1ec>
        LogRED("Load Page Fault");
ffffffe000201950:	00003697          	auipc	a3,0x3
ffffffe000201954:	c2068693          	addi	a3,a3,-992 # ffffffe000204570 <__func__.2>
ffffffe000201958:	02800613          	li	a2,40
ffffffe00020195c:	00003597          	auipc	a1,0x3
ffffffe000201960:	88c58593          	addi	a1,a1,-1908 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201964:	00003517          	auipc	a0,0x3
ffffffe000201968:	9bc50513          	addi	a0,a0,-1604 # ffffffe000204320 <__func__.0+0x148>
ffffffe00020196c:	114020ef          	jal	ra,ffffffe000203a80 <printk>
        do_page_fault(regs);
ffffffe000201970:	f9043503          	ld	a0,-112(s0)
ffffffe000201974:	278000ef          	jal	ra,ffffffe000201bec <do_page_fault>
        csr_write(sepc, sepc);
ffffffe000201978:	fa043783          	ld	a5,-96(s0)
ffffffe00020197c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201980:	fd843783          	ld	a5,-40(s0)
ffffffe000201984:	14179073          	csrw	sepc,a5
        return;
ffffffe000201988:	0680006f          	j	ffffffe0002019f0 <trap_handler+0x250>
    }else if(scause == 0x8){
ffffffe00020198c:	fa843703          	ld	a4,-88(s0)
ffffffe000201990:	00800793          	li	a5,8
ffffffe000201994:	02f71663          	bne	a4,a5,ffffffe0002019c0 <trap_handler+0x220>
        LogRED("Environment Call from U-mode");
ffffffe000201998:	00003697          	auipc	a3,0x3
ffffffe00020199c:	bd868693          	addi	a3,a3,-1064 # ffffffe000204570 <__func__.2>
ffffffe0002019a0:	02d00613          	li	a2,45
ffffffe0002019a4:	00003597          	auipc	a1,0x3
ffffffe0002019a8:	84458593          	addi	a1,a1,-1980 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe0002019ac:	00003517          	auipc	a0,0x3
ffffffe0002019b0:	99c50513          	addi	a0,a0,-1636 # ffffffe000204348 <__func__.0+0x170>
ffffffe0002019b4:	0cc020ef          	jal	ra,ffffffe000203a80 <printk>
        syscall(regs);
ffffffe0002019b8:	f9043503          	ld	a0,-112(s0)
ffffffe0002019bc:	07c000ef          	jal	ra,ffffffe000201a38 <syscall>
    }

    if (scause & 0x8000000000000000) {
ffffffe0002019c0:	fa843783          	ld	a5,-88(s0)
ffffffe0002019c4:	0007dc63          	bgez	a5,ffffffe0002019dc <trap_handler+0x23c>
        csr_write(sepc, sepc);
ffffffe0002019c8:	fa043783          	ld	a5,-96(s0)
ffffffe0002019cc:	faf43823          	sd	a5,-80(s0)
ffffffe0002019d0:	fb043783          	ld	a5,-80(s0)
ffffffe0002019d4:	14179073          	csrw	sepc,a5
ffffffe0002019d8:	0180006f          	j	ffffffe0002019f0 <trap_handler+0x250>
    } else {
        csr_write(sepc, sepc + 4);
ffffffe0002019dc:	fa043783          	ld	a5,-96(s0)
ffffffe0002019e0:	00478793          	addi	a5,a5,4
ffffffe0002019e4:	faf43c23          	sd	a5,-72(s0)
ffffffe0002019e8:	fb843783          	ld	a5,-72(s0)
ffffffe0002019ec:	14179073          	csrw	sepc,a5
    }
}
ffffffe0002019f0:	06813083          	ld	ra,104(sp)
ffffffe0002019f4:	06013403          	ld	s0,96(sp)
ffffffe0002019f8:	07010113          	addi	sp,sp,112
ffffffe0002019fc:	00008067          	ret

ffffffe000201a00 <csr_change>:


void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
ffffffe000201a00:	fc010113          	addi	sp,sp,-64
ffffffe000201a04:	02813c23          	sd	s0,56(sp)
ffffffe000201a08:	04010413          	addi	s0,sp,64
ffffffe000201a0c:	fca43c23          	sd	a0,-40(s0)
ffffffe000201a10:	fcb43823          	sd	a1,-48(s0)
ffffffe000201a14:	fcc43423          	sd	a2,-56(s0)
    csr_write(sscratch, value);
ffffffe000201a18:	fc843783          	ld	a5,-56(s0)
ffffffe000201a1c:	fef43423          	sd	a5,-24(s0)
ffffffe000201a20:	fe843783          	ld	a5,-24(s0)
ffffffe000201a24:	14079073          	csrw	sscratch,a5
}
ffffffe000201a28:	00000013          	nop
ffffffe000201a2c:	03813403          	ld	s0,56(sp)
ffffffe000201a30:	04010113          	addi	sp,sp,64
ffffffe000201a34:	00008067          	ret

ffffffe000201a38 <syscall>:

void syscall(struct pt_regs *regs) {
ffffffe000201a38:	fb010113          	addi	sp,sp,-80
ffffffe000201a3c:	04113423          	sd	ra,72(sp)
ffffffe000201a40:	04813023          	sd	s0,64(sp)
ffffffe000201a44:	05010413          	addi	s0,sp,80
ffffffe000201a48:	faa43c23          	sd	a0,-72(s0)
    uint64_t syscall_num = regs->x[17];
ffffffe000201a4c:	fb843783          	ld	a5,-72(s0)
ffffffe000201a50:	0887b783          	ld	a5,136(a5)
ffffffe000201a54:	fef43023          	sd	a5,-32(s0)
    if (syscall_num == (uint64_t)SYS_WRITE) {
ffffffe000201a58:	fe043703          	ld	a4,-32(s0)
ffffffe000201a5c:	04000793          	li	a5,64
ffffffe000201a60:	0af71463          	bne	a4,a5,ffffffe000201b08 <syscall+0xd0>
        uint64_t fd = regs->x[10];
ffffffe000201a64:	fb843783          	ld	a5,-72(s0)
ffffffe000201a68:	0507b783          	ld	a5,80(a5)
ffffffe000201a6c:	fcf43823          	sd	a5,-48(s0)
        uint64_t i = 0;
ffffffe000201a70:	fe043423          	sd	zero,-24(s0)
        if (fd == 1) {
ffffffe000201a74:	fd043703          	ld	a4,-48(s0)
ffffffe000201a78:	00100793          	li	a5,1
ffffffe000201a7c:	04f71c63          	bne	a4,a5,ffffffe000201ad4 <syscall+0x9c>
            char *buf = (char *)regs->x[11];
ffffffe000201a80:	fb843783          	ld	a5,-72(s0)
ffffffe000201a84:	0587b783          	ld	a5,88(a5)
ffffffe000201a88:	fcf43423          	sd	a5,-56(s0)
            for (i = 0; i < regs->x[12]; i++) {
ffffffe000201a8c:	fe043423          	sd	zero,-24(s0)
ffffffe000201a90:	0340006f          	j	ffffffe000201ac4 <syscall+0x8c>
                printk("%c", buf[i]);
ffffffe000201a94:	fc843703          	ld	a4,-56(s0)
ffffffe000201a98:	fe843783          	ld	a5,-24(s0)
ffffffe000201a9c:	00f707b3          	add	a5,a4,a5
ffffffe000201aa0:	0007c783          	lbu	a5,0(a5)
ffffffe000201aa4:	0007879b          	sext.w	a5,a5
ffffffe000201aa8:	00078593          	mv	a1,a5
ffffffe000201aac:	00003517          	auipc	a0,0x3
ffffffe000201ab0:	8d450513          	addi	a0,a0,-1836 # ffffffe000204380 <__func__.0+0x1a8>
ffffffe000201ab4:	7cd010ef          	jal	ra,ffffffe000203a80 <printk>
            for (i = 0; i < regs->x[12]; i++) {
ffffffe000201ab8:	fe843783          	ld	a5,-24(s0)
ffffffe000201abc:	00178793          	addi	a5,a5,1
ffffffe000201ac0:	fef43423          	sd	a5,-24(s0)
ffffffe000201ac4:	fb843783          	ld	a5,-72(s0)
ffffffe000201ac8:	0607b783          	ld	a5,96(a5)
ffffffe000201acc:	fe843703          	ld	a4,-24(s0)
ffffffe000201ad0:	fcf762e3          	bltu	a4,a5,ffffffe000201a94 <syscall+0x5c>
            }
        }
        regs->x[10] = i;
ffffffe000201ad4:	fb843783          	ld	a5,-72(s0)
ffffffe000201ad8:	fe843703          	ld	a4,-24(s0)
ffffffe000201adc:	04e7b823          	sd	a4,80(a5)
        LogDEEPGREEN("Write: %d", i);
ffffffe000201ae0:	fe843703          	ld	a4,-24(s0)
ffffffe000201ae4:	00002697          	auipc	a3,0x2
ffffffe000201ae8:	51c68693          	addi	a3,a3,1308 # ffffffe000204000 <__func__.1>
ffffffe000201aec:	04900613          	li	a2,73
ffffffe000201af0:	00002597          	auipc	a1,0x2
ffffffe000201af4:	6f858593          	addi	a1,a1,1784 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201af8:	00003517          	auipc	a0,0x3
ffffffe000201afc:	89050513          	addi	a0,a0,-1904 # ffffffe000204388 <__func__.0+0x1b0>
ffffffe000201b00:	781010ef          	jal	ra,ffffffe000203a80 <printk>
        uint64_t pid = do_fork(regs);
        LogYELLOW("[FORK] Parent PID = %d, Child PID = %d", current->pid, pid);
    } else {
        LogRED("Unsupported syscall: %d", syscall_num);
    }
    return;
ffffffe000201b04:	0d80006f          	j	ffffffe000201bdc <syscall+0x1a4>
    } else if (syscall_num == (uint64_t)SYS_GETPID) {
ffffffe000201b08:	fe043703          	ld	a4,-32(s0)
ffffffe000201b0c:	0ac00793          	li	a5,172
ffffffe000201b10:	04f71a63          	bne	a4,a5,ffffffe000201b64 <syscall+0x12c>
        regs->x[10] = current->pid;
ffffffe000201b14:	00007797          	auipc	a5,0x7
ffffffe000201b18:	4fc78793          	addi	a5,a5,1276 # ffffffe000209010 <current>
ffffffe000201b1c:	0007b783          	ld	a5,0(a5)
ffffffe000201b20:	0187b703          	ld	a4,24(a5)
ffffffe000201b24:	fb843783          	ld	a5,-72(s0)
ffffffe000201b28:	04e7b823          	sd	a4,80(a5)
        LogDEEPGREEN("Getpid: %d", current->pid);
ffffffe000201b2c:	00007797          	auipc	a5,0x7
ffffffe000201b30:	4e478793          	addi	a5,a5,1252 # ffffffe000209010 <current>
ffffffe000201b34:	0007b783          	ld	a5,0(a5)
ffffffe000201b38:	0187b783          	ld	a5,24(a5)
ffffffe000201b3c:	00078713          	mv	a4,a5
ffffffe000201b40:	00002697          	auipc	a3,0x2
ffffffe000201b44:	4c068693          	addi	a3,a3,1216 # ffffffe000204000 <__func__.1>
ffffffe000201b48:	04c00613          	li	a2,76
ffffffe000201b4c:	00002597          	auipc	a1,0x2
ffffffe000201b50:	69c58593          	addi	a1,a1,1692 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201b54:	00003517          	auipc	a0,0x3
ffffffe000201b58:	85c50513          	addi	a0,a0,-1956 # ffffffe0002043b0 <__func__.0+0x1d8>
ffffffe000201b5c:	725010ef          	jal	ra,ffffffe000203a80 <printk>
    return;
ffffffe000201b60:	07c0006f          	j	ffffffe000201bdc <syscall+0x1a4>
    } else if (syscall_num == (uint64_t)SYS_CLONE){
ffffffe000201b64:	fe043703          	ld	a4,-32(s0)
ffffffe000201b68:	0dc00793          	li	a5,220
ffffffe000201b6c:	04f71463          	bne	a4,a5,ffffffe000201bb4 <syscall+0x17c>
        uint64_t pid = do_fork(regs);
ffffffe000201b70:	fb843503          	ld	a0,-72(s0)
ffffffe000201b74:	57c000ef          	jal	ra,ffffffe0002020f0 <do_fork>
ffffffe000201b78:	fca43c23          	sd	a0,-40(s0)
        LogYELLOW("[FORK] Parent PID = %d, Child PID = %d", current->pid, pid);
ffffffe000201b7c:	00007797          	auipc	a5,0x7
ffffffe000201b80:	49478793          	addi	a5,a5,1172 # ffffffe000209010 <current>
ffffffe000201b84:	0007b783          	ld	a5,0(a5)
ffffffe000201b88:	0187b703          	ld	a4,24(a5)
ffffffe000201b8c:	fd843783          	ld	a5,-40(s0)
ffffffe000201b90:	00002697          	auipc	a3,0x2
ffffffe000201b94:	47068693          	addi	a3,a3,1136 # ffffffe000204000 <__func__.1>
ffffffe000201b98:	04f00613          	li	a2,79
ffffffe000201b9c:	00002597          	auipc	a1,0x2
ffffffe000201ba0:	64c58593          	addi	a1,a1,1612 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201ba4:	00003517          	auipc	a0,0x3
ffffffe000201ba8:	83450513          	addi	a0,a0,-1996 # ffffffe0002043d8 <__func__.0+0x200>
ffffffe000201bac:	6d5010ef          	jal	ra,ffffffe000203a80 <printk>
    return;
ffffffe000201bb0:	02c0006f          	j	ffffffe000201bdc <syscall+0x1a4>
        LogRED("Unsupported syscall: %d", syscall_num);
ffffffe000201bb4:	fe043703          	ld	a4,-32(s0)
ffffffe000201bb8:	00002697          	auipc	a3,0x2
ffffffe000201bbc:	44868693          	addi	a3,a3,1096 # ffffffe000204000 <__func__.1>
ffffffe000201bc0:	05100613          	li	a2,81
ffffffe000201bc4:	00002597          	auipc	a1,0x2
ffffffe000201bc8:	62458593          	addi	a1,a1,1572 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201bcc:	00003517          	auipc	a0,0x3
ffffffe000201bd0:	84c50513          	addi	a0,a0,-1972 # ffffffe000204418 <__func__.0+0x240>
ffffffe000201bd4:	6ad010ef          	jal	ra,ffffffe000203a80 <printk>
    return;
ffffffe000201bd8:	00000013          	nop
}
ffffffe000201bdc:	04813083          	ld	ra,72(sp)
ffffffe000201be0:	04013403          	ld	s0,64(sp)
ffffffe000201be4:	05010113          	addi	sp,sp,80
ffffffe000201be8:	00008067          	ret

ffffffe000201bec <do_page_fault>:
// #define VM_READ 0x2
// #define VM_WRITE 0x4
// #define VM_EXEC 0x8


void do_page_fault(struct pt_regs *regs) {
ffffffe000201bec:	f3010113          	addi	sp,sp,-208
ffffffe000201bf0:	0c113423          	sd	ra,200(sp)
ffffffe000201bf4:	0c813023          	sd	s0,192(sp)
ffffffe000201bf8:	0d010413          	addi	s0,sp,208
ffffffe000201bfc:	f2a43c23          	sd	a0,-200(s0)
    uint64_t _stval = csr_read(stval);
ffffffe000201c00:	143027f3          	csrr	a5,stval
ffffffe000201c04:	fcf43423          	sd	a5,-56(s0)
ffffffe000201c08:	fc843783          	ld	a5,-56(s0)
ffffffe000201c0c:	fcf43023          	sd	a5,-64(s0)
    uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
ffffffe000201c10:	fc043703          	ld	a4,-64(s0)
ffffffe000201c14:	fffff7b7          	lui	a5,0xfffff
ffffffe000201c18:	00f777b3          	and	a5,a4,a5
ffffffe000201c1c:	faf43c23          	sd	a5,-72(s0)
    struct vm_area_struct *vma = find_vma(&current->mm, _stval);
ffffffe000201c20:	00007797          	auipc	a5,0x7
ffffffe000201c24:	3f078793          	addi	a5,a5,1008 # ffffffe000209010 <current>
ffffffe000201c28:	0007b783          	ld	a5,0(a5)
ffffffe000201c2c:	0b078793          	addi	a5,a5,176
ffffffe000201c30:	fc043583          	ld	a1,-64(s0)
ffffffe000201c34:	00078513          	mv	a0,a5
ffffffe000201c38:	df4ff0ef          	jal	ra,ffffffe00020122c <find_vma>
ffffffe000201c3c:	faa43823          	sd	a0,-80(s0)
    if (!vma){
ffffffe000201c40:	fb043783          	ld	a5,-80(s0)
ffffffe000201c44:	02079663          	bnez	a5,ffffffe000201c70 <do_page_fault+0x84>
        Err("No VMA found at 0x%llx", _stval);
ffffffe000201c48:	fc043703          	ld	a4,-64(s0)
ffffffe000201c4c:	00003697          	auipc	a3,0x3
ffffffe000201c50:	93468693          	addi	a3,a3,-1740 # ffffffe000204580 <__func__.0>
ffffffe000201c54:	06600613          	li	a2,102
ffffffe000201c58:	00002597          	auipc	a1,0x2
ffffffe000201c5c:	59058593          	addi	a1,a1,1424 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201c60:	00002517          	auipc	a0,0x2
ffffffe000201c64:	7e850513          	addi	a0,a0,2024 # ffffffe000204448 <__func__.0+0x270>
ffffffe000201c68:	619010ef          	jal	ra,ffffffe000203a80 <printk>
ffffffe000201c6c:	0000006f          	j	ffffffe000201c6c <do_page_fault+0x80>
        return;
    }

    uint64_t _scause = csr_read(scause);
ffffffe000201c70:	142027f3          	csrr	a5,scause
ffffffe000201c74:	faf43423          	sd	a5,-88(s0)
ffffffe000201c78:	fa843783          	ld	a5,-88(s0)
ffffffe000201c7c:	faf43023          	sd	a5,-96(s0)
    if ((_scause == 0xc && !(vma->vm_flags & VM_EXEC) ) || // Instruction Fault 但是不可以执行
ffffffe000201c80:	fa043703          	ld	a4,-96(s0)
ffffffe000201c84:	00c00793          	li	a5,12
ffffffe000201c88:	00f71a63          	bne	a4,a5,ffffffe000201c9c <do_page_fault+0xb0>
ffffffe000201c8c:	fb043783          	ld	a5,-80(s0)
ffffffe000201c90:	0287b783          	ld	a5,40(a5)
ffffffe000201c94:	0087f793          	andi	a5,a5,8
ffffffe000201c98:	02078e63          	beqz	a5,ffffffe000201cd4 <do_page_fault+0xe8>
ffffffe000201c9c:	fa043703          	ld	a4,-96(s0)
ffffffe000201ca0:	00d00793          	li	a5,13
ffffffe000201ca4:	00f71a63          	bne	a4,a5,ffffffe000201cb8 <do_page_fault+0xcc>
        (_scause == 0xd && !(vma->vm_flags & VM_READ)) || // Load Fault 但是不可以读
ffffffe000201ca8:	fb043783          	ld	a5,-80(s0)
ffffffe000201cac:	0287b783          	ld	a5,40(a5)
ffffffe000201cb0:	0027f793          	andi	a5,a5,2
ffffffe000201cb4:	02078063          	beqz	a5,ffffffe000201cd4 <do_page_fault+0xe8>
ffffffe000201cb8:	fa043703          	ld	a4,-96(s0)
ffffffe000201cbc:	00f00793          	li	a5,15
ffffffe000201cc0:	04f71e63          	bne	a4,a5,ffffffe000201d1c <do_page_fault+0x130>
        (_scause == 0xf && !(vma->vm_flags & VM_WRITE))){ // Store Fault 但是不可以写
ffffffe000201cc4:	fb043783          	ld	a5,-80(s0)
ffffffe000201cc8:	0287b783          	ld	a5,40(a5)
ffffffe000201ccc:	0047f793          	andi	a5,a5,4
ffffffe000201cd0:	04079663          	bnez	a5,ffffffe000201d1c <do_page_fault+0x130>
        LogDEEPGREEN("Permission Denied");
ffffffe000201cd4:	00003697          	auipc	a3,0x3
ffffffe000201cd8:	8ac68693          	addi	a3,a3,-1876 # ffffffe000204580 <__func__.0>
ffffffe000201cdc:	06e00613          	li	a2,110
ffffffe000201ce0:	00002597          	auipc	a1,0x2
ffffffe000201ce4:	50858593          	addi	a1,a1,1288 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201ce8:	00002517          	auipc	a0,0x2
ffffffe000201cec:	79050513          	addi	a0,a0,1936 # ffffffe000204478 <__func__.0+0x2a0>
ffffffe000201cf0:	591010ef          	jal	ra,ffffffe000203a80 <printk>
        Err("Permission Denied at 0x%llx", _stval);
ffffffe000201cf4:	fc043703          	ld	a4,-64(s0)
ffffffe000201cf8:	00003697          	auipc	a3,0x3
ffffffe000201cfc:	88868693          	addi	a3,a3,-1912 # ffffffe000204580 <__func__.0>
ffffffe000201d00:	06f00613          	li	a2,111
ffffffe000201d04:	00002597          	auipc	a1,0x2
ffffffe000201d08:	4e458593          	addi	a1,a1,1252 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201d0c:	00002517          	auipc	a0,0x2
ffffffe000201d10:	79c50513          	addi	a0,a0,1948 # ffffffe0002044a8 <__func__.0+0x2d0>
ffffffe000201d14:	56d010ef          	jal	ra,ffffffe000203a80 <printk>
ffffffe000201d18:	0000006f          	j	ffffffe000201d18 <do_page_fault+0x12c>
        return;
    }

    uint64_t perm = (vma->vm_flags & VM_READ) | (vma->vm_flags & VM_EXEC) | (vma->vm_flags & VM_WRITE) | PTE_U | PTE_V; 
ffffffe000201d1c:	fb043783          	ld	a5,-80(s0)
ffffffe000201d20:	0287b783          	ld	a5,40(a5)
ffffffe000201d24:	00e7f793          	andi	a5,a5,14
ffffffe000201d28:	0117e793          	ori	a5,a5,17
ffffffe000201d2c:	f8f43c23          	sd	a5,-104(s0)
    if (vma->vm_flags & VM_ANON){
ffffffe000201d30:	fb043783          	ld	a5,-80(s0)
ffffffe000201d34:	0287b783          	ld	a5,40(a5)
ffffffe000201d38:	0017f793          	andi	a5,a5,1
ffffffe000201d3c:	06078663          	beqz	a5,ffffffe000201da8 <do_page_fault+0x1bc>
        LogDEEPGREEN("ANON");
ffffffe000201d40:	00003697          	auipc	a3,0x3
ffffffe000201d44:	84068693          	addi	a3,a3,-1984 # ffffffe000204580 <__func__.0>
ffffffe000201d48:	07500613          	li	a2,117
ffffffe000201d4c:	00002597          	auipc	a1,0x2
ffffffe000201d50:	49c58593          	addi	a1,a1,1180 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201d54:	00002517          	auipc	a0,0x2
ffffffe000201d58:	78c50513          	addi	a0,a0,1932 # ffffffe0002044e0 <__func__.0+0x308>
ffffffe000201d5c:	525010ef          	jal	ra,ffffffe000203a80 <printk>
        // uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
        uint64_t pa = VA2PA((uint64_t)alloc_page());
ffffffe000201d60:	be9fe0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe000201d64:	00050793          	mv	a5,a0
ffffffe000201d68:	00078713          	mv	a4,a5
ffffffe000201d6c:	04100793          	li	a5,65
ffffffe000201d70:	01f79793          	slli	a5,a5,0x1f
ffffffe000201d74:	00f707b3          	add	a5,a4,a5
ffffffe000201d78:	f4f43423          	sd	a5,-184(s0)
        create_mapping(current->pgd, va, pa, PGSIZE, perm);
ffffffe000201d7c:	00007797          	auipc	a5,0x7
ffffffe000201d80:	29478793          	addi	a5,a5,660 # ffffffe000209010 <current>
ffffffe000201d84:	0007b783          	ld	a5,0(a5)
ffffffe000201d88:	0a87b783          	ld	a5,168(a5)
ffffffe000201d8c:	f9843703          	ld	a4,-104(s0)
ffffffe000201d90:	000016b7          	lui	a3,0x1
ffffffe000201d94:	f4843603          	ld	a2,-184(s0)
ffffffe000201d98:	fb843583          	ld	a1,-72(s0)
ffffffe000201d9c:	00078513          	mv	a0,a5
ffffffe000201da0:	365000ef          	jal	ra,ffffffe000202904 <create_mapping>
ffffffe000201da4:	33c0006f          	j	ffffffe0002020e0 <do_page_fault+0x4f4>
    }else{
        LogDEEPGREEN("FILE");
ffffffe000201da8:	00002697          	auipc	a3,0x2
ffffffe000201dac:	7d868693          	addi	a3,a3,2008 # ffffffe000204580 <__func__.0>
ffffffe000201db0:	07a00613          	li	a2,122
ffffffe000201db4:	00002597          	auipc	a1,0x2
ffffffe000201db8:	43458593          	addi	a1,a1,1076 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000201dbc:	00002517          	auipc	a0,0x2
ffffffe000201dc0:	74450513          	addi	a0,a0,1860 # ffffffe000204500 <__func__.0+0x328>
ffffffe000201dc4:	4bd010ef          	jal	ra,ffffffe000203a80 <printk>
        // uint64_t va = PGROUNDDOWN(_stval); 
        uint64_t *uapp = (uint64_t*)alloc_page();
ffffffe000201dc8:	b81fe0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe000201dcc:	00050793          	mv	a5,a0
ffffffe000201dd0:	f8f43823          	sd	a5,-112(s0)
        if (PGROUNDDOWN(vma->vm_filesz) < PGSIZE){ // 整个uapp小于一页
ffffffe000201dd4:	fb043783          	ld	a5,-80(s0)
ffffffe000201dd8:	0387b703          	ld	a4,56(a5)
ffffffe000201ddc:	fffff7b7          	lui	a5,0xfffff
ffffffe000201de0:	00f77733          	and	a4,a4,a5
ffffffe000201de4:	000017b7          	lui	a5,0x1
ffffffe000201de8:	08f77863          	bgeu	a4,a5,ffffffe000201e78 <do_page_fault+0x28c>
            char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
ffffffe000201dec:	fb043783          	ld	a5,-80(s0)
ffffffe000201df0:	0087b703          	ld	a4,8(a5) # 1008 <PGSIZE+0x8>
ffffffe000201df4:	000017b7          	lui	a5,0x1
ffffffe000201df8:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201dfc:	00f777b3          	and	a5,a4,a5
ffffffe000201e00:	f9043703          	ld	a4,-112(s0)
ffffffe000201e04:	00f707b3          	add	a5,a4,a5
ffffffe000201e08:	f4f43c23          	sd	a5,-168(s0)
            char *celf = (char*)_sramdisk + (vma->vm_start & 0xfff);
ffffffe000201e0c:	fb043783          	ld	a5,-80(s0)
ffffffe000201e10:	0087b703          	ld	a4,8(a5)
ffffffe000201e14:	000017b7          	lui	a5,0x1
ffffffe000201e18:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201e1c:	00f77733          	and	a4,a4,a5
ffffffe000201e20:	00004797          	auipc	a5,0x4
ffffffe000201e24:	1e078793          	addi	a5,a5,480 # ffffffe000206000 <_sramdisk>
ffffffe000201e28:	00f707b3          	add	a5,a4,a5
ffffffe000201e2c:	f4f43823          	sd	a5,-176(s0)
            for(uint64_t i = 0; i < vma->vm_filesz; i++) cuapp[i] = celf[i];
ffffffe000201e30:	fe043423          	sd	zero,-24(s0)
ffffffe000201e34:	0300006f          	j	ffffffe000201e64 <do_page_fault+0x278>
ffffffe000201e38:	f5043703          	ld	a4,-176(s0)
ffffffe000201e3c:	fe843783          	ld	a5,-24(s0)
ffffffe000201e40:	00f70733          	add	a4,a4,a5
ffffffe000201e44:	f5843683          	ld	a3,-168(s0)
ffffffe000201e48:	fe843783          	ld	a5,-24(s0)
ffffffe000201e4c:	00f687b3          	add	a5,a3,a5
ffffffe000201e50:	00074703          	lbu	a4,0(a4) # 1000 <PGSIZE>
ffffffe000201e54:	00e78023          	sb	a4,0(a5)
ffffffe000201e58:	fe843783          	ld	a5,-24(s0)
ffffffe000201e5c:	00178793          	addi	a5,a5,1
ffffffe000201e60:	fef43423          	sd	a5,-24(s0)
ffffffe000201e64:	fb043783          	ld	a5,-80(s0)
ffffffe000201e68:	0387b783          	ld	a5,56(a5)
ffffffe000201e6c:	fe843703          	ld	a4,-24(s0)
ffffffe000201e70:	fcf764e3          	bltu	a4,a5,ffffffe000201e38 <do_page_fault+0x24c>
ffffffe000201e74:	2380006f          	j	ffffffe0002020ac <do_page_fault+0x4c0>
        }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start)){ // 从头开始
ffffffe000201e78:	fb043783          	ld	a5,-80(s0)
ffffffe000201e7c:	0087b703          	ld	a4,8(a5)
ffffffe000201e80:	fb843783          	ld	a5,-72(s0)
ffffffe000201e84:	00f74733          	xor	a4,a4,a5
ffffffe000201e88:	fffff7b7          	lui	a5,0xfffff
ffffffe000201e8c:	00f777b3          	and	a5,a4,a5
ffffffe000201e90:	0a079063          	bnez	a5,ffffffe000201f30 <do_page_fault+0x344>
            char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
ffffffe000201e94:	fb043783          	ld	a5,-80(s0)
ffffffe000201e98:	0087b703          	ld	a4,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe000201e9c:	000017b7          	lui	a5,0x1
ffffffe000201ea0:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201ea4:	00f777b3          	and	a5,a4,a5
ffffffe000201ea8:	f9043703          	ld	a4,-112(s0)
ffffffe000201eac:	00f707b3          	add	a5,a4,a5
ffffffe000201eb0:	f6f43423          	sd	a5,-152(s0)
            char *celf = (char*)_sramdisk + (vma->vm_start & 0xfff);
ffffffe000201eb4:	fb043783          	ld	a5,-80(s0)
ffffffe000201eb8:	0087b703          	ld	a4,8(a5)
ffffffe000201ebc:	000017b7          	lui	a5,0x1
ffffffe000201ec0:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201ec4:	00f77733          	and	a4,a4,a5
ffffffe000201ec8:	00004797          	auipc	a5,0x4
ffffffe000201ecc:	13878793          	addi	a5,a5,312 # ffffffe000206000 <_sramdisk>
ffffffe000201ed0:	00f707b3          	add	a5,a4,a5
ffffffe000201ed4:	f6f43023          	sd	a5,-160(s0)
            int i;
            // LogBLUE("0x%llx", PGSIZE - vma->vm_start & 0x1ff);
            for(i = 0; i < (PGSIZE - vma->vm_start & 0xfff); i++) {
ffffffe000201ed8:	fe042223          	sw	zero,-28(s0)
ffffffe000201edc:	0300006f          	j	ffffffe000201f0c <do_page_fault+0x320>
                cuapp[i] = celf[i];
ffffffe000201ee0:	fe442783          	lw	a5,-28(s0)
ffffffe000201ee4:	f6043703          	ld	a4,-160(s0)
ffffffe000201ee8:	00f70733          	add	a4,a4,a5
ffffffe000201eec:	fe442783          	lw	a5,-28(s0)
ffffffe000201ef0:	f6843683          	ld	a3,-152(s0)
ffffffe000201ef4:	00f687b3          	add	a5,a3,a5
ffffffe000201ef8:	00074703          	lbu	a4,0(a4)
ffffffe000201efc:	00e78023          	sb	a4,0(a5)
            for(i = 0; i < (PGSIZE - vma->vm_start & 0xfff); i++) {
ffffffe000201f00:	fe442783          	lw	a5,-28(s0)
ffffffe000201f04:	0017879b          	addiw	a5,a5,1
ffffffe000201f08:	fef42223          	sw	a5,-28(s0)
ffffffe000201f0c:	fe442703          	lw	a4,-28(s0)
ffffffe000201f10:	fb043783          	ld	a5,-80(s0)
ffffffe000201f14:	0087b783          	ld	a5,8(a5)
ffffffe000201f18:	40f006b3          	neg	a3,a5
ffffffe000201f1c:	000017b7          	lui	a5,0x1
ffffffe000201f20:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201f24:	00f6f7b3          	and	a5,a3,a5
ffffffe000201f28:	faf76ce3          	bltu	a4,a5,ffffffe000201ee0 <do_page_fault+0x2f4>
ffffffe000201f2c:	1800006f          	j	ffffffe0002020ac <do_page_fault+0x4c0>
                //LogBLUE("[0x%llx] cuapp = 0x%llx, celf = 0x%llx", i, cuapp[i], celf[i]);
            }
            // LogBLUE("[0x%llx] cuapp = 0x%llx, celf = 0x%llx", i, cuapp[i], celf[i]);
        }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start + vma->vm_filesz - 1)){ // 最后一页
ffffffe000201f30:	fb043783          	ld	a5,-80(s0)
ffffffe000201f34:	0087b703          	ld	a4,8(a5)
ffffffe000201f38:	fb043783          	ld	a5,-80(s0)
ffffffe000201f3c:	0387b783          	ld	a5,56(a5)
ffffffe000201f40:	00f707b3          	add	a5,a4,a5
ffffffe000201f44:	fff78713          	addi	a4,a5,-1
ffffffe000201f48:	fb843783          	ld	a5,-72(s0)
ffffffe000201f4c:	00f74733          	xor	a4,a4,a5
ffffffe000201f50:	fffff7b7          	lui	a5,0xfffff
ffffffe000201f54:	00f777b3          	and	a5,a4,a5
ffffffe000201f58:	08079e63          	bnez	a5,ffffffe000201ff4 <do_page_fault+0x408>
            char *cuapp = (char*)uapp;
ffffffe000201f5c:	f9043783          	ld	a5,-112(s0)
ffffffe000201f60:	f6f43c23          	sd	a5,-136(s0)
            char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(va) - PGROUNDDOWN(vma->vm_start));
ffffffe000201f64:	fb843703          	ld	a4,-72(s0)
ffffffe000201f68:	fffff7b7          	lui	a5,0xfffff
ffffffe000201f6c:	00f77733          	and	a4,a4,a5
ffffffe000201f70:	fb043783          	ld	a5,-80(s0)
ffffffe000201f74:	0087b683          	ld	a3,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe000201f78:	fffff7b7          	lui	a5,0xfffff
ffffffe000201f7c:	00f6f7b3          	and	a5,a3,a5
ffffffe000201f80:	40f70733          	sub	a4,a4,a5
ffffffe000201f84:	00004797          	auipc	a5,0x4
ffffffe000201f88:	07c78793          	addi	a5,a5,124 # ffffffe000206000 <_sramdisk>
ffffffe000201f8c:	00f707b3          	add	a5,a4,a5
ffffffe000201f90:	f6f43823          	sd	a5,-144(s0)
            for(uint64_t i = 0; i <= ((vma->vm_start + vma->vm_filesz) & 0xfff); i++) cuapp[i] = celf[i];
ffffffe000201f94:	fc043c23          	sd	zero,-40(s0)
ffffffe000201f98:	0300006f          	j	ffffffe000201fc8 <do_page_fault+0x3dc>
ffffffe000201f9c:	f7043703          	ld	a4,-144(s0)
ffffffe000201fa0:	fd843783          	ld	a5,-40(s0)
ffffffe000201fa4:	00f70733          	add	a4,a4,a5
ffffffe000201fa8:	f7843683          	ld	a3,-136(s0)
ffffffe000201fac:	fd843783          	ld	a5,-40(s0)
ffffffe000201fb0:	00f687b3          	add	a5,a3,a5
ffffffe000201fb4:	00074703          	lbu	a4,0(a4)
ffffffe000201fb8:	00e78023          	sb	a4,0(a5)
ffffffe000201fbc:	fd843783          	ld	a5,-40(s0)
ffffffe000201fc0:	00178793          	addi	a5,a5,1
ffffffe000201fc4:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201fc8:	fb043783          	ld	a5,-80(s0)
ffffffe000201fcc:	0087b703          	ld	a4,8(a5)
ffffffe000201fd0:	fb043783          	ld	a5,-80(s0)
ffffffe000201fd4:	0387b783          	ld	a5,56(a5)
ffffffe000201fd8:	00f70733          	add	a4,a4,a5
ffffffe000201fdc:	000017b7          	lui	a5,0x1
ffffffe000201fe0:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201fe4:	00f777b3          	and	a5,a4,a5
ffffffe000201fe8:	fd843703          	ld	a4,-40(s0)
ffffffe000201fec:	fae7f8e3          	bgeu	a5,a4,ffffffe000201f9c <do_page_fault+0x3b0>
ffffffe000201ff0:	0bc0006f          	j	ffffffe0002020ac <do_page_fault+0x4c0>
            // ! 这里要考虑漏掉一个字节的情况
        }else{ // 中间或mem-
            LogBLUE("vm_start = 0x%llx, vm_end = 0x%llx, vm_filesz = 0x%llx", vma->vm_start, vma->vm_end, vma->vm_filesz);
ffffffe000201ff4:	fb043783          	ld	a5,-80(s0)
ffffffe000201ff8:	0087b703          	ld	a4,8(a5)
ffffffe000201ffc:	fb043783          	ld	a5,-80(s0)
ffffffe000202000:	0107b683          	ld	a3,16(a5)
ffffffe000202004:	fb043783          	ld	a5,-80(s0)
ffffffe000202008:	0387b783          	ld	a5,56(a5)
ffffffe00020200c:	00078813          	mv	a6,a5
ffffffe000202010:	00068793          	mv	a5,a3
ffffffe000202014:	00002697          	auipc	a3,0x2
ffffffe000202018:	56c68693          	addi	a3,a3,1388 # ffffffe000204580 <__func__.0>
ffffffe00020201c:	09100613          	li	a2,145
ffffffe000202020:	00002597          	auipc	a1,0x2
ffffffe000202024:	1c858593          	addi	a1,a1,456 # ffffffe0002041e8 <__func__.0+0x10>
ffffffe000202028:	00002517          	auipc	a0,0x2
ffffffe00020202c:	4f850513          	addi	a0,a0,1272 # ffffffe000204520 <__func__.0+0x348>
ffffffe000202030:	251010ef          	jal	ra,ffffffe000203a80 <printk>
            char *cuapp = (char*)uapp;
ffffffe000202034:	f9043783          	ld	a5,-112(s0)
ffffffe000202038:	f8f43423          	sd	a5,-120(s0)
            char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(va) - PGROUNDDOWN(vma->vm_start));
ffffffe00020203c:	fb843703          	ld	a4,-72(s0)
ffffffe000202040:	fffff7b7          	lui	a5,0xfffff
ffffffe000202044:	00f77733          	and	a4,a4,a5
ffffffe000202048:	fb043783          	ld	a5,-80(s0)
ffffffe00020204c:	0087b683          	ld	a3,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe000202050:	fffff7b7          	lui	a5,0xfffff
ffffffe000202054:	00f6f7b3          	and	a5,a3,a5
ffffffe000202058:	40f70733          	sub	a4,a4,a5
ffffffe00020205c:	00004797          	auipc	a5,0x4
ffffffe000202060:	fa478793          	addi	a5,a5,-92 # ffffffe000206000 <_sramdisk>
ffffffe000202064:	00f707b3          	add	a5,a4,a5
ffffffe000202068:	f8f43023          	sd	a5,-128(s0)
            for(uint64_t i = 0; i < PGSIZE; i++) cuapp[i] = celf[i];
ffffffe00020206c:	fc043823          	sd	zero,-48(s0)
ffffffe000202070:	0300006f          	j	ffffffe0002020a0 <do_page_fault+0x4b4>
ffffffe000202074:	f8043703          	ld	a4,-128(s0)
ffffffe000202078:	fd043783          	ld	a5,-48(s0)
ffffffe00020207c:	00f70733          	add	a4,a4,a5
ffffffe000202080:	f8843683          	ld	a3,-120(s0)
ffffffe000202084:	fd043783          	ld	a5,-48(s0)
ffffffe000202088:	00f687b3          	add	a5,a3,a5
ffffffe00020208c:	00074703          	lbu	a4,0(a4)
ffffffe000202090:	00e78023          	sb	a4,0(a5)
ffffffe000202094:	fd043783          	ld	a5,-48(s0)
ffffffe000202098:	00178793          	addi	a5,a5,1
ffffffe00020209c:	fcf43823          	sd	a5,-48(s0)
ffffffe0002020a0:	fd043703          	ld	a4,-48(s0)
ffffffe0002020a4:	000017b7          	lui	a5,0x1
ffffffe0002020a8:	fcf766e3          	bltu	a4,a5,ffffffe000202074 <do_page_fault+0x488>
        }

        create_mapping(current->pgd, va, VA2PA((uint64_t)uapp), PGSIZE, perm);
ffffffe0002020ac:	00007797          	auipc	a5,0x7
ffffffe0002020b0:	f6478793          	addi	a5,a5,-156 # ffffffe000209010 <current>
ffffffe0002020b4:	0007b783          	ld	a5,0(a5)
ffffffe0002020b8:	0a87b503          	ld	a0,168(a5)
ffffffe0002020bc:	f9043703          	ld	a4,-112(s0)
ffffffe0002020c0:	04100793          	li	a5,65
ffffffe0002020c4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002020c8:	00f707b3          	add	a5,a4,a5
ffffffe0002020cc:	f9843703          	ld	a4,-104(s0)
ffffffe0002020d0:	000016b7          	lui	a3,0x1
ffffffe0002020d4:	00078613          	mv	a2,a5
ffffffe0002020d8:	fb843583          	ld	a1,-72(s0)
ffffffe0002020dc:	029000ef          	jal	ra,ffffffe000202904 <create_mapping>
    }
}
ffffffe0002020e0:	0c813083          	ld	ra,200(sp)
ffffffe0002020e4:	0c013403          	ld	s0,192(sp)
ffffffe0002020e8:	0d010113          	addi	sp,sp,208
ffffffe0002020ec:	00008067          	ret

ffffffe0002020f0 <do_fork>:

uint64_t do_fork(struct pt_regs *regs){
ffffffe0002020f0:	f3010113          	addi	sp,sp,-208
ffffffe0002020f4:	0c113423          	sd	ra,200(sp)
ffffffe0002020f8:	0c813023          	sd	s0,192(sp)
ffffffe0002020fc:	0d010413          	addi	s0,sp,208
ffffffe000202100:	f2a43c23          	sd	a0,-200(s0)
    struct task_struct *ptask = (struct task_struct*)kalloc();
ffffffe000202104:	8b9fe0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe000202108:	00050793          	mv	a5,a0
ffffffe00020210c:	faf43c23          	sd	a5,-72(s0)
    // _sstatus |= (1 << 5);
    // _sstatus |= (1 << 18); 
    // ptask->thread.sstatus = _sstatus;

    // ptask->thread.sscratch = (uint64_t)USER_END;
    char *ccurrent_task = (char*)current;
ffffffe000202110:	00007797          	auipc	a5,0x7
ffffffe000202114:	f0078793          	addi	a5,a5,-256 # ffffffe000209010 <current>
ffffffe000202118:	0007b783          	ld	a5,0(a5)
ffffffe00020211c:	faf43823          	sd	a5,-80(s0)
    char *cptask = (char*)ptask;
ffffffe000202120:	fb843783          	ld	a5,-72(s0)
ffffffe000202124:	faf43423          	sd	a5,-88(s0)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202128:	fe043423          	sd	zero,-24(s0)
ffffffe00020212c:	0300006f          	j	ffffffe00020215c <do_fork+0x6c>
        cptask[i] = ccurrent_task[i];
ffffffe000202130:	fb043703          	ld	a4,-80(s0)
ffffffe000202134:	fe843783          	ld	a5,-24(s0)
ffffffe000202138:	00f70733          	add	a4,a4,a5
ffffffe00020213c:	fa843683          	ld	a3,-88(s0)
ffffffe000202140:	fe843783          	ld	a5,-24(s0)
ffffffe000202144:	00f687b3          	add	a5,a3,a5
ffffffe000202148:	00074703          	lbu	a4,0(a4)
ffffffe00020214c:	00e78023          	sb	a4,0(a5)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202150:	fe843783          	ld	a5,-24(s0)
ffffffe000202154:	00178793          	addi	a5,a5,1
ffffffe000202158:	fef43423          	sd	a5,-24(s0)
ffffffe00020215c:	fe843703          	ld	a4,-24(s0)
ffffffe000202160:	000017b7          	lui	a5,0x1
ffffffe000202164:	fcf766e3          	bltu	a4,a5,ffffffe000202130 <do_fork+0x40>
    }
    ptask->pid = nr_tasks;
ffffffe000202168:	00003797          	auipc	a5,0x3
ffffffe00020216c:	ea878793          	addi	a5,a5,-344 # ffffffe000205010 <nr_tasks>
ffffffe000202170:	0007b703          	ld	a4,0(a5)
ffffffe000202174:	fb843783          	ld	a5,-72(s0)
ffffffe000202178:	00e7bc23          	sd	a4,24(a5)
    ptask->thread.ra = __ret_from_fork;
ffffffe00020217c:	ffffe717          	auipc	a4,0xffffe
ffffffe000202180:	fcc70713          	addi	a4,a4,-52 # ffffffe000200148 <__ret_from_fork>
ffffffe000202184:	fb843783          	ld	a5,-72(s0)
ffffffe000202188:	02e7b023          	sd	a4,32(a5)
    ptask->thread.sp = (uint64_t)ptask + (uint64_t)regs - PGROUNDDOWN((uint64_t)regs); // ??
ffffffe00020218c:	fb843703          	ld	a4,-72(s0)
ffffffe000202190:	f3843783          	ld	a5,-200(s0)
ffffffe000202194:	00f70733          	add	a4,a4,a5
ffffffe000202198:	f3843683          	ld	a3,-200(s0)
ffffffe00020219c:	fffff7b7          	lui	a5,0xfffff
ffffffe0002021a0:	00f6f7b3          	and	a5,a3,a5
ffffffe0002021a4:	40f70733          	sub	a4,a4,a5
ffffffe0002021a8:	fb843783          	ld	a5,-72(s0)
ffffffe0002021ac:	02e7b423          	sd	a4,40(a5) # fffffffffffff028 <VM_END+0xfffff028>
    //ptask sscratch
    // LogBLUE("ptask->thread.sscratch = 0x%llx", ptask->thread.sscratch);
    // uint64_t _sscratch = csr_read(sscratch);
    // LogBLUE("sscratch = 0x%llx", _sscratch);
    ptask->thread.sscratch = csr_read(sscratch);
ffffffe0002021b0:	140027f3          	csrr	a5,sscratch
ffffffe0002021b4:	faf43023          	sd	a5,-96(s0)
ffffffe0002021b8:	fa043703          	ld	a4,-96(s0)
ffffffe0002021bc:	fb843783          	ld	a5,-72(s0)
ffffffe0002021c0:	0ae7b023          	sd	a4,160(a5)
    ptask->thread.sepc = csr_read(sepc) + 4;
ffffffe0002021c4:	141027f3          	csrr	a5,sepc
ffffffe0002021c8:	f8f43c23          	sd	a5,-104(s0)
ffffffe0002021cc:	f9843783          	ld	a5,-104(s0)
ffffffe0002021d0:	00478713          	addi	a4,a5,4
ffffffe0002021d4:	fb843783          	ld	a5,-72(s0)
ffffffe0002021d8:	08e7b823          	sd	a4,144(a5)
    
    struct pt_regs *ptregs = (struct pt_regs*)((uint64_t)regs - (uint64_t)current + (uint64_t)ptask);
ffffffe0002021dc:	f3843783          	ld	a5,-200(s0)
ffffffe0002021e0:	00007717          	auipc	a4,0x7
ffffffe0002021e4:	e3070713          	addi	a4,a4,-464 # ffffffe000209010 <current>
ffffffe0002021e8:	00073703          	ld	a4,0(a4)
ffffffe0002021ec:	40e78733          	sub	a4,a5,a4
ffffffe0002021f0:	fb843783          	ld	a5,-72(s0)
ffffffe0002021f4:	00f707b3          	add	a5,a4,a5
ffffffe0002021f8:	f8f43823          	sd	a5,-112(s0)
    ptregs->x[10] = 0;  
ffffffe0002021fc:	f9043783          	ld	a5,-112(s0)
ffffffe000202200:	0407b823          	sd	zero,80(a5)
    ptregs->x[2] = ptask->thread.sp;
ffffffe000202204:	fb843783          	ld	a5,-72(s0)
ffffffe000202208:	0287b703          	ld	a4,40(a5)
ffffffe00020220c:	f9043783          	ld	a5,-112(s0)
ffffffe000202210:	00e7b823          	sd	a4,16(a5)
    

    ptask->pgd = (uint64_t*)alloc_page();
ffffffe000202214:	f34fe0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe000202218:	00050793          	mv	a5,a0
ffffffe00020221c:	00078713          	mv	a4,a5
ffffffe000202220:	fb843783          	ld	a5,-72(s0)
ffffffe000202224:	0ae7b423          	sd	a4,168(a5)
    char *cpgtbl = (char*)ptask->pgd;
ffffffe000202228:	fb843783          	ld	a5,-72(s0)
ffffffe00020222c:	0a87b783          	ld	a5,168(a5)
ffffffe000202230:	f8f43423          	sd	a5,-120(s0)
    char *cearly_pgtbl = (char*)swapper_pg_dir;
ffffffe000202234:	00009797          	auipc	a5,0x9
ffffffe000202238:	dcc78793          	addi	a5,a5,-564 # ffffffe00020b000 <swapper_pg_dir>
ffffffe00020223c:	f8f43023          	sd	a5,-128(s0)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202240:	fe043023          	sd	zero,-32(s0)
ffffffe000202244:	0300006f          	j	ffffffe000202274 <do_fork+0x184>
        cpgtbl[i] = cearly_pgtbl[i];
ffffffe000202248:	f8043703          	ld	a4,-128(s0)
ffffffe00020224c:	fe043783          	ld	a5,-32(s0)
ffffffe000202250:	00f70733          	add	a4,a4,a5
ffffffe000202254:	f8843683          	ld	a3,-120(s0)
ffffffe000202258:	fe043783          	ld	a5,-32(s0)
ffffffe00020225c:	00f687b3          	add	a5,a3,a5
ffffffe000202260:	00074703          	lbu	a4,0(a4)
ffffffe000202264:	00e78023          	sb	a4,0(a5)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202268:	fe043783          	ld	a5,-32(s0)
ffffffe00020226c:	00178793          	addi	a5,a5,1
ffffffe000202270:	fef43023          	sd	a5,-32(s0)
ffffffe000202274:	fe043703          	ld	a4,-32(s0)
ffffffe000202278:	000017b7          	lui	a5,0x1
ffffffe00020227c:	fcf766e3          	bltu	a4,a5,ffffffe000202248 <do_fork+0x158>
    }

    /*DEEP COPY*/
    ptask->mm.mmap = NULL;
ffffffe000202280:	fb843783          	ld	a5,-72(s0)
ffffffe000202284:	0a07b823          	sd	zero,176(a5) # 10b0 <PGSIZE+0xb0>
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
ffffffe000202288:	00007797          	auipc	a5,0x7
ffffffe00020228c:	d8878793          	addi	a5,a5,-632 # ffffffe000209010 <current>
ffffffe000202290:	0007b783          	ld	a5,0(a5)
ffffffe000202294:	0b07b783          	ld	a5,176(a5)
ffffffe000202298:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020229c:	17c0006f          	j	ffffffe000202418 <do_fork+0x328>
        struct vm_area_struct *new_vma = (struct vm_area_struct*)kalloc();
ffffffe0002022a0:	f1cfe0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe0002022a4:	00050793          	mv	a5,a0
ffffffe0002022a8:	f6f43c23          	sd	a5,-136(s0)
        char *cvma = (char*)vma;
ffffffe0002022ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002022b0:	f6f43823          	sd	a5,-144(s0)
        char *cnew_vma = (char*)new_vma;
ffffffe0002022b4:	f7843783          	ld	a5,-136(s0)
ffffffe0002022b8:	f6f43423          	sd	a5,-152(s0)
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
ffffffe0002022bc:	fc043823          	sd	zero,-48(s0)
ffffffe0002022c0:	0300006f          	j	ffffffe0002022f0 <do_fork+0x200>
            cnew_vma[i] = cvma[i];
ffffffe0002022c4:	f7043703          	ld	a4,-144(s0)
ffffffe0002022c8:	fd043783          	ld	a5,-48(s0)
ffffffe0002022cc:	00f70733          	add	a4,a4,a5
ffffffe0002022d0:	f6843683          	ld	a3,-152(s0)
ffffffe0002022d4:	fd043783          	ld	a5,-48(s0)
ffffffe0002022d8:	00f687b3          	add	a5,a3,a5
ffffffe0002022dc:	00074703          	lbu	a4,0(a4)
ffffffe0002022e0:	00e78023          	sb	a4,0(a5)
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
ffffffe0002022e4:	fd043783          	ld	a5,-48(s0)
ffffffe0002022e8:	00178793          	addi	a5,a5,1
ffffffe0002022ec:	fcf43823          	sd	a5,-48(s0)
ffffffe0002022f0:	fd043703          	ld	a4,-48(s0)
ffffffe0002022f4:	03f00793          	li	a5,63
ffffffe0002022f8:	fce7f6e3          	bgeu	a5,a4,ffffffe0002022c4 <do_fork+0x1d4>
        }
        // LogBLUE("new_vma->vm_start = 0x%llx, new_vma->vm_end = 0x%llx", new_vma->vm_start, new_vma->vm_end);
        // LogBLUE("vma->vm_start = 0x%llx, vma->vm_end = 0x%llx", vma->vm_start, vma->vm_end);
        add_mmap(&ptask->mm, new_vma);
ffffffe0002022fc:	fb843783          	ld	a5,-72(s0)
ffffffe000202300:	0b078793          	addi	a5,a5,176
ffffffe000202304:	f7843583          	ld	a1,-136(s0)
ffffffe000202308:	00078513          	mv	a0,a5
ffffffe00020230c:	278000ef          	jal	ra,ffffffe000202584 <add_mmap>

        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
ffffffe000202310:	fd843783          	ld	a5,-40(s0)
ffffffe000202314:	0087b703          	ld	a4,8(a5)
ffffffe000202318:	fffff7b7          	lui	a5,0xfffff
ffffffe00020231c:	00f777b3          	and	a5,a4,a5
ffffffe000202320:	fcf43423          	sd	a5,-56(s0)
ffffffe000202324:	0d00006f          	j	ffffffe0002023f4 <do_fork+0x304>
            uint64_t perm = check_load(current->pgd, addr);
ffffffe000202328:	00007797          	auipc	a5,0x7
ffffffe00020232c:	ce878793          	addi	a5,a5,-792 # ffffffe000209010 <current>
ffffffe000202330:	0007b783          	ld	a5,0(a5)
ffffffe000202334:	0a87b783          	ld	a5,168(a5)
ffffffe000202338:	fc843583          	ld	a1,-56(s0)
ffffffe00020233c:	00078513          	mv	a0,a5
ffffffe000202340:	13c000ef          	jal	ra,ffffffe00020247c <check_load>
ffffffe000202344:	00050793          	mv	a5,a0
ffffffe000202348:	f6f43023          	sd	a5,-160(s0)
            if (!perm) continue;
ffffffe00020234c:	f6043783          	ld	a5,-160(s0)
ffffffe000202350:	08078863          	beqz	a5,ffffffe0002023e0 <do_fork+0x2f0>

            uint64_t *new_page = (uint64_t*)alloc_page();
ffffffe000202354:	df4fe0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe000202358:	00050793          	mv	a5,a0
ffffffe00020235c:	f4f43c23          	sd	a5,-168(s0)
            char *cnew_page = (char*)new_page;
ffffffe000202360:	f5843783          	ld	a5,-168(s0)
ffffffe000202364:	f4f43823          	sd	a5,-176(s0)
            char *cpage = (char*)addr;
ffffffe000202368:	fc843783          	ld	a5,-56(s0)
ffffffe00020236c:	f4f43423          	sd	a5,-184(s0)
            for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202370:	fc043023          	sd	zero,-64(s0)
ffffffe000202374:	0300006f          	j	ffffffe0002023a4 <do_fork+0x2b4>
                cnew_page[i] = cpage[i];
ffffffe000202378:	f4843703          	ld	a4,-184(s0)
ffffffe00020237c:	fc043783          	ld	a5,-64(s0)
ffffffe000202380:	00f70733          	add	a4,a4,a5
ffffffe000202384:	f5043683          	ld	a3,-176(s0)
ffffffe000202388:	fc043783          	ld	a5,-64(s0)
ffffffe00020238c:	00f687b3          	add	a5,a3,a5
ffffffe000202390:	00074703          	lbu	a4,0(a4)
ffffffe000202394:	00e78023          	sb	a4,0(a5)
            for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202398:	fc043783          	ld	a5,-64(s0)
ffffffe00020239c:	00178793          	addi	a5,a5,1
ffffffe0002023a0:	fcf43023          	sd	a5,-64(s0)
ffffffe0002023a4:	fc043703          	ld	a4,-64(s0)
ffffffe0002023a8:	000017b7          	lui	a5,0x1
ffffffe0002023ac:	fcf766e3          	bltu	a4,a5,ffffffe000202378 <do_fork+0x288>
            }
            create_mapping(ptask->pgd, addr, VA2PA((uint64_t)new_page), PGSIZE, perm);
ffffffe0002023b0:	fb843783          	ld	a5,-72(s0)
ffffffe0002023b4:	0a87b503          	ld	a0,168(a5) # 10a8 <PGSIZE+0xa8>
ffffffe0002023b8:	f5843703          	ld	a4,-168(s0)
ffffffe0002023bc:	04100793          	li	a5,65
ffffffe0002023c0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002023c4:	00f707b3          	add	a5,a4,a5
ffffffe0002023c8:	f6043703          	ld	a4,-160(s0)
ffffffe0002023cc:	000016b7          	lui	a3,0x1
ffffffe0002023d0:	00078613          	mv	a2,a5
ffffffe0002023d4:	fc843583          	ld	a1,-56(s0)
ffffffe0002023d8:	52c000ef          	jal	ra,ffffffe000202904 <create_mapping>
ffffffe0002023dc:	0080006f          	j	ffffffe0002023e4 <do_fork+0x2f4>
            if (!perm) continue;
ffffffe0002023e0:	00000013          	nop
        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
ffffffe0002023e4:	fc843703          	ld	a4,-56(s0)
ffffffe0002023e8:	000017b7          	lui	a5,0x1
ffffffe0002023ec:	00f707b3          	add	a5,a4,a5
ffffffe0002023f0:	fcf43423          	sd	a5,-56(s0)
ffffffe0002023f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002023f8:	0107b703          	ld	a4,16(a5) # 1010 <PGSIZE+0x10>
ffffffe0002023fc:	fffff7b7          	lui	a5,0xfffff
ffffffe000202400:	00f777b3          	and	a5,a4,a5
ffffffe000202404:	fc843703          	ld	a4,-56(s0)
ffffffe000202408:	f2e7f0e3          	bgeu	a5,a4,ffffffe000202328 <do_fork+0x238>
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
ffffffe00020240c:	fd843783          	ld	a5,-40(s0)
ffffffe000202410:	0187b783          	ld	a5,24(a5) # fffffffffffff018 <VM_END+0xfffff018>
ffffffe000202414:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202418:	fd843783          	ld	a5,-40(s0)
ffffffe00020241c:	e80792e3          	bnez	a5,ffffffe0002022a0 <do_fork+0x1b0>
        }
    }


    // load_program(ptask);
    task[nr_tasks] = ptask;
ffffffe000202420:	00003797          	auipc	a5,0x3
ffffffe000202424:	bf078793          	addi	a5,a5,-1040 # ffffffe000205010 <nr_tasks>
ffffffe000202428:	0007b783          	ld	a5,0(a5)
ffffffe00020242c:	00007717          	auipc	a4,0x7
ffffffe000202430:	c0470713          	addi	a4,a4,-1020 # ffffffe000209030 <task>
ffffffe000202434:	00379793          	slli	a5,a5,0x3
ffffffe000202438:	00f707b3          	add	a5,a4,a5
ffffffe00020243c:	fb843703          	ld	a4,-72(s0)
ffffffe000202440:	00e7b023          	sd	a4,0(a5)
    nr_tasks++;
ffffffe000202444:	00003797          	auipc	a5,0x3
ffffffe000202448:	bcc78793          	addi	a5,a5,-1076 # ffffffe000205010 <nr_tasks>
ffffffe00020244c:	0007b783          	ld	a5,0(a5)
ffffffe000202450:	00178713          	addi	a4,a5,1
ffffffe000202454:	00003797          	auipc	a5,0x3
ffffffe000202458:	bbc78793          	addi	a5,a5,-1092 # ffffffe000205010 <nr_tasks>
ffffffe00020245c:	00e7b023          	sd	a4,0(a5)
    return ptask->pid;
ffffffe000202460:	fb843783          	ld	a5,-72(s0)
ffffffe000202464:	0187b783          	ld	a5,24(a5)
}
ffffffe000202468:	00078513          	mv	a0,a5
ffffffe00020246c:	0c813083          	ld	ra,200(sp)
ffffffe000202470:	0c013403          	ld	s0,192(sp)
ffffffe000202474:	0d010113          	addi	sp,sp,208
ffffffe000202478:	00008067          	ret

ffffffe00020247c <check_load>:

int check_load(uint64_t *pgtbl, uint64_t addr){
ffffffe00020247c:	fb010113          	addi	sp,sp,-80
ffffffe000202480:	04813423          	sd	s0,72(sp)
ffffffe000202484:	05010413          	addi	s0,sp,80
ffffffe000202488:	faa43c23          	sd	a0,-72(s0)
ffffffe00020248c:	fab43823          	sd	a1,-80(s0)
    uint64_t pgd_entry = *(pgtbl + ((addr >> 30) & 0x1ff));
ffffffe000202490:	fb043783          	ld	a5,-80(s0)
ffffffe000202494:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202498:	1ff7f793          	andi	a5,a5,511
ffffffe00020249c:	00379793          	slli	a5,a5,0x3
ffffffe0002024a0:	fb843703          	ld	a4,-72(s0)
ffffffe0002024a4:	00f707b3          	add	a5,a4,a5
ffffffe0002024a8:	0007b783          	ld	a5,0(a5)
ffffffe0002024ac:	fef43423          	sd	a5,-24(s0)
    if (!(pgd_entry & PTE_V)) return 0;
ffffffe0002024b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002024b4:	0017f793          	andi	a5,a5,1
ffffffe0002024b8:	00079663          	bnez	a5,ffffffe0002024c4 <check_load+0x48>
ffffffe0002024bc:	00000793          	li	a5,0
ffffffe0002024c0:	0b40006f          	j	ffffffe000202574 <check_load+0xf8>
    uint64_t *pmd = (uint64_t*)(PA2VA((uint64_t)((pgd_entry >> 10) << 12)));
ffffffe0002024c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002024c8:	00a7d793          	srli	a5,a5,0xa
ffffffe0002024cc:	00c79713          	slli	a4,a5,0xc
ffffffe0002024d0:	fbf00793          	li	a5,-65
ffffffe0002024d4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002024d8:	00f707b3          	add	a5,a4,a5
ffffffe0002024dc:	fef43023          	sd	a5,-32(s0)
    uint64_t pmd_entry = *(pmd + ((addr >> 21) & 0x1ff));
ffffffe0002024e0:	fb043783          	ld	a5,-80(s0)
ffffffe0002024e4:	0157d793          	srli	a5,a5,0x15
ffffffe0002024e8:	1ff7f793          	andi	a5,a5,511
ffffffe0002024ec:	00379793          	slli	a5,a5,0x3
ffffffe0002024f0:	fe043703          	ld	a4,-32(s0)
ffffffe0002024f4:	00f707b3          	add	a5,a4,a5
ffffffe0002024f8:	0007b783          	ld	a5,0(a5)
ffffffe0002024fc:	fcf43c23          	sd	a5,-40(s0)
    if (!(pmd_entry & PTE_V)) return 0;
ffffffe000202500:	fd843783          	ld	a5,-40(s0)
ffffffe000202504:	0017f793          	andi	a5,a5,1
ffffffe000202508:	00079663          	bnez	a5,ffffffe000202514 <check_load+0x98>
ffffffe00020250c:	00000793          	li	a5,0
ffffffe000202510:	0640006f          	j	ffffffe000202574 <check_load+0xf8>
    uint64_t *pte = (uint64_t*)(PA2VA((uint64_t)((pmd_entry >> 10) << 12)));
ffffffe000202514:	fd843783          	ld	a5,-40(s0)
ffffffe000202518:	00a7d793          	srli	a5,a5,0xa
ffffffe00020251c:	00c79713          	slli	a4,a5,0xc
ffffffe000202520:	fbf00793          	li	a5,-65
ffffffe000202524:	01f79793          	slli	a5,a5,0x1f
ffffffe000202528:	00f707b3          	add	a5,a4,a5
ffffffe00020252c:	fcf43823          	sd	a5,-48(s0)
    uint64_t pte_entry = *(pte + ((addr >> 12) & 0x1ff));
ffffffe000202530:	fb043783          	ld	a5,-80(s0)
ffffffe000202534:	00c7d793          	srli	a5,a5,0xc
ffffffe000202538:	1ff7f793          	andi	a5,a5,511
ffffffe00020253c:	00379793          	slli	a5,a5,0x3
ffffffe000202540:	fd043703          	ld	a4,-48(s0)
ffffffe000202544:	00f707b3          	add	a5,a4,a5
ffffffe000202548:	0007b783          	ld	a5,0(a5)
ffffffe00020254c:	fcf43423          	sd	a5,-56(s0)
    if (!(pte_entry & PTE_V)) return 0;
ffffffe000202550:	fc843783          	ld	a5,-56(s0)
ffffffe000202554:	0017f793          	andi	a5,a5,1
ffffffe000202558:	00079663          	bnez	a5,ffffffe000202564 <check_load+0xe8>
ffffffe00020255c:	00000793          	li	a5,0
ffffffe000202560:	0140006f          	j	ffffffe000202574 <check_load+0xf8>
    // return (pte_entry & PTE_R) | (pte_entry & PTE_X) | (pte_entry & PTE_W) | PTE_V | PTE_U; 
    return pte_entry & 0XFF;
ffffffe000202564:	fc843783          	ld	a5,-56(s0)
ffffffe000202568:	0007879b          	sext.w	a5,a5
ffffffe00020256c:	0ff7f793          	zext.b	a5,a5
ffffffe000202570:	0007879b          	sext.w	a5,a5
}
ffffffe000202574:	00078513          	mv	a0,a5
ffffffe000202578:	04813403          	ld	s0,72(sp)
ffffffe00020257c:	05010113          	addi	sp,sp,80
ffffffe000202580:	00008067          	ret

ffffffe000202584 <add_mmap>:

void add_mmap(struct mm_struct *mm, struct vm_area_struct *new_vma){
ffffffe000202584:	fd010113          	addi	sp,sp,-48
ffffffe000202588:	02813423          	sd	s0,40(sp)
ffffffe00020258c:	03010413          	addi	s0,sp,48
ffffffe000202590:	fca43c23          	sd	a0,-40(s0)
ffffffe000202594:	fcb43823          	sd	a1,-48(s0)
    new_vma->vm_mm = mm;
ffffffe000202598:	fd043783          	ld	a5,-48(s0)
ffffffe00020259c:	fd843703          	ld	a4,-40(s0)
ffffffe0002025a0:	00e7b023          	sd	a4,0(a5)
    struct vm_area_struct *prev =  mm->mmap;
ffffffe0002025a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002025a8:	0007b783          	ld	a5,0(a5)
ffffffe0002025ac:	fef43423          	sd	a5,-24(s0)
    if(!prev){
ffffffe0002025b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002025b4:	02079263          	bnez	a5,ffffffe0002025d8 <add_mmap+0x54>
        mm->mmap = new_vma;
ffffffe0002025b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002025bc:	fd043703          	ld	a4,-48(s0)
ffffffe0002025c0:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = NULL;
ffffffe0002025c4:	fd043783          	ld	a5,-48(s0)
ffffffe0002025c8:	0007bc23          	sd	zero,24(a5)
        new_vma->vm_prev = NULL;
ffffffe0002025cc:	fd043783          	ld	a5,-48(s0)
ffffffe0002025d0:	0207b023          	sd	zero,32(a5)
        new_vma->vm_next = prev;
        new_vma->vm_prev = NULL;
        prev->vm_prev = new_vma;
    }
    // return mm->mmap;
}
ffffffe0002025d4:	0300006f          	j	ffffffe000202604 <add_mmap+0x80>
        mm->mmap = new_vma;
ffffffe0002025d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002025dc:	fd043703          	ld	a4,-48(s0)
ffffffe0002025e0:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = prev;
ffffffe0002025e4:	fd043783          	ld	a5,-48(s0)
ffffffe0002025e8:	fe843703          	ld	a4,-24(s0)
ffffffe0002025ec:	00e7bc23          	sd	a4,24(a5)
        new_vma->vm_prev = NULL;
ffffffe0002025f0:	fd043783          	ld	a5,-48(s0)
ffffffe0002025f4:	0207b023          	sd	zero,32(a5)
        prev->vm_prev = new_vma;
ffffffe0002025f8:	fe843783          	ld	a5,-24(s0)
ffffffe0002025fc:	fd043703          	ld	a4,-48(s0)
ffffffe000202600:	02e7b023          	sd	a4,32(a5)
}
ffffffe000202604:	00000013          	nop
ffffffe000202608:	02813403          	ld	s0,40(sp)
ffffffe00020260c:	03010113          	addi	sp,sp,48
ffffffe000202610:	00008067          	ret

ffffffe000202614 <setup_vm>:
#include "printk.h"

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe000202614:	fd010113          	addi	sp,sp,-48
ffffffe000202618:	02113423          	sd	ra,40(sp)
ffffffe00020261c:	02813023          	sd	s0,32(sp)
ffffffe000202620:	03010413          	addi	s0,sp,48
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
    memset(early_pgtbl, 0x0, PGSIZE);
ffffffe000202624:	00001637          	lui	a2,0x1
ffffffe000202628:	00000593          	li	a1,0
ffffffe00020262c:	00008517          	auipc	a0,0x8
ffffffe000202630:	9d450513          	addi	a0,a0,-1580 # ffffffe00020a000 <early_pgtbl>
ffffffe000202634:	56c010ef          	jal	ra,ffffffe000203ba0 <memset>
    uint64_t va = VM_START;
ffffffe000202638:	fff00793          	li	a5,-1
ffffffe00020263c:	02579793          	slli	a5,a5,0x25
ffffffe000202640:	fef43423          	sd	a5,-24(s0)
    uint64_t pa = PHY_START;
ffffffe000202644:	00100793          	li	a5,1
ffffffe000202648:	01f79793          	slli	a5,a5,0x1f
ffffffe00020264c:	fef43023          	sd	a5,-32(s0)
    LogGREEN("early_pgtbl: 0x%llx\n", early_pgtbl);
ffffffe000202650:	00008717          	auipc	a4,0x8
ffffffe000202654:	9b070713          	addi	a4,a4,-1616 # ffffffe00020a000 <early_pgtbl>
ffffffe000202658:	00002697          	auipc	a3,0x2
ffffffe00020265c:	07068693          	addi	a3,a3,112 # ffffffe0002046c8 <__func__.2>
ffffffe000202660:	01300613          	li	a2,19
ffffffe000202664:	00002597          	auipc	a1,0x2
ffffffe000202668:	f2c58593          	addi	a1,a1,-212 # ffffffe000204590 <__func__.0+0x10>
ffffffe00020266c:	00002517          	auipc	a0,0x2
ffffffe000202670:	f2c50513          	addi	a0,a0,-212 # ffffffe000204598 <__func__.0+0x18>
ffffffe000202674:	40c010ef          	jal	ra,ffffffe000203a80 <printk>
    uint64_t index = (pa >> 30) & 0x1ff;
ffffffe000202678:	fe043783          	ld	a5,-32(s0)
ffffffe00020267c:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202680:	1ff7f793          	andi	a5,a5,511
ffffffe000202684:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe000202688:	fd843583          	ld	a1,-40(s0)
ffffffe00020268c:	00002517          	auipc	a0,0x2
ffffffe000202690:	f3c50513          	addi	a0,a0,-196 # ffffffe0002045c8 <__func__.0+0x48>
ffffffe000202694:	3ec010ef          	jal	ra,ffffffe000203a80 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe000202698:	fe043783          	ld	a5,-32(s0)
ffffffe00020269c:	0027d713          	srli	a4,a5,0x2
ffffffe0002026a0:	040007b7          	lui	a5,0x4000
ffffffe0002026a4:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe0002026a8:	01c79793          	slli	a5,a5,0x1c
ffffffe0002026ac:	00f777b3          	and	a5,a4,a5
ffffffe0002026b0:	00f7e713          	ori	a4,a5,15
ffffffe0002026b4:	00008697          	auipc	a3,0x8
ffffffe0002026b8:	94c68693          	addi	a3,a3,-1716 # ffffffe00020a000 <early_pgtbl>
ffffffe0002026bc:	fd843783          	ld	a5,-40(s0)
ffffffe0002026c0:	00379793          	slli	a5,a5,0x3
ffffffe0002026c4:	00f687b3          	add	a5,a3,a5
ffffffe0002026c8:	00e7b023          	sd	a4,0(a5)

    index = (va >> 30) & 0x1ff;
ffffffe0002026cc:	fe843783          	ld	a5,-24(s0)
ffffffe0002026d0:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002026d4:	1ff7f793          	andi	a5,a5,511
ffffffe0002026d8:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe0002026dc:	fd843583          	ld	a1,-40(s0)
ffffffe0002026e0:	00002517          	auipc	a0,0x2
ffffffe0002026e4:	ee850513          	addi	a0,a0,-280 # ffffffe0002045c8 <__func__.0+0x48>
ffffffe0002026e8:	398010ef          	jal	ra,ffffffe000203a80 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe0002026ec:	fe043783          	ld	a5,-32(s0)
ffffffe0002026f0:	0027d713          	srli	a4,a5,0x2
ffffffe0002026f4:	040007b7          	lui	a5,0x4000
ffffffe0002026f8:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe0002026fc:	01c79793          	slli	a5,a5,0x1c
ffffffe000202700:	00f777b3          	and	a5,a4,a5
ffffffe000202704:	00f7e713          	ori	a4,a5,15
ffffffe000202708:	00008697          	auipc	a3,0x8
ffffffe00020270c:	8f868693          	addi	a3,a3,-1800 # ffffffe00020a000 <early_pgtbl>
ffffffe000202710:	fd843783          	ld	a5,-40(s0)
ffffffe000202714:	00379793          	slli	a5,a5,0x3
ffffffe000202718:	00f687b3          	add	a5,a3,a5
ffffffe00020271c:	00e7b023          	sd	a4,0(a5)

    printk("setup_vm done...\n");
ffffffe000202720:	00002517          	auipc	a0,0x2
ffffffe000202724:	eb850513          	addi	a0,a0,-328 # ffffffe0002045d8 <__func__.0+0x58>
ffffffe000202728:	358010ef          	jal	ra,ffffffe000203a80 <printk>
}
ffffffe00020272c:	00000013          	nop
ffffffe000202730:	02813083          	ld	ra,40(sp)
ffffffe000202734:	02013403          	ld	s0,32(sp)
ffffffe000202738:	03010113          	addi	sp,sp,48
ffffffe00020273c:	00008067          	ret

ffffffe000202740 <setup_vm_final>:
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

void setup_vm_final() {
ffffffe000202740:	fc010113          	addi	sp,sp,-64
ffffffe000202744:	02113c23          	sd	ra,56(sp)
ffffffe000202748:	02813823          	sd	s0,48(sp)
ffffffe00020274c:	04010413          	addi	s0,sp,64
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000202750:	00001637          	lui	a2,0x1
ffffffe000202754:	00000593          	li	a1,0
ffffffe000202758:	00009517          	auipc	a0,0x9
ffffffe00020275c:	8a850513          	addi	a0,a0,-1880 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000202760:	440010ef          	jal	ra,ffffffe000203ba0 <memset>
    LogYELLOW("_stext: %p, _etext: %p, _srodata: %p, _erodata: %p, _sdata: %p, _edata: %p, _sbss: %p, _ebss: %p\n", _stext, _etext, _srodata, _erodata, _sdata, _edata, _sbss, _ebss);
ffffffe000202764:	0000a797          	auipc	a5,0xa
ffffffe000202768:	89c78793          	addi	a5,a5,-1892 # ffffffe00020c000 <_ebss>
ffffffe00020276c:	00f13c23          	sd	a5,24(sp)
ffffffe000202770:	00006797          	auipc	a5,0x6
ffffffe000202774:	89078793          	addi	a5,a5,-1904 # ffffffe000208000 <_sbss>
ffffffe000202778:	00f13823          	sd	a5,16(sp)
ffffffe00020277c:	00003797          	auipc	a5,0x3
ffffffe000202780:	89c78793          	addi	a5,a5,-1892 # ffffffe000205018 <_edata>
ffffffe000202784:	00f13423          	sd	a5,8(sp)
ffffffe000202788:	00003797          	auipc	a5,0x3
ffffffe00020278c:	87878793          	addi	a5,a5,-1928 # ffffffe000205000 <TIMECLOCK>
ffffffe000202790:	00f13023          	sd	a5,0(sp)
ffffffe000202794:	00002897          	auipc	a7,0x2
ffffffe000202798:	ff488893          	addi	a7,a7,-12 # ffffffe000204788 <_erodata>
ffffffe00020279c:	00002817          	auipc	a6,0x2
ffffffe0002027a0:	86480813          	addi	a6,a6,-1948 # ffffffe000204000 <__func__.1>
ffffffe0002027a4:	00001797          	auipc	a5,0x1
ffffffe0002027a8:	46c78793          	addi	a5,a5,1132 # ffffffe000203c10 <_etext>
ffffffe0002027ac:	ffffe717          	auipc	a4,0xffffe
ffffffe0002027b0:	85470713          	addi	a4,a4,-1964 # ffffffe000200000 <_skernel>
ffffffe0002027b4:	00002697          	auipc	a3,0x2
ffffffe0002027b8:	f2468693          	addi	a3,a3,-220 # ffffffe0002046d8 <__func__.1>
ffffffe0002027bc:	02700613          	li	a2,39
ffffffe0002027c0:	00002597          	auipc	a1,0x2
ffffffe0002027c4:	dd058593          	addi	a1,a1,-560 # ffffffe000204590 <__func__.0+0x10>
ffffffe0002027c8:	00002517          	auipc	a0,0x2
ffffffe0002027cc:	e2850513          	addi	a0,a0,-472 # ffffffe0002045f0 <__func__.0+0x70>
ffffffe0002027d0:	2b0010ef          	jal	ra,ffffffe000203a80 <printk>

    // No OpenSBI mapping required
    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, _stext, _stext - PA2VA_OFFSET, _srodata - _stext, PTE_X | PTE_R | PTE_V);;
ffffffe0002027d4:	ffffe597          	auipc	a1,0xffffe
ffffffe0002027d8:	82c58593          	addi	a1,a1,-2004 # ffffffe000200000 <_skernel>
ffffffe0002027dc:	ffffe717          	auipc	a4,0xffffe
ffffffe0002027e0:	82470713          	addi	a4,a4,-2012 # ffffffe000200000 <_skernel>
ffffffe0002027e4:	04100793          	li	a5,65
ffffffe0002027e8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002027ec:	00f707b3          	add	a5,a4,a5
ffffffe0002027f0:	00078613          	mv	a2,a5
ffffffe0002027f4:	00002717          	auipc	a4,0x2
ffffffe0002027f8:	80c70713          	addi	a4,a4,-2036 # ffffffe000204000 <__func__.1>
ffffffe0002027fc:	ffffe797          	auipc	a5,0xffffe
ffffffe000202800:	80478793          	addi	a5,a5,-2044 # ffffffe000200000 <_skernel>
ffffffe000202804:	40f707b3          	sub	a5,a4,a5
ffffffe000202808:	00b00713          	li	a4,11
ffffffe00020280c:	00078693          	mv	a3,a5
ffffffe000202810:	00008517          	auipc	a0,0x8
ffffffe000202814:	7f050513          	addi	a0,a0,2032 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000202818:	0ec000ef          	jal	ra,ffffffe000202904 <create_mapping>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, _srodata, _srodata - PA2VA_OFFSET, _sdata - _srodata, PTE_R | PTE_V);
ffffffe00020281c:	00001597          	auipc	a1,0x1
ffffffe000202820:	7e458593          	addi	a1,a1,2020 # ffffffe000204000 <__func__.1>
ffffffe000202824:	00001717          	auipc	a4,0x1
ffffffe000202828:	7dc70713          	addi	a4,a4,2012 # ffffffe000204000 <__func__.1>
ffffffe00020282c:	04100793          	li	a5,65
ffffffe000202830:	01f79793          	slli	a5,a5,0x1f
ffffffe000202834:	00f707b3          	add	a5,a4,a5
ffffffe000202838:	00078613          	mv	a2,a5
ffffffe00020283c:	00002717          	auipc	a4,0x2
ffffffe000202840:	7c470713          	addi	a4,a4,1988 # ffffffe000205000 <TIMECLOCK>
ffffffe000202844:	00001797          	auipc	a5,0x1
ffffffe000202848:	7bc78793          	addi	a5,a5,1980 # ffffffe000204000 <__func__.1>
ffffffe00020284c:	40f707b3          	sub	a5,a4,a5
ffffffe000202850:	00300713          	li	a4,3
ffffffe000202854:	00078693          	mv	a3,a5
ffffffe000202858:	00008517          	auipc	a0,0x8
ffffffe00020285c:	7a850513          	addi	a0,a0,1960 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000202860:	0a4000ef          	jal	ra,ffffffe000202904 <create_mapping>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir, _sdata, _sdata - PA2VA_OFFSET, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V);
ffffffe000202864:	00002597          	auipc	a1,0x2
ffffffe000202868:	79c58593          	addi	a1,a1,1948 # ffffffe000205000 <TIMECLOCK>
ffffffe00020286c:	00002717          	auipc	a4,0x2
ffffffe000202870:	79470713          	addi	a4,a4,1940 # ffffffe000205000 <TIMECLOCK>
ffffffe000202874:	04100793          	li	a5,65
ffffffe000202878:	01f79793          	slli	a5,a5,0x1f
ffffffe00020287c:	00f707b3          	add	a5,a4,a5
ffffffe000202880:	00078613          	mv	a2,a5
ffffffe000202884:	00002717          	auipc	a4,0x2
ffffffe000202888:	77c70713          	addi	a4,a4,1916 # ffffffe000205000 <TIMECLOCK>
ffffffe00020288c:	ffffd797          	auipc	a5,0xffffd
ffffffe000202890:	77478793          	addi	a5,a5,1908 # ffffffe000200000 <_skernel>
ffffffe000202894:	40f707b3          	sub	a5,a4,a5
ffffffe000202898:	08000737          	lui	a4,0x8000
ffffffe00020289c:	40f707b3          	sub	a5,a4,a5
ffffffe0002028a0:	00700713          	li	a4,7
ffffffe0002028a4:	00078693          	mv	a3,a5
ffffffe0002028a8:	00008517          	auipc	a0,0x8
ffffffe0002028ac:	75850513          	addi	a0,a0,1880 # ffffffe00020b000 <swapper_pg_dir>
ffffffe0002028b0:	054000ef          	jal	ra,ffffffe000202904 <create_mapping>

    uint64_t _satp = ((((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12) | (uint64_t)0x8 << 60);
ffffffe0002028b4:	00008717          	auipc	a4,0x8
ffffffe0002028b8:	74c70713          	addi	a4,a4,1868 # ffffffe00020b000 <swapper_pg_dir>
ffffffe0002028bc:	04100793          	li	a5,65
ffffffe0002028c0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002028c4:	00f707b3          	add	a5,a4,a5
ffffffe0002028c8:	00c7d713          	srli	a4,a5,0xc
ffffffe0002028cc:	fff00793          	li	a5,-1
ffffffe0002028d0:	03f79793          	slli	a5,a5,0x3f
ffffffe0002028d4:	00f767b3          	or	a5,a4,a5
ffffffe0002028d8:	fef43423          	sd	a5,-24(s0)

    // set satp with swapper_pg_dir
    csr_write(satp, _satp);
ffffffe0002028dc:	fe843783          	ld	a5,-24(s0)
ffffffe0002028e0:	fef43023          	sd	a5,-32(s0)
ffffffe0002028e4:	fe043783          	ld	a5,-32(s0)
ffffffe0002028e8:	18079073          	csrw	satp,a5
    // *_erodata = 0x0;
    // LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);

    // YOUR CODE HERE
    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe0002028ec:	12000073          	sfence.vma
    return;
ffffffe0002028f0:	00000013          	nop
}
ffffffe0002028f4:	03813083          	ld	ra,56(sp)
ffffffe0002028f8:	03013403          	ld	s0,48(sp)
ffffffe0002028fc:	04010113          	addi	sp,sp,64
ffffffe000202900:	00008067          	ret

ffffffe000202904 <create_mapping>:


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000202904:	f7010113          	addi	sp,sp,-144
ffffffe000202908:	08113423          	sd	ra,136(sp)
ffffffe00020290c:	08813023          	sd	s0,128(sp)
ffffffe000202910:	09010413          	addi	s0,sp,144
ffffffe000202914:	faa43423          	sd	a0,-88(s0)
ffffffe000202918:	fab43023          	sd	a1,-96(s0)
ffffffe00020291c:	f8c43c23          	sd	a2,-104(s0)
ffffffe000202920:	f8d43823          	sd	a3,-112(s0)
ffffffe000202924:	f8e43423          	sd	a4,-120(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    // printk("Come into the create_mapping\n");
    LogBLUE("root: 0x%llx, [0x%llx, 0x%llx) -> [0x%llx, 0x%llx), perm: 0x%llx", pgtbl, pa, pa + sz, va, va + sz, perm);
ffffffe000202928:	f9843703          	ld	a4,-104(s0)
ffffffe00020292c:	f9043783          	ld	a5,-112(s0)
ffffffe000202930:	00f706b3          	add	a3,a4,a5
ffffffe000202934:	fa043703          	ld	a4,-96(s0)
ffffffe000202938:	f9043783          	ld	a5,-112(s0)
ffffffe00020293c:	00f707b3          	add	a5,a4,a5
ffffffe000202940:	f8843703          	ld	a4,-120(s0)
ffffffe000202944:	00e13423          	sd	a4,8(sp)
ffffffe000202948:	00f13023          	sd	a5,0(sp)
ffffffe00020294c:	fa043883          	ld	a7,-96(s0)
ffffffe000202950:	00068813          	mv	a6,a3
ffffffe000202954:	f9843783          	ld	a5,-104(s0)
ffffffe000202958:	fa843703          	ld	a4,-88(s0)
ffffffe00020295c:	00002697          	auipc	a3,0x2
ffffffe000202960:	d8c68693          	addi	a3,a3,-628 # ffffffe0002046e8 <__func__.0>
ffffffe000202964:	05300613          	li	a2,83
ffffffe000202968:	00002597          	auipc	a1,0x2
ffffffe00020296c:	c2858593          	addi	a1,a1,-984 # ffffffe000204590 <__func__.0+0x10>
ffffffe000202970:	00002517          	auipc	a0,0x2
ffffffe000202974:	d0050513          	addi	a0,a0,-768 # ffffffe000204670 <__func__.0+0xf0>
ffffffe000202978:	108010ef          	jal	ra,ffffffe000203a80 <printk>
    uint64_t vlimit = va + sz;
ffffffe00020297c:	fa043703          	ld	a4,-96(s0)
ffffffe000202980:	f9043783          	ld	a5,-112(s0)
ffffffe000202984:	00f707b3          	add	a5,a4,a5
ffffffe000202988:	fcf43c23          	sd	a5,-40(s0)
    uint64_t *pgd, *pmd, *pte;
    pgd = pgtbl;
ffffffe00020298c:	fa843783          	ld	a5,-88(s0)
ffffffe000202990:	fcf43823          	sd	a5,-48(s0)

    while(va < vlimit){
ffffffe000202994:	19c0006f          	j	ffffffe000202b30 <create_mapping+0x22c>
        uint64_t pgd_entry = *(pgd + ((va >> 30) & 0x1ff));
ffffffe000202998:	fa043783          	ld	a5,-96(s0)
ffffffe00020299c:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002029a0:	1ff7f793          	andi	a5,a5,511
ffffffe0002029a4:	00379793          	slli	a5,a5,0x3
ffffffe0002029a8:	fd043703          	ld	a4,-48(s0)
ffffffe0002029ac:	00f707b3          	add	a5,a4,a5
ffffffe0002029b0:	0007b783          	ld	a5,0(a5)
ffffffe0002029b4:	fef43423          	sd	a5,-24(s0)
        if (!(pgd_entry & PTE_V)) {
ffffffe0002029b8:	fe843783          	ld	a5,-24(s0)
ffffffe0002029bc:	0017f793          	andi	a5,a5,1
ffffffe0002029c0:	06079063          	bnez	a5,ffffffe000202a20 <create_mapping+0x11c>
            uint64_t ppmd = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppmd是PMD页表的物理地址
ffffffe0002029c4:	ff9fd0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe0002029c8:	00050793          	mv	a5,a0
ffffffe0002029cc:	00078713          	mv	a4,a5
ffffffe0002029d0:	04100793          	li	a5,65
ffffffe0002029d4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002029d8:	00f707b3          	add	a5,a4,a5
ffffffe0002029dc:	fcf43423          	sd	a5,-56(s0)
            // LogBLUE("ppmd: 0x%llx", ppmd);
            *(pgd + ((va >> 30) & 0x1ff)) = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe0002029e0:	fc843783          	ld	a5,-56(s0)
ffffffe0002029e4:	00c7d793          	srli	a5,a5,0xc
ffffffe0002029e8:	00a79713          	slli	a4,a5,0xa
ffffffe0002029ec:	fa043783          	ld	a5,-96(s0)
ffffffe0002029f0:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002029f4:	1ff7f793          	andi	a5,a5,511
ffffffe0002029f8:	00379793          	slli	a5,a5,0x3
ffffffe0002029fc:	fd043683          	ld	a3,-48(s0)
ffffffe000202a00:	00f687b3          	add	a5,a3,a5
ffffffe000202a04:	00176713          	ori	a4,a4,1
ffffffe000202a08:	00e7b023          	sd	a4,0(a5)
            pgd_entry = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe000202a0c:	fc843783          	ld	a5,-56(s0)
ffffffe000202a10:	00c7d793          	srli	a5,a5,0xc
ffffffe000202a14:	00a79793          	slli	a5,a5,0xa
ffffffe000202a18:	0017e793          	ori	a5,a5,1
ffffffe000202a1c:	fef43423          	sd	a5,-24(s0)
        }
    
        pmd = (uint64_t*) (((pgd_entry >> 10) << 12) + PA2VA_OFFSET); // pmd此时是PMD页表的虚拟地址
ffffffe000202a20:	fe843783          	ld	a5,-24(s0)
ffffffe000202a24:	00a7d793          	srli	a5,a5,0xa
ffffffe000202a28:	00c79713          	slli	a4,a5,0xc
ffffffe000202a2c:	fbf00793          	li	a5,-65
ffffffe000202a30:	01f79793          	slli	a5,a5,0x1f
ffffffe000202a34:	00f707b3          	add	a5,a4,a5
ffffffe000202a38:	fcf43023          	sd	a5,-64(s0)
        uint64_t pmd_entry = *(pmd + ((va >> 21) & 0x1ff));
ffffffe000202a3c:	fa043783          	ld	a5,-96(s0)
ffffffe000202a40:	0157d793          	srli	a5,a5,0x15
ffffffe000202a44:	1ff7f793          	andi	a5,a5,511
ffffffe000202a48:	00379793          	slli	a5,a5,0x3
ffffffe000202a4c:	fc043703          	ld	a4,-64(s0)
ffffffe000202a50:	00f707b3          	add	a5,a4,a5
ffffffe000202a54:	0007b783          	ld	a5,0(a5)
ffffffe000202a58:	fef43023          	sd	a5,-32(s0)
        if (!(pmd_entry & PTE_V)) {
ffffffe000202a5c:	fe043783          	ld	a5,-32(s0)
ffffffe000202a60:	0017f793          	andi	a5,a5,1
ffffffe000202a64:	06079063          	bnez	a5,ffffffe000202ac4 <create_mapping+0x1c0>
            uint64_t ppte = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppte是PTE页表的物理地址
ffffffe000202a68:	f55fd0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe000202a6c:	00050793          	mv	a5,a0
ffffffe000202a70:	00078713          	mv	a4,a5
ffffffe000202a74:	04100793          	li	a5,65
ffffffe000202a78:	01f79793          	slli	a5,a5,0x1f
ffffffe000202a7c:	00f707b3          	add	a5,a4,a5
ffffffe000202a80:	faf43c23          	sd	a5,-72(s0)
            // LogBLUE("ppte: 0x%llx", ppte);
            *(pmd + ((va >> 21) & 0x1ff)) = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000202a84:	fb843783          	ld	a5,-72(s0)
ffffffe000202a88:	00c7d793          	srli	a5,a5,0xc
ffffffe000202a8c:	00a79713          	slli	a4,a5,0xa
ffffffe000202a90:	fa043783          	ld	a5,-96(s0)
ffffffe000202a94:	0157d793          	srli	a5,a5,0x15
ffffffe000202a98:	1ff7f793          	andi	a5,a5,511
ffffffe000202a9c:	00379793          	slli	a5,a5,0x3
ffffffe000202aa0:	fc043683          	ld	a3,-64(s0)
ffffffe000202aa4:	00f687b3          	add	a5,a3,a5
ffffffe000202aa8:	00176713          	ori	a4,a4,1
ffffffe000202aac:	00e7b023          	sd	a4,0(a5)
            pmd_entry = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000202ab0:	fb843783          	ld	a5,-72(s0)
ffffffe000202ab4:	00c7d793          	srli	a5,a5,0xc
ffffffe000202ab8:	00a79793          	slli	a5,a5,0xa
ffffffe000202abc:	0017e793          	ori	a5,a5,1
ffffffe000202ac0:	fef43023          	sd	a5,-32(s0)
        }
        
        pte = (uint64_t*) (((pmd_entry >> 10) << 12) + PA2VA_OFFSET); // pte此时是PTE页表的虚拟地址
ffffffe000202ac4:	fe043783          	ld	a5,-32(s0)
ffffffe000202ac8:	00a7d793          	srli	a5,a5,0xa
ffffffe000202acc:	00c79713          	slli	a4,a5,0xc
ffffffe000202ad0:	fbf00793          	li	a5,-65
ffffffe000202ad4:	01f79793          	slli	a5,a5,0x1f
ffffffe000202ad8:	00f707b3          	add	a5,a4,a5
ffffffe000202adc:	faf43823          	sd	a5,-80(s0)
        *(pte + ((va >> 12) & 0x1ff)) = ((pa >> 12) << 10) | perm ;
ffffffe000202ae0:	f9843783          	ld	a5,-104(s0)
ffffffe000202ae4:	00c7d793          	srli	a5,a5,0xc
ffffffe000202ae8:	00a79693          	slli	a3,a5,0xa
ffffffe000202aec:	fa043783          	ld	a5,-96(s0)
ffffffe000202af0:	00c7d793          	srli	a5,a5,0xc
ffffffe000202af4:	1ff7f793          	andi	a5,a5,511
ffffffe000202af8:	00379793          	slli	a5,a5,0x3
ffffffe000202afc:	fb043703          	ld	a4,-80(s0)
ffffffe000202b00:	00f707b3          	add	a5,a4,a5
ffffffe000202b04:	f8843703          	ld	a4,-120(s0)
ffffffe000202b08:	00e6e733          	or	a4,a3,a4
ffffffe000202b0c:	00e7b023          	sd	a4,0(a5)


        // if(va <= 0xffffffe000209000)LogBLUE("va: 0x%llx, pa: 0x%llx, perm: 0x%llx", va, pa, perm);
        va += PGSIZE;
ffffffe000202b10:	fa043703          	ld	a4,-96(s0)
ffffffe000202b14:	000017b7          	lui	a5,0x1
ffffffe000202b18:	00f707b3          	add	a5,a4,a5
ffffffe000202b1c:	faf43023          	sd	a5,-96(s0)
        pa += PGSIZE;
ffffffe000202b20:	f9843703          	ld	a4,-104(s0)
ffffffe000202b24:	000017b7          	lui	a5,0x1
ffffffe000202b28:	00f707b3          	add	a5,a4,a5
ffffffe000202b2c:	f8f43c23          	sd	a5,-104(s0)
    while(va < vlimit){
ffffffe000202b30:	fa043703          	ld	a4,-96(s0)
ffffffe000202b34:	fd843783          	ld	a5,-40(s0)
ffffffe000202b38:	e6f760e3          	bltu	a4,a5,ffffffe000202998 <create_mapping+0x94>
    }
    
}
ffffffe000202b3c:	00000013          	nop
ffffffe000202b40:	00000013          	nop
ffffffe000202b44:	08813083          	ld	ra,136(sp)
ffffffe000202b48:	08013403          	ld	s0,128(sp)
ffffffe000202b4c:	09010113          	addi	sp,sp,144
ffffffe000202b50:	00008067          	ret

ffffffe000202b54 <start_kernel>:
extern void test();

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

int start_kernel() {
ffffffe000202b54:	ff010113          	addi	sp,sp,-16
ffffffe000202b58:	00113423          	sd	ra,8(sp)
ffffffe000202b5c:	00813023          	sd	s0,0(sp)
ffffffe000202b60:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000202b64:	00002517          	auipc	a0,0x2
ffffffe000202b68:	b9450513          	addi	a0,a0,-1132 # ffffffe0002046f8 <__func__.0+0x10>
ffffffe000202b6c:	715000ef          	jal	ra,ffffffe000203a80 <printk>
    printk(" ZJU Operating System\n");
ffffffe000202b70:	00002517          	auipc	a0,0x2
ffffffe000202b74:	b9050513          	addi	a0,a0,-1136 # ffffffe000204700 <__func__.0+0x18>
ffffffe000202b78:	709000ef          	jal	ra,ffffffe000203a80 <printk>
    schedule();
ffffffe000202b7c:	9a4fe0ef          	jal	ra,ffffffe000200d20 <schedule>

    test();
ffffffe000202b80:	01c000ef          	jal	ra,ffffffe000202b9c <test>
    return 0;
ffffffe000202b84:	00000793          	li	a5,0
}
ffffffe000202b88:	00078513          	mv	a0,a5
ffffffe000202b8c:	00813083          	ld	ra,8(sp)
ffffffe000202b90:	00013403          	ld	s0,0(sp)
ffffffe000202b94:	01010113          	addi	sp,sp,16
ffffffe000202b98:	00008067          	ret

ffffffe000202b9c <test>:
#include "printk.h"

void test() {
ffffffe000202b9c:	fe010113          	addi	sp,sp,-32
ffffffe000202ba0:	00113c23          	sd	ra,24(sp)
ffffffe000202ba4:	00813823          	sd	s0,16(sp)
ffffffe000202ba8:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe000202bac:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000202bb0:	fec42783          	lw	a5,-20(s0)
ffffffe000202bb4:	0017879b          	addiw	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe000202bb8:	fef42623          	sw	a5,-20(s0)
ffffffe000202bbc:	fec42783          	lw	a5,-20(s0)
ffffffe000202bc0:	00078713          	mv	a4,a5
ffffffe000202bc4:	05f5e7b7          	lui	a5,0x5f5e
ffffffe000202bc8:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe000202bcc:	02f767bb          	remw	a5,a4,a5
ffffffe000202bd0:	0007879b          	sext.w	a5,a5
ffffffe000202bd4:	fc079ee3          	bnez	a5,ffffffe000202bb0 <test+0x14>
            printk("kernel is running!\n");
ffffffe000202bd8:	00002517          	auipc	a0,0x2
ffffffe000202bdc:	b4050513          	addi	a0,a0,-1216 # ffffffe000204718 <__func__.0+0x30>
ffffffe000202be0:	6a1000ef          	jal	ra,ffffffe000203a80 <printk>
            i = 0;
ffffffe000202be4:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000202be8:	fc9ff06f          	j	ffffffe000202bb0 <test+0x14>

ffffffe000202bec <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe000202bec:	fe010113          	addi	sp,sp,-32
ffffffe000202bf0:	00113c23          	sd	ra,24(sp)
ffffffe000202bf4:	00813823          	sd	s0,16(sp)
ffffffe000202bf8:	02010413          	addi	s0,sp,32
ffffffe000202bfc:	00050793          	mv	a5,a0
ffffffe000202c00:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000202c04:	fec42783          	lw	a5,-20(s0)
ffffffe000202c08:	0ff7f793          	zext.b	a5,a5
ffffffe000202c0c:	00078513          	mv	a0,a5
ffffffe000202c10:	9d9fe0ef          	jal	ra,ffffffe0002015e8 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000202c14:	fec42783          	lw	a5,-20(s0)
ffffffe000202c18:	0ff7f793          	zext.b	a5,a5
ffffffe000202c1c:	0007879b          	sext.w	a5,a5
}
ffffffe000202c20:	00078513          	mv	a0,a5
ffffffe000202c24:	01813083          	ld	ra,24(sp)
ffffffe000202c28:	01013403          	ld	s0,16(sp)
ffffffe000202c2c:	02010113          	addi	sp,sp,32
ffffffe000202c30:	00008067          	ret

ffffffe000202c34 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000202c34:	fe010113          	addi	sp,sp,-32
ffffffe000202c38:	00813c23          	sd	s0,24(sp)
ffffffe000202c3c:	02010413          	addi	s0,sp,32
ffffffe000202c40:	00050793          	mv	a5,a0
ffffffe000202c44:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000202c48:	fec42783          	lw	a5,-20(s0)
ffffffe000202c4c:	0007871b          	sext.w	a4,a5
ffffffe000202c50:	02000793          	li	a5,32
ffffffe000202c54:	02f70263          	beq	a4,a5,ffffffe000202c78 <isspace+0x44>
ffffffe000202c58:	fec42783          	lw	a5,-20(s0)
ffffffe000202c5c:	0007871b          	sext.w	a4,a5
ffffffe000202c60:	00800793          	li	a5,8
ffffffe000202c64:	00e7de63          	bge	a5,a4,ffffffe000202c80 <isspace+0x4c>
ffffffe000202c68:	fec42783          	lw	a5,-20(s0)
ffffffe000202c6c:	0007871b          	sext.w	a4,a5
ffffffe000202c70:	00d00793          	li	a5,13
ffffffe000202c74:	00e7c663          	blt	a5,a4,ffffffe000202c80 <isspace+0x4c>
ffffffe000202c78:	00100793          	li	a5,1
ffffffe000202c7c:	0080006f          	j	ffffffe000202c84 <isspace+0x50>
ffffffe000202c80:	00000793          	li	a5,0
}
ffffffe000202c84:	00078513          	mv	a0,a5
ffffffe000202c88:	01813403          	ld	s0,24(sp)
ffffffe000202c8c:	02010113          	addi	sp,sp,32
ffffffe000202c90:	00008067          	ret

ffffffe000202c94 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000202c94:	fb010113          	addi	sp,sp,-80
ffffffe000202c98:	04113423          	sd	ra,72(sp)
ffffffe000202c9c:	04813023          	sd	s0,64(sp)
ffffffe000202ca0:	05010413          	addi	s0,sp,80
ffffffe000202ca4:	fca43423          	sd	a0,-56(s0)
ffffffe000202ca8:	fcb43023          	sd	a1,-64(s0)
ffffffe000202cac:	00060793          	mv	a5,a2
ffffffe000202cb0:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000202cb4:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000202cb8:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000202cbc:	fc843783          	ld	a5,-56(s0)
ffffffe000202cc0:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000202cc4:	0100006f          	j	ffffffe000202cd4 <strtol+0x40>
        p++;
ffffffe000202cc8:	fd843783          	ld	a5,-40(s0)
ffffffe000202ccc:	00178793          	addi	a5,a5,1
ffffffe000202cd0:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000202cd4:	fd843783          	ld	a5,-40(s0)
ffffffe000202cd8:	0007c783          	lbu	a5,0(a5)
ffffffe000202cdc:	0007879b          	sext.w	a5,a5
ffffffe000202ce0:	00078513          	mv	a0,a5
ffffffe000202ce4:	f51ff0ef          	jal	ra,ffffffe000202c34 <isspace>
ffffffe000202ce8:	00050793          	mv	a5,a0
ffffffe000202cec:	fc079ee3          	bnez	a5,ffffffe000202cc8 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000202cf0:	fd843783          	ld	a5,-40(s0)
ffffffe000202cf4:	0007c783          	lbu	a5,0(a5)
ffffffe000202cf8:	00078713          	mv	a4,a5
ffffffe000202cfc:	02d00793          	li	a5,45
ffffffe000202d00:	00f71e63          	bne	a4,a5,ffffffe000202d1c <strtol+0x88>
        neg = true;
ffffffe000202d04:	00100793          	li	a5,1
ffffffe000202d08:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe000202d0c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d10:	00178793          	addi	a5,a5,1
ffffffe000202d14:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202d18:	0240006f          	j	ffffffe000202d3c <strtol+0xa8>
    } else if (*p == '+') {
ffffffe000202d1c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d20:	0007c783          	lbu	a5,0(a5)
ffffffe000202d24:	00078713          	mv	a4,a5
ffffffe000202d28:	02b00793          	li	a5,43
ffffffe000202d2c:	00f71863          	bne	a4,a5,ffffffe000202d3c <strtol+0xa8>
        p++;
ffffffe000202d30:	fd843783          	ld	a5,-40(s0)
ffffffe000202d34:	00178793          	addi	a5,a5,1
ffffffe000202d38:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe000202d3c:	fbc42783          	lw	a5,-68(s0)
ffffffe000202d40:	0007879b          	sext.w	a5,a5
ffffffe000202d44:	06079c63          	bnez	a5,ffffffe000202dbc <strtol+0x128>
        if (*p == '0') {
ffffffe000202d48:	fd843783          	ld	a5,-40(s0)
ffffffe000202d4c:	0007c783          	lbu	a5,0(a5)
ffffffe000202d50:	00078713          	mv	a4,a5
ffffffe000202d54:	03000793          	li	a5,48
ffffffe000202d58:	04f71e63          	bne	a4,a5,ffffffe000202db4 <strtol+0x120>
            p++;
ffffffe000202d5c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d60:	00178793          	addi	a5,a5,1
ffffffe000202d64:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000202d68:	fd843783          	ld	a5,-40(s0)
ffffffe000202d6c:	0007c783          	lbu	a5,0(a5)
ffffffe000202d70:	00078713          	mv	a4,a5
ffffffe000202d74:	07800793          	li	a5,120
ffffffe000202d78:	00f70c63          	beq	a4,a5,ffffffe000202d90 <strtol+0xfc>
ffffffe000202d7c:	fd843783          	ld	a5,-40(s0)
ffffffe000202d80:	0007c783          	lbu	a5,0(a5)
ffffffe000202d84:	00078713          	mv	a4,a5
ffffffe000202d88:	05800793          	li	a5,88
ffffffe000202d8c:	00f71e63          	bne	a4,a5,ffffffe000202da8 <strtol+0x114>
                base = 16;
ffffffe000202d90:	01000793          	li	a5,16
ffffffe000202d94:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000202d98:	fd843783          	ld	a5,-40(s0)
ffffffe000202d9c:	00178793          	addi	a5,a5,1
ffffffe000202da0:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202da4:	0180006f          	j	ffffffe000202dbc <strtol+0x128>
            } else {
                base = 8;
ffffffe000202da8:	00800793          	li	a5,8
ffffffe000202dac:	faf42e23          	sw	a5,-68(s0)
ffffffe000202db0:	00c0006f          	j	ffffffe000202dbc <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000202db4:	00a00793          	li	a5,10
ffffffe000202db8:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000202dbc:	fd843783          	ld	a5,-40(s0)
ffffffe000202dc0:	0007c783          	lbu	a5,0(a5)
ffffffe000202dc4:	00078713          	mv	a4,a5
ffffffe000202dc8:	02f00793          	li	a5,47
ffffffe000202dcc:	02e7f863          	bgeu	a5,a4,ffffffe000202dfc <strtol+0x168>
ffffffe000202dd0:	fd843783          	ld	a5,-40(s0)
ffffffe000202dd4:	0007c783          	lbu	a5,0(a5)
ffffffe000202dd8:	00078713          	mv	a4,a5
ffffffe000202ddc:	03900793          	li	a5,57
ffffffe000202de0:	00e7ee63          	bltu	a5,a4,ffffffe000202dfc <strtol+0x168>
            digit = *p - '0';
ffffffe000202de4:	fd843783          	ld	a5,-40(s0)
ffffffe000202de8:	0007c783          	lbu	a5,0(a5)
ffffffe000202dec:	0007879b          	sext.w	a5,a5
ffffffe000202df0:	fd07879b          	addiw	a5,a5,-48
ffffffe000202df4:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202df8:	0800006f          	j	ffffffe000202e78 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe000202dfc:	fd843783          	ld	a5,-40(s0)
ffffffe000202e00:	0007c783          	lbu	a5,0(a5)
ffffffe000202e04:	00078713          	mv	a4,a5
ffffffe000202e08:	06000793          	li	a5,96
ffffffe000202e0c:	02e7f863          	bgeu	a5,a4,ffffffe000202e3c <strtol+0x1a8>
ffffffe000202e10:	fd843783          	ld	a5,-40(s0)
ffffffe000202e14:	0007c783          	lbu	a5,0(a5)
ffffffe000202e18:	00078713          	mv	a4,a5
ffffffe000202e1c:	07a00793          	li	a5,122
ffffffe000202e20:	00e7ee63          	bltu	a5,a4,ffffffe000202e3c <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000202e24:	fd843783          	ld	a5,-40(s0)
ffffffe000202e28:	0007c783          	lbu	a5,0(a5)
ffffffe000202e2c:	0007879b          	sext.w	a5,a5
ffffffe000202e30:	fa97879b          	addiw	a5,a5,-87
ffffffe000202e34:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202e38:	0400006f          	j	ffffffe000202e78 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe000202e3c:	fd843783          	ld	a5,-40(s0)
ffffffe000202e40:	0007c783          	lbu	a5,0(a5)
ffffffe000202e44:	00078713          	mv	a4,a5
ffffffe000202e48:	04000793          	li	a5,64
ffffffe000202e4c:	06e7f863          	bgeu	a5,a4,ffffffe000202ebc <strtol+0x228>
ffffffe000202e50:	fd843783          	ld	a5,-40(s0)
ffffffe000202e54:	0007c783          	lbu	a5,0(a5)
ffffffe000202e58:	00078713          	mv	a4,a5
ffffffe000202e5c:	05a00793          	li	a5,90
ffffffe000202e60:	04e7ee63          	bltu	a5,a4,ffffffe000202ebc <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000202e64:	fd843783          	ld	a5,-40(s0)
ffffffe000202e68:	0007c783          	lbu	a5,0(a5)
ffffffe000202e6c:	0007879b          	sext.w	a5,a5
ffffffe000202e70:	fc97879b          	addiw	a5,a5,-55
ffffffe000202e74:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000202e78:	fd442783          	lw	a5,-44(s0)
ffffffe000202e7c:	00078713          	mv	a4,a5
ffffffe000202e80:	fbc42783          	lw	a5,-68(s0)
ffffffe000202e84:	0007071b          	sext.w	a4,a4
ffffffe000202e88:	0007879b          	sext.w	a5,a5
ffffffe000202e8c:	02f75663          	bge	a4,a5,ffffffe000202eb8 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe000202e90:	fbc42703          	lw	a4,-68(s0)
ffffffe000202e94:	fe843783          	ld	a5,-24(s0)
ffffffe000202e98:	02f70733          	mul	a4,a4,a5
ffffffe000202e9c:	fd442783          	lw	a5,-44(s0)
ffffffe000202ea0:	00f707b3          	add	a5,a4,a5
ffffffe000202ea4:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000202ea8:	fd843783          	ld	a5,-40(s0)
ffffffe000202eac:	00178793          	addi	a5,a5,1
ffffffe000202eb0:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000202eb4:	f09ff06f          	j	ffffffe000202dbc <strtol+0x128>
            break;
ffffffe000202eb8:	00000013          	nop
    }

    if (endptr) {
ffffffe000202ebc:	fc043783          	ld	a5,-64(s0)
ffffffe000202ec0:	00078863          	beqz	a5,ffffffe000202ed0 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe000202ec4:	fc043783          	ld	a5,-64(s0)
ffffffe000202ec8:	fd843703          	ld	a4,-40(s0)
ffffffe000202ecc:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000202ed0:	fe744783          	lbu	a5,-25(s0)
ffffffe000202ed4:	0ff7f793          	zext.b	a5,a5
ffffffe000202ed8:	00078863          	beqz	a5,ffffffe000202ee8 <strtol+0x254>
ffffffe000202edc:	fe843783          	ld	a5,-24(s0)
ffffffe000202ee0:	40f007b3          	neg	a5,a5
ffffffe000202ee4:	0080006f          	j	ffffffe000202eec <strtol+0x258>
ffffffe000202ee8:	fe843783          	ld	a5,-24(s0)
}
ffffffe000202eec:	00078513          	mv	a0,a5
ffffffe000202ef0:	04813083          	ld	ra,72(sp)
ffffffe000202ef4:	04013403          	ld	s0,64(sp)
ffffffe000202ef8:	05010113          	addi	sp,sp,80
ffffffe000202efc:	00008067          	ret

ffffffe000202f00 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000202f00:	fd010113          	addi	sp,sp,-48
ffffffe000202f04:	02113423          	sd	ra,40(sp)
ffffffe000202f08:	02813023          	sd	s0,32(sp)
ffffffe000202f0c:	03010413          	addi	s0,sp,48
ffffffe000202f10:	fca43c23          	sd	a0,-40(s0)
ffffffe000202f14:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000202f18:	fd043783          	ld	a5,-48(s0)
ffffffe000202f1c:	00079863          	bnez	a5,ffffffe000202f2c <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe000202f20:	00002797          	auipc	a5,0x2
ffffffe000202f24:	81078793          	addi	a5,a5,-2032 # ffffffe000204730 <__func__.0+0x48>
ffffffe000202f28:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe000202f2c:	fd043783          	ld	a5,-48(s0)
ffffffe000202f30:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000202f34:	0240006f          	j	ffffffe000202f58 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000202f38:	fe843783          	ld	a5,-24(s0)
ffffffe000202f3c:	00178713          	addi	a4,a5,1
ffffffe000202f40:	fee43423          	sd	a4,-24(s0)
ffffffe000202f44:	0007c783          	lbu	a5,0(a5)
ffffffe000202f48:	0007871b          	sext.w	a4,a5
ffffffe000202f4c:	fd843783          	ld	a5,-40(s0)
ffffffe000202f50:	00070513          	mv	a0,a4
ffffffe000202f54:	000780e7          	jalr	a5
    while (*p) {
ffffffe000202f58:	fe843783          	ld	a5,-24(s0)
ffffffe000202f5c:	0007c783          	lbu	a5,0(a5)
ffffffe000202f60:	fc079ce3          	bnez	a5,ffffffe000202f38 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000202f64:	fe843703          	ld	a4,-24(s0)
ffffffe000202f68:	fd043783          	ld	a5,-48(s0)
ffffffe000202f6c:	40f707b3          	sub	a5,a4,a5
ffffffe000202f70:	0007879b          	sext.w	a5,a5
}
ffffffe000202f74:	00078513          	mv	a0,a5
ffffffe000202f78:	02813083          	ld	ra,40(sp)
ffffffe000202f7c:	02013403          	ld	s0,32(sp)
ffffffe000202f80:	03010113          	addi	sp,sp,48
ffffffe000202f84:	00008067          	ret

ffffffe000202f88 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000202f88:	f9010113          	addi	sp,sp,-112
ffffffe000202f8c:	06113423          	sd	ra,104(sp)
ffffffe000202f90:	06813023          	sd	s0,96(sp)
ffffffe000202f94:	07010413          	addi	s0,sp,112
ffffffe000202f98:	faa43423          	sd	a0,-88(s0)
ffffffe000202f9c:	fab43023          	sd	a1,-96(s0)
ffffffe000202fa0:	00060793          	mv	a5,a2
ffffffe000202fa4:	f8d43823          	sd	a3,-112(s0)
ffffffe000202fa8:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000202fac:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202fb0:	0ff7f793          	zext.b	a5,a5
ffffffe000202fb4:	02078663          	beqz	a5,ffffffe000202fe0 <print_dec_int+0x58>
ffffffe000202fb8:	fa043703          	ld	a4,-96(s0)
ffffffe000202fbc:	fff00793          	li	a5,-1
ffffffe000202fc0:	03f79793          	slli	a5,a5,0x3f
ffffffe000202fc4:	00f71e63          	bne	a4,a5,ffffffe000202fe0 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000202fc8:	00001597          	auipc	a1,0x1
ffffffe000202fcc:	77058593          	addi	a1,a1,1904 # ffffffe000204738 <__func__.0+0x50>
ffffffe000202fd0:	fa843503          	ld	a0,-88(s0)
ffffffe000202fd4:	f2dff0ef          	jal	ra,ffffffe000202f00 <puts_wo_nl>
ffffffe000202fd8:	00050793          	mv	a5,a0
ffffffe000202fdc:	2a00006f          	j	ffffffe00020327c <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000202fe0:	f9043783          	ld	a5,-112(s0)
ffffffe000202fe4:	00c7a783          	lw	a5,12(a5)
ffffffe000202fe8:	00079a63          	bnez	a5,ffffffe000202ffc <print_dec_int+0x74>
ffffffe000202fec:	fa043783          	ld	a5,-96(s0)
ffffffe000202ff0:	00079663          	bnez	a5,ffffffe000202ffc <print_dec_int+0x74>
        return 0;
ffffffe000202ff4:	00000793          	li	a5,0
ffffffe000202ff8:	2840006f          	j	ffffffe00020327c <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000202ffc:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000203000:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203004:	0ff7f793          	zext.b	a5,a5
ffffffe000203008:	02078063          	beqz	a5,ffffffe000203028 <print_dec_int+0xa0>
ffffffe00020300c:	fa043783          	ld	a5,-96(s0)
ffffffe000203010:	0007dc63          	bgez	a5,ffffffe000203028 <print_dec_int+0xa0>
        neg = true;
ffffffe000203014:	00100793          	li	a5,1
ffffffe000203018:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe00020301c:	fa043783          	ld	a5,-96(s0)
ffffffe000203020:	40f007b3          	neg	a5,a5
ffffffe000203024:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000203028:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe00020302c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203030:	0ff7f793          	zext.b	a5,a5
ffffffe000203034:	02078863          	beqz	a5,ffffffe000203064 <print_dec_int+0xdc>
ffffffe000203038:	fef44783          	lbu	a5,-17(s0)
ffffffe00020303c:	0ff7f793          	zext.b	a5,a5
ffffffe000203040:	00079e63          	bnez	a5,ffffffe00020305c <print_dec_int+0xd4>
ffffffe000203044:	f9043783          	ld	a5,-112(s0)
ffffffe000203048:	0057c783          	lbu	a5,5(a5)
ffffffe00020304c:	00079863          	bnez	a5,ffffffe00020305c <print_dec_int+0xd4>
ffffffe000203050:	f9043783          	ld	a5,-112(s0)
ffffffe000203054:	0047c783          	lbu	a5,4(a5)
ffffffe000203058:	00078663          	beqz	a5,ffffffe000203064 <print_dec_int+0xdc>
ffffffe00020305c:	00100793          	li	a5,1
ffffffe000203060:	0080006f          	j	ffffffe000203068 <print_dec_int+0xe0>
ffffffe000203064:	00000793          	li	a5,0
ffffffe000203068:	fcf40ba3          	sb	a5,-41(s0)
ffffffe00020306c:	fd744783          	lbu	a5,-41(s0)
ffffffe000203070:	0017f793          	andi	a5,a5,1
ffffffe000203074:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000203078:	fa043703          	ld	a4,-96(s0)
ffffffe00020307c:	00a00793          	li	a5,10
ffffffe000203080:	02f777b3          	remu	a5,a4,a5
ffffffe000203084:	0ff7f713          	zext.b	a4,a5
ffffffe000203088:	fe842783          	lw	a5,-24(s0)
ffffffe00020308c:	0017869b          	addiw	a3,a5,1
ffffffe000203090:	fed42423          	sw	a3,-24(s0)
ffffffe000203094:	0307071b          	addiw	a4,a4,48
ffffffe000203098:	0ff77713          	zext.b	a4,a4
ffffffe00020309c:	ff078793          	addi	a5,a5,-16
ffffffe0002030a0:	008787b3          	add	a5,a5,s0
ffffffe0002030a4:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe0002030a8:	fa043703          	ld	a4,-96(s0)
ffffffe0002030ac:	00a00793          	li	a5,10
ffffffe0002030b0:	02f757b3          	divu	a5,a4,a5
ffffffe0002030b4:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe0002030b8:	fa043783          	ld	a5,-96(s0)
ffffffe0002030bc:	fa079ee3          	bnez	a5,ffffffe000203078 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe0002030c0:	f9043783          	ld	a5,-112(s0)
ffffffe0002030c4:	00c7a783          	lw	a5,12(a5)
ffffffe0002030c8:	00078713          	mv	a4,a5
ffffffe0002030cc:	fff00793          	li	a5,-1
ffffffe0002030d0:	02f71063          	bne	a4,a5,ffffffe0002030f0 <print_dec_int+0x168>
ffffffe0002030d4:	f9043783          	ld	a5,-112(s0)
ffffffe0002030d8:	0037c783          	lbu	a5,3(a5)
ffffffe0002030dc:	00078a63          	beqz	a5,ffffffe0002030f0 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe0002030e0:	f9043783          	ld	a5,-112(s0)
ffffffe0002030e4:	0087a703          	lw	a4,8(a5)
ffffffe0002030e8:	f9043783          	ld	a5,-112(s0)
ffffffe0002030ec:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe0002030f0:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002030f4:	f9043783          	ld	a5,-112(s0)
ffffffe0002030f8:	0087a703          	lw	a4,8(a5)
ffffffe0002030fc:	fe842783          	lw	a5,-24(s0)
ffffffe000203100:	fcf42823          	sw	a5,-48(s0)
ffffffe000203104:	f9043783          	ld	a5,-112(s0)
ffffffe000203108:	00c7a783          	lw	a5,12(a5)
ffffffe00020310c:	fcf42623          	sw	a5,-52(s0)
ffffffe000203110:	fd042783          	lw	a5,-48(s0)
ffffffe000203114:	00078593          	mv	a1,a5
ffffffe000203118:	fcc42783          	lw	a5,-52(s0)
ffffffe00020311c:	00078613          	mv	a2,a5
ffffffe000203120:	0006069b          	sext.w	a3,a2
ffffffe000203124:	0005879b          	sext.w	a5,a1
ffffffe000203128:	00f6d463          	bge	a3,a5,ffffffe000203130 <print_dec_int+0x1a8>
ffffffe00020312c:	00058613          	mv	a2,a1
ffffffe000203130:	0006079b          	sext.w	a5,a2
ffffffe000203134:	40f707bb          	subw	a5,a4,a5
ffffffe000203138:	0007871b          	sext.w	a4,a5
ffffffe00020313c:	fd744783          	lbu	a5,-41(s0)
ffffffe000203140:	0007879b          	sext.w	a5,a5
ffffffe000203144:	40f707bb          	subw	a5,a4,a5
ffffffe000203148:	fef42023          	sw	a5,-32(s0)
ffffffe00020314c:	0280006f          	j	ffffffe000203174 <print_dec_int+0x1ec>
        putch(' ');
ffffffe000203150:	fa843783          	ld	a5,-88(s0)
ffffffe000203154:	02000513          	li	a0,32
ffffffe000203158:	000780e7          	jalr	a5
        ++written;
ffffffe00020315c:	fe442783          	lw	a5,-28(s0)
ffffffe000203160:	0017879b          	addiw	a5,a5,1
ffffffe000203164:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000203168:	fe042783          	lw	a5,-32(s0)
ffffffe00020316c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203170:	fef42023          	sw	a5,-32(s0)
ffffffe000203174:	fe042783          	lw	a5,-32(s0)
ffffffe000203178:	0007879b          	sext.w	a5,a5
ffffffe00020317c:	fcf04ae3          	bgtz	a5,ffffffe000203150 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000203180:	fd744783          	lbu	a5,-41(s0)
ffffffe000203184:	0ff7f793          	zext.b	a5,a5
ffffffe000203188:	04078463          	beqz	a5,ffffffe0002031d0 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe00020318c:	fef44783          	lbu	a5,-17(s0)
ffffffe000203190:	0ff7f793          	zext.b	a5,a5
ffffffe000203194:	00078663          	beqz	a5,ffffffe0002031a0 <print_dec_int+0x218>
ffffffe000203198:	02d00793          	li	a5,45
ffffffe00020319c:	01c0006f          	j	ffffffe0002031b8 <print_dec_int+0x230>
ffffffe0002031a0:	f9043783          	ld	a5,-112(s0)
ffffffe0002031a4:	0057c783          	lbu	a5,5(a5)
ffffffe0002031a8:	00078663          	beqz	a5,ffffffe0002031b4 <print_dec_int+0x22c>
ffffffe0002031ac:	02b00793          	li	a5,43
ffffffe0002031b0:	0080006f          	j	ffffffe0002031b8 <print_dec_int+0x230>
ffffffe0002031b4:	02000793          	li	a5,32
ffffffe0002031b8:	fa843703          	ld	a4,-88(s0)
ffffffe0002031bc:	00078513          	mv	a0,a5
ffffffe0002031c0:	000700e7          	jalr	a4
        ++written;
ffffffe0002031c4:	fe442783          	lw	a5,-28(s0)
ffffffe0002031c8:	0017879b          	addiw	a5,a5,1
ffffffe0002031cc:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002031d0:	fe842783          	lw	a5,-24(s0)
ffffffe0002031d4:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002031d8:	0280006f          	j	ffffffe000203200 <print_dec_int+0x278>
        putch('0');
ffffffe0002031dc:	fa843783          	ld	a5,-88(s0)
ffffffe0002031e0:	03000513          	li	a0,48
ffffffe0002031e4:	000780e7          	jalr	a5
        ++written;
ffffffe0002031e8:	fe442783          	lw	a5,-28(s0)
ffffffe0002031ec:	0017879b          	addiw	a5,a5,1
ffffffe0002031f0:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002031f4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002031f8:	0017879b          	addiw	a5,a5,1
ffffffe0002031fc:	fcf42e23          	sw	a5,-36(s0)
ffffffe000203200:	f9043783          	ld	a5,-112(s0)
ffffffe000203204:	00c7a703          	lw	a4,12(a5)
ffffffe000203208:	fd744783          	lbu	a5,-41(s0)
ffffffe00020320c:	0007879b          	sext.w	a5,a5
ffffffe000203210:	40f707bb          	subw	a5,a4,a5
ffffffe000203214:	0007871b          	sext.w	a4,a5
ffffffe000203218:	fdc42783          	lw	a5,-36(s0)
ffffffe00020321c:	0007879b          	sext.w	a5,a5
ffffffe000203220:	fae7cee3          	blt	a5,a4,ffffffe0002031dc <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203224:	fe842783          	lw	a5,-24(s0)
ffffffe000203228:	fff7879b          	addiw	a5,a5,-1
ffffffe00020322c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203230:	03c0006f          	j	ffffffe00020326c <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000203234:	fd842783          	lw	a5,-40(s0)
ffffffe000203238:	ff078793          	addi	a5,a5,-16
ffffffe00020323c:	008787b3          	add	a5,a5,s0
ffffffe000203240:	fc87c783          	lbu	a5,-56(a5)
ffffffe000203244:	0007871b          	sext.w	a4,a5
ffffffe000203248:	fa843783          	ld	a5,-88(s0)
ffffffe00020324c:	00070513          	mv	a0,a4
ffffffe000203250:	000780e7          	jalr	a5
        ++written;
ffffffe000203254:	fe442783          	lw	a5,-28(s0)
ffffffe000203258:	0017879b          	addiw	a5,a5,1
ffffffe00020325c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203260:	fd842783          	lw	a5,-40(s0)
ffffffe000203264:	fff7879b          	addiw	a5,a5,-1
ffffffe000203268:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020326c:	fd842783          	lw	a5,-40(s0)
ffffffe000203270:	0007879b          	sext.w	a5,a5
ffffffe000203274:	fc07d0e3          	bgez	a5,ffffffe000203234 <print_dec_int+0x2ac>
    }

    return written;
ffffffe000203278:	fe442783          	lw	a5,-28(s0)
}
ffffffe00020327c:	00078513          	mv	a0,a5
ffffffe000203280:	06813083          	ld	ra,104(sp)
ffffffe000203284:	06013403          	ld	s0,96(sp)
ffffffe000203288:	07010113          	addi	sp,sp,112
ffffffe00020328c:	00008067          	ret

ffffffe000203290 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000203290:	f4010113          	addi	sp,sp,-192
ffffffe000203294:	0a113c23          	sd	ra,184(sp)
ffffffe000203298:	0a813823          	sd	s0,176(sp)
ffffffe00020329c:	0c010413          	addi	s0,sp,192
ffffffe0002032a0:	f4a43c23          	sd	a0,-168(s0)
ffffffe0002032a4:	f4b43823          	sd	a1,-176(s0)
ffffffe0002032a8:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe0002032ac:	f8043023          	sd	zero,-128(s0)
ffffffe0002032b0:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe0002032b4:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe0002032b8:	7a40006f          	j	ffffffe000203a5c <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe0002032bc:	f8044783          	lbu	a5,-128(s0)
ffffffe0002032c0:	72078e63          	beqz	a5,ffffffe0002039fc <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe0002032c4:	f5043783          	ld	a5,-176(s0)
ffffffe0002032c8:	0007c783          	lbu	a5,0(a5)
ffffffe0002032cc:	00078713          	mv	a4,a5
ffffffe0002032d0:	02300793          	li	a5,35
ffffffe0002032d4:	00f71863          	bne	a4,a5,ffffffe0002032e4 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe0002032d8:	00100793          	li	a5,1
ffffffe0002032dc:	f8f40123          	sb	a5,-126(s0)
ffffffe0002032e0:	7700006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe0002032e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002032e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002032ec:	00078713          	mv	a4,a5
ffffffe0002032f0:	03000793          	li	a5,48
ffffffe0002032f4:	00f71863          	bne	a4,a5,ffffffe000203304 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe0002032f8:	00100793          	li	a5,1
ffffffe0002032fc:	f8f401a3          	sb	a5,-125(s0)
ffffffe000203300:	7500006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe000203304:	f5043783          	ld	a5,-176(s0)
ffffffe000203308:	0007c783          	lbu	a5,0(a5)
ffffffe00020330c:	00078713          	mv	a4,a5
ffffffe000203310:	06c00793          	li	a5,108
ffffffe000203314:	04f70063          	beq	a4,a5,ffffffe000203354 <vprintfmt+0xc4>
ffffffe000203318:	f5043783          	ld	a5,-176(s0)
ffffffe00020331c:	0007c783          	lbu	a5,0(a5)
ffffffe000203320:	00078713          	mv	a4,a5
ffffffe000203324:	07a00793          	li	a5,122
ffffffe000203328:	02f70663          	beq	a4,a5,ffffffe000203354 <vprintfmt+0xc4>
ffffffe00020332c:	f5043783          	ld	a5,-176(s0)
ffffffe000203330:	0007c783          	lbu	a5,0(a5)
ffffffe000203334:	00078713          	mv	a4,a5
ffffffe000203338:	07400793          	li	a5,116
ffffffe00020333c:	00f70c63          	beq	a4,a5,ffffffe000203354 <vprintfmt+0xc4>
ffffffe000203340:	f5043783          	ld	a5,-176(s0)
ffffffe000203344:	0007c783          	lbu	a5,0(a5)
ffffffe000203348:	00078713          	mv	a4,a5
ffffffe00020334c:	06a00793          	li	a5,106
ffffffe000203350:	00f71863          	bne	a4,a5,ffffffe000203360 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000203354:	00100793          	li	a5,1
ffffffe000203358:	f8f400a3          	sb	a5,-127(s0)
ffffffe00020335c:	6f40006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000203360:	f5043783          	ld	a5,-176(s0)
ffffffe000203364:	0007c783          	lbu	a5,0(a5)
ffffffe000203368:	00078713          	mv	a4,a5
ffffffe00020336c:	02b00793          	li	a5,43
ffffffe000203370:	00f71863          	bne	a4,a5,ffffffe000203380 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000203374:	00100793          	li	a5,1
ffffffe000203378:	f8f402a3          	sb	a5,-123(s0)
ffffffe00020337c:	6d40006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000203380:	f5043783          	ld	a5,-176(s0)
ffffffe000203384:	0007c783          	lbu	a5,0(a5)
ffffffe000203388:	00078713          	mv	a4,a5
ffffffe00020338c:	02000793          	li	a5,32
ffffffe000203390:	00f71863          	bne	a4,a5,ffffffe0002033a0 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000203394:	00100793          	li	a5,1
ffffffe000203398:	f8f40223          	sb	a5,-124(s0)
ffffffe00020339c:	6b40006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe0002033a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002033a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002033a8:	00078713          	mv	a4,a5
ffffffe0002033ac:	02a00793          	li	a5,42
ffffffe0002033b0:	00f71e63          	bne	a4,a5,ffffffe0002033cc <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe0002033b4:	f4843783          	ld	a5,-184(s0)
ffffffe0002033b8:	00878713          	addi	a4,a5,8
ffffffe0002033bc:	f4e43423          	sd	a4,-184(s0)
ffffffe0002033c0:	0007a783          	lw	a5,0(a5)
ffffffe0002033c4:	f8f42423          	sw	a5,-120(s0)
ffffffe0002033c8:	6880006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe0002033cc:	f5043783          	ld	a5,-176(s0)
ffffffe0002033d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002033d4:	00078713          	mv	a4,a5
ffffffe0002033d8:	03000793          	li	a5,48
ffffffe0002033dc:	04e7f663          	bgeu	a5,a4,ffffffe000203428 <vprintfmt+0x198>
ffffffe0002033e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002033e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002033e8:	00078713          	mv	a4,a5
ffffffe0002033ec:	03900793          	li	a5,57
ffffffe0002033f0:	02e7ec63          	bltu	a5,a4,ffffffe000203428 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe0002033f4:	f5043783          	ld	a5,-176(s0)
ffffffe0002033f8:	f5040713          	addi	a4,s0,-176
ffffffe0002033fc:	00a00613          	li	a2,10
ffffffe000203400:	00070593          	mv	a1,a4
ffffffe000203404:	00078513          	mv	a0,a5
ffffffe000203408:	88dff0ef          	jal	ra,ffffffe000202c94 <strtol>
ffffffe00020340c:	00050793          	mv	a5,a0
ffffffe000203410:	0007879b          	sext.w	a5,a5
ffffffe000203414:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe000203418:	f5043783          	ld	a5,-176(s0)
ffffffe00020341c:	fff78793          	addi	a5,a5,-1
ffffffe000203420:	f4f43823          	sd	a5,-176(s0)
ffffffe000203424:	62c0006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe000203428:	f5043783          	ld	a5,-176(s0)
ffffffe00020342c:	0007c783          	lbu	a5,0(a5)
ffffffe000203430:	00078713          	mv	a4,a5
ffffffe000203434:	02e00793          	li	a5,46
ffffffe000203438:	06f71863          	bne	a4,a5,ffffffe0002034a8 <vprintfmt+0x218>
                fmt++;
ffffffe00020343c:	f5043783          	ld	a5,-176(s0)
ffffffe000203440:	00178793          	addi	a5,a5,1
ffffffe000203444:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000203448:	f5043783          	ld	a5,-176(s0)
ffffffe00020344c:	0007c783          	lbu	a5,0(a5)
ffffffe000203450:	00078713          	mv	a4,a5
ffffffe000203454:	02a00793          	li	a5,42
ffffffe000203458:	00f71e63          	bne	a4,a5,ffffffe000203474 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe00020345c:	f4843783          	ld	a5,-184(s0)
ffffffe000203460:	00878713          	addi	a4,a5,8
ffffffe000203464:	f4e43423          	sd	a4,-184(s0)
ffffffe000203468:	0007a783          	lw	a5,0(a5)
ffffffe00020346c:	f8f42623          	sw	a5,-116(s0)
ffffffe000203470:	5e00006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000203474:	f5043783          	ld	a5,-176(s0)
ffffffe000203478:	f5040713          	addi	a4,s0,-176
ffffffe00020347c:	00a00613          	li	a2,10
ffffffe000203480:	00070593          	mv	a1,a4
ffffffe000203484:	00078513          	mv	a0,a5
ffffffe000203488:	80dff0ef          	jal	ra,ffffffe000202c94 <strtol>
ffffffe00020348c:	00050793          	mv	a5,a0
ffffffe000203490:	0007879b          	sext.w	a5,a5
ffffffe000203494:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000203498:	f5043783          	ld	a5,-176(s0)
ffffffe00020349c:	fff78793          	addi	a5,a5,-1
ffffffe0002034a0:	f4f43823          	sd	a5,-176(s0)
ffffffe0002034a4:	5ac0006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002034a8:	f5043783          	ld	a5,-176(s0)
ffffffe0002034ac:	0007c783          	lbu	a5,0(a5)
ffffffe0002034b0:	00078713          	mv	a4,a5
ffffffe0002034b4:	07800793          	li	a5,120
ffffffe0002034b8:	02f70663          	beq	a4,a5,ffffffe0002034e4 <vprintfmt+0x254>
ffffffe0002034bc:	f5043783          	ld	a5,-176(s0)
ffffffe0002034c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002034c4:	00078713          	mv	a4,a5
ffffffe0002034c8:	05800793          	li	a5,88
ffffffe0002034cc:	00f70c63          	beq	a4,a5,ffffffe0002034e4 <vprintfmt+0x254>
ffffffe0002034d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002034d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002034d8:	00078713          	mv	a4,a5
ffffffe0002034dc:	07000793          	li	a5,112
ffffffe0002034e0:	30f71263          	bne	a4,a5,ffffffe0002037e4 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe0002034e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002034e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002034ec:	00078713          	mv	a4,a5
ffffffe0002034f0:	07000793          	li	a5,112
ffffffe0002034f4:	00f70663          	beq	a4,a5,ffffffe000203500 <vprintfmt+0x270>
ffffffe0002034f8:	f8144783          	lbu	a5,-127(s0)
ffffffe0002034fc:	00078663          	beqz	a5,ffffffe000203508 <vprintfmt+0x278>
ffffffe000203500:	00100793          	li	a5,1
ffffffe000203504:	0080006f          	j	ffffffe00020350c <vprintfmt+0x27c>
ffffffe000203508:	00000793          	li	a5,0
ffffffe00020350c:	faf403a3          	sb	a5,-89(s0)
ffffffe000203510:	fa744783          	lbu	a5,-89(s0)
ffffffe000203514:	0017f793          	andi	a5,a5,1
ffffffe000203518:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe00020351c:	fa744783          	lbu	a5,-89(s0)
ffffffe000203520:	0ff7f793          	zext.b	a5,a5
ffffffe000203524:	00078c63          	beqz	a5,ffffffe00020353c <vprintfmt+0x2ac>
ffffffe000203528:	f4843783          	ld	a5,-184(s0)
ffffffe00020352c:	00878713          	addi	a4,a5,8
ffffffe000203530:	f4e43423          	sd	a4,-184(s0)
ffffffe000203534:	0007b783          	ld	a5,0(a5)
ffffffe000203538:	01c0006f          	j	ffffffe000203554 <vprintfmt+0x2c4>
ffffffe00020353c:	f4843783          	ld	a5,-184(s0)
ffffffe000203540:	00878713          	addi	a4,a5,8
ffffffe000203544:	f4e43423          	sd	a4,-184(s0)
ffffffe000203548:	0007a783          	lw	a5,0(a5)
ffffffe00020354c:	02079793          	slli	a5,a5,0x20
ffffffe000203550:	0207d793          	srli	a5,a5,0x20
ffffffe000203554:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000203558:	f8c42783          	lw	a5,-116(s0)
ffffffe00020355c:	02079463          	bnez	a5,ffffffe000203584 <vprintfmt+0x2f4>
ffffffe000203560:	fe043783          	ld	a5,-32(s0)
ffffffe000203564:	02079063          	bnez	a5,ffffffe000203584 <vprintfmt+0x2f4>
ffffffe000203568:	f5043783          	ld	a5,-176(s0)
ffffffe00020356c:	0007c783          	lbu	a5,0(a5)
ffffffe000203570:	00078713          	mv	a4,a5
ffffffe000203574:	07000793          	li	a5,112
ffffffe000203578:	00f70663          	beq	a4,a5,ffffffe000203584 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe00020357c:	f8040023          	sb	zero,-128(s0)
ffffffe000203580:	4d00006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000203584:	f5043783          	ld	a5,-176(s0)
ffffffe000203588:	0007c783          	lbu	a5,0(a5)
ffffffe00020358c:	00078713          	mv	a4,a5
ffffffe000203590:	07000793          	li	a5,112
ffffffe000203594:	00f70a63          	beq	a4,a5,ffffffe0002035a8 <vprintfmt+0x318>
ffffffe000203598:	f8244783          	lbu	a5,-126(s0)
ffffffe00020359c:	00078a63          	beqz	a5,ffffffe0002035b0 <vprintfmt+0x320>
ffffffe0002035a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002035a4:	00078663          	beqz	a5,ffffffe0002035b0 <vprintfmt+0x320>
ffffffe0002035a8:	00100793          	li	a5,1
ffffffe0002035ac:	0080006f          	j	ffffffe0002035b4 <vprintfmt+0x324>
ffffffe0002035b0:	00000793          	li	a5,0
ffffffe0002035b4:	faf40323          	sb	a5,-90(s0)
ffffffe0002035b8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002035bc:	0017f793          	andi	a5,a5,1
ffffffe0002035c0:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe0002035c4:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe0002035c8:	f5043783          	ld	a5,-176(s0)
ffffffe0002035cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002035d0:	00078713          	mv	a4,a5
ffffffe0002035d4:	05800793          	li	a5,88
ffffffe0002035d8:	00f71863          	bne	a4,a5,ffffffe0002035e8 <vprintfmt+0x358>
ffffffe0002035dc:	00001797          	auipc	a5,0x1
ffffffe0002035e0:	17478793          	addi	a5,a5,372 # ffffffe000204750 <upperxdigits.1>
ffffffe0002035e4:	00c0006f          	j	ffffffe0002035f0 <vprintfmt+0x360>
ffffffe0002035e8:	00001797          	auipc	a5,0x1
ffffffe0002035ec:	18078793          	addi	a5,a5,384 # ffffffe000204768 <lowerxdigits.0>
ffffffe0002035f0:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe0002035f4:	fe043783          	ld	a5,-32(s0)
ffffffe0002035f8:	00f7f793          	andi	a5,a5,15
ffffffe0002035fc:	f9843703          	ld	a4,-104(s0)
ffffffe000203600:	00f70733          	add	a4,a4,a5
ffffffe000203604:	fdc42783          	lw	a5,-36(s0)
ffffffe000203608:	0017869b          	addiw	a3,a5,1
ffffffe00020360c:	fcd42e23          	sw	a3,-36(s0)
ffffffe000203610:	00074703          	lbu	a4,0(a4)
ffffffe000203614:	ff078793          	addi	a5,a5,-16
ffffffe000203618:	008787b3          	add	a5,a5,s0
ffffffe00020361c:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000203620:	fe043783          	ld	a5,-32(s0)
ffffffe000203624:	0047d793          	srli	a5,a5,0x4
ffffffe000203628:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe00020362c:	fe043783          	ld	a5,-32(s0)
ffffffe000203630:	fc0792e3          	bnez	a5,ffffffe0002035f4 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000203634:	f8c42783          	lw	a5,-116(s0)
ffffffe000203638:	00078713          	mv	a4,a5
ffffffe00020363c:	fff00793          	li	a5,-1
ffffffe000203640:	02f71663          	bne	a4,a5,ffffffe00020366c <vprintfmt+0x3dc>
ffffffe000203644:	f8344783          	lbu	a5,-125(s0)
ffffffe000203648:	02078263          	beqz	a5,ffffffe00020366c <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe00020364c:	f8842703          	lw	a4,-120(s0)
ffffffe000203650:	fa644783          	lbu	a5,-90(s0)
ffffffe000203654:	0007879b          	sext.w	a5,a5
ffffffe000203658:	0017979b          	slliw	a5,a5,0x1
ffffffe00020365c:	0007879b          	sext.w	a5,a5
ffffffe000203660:	40f707bb          	subw	a5,a4,a5
ffffffe000203664:	0007879b          	sext.w	a5,a5
ffffffe000203668:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe00020366c:	f8842703          	lw	a4,-120(s0)
ffffffe000203670:	fa644783          	lbu	a5,-90(s0)
ffffffe000203674:	0007879b          	sext.w	a5,a5
ffffffe000203678:	0017979b          	slliw	a5,a5,0x1
ffffffe00020367c:	0007879b          	sext.w	a5,a5
ffffffe000203680:	40f707bb          	subw	a5,a4,a5
ffffffe000203684:	0007871b          	sext.w	a4,a5
ffffffe000203688:	fdc42783          	lw	a5,-36(s0)
ffffffe00020368c:	f8f42a23          	sw	a5,-108(s0)
ffffffe000203690:	f8c42783          	lw	a5,-116(s0)
ffffffe000203694:	f8f42823          	sw	a5,-112(s0)
ffffffe000203698:	f9442783          	lw	a5,-108(s0)
ffffffe00020369c:	00078593          	mv	a1,a5
ffffffe0002036a0:	f9042783          	lw	a5,-112(s0)
ffffffe0002036a4:	00078613          	mv	a2,a5
ffffffe0002036a8:	0006069b          	sext.w	a3,a2
ffffffe0002036ac:	0005879b          	sext.w	a5,a1
ffffffe0002036b0:	00f6d463          	bge	a3,a5,ffffffe0002036b8 <vprintfmt+0x428>
ffffffe0002036b4:	00058613          	mv	a2,a1
ffffffe0002036b8:	0006079b          	sext.w	a5,a2
ffffffe0002036bc:	40f707bb          	subw	a5,a4,a5
ffffffe0002036c0:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002036c4:	0280006f          	j	ffffffe0002036ec <vprintfmt+0x45c>
                    putch(' ');
ffffffe0002036c8:	f5843783          	ld	a5,-168(s0)
ffffffe0002036cc:	02000513          	li	a0,32
ffffffe0002036d0:	000780e7          	jalr	a5
                    ++written;
ffffffe0002036d4:	fec42783          	lw	a5,-20(s0)
ffffffe0002036d8:	0017879b          	addiw	a5,a5,1
ffffffe0002036dc:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002036e0:	fd842783          	lw	a5,-40(s0)
ffffffe0002036e4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002036e8:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002036ec:	fd842783          	lw	a5,-40(s0)
ffffffe0002036f0:	0007879b          	sext.w	a5,a5
ffffffe0002036f4:	fcf04ae3          	bgtz	a5,ffffffe0002036c8 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe0002036f8:	fa644783          	lbu	a5,-90(s0)
ffffffe0002036fc:	0ff7f793          	zext.b	a5,a5
ffffffe000203700:	04078463          	beqz	a5,ffffffe000203748 <vprintfmt+0x4b8>
                    putch('0');
ffffffe000203704:	f5843783          	ld	a5,-168(s0)
ffffffe000203708:	03000513          	li	a0,48
ffffffe00020370c:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000203710:	f5043783          	ld	a5,-176(s0)
ffffffe000203714:	0007c783          	lbu	a5,0(a5)
ffffffe000203718:	00078713          	mv	a4,a5
ffffffe00020371c:	05800793          	li	a5,88
ffffffe000203720:	00f71663          	bne	a4,a5,ffffffe00020372c <vprintfmt+0x49c>
ffffffe000203724:	05800793          	li	a5,88
ffffffe000203728:	0080006f          	j	ffffffe000203730 <vprintfmt+0x4a0>
ffffffe00020372c:	07800793          	li	a5,120
ffffffe000203730:	f5843703          	ld	a4,-168(s0)
ffffffe000203734:	00078513          	mv	a0,a5
ffffffe000203738:	000700e7          	jalr	a4
                    written += 2;
ffffffe00020373c:	fec42783          	lw	a5,-20(s0)
ffffffe000203740:	0027879b          	addiw	a5,a5,2
ffffffe000203744:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000203748:	fdc42783          	lw	a5,-36(s0)
ffffffe00020374c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203750:	0280006f          	j	ffffffe000203778 <vprintfmt+0x4e8>
                    putch('0');
ffffffe000203754:	f5843783          	ld	a5,-168(s0)
ffffffe000203758:	03000513          	li	a0,48
ffffffe00020375c:	000780e7          	jalr	a5
                    ++written;
ffffffe000203760:	fec42783          	lw	a5,-20(s0)
ffffffe000203764:	0017879b          	addiw	a5,a5,1
ffffffe000203768:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe00020376c:	fd442783          	lw	a5,-44(s0)
ffffffe000203770:	0017879b          	addiw	a5,a5,1
ffffffe000203774:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203778:	f8c42703          	lw	a4,-116(s0)
ffffffe00020377c:	fd442783          	lw	a5,-44(s0)
ffffffe000203780:	0007879b          	sext.w	a5,a5
ffffffe000203784:	fce7c8e3          	blt	a5,a4,ffffffe000203754 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000203788:	fdc42783          	lw	a5,-36(s0)
ffffffe00020378c:	fff7879b          	addiw	a5,a5,-1
ffffffe000203790:	fcf42823          	sw	a5,-48(s0)
ffffffe000203794:	03c0006f          	j	ffffffe0002037d0 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000203798:	fd042783          	lw	a5,-48(s0)
ffffffe00020379c:	ff078793          	addi	a5,a5,-16
ffffffe0002037a0:	008787b3          	add	a5,a5,s0
ffffffe0002037a4:	f807c783          	lbu	a5,-128(a5)
ffffffe0002037a8:	0007871b          	sext.w	a4,a5
ffffffe0002037ac:	f5843783          	ld	a5,-168(s0)
ffffffe0002037b0:	00070513          	mv	a0,a4
ffffffe0002037b4:	000780e7          	jalr	a5
                    ++written;
ffffffe0002037b8:	fec42783          	lw	a5,-20(s0)
ffffffe0002037bc:	0017879b          	addiw	a5,a5,1
ffffffe0002037c0:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe0002037c4:	fd042783          	lw	a5,-48(s0)
ffffffe0002037c8:	fff7879b          	addiw	a5,a5,-1
ffffffe0002037cc:	fcf42823          	sw	a5,-48(s0)
ffffffe0002037d0:	fd042783          	lw	a5,-48(s0)
ffffffe0002037d4:	0007879b          	sext.w	a5,a5
ffffffe0002037d8:	fc07d0e3          	bgez	a5,ffffffe000203798 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe0002037dc:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe0002037e0:	2700006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe0002037e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002037e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002037ec:	00078713          	mv	a4,a5
ffffffe0002037f0:	06400793          	li	a5,100
ffffffe0002037f4:	02f70663          	beq	a4,a5,ffffffe000203820 <vprintfmt+0x590>
ffffffe0002037f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002037fc:	0007c783          	lbu	a5,0(a5)
ffffffe000203800:	00078713          	mv	a4,a5
ffffffe000203804:	06900793          	li	a5,105
ffffffe000203808:	00f70c63          	beq	a4,a5,ffffffe000203820 <vprintfmt+0x590>
ffffffe00020380c:	f5043783          	ld	a5,-176(s0)
ffffffe000203810:	0007c783          	lbu	a5,0(a5)
ffffffe000203814:	00078713          	mv	a4,a5
ffffffe000203818:	07500793          	li	a5,117
ffffffe00020381c:	08f71063          	bne	a4,a5,ffffffe00020389c <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000203820:	f8144783          	lbu	a5,-127(s0)
ffffffe000203824:	00078c63          	beqz	a5,ffffffe00020383c <vprintfmt+0x5ac>
ffffffe000203828:	f4843783          	ld	a5,-184(s0)
ffffffe00020382c:	00878713          	addi	a4,a5,8
ffffffe000203830:	f4e43423          	sd	a4,-184(s0)
ffffffe000203834:	0007b783          	ld	a5,0(a5)
ffffffe000203838:	0140006f          	j	ffffffe00020384c <vprintfmt+0x5bc>
ffffffe00020383c:	f4843783          	ld	a5,-184(s0)
ffffffe000203840:	00878713          	addi	a4,a5,8
ffffffe000203844:	f4e43423          	sd	a4,-184(s0)
ffffffe000203848:	0007a783          	lw	a5,0(a5)
ffffffe00020384c:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000203850:	fa843583          	ld	a1,-88(s0)
ffffffe000203854:	f5043783          	ld	a5,-176(s0)
ffffffe000203858:	0007c783          	lbu	a5,0(a5)
ffffffe00020385c:	0007871b          	sext.w	a4,a5
ffffffe000203860:	07500793          	li	a5,117
ffffffe000203864:	40f707b3          	sub	a5,a4,a5
ffffffe000203868:	00f037b3          	snez	a5,a5
ffffffe00020386c:	0ff7f793          	zext.b	a5,a5
ffffffe000203870:	f8040713          	addi	a4,s0,-128
ffffffe000203874:	00070693          	mv	a3,a4
ffffffe000203878:	00078613          	mv	a2,a5
ffffffe00020387c:	f5843503          	ld	a0,-168(s0)
ffffffe000203880:	f08ff0ef          	jal	ra,ffffffe000202f88 <print_dec_int>
ffffffe000203884:	00050793          	mv	a5,a0
ffffffe000203888:	fec42703          	lw	a4,-20(s0)
ffffffe00020388c:	00f707bb          	addw	a5,a4,a5
ffffffe000203890:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203894:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000203898:	1b80006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe00020389c:	f5043783          	ld	a5,-176(s0)
ffffffe0002038a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002038a4:	00078713          	mv	a4,a5
ffffffe0002038a8:	06e00793          	li	a5,110
ffffffe0002038ac:	04f71c63          	bne	a4,a5,ffffffe000203904 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe0002038b0:	f8144783          	lbu	a5,-127(s0)
ffffffe0002038b4:	02078463          	beqz	a5,ffffffe0002038dc <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe0002038b8:	f4843783          	ld	a5,-184(s0)
ffffffe0002038bc:	00878713          	addi	a4,a5,8
ffffffe0002038c0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002038c4:	0007b783          	ld	a5,0(a5)
ffffffe0002038c8:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe0002038cc:	fec42703          	lw	a4,-20(s0)
ffffffe0002038d0:	fb043783          	ld	a5,-80(s0)
ffffffe0002038d4:	00e7b023          	sd	a4,0(a5)
ffffffe0002038d8:	0240006f          	j	ffffffe0002038fc <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe0002038dc:	f4843783          	ld	a5,-184(s0)
ffffffe0002038e0:	00878713          	addi	a4,a5,8
ffffffe0002038e4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002038e8:	0007b783          	ld	a5,0(a5)
ffffffe0002038ec:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe0002038f0:	fb843783          	ld	a5,-72(s0)
ffffffe0002038f4:	fec42703          	lw	a4,-20(s0)
ffffffe0002038f8:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe0002038fc:	f8040023          	sb	zero,-128(s0)
ffffffe000203900:	1500006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000203904:	f5043783          	ld	a5,-176(s0)
ffffffe000203908:	0007c783          	lbu	a5,0(a5)
ffffffe00020390c:	00078713          	mv	a4,a5
ffffffe000203910:	07300793          	li	a5,115
ffffffe000203914:	02f71e63          	bne	a4,a5,ffffffe000203950 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000203918:	f4843783          	ld	a5,-184(s0)
ffffffe00020391c:	00878713          	addi	a4,a5,8
ffffffe000203920:	f4e43423          	sd	a4,-184(s0)
ffffffe000203924:	0007b783          	ld	a5,0(a5)
ffffffe000203928:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe00020392c:	fc043583          	ld	a1,-64(s0)
ffffffe000203930:	f5843503          	ld	a0,-168(s0)
ffffffe000203934:	dccff0ef          	jal	ra,ffffffe000202f00 <puts_wo_nl>
ffffffe000203938:	00050793          	mv	a5,a0
ffffffe00020393c:	fec42703          	lw	a4,-20(s0)
ffffffe000203940:	00f707bb          	addw	a5,a4,a5
ffffffe000203944:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203948:	f8040023          	sb	zero,-128(s0)
ffffffe00020394c:	1040006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000203950:	f5043783          	ld	a5,-176(s0)
ffffffe000203954:	0007c783          	lbu	a5,0(a5)
ffffffe000203958:	00078713          	mv	a4,a5
ffffffe00020395c:	06300793          	li	a5,99
ffffffe000203960:	02f71e63          	bne	a4,a5,ffffffe00020399c <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000203964:	f4843783          	ld	a5,-184(s0)
ffffffe000203968:	00878713          	addi	a4,a5,8
ffffffe00020396c:	f4e43423          	sd	a4,-184(s0)
ffffffe000203970:	0007a783          	lw	a5,0(a5)
ffffffe000203974:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000203978:	fcc42703          	lw	a4,-52(s0)
ffffffe00020397c:	f5843783          	ld	a5,-168(s0)
ffffffe000203980:	00070513          	mv	a0,a4
ffffffe000203984:	000780e7          	jalr	a5
                ++written;
ffffffe000203988:	fec42783          	lw	a5,-20(s0)
ffffffe00020398c:	0017879b          	addiw	a5,a5,1
ffffffe000203990:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000203994:	f8040023          	sb	zero,-128(s0)
ffffffe000203998:	0b80006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe00020399c:	f5043783          	ld	a5,-176(s0)
ffffffe0002039a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002039a4:	00078713          	mv	a4,a5
ffffffe0002039a8:	02500793          	li	a5,37
ffffffe0002039ac:	02f71263          	bne	a4,a5,ffffffe0002039d0 <vprintfmt+0x740>
                putch('%');
ffffffe0002039b0:	f5843783          	ld	a5,-168(s0)
ffffffe0002039b4:	02500513          	li	a0,37
ffffffe0002039b8:	000780e7          	jalr	a5
                ++written;
ffffffe0002039bc:	fec42783          	lw	a5,-20(s0)
ffffffe0002039c0:	0017879b          	addiw	a5,a5,1
ffffffe0002039c4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002039c8:	f8040023          	sb	zero,-128(s0)
ffffffe0002039cc:	0840006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe0002039d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002039d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002039d8:	0007871b          	sext.w	a4,a5
ffffffe0002039dc:	f5843783          	ld	a5,-168(s0)
ffffffe0002039e0:	00070513          	mv	a0,a4
ffffffe0002039e4:	000780e7          	jalr	a5
                ++written;
ffffffe0002039e8:	fec42783          	lw	a5,-20(s0)
ffffffe0002039ec:	0017879b          	addiw	a5,a5,1
ffffffe0002039f0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002039f4:	f8040023          	sb	zero,-128(s0)
ffffffe0002039f8:	0580006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe0002039fc:	f5043783          	ld	a5,-176(s0)
ffffffe000203a00:	0007c783          	lbu	a5,0(a5)
ffffffe000203a04:	00078713          	mv	a4,a5
ffffffe000203a08:	02500793          	li	a5,37
ffffffe000203a0c:	02f71063          	bne	a4,a5,ffffffe000203a2c <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000203a10:	f8043023          	sd	zero,-128(s0)
ffffffe000203a14:	f8043423          	sd	zero,-120(s0)
ffffffe000203a18:	00100793          	li	a5,1
ffffffe000203a1c:	f8f40023          	sb	a5,-128(s0)
ffffffe000203a20:	fff00793          	li	a5,-1
ffffffe000203a24:	f8f42623          	sw	a5,-116(s0)
ffffffe000203a28:	0280006f          	j	ffffffe000203a50 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000203a2c:	f5043783          	ld	a5,-176(s0)
ffffffe000203a30:	0007c783          	lbu	a5,0(a5)
ffffffe000203a34:	0007871b          	sext.w	a4,a5
ffffffe000203a38:	f5843783          	ld	a5,-168(s0)
ffffffe000203a3c:	00070513          	mv	a0,a4
ffffffe000203a40:	000780e7          	jalr	a5
            ++written;
ffffffe000203a44:	fec42783          	lw	a5,-20(s0)
ffffffe000203a48:	0017879b          	addiw	a5,a5,1
ffffffe000203a4c:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000203a50:	f5043783          	ld	a5,-176(s0)
ffffffe000203a54:	00178793          	addi	a5,a5,1
ffffffe000203a58:	f4f43823          	sd	a5,-176(s0)
ffffffe000203a5c:	f5043783          	ld	a5,-176(s0)
ffffffe000203a60:	0007c783          	lbu	a5,0(a5)
ffffffe000203a64:	84079ce3          	bnez	a5,ffffffe0002032bc <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000203a68:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203a6c:	00078513          	mv	a0,a5
ffffffe000203a70:	0b813083          	ld	ra,184(sp)
ffffffe000203a74:	0b013403          	ld	s0,176(sp)
ffffffe000203a78:	0c010113          	addi	sp,sp,192
ffffffe000203a7c:	00008067          	ret

ffffffe000203a80 <printk>:

int printk(const char* s, ...) {
ffffffe000203a80:	f9010113          	addi	sp,sp,-112
ffffffe000203a84:	02113423          	sd	ra,40(sp)
ffffffe000203a88:	02813023          	sd	s0,32(sp)
ffffffe000203a8c:	03010413          	addi	s0,sp,48
ffffffe000203a90:	fca43c23          	sd	a0,-40(s0)
ffffffe000203a94:	00b43423          	sd	a1,8(s0)
ffffffe000203a98:	00c43823          	sd	a2,16(s0)
ffffffe000203a9c:	00d43c23          	sd	a3,24(s0)
ffffffe000203aa0:	02e43023          	sd	a4,32(s0)
ffffffe000203aa4:	02f43423          	sd	a5,40(s0)
ffffffe000203aa8:	03043823          	sd	a6,48(s0)
ffffffe000203aac:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000203ab0:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000203ab4:	04040793          	addi	a5,s0,64
ffffffe000203ab8:	fcf43823          	sd	a5,-48(s0)
ffffffe000203abc:	fd043783          	ld	a5,-48(s0)
ffffffe000203ac0:	fc878793          	addi	a5,a5,-56
ffffffe000203ac4:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000203ac8:	fe043783          	ld	a5,-32(s0)
ffffffe000203acc:	00078613          	mv	a2,a5
ffffffe000203ad0:	fd843583          	ld	a1,-40(s0)
ffffffe000203ad4:	fffff517          	auipc	a0,0xfffff
ffffffe000203ad8:	11850513          	addi	a0,a0,280 # ffffffe000202bec <putc>
ffffffe000203adc:	fb4ff0ef          	jal	ra,ffffffe000203290 <vprintfmt>
ffffffe000203ae0:	00050793          	mv	a5,a0
ffffffe000203ae4:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000203ae8:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203aec:	00078513          	mv	a0,a5
ffffffe000203af0:	02813083          	ld	ra,40(sp)
ffffffe000203af4:	02013403          	ld	s0,32(sp)
ffffffe000203af8:	07010113          	addi	sp,sp,112
ffffffe000203afc:	00008067          	ret

ffffffe000203b00 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000203b00:	fe010113          	addi	sp,sp,-32
ffffffe000203b04:	00813c23          	sd	s0,24(sp)
ffffffe000203b08:	02010413          	addi	s0,sp,32
ffffffe000203b0c:	00050793          	mv	a5,a0
ffffffe000203b10:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000203b14:	fec42783          	lw	a5,-20(s0)
ffffffe000203b18:	fff7879b          	addiw	a5,a5,-1
ffffffe000203b1c:	0007879b          	sext.w	a5,a5
ffffffe000203b20:	02079713          	slli	a4,a5,0x20
ffffffe000203b24:	02075713          	srli	a4,a4,0x20
ffffffe000203b28:	00005797          	auipc	a5,0x5
ffffffe000203b2c:	4f078793          	addi	a5,a5,1264 # ffffffe000209018 <seed>
ffffffe000203b30:	00e7b023          	sd	a4,0(a5)
}
ffffffe000203b34:	00000013          	nop
ffffffe000203b38:	01813403          	ld	s0,24(sp)
ffffffe000203b3c:	02010113          	addi	sp,sp,32
ffffffe000203b40:	00008067          	ret

ffffffe000203b44 <rand>:

int rand(void) {
ffffffe000203b44:	ff010113          	addi	sp,sp,-16
ffffffe000203b48:	00813423          	sd	s0,8(sp)
ffffffe000203b4c:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000203b50:	00005797          	auipc	a5,0x5
ffffffe000203b54:	4c878793          	addi	a5,a5,1224 # ffffffe000209018 <seed>
ffffffe000203b58:	0007b703          	ld	a4,0(a5)
ffffffe000203b5c:	00001797          	auipc	a5,0x1
ffffffe000203b60:	c2478793          	addi	a5,a5,-988 # ffffffe000204780 <lowerxdigits.0+0x18>
ffffffe000203b64:	0007b783          	ld	a5,0(a5)
ffffffe000203b68:	02f707b3          	mul	a5,a4,a5
ffffffe000203b6c:	00178713          	addi	a4,a5,1
ffffffe000203b70:	00005797          	auipc	a5,0x5
ffffffe000203b74:	4a878793          	addi	a5,a5,1192 # ffffffe000209018 <seed>
ffffffe000203b78:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000203b7c:	00005797          	auipc	a5,0x5
ffffffe000203b80:	49c78793          	addi	a5,a5,1180 # ffffffe000209018 <seed>
ffffffe000203b84:	0007b783          	ld	a5,0(a5)
ffffffe000203b88:	0217d793          	srli	a5,a5,0x21
ffffffe000203b8c:	0007879b          	sext.w	a5,a5
}
ffffffe000203b90:	00078513          	mv	a0,a5
ffffffe000203b94:	00813403          	ld	s0,8(sp)
ffffffe000203b98:	01010113          	addi	sp,sp,16
ffffffe000203b9c:	00008067          	ret

ffffffe000203ba0 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000203ba0:	fc010113          	addi	sp,sp,-64
ffffffe000203ba4:	02813c23          	sd	s0,56(sp)
ffffffe000203ba8:	04010413          	addi	s0,sp,64
ffffffe000203bac:	fca43c23          	sd	a0,-40(s0)
ffffffe000203bb0:	00058793          	mv	a5,a1
ffffffe000203bb4:	fcc43423          	sd	a2,-56(s0)
ffffffe000203bb8:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000203bbc:	fd843783          	ld	a5,-40(s0)
ffffffe000203bc0:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203bc4:	fe043423          	sd	zero,-24(s0)
ffffffe000203bc8:	0280006f          	j	ffffffe000203bf0 <memset+0x50>
        s[i] = c;
ffffffe000203bcc:	fe043703          	ld	a4,-32(s0)
ffffffe000203bd0:	fe843783          	ld	a5,-24(s0)
ffffffe000203bd4:	00f707b3          	add	a5,a4,a5
ffffffe000203bd8:	fd442703          	lw	a4,-44(s0)
ffffffe000203bdc:	0ff77713          	zext.b	a4,a4
ffffffe000203be0:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000203be4:	fe843783          	ld	a5,-24(s0)
ffffffe000203be8:	00178793          	addi	a5,a5,1
ffffffe000203bec:	fef43423          	sd	a5,-24(s0)
ffffffe000203bf0:	fe843703          	ld	a4,-24(s0)
ffffffe000203bf4:	fc843783          	ld	a5,-56(s0)
ffffffe000203bf8:	fcf76ae3          	bltu	a4,a5,ffffffe000203bcc <memset+0x2c>
    }
    return dest;
ffffffe000203bfc:	fd843783          	ld	a5,-40(s0)
}
ffffffe000203c00:	00078513          	mv	a0,a5
ffffffe000203c04:	03813403          	ld	s0,56(sp)
ffffffe000203c08:	04010113          	addi	sp,sp,64
ffffffe000203c0c:	00008067          	ret
