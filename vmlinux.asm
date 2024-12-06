
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
ffffffe000200008:	3c9010ef          	jal	ra,ffffffe000201bd0 <setup_vm>
    call relocate
ffffffe00020000c:	060000ef          	jal	ra,ffffffe00020006c <relocate>

    call mm_init
ffffffe000200010:	285000ef          	jal	ra,ffffffe000200a94 <mm_init>

    call setup_vm_final
ffffffe000200014:	4e9010ef          	jal	ra,ffffffe000201cfc <setup_vm_final>

    call task_init
ffffffe000200018:	288010ef          	jal	ra,ffffffe0002012a0 <task_init>

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
ffffffe000200068:	0a4020ef          	jal	ra,ffffffe00020210c <start_kernel>

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
ffffffe000200144:	6f0010ef          	jal	ra,ffffffe000201834 <trap_handler>

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
ffffffe000200314:	494010ef          	jal	ra,ffffffe0002017a8 <sbi_set_timer>
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
ffffffe00020048c:	4cd020ef          	jal	ra,ffffffe000203158 <memset>

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
ffffffe000200568:	aa450513          	addi	a0,a0,-1372 # ffffffe000204008 <__func__.0+0x8>
ffffffe00020056c:	2cd020ef          	jal	ra,ffffffe000203038 <printk>
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
ffffffe000200aac:	57850513          	addi	a0,a0,1400 # ffffffe000204020 <__func__.0+0x20>
ffffffe000200ab0:	588020ef          	jal	ra,ffffffe000203038 <printk>
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
ffffffe000200ba0:	49c50513          	addi	a0,a0,1180 # ffffffe000204038 <__func__.0+0x38>
ffffffe000200ba4:	494020ef          	jal	ra,ffffffe000203038 <printk>
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
ffffffe000200bf8:	47450513          	addi	a0,a0,1140 # ffffffe000204068 <__func__.0+0x68>
ffffffe000200bfc:	43c020ef          	jal	ra,ffffffe000203038 <printk>
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
ffffffe000200c24:	46050513          	addi	a0,a0,1120 # ffffffe000204080 <__func__.0+0x80>
ffffffe000200c28:	410020ef          	jal	ra,ffffffe000203038 <printk>
        __switch_to(prev, next);
ffffffe000200c2c:	fd843583          	ld	a1,-40(s0)
ffffffe000200c30:	fe843503          	ld	a0,-24(s0)
ffffffe000200c34:	dbcff0ef          	jal	ra,ffffffe0002001f0 <__switch_to>
        printk("switch done\n");
ffffffe000200c38:	00003517          	auipc	a0,0x3
ffffffe000200c3c:	45850513          	addi	a0,a0,1112 # ffffffe000204090 <__func__.0+0x90>
ffffffe000200c40:	3f8020ef          	jal	ra,ffffffe000203038 <printk>
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
ffffffe000200c84:	42050513          	addi	a0,a0,1056 # ffffffe0002040a0 <__func__.0+0xa0>
ffffffe000200c88:	3b0020ef          	jal	ra,ffffffe000203038 <printk>
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
ffffffe000200cc0:	40450513          	addi	a0,a0,1028 # ffffffe0002040c0 <__func__.0+0xc0>
ffffffe000200cc4:	374020ef          	jal	ra,ffffffe000203038 <printk>
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
ffffffe000200d00:	3dc50513          	addi	a0,a0,988 # ffffffe0002040d8 <__func__.0+0xd8>
ffffffe000200d04:	334020ef          	jal	ra,ffffffe000203038 <printk>
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
    for (int i = 1; i < NR_TASKS; ++i) {
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
ffffffe000200d90:	36450513          	addi	a0,a0,868 # ffffffe0002040f0 <__func__.0+0xf0>
ffffffe000200d94:	2a4020ef          	jal	ra,ffffffe000203038 <printk>
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
ffffffe000200de8:	32450513          	addi	a0,a0,804 # ffffffe000204108 <__func__.0+0x108>
ffffffe000200dec:	24c020ef          	jal	ra,ffffffe000203038 <printk>
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
    for (int i = 1; i < NR_TASKS; ++i) {
ffffffe000200e18:	fe442783          	lw	a5,-28(s0)
ffffffe000200e1c:	0017879b          	addiw	a5,a5,1
ffffffe000200e20:	fef42223          	sw	a5,-28(s0)
ffffffe000200e24:	fe442783          	lw	a5,-28(s0)
ffffffe000200e28:	0007871b          	sext.w	a4,a5
ffffffe000200e2c:	01f00793          	li	a5,31
ffffffe000200e30:	f0e7dee3          	bge	a5,a4,ffffffe000200d4c <schedule+0x2c>
        }
    }

    if (maxCounter == 0) {
ffffffe000200e34:	fec42783          	lw	a5,-20(s0)
ffffffe000200e38:	0007879b          	sext.w	a5,a5
ffffffe000200e3c:	0c079c63          	bnez	a5,ffffffe000200f14 <schedule+0x1f4>
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe000200e40:	00100793          	li	a5,1
ffffffe000200e44:	fef42023          	sw	a5,-32(s0)
ffffffe000200e48:	0b40006f          	j	ffffffe000200efc <schedule+0x1dc>
            if (task[i]->state == TASK_RUNNING) {
ffffffe000200e4c:	00008717          	auipc	a4,0x8
ffffffe000200e50:	1e470713          	addi	a4,a4,484 # ffffffe000209030 <task>
ffffffe000200e54:	fe042783          	lw	a5,-32(s0)
ffffffe000200e58:	00379793          	slli	a5,a5,0x3
ffffffe000200e5c:	00f707b3          	add	a5,a4,a5
ffffffe000200e60:	0007b783          	ld	a5,0(a5)
ffffffe000200e64:	0007b783          	ld	a5,0(a5)
ffffffe000200e68:	02079e63          	bnez	a5,ffffffe000200ea4 <schedule+0x184>
                task[i]->counter = task[i]->priority;
ffffffe000200e6c:	00008717          	auipc	a4,0x8
ffffffe000200e70:	1c470713          	addi	a4,a4,452 # ffffffe000209030 <task>
ffffffe000200e74:	fe042783          	lw	a5,-32(s0)
ffffffe000200e78:	00379793          	slli	a5,a5,0x3
ffffffe000200e7c:	00f707b3          	add	a5,a4,a5
ffffffe000200e80:	0007b703          	ld	a4,0(a5)
ffffffe000200e84:	00008697          	auipc	a3,0x8
ffffffe000200e88:	1ac68693          	addi	a3,a3,428 # ffffffe000209030 <task>
ffffffe000200e8c:	fe042783          	lw	a5,-32(s0)
ffffffe000200e90:	00379793          	slli	a5,a5,0x3
ffffffe000200e94:	00f687b3          	add	a5,a3,a5
ffffffe000200e98:	0007b783          	ld	a5,0(a5)
ffffffe000200e9c:	01073703          	ld	a4,16(a4)
ffffffe000200ea0:	00e7b423          	sd	a4,8(a5)
            }
            printk("schedule2: %d -> %d\n", task[i]->pid, task[i] -> counter);
ffffffe000200ea4:	00008717          	auipc	a4,0x8
ffffffe000200ea8:	18c70713          	addi	a4,a4,396 # ffffffe000209030 <task>
ffffffe000200eac:	fe042783          	lw	a5,-32(s0)
ffffffe000200eb0:	00379793          	slli	a5,a5,0x3
ffffffe000200eb4:	00f707b3          	add	a5,a4,a5
ffffffe000200eb8:	0007b783          	ld	a5,0(a5)
ffffffe000200ebc:	0187b683          	ld	a3,24(a5)
ffffffe000200ec0:	00008717          	auipc	a4,0x8
ffffffe000200ec4:	17070713          	addi	a4,a4,368 # ffffffe000209030 <task>
ffffffe000200ec8:	fe042783          	lw	a5,-32(s0)
ffffffe000200ecc:	00379793          	slli	a5,a5,0x3
ffffffe000200ed0:	00f707b3          	add	a5,a4,a5
ffffffe000200ed4:	0007b783          	ld	a5,0(a5)
ffffffe000200ed8:	0087b783          	ld	a5,8(a5)
ffffffe000200edc:	00078613          	mv	a2,a5
ffffffe000200ee0:	00068593          	mv	a1,a3
ffffffe000200ee4:	00003517          	auipc	a0,0x3
ffffffe000200ee8:	22c50513          	addi	a0,a0,556 # ffffffe000204110 <__func__.0+0x110>
ffffffe000200eec:	14c020ef          	jal	ra,ffffffe000203038 <printk>
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe000200ef0:	fe042783          	lw	a5,-32(s0)
ffffffe000200ef4:	0017879b          	addiw	a5,a5,1
ffffffe000200ef8:	fef42023          	sw	a5,-32(s0)
ffffffe000200efc:	fe042783          	lw	a5,-32(s0)
ffffffe000200f00:	0007871b          	sext.w	a4,a5
ffffffe000200f04:	01f00793          	li	a5,31
ffffffe000200f08:	f4e7d2e3          	bge	a5,a4,ffffffe000200e4c <schedule+0x12c>
        }
        schedule();
ffffffe000200f0c:	e15ff0ef          	jal	ra,ffffffe000200d20 <schedule>
    } else {
        switch_to(task[index]);
    }
}
ffffffe000200f10:	0240006f          	j	ffffffe000200f34 <schedule+0x214>
        switch_to(task[index]);
ffffffe000200f14:	00008717          	auipc	a4,0x8
ffffffe000200f18:	11c70713          	addi	a4,a4,284 # ffffffe000209030 <task>
ffffffe000200f1c:	fe842783          	lw	a5,-24(s0)
ffffffe000200f20:	00379793          	slli	a5,a5,0x3
ffffffe000200f24:	00f707b3          	add	a5,a4,a5
ffffffe000200f28:	0007b783          	ld	a5,0(a5)
ffffffe000200f2c:	00078513          	mv	a0,a5
ffffffe000200f30:	c7dff0ef          	jal	ra,ffffffe000200bac <switch_to>
}
ffffffe000200f34:	00000013          	nop
ffffffe000200f38:	01813083          	ld	ra,24(sp)
ffffffe000200f3c:	01013403          	ld	s0,16(sp)
ffffffe000200f40:	02010113          	addi	sp,sp,32
ffffffe000200f44:	00008067          	ret

ffffffe000200f48 <load_program>:

void load_program(struct task_struct *task) {
ffffffe000200f48:	f8010113          	addi	sp,sp,-128
ffffffe000200f4c:	06113c23          	sd	ra,120(sp)
ffffffe000200f50:	06813823          	sd	s0,112(sp)
ffffffe000200f54:	08010413          	addi	s0,sp,128
ffffffe000200f58:	f8a43423          	sd	a0,-120(s0)
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
ffffffe000200f5c:	00005797          	auipc	a5,0x5
ffffffe000200f60:	0a478793          	addi	a5,a5,164 # ffffffe000206000 <_sramdisk>
ffffffe000200f64:	fcf43c23          	sd	a5,-40(s0)

    LogGREEN("ehdr->e_ident = 0x%llx", *((uint64_t*)ehdr->e_ident));
ffffffe000200f68:	fd843783          	ld	a5,-40(s0)
ffffffe000200f6c:	0007b783          	ld	a5,0(a5)
ffffffe000200f70:	00078713          	mv	a4,a5
ffffffe000200f74:	00003697          	auipc	a3,0x3
ffffffe000200f78:	31c68693          	addi	a3,a3,796 # ffffffe000204290 <__func__.1>
ffffffe000200f7c:	0d000613          	li	a2,208
ffffffe000200f80:	00003597          	auipc	a1,0x3
ffffffe000200f84:	1a858593          	addi	a1,a1,424 # ffffffe000204128 <__func__.0+0x128>
ffffffe000200f88:	00003517          	auipc	a0,0x3
ffffffe000200f8c:	1a850513          	addi	a0,a0,424 # ffffffe000204130 <__func__.0+0x130>
ffffffe000200f90:	0a8020ef          	jal	ra,ffffffe000203038 <printk>
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
ffffffe000200f94:	fd843783          	ld	a5,-40(s0)
ffffffe000200f98:	0207b703          	ld	a4,32(a5)
ffffffe000200f9c:	00005797          	auipc	a5,0x5
ffffffe000200fa0:	06478793          	addi	a5,a5,100 # ffffffe000206000 <_sramdisk>
ffffffe000200fa4:	00f707b3          	add	a5,a4,a5
ffffffe000200fa8:	fcf43823          	sd	a5,-48(s0)
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000200fac:	fe042623          	sw	zero,-20(s0)
ffffffe000200fb0:	2740006f          	j	ffffffe000201224 <load_program+0x2dc>
        Elf64_Phdr *phdr = phdrs + i;
ffffffe000200fb4:	fec42703          	lw	a4,-20(s0)
ffffffe000200fb8:	00070793          	mv	a5,a4
ffffffe000200fbc:	00379793          	slli	a5,a5,0x3
ffffffe000200fc0:	40e787b3          	sub	a5,a5,a4
ffffffe000200fc4:	00379793          	slli	a5,a5,0x3
ffffffe000200fc8:	00078713          	mv	a4,a5
ffffffe000200fcc:	fd043783          	ld	a5,-48(s0)
ffffffe000200fd0:	00e787b3          	add	a5,a5,a4
ffffffe000200fd4:	fcf43023          	sd	a5,-64(s0)
        if (phdr->p_type == PT_LOAD) {
ffffffe000200fd8:	fc043783          	ld	a5,-64(s0)
ffffffe000200fdc:	0007a783          	lw	a5,0(a5)
ffffffe000200fe0:	00078713          	mv	a4,a5
ffffffe000200fe4:	00100793          	li	a5,1
ffffffe000200fe8:	22f71863          	bne	a4,a5,ffffffe000201218 <load_program+0x2d0>
            // alloc space and copy content
            uint64_t _ssegment = (uint64_t)_sramdisk + phdr->p_offset;
ffffffe000200fec:	fc043783          	ld	a5,-64(s0)
ffffffe000200ff0:	0087b703          	ld	a4,8(a5)
ffffffe000200ff4:	00005797          	auipc	a5,0x5
ffffffe000200ff8:	00c78793          	addi	a5,a5,12 # ffffffe000206000 <_sramdisk>
ffffffe000200ffc:	00f707b3          	add	a5,a4,a5
ffffffe000201000:	faf43c23          	sd	a5,-72(s0)
            uint64_t* segment = (uint64_t*)alloc_pages((phdr->p_memsz + (phdr->p_vaddr & 0xfff) + PGSIZE - 1) / PGSIZE);
ffffffe000201004:	fc043783          	ld	a5,-64(s0)
ffffffe000201008:	0287b703          	ld	a4,40(a5)
ffffffe00020100c:	fc043783          	ld	a5,-64(s0)
ffffffe000201010:	0107b683          	ld	a3,16(a5)
ffffffe000201014:	000017b7          	lui	a5,0x1
ffffffe000201018:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe00020101c:	00f6f7b3          	and	a5,a3,a5
ffffffe000201020:	00f70733          	add	a4,a4,a5
ffffffe000201024:	000017b7          	lui	a5,0x1
ffffffe000201028:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe00020102c:	00f707b3          	add	a5,a4,a5
ffffffe000201030:	00c7d793          	srli	a5,a5,0xc
ffffffe000201034:	00078513          	mv	a0,a5
ffffffe000201038:	8b9ff0ef          	jal	ra,ffffffe0002008f0 <alloc_pages>
ffffffe00020103c:	faa43823          	sd	a0,-80(s0)
            
            char *csegment = (char*)segment + (phdr->p_vaddr & 0xfff);
ffffffe000201040:	fc043783          	ld	a5,-64(s0)
ffffffe000201044:	0107b703          	ld	a4,16(a5)
ffffffe000201048:	000017b7          	lui	a5,0x1
ffffffe00020104c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000201050:	00f777b3          	and	a5,a4,a5
ffffffe000201054:	fb043703          	ld	a4,-80(s0)
ffffffe000201058:	00f707b3          	add	a5,a4,a5
ffffffe00020105c:	faf43423          	sd	a5,-88(s0)
            char *_csegment = (char*)_ssegment;
ffffffe000201060:	fb843783          	ld	a5,-72(s0)
ffffffe000201064:	faf43023          	sd	a5,-96(s0)
            for(uint64_t i = 0; i < (uint64_t)phdr->p_filesz; i++){
ffffffe000201068:	fe043023          	sd	zero,-32(s0)
ffffffe00020106c:	0300006f          	j	ffffffe00020109c <load_program+0x154>
                csegment[i] = _csegment[i];
ffffffe000201070:	fa043703          	ld	a4,-96(s0)
ffffffe000201074:	fe043783          	ld	a5,-32(s0)
ffffffe000201078:	00f70733          	add	a4,a4,a5
ffffffe00020107c:	fa843683          	ld	a3,-88(s0)
ffffffe000201080:	fe043783          	ld	a5,-32(s0)
ffffffe000201084:	00f687b3          	add	a5,a3,a5
ffffffe000201088:	00074703          	lbu	a4,0(a4)
ffffffe00020108c:	00e78023          	sb	a4,0(a5)
            for(uint64_t i = 0; i < (uint64_t)phdr->p_filesz; i++){
ffffffe000201090:	fe043783          	ld	a5,-32(s0)
ffffffe000201094:	00178793          	addi	a5,a5,1
ffffffe000201098:	fef43023          	sd	a5,-32(s0)
ffffffe00020109c:	fc043783          	ld	a5,-64(s0)
ffffffe0002010a0:	0207b783          	ld	a5,32(a5)
ffffffe0002010a4:	fe043703          	ld	a4,-32(s0)
ffffffe0002010a8:	fcf764e3          	bltu	a4,a5,ffffffe000201070 <load_program+0x128>
            }
            memset((char*)segment + phdr->p_filesz + (phdr->p_vaddr & 0xfff), 0, phdr->p_memsz - phdr->p_filesz);
ffffffe0002010ac:	fc043783          	ld	a5,-64(s0)
ffffffe0002010b0:	0207b703          	ld	a4,32(a5)
ffffffe0002010b4:	fc043783          	ld	a5,-64(s0)
ffffffe0002010b8:	0107b683          	ld	a3,16(a5)
ffffffe0002010bc:	000017b7          	lui	a5,0x1
ffffffe0002010c0:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002010c4:	00f6f7b3          	and	a5,a3,a5
ffffffe0002010c8:	00f707b3          	add	a5,a4,a5
ffffffe0002010cc:	fb043703          	ld	a4,-80(s0)
ffffffe0002010d0:	00f706b3          	add	a3,a4,a5
ffffffe0002010d4:	fc043783          	ld	a5,-64(s0)
ffffffe0002010d8:	0287b703          	ld	a4,40(a5)
ffffffe0002010dc:	fc043783          	ld	a5,-64(s0)
ffffffe0002010e0:	0207b783          	ld	a5,32(a5)
ffffffe0002010e4:	40f707b3          	sub	a5,a4,a5
ffffffe0002010e8:	00078613          	mv	a2,a5
ffffffe0002010ec:	00000593          	li	a1,0
ffffffe0002010f0:	00068513          	mv	a0,a3
ffffffe0002010f4:	064020ef          	jal	ra,ffffffe000203158 <memset>

            // do mapping
            uint64_t perm = PTE_U | PTE_V | (phdr->p_flags & PF_X) << 3 | (phdr->p_flags & PF_W) << 1 | (phdr->p_flags & PF_R) >> 1;
ffffffe0002010f8:	fc043783          	ld	a5,-64(s0)
ffffffe0002010fc:	0047a783          	lw	a5,4(a5)
ffffffe000201100:	0037979b          	slliw	a5,a5,0x3
ffffffe000201104:	0007879b          	sext.w	a5,a5
ffffffe000201108:	0087f793          	andi	a5,a5,8
ffffffe00020110c:	0007871b          	sext.w	a4,a5
ffffffe000201110:	fc043783          	ld	a5,-64(s0)
ffffffe000201114:	0047a783          	lw	a5,4(a5)
ffffffe000201118:	0017979b          	slliw	a5,a5,0x1
ffffffe00020111c:	0007879b          	sext.w	a5,a5
ffffffe000201120:	0047f793          	andi	a5,a5,4
ffffffe000201124:	0007879b          	sext.w	a5,a5
ffffffe000201128:	00f767b3          	or	a5,a4,a5
ffffffe00020112c:	0007871b          	sext.w	a4,a5
ffffffe000201130:	fc043783          	ld	a5,-64(s0)
ffffffe000201134:	0047a783          	lw	a5,4(a5)
ffffffe000201138:	0017d79b          	srliw	a5,a5,0x1
ffffffe00020113c:	0007879b          	sext.w	a5,a5
ffffffe000201140:	0027f793          	andi	a5,a5,2
ffffffe000201144:	0007879b          	sext.w	a5,a5
ffffffe000201148:	00f767b3          	or	a5,a4,a5
ffffffe00020114c:	0007879b          	sext.w	a5,a5
ffffffe000201150:	0117e793          	ori	a5,a5,17
ffffffe000201154:	0007879b          	sext.w	a5,a5
ffffffe000201158:	02079793          	slli	a5,a5,0x20
ffffffe00020115c:	0207d793          	srli	a5,a5,0x20
ffffffe000201160:	f8f43c23          	sd	a5,-104(s0)
            create_mapping(task->pgd, phdr->p_vaddr, VA2PA((uint64_t)segment), phdr->p_memsz + (phdr->p_vaddr & 0xfff), perm);
ffffffe000201164:	f8843783          	ld	a5,-120(s0)
ffffffe000201168:	0a87b503          	ld	a0,168(a5)
ffffffe00020116c:	fc043783          	ld	a5,-64(s0)
ffffffe000201170:	0107b583          	ld	a1,16(a5)
ffffffe000201174:	fb043703          	ld	a4,-80(s0)
ffffffe000201178:	04100793          	li	a5,65
ffffffe00020117c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201180:	00f70633          	add	a2,a4,a5
ffffffe000201184:	fc043783          	ld	a5,-64(s0)
ffffffe000201188:	0287b703          	ld	a4,40(a5)
ffffffe00020118c:	fc043783          	ld	a5,-64(s0)
ffffffe000201190:	0107b683          	ld	a3,16(a5)
ffffffe000201194:	000017b7          	lui	a5,0x1
ffffffe000201198:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe00020119c:	00f6f7b3          	and	a5,a3,a5
ffffffe0002011a0:	00f707b3          	add	a5,a4,a5
ffffffe0002011a4:	f9843703          	ld	a4,-104(s0)
ffffffe0002011a8:	00078693          	mv	a3,a5
ffffffe0002011ac:	515000ef          	jal	ra,ffffffe000201ec0 <create_mapping>
            LogBLUE("va: 0x%llx, pa: 0x%llx, size: 0x%llx, perm: 0x%llx", phdr->p_vaddr, VA2PA((uint64_t)segment), phdr->p_memsz + (phdr->p_vaddr & 0xfff), perm);
ffffffe0002011b0:	fc043783          	ld	a5,-64(s0)
ffffffe0002011b4:	0107b603          	ld	a2,16(a5)
ffffffe0002011b8:	fb043703          	ld	a4,-80(s0)
ffffffe0002011bc:	04100793          	li	a5,65
ffffffe0002011c0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002011c4:	00f705b3          	add	a1,a4,a5
ffffffe0002011c8:	fc043783          	ld	a5,-64(s0)
ffffffe0002011cc:	0287b703          	ld	a4,40(a5)
ffffffe0002011d0:	fc043783          	ld	a5,-64(s0)
ffffffe0002011d4:	0107b683          	ld	a3,16(a5)
ffffffe0002011d8:	000017b7          	lui	a5,0x1
ffffffe0002011dc:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002011e0:	00f6f7b3          	and	a5,a3,a5
ffffffe0002011e4:	00f707b3          	add	a5,a4,a5
ffffffe0002011e8:	f9843883          	ld	a7,-104(s0)
ffffffe0002011ec:	00078813          	mv	a6,a5
ffffffe0002011f0:	00058793          	mv	a5,a1
ffffffe0002011f4:	00060713          	mv	a4,a2
ffffffe0002011f8:	00003697          	auipc	a3,0x3
ffffffe0002011fc:	09868693          	addi	a3,a3,152 # ffffffe000204290 <__func__.1>
ffffffe000201200:	0e300613          	li	a2,227
ffffffe000201204:	00003597          	auipc	a1,0x3
ffffffe000201208:	f2458593          	addi	a1,a1,-220 # ffffffe000204128 <__func__.0+0x128>
ffffffe00020120c:	00003517          	auipc	a0,0x3
ffffffe000201210:	f5450513          	addi	a0,a0,-172 # ffffffe000204160 <__func__.0+0x160>
ffffffe000201214:	625010ef          	jal	ra,ffffffe000203038 <printk>
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000201218:	fec42783          	lw	a5,-20(s0)
ffffffe00020121c:	0017879b          	addiw	a5,a5,1
ffffffe000201220:	fef42623          	sw	a5,-20(s0)
ffffffe000201224:	fd843783          	ld	a5,-40(s0)
ffffffe000201228:	0387d783          	lhu	a5,56(a5)
ffffffe00020122c:	0007871b          	sext.w	a4,a5
ffffffe000201230:	fec42783          	lw	a5,-20(s0)
ffffffe000201234:	0007879b          	sext.w	a5,a5
ffffffe000201238:	d6e7cee3          	blt	a5,a4,ffffffe000200fb4 <load_program+0x6c>
        }
    }
    uint64_t usp = (uint64_t)alloc_page();
ffffffe00020123c:	f0cff0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe000201240:	00050793          	mv	a5,a0
ffffffe000201244:	fcf43423          	sd	a5,-56(s0)
    create_mapping(task->pgd, USER_END - PGSIZE, VA2PA(usp), PGSIZE, PTE_R | PTE_W | PTE_U | PTE_V);
ffffffe000201248:	f8843783          	ld	a5,-120(s0)
ffffffe00020124c:	0a87b503          	ld	a0,168(a5)
ffffffe000201250:	fc843703          	ld	a4,-56(s0)
ffffffe000201254:	04100793          	li	a5,65
ffffffe000201258:	01f79793          	slli	a5,a5,0x1f
ffffffe00020125c:	00f707b3          	add	a5,a4,a5
ffffffe000201260:	01700713          	li	a4,23
ffffffe000201264:	000016b7          	lui	a3,0x1
ffffffe000201268:	00078613          	mv	a2,a5
ffffffe00020126c:	040007b7          	lui	a5,0x4000
ffffffe000201270:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000201274:	00c79593          	slli	a1,a5,0xc
ffffffe000201278:	449000ef          	jal	ra,ffffffe000201ec0 <create_mapping>
    task->thread.sepc = ehdr->e_entry;
ffffffe00020127c:	fd843783          	ld	a5,-40(s0)
ffffffe000201280:	0187b703          	ld	a4,24(a5)
ffffffe000201284:	f8843783          	ld	a5,-120(s0)
ffffffe000201288:	08e7b823          	sd	a4,144(a5)
}
ffffffe00020128c:	00000013          	nop
ffffffe000201290:	07813083          	ld	ra,120(sp)
ffffffe000201294:	07013403          	ld	s0,112(sp)
ffffffe000201298:	08010113          	addi	sp,sp,128
ffffffe00020129c:	00008067          	ret

ffffffe0002012a0 <task_init>:

//7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00

/*ELF*/

void task_init() {
ffffffe0002012a0:	fc010113          	addi	sp,sp,-64
ffffffe0002012a4:	02113c23          	sd	ra,56(sp)
ffffffe0002012a8:	02813823          	sd	s0,48(sp)
ffffffe0002012ac:	04010413          	addi	s0,sp,64
    srand(2024);
ffffffe0002012b0:	7e800513          	li	a0,2024
ffffffe0002012b4:	605010ef          	jal	ra,ffffffe0002030b8 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
ffffffe0002012b8:	f04ff0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe0002012bc:	00050713          	mv	a4,a0
ffffffe0002012c0:	00008797          	auipc	a5,0x8
ffffffe0002012c4:	d4878793          	addi	a5,a5,-696 # ffffffe000209008 <idle>
ffffffe0002012c8:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe0002012cc:	00008797          	auipc	a5,0x8
ffffffe0002012d0:	d3c78793          	addi	a5,a5,-708 # ffffffe000209008 <idle>
ffffffe0002012d4:	0007b783          	ld	a5,0(a5)
ffffffe0002012d8:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe0002012dc:	00008797          	auipc	a5,0x8
ffffffe0002012e0:	d2c78793          	addi	a5,a5,-724 # ffffffe000209008 <idle>
ffffffe0002012e4:	0007b783          	ld	a5,0(a5)
ffffffe0002012e8:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe0002012ec:	00008797          	auipc	a5,0x8
ffffffe0002012f0:	d1c78793          	addi	a5,a5,-740 # ffffffe000209008 <idle>
ffffffe0002012f4:	0007b783          	ld	a5,0(a5)
ffffffe0002012f8:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe0002012fc:	00008797          	auipc	a5,0x8
ffffffe000201300:	d0c78793          	addi	a5,a5,-756 # ffffffe000209008 <idle>
ffffffe000201304:	0007b783          	ld	a5,0(a5)
ffffffe000201308:	0007bc23          	sd	zero,24(a5)

    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe00020130c:	00008797          	auipc	a5,0x8
ffffffe000201310:	cfc78793          	addi	a5,a5,-772 # ffffffe000209008 <idle>
ffffffe000201314:	0007b703          	ld	a4,0(a5)
ffffffe000201318:	00008797          	auipc	a5,0x8
ffffffe00020131c:	cf878793          	addi	a5,a5,-776 # ffffffe000209010 <current>
ffffffe000201320:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000201324:	00008797          	auipc	a5,0x8
ffffffe000201328:	ce478793          	addi	a5,a5,-796 # ffffffe000209008 <idle>
ffffffe00020132c:	0007b703          	ld	a4,0(a5)
ffffffe000201330:	00008797          	auipc	a5,0x8
ffffffe000201334:	d0078793          	addi	a5,a5,-768 # ffffffe000209030 <task>
ffffffe000201338:	00e7b023          	sd	a4,0(a5)

    /* YOUR CODE HERE */

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    for (int i = 1; i < NR_TASKS; i++){
ffffffe00020133c:	00100793          	li	a5,1
ffffffe000201340:	fef42623          	sw	a5,-20(s0)
ffffffe000201344:	2340006f          	j	ffffffe000201578 <task_init+0x2d8>
        struct task_struct *ptask = (struct task_struct*)kalloc();
ffffffe000201348:	e74ff0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe00020134c:	fca43c23          	sd	a0,-40(s0)
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
        ptask->state = TASK_RUNNING;
ffffffe000201350:	fd843783          	ld	a5,-40(s0)
ffffffe000201354:	0007b023          	sd	zero,0(a5)
        ptask->counter = 0;
ffffffe000201358:	fd843783          	ld	a5,-40(s0)
ffffffe00020135c:	0007b423          	sd	zero,8(a5)
        ptask->priority = (uint64_t)rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
ffffffe000201360:	59d010ef          	jal	ra,ffffffe0002030fc <rand>
ffffffe000201364:	00050793          	mv	a5,a0
ffffffe000201368:	00078713          	mv	a4,a5
ffffffe00020136c:	00a00793          	li	a5,10
ffffffe000201370:	02f777b3          	remu	a5,a4,a5
ffffffe000201374:	00178713          	addi	a4,a5,1
ffffffe000201378:	fd843783          	ld	a5,-40(s0)
ffffffe00020137c:	00e7b823          	sd	a4,16(a5)
        // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址
        ptask->pid = i;
ffffffe000201380:	fec42703          	lw	a4,-20(s0)
ffffffe000201384:	fd843783          	ld	a5,-40(s0)
ffffffe000201388:	00e7bc23          	sd	a4,24(a5)
        ptask->thread.ra = (uint64_t)__dummy;
ffffffe00020138c:	fffff717          	auipc	a4,0xfffff
ffffffe000201390:	e5470713          	addi	a4,a4,-428 # ffffffe0002001e0 <__dummy>
ffffffe000201394:	fd843783          	ld	a5,-40(s0)
ffffffe000201398:	02e7b023          	sd	a4,32(a5)
        ptask->thread.sp = (uint64_t)ptask + PGSIZE;
ffffffe00020139c:	fd843703          	ld	a4,-40(s0)
ffffffe0002013a0:	000017b7          	lui	a5,0x1
ffffffe0002013a4:	00f70733          	add	a4,a4,a5
ffffffe0002013a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002013ac:	02e7b423          	sd	a4,40(a5) # 1028 <PGSIZE+0x28>

        /*Lab4*/
        ptask->thread.sepc = (uint64_t)USER_START;
ffffffe0002013b0:	fd843783          	ld	a5,-40(s0)
ffffffe0002013b4:	0807b823          	sd	zero,144(a5)
        
        uint64_t _sstatus = ptask->thread.sstatus;
ffffffe0002013b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002013bc:	0987b783          	ld	a5,152(a5)
ffffffe0002013c0:	fcf43823          	sd	a5,-48(s0)
        //csr_write(sstatus, _sstatus);
        _sstatus &= ~(1 << 8);
ffffffe0002013c4:	fd043783          	ld	a5,-48(s0)
ffffffe0002013c8:	eff7f793          	andi	a5,a5,-257
ffffffe0002013cc:	fcf43823          	sd	a5,-48(s0)
        _sstatus |= (1 << 5);
ffffffe0002013d0:	fd043783          	ld	a5,-48(s0)
ffffffe0002013d4:	0207e793          	ori	a5,a5,32
ffffffe0002013d8:	fcf43823          	sd	a5,-48(s0)
        _sstatus |= (1 << 18); 
ffffffe0002013dc:	fd043703          	ld	a4,-48(s0)
ffffffe0002013e0:	000407b7          	lui	a5,0x40
ffffffe0002013e4:	00f767b3          	or	a5,a4,a5
ffffffe0002013e8:	fcf43823          	sd	a5,-48(s0)
        ptask->thread.sstatus = _sstatus;
ffffffe0002013ec:	fd843783          	ld	a5,-40(s0)
ffffffe0002013f0:	fd043703          	ld	a4,-48(s0)
ffffffe0002013f4:	08e7bc23          	sd	a4,152(a5) # 40098 <PGSIZE+0x3f098>

        ptask->thread.sscratch = (uint64_t)USER_END;
ffffffe0002013f8:	fd843783          	ld	a5,-40(s0)
ffffffe0002013fc:	00100713          	li	a4,1
ffffffe000201400:	02671713          	slli	a4,a4,0x26
ffffffe000201404:	0ae7b023          	sd	a4,160(a5)

        ptask->pgd = (uint64_t*)alloc_page();
ffffffe000201408:	d40ff0ef          	jal	ra,ffffffe000200948 <alloc_page>
ffffffe00020140c:	00050713          	mv	a4,a0
ffffffe000201410:	fd843783          	ld	a5,-40(s0)
ffffffe000201414:	0ae7b423          	sd	a4,168(a5)
        // PAGE_COPY(swapper_pg_dir, pgtbl);
        for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000201418:	fe043023          	sd	zero,-32(s0)
ffffffe00020141c:	0b00006f          	j	ffffffe0002014cc <task_init+0x22c>
            // char *cpgtbl = (char*)pgtbl;
            char *cpgtbl = (char*)ptask->pgd;
ffffffe000201420:	fd843783          	ld	a5,-40(s0)
ffffffe000201424:	0a87b783          	ld	a5,168(a5)
ffffffe000201428:	fcf43423          	sd	a5,-56(s0)
            char *cearly_pgtbl = (char*)swapper_pg_dir;
ffffffe00020142c:	0000a797          	auipc	a5,0xa
ffffffe000201430:	bd478793          	addi	a5,a5,-1068 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201434:	fcf43023          	sd	a5,-64(s0)
            cpgtbl[i] = cearly_pgtbl[i];
ffffffe000201438:	fc043703          	ld	a4,-64(s0)
ffffffe00020143c:	fe043783          	ld	a5,-32(s0)
ffffffe000201440:	00f70733          	add	a4,a4,a5
ffffffe000201444:	fc843683          	ld	a3,-56(s0)
ffffffe000201448:	fe043783          	ld	a5,-32(s0)
ffffffe00020144c:	00f687b3          	add	a5,a3,a5
ffffffe000201450:	00074703          	lbu	a4,0(a4)
ffffffe000201454:	00e78023          	sb	a4,0(a5)
            if (cpgtbl[i] != cearly_pgtbl[i]) LogRED("cpgtbl[%d] = cearly_pgtbl[%d] = %c", i, i, cpgtbl[i]);
ffffffe000201458:	fc843703          	ld	a4,-56(s0)
ffffffe00020145c:	fe043783          	ld	a5,-32(s0)
ffffffe000201460:	00f707b3          	add	a5,a4,a5
ffffffe000201464:	0007c683          	lbu	a3,0(a5)
ffffffe000201468:	fc043703          	ld	a4,-64(s0)
ffffffe00020146c:	fe043783          	ld	a5,-32(s0)
ffffffe000201470:	00f707b3          	add	a5,a4,a5
ffffffe000201474:	0007c783          	lbu	a5,0(a5)
ffffffe000201478:	00068713          	mv	a4,a3
ffffffe00020147c:	04f70263          	beq	a4,a5,ffffffe0002014c0 <task_init+0x220>
ffffffe000201480:	fc843703          	ld	a4,-56(s0)
ffffffe000201484:	fe043783          	ld	a5,-32(s0)
ffffffe000201488:	00f707b3          	add	a5,a4,a5
ffffffe00020148c:	0007c783          	lbu	a5,0(a5)
ffffffe000201490:	0007879b          	sext.w	a5,a5
ffffffe000201494:	00078813          	mv	a6,a5
ffffffe000201498:	fe043783          	ld	a5,-32(s0)
ffffffe00020149c:	fe043703          	ld	a4,-32(s0)
ffffffe0002014a0:	00003697          	auipc	a3,0x3
ffffffe0002014a4:	e0068693          	addi	a3,a3,-512 # ffffffe0002042a0 <__func__.0>
ffffffe0002014a8:	12500613          	li	a2,293
ffffffe0002014ac:	00003597          	auipc	a1,0x3
ffffffe0002014b0:	c7c58593          	addi	a1,a1,-900 # ffffffe000204128 <__func__.0+0x128>
ffffffe0002014b4:	00003517          	auipc	a0,0x3
ffffffe0002014b8:	cfc50513          	addi	a0,a0,-772 # ffffffe0002041b0 <__func__.0+0x1b0>
ffffffe0002014bc:	37d010ef          	jal	ra,ffffffe000203038 <printk>
        for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002014c0:	fe043783          	ld	a5,-32(s0)
ffffffe0002014c4:	00178793          	addi	a5,a5,1
ffffffe0002014c8:	fef43023          	sd	a5,-32(s0)
ffffffe0002014cc:	fe043703          	ld	a4,-32(s0)
ffffffe0002014d0:	000017b7          	lui	a5,0x1
ffffffe0002014d4:	f4f766e3          	bltu	a4,a5,ffffffe000201420 <task_init+0x180>
        }
        LogGREEN("_sramdisk = %p, _eramdisk = %p", _sramdisk, _eramdisk);
ffffffe0002014d8:	00006797          	auipc	a5,0x6
ffffffe0002014dc:	4d078793          	addi	a5,a5,1232 # ffffffe0002079a8 <_eramdisk>
ffffffe0002014e0:	00005717          	auipc	a4,0x5
ffffffe0002014e4:	b2070713          	addi	a4,a4,-1248 # ffffffe000206000 <_sramdisk>
ffffffe0002014e8:	00003697          	auipc	a3,0x3
ffffffe0002014ec:	db868693          	addi	a3,a3,-584 # ffffffe0002042a0 <__func__.0>
ffffffe0002014f0:	12700613          	li	a2,295
ffffffe0002014f4:	00003597          	auipc	a1,0x3
ffffffe0002014f8:	c3458593          	addi	a1,a1,-972 # ffffffe000204128 <__func__.0+0x128>
ffffffe0002014fc:	00003517          	auipc	a0,0x3
ffffffe000201500:	cf450513          	addi	a0,a0,-780 # ffffffe0002041f0 <__func__.0+0x1f0>
ffffffe000201504:	335010ef          	jal	ra,ffffffe000203038 <printk>

        load_program(ptask);
ffffffe000201508:	fd843503          	ld	a0,-40(s0)
ffffffe00020150c:	a3dff0ef          	jal	ra,ffffffe000200f48 <load_program>
        LogGREEN("[S-MODE] SET PID = %d, PGD = 0x%llx, PRIORITY = %d", ptask->pid, ptask->pgd, ptask->priority);
ffffffe000201510:	fd843783          	ld	a5,-40(s0)
ffffffe000201514:	0187b703          	ld	a4,24(a5)
ffffffe000201518:	fd843783          	ld	a5,-40(s0)
ffffffe00020151c:	0a87b683          	ld	a3,168(a5)
ffffffe000201520:	fd843783          	ld	a5,-40(s0)
ffffffe000201524:	0107b783          	ld	a5,16(a5)
ffffffe000201528:	00078813          	mv	a6,a5
ffffffe00020152c:	00068793          	mv	a5,a3
ffffffe000201530:	00003697          	auipc	a3,0x3
ffffffe000201534:	d7068693          	addi	a3,a3,-656 # ffffffe0002042a0 <__func__.0>
ffffffe000201538:	12a00613          	li	a2,298
ffffffe00020153c:	00003597          	auipc	a1,0x3
ffffffe000201540:	bec58593          	addi	a1,a1,-1044 # ffffffe000204128 <__func__.0+0x128>
ffffffe000201544:	00003517          	auipc	a0,0x3
ffffffe000201548:	ce450513          	addi	a0,a0,-796 # ffffffe000204228 <__func__.0+0x228>
ffffffe00020154c:	2ed010ef          	jal	ra,ffffffe000203038 <printk>
                
        task[i] = ptask;
ffffffe000201550:	00008717          	auipc	a4,0x8
ffffffe000201554:	ae070713          	addi	a4,a4,-1312 # ffffffe000209030 <task>
ffffffe000201558:	fec42783          	lw	a5,-20(s0)
ffffffe00020155c:	00379793          	slli	a5,a5,0x3
ffffffe000201560:	00f707b3          	add	a5,a4,a5
ffffffe000201564:	fd843703          	ld	a4,-40(s0)
ffffffe000201568:	00e7b023          	sd	a4,0(a5)
    for (int i = 1; i < NR_TASKS; i++){
ffffffe00020156c:	fec42783          	lw	a5,-20(s0)
ffffffe000201570:	0017879b          	addiw	a5,a5,1
ffffffe000201574:	fef42623          	sw	a5,-20(s0)
ffffffe000201578:	fec42783          	lw	a5,-20(s0)
ffffffe00020157c:	0007871b          	sext.w	a4,a5
ffffffe000201580:	01f00793          	li	a5,31
ffffffe000201584:	dce7d2e3          	bge	a5,a4,ffffffe000201348 <task_init+0xa8>
    }
    /* YOUR CODE HERE */

    printk("...task_init done!\n");
ffffffe000201588:	00003517          	auipc	a0,0x3
ffffffe00020158c:	cf050513          	addi	a0,a0,-784 # ffffffe000204278 <__func__.0+0x278>
ffffffe000201590:	2a9010ef          	jal	ra,ffffffe000203038 <printk>
ffffffe000201594:	00000013          	nop
ffffffe000201598:	03813083          	ld	ra,56(sp)
ffffffe00020159c:	03013403          	ld	s0,48(sp)
ffffffe0002015a0:	04010113          	addi	sp,sp,64
ffffffe0002015a4:	00008067          	ret

ffffffe0002015a8 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe0002015a8:	f8010113          	addi	sp,sp,-128
ffffffe0002015ac:	06813c23          	sd	s0,120(sp)
ffffffe0002015b0:	06913823          	sd	s1,112(sp)
ffffffe0002015b4:	07213423          	sd	s2,104(sp)
ffffffe0002015b8:	07313023          	sd	s3,96(sp)
ffffffe0002015bc:	08010413          	addi	s0,sp,128
ffffffe0002015c0:	faa43c23          	sd	a0,-72(s0)
ffffffe0002015c4:	fab43823          	sd	a1,-80(s0)
ffffffe0002015c8:	fac43423          	sd	a2,-88(s0)
ffffffe0002015cc:	fad43023          	sd	a3,-96(s0)
ffffffe0002015d0:	f8e43c23          	sd	a4,-104(s0)
ffffffe0002015d4:	f8f43823          	sd	a5,-112(s0)
ffffffe0002015d8:	f9043423          	sd	a6,-120(s0)
ffffffe0002015dc:	f9143023          	sd	a7,-128(s0)
    
    struct sbiret sbiRet;

    asm volatile (
ffffffe0002015e0:	fb843e03          	ld	t3,-72(s0)
ffffffe0002015e4:	fb043e83          	ld	t4,-80(s0)
ffffffe0002015e8:	fa843f03          	ld	t5,-88(s0)
ffffffe0002015ec:	fa043f83          	ld	t6,-96(s0)
ffffffe0002015f0:	f9843283          	ld	t0,-104(s0)
ffffffe0002015f4:	f9043483          	ld	s1,-112(s0)
ffffffe0002015f8:	f8843903          	ld	s2,-120(s0)
ffffffe0002015fc:	f8043983          	ld	s3,-128(s0)
ffffffe000201600:	01c008b3          	add	a7,zero,t3
ffffffe000201604:	01d00833          	add	a6,zero,t4
ffffffe000201608:	01e00533          	add	a0,zero,t5
ffffffe00020160c:	01f005b3          	add	a1,zero,t6
ffffffe000201610:	00500633          	add	a2,zero,t0
ffffffe000201614:	009006b3          	add	a3,zero,s1
ffffffe000201618:	01200733          	add	a4,zero,s2
ffffffe00020161c:	013007b3          	add	a5,zero,s3
ffffffe000201620:	00000073          	ecall
ffffffe000201624:	00050e93          	mv	t4,a0
ffffffe000201628:	00058e13          	mv	t3,a1
ffffffe00020162c:	fdd43023          	sd	t4,-64(s0)
ffffffe000201630:	fdc43423          	sd	t3,-56(s0)
        : "=r"(sbiRet.error), "=r"(sbiRet.value)
        : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );

    return sbiRet;
ffffffe000201634:	fc043783          	ld	a5,-64(s0)
ffffffe000201638:	fcf43823          	sd	a5,-48(s0)
ffffffe00020163c:	fc843783          	ld	a5,-56(s0)
ffffffe000201640:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201644:	fd043703          	ld	a4,-48(s0)
ffffffe000201648:	fd843783          	ld	a5,-40(s0)
ffffffe00020164c:	00070313          	mv	t1,a4
ffffffe000201650:	00078393          	mv	t2,a5
ffffffe000201654:	00030713          	mv	a4,t1
ffffffe000201658:	00038793          	mv	a5,t2
}
ffffffe00020165c:	00070513          	mv	a0,a4
ffffffe000201660:	00078593          	mv	a1,a5
ffffffe000201664:	07813403          	ld	s0,120(sp)
ffffffe000201668:	07013483          	ld	s1,112(sp)
ffffffe00020166c:	06813903          	ld	s2,104(sp)
ffffffe000201670:	06013983          	ld	s3,96(sp)
ffffffe000201674:	08010113          	addi	sp,sp,128
ffffffe000201678:	00008067          	ret

ffffffe00020167c <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe00020167c:	fc010113          	addi	sp,sp,-64
ffffffe000201680:	02113c23          	sd	ra,56(sp)
ffffffe000201684:	02813823          	sd	s0,48(sp)
ffffffe000201688:	03213423          	sd	s2,40(sp)
ffffffe00020168c:	03313023          	sd	s3,32(sp)
ffffffe000201690:	04010413          	addi	s0,sp,64
ffffffe000201694:	00050793          	mv	a5,a0
ffffffe000201698:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
ffffffe00020169c:	fcf44603          	lbu	a2,-49(s0)
ffffffe0002016a0:	00000893          	li	a7,0
ffffffe0002016a4:	00000813          	li	a6,0
ffffffe0002016a8:	00000793          	li	a5,0
ffffffe0002016ac:	00000713          	li	a4,0
ffffffe0002016b0:	00000693          	li	a3,0
ffffffe0002016b4:	00200593          	li	a1,2
ffffffe0002016b8:	44424537          	lui	a0,0x44424
ffffffe0002016bc:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe0002016c0:	ee9ff0ef          	jal	ra,ffffffe0002015a8 <sbi_ecall>
ffffffe0002016c4:	00050713          	mv	a4,a0
ffffffe0002016c8:	00058793          	mv	a5,a1
ffffffe0002016cc:	fce43823          	sd	a4,-48(s0)
ffffffe0002016d0:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002016d4:	fd043703          	ld	a4,-48(s0)
ffffffe0002016d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002016dc:	00070913          	mv	s2,a4
ffffffe0002016e0:	00078993          	mv	s3,a5
ffffffe0002016e4:	00090713          	mv	a4,s2
ffffffe0002016e8:	00098793          	mv	a5,s3
}
ffffffe0002016ec:	00070513          	mv	a0,a4
ffffffe0002016f0:	00078593          	mv	a1,a5
ffffffe0002016f4:	03813083          	ld	ra,56(sp)
ffffffe0002016f8:	03013403          	ld	s0,48(sp)
ffffffe0002016fc:	02813903          	ld	s2,40(sp)
ffffffe000201700:	02013983          	ld	s3,32(sp)
ffffffe000201704:	04010113          	addi	sp,sp,64
ffffffe000201708:	00008067          	ret

ffffffe00020170c <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe00020170c:	fc010113          	addi	sp,sp,-64
ffffffe000201710:	02113c23          	sd	ra,56(sp)
ffffffe000201714:	02813823          	sd	s0,48(sp)
ffffffe000201718:	03213423          	sd	s2,40(sp)
ffffffe00020171c:	03313023          	sd	s3,32(sp)
ffffffe000201720:	04010413          	addi	s0,sp,64
ffffffe000201724:	00050793          	mv	a5,a0
ffffffe000201728:	00058713          	mv	a4,a1
ffffffe00020172c:	fcf42623          	sw	a5,-52(s0)
ffffffe000201730:	00070793          	mv	a5,a4
ffffffe000201734:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe000201738:	fcc46603          	lwu	a2,-52(s0)
ffffffe00020173c:	fc846683          	lwu	a3,-56(s0)
ffffffe000201740:	00000893          	li	a7,0
ffffffe000201744:	00000813          	li	a6,0
ffffffe000201748:	00000793          	li	a5,0
ffffffe00020174c:	00000713          	li	a4,0
ffffffe000201750:	00000593          	li	a1,0
ffffffe000201754:	53525537          	lui	a0,0x53525
ffffffe000201758:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe00020175c:	e4dff0ef          	jal	ra,ffffffe0002015a8 <sbi_ecall>
ffffffe000201760:	00050713          	mv	a4,a0
ffffffe000201764:	00058793          	mv	a5,a1
ffffffe000201768:	fce43823          	sd	a4,-48(s0)
ffffffe00020176c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201770:	fd043703          	ld	a4,-48(s0)
ffffffe000201774:	fd843783          	ld	a5,-40(s0)
ffffffe000201778:	00070913          	mv	s2,a4
ffffffe00020177c:	00078993          	mv	s3,a5
ffffffe000201780:	00090713          	mv	a4,s2
ffffffe000201784:	00098793          	mv	a5,s3
}
ffffffe000201788:	00070513          	mv	a0,a4
ffffffe00020178c:	00078593          	mv	a1,a5
ffffffe000201790:	03813083          	ld	ra,56(sp)
ffffffe000201794:	03013403          	ld	s0,48(sp)
ffffffe000201798:	02813903          	ld	s2,40(sp)
ffffffe00020179c:	02013983          	ld	s3,32(sp)
ffffffe0002017a0:	04010113          	addi	sp,sp,64
ffffffe0002017a4:	00008067          	ret

ffffffe0002017a8 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe0002017a8:	fc010113          	addi	sp,sp,-64
ffffffe0002017ac:	02113c23          	sd	ra,56(sp)
ffffffe0002017b0:	02813823          	sd	s0,48(sp)
ffffffe0002017b4:	03213423          	sd	s2,40(sp)
ffffffe0002017b8:	03313023          	sd	s3,32(sp)
ffffffe0002017bc:	04010413          	addi	s0,sp,64
ffffffe0002017c0:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
ffffffe0002017c4:	00000893          	li	a7,0
ffffffe0002017c8:	00000813          	li	a6,0
ffffffe0002017cc:	00000793          	li	a5,0
ffffffe0002017d0:	00000713          	li	a4,0
ffffffe0002017d4:	00000693          	li	a3,0
ffffffe0002017d8:	fc843603          	ld	a2,-56(s0)
ffffffe0002017dc:	00000593          	li	a1,0
ffffffe0002017e0:	54495537          	lui	a0,0x54495
ffffffe0002017e4:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe0002017e8:	dc1ff0ef          	jal	ra,ffffffe0002015a8 <sbi_ecall>
ffffffe0002017ec:	00050713          	mv	a4,a0
ffffffe0002017f0:	00058793          	mv	a5,a1
ffffffe0002017f4:	fce43823          	sd	a4,-48(s0)
ffffffe0002017f8:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002017fc:	fd043703          	ld	a4,-48(s0)
ffffffe000201800:	fd843783          	ld	a5,-40(s0)
ffffffe000201804:	00070913          	mv	s2,a4
ffffffe000201808:	00078993          	mv	s3,a5
ffffffe00020180c:	00090713          	mv	a4,s2
ffffffe000201810:	00098793          	mv	a5,s3
ffffffe000201814:	00070513          	mv	a0,a4
ffffffe000201818:	00078593          	mv	a1,a5
ffffffe00020181c:	03813083          	ld	ra,56(sp)
ffffffe000201820:	03013403          	ld	s0,48(sp)
ffffffe000201824:	02813903          	ld	s2,40(sp)
ffffffe000201828:	02013983          	ld	s3,32(sp)
ffffffe00020182c:	04010113          	addi	sp,sp,64
ffffffe000201830:	00008067          	ret

ffffffe000201834 <trap_handler>:
#include "defs.h"
#include "proc.h"

extern struct task_struct *current;

void trap_handler(uint64_t scause, uint64_t sepc, uint64_t sstatus, struct pt_regs *regs) {
ffffffe000201834:	fb010113          	addi	sp,sp,-80
ffffffe000201838:	04113423          	sd	ra,72(sp)
ffffffe00020183c:	04813023          	sd	s0,64(sp)
ffffffe000201840:	05010413          	addi	s0,sp,80
ffffffe000201844:	fca43423          	sd	a0,-56(s0)
ffffffe000201848:	fcb43023          	sd	a1,-64(s0)
ffffffe00020184c:	fac43c23          	sd	a2,-72(s0)
ffffffe000201850:	fad43823          	sd	a3,-80(s0)
    // 通过 `scause` 判断 trap 类型
    if(scause == 0x8000000000000005){
ffffffe000201854:	fc843703          	ld	a4,-56(s0)
ffffffe000201858:	fff00793          	li	a5,-1
ffffffe00020185c:	03f79793          	slli	a5,a5,0x3f
ffffffe000201860:	00578793          	addi	a5,a5,5
ffffffe000201864:	02f71863          	bne	a4,a5,ffffffe000201894 <trap_handler+0x60>
        LogRED("Timer Interrupt");
ffffffe000201868:	00003697          	auipc	a3,0x3
ffffffe00020186c:	c5868693          	addi	a3,a3,-936 # ffffffe0002044c0 <__func__.1>
ffffffe000201870:	00d00613          	li	a2,13
ffffffe000201874:	00003597          	auipc	a1,0x3
ffffffe000201878:	a3c58593          	addi	a1,a1,-1476 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe00020187c:	00003517          	auipc	a0,0x3
ffffffe000201880:	a3c50513          	addi	a0,a0,-1476 # ffffffe0002042b8 <__func__.0+0x18>
ffffffe000201884:	7b4010ef          	jal	ra,ffffffe000203038 <printk>
        clock_set_next_event();
ffffffe000201888:	a5dfe0ef          	jal	ra,ffffffe0002002e4 <clock_set_next_event>
        do_timer();
ffffffe00020188c:	bd0ff0ef          	jal	ra,ffffffe000200c5c <do_timer>
ffffffe000201890:	1380006f          	j	ffffffe0002019c8 <trap_handler+0x194>
    }else if(scause == 0xc){
ffffffe000201894:	fc843703          	ld	a4,-56(s0)
ffffffe000201898:	00c00793          	li	a5,12
ffffffe00020189c:	08f71c63          	bne	a4,a5,ffffffe000201934 <trap_handler+0x100>
        LogRED("Instruction Page Fault");
ffffffe0002018a0:	00003697          	auipc	a3,0x3
ffffffe0002018a4:	c2068693          	addi	a3,a3,-992 # ffffffe0002044c0 <__func__.1>
ffffffe0002018a8:	01100613          	li	a2,17
ffffffe0002018ac:	00003597          	auipc	a1,0x3
ffffffe0002018b0:	a0458593          	addi	a1,a1,-1532 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe0002018b4:	00003517          	auipc	a0,0x3
ffffffe0002018b8:	a2c50513          	addi	a0,a0,-1492 # ffffffe0002042e0 <__func__.0+0x40>
ffffffe0002018bc:	77c010ef          	jal	ra,ffffffe000203038 <printk>
        if(sepc < VM_START && sepc > USER_END){
ffffffe0002018c0:	fc043703          	ld	a4,-64(s0)
ffffffe0002018c4:	fff00793          	li	a5,-1
ffffffe0002018c8:	02579793          	slli	a5,a5,0x25
ffffffe0002018cc:	0ef77e63          	bgeu	a4,a5,ffffffe0002019c8 <trap_handler+0x194>
ffffffe0002018d0:	fc043703          	ld	a4,-64(s0)
ffffffe0002018d4:	00100793          	li	a5,1
ffffffe0002018d8:	02679793          	slli	a5,a5,0x26
ffffffe0002018dc:	0ee7f663          	bgeu	a5,a4,ffffffe0002019c8 <trap_handler+0x194>
            LogGREEN("[Physical Address: 0x%llx] -> [Virtual Address: 0x%llx]", sepc, sepc + 0xffffffdf80000000);
ffffffe0002018e0:	fc043703          	ld	a4,-64(s0)
ffffffe0002018e4:	fbf00793          	li	a5,-65
ffffffe0002018e8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002018ec:	00f707b3          	add	a5,a4,a5
ffffffe0002018f0:	fc043703          	ld	a4,-64(s0)
ffffffe0002018f4:	00003697          	auipc	a3,0x3
ffffffe0002018f8:	bcc68693          	addi	a3,a3,-1076 # ffffffe0002044c0 <__func__.1>
ffffffe0002018fc:	01300613          	li	a2,19
ffffffe000201900:	00003597          	auipc	a1,0x3
ffffffe000201904:	9b058593          	addi	a1,a1,-1616 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe000201908:	00003517          	auipc	a0,0x3
ffffffe00020190c:	a0850513          	addi	a0,a0,-1528 # ffffffe000204310 <__func__.0+0x70>
ffffffe000201910:	728010ef          	jal	ra,ffffffe000203038 <printk>
            csr_write(sepc, sepc + 0xffffffdf80000000);
ffffffe000201914:	fc043703          	ld	a4,-64(s0)
ffffffe000201918:	fbf00793          	li	a5,-65
ffffffe00020191c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201920:	00f707b3          	add	a5,a4,a5
ffffffe000201924:	fef43423          	sd	a5,-24(s0)
ffffffe000201928:	fe843783          	ld	a5,-24(s0)
ffffffe00020192c:	14179073          	csrw	sepc,a5
            return;
ffffffe000201930:	0f40006f          	j	ffffffe000201a24 <trap_handler+0x1f0>
        }
    }else if(scause == 0xf){
ffffffe000201934:	fc843703          	ld	a4,-56(s0)
ffffffe000201938:	00f00793          	li	a5,15
ffffffe00020193c:	02f71463          	bne	a4,a5,ffffffe000201964 <trap_handler+0x130>
        LogRED("Store/AMO Page Fault");
ffffffe000201940:	00003697          	auipc	a3,0x3
ffffffe000201944:	b8068693          	addi	a3,a3,-1152 # ffffffe0002044c0 <__func__.1>
ffffffe000201948:	01800613          	li	a2,24
ffffffe00020194c:	00003597          	auipc	a1,0x3
ffffffe000201950:	96458593          	addi	a1,a1,-1692 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe000201954:	00003517          	auipc	a0,0x3
ffffffe000201958:	a0c50513          	addi	a0,a0,-1524 # ffffffe000204360 <__func__.0+0xc0>
ffffffe00020195c:	6dc010ef          	jal	ra,ffffffe000203038 <printk>
ffffffe000201960:	0680006f          	j	ffffffe0002019c8 <trap_handler+0x194>
    }else if(scause == 0xd){
ffffffe000201964:	fc843703          	ld	a4,-56(s0)
ffffffe000201968:	00d00793          	li	a5,13
ffffffe00020196c:	02f71463          	bne	a4,a5,ffffffe000201994 <trap_handler+0x160>
        LogRED("Load Page Fault");
ffffffe000201970:	00003697          	auipc	a3,0x3
ffffffe000201974:	b5068693          	addi	a3,a3,-1200 # ffffffe0002044c0 <__func__.1>
ffffffe000201978:	01a00613          	li	a2,26
ffffffe00020197c:	00003597          	auipc	a1,0x3
ffffffe000201980:	93458593          	addi	a1,a1,-1740 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe000201984:	00003517          	auipc	a0,0x3
ffffffe000201988:	a0c50513          	addi	a0,a0,-1524 # ffffffe000204390 <__func__.0+0xf0>
ffffffe00020198c:	6ac010ef          	jal	ra,ffffffe000203038 <printk>
ffffffe000201990:	0380006f          	j	ffffffe0002019c8 <trap_handler+0x194>
    }else if(scause == 0x8){
ffffffe000201994:	fc843703          	ld	a4,-56(s0)
ffffffe000201998:	00800793          	li	a5,8
ffffffe00020199c:	02f71663          	bne	a4,a5,ffffffe0002019c8 <trap_handler+0x194>
        LogRED("Environment Call from U-mode");
ffffffe0002019a0:	00003697          	auipc	a3,0x3
ffffffe0002019a4:	b2068693          	addi	a3,a3,-1248 # ffffffe0002044c0 <__func__.1>
ffffffe0002019a8:	01c00613          	li	a2,28
ffffffe0002019ac:	00003597          	auipc	a1,0x3
ffffffe0002019b0:	90458593          	addi	a1,a1,-1788 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe0002019b4:	00003517          	auipc	a0,0x3
ffffffe0002019b8:	a0450513          	addi	a0,a0,-1532 # ffffffe0002043b8 <__func__.0+0x118>
ffffffe0002019bc:	67c010ef          	jal	ra,ffffffe000203038 <printk>
        syscall(regs);
ffffffe0002019c0:	fb043503          	ld	a0,-80(s0)
ffffffe0002019c4:	0a8000ef          	jal	ra,ffffffe000201a6c <syscall>
    }

    if (scause & 0x8000000000000000) {
ffffffe0002019c8:	fc843783          	ld	a5,-56(s0)
ffffffe0002019cc:	0007dc63          	bgez	a5,ffffffe0002019e4 <trap_handler+0x1b0>
        csr_write(sepc, sepc);
ffffffe0002019d0:	fc043783          	ld	a5,-64(s0)
ffffffe0002019d4:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002019d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002019dc:	14179073          	csrw	sepc,a5
ffffffe0002019e0:	0180006f          	j	ffffffe0002019f8 <trap_handler+0x1c4>
    } else {
        csr_write(sepc, sepc + 4);
ffffffe0002019e4:	fc043783          	ld	a5,-64(s0)
ffffffe0002019e8:	00478793          	addi	a5,a5,4
ffffffe0002019ec:	fef43023          	sd	a5,-32(s0)
ffffffe0002019f0:	fe043783          	ld	a5,-32(s0)
ffffffe0002019f4:	14179073          	csrw	sepc,a5
    }
    LogPURPLE("scause: 0x%llx, sstatus: 0x%llx, sepc: 0x%llx", scause, sstatus, sepc);
ffffffe0002019f8:	fc043803          	ld	a6,-64(s0)
ffffffe0002019fc:	fb843783          	ld	a5,-72(s0)
ffffffe000201a00:	fc843703          	ld	a4,-56(s0)
ffffffe000201a04:	00003697          	auipc	a3,0x3
ffffffe000201a08:	abc68693          	addi	a3,a3,-1348 # ffffffe0002044c0 <__func__.1>
ffffffe000201a0c:	02500613          	li	a2,37
ffffffe000201a10:	00003597          	auipc	a1,0x3
ffffffe000201a14:	8a058593          	addi	a1,a1,-1888 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe000201a18:	00003517          	auipc	a0,0x3
ffffffe000201a1c:	9d850513          	addi	a0,a0,-1576 # ffffffe0002043f0 <__func__.0+0x150>
ffffffe000201a20:	618010ef          	jal	ra,ffffffe000203038 <printk>
}
ffffffe000201a24:	04813083          	ld	ra,72(sp)
ffffffe000201a28:	04013403          	ld	s0,64(sp)
ffffffe000201a2c:	05010113          	addi	sp,sp,80
ffffffe000201a30:	00008067          	ret

ffffffe000201a34 <csr_change>:


void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
ffffffe000201a34:	fc010113          	addi	sp,sp,-64
ffffffe000201a38:	02813c23          	sd	s0,56(sp)
ffffffe000201a3c:	04010413          	addi	s0,sp,64
ffffffe000201a40:	fca43c23          	sd	a0,-40(s0)
ffffffe000201a44:	fcb43823          	sd	a1,-48(s0)
ffffffe000201a48:	fcc43423          	sd	a2,-56(s0)
    csr_write(sscratch, value);
ffffffe000201a4c:	fc843783          	ld	a5,-56(s0)
ffffffe000201a50:	fef43423          	sd	a5,-24(s0)
ffffffe000201a54:	fe843783          	ld	a5,-24(s0)
ffffffe000201a58:	14079073          	csrw	sscratch,a5
}
ffffffe000201a5c:	00000013          	nop
ffffffe000201a60:	03813403          	ld	s0,56(sp)
ffffffe000201a64:	04010113          	addi	sp,sp,64
ffffffe000201a68:	00008067          	ret

ffffffe000201a6c <syscall>:

void syscall(struct pt_regs *regs) {
ffffffe000201a6c:	fc010113          	addi	sp,sp,-64
ffffffe000201a70:	02113c23          	sd	ra,56(sp)
ffffffe000201a74:	02813823          	sd	s0,48(sp)
ffffffe000201a78:	04010413          	addi	s0,sp,64
ffffffe000201a7c:	fca43423          	sd	a0,-56(s0)
    uint64_t syscall_num = regs->x[17];
ffffffe000201a80:	fc843783          	ld	a5,-56(s0)
ffffffe000201a84:	0887b783          	ld	a5,136(a5)
ffffffe000201a88:	fef43023          	sd	a5,-32(s0)
    if (syscall_num == (uint64_t)SYS_WRITE) {
ffffffe000201a8c:	fe043703          	ld	a4,-32(s0)
ffffffe000201a90:	04000793          	li	a5,64
ffffffe000201a94:	0af71463          	bne	a4,a5,ffffffe000201b3c <syscall+0xd0>
        uint64_t fd = regs->x[10];
ffffffe000201a98:	fc843783          	ld	a5,-56(s0)
ffffffe000201a9c:	0507b783          	ld	a5,80(a5)
ffffffe000201aa0:	fcf43c23          	sd	a5,-40(s0)
        uint64_t i = 0;
ffffffe000201aa4:	fe043423          	sd	zero,-24(s0)
        if (fd == 1) {
ffffffe000201aa8:	fd843703          	ld	a4,-40(s0)
ffffffe000201aac:	00100793          	li	a5,1
ffffffe000201ab0:	04f71c63          	bne	a4,a5,ffffffe000201b08 <syscall+0x9c>
            char *buf = (char *)regs->x[11];
ffffffe000201ab4:	fc843783          	ld	a5,-56(s0)
ffffffe000201ab8:	0587b783          	ld	a5,88(a5)
ffffffe000201abc:	fcf43823          	sd	a5,-48(s0)
            for (i = 0; i < regs->x[12]; i++) {
ffffffe000201ac0:	fe043423          	sd	zero,-24(s0)
ffffffe000201ac4:	0340006f          	j	ffffffe000201af8 <syscall+0x8c>
                printk("%c", buf[i]);
ffffffe000201ac8:	fd043703          	ld	a4,-48(s0)
ffffffe000201acc:	fe843783          	ld	a5,-24(s0)
ffffffe000201ad0:	00f707b3          	add	a5,a4,a5
ffffffe000201ad4:	0007c783          	lbu	a5,0(a5)
ffffffe000201ad8:	0007879b          	sext.w	a5,a5
ffffffe000201adc:	00078593          	mv	a1,a5
ffffffe000201ae0:	00003517          	auipc	a0,0x3
ffffffe000201ae4:	95850513          	addi	a0,a0,-1704 # ffffffe000204438 <__func__.0+0x198>
ffffffe000201ae8:	550010ef          	jal	ra,ffffffe000203038 <printk>
            for (i = 0; i < regs->x[12]; i++) {
ffffffe000201aec:	fe843783          	ld	a5,-24(s0)
ffffffe000201af0:	00178793          	addi	a5,a5,1
ffffffe000201af4:	fef43423          	sd	a5,-24(s0)
ffffffe000201af8:	fc843783          	ld	a5,-56(s0)
ffffffe000201afc:	0607b783          	ld	a5,96(a5)
ffffffe000201b00:	fe843703          	ld	a4,-24(s0)
ffffffe000201b04:	fcf762e3          	bltu	a4,a5,ffffffe000201ac8 <syscall+0x5c>
            }
        }
        regs->x[10] = i;
ffffffe000201b08:	fc843783          	ld	a5,-56(s0)
ffffffe000201b0c:	fe843703          	ld	a4,-24(s0)
ffffffe000201b10:	04e7b823          	sd	a4,80(a5)
        LogDEEPGREEN("Write: %d", i);
ffffffe000201b14:	fe843703          	ld	a4,-24(s0)
ffffffe000201b18:	00002697          	auipc	a3,0x2
ffffffe000201b1c:	4e868693          	addi	a3,a3,1256 # ffffffe000204000 <__func__.0>
ffffffe000201b20:	03900613          	li	a2,57
ffffffe000201b24:	00002597          	auipc	a1,0x2
ffffffe000201b28:	78c58593          	addi	a1,a1,1932 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe000201b2c:	00003517          	auipc	a0,0x3
ffffffe000201b30:	91450513          	addi	a0,a0,-1772 # ffffffe000204440 <__func__.0+0x1a0>
ffffffe000201b34:	504010ef          	jal	ra,ffffffe000203038 <printk>
        regs->x[10] = current->pid;
        LogDEEPGREEN("Getpid: %d", current->pid);
    } else {
        LogRED("Unsupported syscall: %d", syscall_num);
    }
    return;
ffffffe000201b38:	0880006f          	j	ffffffe000201bc0 <syscall+0x154>
    } else if (syscall_num == (uint64_t)SYS_GETPID) {
ffffffe000201b3c:	fe043703          	ld	a4,-32(s0)
ffffffe000201b40:	0ac00793          	li	a5,172
ffffffe000201b44:	04f71a63          	bne	a4,a5,ffffffe000201b98 <syscall+0x12c>
        regs->x[10] = current->pid;
ffffffe000201b48:	00007797          	auipc	a5,0x7
ffffffe000201b4c:	4c878793          	addi	a5,a5,1224 # ffffffe000209010 <current>
ffffffe000201b50:	0007b783          	ld	a5,0(a5)
ffffffe000201b54:	0187b703          	ld	a4,24(a5)
ffffffe000201b58:	fc843783          	ld	a5,-56(s0)
ffffffe000201b5c:	04e7b823          	sd	a4,80(a5)
        LogDEEPGREEN("Getpid: %d", current->pid);
ffffffe000201b60:	00007797          	auipc	a5,0x7
ffffffe000201b64:	4b078793          	addi	a5,a5,1200 # ffffffe000209010 <current>
ffffffe000201b68:	0007b783          	ld	a5,0(a5)
ffffffe000201b6c:	0187b783          	ld	a5,24(a5)
ffffffe000201b70:	00078713          	mv	a4,a5
ffffffe000201b74:	00002697          	auipc	a3,0x2
ffffffe000201b78:	48c68693          	addi	a3,a3,1164 # ffffffe000204000 <__func__.0>
ffffffe000201b7c:	03c00613          	li	a2,60
ffffffe000201b80:	00002597          	auipc	a1,0x2
ffffffe000201b84:	73058593          	addi	a1,a1,1840 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe000201b88:	00003517          	auipc	a0,0x3
ffffffe000201b8c:	8e050513          	addi	a0,a0,-1824 # ffffffe000204468 <__func__.0+0x1c8>
ffffffe000201b90:	4a8010ef          	jal	ra,ffffffe000203038 <printk>
    return;
ffffffe000201b94:	02c0006f          	j	ffffffe000201bc0 <syscall+0x154>
        LogRED("Unsupported syscall: %d", syscall_num);
ffffffe000201b98:	fe043703          	ld	a4,-32(s0)
ffffffe000201b9c:	00002697          	auipc	a3,0x2
ffffffe000201ba0:	46468693          	addi	a3,a3,1124 # ffffffe000204000 <__func__.0>
ffffffe000201ba4:	03e00613          	li	a2,62
ffffffe000201ba8:	00002597          	auipc	a1,0x2
ffffffe000201bac:	70858593          	addi	a1,a1,1800 # ffffffe0002042b0 <__func__.0+0x10>
ffffffe000201bb0:	00003517          	auipc	a0,0x3
ffffffe000201bb4:	8e050513          	addi	a0,a0,-1824 # ffffffe000204490 <__func__.0+0x1f0>
ffffffe000201bb8:	480010ef          	jal	ra,ffffffe000203038 <printk>
    return;
ffffffe000201bbc:	00000013          	nop
ffffffe000201bc0:	03813083          	ld	ra,56(sp)
ffffffe000201bc4:	03013403          	ld	s0,48(sp)
ffffffe000201bc8:	04010113          	addi	sp,sp,64
ffffffe000201bcc:	00008067          	ret

ffffffe000201bd0 <setup_vm>:
#include "printk.h"

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe000201bd0:	fd010113          	addi	sp,sp,-48
ffffffe000201bd4:	02113423          	sd	ra,40(sp)
ffffffe000201bd8:	02813023          	sd	s0,32(sp)
ffffffe000201bdc:	03010413          	addi	s0,sp,48
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
    memset(early_pgtbl, 0x0, PGSIZE);
ffffffe000201be0:	00001637          	lui	a2,0x1
ffffffe000201be4:	00000593          	li	a1,0
ffffffe000201be8:	00008517          	auipc	a0,0x8
ffffffe000201bec:	41850513          	addi	a0,a0,1048 # ffffffe00020a000 <early_pgtbl>
ffffffe000201bf0:	568010ef          	jal	ra,ffffffe000203158 <memset>
    uint64_t va = VM_START;
ffffffe000201bf4:	fff00793          	li	a5,-1
ffffffe000201bf8:	02579793          	slli	a5,a5,0x25
ffffffe000201bfc:	fef43423          	sd	a5,-24(s0)
    uint64_t pa = PHY_START;
ffffffe000201c00:	00100793          	li	a5,1
ffffffe000201c04:	01f79793          	slli	a5,a5,0x1f
ffffffe000201c08:	fef43023          	sd	a5,-32(s0)
    LogGREEN("early_pgtbl: 0x%llx\n", early_pgtbl);
ffffffe000201c0c:	00008717          	auipc	a4,0x8
ffffffe000201c10:	3f470713          	addi	a4,a4,1012 # ffffffe00020a000 <early_pgtbl>
ffffffe000201c14:	00003697          	auipc	a3,0x3
ffffffe000201c18:	9f468693          	addi	a3,a3,-1548 # ffffffe000204608 <__func__.2>
ffffffe000201c1c:	01300613          	li	a2,19
ffffffe000201c20:	00003597          	auipc	a1,0x3
ffffffe000201c24:	8b058593          	addi	a1,a1,-1872 # ffffffe0002044d0 <__func__.1+0x10>
ffffffe000201c28:	00003517          	auipc	a0,0x3
ffffffe000201c2c:	8b050513          	addi	a0,a0,-1872 # ffffffe0002044d8 <__func__.1+0x18>
ffffffe000201c30:	408010ef          	jal	ra,ffffffe000203038 <printk>
    uint64_t index = (pa >> 30) & 0x1ff;
ffffffe000201c34:	fe043783          	ld	a5,-32(s0)
ffffffe000201c38:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201c3c:	1ff7f793          	andi	a5,a5,511
ffffffe000201c40:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe000201c44:	fd843583          	ld	a1,-40(s0)
ffffffe000201c48:	00003517          	auipc	a0,0x3
ffffffe000201c4c:	8c050513          	addi	a0,a0,-1856 # ffffffe000204508 <__func__.1+0x48>
ffffffe000201c50:	3e8010ef          	jal	ra,ffffffe000203038 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe000201c54:	fe043783          	ld	a5,-32(s0)
ffffffe000201c58:	0027d713          	srli	a4,a5,0x2
ffffffe000201c5c:	040007b7          	lui	a5,0x4000
ffffffe000201c60:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000201c64:	01c79793          	slli	a5,a5,0x1c
ffffffe000201c68:	00f777b3          	and	a5,a4,a5
ffffffe000201c6c:	00f7e713          	ori	a4,a5,15
ffffffe000201c70:	00008697          	auipc	a3,0x8
ffffffe000201c74:	39068693          	addi	a3,a3,912 # ffffffe00020a000 <early_pgtbl>
ffffffe000201c78:	fd843783          	ld	a5,-40(s0)
ffffffe000201c7c:	00379793          	slli	a5,a5,0x3
ffffffe000201c80:	00f687b3          	add	a5,a3,a5
ffffffe000201c84:	00e7b023          	sd	a4,0(a5)

    index = (va >> 30) & 0x1ff;
ffffffe000201c88:	fe843783          	ld	a5,-24(s0)
ffffffe000201c8c:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201c90:	1ff7f793          	andi	a5,a5,511
ffffffe000201c94:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe000201c98:	fd843583          	ld	a1,-40(s0)
ffffffe000201c9c:	00003517          	auipc	a0,0x3
ffffffe000201ca0:	86c50513          	addi	a0,a0,-1940 # ffffffe000204508 <__func__.1+0x48>
ffffffe000201ca4:	394010ef          	jal	ra,ffffffe000203038 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe000201ca8:	fe043783          	ld	a5,-32(s0)
ffffffe000201cac:	0027d713          	srli	a4,a5,0x2
ffffffe000201cb0:	040007b7          	lui	a5,0x4000
ffffffe000201cb4:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000201cb8:	01c79793          	slli	a5,a5,0x1c
ffffffe000201cbc:	00f777b3          	and	a5,a4,a5
ffffffe000201cc0:	00f7e713          	ori	a4,a5,15
ffffffe000201cc4:	00008697          	auipc	a3,0x8
ffffffe000201cc8:	33c68693          	addi	a3,a3,828 # ffffffe00020a000 <early_pgtbl>
ffffffe000201ccc:	fd843783          	ld	a5,-40(s0)
ffffffe000201cd0:	00379793          	slli	a5,a5,0x3
ffffffe000201cd4:	00f687b3          	add	a5,a3,a5
ffffffe000201cd8:	00e7b023          	sd	a4,0(a5)

    printk("setup_vm done...\n");
ffffffe000201cdc:	00003517          	auipc	a0,0x3
ffffffe000201ce0:	83c50513          	addi	a0,a0,-1988 # ffffffe000204518 <__func__.1+0x58>
ffffffe000201ce4:	354010ef          	jal	ra,ffffffe000203038 <printk>
}
ffffffe000201ce8:	00000013          	nop
ffffffe000201cec:	02813083          	ld	ra,40(sp)
ffffffe000201cf0:	02013403          	ld	s0,32(sp)
ffffffe000201cf4:	03010113          	addi	sp,sp,48
ffffffe000201cf8:	00008067          	ret

ffffffe000201cfc <setup_vm_final>:
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

void setup_vm_final() {
ffffffe000201cfc:	fc010113          	addi	sp,sp,-64
ffffffe000201d00:	02113c23          	sd	ra,56(sp)
ffffffe000201d04:	02813823          	sd	s0,48(sp)
ffffffe000201d08:	04010413          	addi	s0,sp,64
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000201d0c:	00001637          	lui	a2,0x1
ffffffe000201d10:	00000593          	li	a1,0
ffffffe000201d14:	00009517          	auipc	a0,0x9
ffffffe000201d18:	2ec50513          	addi	a0,a0,748 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201d1c:	43c010ef          	jal	ra,ffffffe000203158 <memset>
    LogYELLOW("_stext: %p, _etext: %p, _srodata: %p, _erodata: %p, _sdata: %p, _edata: %p, _sbss: %p, _ebss: %p\n", _stext, _etext, _srodata, _erodata, _sdata, _edata, _sbss, _ebss);
ffffffe000201d20:	0000a797          	auipc	a5,0xa
ffffffe000201d24:	2e078793          	addi	a5,a5,736 # ffffffe00020c000 <_ebss>
ffffffe000201d28:	00f13c23          	sd	a5,24(sp)
ffffffe000201d2c:	00006797          	auipc	a5,0x6
ffffffe000201d30:	2d478793          	addi	a5,a5,724 # ffffffe000208000 <_sbss>
ffffffe000201d34:	00f13823          	sd	a5,16(sp)
ffffffe000201d38:	00003797          	auipc	a5,0x3
ffffffe000201d3c:	2d878793          	addi	a5,a5,728 # ffffffe000205010 <_edata>
ffffffe000201d40:	00f13423          	sd	a5,8(sp)
ffffffe000201d44:	00003797          	auipc	a5,0x3
ffffffe000201d48:	2bc78793          	addi	a5,a5,700 # ffffffe000205000 <TIMECLOCK>
ffffffe000201d4c:	00f13023          	sd	a5,0(sp)
ffffffe000201d50:	00003897          	auipc	a7,0x3
ffffffe000201d54:	97888893          	addi	a7,a7,-1672 # ffffffe0002046c8 <_erodata>
ffffffe000201d58:	00002817          	auipc	a6,0x2
ffffffe000201d5c:	2a880813          	addi	a6,a6,680 # ffffffe000204000 <__func__.0>
ffffffe000201d60:	00001797          	auipc	a5,0x1
ffffffe000201d64:	46878793          	addi	a5,a5,1128 # ffffffe0002031c8 <_etext>
ffffffe000201d68:	ffffe717          	auipc	a4,0xffffe
ffffffe000201d6c:	29870713          	addi	a4,a4,664 # ffffffe000200000 <_skernel>
ffffffe000201d70:	00003697          	auipc	a3,0x3
ffffffe000201d74:	8a868693          	addi	a3,a3,-1880 # ffffffe000204618 <__func__.1>
ffffffe000201d78:	02700613          	li	a2,39
ffffffe000201d7c:	00002597          	auipc	a1,0x2
ffffffe000201d80:	75458593          	addi	a1,a1,1876 # ffffffe0002044d0 <__func__.1+0x10>
ffffffe000201d84:	00002517          	auipc	a0,0x2
ffffffe000201d88:	7ac50513          	addi	a0,a0,1964 # ffffffe000204530 <__func__.1+0x70>
ffffffe000201d8c:	2ac010ef          	jal	ra,ffffffe000203038 <printk>

    // No OpenSBI mapping required
    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, _stext, _stext - PA2VA_OFFSET, _srodata - _stext, PTE_X | PTE_R | PTE_V);;
ffffffe000201d90:	ffffe597          	auipc	a1,0xffffe
ffffffe000201d94:	27058593          	addi	a1,a1,624 # ffffffe000200000 <_skernel>
ffffffe000201d98:	ffffe717          	auipc	a4,0xffffe
ffffffe000201d9c:	26870713          	addi	a4,a4,616 # ffffffe000200000 <_skernel>
ffffffe000201da0:	04100793          	li	a5,65
ffffffe000201da4:	01f79793          	slli	a5,a5,0x1f
ffffffe000201da8:	00f707b3          	add	a5,a4,a5
ffffffe000201dac:	00078613          	mv	a2,a5
ffffffe000201db0:	00002717          	auipc	a4,0x2
ffffffe000201db4:	25070713          	addi	a4,a4,592 # ffffffe000204000 <__func__.0>
ffffffe000201db8:	ffffe797          	auipc	a5,0xffffe
ffffffe000201dbc:	24878793          	addi	a5,a5,584 # ffffffe000200000 <_skernel>
ffffffe000201dc0:	40f707b3          	sub	a5,a4,a5
ffffffe000201dc4:	00b00713          	li	a4,11
ffffffe000201dc8:	00078693          	mv	a3,a5
ffffffe000201dcc:	00009517          	auipc	a0,0x9
ffffffe000201dd0:	23450513          	addi	a0,a0,564 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201dd4:	0ec000ef          	jal	ra,ffffffe000201ec0 <create_mapping>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, _srodata, _srodata - PA2VA_OFFSET, _sdata - _srodata, PTE_R | PTE_V);
ffffffe000201dd8:	00002597          	auipc	a1,0x2
ffffffe000201ddc:	22858593          	addi	a1,a1,552 # ffffffe000204000 <__func__.0>
ffffffe000201de0:	00002717          	auipc	a4,0x2
ffffffe000201de4:	22070713          	addi	a4,a4,544 # ffffffe000204000 <__func__.0>
ffffffe000201de8:	04100793          	li	a5,65
ffffffe000201dec:	01f79793          	slli	a5,a5,0x1f
ffffffe000201df0:	00f707b3          	add	a5,a4,a5
ffffffe000201df4:	00078613          	mv	a2,a5
ffffffe000201df8:	00003717          	auipc	a4,0x3
ffffffe000201dfc:	20870713          	addi	a4,a4,520 # ffffffe000205000 <TIMECLOCK>
ffffffe000201e00:	00002797          	auipc	a5,0x2
ffffffe000201e04:	20078793          	addi	a5,a5,512 # ffffffe000204000 <__func__.0>
ffffffe000201e08:	40f707b3          	sub	a5,a4,a5
ffffffe000201e0c:	00300713          	li	a4,3
ffffffe000201e10:	00078693          	mv	a3,a5
ffffffe000201e14:	00009517          	auipc	a0,0x9
ffffffe000201e18:	1ec50513          	addi	a0,a0,492 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201e1c:	0a4000ef          	jal	ra,ffffffe000201ec0 <create_mapping>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir, _sdata, _sdata - PA2VA_OFFSET, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V);
ffffffe000201e20:	00003597          	auipc	a1,0x3
ffffffe000201e24:	1e058593          	addi	a1,a1,480 # ffffffe000205000 <TIMECLOCK>
ffffffe000201e28:	00003717          	auipc	a4,0x3
ffffffe000201e2c:	1d870713          	addi	a4,a4,472 # ffffffe000205000 <TIMECLOCK>
ffffffe000201e30:	04100793          	li	a5,65
ffffffe000201e34:	01f79793          	slli	a5,a5,0x1f
ffffffe000201e38:	00f707b3          	add	a5,a4,a5
ffffffe000201e3c:	00078613          	mv	a2,a5
ffffffe000201e40:	00003717          	auipc	a4,0x3
ffffffe000201e44:	1c070713          	addi	a4,a4,448 # ffffffe000205000 <TIMECLOCK>
ffffffe000201e48:	ffffe797          	auipc	a5,0xffffe
ffffffe000201e4c:	1b878793          	addi	a5,a5,440 # ffffffe000200000 <_skernel>
ffffffe000201e50:	40f707b3          	sub	a5,a4,a5
ffffffe000201e54:	08000737          	lui	a4,0x8000
ffffffe000201e58:	40f707b3          	sub	a5,a4,a5
ffffffe000201e5c:	00700713          	li	a4,7
ffffffe000201e60:	00078693          	mv	a3,a5
ffffffe000201e64:	00009517          	auipc	a0,0x9
ffffffe000201e68:	19c50513          	addi	a0,a0,412 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201e6c:	054000ef          	jal	ra,ffffffe000201ec0 <create_mapping>

    uint64_t _satp = ((((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12) | (uint64_t)0x8 << 60);
ffffffe000201e70:	00009717          	auipc	a4,0x9
ffffffe000201e74:	19070713          	addi	a4,a4,400 # ffffffe00020b000 <swapper_pg_dir>
ffffffe000201e78:	04100793          	li	a5,65
ffffffe000201e7c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201e80:	00f707b3          	add	a5,a4,a5
ffffffe000201e84:	00c7d713          	srli	a4,a5,0xc
ffffffe000201e88:	fff00793          	li	a5,-1
ffffffe000201e8c:	03f79793          	slli	a5,a5,0x3f
ffffffe000201e90:	00f767b3          	or	a5,a4,a5
ffffffe000201e94:	fef43423          	sd	a5,-24(s0)

    // set satp with swapper_pg_dir
    csr_write(satp, _satp);
ffffffe000201e98:	fe843783          	ld	a5,-24(s0)
ffffffe000201e9c:	fef43023          	sd	a5,-32(s0)
ffffffe000201ea0:	fe043783          	ld	a5,-32(s0)
ffffffe000201ea4:	18079073          	csrw	satp,a5
    // *_erodata = 0x0;
    // LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);

    // YOUR CODE HERE
    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000201ea8:	12000073          	sfence.vma
    return;
ffffffe000201eac:	00000013          	nop
}
ffffffe000201eb0:	03813083          	ld	ra,56(sp)
ffffffe000201eb4:	03013403          	ld	s0,48(sp)
ffffffe000201eb8:	04010113          	addi	sp,sp,64
ffffffe000201ebc:	00008067          	ret

ffffffe000201ec0 <create_mapping>:


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000201ec0:	f7010113          	addi	sp,sp,-144
ffffffe000201ec4:	08113423          	sd	ra,136(sp)
ffffffe000201ec8:	08813023          	sd	s0,128(sp)
ffffffe000201ecc:	09010413          	addi	s0,sp,144
ffffffe000201ed0:	faa43423          	sd	a0,-88(s0)
ffffffe000201ed4:	fab43023          	sd	a1,-96(s0)
ffffffe000201ed8:	f8c43c23          	sd	a2,-104(s0)
ffffffe000201edc:	f8d43823          	sd	a3,-112(s0)
ffffffe000201ee0:	f8e43423          	sd	a4,-120(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    // printk("Come into the create_mapping\n");
    uint64_t vlimit = va + sz;
ffffffe000201ee4:	fa043703          	ld	a4,-96(s0)
ffffffe000201ee8:	f9043783          	ld	a5,-112(s0)
ffffffe000201eec:	00f707b3          	add	a5,a4,a5
ffffffe000201ef0:	fcf43c23          	sd	a5,-40(s0)
    uint64_t *pgd, *pmd, *pte;
    pgd = pgtbl;
ffffffe000201ef4:	fa843783          	ld	a5,-88(s0)
ffffffe000201ef8:	fcf43823          	sd	a5,-48(s0)

    while(va < vlimit){
ffffffe000201efc:	19c0006f          	j	ffffffe000202098 <create_mapping+0x1d8>
        uint64_t pgd_entry = *(pgd + ((va >> 30) & 0x1ff));
ffffffe000201f00:	fa043783          	ld	a5,-96(s0)
ffffffe000201f04:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201f08:	1ff7f793          	andi	a5,a5,511
ffffffe000201f0c:	00379793          	slli	a5,a5,0x3
ffffffe000201f10:	fd043703          	ld	a4,-48(s0)
ffffffe000201f14:	00f707b3          	add	a5,a4,a5
ffffffe000201f18:	0007b783          	ld	a5,0(a5)
ffffffe000201f1c:	fef43423          	sd	a5,-24(s0)
        if (!(pgd_entry & PTE_V)) {
ffffffe000201f20:	fe843783          	ld	a5,-24(s0)
ffffffe000201f24:	0017f793          	andi	a5,a5,1
ffffffe000201f28:	06079063          	bnez	a5,ffffffe000201f88 <create_mapping+0xc8>
            uint64_t ppmd = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppmd是PMD页表的物理地址
ffffffe000201f2c:	a91fe0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe000201f30:	00050793          	mv	a5,a0
ffffffe000201f34:	00078713          	mv	a4,a5
ffffffe000201f38:	04100793          	li	a5,65
ffffffe000201f3c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201f40:	00f707b3          	add	a5,a4,a5
ffffffe000201f44:	fcf43423          	sd	a5,-56(s0)
            // LogBLUE("ppmd: 0x%llx", ppmd);
            *(pgd + ((va >> 30) & 0x1ff)) = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe000201f48:	fc843783          	ld	a5,-56(s0)
ffffffe000201f4c:	00c7d793          	srli	a5,a5,0xc
ffffffe000201f50:	00a79713          	slli	a4,a5,0xa
ffffffe000201f54:	fa043783          	ld	a5,-96(s0)
ffffffe000201f58:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201f5c:	1ff7f793          	andi	a5,a5,511
ffffffe000201f60:	00379793          	slli	a5,a5,0x3
ffffffe000201f64:	fd043683          	ld	a3,-48(s0)
ffffffe000201f68:	00f687b3          	add	a5,a3,a5
ffffffe000201f6c:	00176713          	ori	a4,a4,1
ffffffe000201f70:	00e7b023          	sd	a4,0(a5)
            pgd_entry = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe000201f74:	fc843783          	ld	a5,-56(s0)
ffffffe000201f78:	00c7d793          	srli	a5,a5,0xc
ffffffe000201f7c:	00a79793          	slli	a5,a5,0xa
ffffffe000201f80:	0017e793          	ori	a5,a5,1
ffffffe000201f84:	fef43423          	sd	a5,-24(s0)
        }
    
        pmd = (uint64_t*) (((pgd_entry >> 10) << 12) + PA2VA_OFFSET); // pmd此时是PMD页表的虚拟地址
ffffffe000201f88:	fe843783          	ld	a5,-24(s0)
ffffffe000201f8c:	00a7d793          	srli	a5,a5,0xa
ffffffe000201f90:	00c79713          	slli	a4,a5,0xc
ffffffe000201f94:	fbf00793          	li	a5,-65
ffffffe000201f98:	01f79793          	slli	a5,a5,0x1f
ffffffe000201f9c:	00f707b3          	add	a5,a4,a5
ffffffe000201fa0:	fcf43023          	sd	a5,-64(s0)
        uint64_t pmd_entry = *(pmd + ((va >> 21) & 0x1ff));
ffffffe000201fa4:	fa043783          	ld	a5,-96(s0)
ffffffe000201fa8:	0157d793          	srli	a5,a5,0x15
ffffffe000201fac:	1ff7f793          	andi	a5,a5,511
ffffffe000201fb0:	00379793          	slli	a5,a5,0x3
ffffffe000201fb4:	fc043703          	ld	a4,-64(s0)
ffffffe000201fb8:	00f707b3          	add	a5,a4,a5
ffffffe000201fbc:	0007b783          	ld	a5,0(a5)
ffffffe000201fc0:	fef43023          	sd	a5,-32(s0)
        if (!(pmd_entry & PTE_V)) {
ffffffe000201fc4:	fe043783          	ld	a5,-32(s0)
ffffffe000201fc8:	0017f793          	andi	a5,a5,1
ffffffe000201fcc:	06079063          	bnez	a5,ffffffe00020202c <create_mapping+0x16c>
            uint64_t ppte = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppte是PTE页表的物理地址
ffffffe000201fd0:	9edfe0ef          	jal	ra,ffffffe0002009bc <kalloc>
ffffffe000201fd4:	00050793          	mv	a5,a0
ffffffe000201fd8:	00078713          	mv	a4,a5
ffffffe000201fdc:	04100793          	li	a5,65
ffffffe000201fe0:	01f79793          	slli	a5,a5,0x1f
ffffffe000201fe4:	00f707b3          	add	a5,a4,a5
ffffffe000201fe8:	faf43c23          	sd	a5,-72(s0)
            // LogBLUE("ppte: 0x%llx", ppte);
            *(pmd + ((va >> 21) & 0x1ff)) = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000201fec:	fb843783          	ld	a5,-72(s0)
ffffffe000201ff0:	00c7d793          	srli	a5,a5,0xc
ffffffe000201ff4:	00a79713          	slli	a4,a5,0xa
ffffffe000201ff8:	fa043783          	ld	a5,-96(s0)
ffffffe000201ffc:	0157d793          	srli	a5,a5,0x15
ffffffe000202000:	1ff7f793          	andi	a5,a5,511
ffffffe000202004:	00379793          	slli	a5,a5,0x3
ffffffe000202008:	fc043683          	ld	a3,-64(s0)
ffffffe00020200c:	00f687b3          	add	a5,a3,a5
ffffffe000202010:	00176713          	ori	a4,a4,1
ffffffe000202014:	00e7b023          	sd	a4,0(a5)
            pmd_entry = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000202018:	fb843783          	ld	a5,-72(s0)
ffffffe00020201c:	00c7d793          	srli	a5,a5,0xc
ffffffe000202020:	00a79793          	slli	a5,a5,0xa
ffffffe000202024:	0017e793          	ori	a5,a5,1
ffffffe000202028:	fef43023          	sd	a5,-32(s0)
        }
        
        pte = (uint64_t*) (((pmd_entry >> 10) << 12) + PA2VA_OFFSET); // pte此时是PTE页表的虚拟地址
ffffffe00020202c:	fe043783          	ld	a5,-32(s0)
ffffffe000202030:	00a7d793          	srli	a5,a5,0xa
ffffffe000202034:	00c79713          	slli	a4,a5,0xc
ffffffe000202038:	fbf00793          	li	a5,-65
ffffffe00020203c:	01f79793          	slli	a5,a5,0x1f
ffffffe000202040:	00f707b3          	add	a5,a4,a5
ffffffe000202044:	faf43823          	sd	a5,-80(s0)
        *(pte + ((va >> 12) & 0x1ff)) = ((pa >> 12) << 10) | perm ;
ffffffe000202048:	f9843783          	ld	a5,-104(s0)
ffffffe00020204c:	00c7d793          	srli	a5,a5,0xc
ffffffe000202050:	00a79693          	slli	a3,a5,0xa
ffffffe000202054:	fa043783          	ld	a5,-96(s0)
ffffffe000202058:	00c7d793          	srli	a5,a5,0xc
ffffffe00020205c:	1ff7f793          	andi	a5,a5,511
ffffffe000202060:	00379793          	slli	a5,a5,0x3
ffffffe000202064:	fb043703          	ld	a4,-80(s0)
ffffffe000202068:	00f707b3          	add	a5,a4,a5
ffffffe00020206c:	f8843703          	ld	a4,-120(s0)
ffffffe000202070:	00e6e733          	or	a4,a3,a4
ffffffe000202074:	00e7b023          	sd	a4,0(a5)


        // if(va <= 0xffffffe000209000)LogBLUE("va: 0x%llx, pa: 0x%llx, perm: 0x%llx", va, pa, perm);
        va += PGSIZE;
ffffffe000202078:	fa043703          	ld	a4,-96(s0)
ffffffe00020207c:	000017b7          	lui	a5,0x1
ffffffe000202080:	00f707b3          	add	a5,a4,a5
ffffffe000202084:	faf43023          	sd	a5,-96(s0)
        pa += PGSIZE;
ffffffe000202088:	f9843703          	ld	a4,-104(s0)
ffffffe00020208c:	000017b7          	lui	a5,0x1
ffffffe000202090:	00f707b3          	add	a5,a4,a5
ffffffe000202094:	f8f43c23          	sd	a5,-104(s0)
    while(va < vlimit){
ffffffe000202098:	fa043703          	ld	a4,-96(s0)
ffffffe00020209c:	fd843783          	ld	a5,-40(s0)
ffffffe0002020a0:	e6f760e3          	bltu	a4,a5,ffffffe000201f00 <create_mapping+0x40>
    }
    LogBLUE("root: 0x%llx, [0x%llx, 0x%llx) -> [0x%llx, 0x%llx), perm: 0x%llx", pgtbl, pa, pa + sz, va, va + sz, perm);
ffffffe0002020a4:	f9843703          	ld	a4,-104(s0)
ffffffe0002020a8:	f9043783          	ld	a5,-112(s0)
ffffffe0002020ac:	00f706b3          	add	a3,a4,a5
ffffffe0002020b0:	fa043703          	ld	a4,-96(s0)
ffffffe0002020b4:	f9043783          	ld	a5,-112(s0)
ffffffe0002020b8:	00f707b3          	add	a5,a4,a5
ffffffe0002020bc:	f8843703          	ld	a4,-120(s0)
ffffffe0002020c0:	00e13423          	sd	a4,8(sp)
ffffffe0002020c4:	00f13023          	sd	a5,0(sp)
ffffffe0002020c8:	fa043883          	ld	a7,-96(s0)
ffffffe0002020cc:	00068813          	mv	a6,a3
ffffffe0002020d0:	f9843783          	ld	a5,-104(s0)
ffffffe0002020d4:	fa843703          	ld	a4,-88(s0)
ffffffe0002020d8:	00002697          	auipc	a3,0x2
ffffffe0002020dc:	55068693          	addi	a3,a3,1360 # ffffffe000204628 <__func__.0>
ffffffe0002020e0:	07100613          	li	a2,113
ffffffe0002020e4:	00002597          	auipc	a1,0x2
ffffffe0002020e8:	3ec58593          	addi	a1,a1,1004 # ffffffe0002044d0 <__func__.1+0x10>
ffffffe0002020ec:	00002517          	auipc	a0,0x2
ffffffe0002020f0:	4c450513          	addi	a0,a0,1220 # ffffffe0002045b0 <__func__.1+0xf0>
ffffffe0002020f4:	745000ef          	jal	ra,ffffffe000203038 <printk>
}
ffffffe0002020f8:	00000013          	nop
ffffffe0002020fc:	08813083          	ld	ra,136(sp)
ffffffe000202100:	08013403          	ld	s0,128(sp)
ffffffe000202104:	09010113          	addi	sp,sp,144
ffffffe000202108:	00008067          	ret

ffffffe00020210c <start_kernel>:
extern void test();

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

int start_kernel() {
ffffffe00020210c:	ff010113          	addi	sp,sp,-16
ffffffe000202110:	00113423          	sd	ra,8(sp)
ffffffe000202114:	00813023          	sd	s0,0(sp)
ffffffe000202118:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe00020211c:	00002517          	auipc	a0,0x2
ffffffe000202120:	51c50513          	addi	a0,a0,1308 # ffffffe000204638 <__func__.0+0x10>
ffffffe000202124:	715000ef          	jal	ra,ffffffe000203038 <printk>
    printk(" ZJU Operating System\n");
ffffffe000202128:	00002517          	auipc	a0,0x2
ffffffe00020212c:	51850513          	addi	a0,a0,1304 # ffffffe000204640 <__func__.0+0x18>
ffffffe000202130:	709000ef          	jal	ra,ffffffe000203038 <printk>
    schedule();
ffffffe000202134:	bedfe0ef          	jal	ra,ffffffe000200d20 <schedule>

    test();
ffffffe000202138:	01c000ef          	jal	ra,ffffffe000202154 <test>
    return 0;
ffffffe00020213c:	00000793          	li	a5,0
}
ffffffe000202140:	00078513          	mv	a0,a5
ffffffe000202144:	00813083          	ld	ra,8(sp)
ffffffe000202148:	00013403          	ld	s0,0(sp)
ffffffe00020214c:	01010113          	addi	sp,sp,16
ffffffe000202150:	00008067          	ret

ffffffe000202154 <test>:
#include "printk.h"

void test() {
ffffffe000202154:	fe010113          	addi	sp,sp,-32
ffffffe000202158:	00113c23          	sd	ra,24(sp)
ffffffe00020215c:	00813823          	sd	s0,16(sp)
ffffffe000202160:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe000202164:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000202168:	fec42783          	lw	a5,-20(s0)
ffffffe00020216c:	0017879b          	addiw	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe000202170:	fef42623          	sw	a5,-20(s0)
ffffffe000202174:	fec42783          	lw	a5,-20(s0)
ffffffe000202178:	00078713          	mv	a4,a5
ffffffe00020217c:	05f5e7b7          	lui	a5,0x5f5e
ffffffe000202180:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe000202184:	02f767bb          	remw	a5,a4,a5
ffffffe000202188:	0007879b          	sext.w	a5,a5
ffffffe00020218c:	fc079ee3          	bnez	a5,ffffffe000202168 <test+0x14>
            printk("kernel is running!\n");
ffffffe000202190:	00002517          	auipc	a0,0x2
ffffffe000202194:	4c850513          	addi	a0,a0,1224 # ffffffe000204658 <__func__.0+0x30>
ffffffe000202198:	6a1000ef          	jal	ra,ffffffe000203038 <printk>
            i = 0;
ffffffe00020219c:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe0002021a0:	fc9ff06f          	j	ffffffe000202168 <test+0x14>

ffffffe0002021a4 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe0002021a4:	fe010113          	addi	sp,sp,-32
ffffffe0002021a8:	00113c23          	sd	ra,24(sp)
ffffffe0002021ac:	00813823          	sd	s0,16(sp)
ffffffe0002021b0:	02010413          	addi	s0,sp,32
ffffffe0002021b4:	00050793          	mv	a5,a0
ffffffe0002021b8:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe0002021bc:	fec42783          	lw	a5,-20(s0)
ffffffe0002021c0:	0ff7f793          	zext.b	a5,a5
ffffffe0002021c4:	00078513          	mv	a0,a5
ffffffe0002021c8:	cb4ff0ef          	jal	ra,ffffffe00020167c <sbi_debug_console_write_byte>
    return (char)c;
ffffffe0002021cc:	fec42783          	lw	a5,-20(s0)
ffffffe0002021d0:	0ff7f793          	zext.b	a5,a5
ffffffe0002021d4:	0007879b          	sext.w	a5,a5
}
ffffffe0002021d8:	00078513          	mv	a0,a5
ffffffe0002021dc:	01813083          	ld	ra,24(sp)
ffffffe0002021e0:	01013403          	ld	s0,16(sp)
ffffffe0002021e4:	02010113          	addi	sp,sp,32
ffffffe0002021e8:	00008067          	ret

ffffffe0002021ec <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe0002021ec:	fe010113          	addi	sp,sp,-32
ffffffe0002021f0:	00813c23          	sd	s0,24(sp)
ffffffe0002021f4:	02010413          	addi	s0,sp,32
ffffffe0002021f8:	00050793          	mv	a5,a0
ffffffe0002021fc:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000202200:	fec42783          	lw	a5,-20(s0)
ffffffe000202204:	0007871b          	sext.w	a4,a5
ffffffe000202208:	02000793          	li	a5,32
ffffffe00020220c:	02f70263          	beq	a4,a5,ffffffe000202230 <isspace+0x44>
ffffffe000202210:	fec42783          	lw	a5,-20(s0)
ffffffe000202214:	0007871b          	sext.w	a4,a5
ffffffe000202218:	00800793          	li	a5,8
ffffffe00020221c:	00e7de63          	bge	a5,a4,ffffffe000202238 <isspace+0x4c>
ffffffe000202220:	fec42783          	lw	a5,-20(s0)
ffffffe000202224:	0007871b          	sext.w	a4,a5
ffffffe000202228:	00d00793          	li	a5,13
ffffffe00020222c:	00e7c663          	blt	a5,a4,ffffffe000202238 <isspace+0x4c>
ffffffe000202230:	00100793          	li	a5,1
ffffffe000202234:	0080006f          	j	ffffffe00020223c <isspace+0x50>
ffffffe000202238:	00000793          	li	a5,0
}
ffffffe00020223c:	00078513          	mv	a0,a5
ffffffe000202240:	01813403          	ld	s0,24(sp)
ffffffe000202244:	02010113          	addi	sp,sp,32
ffffffe000202248:	00008067          	ret

ffffffe00020224c <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe00020224c:	fb010113          	addi	sp,sp,-80
ffffffe000202250:	04113423          	sd	ra,72(sp)
ffffffe000202254:	04813023          	sd	s0,64(sp)
ffffffe000202258:	05010413          	addi	s0,sp,80
ffffffe00020225c:	fca43423          	sd	a0,-56(s0)
ffffffe000202260:	fcb43023          	sd	a1,-64(s0)
ffffffe000202264:	00060793          	mv	a5,a2
ffffffe000202268:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe00020226c:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000202270:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe000202274:	fc843783          	ld	a5,-56(s0)
ffffffe000202278:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe00020227c:	0100006f          	j	ffffffe00020228c <strtol+0x40>
        p++;
ffffffe000202280:	fd843783          	ld	a5,-40(s0)
ffffffe000202284:	00178793          	addi	a5,a5,1
ffffffe000202288:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe00020228c:	fd843783          	ld	a5,-40(s0)
ffffffe000202290:	0007c783          	lbu	a5,0(a5)
ffffffe000202294:	0007879b          	sext.w	a5,a5
ffffffe000202298:	00078513          	mv	a0,a5
ffffffe00020229c:	f51ff0ef          	jal	ra,ffffffe0002021ec <isspace>
ffffffe0002022a0:	00050793          	mv	a5,a0
ffffffe0002022a4:	fc079ee3          	bnez	a5,ffffffe000202280 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe0002022a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002022ac:	0007c783          	lbu	a5,0(a5)
ffffffe0002022b0:	00078713          	mv	a4,a5
ffffffe0002022b4:	02d00793          	li	a5,45
ffffffe0002022b8:	00f71e63          	bne	a4,a5,ffffffe0002022d4 <strtol+0x88>
        neg = true;
ffffffe0002022bc:	00100793          	li	a5,1
ffffffe0002022c0:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe0002022c4:	fd843783          	ld	a5,-40(s0)
ffffffe0002022c8:	00178793          	addi	a5,a5,1
ffffffe0002022cc:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002022d0:	0240006f          	j	ffffffe0002022f4 <strtol+0xa8>
    } else if (*p == '+') {
ffffffe0002022d4:	fd843783          	ld	a5,-40(s0)
ffffffe0002022d8:	0007c783          	lbu	a5,0(a5)
ffffffe0002022dc:	00078713          	mv	a4,a5
ffffffe0002022e0:	02b00793          	li	a5,43
ffffffe0002022e4:	00f71863          	bne	a4,a5,ffffffe0002022f4 <strtol+0xa8>
        p++;
ffffffe0002022e8:	fd843783          	ld	a5,-40(s0)
ffffffe0002022ec:	00178793          	addi	a5,a5,1
ffffffe0002022f0:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe0002022f4:	fbc42783          	lw	a5,-68(s0)
ffffffe0002022f8:	0007879b          	sext.w	a5,a5
ffffffe0002022fc:	06079c63          	bnez	a5,ffffffe000202374 <strtol+0x128>
        if (*p == '0') {
ffffffe000202300:	fd843783          	ld	a5,-40(s0)
ffffffe000202304:	0007c783          	lbu	a5,0(a5)
ffffffe000202308:	00078713          	mv	a4,a5
ffffffe00020230c:	03000793          	li	a5,48
ffffffe000202310:	04f71e63          	bne	a4,a5,ffffffe00020236c <strtol+0x120>
            p++;
ffffffe000202314:	fd843783          	ld	a5,-40(s0)
ffffffe000202318:	00178793          	addi	a5,a5,1
ffffffe00020231c:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000202320:	fd843783          	ld	a5,-40(s0)
ffffffe000202324:	0007c783          	lbu	a5,0(a5)
ffffffe000202328:	00078713          	mv	a4,a5
ffffffe00020232c:	07800793          	li	a5,120
ffffffe000202330:	00f70c63          	beq	a4,a5,ffffffe000202348 <strtol+0xfc>
ffffffe000202334:	fd843783          	ld	a5,-40(s0)
ffffffe000202338:	0007c783          	lbu	a5,0(a5)
ffffffe00020233c:	00078713          	mv	a4,a5
ffffffe000202340:	05800793          	li	a5,88
ffffffe000202344:	00f71e63          	bne	a4,a5,ffffffe000202360 <strtol+0x114>
                base = 16;
ffffffe000202348:	01000793          	li	a5,16
ffffffe00020234c:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000202350:	fd843783          	ld	a5,-40(s0)
ffffffe000202354:	00178793          	addi	a5,a5,1
ffffffe000202358:	fcf43c23          	sd	a5,-40(s0)
ffffffe00020235c:	0180006f          	j	ffffffe000202374 <strtol+0x128>
            } else {
                base = 8;
ffffffe000202360:	00800793          	li	a5,8
ffffffe000202364:	faf42e23          	sw	a5,-68(s0)
ffffffe000202368:	00c0006f          	j	ffffffe000202374 <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe00020236c:	00a00793          	li	a5,10
ffffffe000202370:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe000202374:	fd843783          	ld	a5,-40(s0)
ffffffe000202378:	0007c783          	lbu	a5,0(a5)
ffffffe00020237c:	00078713          	mv	a4,a5
ffffffe000202380:	02f00793          	li	a5,47
ffffffe000202384:	02e7f863          	bgeu	a5,a4,ffffffe0002023b4 <strtol+0x168>
ffffffe000202388:	fd843783          	ld	a5,-40(s0)
ffffffe00020238c:	0007c783          	lbu	a5,0(a5)
ffffffe000202390:	00078713          	mv	a4,a5
ffffffe000202394:	03900793          	li	a5,57
ffffffe000202398:	00e7ee63          	bltu	a5,a4,ffffffe0002023b4 <strtol+0x168>
            digit = *p - '0';
ffffffe00020239c:	fd843783          	ld	a5,-40(s0)
ffffffe0002023a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002023a4:	0007879b          	sext.w	a5,a5
ffffffe0002023a8:	fd07879b          	addiw	a5,a5,-48
ffffffe0002023ac:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002023b0:	0800006f          	j	ffffffe000202430 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe0002023b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002023b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002023bc:	00078713          	mv	a4,a5
ffffffe0002023c0:	06000793          	li	a5,96
ffffffe0002023c4:	02e7f863          	bgeu	a5,a4,ffffffe0002023f4 <strtol+0x1a8>
ffffffe0002023c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002023cc:	0007c783          	lbu	a5,0(a5)
ffffffe0002023d0:	00078713          	mv	a4,a5
ffffffe0002023d4:	07a00793          	li	a5,122
ffffffe0002023d8:	00e7ee63          	bltu	a5,a4,ffffffe0002023f4 <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe0002023dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002023e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002023e4:	0007879b          	sext.w	a5,a5
ffffffe0002023e8:	fa97879b          	addiw	a5,a5,-87
ffffffe0002023ec:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002023f0:	0400006f          	j	ffffffe000202430 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe0002023f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002023f8:	0007c783          	lbu	a5,0(a5)
ffffffe0002023fc:	00078713          	mv	a4,a5
ffffffe000202400:	04000793          	li	a5,64
ffffffe000202404:	06e7f863          	bgeu	a5,a4,ffffffe000202474 <strtol+0x228>
ffffffe000202408:	fd843783          	ld	a5,-40(s0)
ffffffe00020240c:	0007c783          	lbu	a5,0(a5)
ffffffe000202410:	00078713          	mv	a4,a5
ffffffe000202414:	05a00793          	li	a5,90
ffffffe000202418:	04e7ee63          	bltu	a5,a4,ffffffe000202474 <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe00020241c:	fd843783          	ld	a5,-40(s0)
ffffffe000202420:	0007c783          	lbu	a5,0(a5)
ffffffe000202424:	0007879b          	sext.w	a5,a5
ffffffe000202428:	fc97879b          	addiw	a5,a5,-55
ffffffe00020242c:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000202430:	fd442783          	lw	a5,-44(s0)
ffffffe000202434:	00078713          	mv	a4,a5
ffffffe000202438:	fbc42783          	lw	a5,-68(s0)
ffffffe00020243c:	0007071b          	sext.w	a4,a4
ffffffe000202440:	0007879b          	sext.w	a5,a5
ffffffe000202444:	02f75663          	bge	a4,a5,ffffffe000202470 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe000202448:	fbc42703          	lw	a4,-68(s0)
ffffffe00020244c:	fe843783          	ld	a5,-24(s0)
ffffffe000202450:	02f70733          	mul	a4,a4,a5
ffffffe000202454:	fd442783          	lw	a5,-44(s0)
ffffffe000202458:	00f707b3          	add	a5,a4,a5
ffffffe00020245c:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000202460:	fd843783          	ld	a5,-40(s0)
ffffffe000202464:	00178793          	addi	a5,a5,1
ffffffe000202468:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe00020246c:	f09ff06f          	j	ffffffe000202374 <strtol+0x128>
            break;
ffffffe000202470:	00000013          	nop
    }

    if (endptr) {
ffffffe000202474:	fc043783          	ld	a5,-64(s0)
ffffffe000202478:	00078863          	beqz	a5,ffffffe000202488 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe00020247c:	fc043783          	ld	a5,-64(s0)
ffffffe000202480:	fd843703          	ld	a4,-40(s0)
ffffffe000202484:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000202488:	fe744783          	lbu	a5,-25(s0)
ffffffe00020248c:	0ff7f793          	zext.b	a5,a5
ffffffe000202490:	00078863          	beqz	a5,ffffffe0002024a0 <strtol+0x254>
ffffffe000202494:	fe843783          	ld	a5,-24(s0)
ffffffe000202498:	40f007b3          	neg	a5,a5
ffffffe00020249c:	0080006f          	j	ffffffe0002024a4 <strtol+0x258>
ffffffe0002024a0:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002024a4:	00078513          	mv	a0,a5
ffffffe0002024a8:	04813083          	ld	ra,72(sp)
ffffffe0002024ac:	04013403          	ld	s0,64(sp)
ffffffe0002024b0:	05010113          	addi	sp,sp,80
ffffffe0002024b4:	00008067          	ret

ffffffe0002024b8 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe0002024b8:	fd010113          	addi	sp,sp,-48
ffffffe0002024bc:	02113423          	sd	ra,40(sp)
ffffffe0002024c0:	02813023          	sd	s0,32(sp)
ffffffe0002024c4:	03010413          	addi	s0,sp,48
ffffffe0002024c8:	fca43c23          	sd	a0,-40(s0)
ffffffe0002024cc:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe0002024d0:	fd043783          	ld	a5,-48(s0)
ffffffe0002024d4:	00079863          	bnez	a5,ffffffe0002024e4 <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe0002024d8:	00002797          	auipc	a5,0x2
ffffffe0002024dc:	19878793          	addi	a5,a5,408 # ffffffe000204670 <__func__.0+0x48>
ffffffe0002024e0:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe0002024e4:	fd043783          	ld	a5,-48(s0)
ffffffe0002024e8:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe0002024ec:	0240006f          	j	ffffffe000202510 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe0002024f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002024f4:	00178713          	addi	a4,a5,1
ffffffe0002024f8:	fee43423          	sd	a4,-24(s0)
ffffffe0002024fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202500:	0007871b          	sext.w	a4,a5
ffffffe000202504:	fd843783          	ld	a5,-40(s0)
ffffffe000202508:	00070513          	mv	a0,a4
ffffffe00020250c:	000780e7          	jalr	a5
    while (*p) {
ffffffe000202510:	fe843783          	ld	a5,-24(s0)
ffffffe000202514:	0007c783          	lbu	a5,0(a5)
ffffffe000202518:	fc079ce3          	bnez	a5,ffffffe0002024f0 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe00020251c:	fe843703          	ld	a4,-24(s0)
ffffffe000202520:	fd043783          	ld	a5,-48(s0)
ffffffe000202524:	40f707b3          	sub	a5,a4,a5
ffffffe000202528:	0007879b          	sext.w	a5,a5
}
ffffffe00020252c:	00078513          	mv	a0,a5
ffffffe000202530:	02813083          	ld	ra,40(sp)
ffffffe000202534:	02013403          	ld	s0,32(sp)
ffffffe000202538:	03010113          	addi	sp,sp,48
ffffffe00020253c:	00008067          	ret

ffffffe000202540 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000202540:	f9010113          	addi	sp,sp,-112
ffffffe000202544:	06113423          	sd	ra,104(sp)
ffffffe000202548:	06813023          	sd	s0,96(sp)
ffffffe00020254c:	07010413          	addi	s0,sp,112
ffffffe000202550:	faa43423          	sd	a0,-88(s0)
ffffffe000202554:	fab43023          	sd	a1,-96(s0)
ffffffe000202558:	00060793          	mv	a5,a2
ffffffe00020255c:	f8d43823          	sd	a3,-112(s0)
ffffffe000202560:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000202564:	f9f44783          	lbu	a5,-97(s0)
ffffffe000202568:	0ff7f793          	zext.b	a5,a5
ffffffe00020256c:	02078663          	beqz	a5,ffffffe000202598 <print_dec_int+0x58>
ffffffe000202570:	fa043703          	ld	a4,-96(s0)
ffffffe000202574:	fff00793          	li	a5,-1
ffffffe000202578:	03f79793          	slli	a5,a5,0x3f
ffffffe00020257c:	00f71e63          	bne	a4,a5,ffffffe000202598 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000202580:	00002597          	auipc	a1,0x2
ffffffe000202584:	0f858593          	addi	a1,a1,248 # ffffffe000204678 <__func__.0+0x50>
ffffffe000202588:	fa843503          	ld	a0,-88(s0)
ffffffe00020258c:	f2dff0ef          	jal	ra,ffffffe0002024b8 <puts_wo_nl>
ffffffe000202590:	00050793          	mv	a5,a0
ffffffe000202594:	2a00006f          	j	ffffffe000202834 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000202598:	f9043783          	ld	a5,-112(s0)
ffffffe00020259c:	00c7a783          	lw	a5,12(a5)
ffffffe0002025a0:	00079a63          	bnez	a5,ffffffe0002025b4 <print_dec_int+0x74>
ffffffe0002025a4:	fa043783          	ld	a5,-96(s0)
ffffffe0002025a8:	00079663          	bnez	a5,ffffffe0002025b4 <print_dec_int+0x74>
        return 0;
ffffffe0002025ac:	00000793          	li	a5,0
ffffffe0002025b0:	2840006f          	j	ffffffe000202834 <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe0002025b4:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe0002025b8:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002025bc:	0ff7f793          	zext.b	a5,a5
ffffffe0002025c0:	02078063          	beqz	a5,ffffffe0002025e0 <print_dec_int+0xa0>
ffffffe0002025c4:	fa043783          	ld	a5,-96(s0)
ffffffe0002025c8:	0007dc63          	bgez	a5,ffffffe0002025e0 <print_dec_int+0xa0>
        neg = true;
ffffffe0002025cc:	00100793          	li	a5,1
ffffffe0002025d0:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe0002025d4:	fa043783          	ld	a5,-96(s0)
ffffffe0002025d8:	40f007b3          	neg	a5,a5
ffffffe0002025dc:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe0002025e0:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe0002025e4:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002025e8:	0ff7f793          	zext.b	a5,a5
ffffffe0002025ec:	02078863          	beqz	a5,ffffffe00020261c <print_dec_int+0xdc>
ffffffe0002025f0:	fef44783          	lbu	a5,-17(s0)
ffffffe0002025f4:	0ff7f793          	zext.b	a5,a5
ffffffe0002025f8:	00079e63          	bnez	a5,ffffffe000202614 <print_dec_int+0xd4>
ffffffe0002025fc:	f9043783          	ld	a5,-112(s0)
ffffffe000202600:	0057c783          	lbu	a5,5(a5)
ffffffe000202604:	00079863          	bnez	a5,ffffffe000202614 <print_dec_int+0xd4>
ffffffe000202608:	f9043783          	ld	a5,-112(s0)
ffffffe00020260c:	0047c783          	lbu	a5,4(a5)
ffffffe000202610:	00078663          	beqz	a5,ffffffe00020261c <print_dec_int+0xdc>
ffffffe000202614:	00100793          	li	a5,1
ffffffe000202618:	0080006f          	j	ffffffe000202620 <print_dec_int+0xe0>
ffffffe00020261c:	00000793          	li	a5,0
ffffffe000202620:	fcf40ba3          	sb	a5,-41(s0)
ffffffe000202624:	fd744783          	lbu	a5,-41(s0)
ffffffe000202628:	0017f793          	andi	a5,a5,1
ffffffe00020262c:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000202630:	fa043703          	ld	a4,-96(s0)
ffffffe000202634:	00a00793          	li	a5,10
ffffffe000202638:	02f777b3          	remu	a5,a4,a5
ffffffe00020263c:	0ff7f713          	zext.b	a4,a5
ffffffe000202640:	fe842783          	lw	a5,-24(s0)
ffffffe000202644:	0017869b          	addiw	a3,a5,1
ffffffe000202648:	fed42423          	sw	a3,-24(s0)
ffffffe00020264c:	0307071b          	addiw	a4,a4,48
ffffffe000202650:	0ff77713          	zext.b	a4,a4
ffffffe000202654:	ff078793          	addi	a5,a5,-16
ffffffe000202658:	008787b3          	add	a5,a5,s0
ffffffe00020265c:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000202660:	fa043703          	ld	a4,-96(s0)
ffffffe000202664:	00a00793          	li	a5,10
ffffffe000202668:	02f757b3          	divu	a5,a4,a5
ffffffe00020266c:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000202670:	fa043783          	ld	a5,-96(s0)
ffffffe000202674:	fa079ee3          	bnez	a5,ffffffe000202630 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000202678:	f9043783          	ld	a5,-112(s0)
ffffffe00020267c:	00c7a783          	lw	a5,12(a5)
ffffffe000202680:	00078713          	mv	a4,a5
ffffffe000202684:	fff00793          	li	a5,-1
ffffffe000202688:	02f71063          	bne	a4,a5,ffffffe0002026a8 <print_dec_int+0x168>
ffffffe00020268c:	f9043783          	ld	a5,-112(s0)
ffffffe000202690:	0037c783          	lbu	a5,3(a5)
ffffffe000202694:	00078a63          	beqz	a5,ffffffe0002026a8 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000202698:	f9043783          	ld	a5,-112(s0)
ffffffe00020269c:	0087a703          	lw	a4,8(a5)
ffffffe0002026a0:	f9043783          	ld	a5,-112(s0)
ffffffe0002026a4:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe0002026a8:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe0002026ac:	f9043783          	ld	a5,-112(s0)
ffffffe0002026b0:	0087a703          	lw	a4,8(a5)
ffffffe0002026b4:	fe842783          	lw	a5,-24(s0)
ffffffe0002026b8:	fcf42823          	sw	a5,-48(s0)
ffffffe0002026bc:	f9043783          	ld	a5,-112(s0)
ffffffe0002026c0:	00c7a783          	lw	a5,12(a5)
ffffffe0002026c4:	fcf42623          	sw	a5,-52(s0)
ffffffe0002026c8:	fd042783          	lw	a5,-48(s0)
ffffffe0002026cc:	00078593          	mv	a1,a5
ffffffe0002026d0:	fcc42783          	lw	a5,-52(s0)
ffffffe0002026d4:	00078613          	mv	a2,a5
ffffffe0002026d8:	0006069b          	sext.w	a3,a2
ffffffe0002026dc:	0005879b          	sext.w	a5,a1
ffffffe0002026e0:	00f6d463          	bge	a3,a5,ffffffe0002026e8 <print_dec_int+0x1a8>
ffffffe0002026e4:	00058613          	mv	a2,a1
ffffffe0002026e8:	0006079b          	sext.w	a5,a2
ffffffe0002026ec:	40f707bb          	subw	a5,a4,a5
ffffffe0002026f0:	0007871b          	sext.w	a4,a5
ffffffe0002026f4:	fd744783          	lbu	a5,-41(s0)
ffffffe0002026f8:	0007879b          	sext.w	a5,a5
ffffffe0002026fc:	40f707bb          	subw	a5,a4,a5
ffffffe000202700:	fef42023          	sw	a5,-32(s0)
ffffffe000202704:	0280006f          	j	ffffffe00020272c <print_dec_int+0x1ec>
        putch(' ');
ffffffe000202708:	fa843783          	ld	a5,-88(s0)
ffffffe00020270c:	02000513          	li	a0,32
ffffffe000202710:	000780e7          	jalr	a5
        ++written;
ffffffe000202714:	fe442783          	lw	a5,-28(s0)
ffffffe000202718:	0017879b          	addiw	a5,a5,1
ffffffe00020271c:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000202720:	fe042783          	lw	a5,-32(s0)
ffffffe000202724:	fff7879b          	addiw	a5,a5,-1
ffffffe000202728:	fef42023          	sw	a5,-32(s0)
ffffffe00020272c:	fe042783          	lw	a5,-32(s0)
ffffffe000202730:	0007879b          	sext.w	a5,a5
ffffffe000202734:	fcf04ae3          	bgtz	a5,ffffffe000202708 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000202738:	fd744783          	lbu	a5,-41(s0)
ffffffe00020273c:	0ff7f793          	zext.b	a5,a5
ffffffe000202740:	04078463          	beqz	a5,ffffffe000202788 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000202744:	fef44783          	lbu	a5,-17(s0)
ffffffe000202748:	0ff7f793          	zext.b	a5,a5
ffffffe00020274c:	00078663          	beqz	a5,ffffffe000202758 <print_dec_int+0x218>
ffffffe000202750:	02d00793          	li	a5,45
ffffffe000202754:	01c0006f          	j	ffffffe000202770 <print_dec_int+0x230>
ffffffe000202758:	f9043783          	ld	a5,-112(s0)
ffffffe00020275c:	0057c783          	lbu	a5,5(a5)
ffffffe000202760:	00078663          	beqz	a5,ffffffe00020276c <print_dec_int+0x22c>
ffffffe000202764:	02b00793          	li	a5,43
ffffffe000202768:	0080006f          	j	ffffffe000202770 <print_dec_int+0x230>
ffffffe00020276c:	02000793          	li	a5,32
ffffffe000202770:	fa843703          	ld	a4,-88(s0)
ffffffe000202774:	00078513          	mv	a0,a5
ffffffe000202778:	000700e7          	jalr	a4
        ++written;
ffffffe00020277c:	fe442783          	lw	a5,-28(s0)
ffffffe000202780:	0017879b          	addiw	a5,a5,1
ffffffe000202784:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000202788:	fe842783          	lw	a5,-24(s0)
ffffffe00020278c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000202790:	0280006f          	j	ffffffe0002027b8 <print_dec_int+0x278>
        putch('0');
ffffffe000202794:	fa843783          	ld	a5,-88(s0)
ffffffe000202798:	03000513          	li	a0,48
ffffffe00020279c:	000780e7          	jalr	a5
        ++written;
ffffffe0002027a0:	fe442783          	lw	a5,-28(s0)
ffffffe0002027a4:	0017879b          	addiw	a5,a5,1
ffffffe0002027a8:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe0002027ac:	fdc42783          	lw	a5,-36(s0)
ffffffe0002027b0:	0017879b          	addiw	a5,a5,1
ffffffe0002027b4:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002027b8:	f9043783          	ld	a5,-112(s0)
ffffffe0002027bc:	00c7a703          	lw	a4,12(a5)
ffffffe0002027c0:	fd744783          	lbu	a5,-41(s0)
ffffffe0002027c4:	0007879b          	sext.w	a5,a5
ffffffe0002027c8:	40f707bb          	subw	a5,a4,a5
ffffffe0002027cc:	0007871b          	sext.w	a4,a5
ffffffe0002027d0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002027d4:	0007879b          	sext.w	a5,a5
ffffffe0002027d8:	fae7cee3          	blt	a5,a4,ffffffe000202794 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe0002027dc:	fe842783          	lw	a5,-24(s0)
ffffffe0002027e0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002027e4:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002027e8:	03c0006f          	j	ffffffe000202824 <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe0002027ec:	fd842783          	lw	a5,-40(s0)
ffffffe0002027f0:	ff078793          	addi	a5,a5,-16
ffffffe0002027f4:	008787b3          	add	a5,a5,s0
ffffffe0002027f8:	fc87c783          	lbu	a5,-56(a5)
ffffffe0002027fc:	0007871b          	sext.w	a4,a5
ffffffe000202800:	fa843783          	ld	a5,-88(s0)
ffffffe000202804:	00070513          	mv	a0,a4
ffffffe000202808:	000780e7          	jalr	a5
        ++written;
ffffffe00020280c:	fe442783          	lw	a5,-28(s0)
ffffffe000202810:	0017879b          	addiw	a5,a5,1
ffffffe000202814:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000202818:	fd842783          	lw	a5,-40(s0)
ffffffe00020281c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202820:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202824:	fd842783          	lw	a5,-40(s0)
ffffffe000202828:	0007879b          	sext.w	a5,a5
ffffffe00020282c:	fc07d0e3          	bgez	a5,ffffffe0002027ec <print_dec_int+0x2ac>
    }

    return written;
ffffffe000202830:	fe442783          	lw	a5,-28(s0)
}
ffffffe000202834:	00078513          	mv	a0,a5
ffffffe000202838:	06813083          	ld	ra,104(sp)
ffffffe00020283c:	06013403          	ld	s0,96(sp)
ffffffe000202840:	07010113          	addi	sp,sp,112
ffffffe000202844:	00008067          	ret

ffffffe000202848 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000202848:	f4010113          	addi	sp,sp,-192
ffffffe00020284c:	0a113c23          	sd	ra,184(sp)
ffffffe000202850:	0a813823          	sd	s0,176(sp)
ffffffe000202854:	0c010413          	addi	s0,sp,192
ffffffe000202858:	f4a43c23          	sd	a0,-168(s0)
ffffffe00020285c:	f4b43823          	sd	a1,-176(s0)
ffffffe000202860:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000202864:	f8043023          	sd	zero,-128(s0)
ffffffe000202868:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe00020286c:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000202870:	7a40006f          	j	ffffffe000203014 <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000202874:	f8044783          	lbu	a5,-128(s0)
ffffffe000202878:	72078e63          	beqz	a5,ffffffe000202fb4 <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe00020287c:	f5043783          	ld	a5,-176(s0)
ffffffe000202880:	0007c783          	lbu	a5,0(a5)
ffffffe000202884:	00078713          	mv	a4,a5
ffffffe000202888:	02300793          	li	a5,35
ffffffe00020288c:	00f71863          	bne	a4,a5,ffffffe00020289c <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000202890:	00100793          	li	a5,1
ffffffe000202894:	f8f40123          	sb	a5,-126(s0)
ffffffe000202898:	7700006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe00020289c:	f5043783          	ld	a5,-176(s0)
ffffffe0002028a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002028a4:	00078713          	mv	a4,a5
ffffffe0002028a8:	03000793          	li	a5,48
ffffffe0002028ac:	00f71863          	bne	a4,a5,ffffffe0002028bc <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe0002028b0:	00100793          	li	a5,1
ffffffe0002028b4:	f8f401a3          	sb	a5,-125(s0)
ffffffe0002028b8:	7500006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe0002028bc:	f5043783          	ld	a5,-176(s0)
ffffffe0002028c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002028c4:	00078713          	mv	a4,a5
ffffffe0002028c8:	06c00793          	li	a5,108
ffffffe0002028cc:	04f70063          	beq	a4,a5,ffffffe00020290c <vprintfmt+0xc4>
ffffffe0002028d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002028d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002028d8:	00078713          	mv	a4,a5
ffffffe0002028dc:	07a00793          	li	a5,122
ffffffe0002028e0:	02f70663          	beq	a4,a5,ffffffe00020290c <vprintfmt+0xc4>
ffffffe0002028e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002028e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002028ec:	00078713          	mv	a4,a5
ffffffe0002028f0:	07400793          	li	a5,116
ffffffe0002028f4:	00f70c63          	beq	a4,a5,ffffffe00020290c <vprintfmt+0xc4>
ffffffe0002028f8:	f5043783          	ld	a5,-176(s0)
ffffffe0002028fc:	0007c783          	lbu	a5,0(a5)
ffffffe000202900:	00078713          	mv	a4,a5
ffffffe000202904:	06a00793          	li	a5,106
ffffffe000202908:	00f71863          	bne	a4,a5,ffffffe000202918 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe00020290c:	00100793          	li	a5,1
ffffffe000202910:	f8f400a3          	sb	a5,-127(s0)
ffffffe000202914:	6f40006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000202918:	f5043783          	ld	a5,-176(s0)
ffffffe00020291c:	0007c783          	lbu	a5,0(a5)
ffffffe000202920:	00078713          	mv	a4,a5
ffffffe000202924:	02b00793          	li	a5,43
ffffffe000202928:	00f71863          	bne	a4,a5,ffffffe000202938 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe00020292c:	00100793          	li	a5,1
ffffffe000202930:	f8f402a3          	sb	a5,-123(s0)
ffffffe000202934:	6d40006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000202938:	f5043783          	ld	a5,-176(s0)
ffffffe00020293c:	0007c783          	lbu	a5,0(a5)
ffffffe000202940:	00078713          	mv	a4,a5
ffffffe000202944:	02000793          	li	a5,32
ffffffe000202948:	00f71863          	bne	a4,a5,ffffffe000202958 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe00020294c:	00100793          	li	a5,1
ffffffe000202950:	f8f40223          	sb	a5,-124(s0)
ffffffe000202954:	6b40006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000202958:	f5043783          	ld	a5,-176(s0)
ffffffe00020295c:	0007c783          	lbu	a5,0(a5)
ffffffe000202960:	00078713          	mv	a4,a5
ffffffe000202964:	02a00793          	li	a5,42
ffffffe000202968:	00f71e63          	bne	a4,a5,ffffffe000202984 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe00020296c:	f4843783          	ld	a5,-184(s0)
ffffffe000202970:	00878713          	addi	a4,a5,8
ffffffe000202974:	f4e43423          	sd	a4,-184(s0)
ffffffe000202978:	0007a783          	lw	a5,0(a5)
ffffffe00020297c:	f8f42423          	sw	a5,-120(s0)
ffffffe000202980:	6880006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000202984:	f5043783          	ld	a5,-176(s0)
ffffffe000202988:	0007c783          	lbu	a5,0(a5)
ffffffe00020298c:	00078713          	mv	a4,a5
ffffffe000202990:	03000793          	li	a5,48
ffffffe000202994:	04e7f663          	bgeu	a5,a4,ffffffe0002029e0 <vprintfmt+0x198>
ffffffe000202998:	f5043783          	ld	a5,-176(s0)
ffffffe00020299c:	0007c783          	lbu	a5,0(a5)
ffffffe0002029a0:	00078713          	mv	a4,a5
ffffffe0002029a4:	03900793          	li	a5,57
ffffffe0002029a8:	02e7ec63          	bltu	a5,a4,ffffffe0002029e0 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe0002029ac:	f5043783          	ld	a5,-176(s0)
ffffffe0002029b0:	f5040713          	addi	a4,s0,-176
ffffffe0002029b4:	00a00613          	li	a2,10
ffffffe0002029b8:	00070593          	mv	a1,a4
ffffffe0002029bc:	00078513          	mv	a0,a5
ffffffe0002029c0:	88dff0ef          	jal	ra,ffffffe00020224c <strtol>
ffffffe0002029c4:	00050793          	mv	a5,a0
ffffffe0002029c8:	0007879b          	sext.w	a5,a5
ffffffe0002029cc:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe0002029d0:	f5043783          	ld	a5,-176(s0)
ffffffe0002029d4:	fff78793          	addi	a5,a5,-1
ffffffe0002029d8:	f4f43823          	sd	a5,-176(s0)
ffffffe0002029dc:	62c0006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe0002029e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002029e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002029e8:	00078713          	mv	a4,a5
ffffffe0002029ec:	02e00793          	li	a5,46
ffffffe0002029f0:	06f71863          	bne	a4,a5,ffffffe000202a60 <vprintfmt+0x218>
                fmt++;
ffffffe0002029f4:	f5043783          	ld	a5,-176(s0)
ffffffe0002029f8:	00178793          	addi	a5,a5,1
ffffffe0002029fc:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000202a00:	f5043783          	ld	a5,-176(s0)
ffffffe000202a04:	0007c783          	lbu	a5,0(a5)
ffffffe000202a08:	00078713          	mv	a4,a5
ffffffe000202a0c:	02a00793          	li	a5,42
ffffffe000202a10:	00f71e63          	bne	a4,a5,ffffffe000202a2c <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe000202a14:	f4843783          	ld	a5,-184(s0)
ffffffe000202a18:	00878713          	addi	a4,a5,8
ffffffe000202a1c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202a20:	0007a783          	lw	a5,0(a5)
ffffffe000202a24:	f8f42623          	sw	a5,-116(s0)
ffffffe000202a28:	5e00006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000202a2c:	f5043783          	ld	a5,-176(s0)
ffffffe000202a30:	f5040713          	addi	a4,s0,-176
ffffffe000202a34:	00a00613          	li	a2,10
ffffffe000202a38:	00070593          	mv	a1,a4
ffffffe000202a3c:	00078513          	mv	a0,a5
ffffffe000202a40:	80dff0ef          	jal	ra,ffffffe00020224c <strtol>
ffffffe000202a44:	00050793          	mv	a5,a0
ffffffe000202a48:	0007879b          	sext.w	a5,a5
ffffffe000202a4c:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000202a50:	f5043783          	ld	a5,-176(s0)
ffffffe000202a54:	fff78793          	addi	a5,a5,-1
ffffffe000202a58:	f4f43823          	sd	a5,-176(s0)
ffffffe000202a5c:	5ac0006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202a60:	f5043783          	ld	a5,-176(s0)
ffffffe000202a64:	0007c783          	lbu	a5,0(a5)
ffffffe000202a68:	00078713          	mv	a4,a5
ffffffe000202a6c:	07800793          	li	a5,120
ffffffe000202a70:	02f70663          	beq	a4,a5,ffffffe000202a9c <vprintfmt+0x254>
ffffffe000202a74:	f5043783          	ld	a5,-176(s0)
ffffffe000202a78:	0007c783          	lbu	a5,0(a5)
ffffffe000202a7c:	00078713          	mv	a4,a5
ffffffe000202a80:	05800793          	li	a5,88
ffffffe000202a84:	00f70c63          	beq	a4,a5,ffffffe000202a9c <vprintfmt+0x254>
ffffffe000202a88:	f5043783          	ld	a5,-176(s0)
ffffffe000202a8c:	0007c783          	lbu	a5,0(a5)
ffffffe000202a90:	00078713          	mv	a4,a5
ffffffe000202a94:	07000793          	li	a5,112
ffffffe000202a98:	30f71263          	bne	a4,a5,ffffffe000202d9c <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000202a9c:	f5043783          	ld	a5,-176(s0)
ffffffe000202aa0:	0007c783          	lbu	a5,0(a5)
ffffffe000202aa4:	00078713          	mv	a4,a5
ffffffe000202aa8:	07000793          	li	a5,112
ffffffe000202aac:	00f70663          	beq	a4,a5,ffffffe000202ab8 <vprintfmt+0x270>
ffffffe000202ab0:	f8144783          	lbu	a5,-127(s0)
ffffffe000202ab4:	00078663          	beqz	a5,ffffffe000202ac0 <vprintfmt+0x278>
ffffffe000202ab8:	00100793          	li	a5,1
ffffffe000202abc:	0080006f          	j	ffffffe000202ac4 <vprintfmt+0x27c>
ffffffe000202ac0:	00000793          	li	a5,0
ffffffe000202ac4:	faf403a3          	sb	a5,-89(s0)
ffffffe000202ac8:	fa744783          	lbu	a5,-89(s0)
ffffffe000202acc:	0017f793          	andi	a5,a5,1
ffffffe000202ad0:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000202ad4:	fa744783          	lbu	a5,-89(s0)
ffffffe000202ad8:	0ff7f793          	zext.b	a5,a5
ffffffe000202adc:	00078c63          	beqz	a5,ffffffe000202af4 <vprintfmt+0x2ac>
ffffffe000202ae0:	f4843783          	ld	a5,-184(s0)
ffffffe000202ae4:	00878713          	addi	a4,a5,8
ffffffe000202ae8:	f4e43423          	sd	a4,-184(s0)
ffffffe000202aec:	0007b783          	ld	a5,0(a5)
ffffffe000202af0:	01c0006f          	j	ffffffe000202b0c <vprintfmt+0x2c4>
ffffffe000202af4:	f4843783          	ld	a5,-184(s0)
ffffffe000202af8:	00878713          	addi	a4,a5,8
ffffffe000202afc:	f4e43423          	sd	a4,-184(s0)
ffffffe000202b00:	0007a783          	lw	a5,0(a5)
ffffffe000202b04:	02079793          	slli	a5,a5,0x20
ffffffe000202b08:	0207d793          	srli	a5,a5,0x20
ffffffe000202b0c:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000202b10:	f8c42783          	lw	a5,-116(s0)
ffffffe000202b14:	02079463          	bnez	a5,ffffffe000202b3c <vprintfmt+0x2f4>
ffffffe000202b18:	fe043783          	ld	a5,-32(s0)
ffffffe000202b1c:	02079063          	bnez	a5,ffffffe000202b3c <vprintfmt+0x2f4>
ffffffe000202b20:	f5043783          	ld	a5,-176(s0)
ffffffe000202b24:	0007c783          	lbu	a5,0(a5)
ffffffe000202b28:	00078713          	mv	a4,a5
ffffffe000202b2c:	07000793          	li	a5,112
ffffffe000202b30:	00f70663          	beq	a4,a5,ffffffe000202b3c <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe000202b34:	f8040023          	sb	zero,-128(s0)
ffffffe000202b38:	4d00006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000202b3c:	f5043783          	ld	a5,-176(s0)
ffffffe000202b40:	0007c783          	lbu	a5,0(a5)
ffffffe000202b44:	00078713          	mv	a4,a5
ffffffe000202b48:	07000793          	li	a5,112
ffffffe000202b4c:	00f70a63          	beq	a4,a5,ffffffe000202b60 <vprintfmt+0x318>
ffffffe000202b50:	f8244783          	lbu	a5,-126(s0)
ffffffe000202b54:	00078a63          	beqz	a5,ffffffe000202b68 <vprintfmt+0x320>
ffffffe000202b58:	fe043783          	ld	a5,-32(s0)
ffffffe000202b5c:	00078663          	beqz	a5,ffffffe000202b68 <vprintfmt+0x320>
ffffffe000202b60:	00100793          	li	a5,1
ffffffe000202b64:	0080006f          	j	ffffffe000202b6c <vprintfmt+0x324>
ffffffe000202b68:	00000793          	li	a5,0
ffffffe000202b6c:	faf40323          	sb	a5,-90(s0)
ffffffe000202b70:	fa644783          	lbu	a5,-90(s0)
ffffffe000202b74:	0017f793          	andi	a5,a5,1
ffffffe000202b78:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000202b7c:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000202b80:	f5043783          	ld	a5,-176(s0)
ffffffe000202b84:	0007c783          	lbu	a5,0(a5)
ffffffe000202b88:	00078713          	mv	a4,a5
ffffffe000202b8c:	05800793          	li	a5,88
ffffffe000202b90:	00f71863          	bne	a4,a5,ffffffe000202ba0 <vprintfmt+0x358>
ffffffe000202b94:	00002797          	auipc	a5,0x2
ffffffe000202b98:	afc78793          	addi	a5,a5,-1284 # ffffffe000204690 <upperxdigits.1>
ffffffe000202b9c:	00c0006f          	j	ffffffe000202ba8 <vprintfmt+0x360>
ffffffe000202ba0:	00002797          	auipc	a5,0x2
ffffffe000202ba4:	b0878793          	addi	a5,a5,-1272 # ffffffe0002046a8 <lowerxdigits.0>
ffffffe000202ba8:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000202bac:	fe043783          	ld	a5,-32(s0)
ffffffe000202bb0:	00f7f793          	andi	a5,a5,15
ffffffe000202bb4:	f9843703          	ld	a4,-104(s0)
ffffffe000202bb8:	00f70733          	add	a4,a4,a5
ffffffe000202bbc:	fdc42783          	lw	a5,-36(s0)
ffffffe000202bc0:	0017869b          	addiw	a3,a5,1
ffffffe000202bc4:	fcd42e23          	sw	a3,-36(s0)
ffffffe000202bc8:	00074703          	lbu	a4,0(a4)
ffffffe000202bcc:	ff078793          	addi	a5,a5,-16
ffffffe000202bd0:	008787b3          	add	a5,a5,s0
ffffffe000202bd4:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000202bd8:	fe043783          	ld	a5,-32(s0)
ffffffe000202bdc:	0047d793          	srli	a5,a5,0x4
ffffffe000202be0:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe000202be4:	fe043783          	ld	a5,-32(s0)
ffffffe000202be8:	fc0792e3          	bnez	a5,ffffffe000202bac <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000202bec:	f8c42783          	lw	a5,-116(s0)
ffffffe000202bf0:	00078713          	mv	a4,a5
ffffffe000202bf4:	fff00793          	li	a5,-1
ffffffe000202bf8:	02f71663          	bne	a4,a5,ffffffe000202c24 <vprintfmt+0x3dc>
ffffffe000202bfc:	f8344783          	lbu	a5,-125(s0)
ffffffe000202c00:	02078263          	beqz	a5,ffffffe000202c24 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe000202c04:	f8842703          	lw	a4,-120(s0)
ffffffe000202c08:	fa644783          	lbu	a5,-90(s0)
ffffffe000202c0c:	0007879b          	sext.w	a5,a5
ffffffe000202c10:	0017979b          	slliw	a5,a5,0x1
ffffffe000202c14:	0007879b          	sext.w	a5,a5
ffffffe000202c18:	40f707bb          	subw	a5,a4,a5
ffffffe000202c1c:	0007879b          	sext.w	a5,a5
ffffffe000202c20:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202c24:	f8842703          	lw	a4,-120(s0)
ffffffe000202c28:	fa644783          	lbu	a5,-90(s0)
ffffffe000202c2c:	0007879b          	sext.w	a5,a5
ffffffe000202c30:	0017979b          	slliw	a5,a5,0x1
ffffffe000202c34:	0007879b          	sext.w	a5,a5
ffffffe000202c38:	40f707bb          	subw	a5,a4,a5
ffffffe000202c3c:	0007871b          	sext.w	a4,a5
ffffffe000202c40:	fdc42783          	lw	a5,-36(s0)
ffffffe000202c44:	f8f42a23          	sw	a5,-108(s0)
ffffffe000202c48:	f8c42783          	lw	a5,-116(s0)
ffffffe000202c4c:	f8f42823          	sw	a5,-112(s0)
ffffffe000202c50:	f9442783          	lw	a5,-108(s0)
ffffffe000202c54:	00078593          	mv	a1,a5
ffffffe000202c58:	f9042783          	lw	a5,-112(s0)
ffffffe000202c5c:	00078613          	mv	a2,a5
ffffffe000202c60:	0006069b          	sext.w	a3,a2
ffffffe000202c64:	0005879b          	sext.w	a5,a1
ffffffe000202c68:	00f6d463          	bge	a3,a5,ffffffe000202c70 <vprintfmt+0x428>
ffffffe000202c6c:	00058613          	mv	a2,a1
ffffffe000202c70:	0006079b          	sext.w	a5,a2
ffffffe000202c74:	40f707bb          	subw	a5,a4,a5
ffffffe000202c78:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202c7c:	0280006f          	j	ffffffe000202ca4 <vprintfmt+0x45c>
                    putch(' ');
ffffffe000202c80:	f5843783          	ld	a5,-168(s0)
ffffffe000202c84:	02000513          	li	a0,32
ffffffe000202c88:	000780e7          	jalr	a5
                    ++written;
ffffffe000202c8c:	fec42783          	lw	a5,-20(s0)
ffffffe000202c90:	0017879b          	addiw	a5,a5,1
ffffffe000202c94:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202c98:	fd842783          	lw	a5,-40(s0)
ffffffe000202c9c:	fff7879b          	addiw	a5,a5,-1
ffffffe000202ca0:	fcf42c23          	sw	a5,-40(s0)
ffffffe000202ca4:	fd842783          	lw	a5,-40(s0)
ffffffe000202ca8:	0007879b          	sext.w	a5,a5
ffffffe000202cac:	fcf04ae3          	bgtz	a5,ffffffe000202c80 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe000202cb0:	fa644783          	lbu	a5,-90(s0)
ffffffe000202cb4:	0ff7f793          	zext.b	a5,a5
ffffffe000202cb8:	04078463          	beqz	a5,ffffffe000202d00 <vprintfmt+0x4b8>
                    putch('0');
ffffffe000202cbc:	f5843783          	ld	a5,-168(s0)
ffffffe000202cc0:	03000513          	li	a0,48
ffffffe000202cc4:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000202cc8:	f5043783          	ld	a5,-176(s0)
ffffffe000202ccc:	0007c783          	lbu	a5,0(a5)
ffffffe000202cd0:	00078713          	mv	a4,a5
ffffffe000202cd4:	05800793          	li	a5,88
ffffffe000202cd8:	00f71663          	bne	a4,a5,ffffffe000202ce4 <vprintfmt+0x49c>
ffffffe000202cdc:	05800793          	li	a5,88
ffffffe000202ce0:	0080006f          	j	ffffffe000202ce8 <vprintfmt+0x4a0>
ffffffe000202ce4:	07800793          	li	a5,120
ffffffe000202ce8:	f5843703          	ld	a4,-168(s0)
ffffffe000202cec:	00078513          	mv	a0,a5
ffffffe000202cf0:	000700e7          	jalr	a4
                    written += 2;
ffffffe000202cf4:	fec42783          	lw	a5,-20(s0)
ffffffe000202cf8:	0027879b          	addiw	a5,a5,2
ffffffe000202cfc:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202d00:	fdc42783          	lw	a5,-36(s0)
ffffffe000202d04:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202d08:	0280006f          	j	ffffffe000202d30 <vprintfmt+0x4e8>
                    putch('0');
ffffffe000202d0c:	f5843783          	ld	a5,-168(s0)
ffffffe000202d10:	03000513          	li	a0,48
ffffffe000202d14:	000780e7          	jalr	a5
                    ++written;
ffffffe000202d18:	fec42783          	lw	a5,-20(s0)
ffffffe000202d1c:	0017879b          	addiw	a5,a5,1
ffffffe000202d20:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202d24:	fd442783          	lw	a5,-44(s0)
ffffffe000202d28:	0017879b          	addiw	a5,a5,1
ffffffe000202d2c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202d30:	f8c42703          	lw	a4,-116(s0)
ffffffe000202d34:	fd442783          	lw	a5,-44(s0)
ffffffe000202d38:	0007879b          	sext.w	a5,a5
ffffffe000202d3c:	fce7c8e3          	blt	a5,a4,ffffffe000202d0c <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202d40:	fdc42783          	lw	a5,-36(s0)
ffffffe000202d44:	fff7879b          	addiw	a5,a5,-1
ffffffe000202d48:	fcf42823          	sw	a5,-48(s0)
ffffffe000202d4c:	03c0006f          	j	ffffffe000202d88 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000202d50:	fd042783          	lw	a5,-48(s0)
ffffffe000202d54:	ff078793          	addi	a5,a5,-16
ffffffe000202d58:	008787b3          	add	a5,a5,s0
ffffffe000202d5c:	f807c783          	lbu	a5,-128(a5)
ffffffe000202d60:	0007871b          	sext.w	a4,a5
ffffffe000202d64:	f5843783          	ld	a5,-168(s0)
ffffffe000202d68:	00070513          	mv	a0,a4
ffffffe000202d6c:	000780e7          	jalr	a5
                    ++written;
ffffffe000202d70:	fec42783          	lw	a5,-20(s0)
ffffffe000202d74:	0017879b          	addiw	a5,a5,1
ffffffe000202d78:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000202d7c:	fd042783          	lw	a5,-48(s0)
ffffffe000202d80:	fff7879b          	addiw	a5,a5,-1
ffffffe000202d84:	fcf42823          	sw	a5,-48(s0)
ffffffe000202d88:	fd042783          	lw	a5,-48(s0)
ffffffe000202d8c:	0007879b          	sext.w	a5,a5
ffffffe000202d90:	fc07d0e3          	bgez	a5,ffffffe000202d50 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe000202d94:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202d98:	2700006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202d9c:	f5043783          	ld	a5,-176(s0)
ffffffe000202da0:	0007c783          	lbu	a5,0(a5)
ffffffe000202da4:	00078713          	mv	a4,a5
ffffffe000202da8:	06400793          	li	a5,100
ffffffe000202dac:	02f70663          	beq	a4,a5,ffffffe000202dd8 <vprintfmt+0x590>
ffffffe000202db0:	f5043783          	ld	a5,-176(s0)
ffffffe000202db4:	0007c783          	lbu	a5,0(a5)
ffffffe000202db8:	00078713          	mv	a4,a5
ffffffe000202dbc:	06900793          	li	a5,105
ffffffe000202dc0:	00f70c63          	beq	a4,a5,ffffffe000202dd8 <vprintfmt+0x590>
ffffffe000202dc4:	f5043783          	ld	a5,-176(s0)
ffffffe000202dc8:	0007c783          	lbu	a5,0(a5)
ffffffe000202dcc:	00078713          	mv	a4,a5
ffffffe000202dd0:	07500793          	li	a5,117
ffffffe000202dd4:	08f71063          	bne	a4,a5,ffffffe000202e54 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000202dd8:	f8144783          	lbu	a5,-127(s0)
ffffffe000202ddc:	00078c63          	beqz	a5,ffffffe000202df4 <vprintfmt+0x5ac>
ffffffe000202de0:	f4843783          	ld	a5,-184(s0)
ffffffe000202de4:	00878713          	addi	a4,a5,8
ffffffe000202de8:	f4e43423          	sd	a4,-184(s0)
ffffffe000202dec:	0007b783          	ld	a5,0(a5)
ffffffe000202df0:	0140006f          	j	ffffffe000202e04 <vprintfmt+0x5bc>
ffffffe000202df4:	f4843783          	ld	a5,-184(s0)
ffffffe000202df8:	00878713          	addi	a4,a5,8
ffffffe000202dfc:	f4e43423          	sd	a4,-184(s0)
ffffffe000202e00:	0007a783          	lw	a5,0(a5)
ffffffe000202e04:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000202e08:	fa843583          	ld	a1,-88(s0)
ffffffe000202e0c:	f5043783          	ld	a5,-176(s0)
ffffffe000202e10:	0007c783          	lbu	a5,0(a5)
ffffffe000202e14:	0007871b          	sext.w	a4,a5
ffffffe000202e18:	07500793          	li	a5,117
ffffffe000202e1c:	40f707b3          	sub	a5,a4,a5
ffffffe000202e20:	00f037b3          	snez	a5,a5
ffffffe000202e24:	0ff7f793          	zext.b	a5,a5
ffffffe000202e28:	f8040713          	addi	a4,s0,-128
ffffffe000202e2c:	00070693          	mv	a3,a4
ffffffe000202e30:	00078613          	mv	a2,a5
ffffffe000202e34:	f5843503          	ld	a0,-168(s0)
ffffffe000202e38:	f08ff0ef          	jal	ra,ffffffe000202540 <print_dec_int>
ffffffe000202e3c:	00050793          	mv	a5,a0
ffffffe000202e40:	fec42703          	lw	a4,-20(s0)
ffffffe000202e44:	00f707bb          	addw	a5,a4,a5
ffffffe000202e48:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202e4c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202e50:	1b80006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe000202e54:	f5043783          	ld	a5,-176(s0)
ffffffe000202e58:	0007c783          	lbu	a5,0(a5)
ffffffe000202e5c:	00078713          	mv	a4,a5
ffffffe000202e60:	06e00793          	li	a5,110
ffffffe000202e64:	04f71c63          	bne	a4,a5,ffffffe000202ebc <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe000202e68:	f8144783          	lbu	a5,-127(s0)
ffffffe000202e6c:	02078463          	beqz	a5,ffffffe000202e94 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe000202e70:	f4843783          	ld	a5,-184(s0)
ffffffe000202e74:	00878713          	addi	a4,a5,8
ffffffe000202e78:	f4e43423          	sd	a4,-184(s0)
ffffffe000202e7c:	0007b783          	ld	a5,0(a5)
ffffffe000202e80:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe000202e84:	fec42703          	lw	a4,-20(s0)
ffffffe000202e88:	fb043783          	ld	a5,-80(s0)
ffffffe000202e8c:	00e7b023          	sd	a4,0(a5)
ffffffe000202e90:	0240006f          	j	ffffffe000202eb4 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe000202e94:	f4843783          	ld	a5,-184(s0)
ffffffe000202e98:	00878713          	addi	a4,a5,8
ffffffe000202e9c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202ea0:	0007b783          	ld	a5,0(a5)
ffffffe000202ea4:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000202ea8:	fb843783          	ld	a5,-72(s0)
ffffffe000202eac:	fec42703          	lw	a4,-20(s0)
ffffffe000202eb0:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe000202eb4:	f8040023          	sb	zero,-128(s0)
ffffffe000202eb8:	1500006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000202ebc:	f5043783          	ld	a5,-176(s0)
ffffffe000202ec0:	0007c783          	lbu	a5,0(a5)
ffffffe000202ec4:	00078713          	mv	a4,a5
ffffffe000202ec8:	07300793          	li	a5,115
ffffffe000202ecc:	02f71e63          	bne	a4,a5,ffffffe000202f08 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000202ed0:	f4843783          	ld	a5,-184(s0)
ffffffe000202ed4:	00878713          	addi	a4,a5,8
ffffffe000202ed8:	f4e43423          	sd	a4,-184(s0)
ffffffe000202edc:	0007b783          	ld	a5,0(a5)
ffffffe000202ee0:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe000202ee4:	fc043583          	ld	a1,-64(s0)
ffffffe000202ee8:	f5843503          	ld	a0,-168(s0)
ffffffe000202eec:	dccff0ef          	jal	ra,ffffffe0002024b8 <puts_wo_nl>
ffffffe000202ef0:	00050793          	mv	a5,a0
ffffffe000202ef4:	fec42703          	lw	a4,-20(s0)
ffffffe000202ef8:	00f707bb          	addw	a5,a4,a5
ffffffe000202efc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202f00:	f8040023          	sb	zero,-128(s0)
ffffffe000202f04:	1040006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000202f08:	f5043783          	ld	a5,-176(s0)
ffffffe000202f0c:	0007c783          	lbu	a5,0(a5)
ffffffe000202f10:	00078713          	mv	a4,a5
ffffffe000202f14:	06300793          	li	a5,99
ffffffe000202f18:	02f71e63          	bne	a4,a5,ffffffe000202f54 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000202f1c:	f4843783          	ld	a5,-184(s0)
ffffffe000202f20:	00878713          	addi	a4,a5,8
ffffffe000202f24:	f4e43423          	sd	a4,-184(s0)
ffffffe000202f28:	0007a783          	lw	a5,0(a5)
ffffffe000202f2c:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000202f30:	fcc42703          	lw	a4,-52(s0)
ffffffe000202f34:	f5843783          	ld	a5,-168(s0)
ffffffe000202f38:	00070513          	mv	a0,a4
ffffffe000202f3c:	000780e7          	jalr	a5
                ++written;
ffffffe000202f40:	fec42783          	lw	a5,-20(s0)
ffffffe000202f44:	0017879b          	addiw	a5,a5,1
ffffffe000202f48:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202f4c:	f8040023          	sb	zero,-128(s0)
ffffffe000202f50:	0b80006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe000202f54:	f5043783          	ld	a5,-176(s0)
ffffffe000202f58:	0007c783          	lbu	a5,0(a5)
ffffffe000202f5c:	00078713          	mv	a4,a5
ffffffe000202f60:	02500793          	li	a5,37
ffffffe000202f64:	02f71263          	bne	a4,a5,ffffffe000202f88 <vprintfmt+0x740>
                putch('%');
ffffffe000202f68:	f5843783          	ld	a5,-168(s0)
ffffffe000202f6c:	02500513          	li	a0,37
ffffffe000202f70:	000780e7          	jalr	a5
                ++written;
ffffffe000202f74:	fec42783          	lw	a5,-20(s0)
ffffffe000202f78:	0017879b          	addiw	a5,a5,1
ffffffe000202f7c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202f80:	f8040023          	sb	zero,-128(s0)
ffffffe000202f84:	0840006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000202f88:	f5043783          	ld	a5,-176(s0)
ffffffe000202f8c:	0007c783          	lbu	a5,0(a5)
ffffffe000202f90:	0007871b          	sext.w	a4,a5
ffffffe000202f94:	f5843783          	ld	a5,-168(s0)
ffffffe000202f98:	00070513          	mv	a0,a4
ffffffe000202f9c:	000780e7          	jalr	a5
                ++written;
ffffffe000202fa0:	fec42783          	lw	a5,-20(s0)
ffffffe000202fa4:	0017879b          	addiw	a5,a5,1
ffffffe000202fa8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202fac:	f8040023          	sb	zero,-128(s0)
ffffffe000202fb0:	0580006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe000202fb4:	f5043783          	ld	a5,-176(s0)
ffffffe000202fb8:	0007c783          	lbu	a5,0(a5)
ffffffe000202fbc:	00078713          	mv	a4,a5
ffffffe000202fc0:	02500793          	li	a5,37
ffffffe000202fc4:	02f71063          	bne	a4,a5,ffffffe000202fe4 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202fc8:	f8043023          	sd	zero,-128(s0)
ffffffe000202fcc:	f8043423          	sd	zero,-120(s0)
ffffffe000202fd0:	00100793          	li	a5,1
ffffffe000202fd4:	f8f40023          	sb	a5,-128(s0)
ffffffe000202fd8:	fff00793          	li	a5,-1
ffffffe000202fdc:	f8f42623          	sw	a5,-116(s0)
ffffffe000202fe0:	0280006f          	j	ffffffe000203008 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe000202fe4:	f5043783          	ld	a5,-176(s0)
ffffffe000202fe8:	0007c783          	lbu	a5,0(a5)
ffffffe000202fec:	0007871b          	sext.w	a4,a5
ffffffe000202ff0:	f5843783          	ld	a5,-168(s0)
ffffffe000202ff4:	00070513          	mv	a0,a4
ffffffe000202ff8:	000780e7          	jalr	a5
            ++written;
ffffffe000202ffc:	fec42783          	lw	a5,-20(s0)
ffffffe000203000:	0017879b          	addiw	a5,a5,1
ffffffe000203004:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000203008:	f5043783          	ld	a5,-176(s0)
ffffffe00020300c:	00178793          	addi	a5,a5,1
ffffffe000203010:	f4f43823          	sd	a5,-176(s0)
ffffffe000203014:	f5043783          	ld	a5,-176(s0)
ffffffe000203018:	0007c783          	lbu	a5,0(a5)
ffffffe00020301c:	84079ce3          	bnez	a5,ffffffe000202874 <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000203020:	fec42783          	lw	a5,-20(s0)
}
ffffffe000203024:	00078513          	mv	a0,a5
ffffffe000203028:	0b813083          	ld	ra,184(sp)
ffffffe00020302c:	0b013403          	ld	s0,176(sp)
ffffffe000203030:	0c010113          	addi	sp,sp,192
ffffffe000203034:	00008067          	ret

ffffffe000203038 <printk>:

int printk(const char* s, ...) {
ffffffe000203038:	f9010113          	addi	sp,sp,-112
ffffffe00020303c:	02113423          	sd	ra,40(sp)
ffffffe000203040:	02813023          	sd	s0,32(sp)
ffffffe000203044:	03010413          	addi	s0,sp,48
ffffffe000203048:	fca43c23          	sd	a0,-40(s0)
ffffffe00020304c:	00b43423          	sd	a1,8(s0)
ffffffe000203050:	00c43823          	sd	a2,16(s0)
ffffffe000203054:	00d43c23          	sd	a3,24(s0)
ffffffe000203058:	02e43023          	sd	a4,32(s0)
ffffffe00020305c:	02f43423          	sd	a5,40(s0)
ffffffe000203060:	03043823          	sd	a6,48(s0)
ffffffe000203064:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000203068:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe00020306c:	04040793          	addi	a5,s0,64
ffffffe000203070:	fcf43823          	sd	a5,-48(s0)
ffffffe000203074:	fd043783          	ld	a5,-48(s0)
ffffffe000203078:	fc878793          	addi	a5,a5,-56
ffffffe00020307c:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000203080:	fe043783          	ld	a5,-32(s0)
ffffffe000203084:	00078613          	mv	a2,a5
ffffffe000203088:	fd843583          	ld	a1,-40(s0)
ffffffe00020308c:	fffff517          	auipc	a0,0xfffff
ffffffe000203090:	11850513          	addi	a0,a0,280 # ffffffe0002021a4 <putc>
ffffffe000203094:	fb4ff0ef          	jal	ra,ffffffe000202848 <vprintfmt>
ffffffe000203098:	00050793          	mv	a5,a0
ffffffe00020309c:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe0002030a0:	fec42783          	lw	a5,-20(s0)
}
ffffffe0002030a4:	00078513          	mv	a0,a5
ffffffe0002030a8:	02813083          	ld	ra,40(sp)
ffffffe0002030ac:	02013403          	ld	s0,32(sp)
ffffffe0002030b0:	07010113          	addi	sp,sp,112
ffffffe0002030b4:	00008067          	ret

ffffffe0002030b8 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe0002030b8:	fe010113          	addi	sp,sp,-32
ffffffe0002030bc:	00813c23          	sd	s0,24(sp)
ffffffe0002030c0:	02010413          	addi	s0,sp,32
ffffffe0002030c4:	00050793          	mv	a5,a0
ffffffe0002030c8:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe0002030cc:	fec42783          	lw	a5,-20(s0)
ffffffe0002030d0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002030d4:	0007879b          	sext.w	a5,a5
ffffffe0002030d8:	02079713          	slli	a4,a5,0x20
ffffffe0002030dc:	02075713          	srli	a4,a4,0x20
ffffffe0002030e0:	00006797          	auipc	a5,0x6
ffffffe0002030e4:	f3878793          	addi	a5,a5,-200 # ffffffe000209018 <seed>
ffffffe0002030e8:	00e7b023          	sd	a4,0(a5)
}
ffffffe0002030ec:	00000013          	nop
ffffffe0002030f0:	01813403          	ld	s0,24(sp)
ffffffe0002030f4:	02010113          	addi	sp,sp,32
ffffffe0002030f8:	00008067          	ret

ffffffe0002030fc <rand>:

int rand(void) {
ffffffe0002030fc:	ff010113          	addi	sp,sp,-16
ffffffe000203100:	00813423          	sd	s0,8(sp)
ffffffe000203104:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000203108:	00006797          	auipc	a5,0x6
ffffffe00020310c:	f1078793          	addi	a5,a5,-240 # ffffffe000209018 <seed>
ffffffe000203110:	0007b703          	ld	a4,0(a5)
ffffffe000203114:	00001797          	auipc	a5,0x1
ffffffe000203118:	5ac78793          	addi	a5,a5,1452 # ffffffe0002046c0 <lowerxdigits.0+0x18>
ffffffe00020311c:	0007b783          	ld	a5,0(a5)
ffffffe000203120:	02f707b3          	mul	a5,a4,a5
ffffffe000203124:	00178713          	addi	a4,a5,1
ffffffe000203128:	00006797          	auipc	a5,0x6
ffffffe00020312c:	ef078793          	addi	a5,a5,-272 # ffffffe000209018 <seed>
ffffffe000203130:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe000203134:	00006797          	auipc	a5,0x6
ffffffe000203138:	ee478793          	addi	a5,a5,-284 # ffffffe000209018 <seed>
ffffffe00020313c:	0007b783          	ld	a5,0(a5)
ffffffe000203140:	0217d793          	srli	a5,a5,0x21
ffffffe000203144:	0007879b          	sext.w	a5,a5
}
ffffffe000203148:	00078513          	mv	a0,a5
ffffffe00020314c:	00813403          	ld	s0,8(sp)
ffffffe000203150:	01010113          	addi	sp,sp,16
ffffffe000203154:	00008067          	ret

ffffffe000203158 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000203158:	fc010113          	addi	sp,sp,-64
ffffffe00020315c:	02813c23          	sd	s0,56(sp)
ffffffe000203160:	04010413          	addi	s0,sp,64
ffffffe000203164:	fca43c23          	sd	a0,-40(s0)
ffffffe000203168:	00058793          	mv	a5,a1
ffffffe00020316c:	fcc43423          	sd	a2,-56(s0)
ffffffe000203170:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe000203174:	fd843783          	ld	a5,-40(s0)
ffffffe000203178:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe00020317c:	fe043423          	sd	zero,-24(s0)
ffffffe000203180:	0280006f          	j	ffffffe0002031a8 <memset+0x50>
        s[i] = c;
ffffffe000203184:	fe043703          	ld	a4,-32(s0)
ffffffe000203188:	fe843783          	ld	a5,-24(s0)
ffffffe00020318c:	00f707b3          	add	a5,a4,a5
ffffffe000203190:	fd442703          	lw	a4,-44(s0)
ffffffe000203194:	0ff77713          	zext.b	a4,a4
ffffffe000203198:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe00020319c:	fe843783          	ld	a5,-24(s0)
ffffffe0002031a0:	00178793          	addi	a5,a5,1
ffffffe0002031a4:	fef43423          	sd	a5,-24(s0)
ffffffe0002031a8:	fe843703          	ld	a4,-24(s0)
ffffffe0002031ac:	fc843783          	ld	a5,-56(s0)
ffffffe0002031b0:	fcf76ae3          	bltu	a4,a5,ffffffe000203184 <memset+0x2c>
    }
    return dest;
ffffffe0002031b4:	fd843783          	ld	a5,-40(s0)
}
ffffffe0002031b8:	00078513          	mv	a0,a5
ffffffe0002031bc:	03813403          	ld	s0,56(sp)
ffffffe0002031c0:	04010113          	addi	sp,sp,64
ffffffe0002031c4:	00008067          	ret
