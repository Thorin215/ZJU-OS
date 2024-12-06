
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .extern setup_vm
    .extern setup_vm_final
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
ffffffe000200000:	0000b117          	auipc	sp,0xb
ffffffe000200004:	00010113          	mv	sp,sp
    
    call setup_vm
ffffffe000200008:	09c030ef          	jal	ra,ffffffe0002030a4 <setup_vm>
    call relocate
ffffffe00020000c:	060000ef          	jal	ra,ffffffe00020006c <relocate>

    call mm_init
ffffffe000200010:	575000ef          	jal	ra,ffffffe000200d84 <mm_init>

    call setup_vm_final
ffffffe000200014:	1bc030ef          	jal	ra,ffffffe0002031d0 <setup_vm_final>

    call task_init
ffffffe000200018:	228010ef          	jal	ra,ffffffe000201240 <task_init>

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
ffffffe000200068:	57c030ef          	jal	ra,ffffffe0002035e4 <start_kernel>

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
ffffffe000200080:	0000c317          	auipc	t1,0xc
ffffffe000200084:	f8030313          	addi	t1,t1,-128 # ffffffe00020c000 <early_pgtbl>
    
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
ffffffe0002000b0:	f0010113          	addi	sp,sp,-256 # ffffffe00020af00 <_sbss+0xf00>
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
ffffffe000200144:	14d010ef          	jal	ra,ffffffe000201a90 <trap_handler>

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
ffffffe0002002fc:	00006797          	auipc	a5,0x6
ffffffe000200300:	d0478793          	addi	a5,a5,-764 # ffffffe000206000 <TIMECLOCK>
ffffffe000200304:	0007b783          	ld	a5,0(a5)
ffffffe000200308:	00f707b3          	add	a5,a4,a5
ffffffe00020030c:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe000200310:	fe843503          	ld	a0,-24(s0)
ffffffe000200314:	6f0010ef          	jal	ra,ffffffe000201a04 <sbi_set_timer>
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
ffffffe000200410:	0000b797          	auipc	a5,0xb
ffffffe000200414:	c1078793          	addi	a5,a5,-1008 # ffffffe00020b020 <buddy>
ffffffe000200418:	fe843703          	ld	a4,-24(s0)
ffffffe00020041c:	00e7b023          	sd	a4,0(a5)
    buddy.bitmap = free_page_start;
ffffffe000200420:	00006797          	auipc	a5,0x6
ffffffe000200424:	be878793          	addi	a5,a5,-1048 # ffffffe000206008 <free_page_start>
ffffffe000200428:	0007b703          	ld	a4,0(a5)
ffffffe00020042c:	0000b797          	auipc	a5,0xb
ffffffe000200430:	bf478793          	addi	a5,a5,-1036 # ffffffe00020b020 <buddy>
ffffffe000200434:	00e7b423          	sd	a4,8(a5)
    free_page_start += 2 * buddy.size * sizeof(*buddy.bitmap);
ffffffe000200438:	00006797          	auipc	a5,0x6
ffffffe00020043c:	bd078793          	addi	a5,a5,-1072 # ffffffe000206008 <free_page_start>
ffffffe000200440:	0007b703          	ld	a4,0(a5)
ffffffe000200444:	0000b797          	auipc	a5,0xb
ffffffe000200448:	bdc78793          	addi	a5,a5,-1060 # ffffffe00020b020 <buddy>
ffffffe00020044c:	0007b783          	ld	a5,0(a5)
ffffffe000200450:	00479793          	slli	a5,a5,0x4
ffffffe000200454:	00f70733          	add	a4,a4,a5
ffffffe000200458:	00006797          	auipc	a5,0x6
ffffffe00020045c:	bb078793          	addi	a5,a5,-1104 # ffffffe000206008 <free_page_start>
ffffffe000200460:	00e7b023          	sd	a4,0(a5)
    memset(buddy.bitmap, 0, 2 * buddy.size * sizeof(*buddy.bitmap));
ffffffe000200464:	0000b797          	auipc	a5,0xb
ffffffe000200468:	bbc78793          	addi	a5,a5,-1092 # ffffffe00020b020 <buddy>
ffffffe00020046c:	0087b703          	ld	a4,8(a5)
ffffffe000200470:	0000b797          	auipc	a5,0xb
ffffffe000200474:	bb078793          	addi	a5,a5,-1104 # ffffffe00020b020 <buddy>
ffffffe000200478:	0007b783          	ld	a5,0(a5)
ffffffe00020047c:	00479793          	slli	a5,a5,0x4
ffffffe000200480:	00078613          	mv	a2,a5
ffffffe000200484:	00000593          	li	a1,0
ffffffe000200488:	00070513          	mv	a0,a4
ffffffe00020048c:	1a4040ef          	jal	ra,ffffffe000204630 <memset>

    buddy.ref_cnt = free_page_start;
ffffffe000200490:	00006797          	auipc	a5,0x6
ffffffe000200494:	b7878793          	addi	a5,a5,-1160 # ffffffe000206008 <free_page_start>
ffffffe000200498:	0007b703          	ld	a4,0(a5)
ffffffe00020049c:	0000b797          	auipc	a5,0xb
ffffffe0002004a0:	b8478793          	addi	a5,a5,-1148 # ffffffe00020b020 <buddy>
ffffffe0002004a4:	00e7b823          	sd	a4,16(a5)
    free_page_start += buddy.size * sizeof(*buddy.ref_cnt);
ffffffe0002004a8:	00006797          	auipc	a5,0x6
ffffffe0002004ac:	b6078793          	addi	a5,a5,-1184 # ffffffe000206008 <free_page_start>
ffffffe0002004b0:	0007b703          	ld	a4,0(a5)
ffffffe0002004b4:	0000b797          	auipc	a5,0xb
ffffffe0002004b8:	b6c78793          	addi	a5,a5,-1172 # ffffffe00020b020 <buddy>
ffffffe0002004bc:	0007b783          	ld	a5,0(a5)
ffffffe0002004c0:	00379793          	slli	a5,a5,0x3
ffffffe0002004c4:	00f70733          	add	a4,a4,a5
ffffffe0002004c8:	00006797          	auipc	a5,0x6
ffffffe0002004cc:	b4078793          	addi	a5,a5,-1216 # ffffffe000206008 <free_page_start>
ffffffe0002004d0:	00e7b023          	sd	a4,0(a5)
    memset(buddy.ref_cnt, 0, buddy.size * sizeof(*buddy.ref_cnt));
ffffffe0002004d4:	0000b797          	auipc	a5,0xb
ffffffe0002004d8:	b4c78793          	addi	a5,a5,-1204 # ffffffe00020b020 <buddy>
ffffffe0002004dc:	0107b703          	ld	a4,16(a5)
ffffffe0002004e0:	0000b797          	auipc	a5,0xb
ffffffe0002004e4:	b4078793          	addi	a5,a5,-1216 # ffffffe00020b020 <buddy>
ffffffe0002004e8:	0007b783          	ld	a5,0(a5)
ffffffe0002004ec:	00379793          	slli	a5,a5,0x3
ffffffe0002004f0:	00078613          	mv	a2,a5
ffffffe0002004f4:	00000593          	li	a1,0
ffffffe0002004f8:	00070513          	mv	a0,a4
ffffffe0002004fc:	134040ef          	jal	ra,ffffffe000204630 <memset>

    uint64_t node_size = buddy.size * 2;
ffffffe000200500:	0000b797          	auipc	a5,0xb
ffffffe000200504:	b2078793          	addi	a5,a5,-1248 # ffffffe00020b020 <buddy>
ffffffe000200508:	0007b783          	ld	a5,0(a5)
ffffffe00020050c:	00179793          	slli	a5,a5,0x1
ffffffe000200510:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe000200514:	fc043c23          	sd	zero,-40(s0)
ffffffe000200518:	0500006f          	j	ffffffe000200568 <buddy_init+0x190>
        if (IS_POWER_OF_2(i + 1))
ffffffe00020051c:	fd843783          	ld	a5,-40(s0)
ffffffe000200520:	00178713          	addi	a4,a5,1
ffffffe000200524:	fd843783          	ld	a5,-40(s0)
ffffffe000200528:	00f777b3          	and	a5,a4,a5
ffffffe00020052c:	00079863          	bnez	a5,ffffffe00020053c <buddy_init+0x164>
            node_size /= 2;
ffffffe000200530:	fe043783          	ld	a5,-32(s0)
ffffffe000200534:	0017d793          	srli	a5,a5,0x1
ffffffe000200538:	fef43023          	sd	a5,-32(s0)
        buddy.bitmap[i] = node_size;
ffffffe00020053c:	0000b797          	auipc	a5,0xb
ffffffe000200540:	ae478793          	addi	a5,a5,-1308 # ffffffe00020b020 <buddy>
ffffffe000200544:	0087b703          	ld	a4,8(a5)
ffffffe000200548:	fd843783          	ld	a5,-40(s0)
ffffffe00020054c:	00379793          	slli	a5,a5,0x3
ffffffe000200550:	00f707b3          	add	a5,a4,a5
ffffffe000200554:	fe043703          	ld	a4,-32(s0)
ffffffe000200558:	00e7b023          	sd	a4,0(a5)
    for (uint64_t i = 0; i < 2 * buddy.size - 1; ++i) {
ffffffe00020055c:	fd843783          	ld	a5,-40(s0)
ffffffe000200560:	00178793          	addi	a5,a5,1
ffffffe000200564:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200568:	0000b797          	auipc	a5,0xb
ffffffe00020056c:	ab878793          	addi	a5,a5,-1352 # ffffffe00020b020 <buddy>
ffffffe000200570:	0007b783          	ld	a5,0(a5)
ffffffe000200574:	00179793          	slli	a5,a5,0x1
ffffffe000200578:	fff78793          	addi	a5,a5,-1
ffffffe00020057c:	fd843703          	ld	a4,-40(s0)
ffffffe000200580:	f8f76ee3          	bltu	a4,a5,ffffffe00020051c <buddy_init+0x144>
    }

    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200584:	fc043823          	sd	zero,-48(s0)
ffffffe000200588:	0180006f          	j	ffffffe0002005a0 <buddy_init+0x1c8>
        buddy_alloc(1);
ffffffe00020058c:	00100513          	li	a0,1
ffffffe000200590:	32c000ef          	jal	ra,ffffffe0002008bc <buddy_alloc>
    for (uint64_t pfn = 0; (uint64_t)PFN2PHYS(pfn) < VA2PA((uint64_t)free_page_start); ++pfn) {
ffffffe000200594:	fd043783          	ld	a5,-48(s0)
ffffffe000200598:	00178793          	addi	a5,a5,1
ffffffe00020059c:	fcf43823          	sd	a5,-48(s0)
ffffffe0002005a0:	fd043783          	ld	a5,-48(s0)
ffffffe0002005a4:	00c79713          	slli	a4,a5,0xc
ffffffe0002005a8:	00100793          	li	a5,1
ffffffe0002005ac:	01f79793          	slli	a5,a5,0x1f
ffffffe0002005b0:	00f70733          	add	a4,a4,a5
ffffffe0002005b4:	00006797          	auipc	a5,0x6
ffffffe0002005b8:	a5478793          	addi	a5,a5,-1452 # ffffffe000206008 <free_page_start>
ffffffe0002005bc:	0007b783          	ld	a5,0(a5)
ffffffe0002005c0:	00078693          	mv	a3,a5
ffffffe0002005c4:	04100793          	li	a5,65
ffffffe0002005c8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002005cc:	00f687b3          	add	a5,a3,a5
ffffffe0002005d0:	faf76ee3          	bltu	a4,a5,ffffffe00020058c <buddy_init+0x1b4>
    }

    printk("...buddy_init done!\n");
ffffffe0002005d4:	00005517          	auipc	a0,0x5
ffffffe0002005d8:	a3450513          	addi	a0,a0,-1484 # ffffffe000205008 <__func__.3+0x8>
ffffffe0002005dc:	735030ef          	jal	ra,ffffffe000204510 <printk>
    return;
ffffffe0002005e0:	00000013          	nop
}
ffffffe0002005e4:	02813083          	ld	ra,40(sp)
ffffffe0002005e8:	02013403          	ld	s0,32(sp)
ffffffe0002005ec:	03010113          	addi	sp,sp,48
ffffffe0002005f0:	00008067          	ret

ffffffe0002005f4 <page_ref_inc>:

void page_ref_inc(uint64_t pfn) {
ffffffe0002005f4:	fe010113          	addi	sp,sp,-32
ffffffe0002005f8:	00813c23          	sd	s0,24(sp)
ffffffe0002005fc:	02010413          	addi	s0,sp,32
ffffffe000200600:	fea43423          	sd	a0,-24(s0)
    buddy.ref_cnt[pfn]++;
ffffffe000200604:	0000b797          	auipc	a5,0xb
ffffffe000200608:	a1c78793          	addi	a5,a5,-1508 # ffffffe00020b020 <buddy>
ffffffe00020060c:	0107b703          	ld	a4,16(a5)
ffffffe000200610:	fe843783          	ld	a5,-24(s0)
ffffffe000200614:	00379793          	slli	a5,a5,0x3
ffffffe000200618:	00f707b3          	add	a5,a4,a5
ffffffe00020061c:	0007b703          	ld	a4,0(a5)
ffffffe000200620:	00170713          	addi	a4,a4,1
ffffffe000200624:	00e7b023          	sd	a4,0(a5)
}
ffffffe000200628:	00000013          	nop
ffffffe00020062c:	01813403          	ld	s0,24(sp)
ffffffe000200630:	02010113          	addi	sp,sp,32
ffffffe000200634:	00008067          	ret

ffffffe000200638 <page_ref_dec>:

void page_ref_dec(uint64_t pfn) {
ffffffe000200638:	fe010113          	addi	sp,sp,-32
ffffffe00020063c:	00113c23          	sd	ra,24(sp)
ffffffe000200640:	00813823          	sd	s0,16(sp)
ffffffe000200644:	02010413          	addi	s0,sp,32
ffffffe000200648:	fea43423          	sd	a0,-24(s0)
    if (buddy.ref_cnt[pfn] > 0) {
ffffffe00020064c:	0000b797          	auipc	a5,0xb
ffffffe000200650:	9d478793          	addi	a5,a5,-1580 # ffffffe00020b020 <buddy>
ffffffe000200654:	0107b703          	ld	a4,16(a5)
ffffffe000200658:	fe843783          	ld	a5,-24(s0)
ffffffe00020065c:	00379793          	slli	a5,a5,0x3
ffffffe000200660:	00f707b3          	add	a5,a4,a5
ffffffe000200664:	0007b783          	ld	a5,0(a5)
ffffffe000200668:	02078463          	beqz	a5,ffffffe000200690 <page_ref_dec+0x58>
        buddy.ref_cnt[pfn]--;
ffffffe00020066c:	0000b797          	auipc	a5,0xb
ffffffe000200670:	9b478793          	addi	a5,a5,-1612 # ffffffe00020b020 <buddy>
ffffffe000200674:	0107b703          	ld	a4,16(a5)
ffffffe000200678:	fe843783          	ld	a5,-24(s0)
ffffffe00020067c:	00379793          	slli	a5,a5,0x3
ffffffe000200680:	00f707b3          	add	a5,a4,a5
ffffffe000200684:	0007b703          	ld	a4,0(a5)
ffffffe000200688:	fff70713          	addi	a4,a4,-1
ffffffe00020068c:	00e7b023          	sd	a4,0(a5)
    }
    if (buddy.ref_cnt[pfn] == 0) {
ffffffe000200690:	0000b797          	auipc	a5,0xb
ffffffe000200694:	99078793          	addi	a5,a5,-1648 # ffffffe00020b020 <buddy>
ffffffe000200698:	0107b703          	ld	a4,16(a5)
ffffffe00020069c:	fe843783          	ld	a5,-24(s0)
ffffffe0002006a0:	00379793          	slli	a5,a5,0x3
ffffffe0002006a4:	00f707b3          	add	a5,a4,a5
ffffffe0002006a8:	0007b783          	ld	a5,0(a5)
ffffffe0002006ac:	04079263          	bnez	a5,ffffffe0002006f0 <page_ref_dec+0xb8>
        LogYELLOW("free page: %p", PFN2PHYS(pfn));
ffffffe0002006b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002006b4:	00c79713          	slli	a4,a5,0xc
ffffffe0002006b8:	00100793          	li	a5,1
ffffffe0002006bc:	01f79793          	slli	a5,a5,0x1f
ffffffe0002006c0:	00f707b3          	add	a5,a4,a5
ffffffe0002006c4:	00078713          	mv	a4,a5
ffffffe0002006c8:	00005697          	auipc	a3,0x5
ffffffe0002006cc:	9a068693          	addi	a3,a3,-1632 # ffffffe000205068 <__func__.0>
ffffffe0002006d0:	04c00613          	li	a2,76
ffffffe0002006d4:	00005597          	auipc	a1,0x5
ffffffe0002006d8:	94c58593          	addi	a1,a1,-1716 # ffffffe000205020 <__func__.3+0x20>
ffffffe0002006dc:	00005517          	auipc	a0,0x5
ffffffe0002006e0:	94c50513          	addi	a0,a0,-1716 # ffffffe000205028 <__func__.3+0x28>
ffffffe0002006e4:	62d030ef          	jal	ra,ffffffe000204510 <printk>
        buddy_free(pfn);
ffffffe0002006e8:	fe843503          	ld	a0,-24(s0)
ffffffe0002006ec:	018000ef          	jal	ra,ffffffe000200704 <buddy_free>
    }
}
ffffffe0002006f0:	00000013          	nop
ffffffe0002006f4:	01813083          	ld	ra,24(sp)
ffffffe0002006f8:	01013403          	ld	s0,16(sp)
ffffffe0002006fc:	02010113          	addi	sp,sp,32
ffffffe000200700:	00008067          	ret

ffffffe000200704 <buddy_free>:


void buddy_free(uint64_t pfn) {
ffffffe000200704:	fc010113          	addi	sp,sp,-64
ffffffe000200708:	02813c23          	sd	s0,56(sp)
ffffffe00020070c:	04010413          	addi	s0,sp,64
ffffffe000200710:	fca43423          	sd	a0,-56(s0)
    if (buddy.ref_cnt[pfn]) {
ffffffe000200714:	0000b797          	auipc	a5,0xb
ffffffe000200718:	90c78793          	addi	a5,a5,-1780 # ffffffe00020b020 <buddy>
ffffffe00020071c:	0107b703          	ld	a4,16(a5)
ffffffe000200720:	fc843783          	ld	a5,-56(s0)
ffffffe000200724:	00379793          	slli	a5,a5,0x3
ffffffe000200728:	00f707b3          	add	a5,a4,a5
ffffffe00020072c:	0007b783          	ld	a5,0(a5)
ffffffe000200730:	16079e63          	bnez	a5,ffffffe0002008ac <buddy_free+0x1a8>
        return;
    }
    uint64_t node_size, index = 0;
ffffffe000200734:	fe043023          	sd	zero,-32(s0)
    uint64_t left_longest, right_longest;

    node_size = 1;
ffffffe000200738:	00100793          	li	a5,1
ffffffe00020073c:	fef43423          	sd	a5,-24(s0)
    index = pfn + buddy.size - 1;
ffffffe000200740:	0000b797          	auipc	a5,0xb
ffffffe000200744:	8e078793          	addi	a5,a5,-1824 # ffffffe00020b020 <buddy>
ffffffe000200748:	0007b703          	ld	a4,0(a5)
ffffffe00020074c:	fc843783          	ld	a5,-56(s0)
ffffffe000200750:	00f707b3          	add	a5,a4,a5
ffffffe000200754:	fff78793          	addi	a5,a5,-1
ffffffe000200758:	fef43023          	sd	a5,-32(s0)

    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe00020075c:	02c0006f          	j	ffffffe000200788 <buddy_free+0x84>
        node_size *= 2;
ffffffe000200760:	fe843783          	ld	a5,-24(s0)
ffffffe000200764:	00179793          	slli	a5,a5,0x1
ffffffe000200768:	fef43423          	sd	a5,-24(s0)
        if (index == 0)
ffffffe00020076c:	fe043783          	ld	a5,-32(s0)
ffffffe000200770:	02078e63          	beqz	a5,ffffffe0002007ac <buddy_free+0xa8>
    for (; buddy.bitmap[index]; index = PARENT(index)) {
ffffffe000200774:	fe043783          	ld	a5,-32(s0)
ffffffe000200778:	00178793          	addi	a5,a5,1
ffffffe00020077c:	0017d793          	srli	a5,a5,0x1
ffffffe000200780:	fff78793          	addi	a5,a5,-1
ffffffe000200784:	fef43023          	sd	a5,-32(s0)
ffffffe000200788:	0000b797          	auipc	a5,0xb
ffffffe00020078c:	89878793          	addi	a5,a5,-1896 # ffffffe00020b020 <buddy>
ffffffe000200790:	0087b703          	ld	a4,8(a5)
ffffffe000200794:	fe043783          	ld	a5,-32(s0)
ffffffe000200798:	00379793          	slli	a5,a5,0x3
ffffffe00020079c:	00f707b3          	add	a5,a4,a5
ffffffe0002007a0:	0007b783          	ld	a5,0(a5)
ffffffe0002007a4:	fa079ee3          	bnez	a5,ffffffe000200760 <buddy_free+0x5c>
ffffffe0002007a8:	0080006f          	j	ffffffe0002007b0 <buddy_free+0xac>
            break;
ffffffe0002007ac:	00000013          	nop
    }

    buddy.bitmap[index] = node_size;
ffffffe0002007b0:	0000b797          	auipc	a5,0xb
ffffffe0002007b4:	87078793          	addi	a5,a5,-1936 # ffffffe00020b020 <buddy>
ffffffe0002007b8:	0087b703          	ld	a4,8(a5)
ffffffe0002007bc:	fe043783          	ld	a5,-32(s0)
ffffffe0002007c0:	00379793          	slli	a5,a5,0x3
ffffffe0002007c4:	00f707b3          	add	a5,a4,a5
ffffffe0002007c8:	fe843703          	ld	a4,-24(s0)
ffffffe0002007cc:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe0002007d0:	0d00006f          	j	ffffffe0002008a0 <buddy_free+0x19c>
        index = PARENT(index);
ffffffe0002007d4:	fe043783          	ld	a5,-32(s0)
ffffffe0002007d8:	00178793          	addi	a5,a5,1
ffffffe0002007dc:	0017d793          	srli	a5,a5,0x1
ffffffe0002007e0:	fff78793          	addi	a5,a5,-1
ffffffe0002007e4:	fef43023          	sd	a5,-32(s0)
        node_size *= 2;
ffffffe0002007e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002007ec:	00179793          	slli	a5,a5,0x1
ffffffe0002007f0:	fef43423          	sd	a5,-24(s0)

        left_longest = buddy.bitmap[LEFT_LEAF(index)];
ffffffe0002007f4:	0000b797          	auipc	a5,0xb
ffffffe0002007f8:	82c78793          	addi	a5,a5,-2004 # ffffffe00020b020 <buddy>
ffffffe0002007fc:	0087b703          	ld	a4,8(a5)
ffffffe000200800:	fe043783          	ld	a5,-32(s0)
ffffffe000200804:	00479793          	slli	a5,a5,0x4
ffffffe000200808:	00878793          	addi	a5,a5,8
ffffffe00020080c:	00f707b3          	add	a5,a4,a5
ffffffe000200810:	0007b783          	ld	a5,0(a5)
ffffffe000200814:	fcf43c23          	sd	a5,-40(s0)
        right_longest = buddy.bitmap[RIGHT_LEAF(index)];
ffffffe000200818:	0000b797          	auipc	a5,0xb
ffffffe00020081c:	80878793          	addi	a5,a5,-2040 # ffffffe00020b020 <buddy>
ffffffe000200820:	0087b703          	ld	a4,8(a5)
ffffffe000200824:	fe043783          	ld	a5,-32(s0)
ffffffe000200828:	00178793          	addi	a5,a5,1
ffffffe00020082c:	00479793          	slli	a5,a5,0x4
ffffffe000200830:	00f707b3          	add	a5,a4,a5
ffffffe000200834:	0007b783          	ld	a5,0(a5)
ffffffe000200838:	fcf43823          	sd	a5,-48(s0)

        if (left_longest + right_longest == node_size) 
ffffffe00020083c:	fd843703          	ld	a4,-40(s0)
ffffffe000200840:	fd043783          	ld	a5,-48(s0)
ffffffe000200844:	00f707b3          	add	a5,a4,a5
ffffffe000200848:	fe843703          	ld	a4,-24(s0)
ffffffe00020084c:	02f71463          	bne	a4,a5,ffffffe000200874 <buddy_free+0x170>
            buddy.bitmap[index] = node_size;
ffffffe000200850:	0000a797          	auipc	a5,0xa
ffffffe000200854:	7d078793          	addi	a5,a5,2000 # ffffffe00020b020 <buddy>
ffffffe000200858:	0087b703          	ld	a4,8(a5)
ffffffe00020085c:	fe043783          	ld	a5,-32(s0)
ffffffe000200860:	00379793          	slli	a5,a5,0x3
ffffffe000200864:	00f707b3          	add	a5,a4,a5
ffffffe000200868:	fe843703          	ld	a4,-24(s0)
ffffffe00020086c:	00e7b023          	sd	a4,0(a5)
ffffffe000200870:	0300006f          	j	ffffffe0002008a0 <buddy_free+0x19c>
        else
            buddy.bitmap[index] = MAX(left_longest, right_longest);
ffffffe000200874:	0000a797          	auipc	a5,0xa
ffffffe000200878:	7ac78793          	addi	a5,a5,1964 # ffffffe00020b020 <buddy>
ffffffe00020087c:	0087b703          	ld	a4,8(a5)
ffffffe000200880:	fe043783          	ld	a5,-32(s0)
ffffffe000200884:	00379793          	slli	a5,a5,0x3
ffffffe000200888:	00f706b3          	add	a3,a4,a5
ffffffe00020088c:	fd843703          	ld	a4,-40(s0)
ffffffe000200890:	fd043783          	ld	a5,-48(s0)
ffffffe000200894:	00e7f463          	bgeu	a5,a4,ffffffe00020089c <buddy_free+0x198>
ffffffe000200898:	00070793          	mv	a5,a4
ffffffe00020089c:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe0002008a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002008a4:	f20798e3          	bnez	a5,ffffffe0002007d4 <buddy_free+0xd0>
ffffffe0002008a8:	0080006f          	j	ffffffe0002008b0 <buddy_free+0x1ac>
        return;
ffffffe0002008ac:	00000013          	nop
    }
}
ffffffe0002008b0:	03813403          	ld	s0,56(sp)
ffffffe0002008b4:	04010113          	addi	sp,sp,64
ffffffe0002008b8:	00008067          	ret

ffffffe0002008bc <buddy_alloc>:

uint64_t buddy_alloc(uint64_t nrpages) {
ffffffe0002008bc:	fc010113          	addi	sp,sp,-64
ffffffe0002008c0:	02113c23          	sd	ra,56(sp)
ffffffe0002008c4:	02813823          	sd	s0,48(sp)
ffffffe0002008c8:	04010413          	addi	s0,sp,64
ffffffe0002008cc:	fca43423          	sd	a0,-56(s0)
    uint64_t index = 0;
ffffffe0002008d0:	fe043423          	sd	zero,-24(s0)
    uint64_t node_size;
    uint64_t pfn = 0;
ffffffe0002008d4:	fc043c23          	sd	zero,-40(s0)

    if (nrpages <= 0)
ffffffe0002008d8:	fc843783          	ld	a5,-56(s0)
ffffffe0002008dc:	00079863          	bnez	a5,ffffffe0002008ec <buddy_alloc+0x30>
        nrpages = 1;
ffffffe0002008e0:	00100793          	li	a5,1
ffffffe0002008e4:	fcf43423          	sd	a5,-56(s0)
ffffffe0002008e8:	0240006f          	j	ffffffe00020090c <buddy_alloc+0x50>
    else if (!IS_POWER_OF_2(nrpages))
ffffffe0002008ec:	fc843783          	ld	a5,-56(s0)
ffffffe0002008f0:	fff78713          	addi	a4,a5,-1
ffffffe0002008f4:	fc843783          	ld	a5,-56(s0)
ffffffe0002008f8:	00f777b3          	and	a5,a4,a5
ffffffe0002008fc:	00078863          	beqz	a5,ffffffe00020090c <buddy_alloc+0x50>
        nrpages = fixsize(nrpages);
ffffffe000200900:	fc843503          	ld	a0,-56(s0)
ffffffe000200904:	a29ff0ef          	jal	ra,ffffffe00020032c <fixsize>
ffffffe000200908:	fca43423          	sd	a0,-56(s0)

    if (buddy.bitmap[index] < nrpages)
ffffffe00020090c:	0000a797          	auipc	a5,0xa
ffffffe000200910:	71478793          	addi	a5,a5,1812 # ffffffe00020b020 <buddy>
ffffffe000200914:	0087b703          	ld	a4,8(a5)
ffffffe000200918:	fe843783          	ld	a5,-24(s0)
ffffffe00020091c:	00379793          	slli	a5,a5,0x3
ffffffe000200920:	00f707b3          	add	a5,a4,a5
ffffffe000200924:	0007b783          	ld	a5,0(a5)
ffffffe000200928:	fc843703          	ld	a4,-56(s0)
ffffffe00020092c:	00e7f663          	bgeu	a5,a4,ffffffe000200938 <buddy_alloc+0x7c>
        return 0;
ffffffe000200930:	00000793          	li	a5,0
ffffffe000200934:	1680006f          	j	ffffffe000200a9c <buddy_alloc+0x1e0>

    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200938:	0000a797          	auipc	a5,0xa
ffffffe00020093c:	6e878793          	addi	a5,a5,1768 # ffffffe00020b020 <buddy>
ffffffe000200940:	0007b783          	ld	a5,0(a5)
ffffffe000200944:	fef43023          	sd	a5,-32(s0)
ffffffe000200948:	05c0006f          	j	ffffffe0002009a4 <buddy_alloc+0xe8>
        if (buddy.bitmap[LEFT_LEAF(index)] >= nrpages)
ffffffe00020094c:	0000a797          	auipc	a5,0xa
ffffffe000200950:	6d478793          	addi	a5,a5,1748 # ffffffe00020b020 <buddy>
ffffffe000200954:	0087b703          	ld	a4,8(a5)
ffffffe000200958:	fe843783          	ld	a5,-24(s0)
ffffffe00020095c:	00479793          	slli	a5,a5,0x4
ffffffe000200960:	00878793          	addi	a5,a5,8
ffffffe000200964:	00f707b3          	add	a5,a4,a5
ffffffe000200968:	0007b783          	ld	a5,0(a5)
ffffffe00020096c:	fc843703          	ld	a4,-56(s0)
ffffffe000200970:	00e7ec63          	bltu	a5,a4,ffffffe000200988 <buddy_alloc+0xcc>
            index = LEFT_LEAF(index);
ffffffe000200974:	fe843783          	ld	a5,-24(s0)
ffffffe000200978:	00179793          	slli	a5,a5,0x1
ffffffe00020097c:	00178793          	addi	a5,a5,1
ffffffe000200980:	fef43423          	sd	a5,-24(s0)
ffffffe000200984:	0140006f          	j	ffffffe000200998 <buddy_alloc+0xdc>
        else
            index = RIGHT_LEAF(index);
ffffffe000200988:	fe843783          	ld	a5,-24(s0)
ffffffe00020098c:	00178793          	addi	a5,a5,1
ffffffe000200990:	00179793          	slli	a5,a5,0x1
ffffffe000200994:	fef43423          	sd	a5,-24(s0)
    for(node_size = buddy.size; node_size != nrpages; node_size /= 2 ) {
ffffffe000200998:	fe043783          	ld	a5,-32(s0)
ffffffe00020099c:	0017d793          	srli	a5,a5,0x1
ffffffe0002009a0:	fef43023          	sd	a5,-32(s0)
ffffffe0002009a4:	fe043703          	ld	a4,-32(s0)
ffffffe0002009a8:	fc843783          	ld	a5,-56(s0)
ffffffe0002009ac:	faf710e3          	bne	a4,a5,ffffffe00020094c <buddy_alloc+0x90>
    }

    buddy.bitmap[index] = 0;
ffffffe0002009b0:	0000a797          	auipc	a5,0xa
ffffffe0002009b4:	67078793          	addi	a5,a5,1648 # ffffffe00020b020 <buddy>
ffffffe0002009b8:	0087b703          	ld	a4,8(a5)
ffffffe0002009bc:	fe843783          	ld	a5,-24(s0)
ffffffe0002009c0:	00379793          	slli	a5,a5,0x3
ffffffe0002009c4:	00f707b3          	add	a5,a4,a5
ffffffe0002009c8:	0007b023          	sd	zero,0(a5)

    pfn = (index + 1) * node_size - buddy.size;
ffffffe0002009cc:	fe843783          	ld	a5,-24(s0)
ffffffe0002009d0:	00178713          	addi	a4,a5,1
ffffffe0002009d4:	fe043783          	ld	a5,-32(s0)
ffffffe0002009d8:	02f70733          	mul	a4,a4,a5
ffffffe0002009dc:	0000a797          	auipc	a5,0xa
ffffffe0002009e0:	64478793          	addi	a5,a5,1604 # ffffffe00020b020 <buddy>
ffffffe0002009e4:	0007b783          	ld	a5,0(a5)
ffffffe0002009e8:	40f707b3          	sub	a5,a4,a5
ffffffe0002009ec:	fcf43c23          	sd	a5,-40(s0)
    buddy.ref_cnt[pfn] = 1;
ffffffe0002009f0:	0000a797          	auipc	a5,0xa
ffffffe0002009f4:	63078793          	addi	a5,a5,1584 # ffffffe00020b020 <buddy>
ffffffe0002009f8:	0107b703          	ld	a4,16(a5)
ffffffe0002009fc:	fd843783          	ld	a5,-40(s0)
ffffffe000200a00:	00379793          	slli	a5,a5,0x3
ffffffe000200a04:	00f707b3          	add	a5,a4,a5
ffffffe000200a08:	00100713          	li	a4,1
ffffffe000200a0c:	00e7b023          	sd	a4,0(a5)

    while (index) {
ffffffe000200a10:	0800006f          	j	ffffffe000200a90 <buddy_alloc+0x1d4>
        index = PARENT(index);
ffffffe000200a14:	fe843783          	ld	a5,-24(s0)
ffffffe000200a18:	00178793          	addi	a5,a5,1
ffffffe000200a1c:	0017d793          	srli	a5,a5,0x1
ffffffe000200a20:	fff78793          	addi	a5,a5,-1
ffffffe000200a24:	fef43423          	sd	a5,-24(s0)
        buddy.bitmap[index] = 
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe000200a28:	0000a797          	auipc	a5,0xa
ffffffe000200a2c:	5f878793          	addi	a5,a5,1528 # ffffffe00020b020 <buddy>
ffffffe000200a30:	0087b703          	ld	a4,8(a5)
ffffffe000200a34:	fe843783          	ld	a5,-24(s0)
ffffffe000200a38:	00178793          	addi	a5,a5,1
ffffffe000200a3c:	00479793          	slli	a5,a5,0x4
ffffffe000200a40:	00f707b3          	add	a5,a4,a5
ffffffe000200a44:	0007b603          	ld	a2,0(a5)
ffffffe000200a48:	0000a797          	auipc	a5,0xa
ffffffe000200a4c:	5d878793          	addi	a5,a5,1496 # ffffffe00020b020 <buddy>
ffffffe000200a50:	0087b703          	ld	a4,8(a5)
ffffffe000200a54:	fe843783          	ld	a5,-24(s0)
ffffffe000200a58:	00479793          	slli	a5,a5,0x4
ffffffe000200a5c:	00878793          	addi	a5,a5,8
ffffffe000200a60:	00f707b3          	add	a5,a4,a5
ffffffe000200a64:	0007b703          	ld	a4,0(a5)
        buddy.bitmap[index] = 
ffffffe000200a68:	0000a797          	auipc	a5,0xa
ffffffe000200a6c:	5b878793          	addi	a5,a5,1464 # ffffffe00020b020 <buddy>
ffffffe000200a70:	0087b683          	ld	a3,8(a5)
ffffffe000200a74:	fe843783          	ld	a5,-24(s0)
ffffffe000200a78:	00379793          	slli	a5,a5,0x3
ffffffe000200a7c:	00f686b3          	add	a3,a3,a5
            MAX(buddy.bitmap[LEFT_LEAF(index)], buddy.bitmap[RIGHT_LEAF(index)]);
ffffffe000200a80:	00060793          	mv	a5,a2
ffffffe000200a84:	00e7f463          	bgeu	a5,a4,ffffffe000200a8c <buddy_alloc+0x1d0>
ffffffe000200a88:	00070793          	mv	a5,a4
        buddy.bitmap[index] = 
ffffffe000200a8c:	00f6b023          	sd	a5,0(a3)
    while (index) {
ffffffe000200a90:	fe843783          	ld	a5,-24(s0)
ffffffe000200a94:	f80790e3          	bnez	a5,ffffffe000200a14 <buddy_alloc+0x158>
    }
    
    return pfn;
ffffffe000200a98:	fd843783          	ld	a5,-40(s0)
}
ffffffe000200a9c:	00078513          	mv	a0,a5
ffffffe000200aa0:	03813083          	ld	ra,56(sp)
ffffffe000200aa4:	03013403          	ld	s0,48(sp)
ffffffe000200aa8:	04010113          	addi	sp,sp,64
ffffffe000200aac:	00008067          	ret

ffffffe000200ab0 <get_page>:

uint64_t get_page(void *va) {
ffffffe000200ab0:	fd010113          	addi	sp,sp,-48
ffffffe000200ab4:	02113423          	sd	ra,40(sp)
ffffffe000200ab8:	02813023          	sd	s0,32(sp)
ffffffe000200abc:	03010413          	addi	s0,sp,48
ffffffe000200ac0:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = PHYS2PFN(VA2PA((uint64_t)va));
ffffffe000200ac4:	fd843703          	ld	a4,-40(s0)
ffffffe000200ac8:	00100793          	li	a5,1
ffffffe000200acc:	02579793          	slli	a5,a5,0x25
ffffffe000200ad0:	00f707b3          	add	a5,a4,a5
ffffffe000200ad4:	00c7d793          	srli	a5,a5,0xc
ffffffe000200ad8:	fef43423          	sd	a5,-24(s0)
    // check if the page is already allocated
    if (buddy.ref_cnt[pfn] == 0) {
ffffffe000200adc:	0000a797          	auipc	a5,0xa
ffffffe000200ae0:	54478793          	addi	a5,a5,1348 # ffffffe00020b020 <buddy>
ffffffe000200ae4:	0107b703          	ld	a4,16(a5)
ffffffe000200ae8:	fe843783          	ld	a5,-24(s0)
ffffffe000200aec:	00379793          	slli	a5,a5,0x3
ffffffe000200af0:	00f707b3          	add	a5,a4,a5
ffffffe000200af4:	0007b783          	ld	a5,0(a5)
ffffffe000200af8:	00079663          	bnez	a5,ffffffe000200b04 <get_page+0x54>
        return 1;
ffffffe000200afc:	00100793          	li	a5,1
ffffffe000200b00:	0100006f          	j	ffffffe000200b10 <get_page+0x60>
    }
    page_ref_inc(pfn);
ffffffe000200b04:	fe843503          	ld	a0,-24(s0)
ffffffe000200b08:	aedff0ef          	jal	ra,ffffffe0002005f4 <page_ref_inc>
    return 0;
ffffffe000200b0c:	00000793          	li	a5,0
}
ffffffe000200b10:	00078513          	mv	a0,a5
ffffffe000200b14:	02813083          	ld	ra,40(sp)
ffffffe000200b18:	02013403          	ld	s0,32(sp)
ffffffe000200b1c:	03010113          	addi	sp,sp,48
ffffffe000200b20:	00008067          	ret

ffffffe000200b24 <get_page_refcnt>:

uint64_t get_page_refcnt(void *va) {
ffffffe000200b24:	fd010113          	addi	sp,sp,-48
ffffffe000200b28:	02813423          	sd	s0,40(sp)
ffffffe000200b2c:	03010413          	addi	s0,sp,48
ffffffe000200b30:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = PHYS2PFN(VA2PA((uint64_t)va));
ffffffe000200b34:	fd843703          	ld	a4,-40(s0)
ffffffe000200b38:	00100793          	li	a5,1
ffffffe000200b3c:	02579793          	slli	a5,a5,0x25
ffffffe000200b40:	00f707b3          	add	a5,a4,a5
ffffffe000200b44:	00c7d793          	srli	a5,a5,0xc
ffffffe000200b48:	fef43423          	sd	a5,-24(s0)
    uint64_t a = buddy.ref_cnt[pfn];
ffffffe000200b4c:	0000a797          	auipc	a5,0xa
ffffffe000200b50:	4d478793          	addi	a5,a5,1236 # ffffffe00020b020 <buddy>
ffffffe000200b54:	0107b703          	ld	a4,16(a5)
ffffffe000200b58:	fe843783          	ld	a5,-24(s0)
ffffffe000200b5c:	00379793          	slli	a5,a5,0x3
ffffffe000200b60:	00f707b3          	add	a5,a4,a5
ffffffe000200b64:	0007b783          	ld	a5,0(a5)
ffffffe000200b68:	fef43023          	sd	a5,-32(s0)
    uint64_t m;
    return buddy.ref_cnt[pfn];
ffffffe000200b6c:	0000a797          	auipc	a5,0xa
ffffffe000200b70:	4b478793          	addi	a5,a5,1204 # ffffffe00020b020 <buddy>
ffffffe000200b74:	0107b703          	ld	a4,16(a5)
ffffffe000200b78:	fe843783          	ld	a5,-24(s0)
ffffffe000200b7c:	00379793          	slli	a5,a5,0x3
ffffffe000200b80:	00f707b3          	add	a5,a4,a5
ffffffe000200b84:	0007b783          	ld	a5,0(a5)
}
ffffffe000200b88:	00078513          	mv	a0,a5
ffffffe000200b8c:	02813403          	ld	s0,40(sp)
ffffffe000200b90:	03010113          	addi	sp,sp,48
ffffffe000200b94:	00008067          	ret

ffffffe000200b98 <put_page>:

void put_page(void *va) {
ffffffe000200b98:	fd010113          	addi	sp,sp,-48
ffffffe000200b9c:	02113423          	sd	ra,40(sp)
ffffffe000200ba0:	02813023          	sd	s0,32(sp)
ffffffe000200ba4:	03010413          	addi	s0,sp,48
ffffffe000200ba8:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = PHYS2PFN(VA2PA((uint64_t)va));
ffffffe000200bac:	fd843703          	ld	a4,-40(s0)
ffffffe000200bb0:	00100793          	li	a5,1
ffffffe000200bb4:	02579793          	slli	a5,a5,0x25
ffffffe000200bb8:	00f707b3          	add	a5,a4,a5
ffffffe000200bbc:	00c7d793          	srli	a5,a5,0xc
ffffffe000200bc0:	fef43423          	sd	a5,-24(s0)
    page_ref_dec(pfn);
ffffffe000200bc4:	fe843503          	ld	a0,-24(s0)
ffffffe000200bc8:	a71ff0ef          	jal	ra,ffffffe000200638 <page_ref_dec>
}
ffffffe000200bcc:	00000013          	nop
ffffffe000200bd0:	02813083          	ld	ra,40(sp)
ffffffe000200bd4:	02013403          	ld	s0,32(sp)
ffffffe000200bd8:	03010113          	addi	sp,sp,48
ffffffe000200bdc:	00008067          	ret

ffffffe000200be0 <alloc_pages>:

void *alloc_pages(uint64_t nrpages) {
ffffffe000200be0:	fd010113          	addi	sp,sp,-48
ffffffe000200be4:	02113423          	sd	ra,40(sp)
ffffffe000200be8:	02813023          	sd	s0,32(sp)
ffffffe000200bec:	03010413          	addi	s0,sp,48
ffffffe000200bf0:	fca43c23          	sd	a0,-40(s0)
    uint64_t pfn = buddy_alloc(nrpages);
ffffffe000200bf4:	fd843503          	ld	a0,-40(s0)
ffffffe000200bf8:	cc5ff0ef          	jal	ra,ffffffe0002008bc <buddy_alloc>
ffffffe000200bfc:	fea43423          	sd	a0,-24(s0)
    if (pfn == 0)
ffffffe000200c00:	fe843783          	ld	a5,-24(s0)
ffffffe000200c04:	00079663          	bnez	a5,ffffffe000200c10 <alloc_pages+0x30>
        return 0;
ffffffe000200c08:	00000793          	li	a5,0
ffffffe000200c0c:	0180006f          	j	ffffffe000200c24 <alloc_pages+0x44>
    return (void *)(PA2VA(PFN2PHYS(pfn)));
ffffffe000200c10:	fe843783          	ld	a5,-24(s0)
ffffffe000200c14:	00c79713          	slli	a4,a5,0xc
ffffffe000200c18:	fff00793          	li	a5,-1
ffffffe000200c1c:	02579793          	slli	a5,a5,0x25
ffffffe000200c20:	00f707b3          	add	a5,a4,a5
}
ffffffe000200c24:	00078513          	mv	a0,a5
ffffffe000200c28:	02813083          	ld	ra,40(sp)
ffffffe000200c2c:	02013403          	ld	s0,32(sp)
ffffffe000200c30:	03010113          	addi	sp,sp,48
ffffffe000200c34:	00008067          	ret

ffffffe000200c38 <alloc_page>:

void *alloc_page() {
ffffffe000200c38:	ff010113          	addi	sp,sp,-16
ffffffe000200c3c:	00113423          	sd	ra,8(sp)
ffffffe000200c40:	00813023          	sd	s0,0(sp)
ffffffe000200c44:	01010413          	addi	s0,sp,16
    return alloc_pages(1);
ffffffe000200c48:	00100513          	li	a0,1
ffffffe000200c4c:	f95ff0ef          	jal	ra,ffffffe000200be0 <alloc_pages>
ffffffe000200c50:	00050793          	mv	a5,a0
}
ffffffe000200c54:	00078513          	mv	a0,a5
ffffffe000200c58:	00813083          	ld	ra,8(sp)
ffffffe000200c5c:	00013403          	ld	s0,0(sp)
ffffffe000200c60:	01010113          	addi	sp,sp,16
ffffffe000200c64:	00008067          	ret

ffffffe000200c68 <free_pages>:

void free_pages(void *va) {
ffffffe000200c68:	fe010113          	addi	sp,sp,-32
ffffffe000200c6c:	00113c23          	sd	ra,24(sp)
ffffffe000200c70:	00813823          	sd	s0,16(sp)
ffffffe000200c74:	02010413          	addi	s0,sp,32
ffffffe000200c78:	fea43423          	sd	a0,-24(s0)
    buddy_free(PHYS2PFN(VA2PA((uint64_t)va)));
ffffffe000200c7c:	fe843703          	ld	a4,-24(s0)
ffffffe000200c80:	00100793          	li	a5,1
ffffffe000200c84:	02579793          	slli	a5,a5,0x25
ffffffe000200c88:	00f707b3          	add	a5,a4,a5
ffffffe000200c8c:	00c7d793          	srli	a5,a5,0xc
ffffffe000200c90:	00078513          	mv	a0,a5
ffffffe000200c94:	a71ff0ef          	jal	ra,ffffffe000200704 <buddy_free>
}
ffffffe000200c98:	00000013          	nop
ffffffe000200c9c:	01813083          	ld	ra,24(sp)
ffffffe000200ca0:	01013403          	ld	s0,16(sp)
ffffffe000200ca4:	02010113          	addi	sp,sp,32
ffffffe000200ca8:	00008067          	ret

ffffffe000200cac <kalloc>:

void *kalloc() {
ffffffe000200cac:	ff010113          	addi	sp,sp,-16
ffffffe000200cb0:	00113423          	sd	ra,8(sp)
ffffffe000200cb4:	00813023          	sd	s0,0(sp)
ffffffe000200cb8:	01010413          	addi	s0,sp,16
    // r = kmem.freelist;
    // kmem.freelist = r->next;
    
    // memset((void *)r, 0x0, PGSIZE);
    // return (void *)r;
    return alloc_page();
ffffffe000200cbc:	f7dff0ef          	jal	ra,ffffffe000200c38 <alloc_page>
ffffffe000200cc0:	00050793          	mv	a5,a0
}
ffffffe000200cc4:	00078513          	mv	a0,a5
ffffffe000200cc8:	00813083          	ld	ra,8(sp)
ffffffe000200ccc:	00013403          	ld	s0,0(sp)
ffffffe000200cd0:	01010113          	addi	sp,sp,16
ffffffe000200cd4:	00008067          	ret

ffffffe000200cd8 <kfree>:

void kfree(void *addr) {
ffffffe000200cd8:	fe010113          	addi	sp,sp,-32
ffffffe000200cdc:	00113c23          	sd	ra,24(sp)
ffffffe000200ce0:	00813823          	sd	s0,16(sp)
ffffffe000200ce4:	02010413          	addi	s0,sp,32
ffffffe000200ce8:	fea43423          	sd	a0,-24(s0)
    // memset(addr, 0x0, (uint64_t)PGSIZE);

    // r = (struct run *)addr;
    // r->next = kmem.freelist;
    // kmem.freelist = r;
    free_pages(addr);
ffffffe000200cec:	fe843503          	ld	a0,-24(s0)
ffffffe000200cf0:	f79ff0ef          	jal	ra,ffffffe000200c68 <free_pages>

    return;
ffffffe000200cf4:	00000013          	nop
}
ffffffe000200cf8:	01813083          	ld	ra,24(sp)
ffffffe000200cfc:	01013403          	ld	s0,16(sp)
ffffffe000200d00:	02010113          	addi	sp,sp,32
ffffffe000200d04:	00008067          	ret

ffffffe000200d08 <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe000200d08:	fd010113          	addi	sp,sp,-48
ffffffe000200d0c:	02113423          	sd	ra,40(sp)
ffffffe000200d10:	02813023          	sd	s0,32(sp)
ffffffe000200d14:	03010413          	addi	s0,sp,48
ffffffe000200d18:	fca43c23          	sd	a0,-40(s0)
ffffffe000200d1c:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe000200d20:	fd843703          	ld	a4,-40(s0)
ffffffe000200d24:	000017b7          	lui	a5,0x1
ffffffe000200d28:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000200d2c:	00f70733          	add	a4,a4,a5
ffffffe000200d30:	fffff7b7          	lui	a5,0xfffff
ffffffe000200d34:	00f777b3          	and	a5,a4,a5
ffffffe000200d38:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200d3c:	01c0006f          	j	ffffffe000200d58 <kfreerange+0x50>
        kfree((void *)addr);
ffffffe000200d40:	fe843503          	ld	a0,-24(s0)
ffffffe000200d44:	f95ff0ef          	jal	ra,ffffffe000200cd8 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe000200d48:	fe843703          	ld	a4,-24(s0)
ffffffe000200d4c:	000017b7          	lui	a5,0x1
ffffffe000200d50:	00f707b3          	add	a5,a4,a5
ffffffe000200d54:	fef43423          	sd	a5,-24(s0)
ffffffe000200d58:	fe843703          	ld	a4,-24(s0)
ffffffe000200d5c:	000017b7          	lui	a5,0x1
ffffffe000200d60:	00f70733          	add	a4,a4,a5
ffffffe000200d64:	fd043783          	ld	a5,-48(s0)
ffffffe000200d68:	fce7fce3          	bgeu	a5,a4,ffffffe000200d40 <kfreerange+0x38>
    }
}
ffffffe000200d6c:	00000013          	nop
ffffffe000200d70:	00000013          	nop
ffffffe000200d74:	02813083          	ld	ra,40(sp)
ffffffe000200d78:	02013403          	ld	s0,32(sp)
ffffffe000200d7c:	03010113          	addi	sp,sp,48
ffffffe000200d80:	00008067          	ret

ffffffe000200d84 <mm_init>:

void mm_init(void) {
ffffffe000200d84:	ff010113          	addi	sp,sp,-16
ffffffe000200d88:	00113423          	sd	ra,8(sp)
ffffffe000200d8c:	00813023          	sd	s0,0(sp)
ffffffe000200d90:	01010413          	addi	s0,sp,16
    // kfreerange(_ekernel, (char *)PHY_END+PA2VA_OFFSET);
    buddy_init();
ffffffe000200d94:	e44ff0ef          	jal	ra,ffffffe0002003d8 <buddy_init>
    printk("...mm_init done!\n");
ffffffe000200d98:	00004517          	auipc	a0,0x4
ffffffe000200d9c:	2b850513          	addi	a0,a0,696 # ffffffe000205050 <__func__.3+0x50>
ffffffe000200da0:	770030ef          	jal	ra,ffffffe000204510 <printk>
}
ffffffe000200da4:	00000013          	nop
ffffffe000200da8:	00813083          	ld	ra,8(sp)
ffffffe000200dac:	00013403          	ld	s0,0(sp)
ffffffe000200db0:	01010113          	addi	sp,sp,16
ffffffe000200db4:	00008067          	ret

ffffffe000200db8 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe000200db8:	fd010113          	addi	sp,sp,-48
ffffffe000200dbc:	02113423          	sd	ra,40(sp)
ffffffe000200dc0:	02813023          	sd	s0,32(sp)
ffffffe000200dc4:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
ffffffe000200dc8:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000200dcc:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe000200dd0:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe000200dd4:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe000200dd8:	fff00793          	li	a5,-1
ffffffe000200ddc:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200de0:	fe442783          	lw	a5,-28(s0)
ffffffe000200de4:	0007871b          	sext.w	a4,a5
ffffffe000200de8:	fff00793          	li	a5,-1
ffffffe000200dec:	00f70e63          	beq	a4,a5,ffffffe000200e08 <dummy+0x50>
ffffffe000200df0:	0000a797          	auipc	a5,0xa
ffffffe000200df4:	22078793          	addi	a5,a5,544 # ffffffe00020b010 <current>
ffffffe000200df8:	0007b783          	ld	a5,0(a5)
ffffffe000200dfc:	0087b703          	ld	a4,8(a5)
ffffffe000200e00:	fe442783          	lw	a5,-28(s0)
ffffffe000200e04:	fcf70ee3          	beq	a4,a5,ffffffe000200de0 <dummy+0x28>
ffffffe000200e08:	0000a797          	auipc	a5,0xa
ffffffe000200e0c:	20878793          	addi	a5,a5,520 # ffffffe00020b010 <current>
ffffffe000200e10:	0007b783          	ld	a5,0(a5)
ffffffe000200e14:	0087b783          	ld	a5,8(a5)
ffffffe000200e18:	fc0784e3          	beqz	a5,ffffffe000200de0 <dummy+0x28>
            if (current->counter == 1) {
ffffffe000200e1c:	0000a797          	auipc	a5,0xa
ffffffe000200e20:	1f478793          	addi	a5,a5,500 # ffffffe00020b010 <current>
ffffffe000200e24:	0007b783          	ld	a5,0(a5)
ffffffe000200e28:	0087b703          	ld	a4,8(a5)
ffffffe000200e2c:	00100793          	li	a5,1
ffffffe000200e30:	00f71e63          	bne	a4,a5,ffffffe000200e4c <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe000200e34:	0000a797          	auipc	a5,0xa
ffffffe000200e38:	1dc78793          	addi	a5,a5,476 # ffffffe00020b010 <current>
ffffffe000200e3c:	0007b783          	ld	a5,0(a5)
ffffffe000200e40:	0087b703          	ld	a4,8(a5)
ffffffe000200e44:	fff70713          	addi	a4,a4,-1
ffffffe000200e48:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe000200e4c:	0000a797          	auipc	a5,0xa
ffffffe000200e50:	1c478793          	addi	a5,a5,452 # ffffffe00020b010 <current>
ffffffe000200e54:	0007b783          	ld	a5,0(a5)
ffffffe000200e58:	0087b783          	ld	a5,8(a5)
ffffffe000200e5c:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe000200e60:	fe843783          	ld	a5,-24(s0)
ffffffe000200e64:	00178713          	addi	a4,a5,1
ffffffe000200e68:	fd843783          	ld	a5,-40(s0)
ffffffe000200e6c:	02f777b3          	remu	a5,a4,a5
ffffffe000200e70:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe000200e74:	0000a797          	auipc	a5,0xa
ffffffe000200e78:	19c78793          	addi	a5,a5,412 # ffffffe00020b010 <current>
ffffffe000200e7c:	0007b783          	ld	a5,0(a5)
ffffffe000200e80:	0187b783          	ld	a5,24(a5)
ffffffe000200e84:	fe843603          	ld	a2,-24(s0)
ffffffe000200e88:	00078593          	mv	a1,a5
ffffffe000200e8c:	00004517          	auipc	a0,0x4
ffffffe000200e90:	1ec50513          	addi	a0,a0,492 # ffffffe000205078 <__func__.0+0x10>
ffffffe000200e94:	67c030ef          	jal	ra,ffffffe000204510 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe000200e98:	f49ff06f          	j	ffffffe000200de0 <dummy+0x28>

ffffffe000200e9c <switch_to>:
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
ffffffe000200e9c:	fd010113          	addi	sp,sp,-48
ffffffe000200ea0:	02113423          	sd	ra,40(sp)
ffffffe000200ea4:	02813023          	sd	s0,32(sp)
ffffffe000200ea8:	03010413          	addi	s0,sp,48
ffffffe000200eac:	fca43c23          	sd	a0,-40(s0)
    if(current == next) {
ffffffe000200eb0:	0000a797          	auipc	a5,0xa
ffffffe000200eb4:	16078793          	addi	a5,a5,352 # ffffffe00020b010 <current>
ffffffe000200eb8:	0007b783          	ld	a5,0(a5)
ffffffe000200ebc:	fd843703          	ld	a4,-40(s0)
ffffffe000200ec0:	06f70c63          	beq	a4,a5,ffffffe000200f38 <switch_to+0x9c>
        return;
    }else{
        printk("switch_to: %d -> %d\n", current->pid, next->pid);
ffffffe000200ec4:	0000a797          	auipc	a5,0xa
ffffffe000200ec8:	14c78793          	addi	a5,a5,332 # ffffffe00020b010 <current>
ffffffe000200ecc:	0007b783          	ld	a5,0(a5)
ffffffe000200ed0:	0187b703          	ld	a4,24(a5)
ffffffe000200ed4:	fd843783          	ld	a5,-40(s0)
ffffffe000200ed8:	0187b783          	ld	a5,24(a5)
ffffffe000200edc:	00078613          	mv	a2,a5
ffffffe000200ee0:	00070593          	mv	a1,a4
ffffffe000200ee4:	00004517          	auipc	a0,0x4
ffffffe000200ee8:	1c450513          	addi	a0,a0,452 # ffffffe0002050a8 <__func__.0+0x40>
ffffffe000200eec:	624030ef          	jal	ra,ffffffe000204510 <printk>
        struct task_struct *prev = current;
ffffffe000200ef0:	0000a797          	auipc	a5,0xa
ffffffe000200ef4:	12078793          	addi	a5,a5,288 # ffffffe00020b010 <current>
ffffffe000200ef8:	0007b783          	ld	a5,0(a5)
ffffffe000200efc:	fef43423          	sd	a5,-24(s0)
        current = next;
ffffffe000200f00:	0000a797          	auipc	a5,0xa
ffffffe000200f04:	11078793          	addi	a5,a5,272 # ffffffe00020b010 <current>
ffffffe000200f08:	fd843703          	ld	a4,-40(s0)
ffffffe000200f0c:	00e7b023          	sd	a4,0(a5)
        printk("switch ing\n");
ffffffe000200f10:	00004517          	auipc	a0,0x4
ffffffe000200f14:	1b050513          	addi	a0,a0,432 # ffffffe0002050c0 <__func__.0+0x58>
ffffffe000200f18:	5f8030ef          	jal	ra,ffffffe000204510 <printk>
        __switch_to(prev, next);
ffffffe000200f1c:	fd843583          	ld	a1,-40(s0)
ffffffe000200f20:	fe843503          	ld	a0,-24(s0)
ffffffe000200f24:	accff0ef          	jal	ra,ffffffe0002001f0 <__switch_to>
        printk("switch done\n");
ffffffe000200f28:	00004517          	auipc	a0,0x4
ffffffe000200f2c:	1a850513          	addi	a0,a0,424 # ffffffe0002050d0 <__func__.0+0x68>
ffffffe000200f30:	5e0030ef          	jal	ra,ffffffe000204510 <printk>
ffffffe000200f34:	0080006f          	j	ffffffe000200f3c <switch_to+0xa0>
        return;
ffffffe000200f38:	00000013          	nop
    }
}
ffffffe000200f3c:	02813083          	ld	ra,40(sp)
ffffffe000200f40:	02013403          	ld	s0,32(sp)
ffffffe000200f44:	03010113          	addi	sp,sp,48
ffffffe000200f48:	00008067          	ret

ffffffe000200f4c <do_timer>:

void do_timer() {
ffffffe000200f4c:	ff010113          	addi	sp,sp,-16
ffffffe000200f50:	00113423          	sd	ra,8(sp)
ffffffe000200f54:	00813023          	sd	s0,0(sp)
ffffffe000200f58:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    printk("do_timer: current->pid = %d\n", current->pid);
ffffffe000200f5c:	0000a797          	auipc	a5,0xa
ffffffe000200f60:	0b478793          	addi	a5,a5,180 # ffffffe00020b010 <current>
ffffffe000200f64:	0007b783          	ld	a5,0(a5)
ffffffe000200f68:	0187b783          	ld	a5,24(a5)
ffffffe000200f6c:	00078593          	mv	a1,a5
ffffffe000200f70:	00004517          	auipc	a0,0x4
ffffffe000200f74:	17050513          	addi	a0,a0,368 # ffffffe0002050e0 <__func__.0+0x78>
ffffffe000200f78:	598030ef          	jal	ra,ffffffe000204510 <printk>
    // YOUR CODE HERE
    if (current == idle || current->counter == 0) {
ffffffe000200f7c:	0000a797          	auipc	a5,0xa
ffffffe000200f80:	09478793          	addi	a5,a5,148 # ffffffe00020b010 <current>
ffffffe000200f84:	0007b703          	ld	a4,0(a5)
ffffffe000200f88:	0000a797          	auipc	a5,0xa
ffffffe000200f8c:	08078793          	addi	a5,a5,128 # ffffffe00020b008 <idle>
ffffffe000200f90:	0007b783          	ld	a5,0(a5)
ffffffe000200f94:	00f70c63          	beq	a4,a5,ffffffe000200fac <do_timer+0x60>
ffffffe000200f98:	0000a797          	auipc	a5,0xa
ffffffe000200f9c:	07878793          	addi	a5,a5,120 # ffffffe00020b010 <current>
ffffffe000200fa0:	0007b783          	ld	a5,0(a5)
ffffffe000200fa4:	0087b783          	ld	a5,8(a5)
ffffffe000200fa8:	00079c63          	bnez	a5,ffffffe000200fc0 <do_timer+0x74>
        printk("do_timer: schedule\n");
ffffffe000200fac:	00004517          	auipc	a0,0x4
ffffffe000200fb0:	15450513          	addi	a0,a0,340 # ffffffe000205100 <__func__.0+0x98>
ffffffe000200fb4:	55c030ef          	jal	ra,ffffffe000204510 <printk>
        schedule();
ffffffe000200fb8:	058000ef          	jal	ra,ffffffe000201010 <schedule>
        if (current->counter == 0) {
            printk("do_timer: schedule2\n");
            schedule();
        }
    }
}
ffffffe000200fbc:	0400006f          	j	ffffffe000200ffc <do_timer+0xb0>
        current->counter --;
ffffffe000200fc0:	0000a797          	auipc	a5,0xa
ffffffe000200fc4:	05078793          	addi	a5,a5,80 # ffffffe00020b010 <current>
ffffffe000200fc8:	0007b783          	ld	a5,0(a5)
ffffffe000200fcc:	0087b703          	ld	a4,8(a5)
ffffffe000200fd0:	fff70713          	addi	a4,a4,-1
ffffffe000200fd4:	00e7b423          	sd	a4,8(a5)
        if (current->counter == 0) {
ffffffe000200fd8:	0000a797          	auipc	a5,0xa
ffffffe000200fdc:	03878793          	addi	a5,a5,56 # ffffffe00020b010 <current>
ffffffe000200fe0:	0007b783          	ld	a5,0(a5)
ffffffe000200fe4:	0087b783          	ld	a5,8(a5)
ffffffe000200fe8:	00079a63          	bnez	a5,ffffffe000200ffc <do_timer+0xb0>
            printk("do_timer: schedule2\n");
ffffffe000200fec:	00004517          	auipc	a0,0x4
ffffffe000200ff0:	12c50513          	addi	a0,a0,300 # ffffffe000205118 <__func__.0+0xb0>
ffffffe000200ff4:	51c030ef          	jal	ra,ffffffe000204510 <printk>
            schedule();
ffffffe000200ff8:	018000ef          	jal	ra,ffffffe000201010 <schedule>
}
ffffffe000200ffc:	00000013          	nop
ffffffe000201000:	00813083          	ld	ra,8(sp)
ffffffe000201004:	00013403          	ld	s0,0(sp)
ffffffe000201008:	01010113          	addi	sp,sp,16
ffffffe00020100c:	00008067          	ret

ffffffe000201010 <schedule>:

void schedule() {
ffffffe000201010:	fe010113          	addi	sp,sp,-32
ffffffe000201014:	00113c23          	sd	ra,24(sp)
ffffffe000201018:	00813823          	sd	s0,16(sp)
ffffffe00020101c:	02010413          	addi	s0,sp,32
    // YOUR CODE HERE
    int maxCounter = -1;
ffffffe000201020:	fff00793          	li	a5,-1
ffffffe000201024:	fef42623          	sw	a5,-20(s0)
    int index = -1;
ffffffe000201028:	fff00793          	li	a5,-1
ffffffe00020102c:	fef42423          	sw	a5,-24(s0)
    for (int i = 1; i < nr_tasks; ++i) {
ffffffe000201030:	00100793          	li	a5,1
ffffffe000201034:	fef42223          	sw	a5,-28(s0)
ffffffe000201038:	0dc0006f          	j	ffffffe000201114 <schedule+0x104>
        printk("schedule: %d -> %d\n", task[i]->pid, task[i] -> counter);
ffffffe00020103c:	0000a717          	auipc	a4,0xa
ffffffe000201040:	ffc70713          	addi	a4,a4,-4 # ffffffe00020b038 <task>
ffffffe000201044:	fe442783          	lw	a5,-28(s0)
ffffffe000201048:	00379793          	slli	a5,a5,0x3
ffffffe00020104c:	00f707b3          	add	a5,a4,a5
ffffffe000201050:	0007b783          	ld	a5,0(a5)
ffffffe000201054:	0187b683          	ld	a3,24(a5)
ffffffe000201058:	0000a717          	auipc	a4,0xa
ffffffe00020105c:	fe070713          	addi	a4,a4,-32 # ffffffe00020b038 <task>
ffffffe000201060:	fe442783          	lw	a5,-28(s0)
ffffffe000201064:	00379793          	slli	a5,a5,0x3
ffffffe000201068:	00f707b3          	add	a5,a4,a5
ffffffe00020106c:	0007b783          	ld	a5,0(a5)
ffffffe000201070:	0087b783          	ld	a5,8(a5)
ffffffe000201074:	00078613          	mv	a2,a5
ffffffe000201078:	00068593          	mv	a1,a3
ffffffe00020107c:	00004517          	auipc	a0,0x4
ffffffe000201080:	0b450513          	addi	a0,a0,180 # ffffffe000205130 <__func__.0+0xc8>
ffffffe000201084:	48c030ef          	jal	ra,ffffffe000204510 <printk>
        if (task[i]->state == TASK_RUNNING && (int)task[i]->counter > maxCounter) {
ffffffe000201088:	0000a717          	auipc	a4,0xa
ffffffe00020108c:	fb070713          	addi	a4,a4,-80 # ffffffe00020b038 <task>
ffffffe000201090:	fe442783          	lw	a5,-28(s0)
ffffffe000201094:	00379793          	slli	a5,a5,0x3
ffffffe000201098:	00f707b3          	add	a5,a4,a5
ffffffe00020109c:	0007b783          	ld	a5,0(a5)
ffffffe0002010a0:	0007b783          	ld	a5,0(a5)
ffffffe0002010a4:	06079263          	bnez	a5,ffffffe000201108 <schedule+0xf8>
ffffffe0002010a8:	0000a717          	auipc	a4,0xa
ffffffe0002010ac:	f9070713          	addi	a4,a4,-112 # ffffffe00020b038 <task>
ffffffe0002010b0:	fe442783          	lw	a5,-28(s0)
ffffffe0002010b4:	00379793          	slli	a5,a5,0x3
ffffffe0002010b8:	00f707b3          	add	a5,a4,a5
ffffffe0002010bc:	0007b783          	ld	a5,0(a5)
ffffffe0002010c0:	0087b783          	ld	a5,8(a5)
ffffffe0002010c4:	0007871b          	sext.w	a4,a5
ffffffe0002010c8:	fec42783          	lw	a5,-20(s0)
ffffffe0002010cc:	0007879b          	sext.w	a5,a5
ffffffe0002010d0:	02e7dc63          	bge	a5,a4,ffffffe000201108 <schedule+0xf8>
            printk("mamba\n");
ffffffe0002010d4:	00004517          	auipc	a0,0x4
ffffffe0002010d8:	07450513          	addi	a0,a0,116 # ffffffe000205148 <__func__.0+0xe0>
ffffffe0002010dc:	434030ef          	jal	ra,ffffffe000204510 <printk>
            maxCounter = task[i]->counter;
ffffffe0002010e0:	0000a717          	auipc	a4,0xa
ffffffe0002010e4:	f5870713          	addi	a4,a4,-168 # ffffffe00020b038 <task>
ffffffe0002010e8:	fe442783          	lw	a5,-28(s0)
ffffffe0002010ec:	00379793          	slli	a5,a5,0x3
ffffffe0002010f0:	00f707b3          	add	a5,a4,a5
ffffffe0002010f4:	0007b783          	ld	a5,0(a5)
ffffffe0002010f8:	0087b783          	ld	a5,8(a5)
ffffffe0002010fc:	fef42623          	sw	a5,-20(s0)
            index = i;
ffffffe000201100:	fe442783          	lw	a5,-28(s0)
ffffffe000201104:	fef42423          	sw	a5,-24(s0)
    for (int i = 1; i < nr_tasks; ++i) {
ffffffe000201108:	fe442783          	lw	a5,-28(s0)
ffffffe00020110c:	0017879b          	addiw	a5,a5,1
ffffffe000201110:	fef42223          	sw	a5,-28(s0)
ffffffe000201114:	fe442703          	lw	a4,-28(s0)
ffffffe000201118:	00005797          	auipc	a5,0x5
ffffffe00020111c:	ef878793          	addi	a5,a5,-264 # ffffffe000206010 <nr_tasks>
ffffffe000201120:	0007b783          	ld	a5,0(a5)
ffffffe000201124:	f0f76ce3          	bltu	a4,a5,ffffffe00020103c <schedule+0x2c>
        }
    }

    if (maxCounter == 0) {
ffffffe000201128:	fec42783          	lw	a5,-20(s0)
ffffffe00020112c:	0007879b          	sext.w	a5,a5
ffffffe000201130:	0c079e63          	bnez	a5,ffffffe00020120c <schedule+0x1fc>
        for (int i = 1; i < nr_tasks; ++i) {
ffffffe000201134:	00100793          	li	a5,1
ffffffe000201138:	fef42023          	sw	a5,-32(s0)
ffffffe00020113c:	0b40006f          	j	ffffffe0002011f0 <schedule+0x1e0>
            if (task[i]->state == TASK_RUNNING) {
ffffffe000201140:	0000a717          	auipc	a4,0xa
ffffffe000201144:	ef870713          	addi	a4,a4,-264 # ffffffe00020b038 <task>
ffffffe000201148:	fe042783          	lw	a5,-32(s0)
ffffffe00020114c:	00379793          	slli	a5,a5,0x3
ffffffe000201150:	00f707b3          	add	a5,a4,a5
ffffffe000201154:	0007b783          	ld	a5,0(a5)
ffffffe000201158:	0007b783          	ld	a5,0(a5)
ffffffe00020115c:	02079e63          	bnez	a5,ffffffe000201198 <schedule+0x188>
                task[i]->counter = task[i]->priority;
ffffffe000201160:	0000a717          	auipc	a4,0xa
ffffffe000201164:	ed870713          	addi	a4,a4,-296 # ffffffe00020b038 <task>
ffffffe000201168:	fe042783          	lw	a5,-32(s0)
ffffffe00020116c:	00379793          	slli	a5,a5,0x3
ffffffe000201170:	00f707b3          	add	a5,a4,a5
ffffffe000201174:	0007b703          	ld	a4,0(a5)
ffffffe000201178:	0000a697          	auipc	a3,0xa
ffffffe00020117c:	ec068693          	addi	a3,a3,-320 # ffffffe00020b038 <task>
ffffffe000201180:	fe042783          	lw	a5,-32(s0)
ffffffe000201184:	00379793          	slli	a5,a5,0x3
ffffffe000201188:	00f687b3          	add	a5,a3,a5
ffffffe00020118c:	0007b783          	ld	a5,0(a5)
ffffffe000201190:	01073703          	ld	a4,16(a4)
ffffffe000201194:	00e7b423          	sd	a4,8(a5)
            }
            printk("schedule2: %d -> %d\n", task[i]->pid, task[i] -> counter);
ffffffe000201198:	0000a717          	auipc	a4,0xa
ffffffe00020119c:	ea070713          	addi	a4,a4,-352 # ffffffe00020b038 <task>
ffffffe0002011a0:	fe042783          	lw	a5,-32(s0)
ffffffe0002011a4:	00379793          	slli	a5,a5,0x3
ffffffe0002011a8:	00f707b3          	add	a5,a4,a5
ffffffe0002011ac:	0007b783          	ld	a5,0(a5)
ffffffe0002011b0:	0187b683          	ld	a3,24(a5)
ffffffe0002011b4:	0000a717          	auipc	a4,0xa
ffffffe0002011b8:	e8470713          	addi	a4,a4,-380 # ffffffe00020b038 <task>
ffffffe0002011bc:	fe042783          	lw	a5,-32(s0)
ffffffe0002011c0:	00379793          	slli	a5,a5,0x3
ffffffe0002011c4:	00f707b3          	add	a5,a4,a5
ffffffe0002011c8:	0007b783          	ld	a5,0(a5)
ffffffe0002011cc:	0087b783          	ld	a5,8(a5)
ffffffe0002011d0:	00078613          	mv	a2,a5
ffffffe0002011d4:	00068593          	mv	a1,a3
ffffffe0002011d8:	00004517          	auipc	a0,0x4
ffffffe0002011dc:	f7850513          	addi	a0,a0,-136 # ffffffe000205150 <__func__.0+0xe8>
ffffffe0002011e0:	330030ef          	jal	ra,ffffffe000204510 <printk>
        for (int i = 1; i < nr_tasks; ++i) {
ffffffe0002011e4:	fe042783          	lw	a5,-32(s0)
ffffffe0002011e8:	0017879b          	addiw	a5,a5,1
ffffffe0002011ec:	fef42023          	sw	a5,-32(s0)
ffffffe0002011f0:	fe042703          	lw	a4,-32(s0)
ffffffe0002011f4:	00005797          	auipc	a5,0x5
ffffffe0002011f8:	e1c78793          	addi	a5,a5,-484 # ffffffe000206010 <nr_tasks>
ffffffe0002011fc:	0007b783          	ld	a5,0(a5)
ffffffe000201200:	f4f760e3          	bltu	a4,a5,ffffffe000201140 <schedule+0x130>
        }
        schedule();
ffffffe000201204:	e0dff0ef          	jal	ra,ffffffe000201010 <schedule>
    } else {
        switch_to(task[index]);
    }
}
ffffffe000201208:	0240006f          	j	ffffffe00020122c <schedule+0x21c>
        switch_to(task[index]);
ffffffe00020120c:	0000a717          	auipc	a4,0xa
ffffffe000201210:	e2c70713          	addi	a4,a4,-468 # ffffffe00020b038 <task>
ffffffe000201214:	fe842783          	lw	a5,-24(s0)
ffffffe000201218:	00379793          	slli	a5,a5,0x3
ffffffe00020121c:	00f707b3          	add	a5,a4,a5
ffffffe000201220:	0007b783          	ld	a5,0(a5)
ffffffe000201224:	00078513          	mv	a0,a5
ffffffe000201228:	c75ff0ef          	jal	ra,ffffffe000200e9c <switch_to>
}
ffffffe00020122c:	00000013          	nop
ffffffe000201230:	01813083          	ld	ra,24(sp)
ffffffe000201234:	01013403          	ld	s0,16(sp)
ffffffe000201238:	02010113          	addi	sp,sp,32
ffffffe00020123c:	00008067          	ret

ffffffe000201240 <task_init>:

//7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00

/*ELF*/

void task_init() {
ffffffe000201240:	fc010113          	addi	sp,sp,-64
ffffffe000201244:	02113c23          	sd	ra,56(sp)
ffffffe000201248:	02813823          	sd	s0,48(sp)
ffffffe00020124c:	04010413          	addi	s0,sp,64
    srand(2024);
ffffffe000201250:	7e800513          	li	a0,2024
ffffffe000201254:	33c030ef          	jal	ra,ffffffe000204590 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
ffffffe000201258:	a55ff0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe00020125c:	00050713          	mv	a4,a0
ffffffe000201260:	0000a797          	auipc	a5,0xa
ffffffe000201264:	da878793          	addi	a5,a5,-600 # ffffffe00020b008 <idle>
ffffffe000201268:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe00020126c:	0000a797          	auipc	a5,0xa
ffffffe000201270:	d9c78793          	addi	a5,a5,-612 # ffffffe00020b008 <idle>
ffffffe000201274:	0007b783          	ld	a5,0(a5)
ffffffe000201278:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe00020127c:	0000a797          	auipc	a5,0xa
ffffffe000201280:	d8c78793          	addi	a5,a5,-628 # ffffffe00020b008 <idle>
ffffffe000201284:	0007b783          	ld	a5,0(a5)
ffffffe000201288:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe00020128c:	0000a797          	auipc	a5,0xa
ffffffe000201290:	d7c78793          	addi	a5,a5,-644 # ffffffe00020b008 <idle>
ffffffe000201294:	0007b783          	ld	a5,0(a5)
ffffffe000201298:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe00020129c:	0000a797          	auipc	a5,0xa
ffffffe0002012a0:	d6c78793          	addi	a5,a5,-660 # ffffffe00020b008 <idle>
ffffffe0002012a4:	0007b783          	ld	a5,0(a5)
ffffffe0002012a8:	0007bc23          	sd	zero,24(a5)

    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe0002012ac:	0000a797          	auipc	a5,0xa
ffffffe0002012b0:	d5c78793          	addi	a5,a5,-676 # ffffffe00020b008 <idle>
ffffffe0002012b4:	0007b703          	ld	a4,0(a5)
ffffffe0002012b8:	0000a797          	auipc	a5,0xa
ffffffe0002012bc:	d5878793          	addi	a5,a5,-680 # ffffffe00020b010 <current>
ffffffe0002012c0:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe0002012c4:	0000a797          	auipc	a5,0xa
ffffffe0002012c8:	d4478793          	addi	a5,a5,-700 # ffffffe00020b008 <idle>
ffffffe0002012cc:	0007b703          	ld	a4,0(a5)
ffffffe0002012d0:	0000a797          	auipc	a5,0xa
ffffffe0002012d4:	d6878793          	addi	a5,a5,-664 # ffffffe00020b038 <task>
ffffffe0002012d8:	00e7b023          	sd	a4,0(a5)

    /* YOUR CODE HERE */

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    for (int i = 1; i < nr_tasks; i++){
ffffffe0002012dc:	00100793          	li	a5,1
ffffffe0002012e0:	fef42623          	sw	a5,-20(s0)
ffffffe0002012e4:	2040006f          	j	ffffffe0002014e8 <task_init+0x2a8>
        struct task_struct *ptask = (struct task_struct*)kalloc();
ffffffe0002012e8:	9c5ff0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe0002012ec:	fca43c23          	sd	a0,-40(s0)
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
        ptask->state = TASK_RUNNING;
ffffffe0002012f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002012f4:	0007b023          	sd	zero,0(a5)
        ptask->counter = 0;
ffffffe0002012f8:	fd843783          	ld	a5,-40(s0)
ffffffe0002012fc:	0007b423          	sd	zero,8(a5)
        ptask->priority = (uint64_t)rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
ffffffe000201300:	2d4030ef          	jal	ra,ffffffe0002045d4 <rand>
ffffffe000201304:	00050793          	mv	a5,a0
ffffffe000201308:	00078713          	mv	a4,a5
ffffffe00020130c:	00a00793          	li	a5,10
ffffffe000201310:	02f777b3          	remu	a5,a4,a5
ffffffe000201314:	00178713          	addi	a4,a5,1
ffffffe000201318:	fd843783          	ld	a5,-40(s0)
ffffffe00020131c:	00e7b823          	sd	a4,16(a5)
        // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址
        ptask->pid = i;
ffffffe000201320:	fec42703          	lw	a4,-20(s0)
ffffffe000201324:	fd843783          	ld	a5,-40(s0)
ffffffe000201328:	00e7bc23          	sd	a4,24(a5)
        ptask->thread.ra = (uint64_t)__dummy;
ffffffe00020132c:	fffff717          	auipc	a4,0xfffff
ffffffe000201330:	eb470713          	addi	a4,a4,-332 # ffffffe0002001e0 <__dummy>
ffffffe000201334:	fd843783          	ld	a5,-40(s0)
ffffffe000201338:	02e7b023          	sd	a4,32(a5)
        ptask->thread.sp = (uint64_t)ptask + PGSIZE;
ffffffe00020133c:	fd843703          	ld	a4,-40(s0)
ffffffe000201340:	000017b7          	lui	a5,0x1
ffffffe000201344:	00f70733          	add	a4,a4,a5
ffffffe000201348:	fd843783          	ld	a5,-40(s0)
ffffffe00020134c:	02e7b423          	sd	a4,40(a5) # 1028 <PGSIZE+0x28>

        /*Lab4*/
        ptask->thread.sepc = (uint64_t)USER_START;
ffffffe000201350:	fd843783          	ld	a5,-40(s0)
ffffffe000201354:	0807b823          	sd	zero,144(a5)
        
        uint64_t _sstatus = ptask->thread.sstatus;
ffffffe000201358:	fd843783          	ld	a5,-40(s0)
ffffffe00020135c:	0987b783          	ld	a5,152(a5)
ffffffe000201360:	fcf43823          	sd	a5,-48(s0)
        //csr_write(sstatus, _sstatus);
        _sstatus &= ~(1 << 8);
ffffffe000201364:	fd043783          	ld	a5,-48(s0)
ffffffe000201368:	eff7f793          	andi	a5,a5,-257
ffffffe00020136c:	fcf43823          	sd	a5,-48(s0)
        _sstatus |= (1 << 5);
ffffffe000201370:	fd043783          	ld	a5,-48(s0)
ffffffe000201374:	0207e793          	ori	a5,a5,32
ffffffe000201378:	fcf43823          	sd	a5,-48(s0)
        _sstatus |= (1 << 18); 
ffffffe00020137c:	fd043703          	ld	a4,-48(s0)
ffffffe000201380:	000407b7          	lui	a5,0x40
ffffffe000201384:	00f767b3          	or	a5,a4,a5
ffffffe000201388:	fcf43823          	sd	a5,-48(s0)
        ptask->thread.sstatus = _sstatus;
ffffffe00020138c:	fd843783          	ld	a5,-40(s0)
ffffffe000201390:	fd043703          	ld	a4,-48(s0)
ffffffe000201394:	08e7bc23          	sd	a4,152(a5) # 40098 <PGSIZE+0x3f098>

        ptask->thread.sscratch = (uint64_t)USER_END;
ffffffe000201398:	fd843783          	ld	a5,-40(s0)
ffffffe00020139c:	00100713          	li	a4,1
ffffffe0002013a0:	02671713          	slli	a4,a4,0x26
ffffffe0002013a4:	0ae7b023          	sd	a4,160(a5)

        ptask->pgd = (uint64_t*)alloc_page();
ffffffe0002013a8:	891ff0ef          	jal	ra,ffffffe000200c38 <alloc_page>
ffffffe0002013ac:	00050713          	mv	a4,a0
ffffffe0002013b0:	fd843783          	ld	a5,-40(s0)
ffffffe0002013b4:	0ae7b423          	sd	a4,168(a5)
        // PAGE_COPY(swapper_pg_dir, pgtbl);
        for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002013b8:	fe043023          	sd	zero,-32(s0)
ffffffe0002013bc:	0b00006f          	j	ffffffe00020146c <task_init+0x22c>
            // char *cpgtbl = (char*)pgtbl;
            char *cpgtbl = (char*)ptask->pgd;
ffffffe0002013c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002013c4:	0a87b783          	ld	a5,168(a5)
ffffffe0002013c8:	fcf43423          	sd	a5,-56(s0)
            char *cearly_pgtbl = (char*)swapper_pg_dir;
ffffffe0002013cc:	0000c797          	auipc	a5,0xc
ffffffe0002013d0:	c3478793          	addi	a5,a5,-972 # ffffffe00020d000 <swapper_pg_dir>
ffffffe0002013d4:	fcf43023          	sd	a5,-64(s0)
            cpgtbl[i] = cearly_pgtbl[i];
ffffffe0002013d8:	fc043703          	ld	a4,-64(s0)
ffffffe0002013dc:	fe043783          	ld	a5,-32(s0)
ffffffe0002013e0:	00f70733          	add	a4,a4,a5
ffffffe0002013e4:	fc843683          	ld	a3,-56(s0)
ffffffe0002013e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002013ec:	00f687b3          	add	a5,a3,a5
ffffffe0002013f0:	00074703          	lbu	a4,0(a4)
ffffffe0002013f4:	00e78023          	sb	a4,0(a5)
            if (cpgtbl[i] != cearly_pgtbl[i]) LogRED("cpgtbl[%d] = cearly_pgtbl[%d] = %c", i, i, cpgtbl[i]);
ffffffe0002013f8:	fc843703          	ld	a4,-56(s0)
ffffffe0002013fc:	fe043783          	ld	a5,-32(s0)
ffffffe000201400:	00f707b3          	add	a5,a4,a5
ffffffe000201404:	0007c683          	lbu	a3,0(a5)
ffffffe000201408:	fc043703          	ld	a4,-64(s0)
ffffffe00020140c:	fe043783          	ld	a5,-32(s0)
ffffffe000201410:	00f707b3          	add	a5,a4,a5
ffffffe000201414:	0007c783          	lbu	a5,0(a5)
ffffffe000201418:	00068713          	mv	a4,a3
ffffffe00020141c:	04f70263          	beq	a4,a5,ffffffe000201460 <task_init+0x220>
ffffffe000201420:	fc843703          	ld	a4,-56(s0)
ffffffe000201424:	fe043783          	ld	a5,-32(s0)
ffffffe000201428:	00f707b3          	add	a5,a4,a5
ffffffe00020142c:	0007c783          	lbu	a5,0(a5)
ffffffe000201430:	0007879b          	sext.w	a5,a5
ffffffe000201434:	00078813          	mv	a6,a5
ffffffe000201438:	fe043783          	ld	a5,-32(s0)
ffffffe00020143c:	fe043703          	ld	a4,-32(s0)
ffffffe000201440:	00004697          	auipc	a3,0x4
ffffffe000201444:	dd868693          	addi	a3,a3,-552 # ffffffe000205218 <__func__.0>
ffffffe000201448:	12400613          	li	a2,292
ffffffe00020144c:	00004597          	auipc	a1,0x4
ffffffe000201450:	d1c58593          	addi	a1,a1,-740 # ffffffe000205168 <__func__.0+0x100>
ffffffe000201454:	00004517          	auipc	a0,0x4
ffffffe000201458:	d1c50513          	addi	a0,a0,-740 # ffffffe000205170 <__func__.0+0x108>
ffffffe00020145c:	0b4030ef          	jal	ra,ffffffe000204510 <printk>
        for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000201460:	fe043783          	ld	a5,-32(s0)
ffffffe000201464:	00178793          	addi	a5,a5,1
ffffffe000201468:	fef43023          	sd	a5,-32(s0)
ffffffe00020146c:	fe043703          	ld	a4,-32(s0)
ffffffe000201470:	000017b7          	lui	a5,0x1
ffffffe000201474:	f4f766e3          	bltu	a4,a5,ffffffe0002013c0 <task_init+0x180>
        }
        // LogGREEN("_sramdisk = %p, _eramdisk = %p", _sramdisk, _eramdisk);

        load_program(ptask);
ffffffe000201478:	fd843503          	ld	a0,-40(s0)
ffffffe00020147c:	20c000ef          	jal	ra,ffffffe000201688 <load_program>
        LogGREEN("[S-MODE] SET PID = %d, PGD = 0x%llx, PRIORITY = %d", ptask->pid, ptask->pgd, ptask->priority);
ffffffe000201480:	fd843783          	ld	a5,-40(s0)
ffffffe000201484:	0187b703          	ld	a4,24(a5) # 1018 <PGSIZE+0x18>
ffffffe000201488:	fd843783          	ld	a5,-40(s0)
ffffffe00020148c:	0a87b683          	ld	a3,168(a5)
ffffffe000201490:	fd843783          	ld	a5,-40(s0)
ffffffe000201494:	0107b783          	ld	a5,16(a5)
ffffffe000201498:	00078813          	mv	a6,a5
ffffffe00020149c:	00068793          	mv	a5,a3
ffffffe0002014a0:	00004697          	auipc	a3,0x4
ffffffe0002014a4:	d7868693          	addi	a3,a3,-648 # ffffffe000205218 <__func__.0>
ffffffe0002014a8:	12900613          	li	a2,297
ffffffe0002014ac:	00004597          	auipc	a1,0x4
ffffffe0002014b0:	cbc58593          	addi	a1,a1,-836 # ffffffe000205168 <__func__.0+0x100>
ffffffe0002014b4:	00004517          	auipc	a0,0x4
ffffffe0002014b8:	cfc50513          	addi	a0,a0,-772 # ffffffe0002051b0 <__func__.0+0x148>
ffffffe0002014bc:	054030ef          	jal	ra,ffffffe000204510 <printk>
                
        task[i] = ptask;
ffffffe0002014c0:	0000a717          	auipc	a4,0xa
ffffffe0002014c4:	b7870713          	addi	a4,a4,-1160 # ffffffe00020b038 <task>
ffffffe0002014c8:	fec42783          	lw	a5,-20(s0)
ffffffe0002014cc:	00379793          	slli	a5,a5,0x3
ffffffe0002014d0:	00f707b3          	add	a5,a4,a5
ffffffe0002014d4:	fd843703          	ld	a4,-40(s0)
ffffffe0002014d8:	00e7b023          	sd	a4,0(a5)
    for (int i = 1; i < nr_tasks; i++){
ffffffe0002014dc:	fec42783          	lw	a5,-20(s0)
ffffffe0002014e0:	0017879b          	addiw	a5,a5,1
ffffffe0002014e4:	fef42623          	sw	a5,-20(s0)
ffffffe0002014e8:	fec42703          	lw	a4,-20(s0)
ffffffe0002014ec:	00005797          	auipc	a5,0x5
ffffffe0002014f0:	b2478793          	addi	a5,a5,-1244 # ffffffe000206010 <nr_tasks>
ffffffe0002014f4:	0007b783          	ld	a5,0(a5)
ffffffe0002014f8:	def768e3          	bltu	a4,a5,ffffffe0002012e8 <task_init+0xa8>
    }
    /* YOUR CODE HERE */

    printk("...task_init done!\n");
ffffffe0002014fc:	00004517          	auipc	a0,0x4
ffffffe000201500:	d0450513          	addi	a0,a0,-764 # ffffffe000205200 <__func__.0+0x198>
ffffffe000201504:	00c030ef          	jal	ra,ffffffe000204510 <printk>
}
ffffffe000201508:	00000013          	nop
ffffffe00020150c:	03813083          	ld	ra,56(sp)
ffffffe000201510:	03013403          	ld	s0,48(sp)
ffffffe000201514:	04010113          	addi	sp,sp,64
ffffffe000201518:	00008067          	ret

ffffffe00020151c <find_vma>:
* @mm       : current thread's mm_struct
* @addr     : the va to look up
*
* @return   : the VMA if found or NULL if not found
*/
struct vm_area_struct *find_vma(struct mm_struct *mm, uint64_t addr){
ffffffe00020151c:	fd010113          	addi	sp,sp,-48
ffffffe000201520:	02813423          	sd	s0,40(sp)
ffffffe000201524:	03010413          	addi	s0,sp,48
ffffffe000201528:	fca43c23          	sd	a0,-40(s0)
ffffffe00020152c:	fcb43823          	sd	a1,-48(s0)
    struct vm_area_struct *vma = mm->mmap;
ffffffe000201530:	fd843783          	ld	a5,-40(s0)
ffffffe000201534:	0007b783          	ld	a5,0(a5)
ffffffe000201538:	fef43423          	sd	a5,-24(s0)
    while(vma){
ffffffe00020153c:	0380006f          	j	ffffffe000201574 <find_vma+0x58>
        if(vma->vm_start <= addr && addr < vma->vm_end){
ffffffe000201540:	fe843783          	ld	a5,-24(s0)
ffffffe000201544:	0087b783          	ld	a5,8(a5)
ffffffe000201548:	fd043703          	ld	a4,-48(s0)
ffffffe00020154c:	00f76e63          	bltu	a4,a5,ffffffe000201568 <find_vma+0x4c>
ffffffe000201550:	fe843783          	ld	a5,-24(s0)
ffffffe000201554:	0107b783          	ld	a5,16(a5)
ffffffe000201558:	fd043703          	ld	a4,-48(s0)
ffffffe00020155c:	00f77663          	bgeu	a4,a5,ffffffe000201568 <find_vma+0x4c>
            return vma;
ffffffe000201560:	fe843783          	ld	a5,-24(s0)
ffffffe000201564:	01c0006f          	j	ffffffe000201580 <find_vma+0x64>
        }
        vma = vma->vm_next;
ffffffe000201568:	fe843783          	ld	a5,-24(s0)
ffffffe00020156c:	0187b783          	ld	a5,24(a5)
ffffffe000201570:	fef43423          	sd	a5,-24(s0)
    while(vma){
ffffffe000201574:	fe843783          	ld	a5,-24(s0)
ffffffe000201578:	fc0794e3          	bnez	a5,ffffffe000201540 <find_vma+0x24>
    }
    return NULL;
ffffffe00020157c:	00000793          	li	a5,0
}
ffffffe000201580:	00078513          	mv	a0,a5
ffffffe000201584:	02813403          	ld	s0,40(sp)
ffffffe000201588:	03010113          	addi	sp,sp,48
ffffffe00020158c:	00008067          	ret

ffffffe000201590 <do_mmap>:
* @vm_filesz: phdr->p_filesz
* @flags    : flags for the new VMA
*
* @return   : start va
*/
uint64_t do_mmap(struct mm_struct *mm, uint64_t addr, uint64_t len, uint64_t vm_pgoff, uint64_t vm_filesz, uint64_t flags){
ffffffe000201590:	fb010113          	addi	sp,sp,-80
ffffffe000201594:	04113423          	sd	ra,72(sp)
ffffffe000201598:	04813023          	sd	s0,64(sp)
ffffffe00020159c:	05010413          	addi	s0,sp,80
ffffffe0002015a0:	fca43c23          	sd	a0,-40(s0)
ffffffe0002015a4:	fcb43823          	sd	a1,-48(s0)
ffffffe0002015a8:	fcc43423          	sd	a2,-56(s0)
ffffffe0002015ac:	fcd43023          	sd	a3,-64(s0)
ffffffe0002015b0:	fae43c23          	sd	a4,-72(s0)
ffffffe0002015b4:	faf43823          	sd	a5,-80(s0)
    struct vm_area_struct *new_vma = (struct vm_area_struct*)kalloc();
ffffffe0002015b8:	ef4ff0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe0002015bc:	fea43423          	sd	a0,-24(s0)
    
    new_vma->vm_mm = mm;
ffffffe0002015c0:	fe843783          	ld	a5,-24(s0)
ffffffe0002015c4:	fd843703          	ld	a4,-40(s0)
ffffffe0002015c8:	00e7b023          	sd	a4,0(a5)
    struct vm_area_struct *prev =  mm->mmap;
ffffffe0002015cc:	fd843783          	ld	a5,-40(s0)
ffffffe0002015d0:	0007b783          	ld	a5,0(a5)
ffffffe0002015d4:	fef43023          	sd	a5,-32(s0)
    if(!prev){
ffffffe0002015d8:	fe043783          	ld	a5,-32(s0)
ffffffe0002015dc:	02079263          	bnez	a5,ffffffe000201600 <do_mmap+0x70>
        mm->mmap = new_vma;
ffffffe0002015e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002015e4:	fe843703          	ld	a4,-24(s0)
ffffffe0002015e8:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = NULL;
ffffffe0002015ec:	fe843783          	ld	a5,-24(s0)
ffffffe0002015f0:	0007bc23          	sd	zero,24(a5)
        new_vma->vm_prev = NULL;
ffffffe0002015f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002015f8:	0207b023          	sd	zero,32(a5)
ffffffe0002015fc:	0300006f          	j	ffffffe00020162c <do_mmap+0x9c>
    }else{
        mm->mmap = new_vma;
ffffffe000201600:	fd843783          	ld	a5,-40(s0)
ffffffe000201604:	fe843703          	ld	a4,-24(s0)
ffffffe000201608:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = prev;
ffffffe00020160c:	fe843783          	ld	a5,-24(s0)
ffffffe000201610:	fe043703          	ld	a4,-32(s0)
ffffffe000201614:	00e7bc23          	sd	a4,24(a5)
        new_vma->vm_prev = NULL;
ffffffe000201618:	fe843783          	ld	a5,-24(s0)
ffffffe00020161c:	0207b023          	sd	zero,32(a5)
        prev->vm_prev = new_vma;
ffffffe000201620:	fe043783          	ld	a5,-32(s0)
ffffffe000201624:	fe843703          	ld	a4,-24(s0)
ffffffe000201628:	02e7b023          	sd	a4,32(a5)
    }

    new_vma->vm_start = addr;
ffffffe00020162c:	fe843783          	ld	a5,-24(s0)
ffffffe000201630:	fd043703          	ld	a4,-48(s0)
ffffffe000201634:	00e7b423          	sd	a4,8(a5)
    new_vma->vm_end = addr + len;
ffffffe000201638:	fd043703          	ld	a4,-48(s0)
ffffffe00020163c:	fc843783          	ld	a5,-56(s0)
ffffffe000201640:	00f70733          	add	a4,a4,a5
ffffffe000201644:	fe843783          	ld	a5,-24(s0)
ffffffe000201648:	00e7b823          	sd	a4,16(a5)
    new_vma->vm_flags = flags;
ffffffe00020164c:	fe843783          	ld	a5,-24(s0)
ffffffe000201650:	fb043703          	ld	a4,-80(s0)
ffffffe000201654:	02e7b423          	sd	a4,40(a5)
    new_vma->vm_pgoff = vm_pgoff;
ffffffe000201658:	fe843783          	ld	a5,-24(s0)
ffffffe00020165c:	fc043703          	ld	a4,-64(s0)
ffffffe000201660:	02e7b823          	sd	a4,48(a5)
    new_vma->vm_filesz = vm_filesz;
ffffffe000201664:	fe843783          	ld	a5,-24(s0)
ffffffe000201668:	fb843703          	ld	a4,-72(s0)
ffffffe00020166c:	02e7bc23          	sd	a4,56(a5)

    return addr;
ffffffe000201670:	fd043783          	ld	a5,-48(s0)
}
ffffffe000201674:	00078513          	mv	a0,a5
ffffffe000201678:	04813083          	ld	ra,72(sp)
ffffffe00020167c:	04013403          	ld	s0,64(sp)
ffffffe000201680:	05010113          	addi	sp,sp,80
ffffffe000201684:	00008067          	ret

ffffffe000201688 <load_program>:
// #define VM_EXEC 0x8

// #define PF_X		(1 << 0)
// #define PF_W		(1 << 1)
// #define PF_R		(1 << 2)
void load_program(struct task_struct *task) {
ffffffe000201688:	fb010113          	addi	sp,sp,-80
ffffffe00020168c:	04113423          	sd	ra,72(sp)
ffffffe000201690:	04813023          	sd	s0,64(sp)
ffffffe000201694:	05010413          	addi	s0,sp,80
ffffffe000201698:	faa43c23          	sd	a0,-72(s0)
    Elf64_Ehdr *ehdr = (Elf64_Ehdr *)_sramdisk;
ffffffe00020169c:	00006797          	auipc	a5,0x6
ffffffe0002016a0:	96478793          	addi	a5,a5,-1692 # ffffffe000207000 <_sramdisk>
ffffffe0002016a4:	fef43023          	sd	a5,-32(s0)

    // LogGREEN("ehdr->e_ident = 0x%llx", *((uint64_t*)ehdr->e_ident));
    Elf64_Phdr *phdrs = (Elf64_Phdr *)(_sramdisk + ehdr->e_phoff);
ffffffe0002016a8:	fe043783          	ld	a5,-32(s0)
ffffffe0002016ac:	0207b703          	ld	a4,32(a5)
ffffffe0002016b0:	00006797          	auipc	a5,0x6
ffffffe0002016b4:	95078793          	addi	a5,a5,-1712 # ffffffe000207000 <_sramdisk>
ffffffe0002016b8:	00f707b3          	add	a5,a4,a5
ffffffe0002016bc:	fcf43c23          	sd	a5,-40(s0)
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe0002016c0:	fe042623          	sw	zero,-20(s0)
ffffffe0002016c4:	0dc0006f          	j	ffffffe0002017a0 <load_program+0x118>
        Elf64_Phdr *phdr = phdrs + i;
ffffffe0002016c8:	fec42703          	lw	a4,-20(s0)
ffffffe0002016cc:	00070793          	mv	a5,a4
ffffffe0002016d0:	00379793          	slli	a5,a5,0x3
ffffffe0002016d4:	40e787b3          	sub	a5,a5,a4
ffffffe0002016d8:	00379793          	slli	a5,a5,0x3
ffffffe0002016dc:	00078713          	mv	a4,a5
ffffffe0002016e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002016e4:	00e787b3          	add	a5,a5,a4
ffffffe0002016e8:	fcf43823          	sd	a5,-48(s0)
        if (phdr->p_type == PT_LOAD) {
ffffffe0002016ec:	fd043783          	ld	a5,-48(s0)
ffffffe0002016f0:	0007a783          	lw	a5,0(a5)
ffffffe0002016f4:	00078713          	mv	a4,a5
ffffffe0002016f8:	00100793          	li	a5,1
ffffffe0002016fc:	08f71c63          	bne	a4,a5,ffffffe000201794 <load_program+0x10c>
            uint64_t perm = (phdr->p_flags & PF_X) << 3 | (phdr->p_flags & PF_R) >> 1 | (phdr->p_flags & PF_W) << 1;
ffffffe000201700:	fd043783          	ld	a5,-48(s0)
ffffffe000201704:	0047a783          	lw	a5,4(a5)
ffffffe000201708:	0037979b          	slliw	a5,a5,0x3
ffffffe00020170c:	0007879b          	sext.w	a5,a5
ffffffe000201710:	0087f793          	andi	a5,a5,8
ffffffe000201714:	0007871b          	sext.w	a4,a5
ffffffe000201718:	fd043783          	ld	a5,-48(s0)
ffffffe00020171c:	0047a783          	lw	a5,4(a5)
ffffffe000201720:	0017d79b          	srliw	a5,a5,0x1
ffffffe000201724:	0007879b          	sext.w	a5,a5
ffffffe000201728:	0027f793          	andi	a5,a5,2
ffffffe00020172c:	0007879b          	sext.w	a5,a5
ffffffe000201730:	00f767b3          	or	a5,a4,a5
ffffffe000201734:	0007871b          	sext.w	a4,a5
ffffffe000201738:	fd043783          	ld	a5,-48(s0)
ffffffe00020173c:	0047a783          	lw	a5,4(a5)
ffffffe000201740:	0017979b          	slliw	a5,a5,0x1
ffffffe000201744:	0007879b          	sext.w	a5,a5
ffffffe000201748:	0047f793          	andi	a5,a5,4
ffffffe00020174c:	0007879b          	sext.w	a5,a5
ffffffe000201750:	00f767b3          	or	a5,a4,a5
ffffffe000201754:	0007879b          	sext.w	a5,a5
ffffffe000201758:	02079793          	slli	a5,a5,0x20
ffffffe00020175c:	0207d793          	srli	a5,a5,0x20
ffffffe000201760:	fcf43423          	sd	a5,-56(s0)
            do_mmap(&(task->mm), phdr->p_paddr, phdr->p_memsz, phdr->p_offset, phdr->p_filesz, perm);
ffffffe000201764:	fb843783          	ld	a5,-72(s0)
ffffffe000201768:	0b078513          	addi	a0,a5,176
ffffffe00020176c:	fd043783          	ld	a5,-48(s0)
ffffffe000201770:	0187b583          	ld	a1,24(a5)
ffffffe000201774:	fd043783          	ld	a5,-48(s0)
ffffffe000201778:	0287b603          	ld	a2,40(a5)
ffffffe00020177c:	fd043783          	ld	a5,-48(s0)
ffffffe000201780:	0087b683          	ld	a3,8(a5)
ffffffe000201784:	fd043783          	ld	a5,-48(s0)
ffffffe000201788:	0207b703          	ld	a4,32(a5)
ffffffe00020178c:	fc843783          	ld	a5,-56(s0)
ffffffe000201790:	e01ff0ef          	jal	ra,ffffffe000201590 <do_mmap>
    for (int i = 0; i < ehdr->e_phnum; ++i) {
ffffffe000201794:	fec42783          	lw	a5,-20(s0)
ffffffe000201798:	0017879b          	addiw	a5,a5,1
ffffffe00020179c:	fef42623          	sw	a5,-20(s0)
ffffffe0002017a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002017a4:	0387d783          	lhu	a5,56(a5)
ffffffe0002017a8:	0007871b          	sext.w	a4,a5
ffffffe0002017ac:	fec42783          	lw	a5,-20(s0)
ffffffe0002017b0:	0007879b          	sext.w	a5,a5
ffffffe0002017b4:	f0e7cae3          	blt	a5,a4,ffffffe0002016c8 <load_program+0x40>
        }
    }
    do_mmap(&(task->mm), USER_END - PGSIZE, PGSIZE, 0, PGSIZE, VM_READ | VM_ANON | VM_WRITE);
ffffffe0002017b8:	fb843783          	ld	a5,-72(s0)
ffffffe0002017bc:	0b078513          	addi	a0,a5,176
ffffffe0002017c0:	00700793          	li	a5,7
ffffffe0002017c4:	00001737          	lui	a4,0x1
ffffffe0002017c8:	00000693          	li	a3,0
ffffffe0002017cc:	00001637          	lui	a2,0x1
ffffffe0002017d0:	040005b7          	lui	a1,0x4000
ffffffe0002017d4:	fff58593          	addi	a1,a1,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe0002017d8:	00c59593          	slli	a1,a1,0xc
ffffffe0002017dc:	db5ff0ef          	jal	ra,ffffffe000201590 <do_mmap>
    task->thread.sepc = ehdr->e_entry;
ffffffe0002017e0:	fe043783          	ld	a5,-32(s0)
ffffffe0002017e4:	0187b703          	ld	a4,24(a5)
ffffffe0002017e8:	fb843783          	ld	a5,-72(s0)
ffffffe0002017ec:	08e7b823          	sd	a4,144(a5)
}
ffffffe0002017f0:	00000013          	nop
ffffffe0002017f4:	04813083          	ld	ra,72(sp)
ffffffe0002017f8:	04013403          	ld	s0,64(sp)
ffffffe0002017fc:	05010113          	addi	sp,sp,80
ffffffe000201800:	00008067          	ret

ffffffe000201804 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000201804:	f8010113          	addi	sp,sp,-128
ffffffe000201808:	06813c23          	sd	s0,120(sp)
ffffffe00020180c:	06913823          	sd	s1,112(sp)
ffffffe000201810:	07213423          	sd	s2,104(sp)
ffffffe000201814:	07313023          	sd	s3,96(sp)
ffffffe000201818:	08010413          	addi	s0,sp,128
ffffffe00020181c:	faa43c23          	sd	a0,-72(s0)
ffffffe000201820:	fab43823          	sd	a1,-80(s0)
ffffffe000201824:	fac43423          	sd	a2,-88(s0)
ffffffe000201828:	fad43023          	sd	a3,-96(s0)
ffffffe00020182c:	f8e43c23          	sd	a4,-104(s0)
ffffffe000201830:	f8f43823          	sd	a5,-112(s0)
ffffffe000201834:	f9043423          	sd	a6,-120(s0)
ffffffe000201838:	f9143023          	sd	a7,-128(s0)
    
    struct sbiret sbiRet;

    asm volatile (
ffffffe00020183c:	fb843e03          	ld	t3,-72(s0)
ffffffe000201840:	fb043e83          	ld	t4,-80(s0)
ffffffe000201844:	fa843f03          	ld	t5,-88(s0)
ffffffe000201848:	fa043f83          	ld	t6,-96(s0)
ffffffe00020184c:	f9843283          	ld	t0,-104(s0)
ffffffe000201850:	f9043483          	ld	s1,-112(s0)
ffffffe000201854:	f8843903          	ld	s2,-120(s0)
ffffffe000201858:	f8043983          	ld	s3,-128(s0)
ffffffe00020185c:	01c008b3          	add	a7,zero,t3
ffffffe000201860:	01d00833          	add	a6,zero,t4
ffffffe000201864:	01e00533          	add	a0,zero,t5
ffffffe000201868:	01f005b3          	add	a1,zero,t6
ffffffe00020186c:	00500633          	add	a2,zero,t0
ffffffe000201870:	009006b3          	add	a3,zero,s1
ffffffe000201874:	01200733          	add	a4,zero,s2
ffffffe000201878:	013007b3          	add	a5,zero,s3
ffffffe00020187c:	00000073          	ecall
ffffffe000201880:	00050e93          	mv	t4,a0
ffffffe000201884:	00058e13          	mv	t3,a1
ffffffe000201888:	fdd43023          	sd	t4,-64(s0)
ffffffe00020188c:	fdc43423          	sd	t3,-56(s0)
        : "=r"(sbiRet.error), "=r"(sbiRet.value)
        : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );

    return sbiRet;
ffffffe000201890:	fc043783          	ld	a5,-64(s0)
ffffffe000201894:	fcf43823          	sd	a5,-48(s0)
ffffffe000201898:	fc843783          	ld	a5,-56(s0)
ffffffe00020189c:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002018a0:	fd043703          	ld	a4,-48(s0)
ffffffe0002018a4:	fd843783          	ld	a5,-40(s0)
ffffffe0002018a8:	00070313          	mv	t1,a4
ffffffe0002018ac:	00078393          	mv	t2,a5
ffffffe0002018b0:	00030713          	mv	a4,t1
ffffffe0002018b4:	00038793          	mv	a5,t2
}
ffffffe0002018b8:	00070513          	mv	a0,a4
ffffffe0002018bc:	00078593          	mv	a1,a5
ffffffe0002018c0:	07813403          	ld	s0,120(sp)
ffffffe0002018c4:	07013483          	ld	s1,112(sp)
ffffffe0002018c8:	06813903          	ld	s2,104(sp)
ffffffe0002018cc:	06013983          	ld	s3,96(sp)
ffffffe0002018d0:	08010113          	addi	sp,sp,128
ffffffe0002018d4:	00008067          	ret

ffffffe0002018d8 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe0002018d8:	fc010113          	addi	sp,sp,-64
ffffffe0002018dc:	02113c23          	sd	ra,56(sp)
ffffffe0002018e0:	02813823          	sd	s0,48(sp)
ffffffe0002018e4:	03213423          	sd	s2,40(sp)
ffffffe0002018e8:	03313023          	sd	s3,32(sp)
ffffffe0002018ec:	04010413          	addi	s0,sp,64
ffffffe0002018f0:	00050793          	mv	a5,a0
ffffffe0002018f4:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
ffffffe0002018f8:	fcf44603          	lbu	a2,-49(s0)
ffffffe0002018fc:	00000893          	li	a7,0
ffffffe000201900:	00000813          	li	a6,0
ffffffe000201904:	00000793          	li	a5,0
ffffffe000201908:	00000713          	li	a4,0
ffffffe00020190c:	00000693          	li	a3,0
ffffffe000201910:	00200593          	li	a1,2
ffffffe000201914:	44424537          	lui	a0,0x44424
ffffffe000201918:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe00020191c:	ee9ff0ef          	jal	ra,ffffffe000201804 <sbi_ecall>
ffffffe000201920:	00050713          	mv	a4,a0
ffffffe000201924:	00058793          	mv	a5,a1
ffffffe000201928:	fce43823          	sd	a4,-48(s0)
ffffffe00020192c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201930:	fd043703          	ld	a4,-48(s0)
ffffffe000201934:	fd843783          	ld	a5,-40(s0)
ffffffe000201938:	00070913          	mv	s2,a4
ffffffe00020193c:	00078993          	mv	s3,a5
ffffffe000201940:	00090713          	mv	a4,s2
ffffffe000201944:	00098793          	mv	a5,s3
}
ffffffe000201948:	00070513          	mv	a0,a4
ffffffe00020194c:	00078593          	mv	a1,a5
ffffffe000201950:	03813083          	ld	ra,56(sp)
ffffffe000201954:	03013403          	ld	s0,48(sp)
ffffffe000201958:	02813903          	ld	s2,40(sp)
ffffffe00020195c:	02013983          	ld	s3,32(sp)
ffffffe000201960:	04010113          	addi	sp,sp,64
ffffffe000201964:	00008067          	ret

ffffffe000201968 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000201968:	fc010113          	addi	sp,sp,-64
ffffffe00020196c:	02113c23          	sd	ra,56(sp)
ffffffe000201970:	02813823          	sd	s0,48(sp)
ffffffe000201974:	03213423          	sd	s2,40(sp)
ffffffe000201978:	03313023          	sd	s3,32(sp)
ffffffe00020197c:	04010413          	addi	s0,sp,64
ffffffe000201980:	00050793          	mv	a5,a0
ffffffe000201984:	00058713          	mv	a4,a1
ffffffe000201988:	fcf42623          	sw	a5,-52(s0)
ffffffe00020198c:	00070793          	mv	a5,a4
ffffffe000201990:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe000201994:	fcc46603          	lwu	a2,-52(s0)
ffffffe000201998:	fc846683          	lwu	a3,-56(s0)
ffffffe00020199c:	00000893          	li	a7,0
ffffffe0002019a0:	00000813          	li	a6,0
ffffffe0002019a4:	00000793          	li	a5,0
ffffffe0002019a8:	00000713          	li	a4,0
ffffffe0002019ac:	00000593          	li	a1,0
ffffffe0002019b0:	53525537          	lui	a0,0x53525
ffffffe0002019b4:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe0002019b8:	e4dff0ef          	jal	ra,ffffffe000201804 <sbi_ecall>
ffffffe0002019bc:	00050713          	mv	a4,a0
ffffffe0002019c0:	00058793          	mv	a5,a1
ffffffe0002019c4:	fce43823          	sd	a4,-48(s0)
ffffffe0002019c8:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002019cc:	fd043703          	ld	a4,-48(s0)
ffffffe0002019d0:	fd843783          	ld	a5,-40(s0)
ffffffe0002019d4:	00070913          	mv	s2,a4
ffffffe0002019d8:	00078993          	mv	s3,a5
ffffffe0002019dc:	00090713          	mv	a4,s2
ffffffe0002019e0:	00098793          	mv	a5,s3
}
ffffffe0002019e4:	00070513          	mv	a0,a4
ffffffe0002019e8:	00078593          	mv	a1,a5
ffffffe0002019ec:	03813083          	ld	ra,56(sp)
ffffffe0002019f0:	03013403          	ld	s0,48(sp)
ffffffe0002019f4:	02813903          	ld	s2,40(sp)
ffffffe0002019f8:	02013983          	ld	s3,32(sp)
ffffffe0002019fc:	04010113          	addi	sp,sp,64
ffffffe000201a00:	00008067          	ret

ffffffe000201a04 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe000201a04:	fc010113          	addi	sp,sp,-64
ffffffe000201a08:	02113c23          	sd	ra,56(sp)
ffffffe000201a0c:	02813823          	sd	s0,48(sp)
ffffffe000201a10:	03213423          	sd	s2,40(sp)
ffffffe000201a14:	03313023          	sd	s3,32(sp)
ffffffe000201a18:	04010413          	addi	s0,sp,64
ffffffe000201a1c:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
ffffffe000201a20:	00000893          	li	a7,0
ffffffe000201a24:	00000813          	li	a6,0
ffffffe000201a28:	00000793          	li	a5,0
ffffffe000201a2c:	00000713          	li	a4,0
ffffffe000201a30:	00000693          	li	a3,0
ffffffe000201a34:	fc843603          	ld	a2,-56(s0)
ffffffe000201a38:	00000593          	li	a1,0
ffffffe000201a3c:	54495537          	lui	a0,0x54495
ffffffe000201a40:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000201a44:	dc1ff0ef          	jal	ra,ffffffe000201804 <sbi_ecall>
ffffffe000201a48:	00050713          	mv	a4,a0
ffffffe000201a4c:	00058793          	mv	a5,a1
ffffffe000201a50:	fce43823          	sd	a4,-48(s0)
ffffffe000201a54:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201a58:	fd043703          	ld	a4,-48(s0)
ffffffe000201a5c:	fd843783          	ld	a5,-40(s0)
ffffffe000201a60:	00070913          	mv	s2,a4
ffffffe000201a64:	00078993          	mv	s3,a5
ffffffe000201a68:	00090713          	mv	a4,s2
ffffffe000201a6c:	00098793          	mv	a5,s3
ffffffe000201a70:	00070513          	mv	a0,a4
ffffffe000201a74:	00078593          	mv	a1,a5
ffffffe000201a78:	03813083          	ld	ra,56(sp)
ffffffe000201a7c:	03013403          	ld	s0,48(sp)
ffffffe000201a80:	02813903          	ld	s2,40(sp)
ffffffe000201a84:	02013983          	ld	s3,32(sp)
ffffffe000201a88:	04010113          	addi	sp,sp,64
ffffffe000201a8c:	00008067          	ret

ffffffe000201a90 <trap_handler>:
extern char _sramdisk[], _eramdisk[];
extern uint64_t nr_tasks;
extern struct task_struct *task[];
extern void __ret_from_fork();
extern uint64_t swapper_pg_dir[];
void trap_handler(uint64_t scause, uint64_t sepc, uint64_t sstatus, struct pt_regs *regs) {
ffffffe000201a90:	f9010113          	addi	sp,sp,-112
ffffffe000201a94:	06113423          	sd	ra,104(sp)
ffffffe000201a98:	06813023          	sd	s0,96(sp)
ffffffe000201a9c:	07010413          	addi	s0,sp,112
ffffffe000201aa0:	faa43423          	sd	a0,-88(s0)
ffffffe000201aa4:	fab43023          	sd	a1,-96(s0)
ffffffe000201aa8:	f8c43c23          	sd	a2,-104(s0)
ffffffe000201aac:	f8d43823          	sd	a3,-112(s0)
    // 通过 `scause` 判断 trap 类型
    uint64_t _stvac = csr_read(stval);
ffffffe000201ab0:	143027f3          	csrr	a5,stval
ffffffe000201ab4:	fef43423          	sd	a5,-24(s0)
ffffffe000201ab8:	fe843783          	ld	a5,-24(s0)
ffffffe000201abc:	fef43023          	sd	a5,-32(s0)
    LogPURPLE("scause: 0x%llx, sstatus: 0x%llx, sepc: 0x%llx, stvac: 0x%llx", scause, sstatus, sepc, _stvac);
ffffffe000201ac0:	fe043883          	ld	a7,-32(s0)
ffffffe000201ac4:	fa043803          	ld	a6,-96(s0)
ffffffe000201ac8:	f9843783          	ld	a5,-104(s0)
ffffffe000201acc:	fa843703          	ld	a4,-88(s0)
ffffffe000201ad0:	00004697          	auipc	a3,0x4
ffffffe000201ad4:	ac868693          	addi	a3,a3,-1336 # ffffffe000205598 <__func__.4>
ffffffe000201ad8:	01200613          	li	a2,18
ffffffe000201adc:	00003597          	auipc	a1,0x3
ffffffe000201ae0:	74c58593          	addi	a1,a1,1868 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201ae4:	00003517          	auipc	a0,0x3
ffffffe000201ae8:	74c50513          	addi	a0,a0,1868 # ffffffe000205230 <__func__.0+0x18>
ffffffe000201aec:	225020ef          	jal	ra,ffffffe000204510 <printk>
    // if (scause == 0x1) Err("_*stvac = 0x%llx", *(uint64_t*)_stvac);
    if(scause == 0x8000000000000005){
ffffffe000201af0:	fa843703          	ld	a4,-88(s0)
ffffffe000201af4:	fff00793          	li	a5,-1
ffffffe000201af8:	03f79793          	slli	a5,a5,0x3f
ffffffe000201afc:	00578793          	addi	a5,a5,5
ffffffe000201b00:	02f71863          	bne	a4,a5,ffffffe000201b30 <trap_handler+0xa0>
        LogRED("Timer Interrupt");
ffffffe000201b04:	00004697          	auipc	a3,0x4
ffffffe000201b08:	a9468693          	addi	a3,a3,-1388 # ffffffe000205598 <__func__.4>
ffffffe000201b0c:	01500613          	li	a2,21
ffffffe000201b10:	00003597          	auipc	a1,0x3
ffffffe000201b14:	71858593          	addi	a1,a1,1816 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201b18:	00003517          	auipc	a0,0x3
ffffffe000201b1c:	77050513          	addi	a0,a0,1904 # ffffffe000205288 <__func__.0+0x70>
ffffffe000201b20:	1f1020ef          	jal	ra,ffffffe000204510 <printk>
        clock_set_next_event();
ffffffe000201b24:	fc0fe0ef          	jal	ra,ffffffe0002002e4 <clock_set_next_event>
        do_timer();
ffffffe000201b28:	c24ff0ef          	jal	ra,ffffffe000200f4c <do_timer>
ffffffe000201b2c:	1840006f          	j	ffffffe000201cb0 <trap_handler+0x220>
    }else if(scause == 0xc){
ffffffe000201b30:	fa843703          	ld	a4,-88(s0)
ffffffe000201b34:	00c00793          	li	a5,12
ffffffe000201b38:	0af71a63          	bne	a4,a5,ffffffe000201bec <trap_handler+0x15c>
        LogRED("Instruction Page Fault");
ffffffe000201b3c:	00004697          	auipc	a3,0x4
ffffffe000201b40:	a5c68693          	addi	a3,a3,-1444 # ffffffe000205598 <__func__.4>
ffffffe000201b44:	01900613          	li	a2,25
ffffffe000201b48:	00003597          	auipc	a1,0x3
ffffffe000201b4c:	6e058593          	addi	a1,a1,1760 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201b50:	00003517          	auipc	a0,0x3
ffffffe000201b54:	76050513          	addi	a0,a0,1888 # ffffffe0002052b0 <__func__.0+0x98>
ffffffe000201b58:	1b9020ef          	jal	ra,ffffffe000204510 <printk>
        if(sepc < VM_START && sepc > USER_END){
ffffffe000201b5c:	fa043703          	ld	a4,-96(s0)
ffffffe000201b60:	fff00793          	li	a5,-1
ffffffe000201b64:	02579793          	slli	a5,a5,0x25
ffffffe000201b68:	06f77463          	bgeu	a4,a5,ffffffe000201bd0 <trap_handler+0x140>
ffffffe000201b6c:	fa043703          	ld	a4,-96(s0)
ffffffe000201b70:	00100793          	li	a5,1
ffffffe000201b74:	02679793          	slli	a5,a5,0x26
ffffffe000201b78:	04e7fc63          	bgeu	a5,a4,ffffffe000201bd0 <trap_handler+0x140>
            LogGREEN("[Physical Address: 0x%llx] -> [Virtual Address: 0x%llx]", sepc, sepc + 0xffffffdf80000000);
ffffffe000201b7c:	fa043703          	ld	a4,-96(s0)
ffffffe000201b80:	fbf00793          	li	a5,-65
ffffffe000201b84:	01f79793          	slli	a5,a5,0x1f
ffffffe000201b88:	00f707b3          	add	a5,a4,a5
ffffffe000201b8c:	fa043703          	ld	a4,-96(s0)
ffffffe000201b90:	00004697          	auipc	a3,0x4
ffffffe000201b94:	a0868693          	addi	a3,a3,-1528 # ffffffe000205598 <__func__.4>
ffffffe000201b98:	01b00613          	li	a2,27
ffffffe000201b9c:	00003597          	auipc	a1,0x3
ffffffe000201ba0:	68c58593          	addi	a1,a1,1676 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201ba4:	00003517          	auipc	a0,0x3
ffffffe000201ba8:	73c50513          	addi	a0,a0,1852 # ffffffe0002052e0 <__func__.0+0xc8>
ffffffe000201bac:	165020ef          	jal	ra,ffffffe000204510 <printk>
            csr_write(sepc, sepc + 0xffffffdf80000000);
ffffffe000201bb0:	fa043703          	ld	a4,-96(s0)
ffffffe000201bb4:	fbf00793          	li	a5,-65
ffffffe000201bb8:	01f79793          	slli	a5,a5,0x1f
ffffffe000201bbc:	00f707b3          	add	a5,a4,a5
ffffffe000201bc0:	fcf43423          	sd	a5,-56(s0)
ffffffe000201bc4:	fc843783          	ld	a5,-56(s0)
ffffffe000201bc8:	14179073          	csrw	sepc,a5
            return;
ffffffe000201bcc:	1140006f          	j	ffffffe000201ce0 <trap_handler+0x250>
        }
        do_page_fault(regs);
ffffffe000201bd0:	f9043503          	ld	a0,-112(s0)
ffffffe000201bd4:	308000ef          	jal	ra,ffffffe000201edc <do_page_fault>
        csr_write(sepc, sepc);
ffffffe000201bd8:	fa043783          	ld	a5,-96(s0)
ffffffe000201bdc:	fcf43023          	sd	a5,-64(s0)
ffffffe000201be0:	fc043783          	ld	a5,-64(s0)
ffffffe000201be4:	14179073          	csrw	sepc,a5
        return;
ffffffe000201be8:	0f80006f          	j	ffffffe000201ce0 <trap_handler+0x250>
    }else if(scause == 0xf){
ffffffe000201bec:	fa843703          	ld	a4,-88(s0)
ffffffe000201bf0:	00f00793          	li	a5,15
ffffffe000201bf4:	04f71063          	bne	a4,a5,ffffffe000201c34 <trap_handler+0x1a4>
        LogRED("Store/AMO Page Fault");
ffffffe000201bf8:	00004697          	auipc	a3,0x4
ffffffe000201bfc:	9a068693          	addi	a3,a3,-1632 # ffffffe000205598 <__func__.4>
ffffffe000201c00:	02300613          	li	a2,35
ffffffe000201c04:	00003597          	auipc	a1,0x3
ffffffe000201c08:	62458593          	addi	a1,a1,1572 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201c0c:	00003517          	auipc	a0,0x3
ffffffe000201c10:	72450513          	addi	a0,a0,1828 # ffffffe000205330 <__func__.0+0x118>
ffffffe000201c14:	0fd020ef          	jal	ra,ffffffe000204510 <printk>
        // LogBLUE("exist = %d", exist);
        // uint64_t entry = pte_entry_ret(&(current->pgd), _stvac);
        // uint64_t check = get_page_refcnt((void *)(((entry >> 10) << 12) | (_stvac & 0xfff)));
        // // uint64_t check = check_load(current->pgd, _stvac);
        // if(!check) 
        do_page_fault(regs);
ffffffe000201c18:	f9043503          	ld	a0,-112(s0)
ffffffe000201c1c:	2c0000ef          	jal	ra,ffffffe000201edc <do_page_fault>
        //     if(perm & perm != 0xfff){
        //         LogYELLOW("[COW]");
        //         page_cow(current->pgd, _stvac, perm);
        //     }
        // }
        csr_write(sepc, sepc);
ffffffe000201c20:	fa043783          	ld	a5,-96(s0)
ffffffe000201c24:	fcf43823          	sd	a5,-48(s0)
ffffffe000201c28:	fd043783          	ld	a5,-48(s0)
ffffffe000201c2c:	14179073          	csrw	sepc,a5
        return;
ffffffe000201c30:	0b00006f          	j	ffffffe000201ce0 <trap_handler+0x250>
    }else if(scause == 0xd){
ffffffe000201c34:	fa843703          	ld	a4,-88(s0)
ffffffe000201c38:	00d00793          	li	a5,13
ffffffe000201c3c:	04f71063          	bne	a4,a5,ffffffe000201c7c <trap_handler+0x1ec>
        LogRED("Load Page Fault");
ffffffe000201c40:	00004697          	auipc	a3,0x4
ffffffe000201c44:	95868693          	addi	a3,a3,-1704 # ffffffe000205598 <__func__.4>
ffffffe000201c48:	03600613          	li	a2,54
ffffffe000201c4c:	00003597          	auipc	a1,0x3
ffffffe000201c50:	5dc58593          	addi	a1,a1,1500 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201c54:	00003517          	auipc	a0,0x3
ffffffe000201c58:	70c50513          	addi	a0,a0,1804 # ffffffe000205360 <__func__.0+0x148>
ffffffe000201c5c:	0b5020ef          	jal	ra,ffffffe000204510 <printk>
        do_page_fault(regs);
ffffffe000201c60:	f9043503          	ld	a0,-112(s0)
ffffffe000201c64:	278000ef          	jal	ra,ffffffe000201edc <do_page_fault>
        csr_write(sepc, sepc);
ffffffe000201c68:	fa043783          	ld	a5,-96(s0)
ffffffe000201c6c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201c70:	fd843783          	ld	a5,-40(s0)
ffffffe000201c74:	14179073          	csrw	sepc,a5
        return;
ffffffe000201c78:	0680006f          	j	ffffffe000201ce0 <trap_handler+0x250>
    }else if(scause == 0x8){
ffffffe000201c7c:	fa843703          	ld	a4,-88(s0)
ffffffe000201c80:	00800793          	li	a5,8
ffffffe000201c84:	02f71663          	bne	a4,a5,ffffffe000201cb0 <trap_handler+0x220>
        LogRED("Environment Call from U-mode");
ffffffe000201c88:	00004697          	auipc	a3,0x4
ffffffe000201c8c:	91068693          	addi	a3,a3,-1776 # ffffffe000205598 <__func__.4>
ffffffe000201c90:	03b00613          	li	a2,59
ffffffe000201c94:	00003597          	auipc	a1,0x3
ffffffe000201c98:	59458593          	addi	a1,a1,1428 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201c9c:	00003517          	auipc	a0,0x3
ffffffe000201ca0:	6ec50513          	addi	a0,a0,1772 # ffffffe000205388 <__func__.0+0x170>
ffffffe000201ca4:	06d020ef          	jal	ra,ffffffe000204510 <printk>
        syscall(regs);
ffffffe000201ca8:	f9043503          	ld	a0,-112(s0)
ffffffe000201cac:	07c000ef          	jal	ra,ffffffe000201d28 <syscall>
    }

    if (scause & 0x8000000000000000) {
ffffffe000201cb0:	fa843783          	ld	a5,-88(s0)
ffffffe000201cb4:	0007dc63          	bgez	a5,ffffffe000201ccc <trap_handler+0x23c>
        csr_write(sepc, sepc);
ffffffe000201cb8:	fa043783          	ld	a5,-96(s0)
ffffffe000201cbc:	faf43823          	sd	a5,-80(s0)
ffffffe000201cc0:	fb043783          	ld	a5,-80(s0)
ffffffe000201cc4:	14179073          	csrw	sepc,a5
ffffffe000201cc8:	0180006f          	j	ffffffe000201ce0 <trap_handler+0x250>
    } else {
        csr_write(sepc, sepc + 4);
ffffffe000201ccc:	fa043783          	ld	a5,-96(s0)
ffffffe000201cd0:	00478793          	addi	a5,a5,4
ffffffe000201cd4:	faf43c23          	sd	a5,-72(s0)
ffffffe000201cd8:	fb843783          	ld	a5,-72(s0)
ffffffe000201cdc:	14179073          	csrw	sepc,a5
    }
}
ffffffe000201ce0:	06813083          	ld	ra,104(sp)
ffffffe000201ce4:	06013403          	ld	s0,96(sp)
ffffffe000201ce8:	07010113          	addi	sp,sp,112
ffffffe000201cec:	00008067          	ret

ffffffe000201cf0 <csr_change>:


void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
ffffffe000201cf0:	fc010113          	addi	sp,sp,-64
ffffffe000201cf4:	02813c23          	sd	s0,56(sp)
ffffffe000201cf8:	04010413          	addi	s0,sp,64
ffffffe000201cfc:	fca43c23          	sd	a0,-40(s0)
ffffffe000201d00:	fcb43823          	sd	a1,-48(s0)
ffffffe000201d04:	fcc43423          	sd	a2,-56(s0)
    csr_write(sscratch, value);
ffffffe000201d08:	fc843783          	ld	a5,-56(s0)
ffffffe000201d0c:	fef43423          	sd	a5,-24(s0)
ffffffe000201d10:	fe843783          	ld	a5,-24(s0)
ffffffe000201d14:	14079073          	csrw	sscratch,a5
}
ffffffe000201d18:	00000013          	nop
ffffffe000201d1c:	03813403          	ld	s0,56(sp)
ffffffe000201d20:	04010113          	addi	sp,sp,64
ffffffe000201d24:	00008067          	ret

ffffffe000201d28 <syscall>:

void syscall(struct pt_regs *regs) {
ffffffe000201d28:	fb010113          	addi	sp,sp,-80
ffffffe000201d2c:	04113423          	sd	ra,72(sp)
ffffffe000201d30:	04813023          	sd	s0,64(sp)
ffffffe000201d34:	05010413          	addi	s0,sp,80
ffffffe000201d38:	faa43c23          	sd	a0,-72(s0)
    uint64_t syscall_num = regs->x[17];
ffffffe000201d3c:	fb843783          	ld	a5,-72(s0)
ffffffe000201d40:	0887b783          	ld	a5,136(a5)
ffffffe000201d44:	fef43023          	sd	a5,-32(s0)
    if (syscall_num == (uint64_t)SYS_WRITE) {
ffffffe000201d48:	fe043703          	ld	a4,-32(s0)
ffffffe000201d4c:	04000793          	li	a5,64
ffffffe000201d50:	0af71463          	bne	a4,a5,ffffffe000201df8 <syscall+0xd0>
        uint64_t fd = regs->x[10];
ffffffe000201d54:	fb843783          	ld	a5,-72(s0)
ffffffe000201d58:	0507b783          	ld	a5,80(a5)
ffffffe000201d5c:	fcf43823          	sd	a5,-48(s0)
        uint64_t i = 0;
ffffffe000201d60:	fe043423          	sd	zero,-24(s0)
        if (fd == 1) {
ffffffe000201d64:	fd043703          	ld	a4,-48(s0)
ffffffe000201d68:	00100793          	li	a5,1
ffffffe000201d6c:	04f71c63          	bne	a4,a5,ffffffe000201dc4 <syscall+0x9c>
            char *buf = (char *)regs->x[11];
ffffffe000201d70:	fb843783          	ld	a5,-72(s0)
ffffffe000201d74:	0587b783          	ld	a5,88(a5)
ffffffe000201d78:	fcf43423          	sd	a5,-56(s0)
            for (i = 0; i < regs->x[12]; i++) {
ffffffe000201d7c:	fe043423          	sd	zero,-24(s0)
ffffffe000201d80:	0340006f          	j	ffffffe000201db4 <syscall+0x8c>
                printk("%c", buf[i]);
ffffffe000201d84:	fc843703          	ld	a4,-56(s0)
ffffffe000201d88:	fe843783          	ld	a5,-24(s0)
ffffffe000201d8c:	00f707b3          	add	a5,a4,a5
ffffffe000201d90:	0007c783          	lbu	a5,0(a5)
ffffffe000201d94:	0007879b          	sext.w	a5,a5
ffffffe000201d98:	00078593          	mv	a1,a5
ffffffe000201d9c:	00003517          	auipc	a0,0x3
ffffffe000201da0:	62450513          	addi	a0,a0,1572 # ffffffe0002053c0 <__func__.0+0x1a8>
ffffffe000201da4:	76c020ef          	jal	ra,ffffffe000204510 <printk>
            for (i = 0; i < regs->x[12]; i++) {
ffffffe000201da8:	fe843783          	ld	a5,-24(s0)
ffffffe000201dac:	00178793          	addi	a5,a5,1
ffffffe000201db0:	fef43423          	sd	a5,-24(s0)
ffffffe000201db4:	fb843783          	ld	a5,-72(s0)
ffffffe000201db8:	0607b783          	ld	a5,96(a5)
ffffffe000201dbc:	fe843703          	ld	a4,-24(s0)
ffffffe000201dc0:	fcf762e3          	bltu	a4,a5,ffffffe000201d84 <syscall+0x5c>
            }
        }
        regs->x[10] = i;
ffffffe000201dc4:	fb843783          	ld	a5,-72(s0)
ffffffe000201dc8:	fe843703          	ld	a4,-24(s0)
ffffffe000201dcc:	04e7b823          	sd	a4,80(a5)
        LogDEEPGREEN("Write: %d", i);
ffffffe000201dd0:	fe843703          	ld	a4,-24(s0)
ffffffe000201dd4:	00003697          	auipc	a3,0x3
ffffffe000201dd8:	22c68693          	addi	a3,a3,556 # ffffffe000205000 <__func__.3>
ffffffe000201ddc:	05700613          	li	a2,87
ffffffe000201de0:	00003597          	auipc	a1,0x3
ffffffe000201de4:	44858593          	addi	a1,a1,1096 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201de8:	00003517          	auipc	a0,0x3
ffffffe000201dec:	5e050513          	addi	a0,a0,1504 # ffffffe0002053c8 <__func__.0+0x1b0>
ffffffe000201df0:	720020ef          	jal	ra,ffffffe000204510 <printk>
        uint64_t pid = do_fork_cow(regs);
        LogYELLOW("[FORK] Parent PID = %d, Child PID = %d", current->pid, pid);
    } else {
        LogRED("Unsupported syscall: %d", syscall_num);
    }
    return;
ffffffe000201df4:	0d80006f          	j	ffffffe000201ecc <syscall+0x1a4>
    } else if (syscall_num == (uint64_t)SYS_GETPID) {
ffffffe000201df8:	fe043703          	ld	a4,-32(s0)
ffffffe000201dfc:	0ac00793          	li	a5,172
ffffffe000201e00:	04f71a63          	bne	a4,a5,ffffffe000201e54 <syscall+0x12c>
        regs->x[10] = current->pid;
ffffffe000201e04:	00009797          	auipc	a5,0x9
ffffffe000201e08:	20c78793          	addi	a5,a5,524 # ffffffe00020b010 <current>
ffffffe000201e0c:	0007b783          	ld	a5,0(a5)
ffffffe000201e10:	0187b703          	ld	a4,24(a5)
ffffffe000201e14:	fb843783          	ld	a5,-72(s0)
ffffffe000201e18:	04e7b823          	sd	a4,80(a5)
        LogDEEPGREEN("Getpid: %d", current->pid);
ffffffe000201e1c:	00009797          	auipc	a5,0x9
ffffffe000201e20:	1f478793          	addi	a5,a5,500 # ffffffe00020b010 <current>
ffffffe000201e24:	0007b783          	ld	a5,0(a5)
ffffffe000201e28:	0187b783          	ld	a5,24(a5)
ffffffe000201e2c:	00078713          	mv	a4,a5
ffffffe000201e30:	00003697          	auipc	a3,0x3
ffffffe000201e34:	1d068693          	addi	a3,a3,464 # ffffffe000205000 <__func__.3>
ffffffe000201e38:	05a00613          	li	a2,90
ffffffe000201e3c:	00003597          	auipc	a1,0x3
ffffffe000201e40:	3ec58593          	addi	a1,a1,1004 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201e44:	00003517          	auipc	a0,0x3
ffffffe000201e48:	5ac50513          	addi	a0,a0,1452 # ffffffe0002053f0 <__func__.0+0x1d8>
ffffffe000201e4c:	6c4020ef          	jal	ra,ffffffe000204510 <printk>
    return;
ffffffe000201e50:	07c0006f          	j	ffffffe000201ecc <syscall+0x1a4>
    } else if (syscall_num == (uint64_t)SYS_CLONE){
ffffffe000201e54:	fe043703          	ld	a4,-32(s0)
ffffffe000201e58:	0dc00793          	li	a5,220
ffffffe000201e5c:	04f71463          	bne	a4,a5,ffffffe000201ea4 <syscall+0x17c>
        uint64_t pid = do_fork_cow(regs);
ffffffe000201e60:	fb843503          	ld	a0,-72(s0)
ffffffe000201e64:	2ed000ef          	jal	ra,ffffffe000202950 <do_fork_cow>
ffffffe000201e68:	fca43c23          	sd	a0,-40(s0)
        LogYELLOW("[FORK] Parent PID = %d, Child PID = %d", current->pid, pid);
ffffffe000201e6c:	00009797          	auipc	a5,0x9
ffffffe000201e70:	1a478793          	addi	a5,a5,420 # ffffffe00020b010 <current>
ffffffe000201e74:	0007b783          	ld	a5,0(a5)
ffffffe000201e78:	0187b703          	ld	a4,24(a5)
ffffffe000201e7c:	fd843783          	ld	a5,-40(s0)
ffffffe000201e80:	00003697          	auipc	a3,0x3
ffffffe000201e84:	18068693          	addi	a3,a3,384 # ffffffe000205000 <__func__.3>
ffffffe000201e88:	05d00613          	li	a2,93
ffffffe000201e8c:	00003597          	auipc	a1,0x3
ffffffe000201e90:	39c58593          	addi	a1,a1,924 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201e94:	00003517          	auipc	a0,0x3
ffffffe000201e98:	58450513          	addi	a0,a0,1412 # ffffffe000205418 <__func__.0+0x200>
ffffffe000201e9c:	674020ef          	jal	ra,ffffffe000204510 <printk>
    return;
ffffffe000201ea0:	02c0006f          	j	ffffffe000201ecc <syscall+0x1a4>
        LogRED("Unsupported syscall: %d", syscall_num);
ffffffe000201ea4:	fe043703          	ld	a4,-32(s0)
ffffffe000201ea8:	00003697          	auipc	a3,0x3
ffffffe000201eac:	15868693          	addi	a3,a3,344 # ffffffe000205000 <__func__.3>
ffffffe000201eb0:	05f00613          	li	a2,95
ffffffe000201eb4:	00003597          	auipc	a1,0x3
ffffffe000201eb8:	37458593          	addi	a1,a1,884 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201ebc:	00003517          	auipc	a0,0x3
ffffffe000201ec0:	59c50513          	addi	a0,a0,1436 # ffffffe000205458 <__func__.0+0x240>
ffffffe000201ec4:	64c020ef          	jal	ra,ffffffe000204510 <printk>
    return;
ffffffe000201ec8:	00000013          	nop
}
ffffffe000201ecc:	04813083          	ld	ra,72(sp)
ffffffe000201ed0:	04013403          	ld	s0,64(sp)
ffffffe000201ed4:	05010113          	addi	sp,sp,80
ffffffe000201ed8:	00008067          	ret

ffffffe000201edc <do_page_fault>:


// vma 没有
// vma 有 但是 pgd没有
// vma 有 pgd 有 （检查权限冲突 若是则为cow）
void do_page_fault(struct pt_regs *regs) {
ffffffe000201edc:	f3010113          	addi	sp,sp,-208
ffffffe000201ee0:	0c113423          	sd	ra,200(sp)
ffffffe000201ee4:	0c813023          	sd	s0,192(sp)
ffffffe000201ee8:	0d010413          	addi	s0,sp,208
ffffffe000201eec:	f2a43c23          	sd	a0,-200(s0)
    uint64_t _stval = csr_read(stval);
ffffffe000201ef0:	143027f3          	csrr	a5,stval
ffffffe000201ef4:	fcf43423          	sd	a5,-56(s0)
ffffffe000201ef8:	fc843783          	ld	a5,-56(s0)
ffffffe000201efc:	fcf43023          	sd	a5,-64(s0)
    uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
ffffffe000201f00:	fc043703          	ld	a4,-64(s0)
ffffffe000201f04:	fffff7b7          	lui	a5,0xfffff
ffffffe000201f08:	00f777b3          	and	a5,a4,a5
ffffffe000201f0c:	faf43c23          	sd	a5,-72(s0)
    struct vm_area_struct *vma = find_vma(&current->mm, _stval);
ffffffe000201f10:	00009797          	auipc	a5,0x9
ffffffe000201f14:	10078793          	addi	a5,a5,256 # ffffffe00020b010 <current>
ffffffe000201f18:	0007b783          	ld	a5,0(a5)
ffffffe000201f1c:	0b078793          	addi	a5,a5,176
ffffffe000201f20:	fc043583          	ld	a1,-64(s0)
ffffffe000201f24:	00078513          	mv	a0,a5
ffffffe000201f28:	df4ff0ef          	jal	ra,ffffffe00020151c <find_vma>
ffffffe000201f2c:	faa43823          	sd	a0,-80(s0)
    if (!vma){  // vma 里面没有
ffffffe000201f30:	fb043783          	ld	a5,-80(s0)
ffffffe000201f34:	02079663          	bnez	a5,ffffffe000201f60 <do_page_fault+0x84>
        Err("No VMA found at 0x%llx", _stval);
ffffffe000201f38:	fc043703          	ld	a4,-64(s0)
ffffffe000201f3c:	00003697          	auipc	a3,0x3
ffffffe000201f40:	66c68693          	addi	a3,a3,1644 # ffffffe0002055a8 <__func__.2>
ffffffe000201f44:	07700613          	li	a2,119
ffffffe000201f48:	00003597          	auipc	a1,0x3
ffffffe000201f4c:	2e058593          	addi	a1,a1,736 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201f50:	00003517          	auipc	a0,0x3
ffffffe000201f54:	53850513          	addi	a0,a0,1336 # ffffffe000205488 <__func__.0+0x270>
ffffffe000201f58:	5b8020ef          	jal	ra,ffffffe000204510 <printk>
ffffffe000201f5c:	0000006f          	j	ffffffe000201f5c <do_page_fault+0x80>
        return;
    }
    uint64_t check = check_load(current->pgd, va);
ffffffe000201f60:	00009797          	auipc	a5,0x9
ffffffe000201f64:	0b078793          	addi	a5,a5,176 # ffffffe00020b010 <current>
ffffffe000201f68:	0007b783          	ld	a5,0(a5)
ffffffe000201f6c:	0a87b783          	ld	a5,168(a5)
ffffffe000201f70:	fb843583          	ld	a1,-72(s0)
ffffffe000201f74:	00078513          	mv	a0,a5
ffffffe000201f78:	041000ef          	jal	ra,ffffffe0002027b8 <check_load>
ffffffe000201f7c:	00050793          	mv	a5,a0
ffffffe000201f80:	faf43423          	sd	a5,-88(s0)
    if (!check){
ffffffe000201f84:	fa843783          	ld	a5,-88(s0)
ffffffe000201f88:	38079463          	bnez	a5,ffffffe000202310 <do_page_fault+0x434>
        uint64_t perm = (vma->vm_flags & VM_READ) | (vma->vm_flags & VM_EXEC) | (vma->vm_flags & VM_WRITE) | PTE_U | PTE_V; 
ffffffe000201f8c:	fb043783          	ld	a5,-80(s0)
ffffffe000201f90:	0287b783          	ld	a5,40(a5)
ffffffe000201f94:	00e7f793          	andi	a5,a5,14
ffffffe000201f98:	0117e793          	ori	a5,a5,17
ffffffe000201f9c:	f8f43823          	sd	a5,-112(s0)
        if (vma->vm_flags & VM_ANON){
ffffffe000201fa0:	fb043783          	ld	a5,-80(s0)
ffffffe000201fa4:	0287b783          	ld	a5,40(a5)
ffffffe000201fa8:	0017f793          	andi	a5,a5,1
ffffffe000201fac:	06078663          	beqz	a5,ffffffe000202018 <do_page_fault+0x13c>
            LogDEEPGREEN("ANON");
ffffffe000201fb0:	00003697          	auipc	a3,0x3
ffffffe000201fb4:	5f868693          	addi	a3,a3,1528 # ffffffe0002055a8 <__func__.2>
ffffffe000201fb8:	07e00613          	li	a2,126
ffffffe000201fbc:	00003597          	auipc	a1,0x3
ffffffe000201fc0:	26c58593          	addi	a1,a1,620 # ffffffe000205228 <__func__.0+0x10>
ffffffe000201fc4:	00003517          	auipc	a0,0x3
ffffffe000201fc8:	4f450513          	addi	a0,a0,1268 # ffffffe0002054b8 <__func__.0+0x2a0>
ffffffe000201fcc:	544020ef          	jal	ra,ffffffe000204510 <printk>
            // uint64_t va = (uint64_t)PGROUNDDOWN(_stval);
            uint64_t pa = VA2PA((uint64_t)alloc_page());
ffffffe000201fd0:	c69fe0ef          	jal	ra,ffffffe000200c38 <alloc_page>
ffffffe000201fd4:	00050793          	mv	a5,a0
ffffffe000201fd8:	00078713          	mv	a4,a5
ffffffe000201fdc:	04100793          	li	a5,65
ffffffe000201fe0:	01f79793          	slli	a5,a5,0x1f
ffffffe000201fe4:	00f707b3          	add	a5,a4,a5
ffffffe000201fe8:	f4f43023          	sd	a5,-192(s0)
            create_mapping(current->pgd, va, pa, PGSIZE, perm);
ffffffe000201fec:	00009797          	auipc	a5,0x9
ffffffe000201ff0:	02478793          	addi	a5,a5,36 # ffffffe00020b010 <current>
ffffffe000201ff4:	0007b783          	ld	a5,0(a5)
ffffffe000201ff8:	0a87b783          	ld	a5,168(a5)
ffffffe000201ffc:	f9043703          	ld	a4,-112(s0)
ffffffe000202000:	000016b7          	lui	a3,0x1
ffffffe000202004:	f4043603          	ld	a2,-192(s0)
ffffffe000202008:	fb843583          	ld	a1,-72(s0)
ffffffe00020200c:	00078513          	mv	a0,a5
ffffffe000202010:	384010ef          	jal	ra,ffffffe000203394 <create_mapping>
                for(uint64_t i = 0; i < PGSIZE; i++) cuapp[i] = celf[i];
            }

            create_mapping(current->pgd, va, VA2PA((uint64_t)uapp), PGSIZE, perm);
        }
        return;
ffffffe000202014:	4180006f          	j	ffffffe00020242c <do_page_fault+0x550>
            LogDEEPGREEN("FILE");
ffffffe000202018:	00003697          	auipc	a3,0x3
ffffffe00020201c:	59068693          	addi	a3,a3,1424 # ffffffe0002055a8 <__func__.2>
ffffffe000202020:	08300613          	li	a2,131
ffffffe000202024:	00003597          	auipc	a1,0x3
ffffffe000202028:	20458593          	addi	a1,a1,516 # ffffffe000205228 <__func__.0+0x10>
ffffffe00020202c:	00003517          	auipc	a0,0x3
ffffffe000202030:	4ac50513          	addi	a0,a0,1196 # ffffffe0002054d8 <__func__.0+0x2c0>
ffffffe000202034:	4dc020ef          	jal	ra,ffffffe000204510 <printk>
            uint64_t *uapp = (uint64_t*)alloc_page();
ffffffe000202038:	c01fe0ef          	jal	ra,ffffffe000200c38 <alloc_page>
ffffffe00020203c:	f8a43423          	sd	a0,-120(s0)
            if (PGROUNDDOWN(vma->vm_filesz) < PGSIZE){ // 整个uapp小于一页
ffffffe000202040:	fb043783          	ld	a5,-80(s0)
ffffffe000202044:	0387b703          	ld	a4,56(a5)
ffffffe000202048:	fffff7b7          	lui	a5,0xfffff
ffffffe00020204c:	00f77733          	and	a4,a4,a5
ffffffe000202050:	000017b7          	lui	a5,0x1
ffffffe000202054:	08f77863          	bgeu	a4,a5,ffffffe0002020e4 <do_page_fault+0x208>
                char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
ffffffe000202058:	fb043783          	ld	a5,-80(s0)
ffffffe00020205c:	0087b703          	ld	a4,8(a5) # 1008 <PGSIZE+0x8>
ffffffe000202060:	000017b7          	lui	a5,0x1
ffffffe000202064:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202068:	00f777b3          	and	a5,a4,a5
ffffffe00020206c:	f8843703          	ld	a4,-120(s0)
ffffffe000202070:	00f707b3          	add	a5,a4,a5
ffffffe000202074:	f4f43823          	sd	a5,-176(s0)
                char *celf = (char*)_sramdisk + (vma->vm_start & 0xfff);
ffffffe000202078:	fb043783          	ld	a5,-80(s0)
ffffffe00020207c:	0087b703          	ld	a4,8(a5)
ffffffe000202080:	000017b7          	lui	a5,0x1
ffffffe000202084:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202088:	00f77733          	and	a4,a4,a5
ffffffe00020208c:	00005797          	auipc	a5,0x5
ffffffe000202090:	f7478793          	addi	a5,a5,-140 # ffffffe000207000 <_sramdisk>
ffffffe000202094:	00f707b3          	add	a5,a4,a5
ffffffe000202098:	f4f43423          	sd	a5,-184(s0)
                for(uint64_t i = 0; i < vma->vm_filesz; i++) cuapp[i] = celf[i];
ffffffe00020209c:	fe043423          	sd	zero,-24(s0)
ffffffe0002020a0:	0300006f          	j	ffffffe0002020d0 <do_page_fault+0x1f4>
ffffffe0002020a4:	f4843703          	ld	a4,-184(s0)
ffffffe0002020a8:	fe843783          	ld	a5,-24(s0)
ffffffe0002020ac:	00f70733          	add	a4,a4,a5
ffffffe0002020b0:	f5043683          	ld	a3,-176(s0)
ffffffe0002020b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002020b8:	00f687b3          	add	a5,a3,a5
ffffffe0002020bc:	00074703          	lbu	a4,0(a4) # 1000 <PGSIZE>
ffffffe0002020c0:	00e78023          	sb	a4,0(a5)
ffffffe0002020c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002020c8:	00178793          	addi	a5,a5,1
ffffffe0002020cc:	fef43423          	sd	a5,-24(s0)
ffffffe0002020d0:	fb043783          	ld	a5,-80(s0)
ffffffe0002020d4:	0387b783          	ld	a5,56(a5)
ffffffe0002020d8:	fe843703          	ld	a4,-24(s0)
ffffffe0002020dc:	fcf764e3          	bltu	a4,a5,ffffffe0002020a4 <do_page_fault+0x1c8>
ffffffe0002020e0:	1f80006f          	j	ffffffe0002022d8 <do_page_fault+0x3fc>
            }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start)){ // 从头开始
ffffffe0002020e4:	fb043783          	ld	a5,-80(s0)
ffffffe0002020e8:	0087b703          	ld	a4,8(a5)
ffffffe0002020ec:	fb843783          	ld	a5,-72(s0)
ffffffe0002020f0:	00f74733          	xor	a4,a4,a5
ffffffe0002020f4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002020f8:	00f777b3          	and	a5,a4,a5
ffffffe0002020fc:	0a079063          	bnez	a5,ffffffe00020219c <do_page_fault+0x2c0>
                char *cuapp = (char*)uapp + (vma->vm_start & 0xfff);
ffffffe000202100:	fb043783          	ld	a5,-80(s0)
ffffffe000202104:	0087b703          	ld	a4,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe000202108:	000017b7          	lui	a5,0x1
ffffffe00020210c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202110:	00f777b3          	and	a5,a4,a5
ffffffe000202114:	f8843703          	ld	a4,-120(s0)
ffffffe000202118:	00f707b3          	add	a5,a4,a5
ffffffe00020211c:	f6f43023          	sd	a5,-160(s0)
                char *celf = (char*)_sramdisk + (vma->vm_start & 0xfff);
ffffffe000202120:	fb043783          	ld	a5,-80(s0)
ffffffe000202124:	0087b703          	ld	a4,8(a5)
ffffffe000202128:	000017b7          	lui	a5,0x1
ffffffe00020212c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202130:	00f77733          	and	a4,a4,a5
ffffffe000202134:	00005797          	auipc	a5,0x5
ffffffe000202138:	ecc78793          	addi	a5,a5,-308 # ffffffe000207000 <_sramdisk>
ffffffe00020213c:	00f707b3          	add	a5,a4,a5
ffffffe000202140:	f4f43c23          	sd	a5,-168(s0)
                for(i = 0; i < (PGSIZE - vma->vm_start & 0xfff); i++) {
ffffffe000202144:	fe042223          	sw	zero,-28(s0)
ffffffe000202148:	0300006f          	j	ffffffe000202178 <do_page_fault+0x29c>
                    cuapp[i] = celf[i];
ffffffe00020214c:	fe442783          	lw	a5,-28(s0)
ffffffe000202150:	f5843703          	ld	a4,-168(s0)
ffffffe000202154:	00f70733          	add	a4,a4,a5
ffffffe000202158:	fe442783          	lw	a5,-28(s0)
ffffffe00020215c:	f6043683          	ld	a3,-160(s0)
ffffffe000202160:	00f687b3          	add	a5,a3,a5
ffffffe000202164:	00074703          	lbu	a4,0(a4)
ffffffe000202168:	00e78023          	sb	a4,0(a5)
                for(i = 0; i < (PGSIZE - vma->vm_start & 0xfff); i++) {
ffffffe00020216c:	fe442783          	lw	a5,-28(s0)
ffffffe000202170:	0017879b          	addiw	a5,a5,1
ffffffe000202174:	fef42223          	sw	a5,-28(s0)
ffffffe000202178:	fe442703          	lw	a4,-28(s0)
ffffffe00020217c:	fb043783          	ld	a5,-80(s0)
ffffffe000202180:	0087b783          	ld	a5,8(a5)
ffffffe000202184:	40f006b3          	neg	a3,a5
ffffffe000202188:	000017b7          	lui	a5,0x1
ffffffe00020218c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202190:	00f6f7b3          	and	a5,a3,a5
ffffffe000202194:	faf76ce3          	bltu	a4,a5,ffffffe00020214c <do_page_fault+0x270>
ffffffe000202198:	1400006f          	j	ffffffe0002022d8 <do_page_fault+0x3fc>
            }else if(PGROUNDDOWN(va) == PGROUNDDOWN(vma->vm_start + vma->vm_filesz - 1)){ // 最后一页
ffffffe00020219c:	fb043783          	ld	a5,-80(s0)
ffffffe0002021a0:	0087b703          	ld	a4,8(a5)
ffffffe0002021a4:	fb043783          	ld	a5,-80(s0)
ffffffe0002021a8:	0387b783          	ld	a5,56(a5)
ffffffe0002021ac:	00f707b3          	add	a5,a4,a5
ffffffe0002021b0:	fff78713          	addi	a4,a5,-1
ffffffe0002021b4:	fb843783          	ld	a5,-72(s0)
ffffffe0002021b8:	00f74733          	xor	a4,a4,a5
ffffffe0002021bc:	fffff7b7          	lui	a5,0xfffff
ffffffe0002021c0:	00f777b3          	and	a5,a4,a5
ffffffe0002021c4:	08079e63          	bnez	a5,ffffffe000202260 <do_page_fault+0x384>
                char *cuapp = (char*)uapp;
ffffffe0002021c8:	f8843783          	ld	a5,-120(s0)
ffffffe0002021cc:	f6f43823          	sd	a5,-144(s0)
                char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(va) - PGROUNDDOWN(vma->vm_start));
ffffffe0002021d0:	fb843703          	ld	a4,-72(s0)
ffffffe0002021d4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002021d8:	00f77733          	and	a4,a4,a5
ffffffe0002021dc:	fb043783          	ld	a5,-80(s0)
ffffffe0002021e0:	0087b683          	ld	a3,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe0002021e4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002021e8:	00f6f7b3          	and	a5,a3,a5
ffffffe0002021ec:	40f70733          	sub	a4,a4,a5
ffffffe0002021f0:	00005797          	auipc	a5,0x5
ffffffe0002021f4:	e1078793          	addi	a5,a5,-496 # ffffffe000207000 <_sramdisk>
ffffffe0002021f8:	00f707b3          	add	a5,a4,a5
ffffffe0002021fc:	f6f43423          	sd	a5,-152(s0)
                for(uint64_t i = 0; i <= ((vma->vm_start + vma->vm_filesz) & 0xfff); i++) cuapp[i] = celf[i];
ffffffe000202200:	fc043c23          	sd	zero,-40(s0)
ffffffe000202204:	0300006f          	j	ffffffe000202234 <do_page_fault+0x358>
ffffffe000202208:	f6843703          	ld	a4,-152(s0)
ffffffe00020220c:	fd843783          	ld	a5,-40(s0)
ffffffe000202210:	00f70733          	add	a4,a4,a5
ffffffe000202214:	f7043683          	ld	a3,-144(s0)
ffffffe000202218:	fd843783          	ld	a5,-40(s0)
ffffffe00020221c:	00f687b3          	add	a5,a3,a5
ffffffe000202220:	00074703          	lbu	a4,0(a4)
ffffffe000202224:	00e78023          	sb	a4,0(a5)
ffffffe000202228:	fd843783          	ld	a5,-40(s0)
ffffffe00020222c:	00178793          	addi	a5,a5,1
ffffffe000202230:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202234:	fb043783          	ld	a5,-80(s0)
ffffffe000202238:	0087b703          	ld	a4,8(a5)
ffffffe00020223c:	fb043783          	ld	a5,-80(s0)
ffffffe000202240:	0387b783          	ld	a5,56(a5)
ffffffe000202244:	00f70733          	add	a4,a4,a5
ffffffe000202248:	000017b7          	lui	a5,0x1
ffffffe00020224c:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202250:	00f777b3          	and	a5,a4,a5
ffffffe000202254:	fd843703          	ld	a4,-40(s0)
ffffffe000202258:	fae7f8e3          	bgeu	a5,a4,ffffffe000202208 <do_page_fault+0x32c>
ffffffe00020225c:	07c0006f          	j	ffffffe0002022d8 <do_page_fault+0x3fc>
                char *cuapp = (char*)uapp;
ffffffe000202260:	f8843783          	ld	a5,-120(s0)
ffffffe000202264:	f8f43023          	sd	a5,-128(s0)
                char *celf = (char*)((uint64_t)_sramdisk + PGROUNDDOWN(va) - PGROUNDDOWN(vma->vm_start));
ffffffe000202268:	fb843703          	ld	a4,-72(s0)
ffffffe00020226c:	fffff7b7          	lui	a5,0xfffff
ffffffe000202270:	00f77733          	and	a4,a4,a5
ffffffe000202274:	fb043783          	ld	a5,-80(s0)
ffffffe000202278:	0087b683          	ld	a3,8(a5) # fffffffffffff008 <VM_END+0xfffff008>
ffffffe00020227c:	fffff7b7          	lui	a5,0xfffff
ffffffe000202280:	00f6f7b3          	and	a5,a3,a5
ffffffe000202284:	40f70733          	sub	a4,a4,a5
ffffffe000202288:	00005797          	auipc	a5,0x5
ffffffe00020228c:	d7878793          	addi	a5,a5,-648 # ffffffe000207000 <_sramdisk>
ffffffe000202290:	00f707b3          	add	a5,a4,a5
ffffffe000202294:	f6f43c23          	sd	a5,-136(s0)
                for(uint64_t i = 0; i < PGSIZE; i++) cuapp[i] = celf[i];
ffffffe000202298:	fc043823          	sd	zero,-48(s0)
ffffffe00020229c:	0300006f          	j	ffffffe0002022cc <do_page_fault+0x3f0>
ffffffe0002022a0:	f7843703          	ld	a4,-136(s0)
ffffffe0002022a4:	fd043783          	ld	a5,-48(s0)
ffffffe0002022a8:	00f70733          	add	a4,a4,a5
ffffffe0002022ac:	f8043683          	ld	a3,-128(s0)
ffffffe0002022b0:	fd043783          	ld	a5,-48(s0)
ffffffe0002022b4:	00f687b3          	add	a5,a3,a5
ffffffe0002022b8:	00074703          	lbu	a4,0(a4)
ffffffe0002022bc:	00e78023          	sb	a4,0(a5)
ffffffe0002022c0:	fd043783          	ld	a5,-48(s0)
ffffffe0002022c4:	00178793          	addi	a5,a5,1
ffffffe0002022c8:	fcf43823          	sd	a5,-48(s0)
ffffffe0002022cc:	fd043703          	ld	a4,-48(s0)
ffffffe0002022d0:	000017b7          	lui	a5,0x1
ffffffe0002022d4:	fcf766e3          	bltu	a4,a5,ffffffe0002022a0 <do_page_fault+0x3c4>
            create_mapping(current->pgd, va, VA2PA((uint64_t)uapp), PGSIZE, perm);
ffffffe0002022d8:	00009797          	auipc	a5,0x9
ffffffe0002022dc:	d3878793          	addi	a5,a5,-712 # ffffffe00020b010 <current>
ffffffe0002022e0:	0007b783          	ld	a5,0(a5)
ffffffe0002022e4:	0a87b503          	ld	a0,168(a5)
ffffffe0002022e8:	f8843703          	ld	a4,-120(s0)
ffffffe0002022ec:	04100793          	li	a5,65
ffffffe0002022f0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002022f4:	00f707b3          	add	a5,a4,a5
ffffffe0002022f8:	f9043703          	ld	a4,-112(s0)
ffffffe0002022fc:	000016b7          	lui	a3,0x1
ffffffe000202300:	00078613          	mv	a2,a5
ffffffe000202304:	fb843583          	ld	a1,-72(s0)
ffffffe000202308:	08c010ef          	jal	ra,ffffffe000203394 <create_mapping>
        return;
ffffffe00020230c:	1200006f          	j	ffffffe00020242c <do_page_fault+0x550>
    }
    // LogYELLOW("check = 0x%llx", check);
    if ((vma->vm_flags & VM_WRITE) && !(check & PTE_W)){
ffffffe000202310:	fb043783          	ld	a5,-80(s0)
ffffffe000202314:	0287b783          	ld	a5,40(a5)
ffffffe000202318:	0047f793          	andi	a5,a5,4
ffffffe00020231c:	10078863          	beqz	a5,ffffffe00020242c <do_page_fault+0x550>
ffffffe000202320:	fa843783          	ld	a5,-88(s0)
ffffffe000202324:	0047f793          	andi	a5,a5,4
ffffffe000202328:	10079263          	bnez	a5,ffffffe00020242c <do_page_fault+0x550>
        // if (perm & perm != 0xfff){
        //     LogYELLOW("[COW]");
        //     page_cow(current->pgd, va, perm);
        // }
        // LogYELLOW("[COW]");
        uint64_t entry = pte_entry_ret(current->pgd, va);
ffffffe00020232c:	00009797          	auipc	a5,0x9
ffffffe000202330:	ce478793          	addi	a5,a5,-796 # ffffffe00020b010 <current>
ffffffe000202334:	0007b783          	ld	a5,0(a5)
ffffffe000202338:	0a87b783          	ld	a5,168(a5)
ffffffe00020233c:	fb843583          	ld	a1,-72(s0)
ffffffe000202340:	00078513          	mv	a0,a5
ffffffe000202344:	175000ef          	jal	ra,ffffffe000202cb8 <pte_entry_ret>
ffffffe000202348:	faa43023          	sd	a0,-96(s0)
        // LogBLUE("pa = 0x%llx, va = 0x%llx", ((entry >> 10) << 12) | (_stval & 0xfff), _stval);
        uint64_t num = get_page_refcnt(PA2VA(((entry >> 10) << 12)));
ffffffe00020234c:	fa043783          	ld	a5,-96(s0)
ffffffe000202350:	00a7d793          	srli	a5,a5,0xa
ffffffe000202354:	00c79713          	slli	a4,a5,0xc
ffffffe000202358:	fbf00793          	li	a5,-65
ffffffe00020235c:	01f79793          	slli	a5,a5,0x1f
ffffffe000202360:	00f707b3          	add	a5,a4,a5
ffffffe000202364:	00078513          	mv	a0,a5
ffffffe000202368:	fbcfe0ef          	jal	ra,ffffffe000200b24 <get_page_refcnt>
ffffffe00020236c:	f8a43c23          	sd	a0,-104(s0)
        if (num == 1){
ffffffe000202370:	f9843703          	ld	a4,-104(s0)
ffffffe000202374:	00100793          	li	a5,1
ffffffe000202378:	04f71c63          	bne	a4,a5,ffffffe0002023d0 <do_page_fault+0x4f4>
            LogYELLOW("[COW] PID = %d JUST CHANGE PERM", current->pid);
ffffffe00020237c:	00009797          	auipc	a5,0x9
ffffffe000202380:	c9478793          	addi	a5,a5,-876 # ffffffe00020b010 <current>
ffffffe000202384:	0007b783          	ld	a5,0(a5)
ffffffe000202388:	0187b783          	ld	a5,24(a5)
ffffffe00020238c:	00078713          	mv	a4,a5
ffffffe000202390:	00003697          	auipc	a3,0x3
ffffffe000202394:	21868693          	addi	a3,a3,536 # ffffffe0002055a8 <__func__.2>
ffffffe000202398:	0b000613          	li	a2,176
ffffffe00020239c:	00003597          	auipc	a1,0x3
ffffffe0002023a0:	e8c58593          	addi	a1,a1,-372 # ffffffe000205228 <__func__.0+0x10>
ffffffe0002023a4:	00003517          	auipc	a0,0x3
ffffffe0002023a8:	15450513          	addi	a0,a0,340 # ffffffe0002054f8 <__func__.0+0x2e0>
ffffffe0002023ac:	164020ef          	jal	ra,ffffffe000204510 <printk>
            // page_cow(current->pgd, va, check);
            change_perm(current->pgd, _stval);
ffffffe0002023b0:	00009797          	auipc	a5,0x9
ffffffe0002023b4:	c6078793          	addi	a5,a5,-928 # ffffffe00020b010 <current>
ffffffe0002023b8:	0007b783          	ld	a5,0(a5)
ffffffe0002023bc:	0a87b783          	ld	a5,168(a5)
ffffffe0002023c0:	fc043583          	ld	a1,-64(s0)
ffffffe0002023c4:	00078513          	mv	a0,a5
ffffffe0002023c8:	3f9000ef          	jal	ra,ffffffe000202fc0 <change_perm>
ffffffe0002023cc:	0600006f          	j	ffffffe00020242c <do_page_fault+0x550>
        }else{
            LogYELLOW("[COW] PID = %d COPY PAGE", current->pid);
ffffffe0002023d0:	00009797          	auipc	a5,0x9
ffffffe0002023d4:	c4078793          	addi	a5,a5,-960 # ffffffe00020b010 <current>
ffffffe0002023d8:	0007b783          	ld	a5,0(a5)
ffffffe0002023dc:	0187b783          	ld	a5,24(a5)
ffffffe0002023e0:	00078713          	mv	a4,a5
ffffffe0002023e4:	00003697          	auipc	a3,0x3
ffffffe0002023e8:	1c468693          	addi	a3,a3,452 # ffffffe0002055a8 <__func__.2>
ffffffe0002023ec:	0b400613          	li	a2,180
ffffffe0002023f0:	00003597          	auipc	a1,0x3
ffffffe0002023f4:	e3858593          	addi	a1,a1,-456 # ffffffe000205228 <__func__.0+0x10>
ffffffe0002023f8:	00003517          	auipc	a0,0x3
ffffffe0002023fc:	13850513          	addi	a0,a0,312 # ffffffe000205530 <__func__.0+0x318>
ffffffe000202400:	110020ef          	jal	ra,ffffffe000204510 <printk>
            // change_perm(current->pgd, _stval);
            // char *new_page = (char*)alloc_page();
            // LogBLUE("pa = 0x%llx, va = 0x%llx", VA2PA((uint64_t*)new_page), _stval);
            page_cow(current->pgd, va, check | PTE_W);
ffffffe000202404:	00009797          	auipc	a5,0x9
ffffffe000202408:	c0c78793          	addi	a5,a5,-1012 # ffffffe00020b010 <current>
ffffffe00020240c:	0007b783          	ld	a5,0(a5)
ffffffe000202410:	0a87b703          	ld	a4,168(a5)
ffffffe000202414:	fa843783          	ld	a5,-88(s0)
ffffffe000202418:	0047e793          	ori	a5,a5,4
ffffffe00020241c:	00078613          	mv	a2,a5
ffffffe000202420:	fb843583          	ld	a1,-72(s0)
ffffffe000202424:	00070513          	mv	a0,a4
ffffffe000202428:	295000ef          	jal	ra,ffffffe000202ebc <page_cow>
        }
    }
}
ffffffe00020242c:	0c813083          	ld	ra,200(sp)
ffffffe000202430:	0c013403          	ld	s0,192(sp)
ffffffe000202434:	0d010113          	addi	sp,sp,208
ffffffe000202438:	00008067          	ret

ffffffe00020243c <do_fork>:

uint64_t do_fork(struct pt_regs *regs){
ffffffe00020243c:	f3010113          	addi	sp,sp,-208
ffffffe000202440:	0c113423          	sd	ra,200(sp)
ffffffe000202444:	0c813023          	sd	s0,192(sp)
ffffffe000202448:	0d010413          	addi	s0,sp,208
ffffffe00020244c:	f2a43c23          	sd	a0,-200(s0)
    struct task_struct *ptask = (struct task_struct*)kalloc();
ffffffe000202450:	85dfe0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe000202454:	faa43c23          	sd	a0,-72(s0)
    // _sstatus |= (1 << 5);
    // _sstatus |= (1 << 18); 
    // ptask->thread.sstatus = _sstatus;

    // ptask->thread.sscratch = (uint64_t)USER_END;
    char *ccurrent_task = (char*)current;
ffffffe000202458:	00009797          	auipc	a5,0x9
ffffffe00020245c:	bb878793          	addi	a5,a5,-1096 # ffffffe00020b010 <current>
ffffffe000202460:	0007b783          	ld	a5,0(a5)
ffffffe000202464:	faf43823          	sd	a5,-80(s0)
    char *cptask = (char*)ptask;
ffffffe000202468:	fb843783          	ld	a5,-72(s0)
ffffffe00020246c:	faf43423          	sd	a5,-88(s0)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202470:	fe043423          	sd	zero,-24(s0)
ffffffe000202474:	0300006f          	j	ffffffe0002024a4 <do_fork+0x68>
        cptask[i] = ccurrent_task[i];
ffffffe000202478:	fb043703          	ld	a4,-80(s0)
ffffffe00020247c:	fe843783          	ld	a5,-24(s0)
ffffffe000202480:	00f70733          	add	a4,a4,a5
ffffffe000202484:	fa843683          	ld	a3,-88(s0)
ffffffe000202488:	fe843783          	ld	a5,-24(s0)
ffffffe00020248c:	00f687b3          	add	a5,a3,a5
ffffffe000202490:	00074703          	lbu	a4,0(a4)
ffffffe000202494:	00e78023          	sb	a4,0(a5)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202498:	fe843783          	ld	a5,-24(s0)
ffffffe00020249c:	00178793          	addi	a5,a5,1
ffffffe0002024a0:	fef43423          	sd	a5,-24(s0)
ffffffe0002024a4:	fe843703          	ld	a4,-24(s0)
ffffffe0002024a8:	000017b7          	lui	a5,0x1
ffffffe0002024ac:	fcf766e3          	bltu	a4,a5,ffffffe000202478 <do_fork+0x3c>
    }
    ptask->pid = nr_tasks;
ffffffe0002024b0:	00004797          	auipc	a5,0x4
ffffffe0002024b4:	b6078793          	addi	a5,a5,-1184 # ffffffe000206010 <nr_tasks>
ffffffe0002024b8:	0007b703          	ld	a4,0(a5)
ffffffe0002024bc:	fb843783          	ld	a5,-72(s0)
ffffffe0002024c0:	00e7bc23          	sd	a4,24(a5)
    ptask->thread.ra = __ret_from_fork;
ffffffe0002024c4:	ffffe717          	auipc	a4,0xffffe
ffffffe0002024c8:	c8470713          	addi	a4,a4,-892 # ffffffe000200148 <__ret_from_fork>
ffffffe0002024cc:	fb843783          	ld	a5,-72(s0)
ffffffe0002024d0:	02e7b023          	sd	a4,32(a5)
    ptask->thread.sp = (uint64_t)ptask + (uint64_t)regs - PGROUNDDOWN((uint64_t)regs); // ??
ffffffe0002024d4:	fb843703          	ld	a4,-72(s0)
ffffffe0002024d8:	f3843783          	ld	a5,-200(s0)
ffffffe0002024dc:	00f70733          	add	a4,a4,a5
ffffffe0002024e0:	f3843683          	ld	a3,-200(s0)
ffffffe0002024e4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002024e8:	00f6f7b3          	and	a5,a3,a5
ffffffe0002024ec:	40f70733          	sub	a4,a4,a5
ffffffe0002024f0:	fb843783          	ld	a5,-72(s0)
ffffffe0002024f4:	02e7b423          	sd	a4,40(a5) # fffffffffffff028 <VM_END+0xfffff028>
    //ptask sscratch
    // LogBLUE("ptask->thread.sscratch = 0x%llx", ptask->thread.sscratch);
    // uint64_t _sscratch = csr_read(sscratch);
    // LogBLUE("sscratch = 0x%llx", _sscratch);
    ptask->thread.sscratch = csr_read(sscratch);
ffffffe0002024f8:	140027f3          	csrr	a5,sscratch
ffffffe0002024fc:	faf43023          	sd	a5,-96(s0)
ffffffe000202500:	fa043703          	ld	a4,-96(s0)
ffffffe000202504:	fb843783          	ld	a5,-72(s0)
ffffffe000202508:	0ae7b023          	sd	a4,160(a5)
    struct pt_regs *ptregs = (struct pt_regs*)((uint64_t)regs - (uint64_t)current + (uint64_t)ptask);
ffffffe00020250c:	f3843783          	ld	a5,-200(s0)
ffffffe000202510:	00009717          	auipc	a4,0x9
ffffffe000202514:	b0070713          	addi	a4,a4,-1280 # ffffffe00020b010 <current>
ffffffe000202518:	00073703          	ld	a4,0(a4)
ffffffe00020251c:	40e78733          	sub	a4,a5,a4
ffffffe000202520:	fb843783          	ld	a5,-72(s0)
ffffffe000202524:	00f707b3          	add	a5,a4,a5
ffffffe000202528:	f8f43c23          	sd	a5,-104(s0)
    ptregs->x[10] = 0;  
ffffffe00020252c:	f9843783          	ld	a5,-104(s0)
ffffffe000202530:	0407b823          	sd	zero,80(a5)
    ptregs->x[2] = ptask->thread.sp;
ffffffe000202534:	fb843783          	ld	a5,-72(s0)
ffffffe000202538:	0287b703          	ld	a4,40(a5)
ffffffe00020253c:	f9843783          	ld	a5,-104(s0)
ffffffe000202540:	00e7b823          	sd	a4,16(a5)
    ptask->thread.sepc = csr_read(sepc) + 4;
ffffffe000202544:	141027f3          	csrr	a5,sepc
ffffffe000202548:	f8f43823          	sd	a5,-112(s0)
ffffffe00020254c:	f9043783          	ld	a5,-112(s0)
ffffffe000202550:	00478713          	addi	a4,a5,4
ffffffe000202554:	fb843783          	ld	a5,-72(s0)
ffffffe000202558:	08e7b823          	sd	a4,144(a5)

    ptask->pgd = (uint64_t*)alloc_page();
ffffffe00020255c:	edcfe0ef          	jal	ra,ffffffe000200c38 <alloc_page>
ffffffe000202560:	00050713          	mv	a4,a0
ffffffe000202564:	fb843783          	ld	a5,-72(s0)
ffffffe000202568:	0ae7b423          	sd	a4,168(a5)
    char *cpgtbl = (char*)ptask->pgd;
ffffffe00020256c:	fb843783          	ld	a5,-72(s0)
ffffffe000202570:	0a87b783          	ld	a5,168(a5)
ffffffe000202574:	f8f43423          	sd	a5,-120(s0)
    char *cearly_pgtbl = (char*)swapper_pg_dir;
ffffffe000202578:	0000b797          	auipc	a5,0xb
ffffffe00020257c:	a8878793          	addi	a5,a5,-1400 # ffffffe00020d000 <swapper_pg_dir>
ffffffe000202580:	f8f43023          	sd	a5,-128(s0)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202584:	fe043023          	sd	zero,-32(s0)
ffffffe000202588:	0300006f          	j	ffffffe0002025b8 <do_fork+0x17c>
        cpgtbl[i] = cearly_pgtbl[i];
ffffffe00020258c:	f8043703          	ld	a4,-128(s0)
ffffffe000202590:	fe043783          	ld	a5,-32(s0)
ffffffe000202594:	00f70733          	add	a4,a4,a5
ffffffe000202598:	f8843683          	ld	a3,-120(s0)
ffffffe00020259c:	fe043783          	ld	a5,-32(s0)
ffffffe0002025a0:	00f687b3          	add	a5,a3,a5
ffffffe0002025a4:	00074703          	lbu	a4,0(a4)
ffffffe0002025a8:	00e78023          	sb	a4,0(a5)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002025ac:	fe043783          	ld	a5,-32(s0)
ffffffe0002025b0:	00178793          	addi	a5,a5,1
ffffffe0002025b4:	fef43023          	sd	a5,-32(s0)
ffffffe0002025b8:	fe043703          	ld	a4,-32(s0)
ffffffe0002025bc:	000017b7          	lui	a5,0x1
ffffffe0002025c0:	fcf766e3          	bltu	a4,a5,ffffffe00020258c <do_fork+0x150>
    }

    /*DEEP COPY*/
    ptask->mm.mmap = NULL;
ffffffe0002025c4:	fb843783          	ld	a5,-72(s0)
ffffffe0002025c8:	0a07b823          	sd	zero,176(a5) # 10b0 <PGSIZE+0xb0>
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
ffffffe0002025cc:	00009797          	auipc	a5,0x9
ffffffe0002025d0:	a4478793          	addi	a5,a5,-1468 # ffffffe00020b010 <current>
ffffffe0002025d4:	0007b783          	ld	a5,0(a5)
ffffffe0002025d8:	0b07b783          	ld	a5,176(a5)
ffffffe0002025dc:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002025e0:	1740006f          	j	ffffffe000202754 <do_fork+0x318>
        struct vm_area_struct *new_vma = (struct vm_area_struct*)kalloc();
ffffffe0002025e4:	ec8fe0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe0002025e8:	f6a43c23          	sd	a0,-136(s0)
        char *cvma = (char*)vma;
ffffffe0002025ec:	fd843783          	ld	a5,-40(s0)
ffffffe0002025f0:	f6f43823          	sd	a5,-144(s0)
        char *cnew_vma = (char*)new_vma;
ffffffe0002025f4:	f7843783          	ld	a5,-136(s0)
ffffffe0002025f8:	f6f43423          	sd	a5,-152(s0)
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
ffffffe0002025fc:	fc043823          	sd	zero,-48(s0)
ffffffe000202600:	0300006f          	j	ffffffe000202630 <do_fork+0x1f4>
            cnew_vma[i] = cvma[i];
ffffffe000202604:	f7043703          	ld	a4,-144(s0)
ffffffe000202608:	fd043783          	ld	a5,-48(s0)
ffffffe00020260c:	00f70733          	add	a4,a4,a5
ffffffe000202610:	f6843683          	ld	a3,-152(s0)
ffffffe000202614:	fd043783          	ld	a5,-48(s0)
ffffffe000202618:	00f687b3          	add	a5,a3,a5
ffffffe00020261c:	00074703          	lbu	a4,0(a4)
ffffffe000202620:	00e78023          	sb	a4,0(a5)
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
ffffffe000202624:	fd043783          	ld	a5,-48(s0)
ffffffe000202628:	00178793          	addi	a5,a5,1
ffffffe00020262c:	fcf43823          	sd	a5,-48(s0)
ffffffe000202630:	fd043703          	ld	a4,-48(s0)
ffffffe000202634:	03f00793          	li	a5,63
ffffffe000202638:	fce7f6e3          	bgeu	a5,a4,ffffffe000202604 <do_fork+0x1c8>
        }
        // LogBLUE("new_vma->vm_start = 0x%llx, new_vma->vm_end = 0x%llx", new_vma->vm_start, new_vma->vm_end);
        // LogBLUE("vma->vm_start = 0x%llx, vma->vm_end = 0x%llx", vma->vm_start, vma->vm_end);
        add_mmap(&ptask->mm, new_vma);
ffffffe00020263c:	fb843783          	ld	a5,-72(s0)
ffffffe000202640:	0b078793          	addi	a5,a5,176
ffffffe000202644:	f7843583          	ld	a1,-136(s0)
ffffffe000202648:	00078513          	mv	a0,a5
ffffffe00020264c:	274000ef          	jal	ra,ffffffe0002028c0 <add_mmap>

        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
ffffffe000202650:	fd843783          	ld	a5,-40(s0)
ffffffe000202654:	0087b703          	ld	a4,8(a5)
ffffffe000202658:	fffff7b7          	lui	a5,0xfffff
ffffffe00020265c:	00f777b3          	and	a5,a4,a5
ffffffe000202660:	fcf43423          	sd	a5,-56(s0)
ffffffe000202664:	0cc0006f          	j	ffffffe000202730 <do_fork+0x2f4>
            uint64_t perm = check_load(current->pgd, addr);
ffffffe000202668:	00009797          	auipc	a5,0x9
ffffffe00020266c:	9a878793          	addi	a5,a5,-1624 # ffffffe00020b010 <current>
ffffffe000202670:	0007b783          	ld	a5,0(a5)
ffffffe000202674:	0a87b783          	ld	a5,168(a5)
ffffffe000202678:	fc843583          	ld	a1,-56(s0)
ffffffe00020267c:	00078513          	mv	a0,a5
ffffffe000202680:	138000ef          	jal	ra,ffffffe0002027b8 <check_load>
ffffffe000202684:	00050793          	mv	a5,a0
ffffffe000202688:	f6f43023          	sd	a5,-160(s0)
            if (!perm) continue;
ffffffe00020268c:	f6043783          	ld	a5,-160(s0)
ffffffe000202690:	08078663          	beqz	a5,ffffffe00020271c <do_fork+0x2e0>

            uint64_t *new_page = (uint64_t*)alloc_page();
ffffffe000202694:	da4fe0ef          	jal	ra,ffffffe000200c38 <alloc_page>
ffffffe000202698:	f4a43c23          	sd	a0,-168(s0)
            char *cnew_page = (char*)new_page;
ffffffe00020269c:	f5843783          	ld	a5,-168(s0)
ffffffe0002026a0:	f4f43823          	sd	a5,-176(s0)
            char *cpage = (char*)addr;
ffffffe0002026a4:	fc843783          	ld	a5,-56(s0)
ffffffe0002026a8:	f4f43423          	sd	a5,-184(s0)
            for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002026ac:	fc043023          	sd	zero,-64(s0)
ffffffe0002026b0:	0300006f          	j	ffffffe0002026e0 <do_fork+0x2a4>
                cnew_page[i] = cpage[i];
ffffffe0002026b4:	f4843703          	ld	a4,-184(s0)
ffffffe0002026b8:	fc043783          	ld	a5,-64(s0)
ffffffe0002026bc:	00f70733          	add	a4,a4,a5
ffffffe0002026c0:	f5043683          	ld	a3,-176(s0)
ffffffe0002026c4:	fc043783          	ld	a5,-64(s0)
ffffffe0002026c8:	00f687b3          	add	a5,a3,a5
ffffffe0002026cc:	00074703          	lbu	a4,0(a4)
ffffffe0002026d0:	00e78023          	sb	a4,0(a5)
            for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002026d4:	fc043783          	ld	a5,-64(s0)
ffffffe0002026d8:	00178793          	addi	a5,a5,1
ffffffe0002026dc:	fcf43023          	sd	a5,-64(s0)
ffffffe0002026e0:	fc043703          	ld	a4,-64(s0)
ffffffe0002026e4:	000017b7          	lui	a5,0x1
ffffffe0002026e8:	fcf766e3          	bltu	a4,a5,ffffffe0002026b4 <do_fork+0x278>
            }
            create_mapping(ptask->pgd, addr, VA2PA((uint64_t*)new_page), PGSIZE, perm);
ffffffe0002026ec:	fb843783          	ld	a5,-72(s0)
ffffffe0002026f0:	0a87b503          	ld	a0,168(a5) # 10a8 <PGSIZE+0xa8>
ffffffe0002026f4:	f5843703          	ld	a4,-168(s0)
ffffffe0002026f8:	04100793          	li	a5,65
ffffffe0002026fc:	02279793          	slli	a5,a5,0x22
ffffffe000202700:	00f707b3          	add	a5,a4,a5
ffffffe000202704:	f6043703          	ld	a4,-160(s0)
ffffffe000202708:	000016b7          	lui	a3,0x1
ffffffe00020270c:	00078613          	mv	a2,a5
ffffffe000202710:	fc843583          	ld	a1,-56(s0)
ffffffe000202714:	481000ef          	jal	ra,ffffffe000203394 <create_mapping>
ffffffe000202718:	0080006f          	j	ffffffe000202720 <do_fork+0x2e4>
            if (!perm) continue;
ffffffe00020271c:	00000013          	nop
        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
ffffffe000202720:	fc843703          	ld	a4,-56(s0)
ffffffe000202724:	000017b7          	lui	a5,0x1
ffffffe000202728:	00f707b3          	add	a5,a4,a5
ffffffe00020272c:	fcf43423          	sd	a5,-56(s0)
ffffffe000202730:	fd843783          	ld	a5,-40(s0)
ffffffe000202734:	0107b703          	ld	a4,16(a5) # 1010 <PGSIZE+0x10>
ffffffe000202738:	fffff7b7          	lui	a5,0xfffff
ffffffe00020273c:	00f777b3          	and	a5,a4,a5
ffffffe000202740:	fc843703          	ld	a4,-56(s0)
ffffffe000202744:	f2e7f2e3          	bgeu	a5,a4,ffffffe000202668 <do_fork+0x22c>
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
ffffffe000202748:	fd843783          	ld	a5,-40(s0)
ffffffe00020274c:	0187b783          	ld	a5,24(a5) # fffffffffffff018 <VM_END+0xfffff018>
ffffffe000202750:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202754:	fd843783          	ld	a5,-40(s0)
ffffffe000202758:	e80796e3          	bnez	a5,ffffffe0002025e4 <do_fork+0x1a8>
        }
    }


    // load_program(ptask);
    task[nr_tasks] = ptask;
ffffffe00020275c:	00004797          	auipc	a5,0x4
ffffffe000202760:	8b478793          	addi	a5,a5,-1868 # ffffffe000206010 <nr_tasks>
ffffffe000202764:	0007b783          	ld	a5,0(a5)
ffffffe000202768:	00009717          	auipc	a4,0x9
ffffffe00020276c:	8d070713          	addi	a4,a4,-1840 # ffffffe00020b038 <task>
ffffffe000202770:	00379793          	slli	a5,a5,0x3
ffffffe000202774:	00f707b3          	add	a5,a4,a5
ffffffe000202778:	fb843703          	ld	a4,-72(s0)
ffffffe00020277c:	00e7b023          	sd	a4,0(a5)
    nr_tasks++;
ffffffe000202780:	00004797          	auipc	a5,0x4
ffffffe000202784:	89078793          	addi	a5,a5,-1904 # ffffffe000206010 <nr_tasks>
ffffffe000202788:	0007b783          	ld	a5,0(a5)
ffffffe00020278c:	00178713          	addi	a4,a5,1
ffffffe000202790:	00004797          	auipc	a5,0x4
ffffffe000202794:	88078793          	addi	a5,a5,-1920 # ffffffe000206010 <nr_tasks>
ffffffe000202798:	00e7b023          	sd	a4,0(a5)
    return ptask->pid;
ffffffe00020279c:	fb843783          	ld	a5,-72(s0)
ffffffe0002027a0:	0187b783          	ld	a5,24(a5)
}
ffffffe0002027a4:	00078513          	mv	a0,a5
ffffffe0002027a8:	0c813083          	ld	ra,200(sp)
ffffffe0002027ac:	0c013403          	ld	s0,192(sp)
ffffffe0002027b0:	0d010113          	addi	sp,sp,208
ffffffe0002027b4:	00008067          	ret

ffffffe0002027b8 <check_load>:

int check_load(uint64_t *pgtbl, uint64_t addr){
ffffffe0002027b8:	fb010113          	addi	sp,sp,-80
ffffffe0002027bc:	04813423          	sd	s0,72(sp)
ffffffe0002027c0:	05010413          	addi	s0,sp,80
ffffffe0002027c4:	faa43c23          	sd	a0,-72(s0)
ffffffe0002027c8:	fab43823          	sd	a1,-80(s0)
    uint64_t pgd_entry = *(pgtbl + ((addr >> 30) & 0x1ff));
ffffffe0002027cc:	fb043783          	ld	a5,-80(s0)
ffffffe0002027d0:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002027d4:	1ff7f793          	andi	a5,a5,511
ffffffe0002027d8:	00379793          	slli	a5,a5,0x3
ffffffe0002027dc:	fb843703          	ld	a4,-72(s0)
ffffffe0002027e0:	00f707b3          	add	a5,a4,a5
ffffffe0002027e4:	0007b783          	ld	a5,0(a5)
ffffffe0002027e8:	fef43423          	sd	a5,-24(s0)
    if (!(pgd_entry & PTE_V)) return 0;
ffffffe0002027ec:	fe843783          	ld	a5,-24(s0)
ffffffe0002027f0:	0017f793          	andi	a5,a5,1
ffffffe0002027f4:	00079663          	bnez	a5,ffffffe000202800 <check_load+0x48>
ffffffe0002027f8:	00000793          	li	a5,0
ffffffe0002027fc:	0b40006f          	j	ffffffe0002028b0 <check_load+0xf8>
    uint64_t *pmd = (uint64_t*)(PA2VA((uint64_t)((pgd_entry >> 10) << 12)));
ffffffe000202800:	fe843783          	ld	a5,-24(s0)
ffffffe000202804:	00a7d793          	srli	a5,a5,0xa
ffffffe000202808:	00c79713          	slli	a4,a5,0xc
ffffffe00020280c:	fbf00793          	li	a5,-65
ffffffe000202810:	01f79793          	slli	a5,a5,0x1f
ffffffe000202814:	00f707b3          	add	a5,a4,a5
ffffffe000202818:	fef43023          	sd	a5,-32(s0)
    uint64_t pmd_entry = *(pmd + ((addr >> 21) & 0x1ff));
ffffffe00020281c:	fb043783          	ld	a5,-80(s0)
ffffffe000202820:	0157d793          	srli	a5,a5,0x15
ffffffe000202824:	1ff7f793          	andi	a5,a5,511
ffffffe000202828:	00379793          	slli	a5,a5,0x3
ffffffe00020282c:	fe043703          	ld	a4,-32(s0)
ffffffe000202830:	00f707b3          	add	a5,a4,a5
ffffffe000202834:	0007b783          	ld	a5,0(a5)
ffffffe000202838:	fcf43c23          	sd	a5,-40(s0)
    if (!(pmd_entry & PTE_V)) return 0;
ffffffe00020283c:	fd843783          	ld	a5,-40(s0)
ffffffe000202840:	0017f793          	andi	a5,a5,1
ffffffe000202844:	00079663          	bnez	a5,ffffffe000202850 <check_load+0x98>
ffffffe000202848:	00000793          	li	a5,0
ffffffe00020284c:	0640006f          	j	ffffffe0002028b0 <check_load+0xf8>
    uint64_t *pte = (uint64_t*)(PA2VA((uint64_t)((pmd_entry >> 10) << 12)));
ffffffe000202850:	fd843783          	ld	a5,-40(s0)
ffffffe000202854:	00a7d793          	srli	a5,a5,0xa
ffffffe000202858:	00c79713          	slli	a4,a5,0xc
ffffffe00020285c:	fbf00793          	li	a5,-65
ffffffe000202860:	01f79793          	slli	a5,a5,0x1f
ffffffe000202864:	00f707b3          	add	a5,a4,a5
ffffffe000202868:	fcf43823          	sd	a5,-48(s0)
    uint64_t pte_entry = *(pte + ((addr >> 12) & 0x1ff));
ffffffe00020286c:	fb043783          	ld	a5,-80(s0)
ffffffe000202870:	00c7d793          	srli	a5,a5,0xc
ffffffe000202874:	1ff7f793          	andi	a5,a5,511
ffffffe000202878:	00379793          	slli	a5,a5,0x3
ffffffe00020287c:	fd043703          	ld	a4,-48(s0)
ffffffe000202880:	00f707b3          	add	a5,a4,a5
ffffffe000202884:	0007b783          	ld	a5,0(a5)
ffffffe000202888:	fcf43423          	sd	a5,-56(s0)
    if (!(pte_entry & PTE_V)) return 0;
ffffffe00020288c:	fc843783          	ld	a5,-56(s0)
ffffffe000202890:	0017f793          	andi	a5,a5,1
ffffffe000202894:	00079663          	bnez	a5,ffffffe0002028a0 <check_load+0xe8>
ffffffe000202898:	00000793          	li	a5,0
ffffffe00020289c:	0140006f          	j	ffffffe0002028b0 <check_load+0xf8>
    // return (pte_entry & PTE_R) | (pte_entry & PTE_X) | (pte_entry & PTE_W) | PTE_V | PTE_U; 
    return pte_entry & 0XFF;
ffffffe0002028a0:	fc843783          	ld	a5,-56(s0)
ffffffe0002028a4:	0007879b          	sext.w	a5,a5
ffffffe0002028a8:	0ff7f793          	zext.b	a5,a5
ffffffe0002028ac:	0007879b          	sext.w	a5,a5
}
ffffffe0002028b0:	00078513          	mv	a0,a5
ffffffe0002028b4:	04813403          	ld	s0,72(sp)
ffffffe0002028b8:	05010113          	addi	sp,sp,80
ffffffe0002028bc:	00008067          	ret

ffffffe0002028c0 <add_mmap>:

void add_mmap(struct mm_struct *mm, struct vm_area_struct *new_vma){
ffffffe0002028c0:	fd010113          	addi	sp,sp,-48
ffffffe0002028c4:	02813423          	sd	s0,40(sp)
ffffffe0002028c8:	03010413          	addi	s0,sp,48
ffffffe0002028cc:	fca43c23          	sd	a0,-40(s0)
ffffffe0002028d0:	fcb43823          	sd	a1,-48(s0)
    new_vma->vm_mm = mm;
ffffffe0002028d4:	fd043783          	ld	a5,-48(s0)
ffffffe0002028d8:	fd843703          	ld	a4,-40(s0)
ffffffe0002028dc:	00e7b023          	sd	a4,0(a5)
    struct vm_area_struct *prev =  mm->mmap;
ffffffe0002028e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002028e4:	0007b783          	ld	a5,0(a5)
ffffffe0002028e8:	fef43423          	sd	a5,-24(s0)
    if(!prev){
ffffffe0002028ec:	fe843783          	ld	a5,-24(s0)
ffffffe0002028f0:	02079263          	bnez	a5,ffffffe000202914 <add_mmap+0x54>
        mm->mmap = new_vma;
ffffffe0002028f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002028f8:	fd043703          	ld	a4,-48(s0)
ffffffe0002028fc:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = NULL;
ffffffe000202900:	fd043783          	ld	a5,-48(s0)
ffffffe000202904:	0007bc23          	sd	zero,24(a5)
        new_vma->vm_prev = NULL;
ffffffe000202908:	fd043783          	ld	a5,-48(s0)
ffffffe00020290c:	0207b023          	sd	zero,32(a5)
        new_vma->vm_next = prev;
        new_vma->vm_prev = NULL;
        prev->vm_prev = new_vma;
    }
    // return mm->mmap;
}
ffffffe000202910:	0300006f          	j	ffffffe000202940 <add_mmap+0x80>
        mm->mmap = new_vma;
ffffffe000202914:	fd843783          	ld	a5,-40(s0)
ffffffe000202918:	fd043703          	ld	a4,-48(s0)
ffffffe00020291c:	00e7b023          	sd	a4,0(a5)
        new_vma->vm_next = prev;
ffffffe000202920:	fd043783          	ld	a5,-48(s0)
ffffffe000202924:	fe843703          	ld	a4,-24(s0)
ffffffe000202928:	00e7bc23          	sd	a4,24(a5)
        new_vma->vm_prev = NULL;
ffffffe00020292c:	fd043783          	ld	a5,-48(s0)
ffffffe000202930:	0207b023          	sd	zero,32(a5)
        prev->vm_prev = new_vma;
ffffffe000202934:	fe843783          	ld	a5,-24(s0)
ffffffe000202938:	fd043703          	ld	a4,-48(s0)
ffffffe00020293c:	02e7b023          	sd	a4,32(a5)
}
ffffffe000202940:	00000013          	nop
ffffffe000202944:	02813403          	ld	s0,40(sp)
ffffffe000202948:	03010113          	addi	sp,sp,48
ffffffe00020294c:	00008067          	ret

ffffffe000202950 <do_fork_cow>:

uint64_t do_fork_cow(struct pt_regs *regs){
ffffffe000202950:	f5010113          	addi	sp,sp,-176
ffffffe000202954:	0a113423          	sd	ra,168(sp)
ffffffe000202958:	0a813023          	sd	s0,160(sp)
ffffffe00020295c:	0b010413          	addi	s0,sp,176
ffffffe000202960:	f4a43c23          	sd	a0,-168(s0)
    struct task_struct *ptask = (struct task_struct*)kalloc();
ffffffe000202964:	b48fe0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe000202968:	fca43023          	sd	a0,-64(s0)
    // _sstatus |= (1 << 5);
    // _sstatus |= (1 << 18); 
    // ptask->thread.sstatus = _sstatus;

    // ptask->thread.sscratch = (uint64_t)USER_END;
    char *ccurrent_task = (char*)current;
ffffffe00020296c:	00008797          	auipc	a5,0x8
ffffffe000202970:	6a478793          	addi	a5,a5,1700 # ffffffe00020b010 <current>
ffffffe000202974:	0007b783          	ld	a5,0(a5)
ffffffe000202978:	faf43c23          	sd	a5,-72(s0)
    char *cptask = (char*)ptask;
ffffffe00020297c:	fc043783          	ld	a5,-64(s0)
ffffffe000202980:	faf43823          	sd	a5,-80(s0)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202984:	fe043423          	sd	zero,-24(s0)
ffffffe000202988:	0300006f          	j	ffffffe0002029b8 <do_fork_cow+0x68>
        cptask[i] = ccurrent_task[i];
ffffffe00020298c:	fb843703          	ld	a4,-72(s0)
ffffffe000202990:	fe843783          	ld	a5,-24(s0)
ffffffe000202994:	00f70733          	add	a4,a4,a5
ffffffe000202998:	fb043683          	ld	a3,-80(s0)
ffffffe00020299c:	fe843783          	ld	a5,-24(s0)
ffffffe0002029a0:	00f687b3          	add	a5,a3,a5
ffffffe0002029a4:	00074703          	lbu	a4,0(a4)
ffffffe0002029a8:	00e78023          	sb	a4,0(a5)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe0002029ac:	fe843783          	ld	a5,-24(s0)
ffffffe0002029b0:	00178793          	addi	a5,a5,1
ffffffe0002029b4:	fef43423          	sd	a5,-24(s0)
ffffffe0002029b8:	fe843703          	ld	a4,-24(s0)
ffffffe0002029bc:	000017b7          	lui	a5,0x1
ffffffe0002029c0:	fcf766e3          	bltu	a4,a5,ffffffe00020298c <do_fork_cow+0x3c>
    }
    ptask->pid = nr_tasks;
ffffffe0002029c4:	00003797          	auipc	a5,0x3
ffffffe0002029c8:	64c78793          	addi	a5,a5,1612 # ffffffe000206010 <nr_tasks>
ffffffe0002029cc:	0007b703          	ld	a4,0(a5)
ffffffe0002029d0:	fc043783          	ld	a5,-64(s0)
ffffffe0002029d4:	00e7bc23          	sd	a4,24(a5)
    ptask->thread.ra = __ret_from_fork;
ffffffe0002029d8:	ffffd717          	auipc	a4,0xffffd
ffffffe0002029dc:	77070713          	addi	a4,a4,1904 # ffffffe000200148 <__ret_from_fork>
ffffffe0002029e0:	fc043783          	ld	a5,-64(s0)
ffffffe0002029e4:	02e7b023          	sd	a4,32(a5)
    ptask->thread.sp = (uint64_t)ptask + (uint64_t)regs - PGROUNDDOWN((uint64_t)regs); // ??
ffffffe0002029e8:	fc043703          	ld	a4,-64(s0)
ffffffe0002029ec:	f5843783          	ld	a5,-168(s0)
ffffffe0002029f0:	00f70733          	add	a4,a4,a5
ffffffe0002029f4:	f5843683          	ld	a3,-168(s0)
ffffffe0002029f8:	fffff7b7          	lui	a5,0xfffff
ffffffe0002029fc:	00f6f7b3          	and	a5,a3,a5
ffffffe000202a00:	40f70733          	sub	a4,a4,a5
ffffffe000202a04:	fc043783          	ld	a5,-64(s0)
ffffffe000202a08:	02e7b423          	sd	a4,40(a5) # fffffffffffff028 <VM_END+0xfffff028>
    //ptask sscratch
    // LogBLUE("ptask->thread.sscratch = 0x%llx", ptask->thread.sscratch);
    // uint64_t _sscratch = csr_read(sscratch);
    // LogBLUE("sscratch = 0x%llx", _sscratch);
    ptask->thread.sscratch = csr_read(sscratch);
ffffffe000202a0c:	140027f3          	csrr	a5,sscratch
ffffffe000202a10:	faf43423          	sd	a5,-88(s0)
ffffffe000202a14:	fa843703          	ld	a4,-88(s0)
ffffffe000202a18:	fc043783          	ld	a5,-64(s0)
ffffffe000202a1c:	0ae7b023          	sd	a4,160(a5)
    struct pt_regs *ptregs = (struct pt_regs*)((uint64_t)regs - (uint64_t)current + (uint64_t)ptask);
ffffffe000202a20:	f5843783          	ld	a5,-168(s0)
ffffffe000202a24:	00008717          	auipc	a4,0x8
ffffffe000202a28:	5ec70713          	addi	a4,a4,1516 # ffffffe00020b010 <current>
ffffffe000202a2c:	00073703          	ld	a4,0(a4)
ffffffe000202a30:	40e78733          	sub	a4,a5,a4
ffffffe000202a34:	fc043783          	ld	a5,-64(s0)
ffffffe000202a38:	00f707b3          	add	a5,a4,a5
ffffffe000202a3c:	faf43023          	sd	a5,-96(s0)
    ptregs->x[10] = 0;  
ffffffe000202a40:	fa043783          	ld	a5,-96(s0)
ffffffe000202a44:	0407b823          	sd	zero,80(a5)
    ptregs->x[2] = ptask->thread.sp;
ffffffe000202a48:	fc043783          	ld	a5,-64(s0)
ffffffe000202a4c:	0287b703          	ld	a4,40(a5)
ffffffe000202a50:	fa043783          	ld	a5,-96(s0)
ffffffe000202a54:	00e7b823          	sd	a4,16(a5)
    ptask->thread.sepc = csr_read(sepc) + 4;
ffffffe000202a58:	141027f3          	csrr	a5,sepc
ffffffe000202a5c:	f8f43c23          	sd	a5,-104(s0)
ffffffe000202a60:	f9843783          	ld	a5,-104(s0)
ffffffe000202a64:	00478713          	addi	a4,a5,4
ffffffe000202a68:	fc043783          	ld	a5,-64(s0)
ffffffe000202a6c:	08e7b823          	sd	a4,144(a5)

    ptask->pgd = (uint64_t*)alloc_page();
ffffffe000202a70:	9c8fe0ef          	jal	ra,ffffffe000200c38 <alloc_page>
ffffffe000202a74:	00050713          	mv	a4,a0
ffffffe000202a78:	fc043783          	ld	a5,-64(s0)
ffffffe000202a7c:	0ae7b423          	sd	a4,168(a5)
    char *cpgtbl = (char*)ptask->pgd;
ffffffe000202a80:	fc043783          	ld	a5,-64(s0)
ffffffe000202a84:	0a87b783          	ld	a5,168(a5)
ffffffe000202a88:	f8f43823          	sd	a5,-112(s0)
    char *cearly_pgtbl = (char*)swapper_pg_dir;
ffffffe000202a8c:	0000a797          	auipc	a5,0xa
ffffffe000202a90:	57478793          	addi	a5,a5,1396 # ffffffe00020d000 <swapper_pg_dir>
ffffffe000202a94:	f8f43423          	sd	a5,-120(s0)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202a98:	fe043023          	sd	zero,-32(s0)
ffffffe000202a9c:	0300006f          	j	ffffffe000202acc <do_fork_cow+0x17c>
        cpgtbl[i] = cearly_pgtbl[i];
ffffffe000202aa0:	f8843703          	ld	a4,-120(s0)
ffffffe000202aa4:	fe043783          	ld	a5,-32(s0)
ffffffe000202aa8:	00f70733          	add	a4,a4,a5
ffffffe000202aac:	f9043683          	ld	a3,-112(s0)
ffffffe000202ab0:	fe043783          	ld	a5,-32(s0)
ffffffe000202ab4:	00f687b3          	add	a5,a3,a5
ffffffe000202ab8:	00074703          	lbu	a4,0(a4)
ffffffe000202abc:	00e78023          	sb	a4,0(a5)
    for(uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202ac0:	fe043783          	ld	a5,-32(s0)
ffffffe000202ac4:	00178793          	addi	a5,a5,1
ffffffe000202ac8:	fef43023          	sd	a5,-32(s0)
ffffffe000202acc:	fe043703          	ld	a4,-32(s0)
ffffffe000202ad0:	000017b7          	lui	a5,0x1
ffffffe000202ad4:	fcf766e3          	bltu	a4,a5,ffffffe000202aa0 <do_fork_cow+0x150>
    }

    /*DEEP COPY*/
    ptask->mm.mmap = NULL;
ffffffe000202ad8:	fc043783          	ld	a5,-64(s0)
ffffffe000202adc:	0a07b823          	sd	zero,176(a5) # 10b0 <PGSIZE+0xb0>
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
ffffffe000202ae0:	00008797          	auipc	a5,0x8
ffffffe000202ae4:	53078793          	addi	a5,a5,1328 # ffffffe00020b010 <current>
ffffffe000202ae8:	0007b783          	ld	a5,0(a5)
ffffffe000202aec:	0b07b783          	ld	a5,176(a5)
ffffffe000202af0:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202af4:	15c0006f          	j	ffffffe000202c50 <do_fork_cow+0x300>
        struct vm_area_struct *new_vma = (struct vm_area_struct*)kalloc();
ffffffe000202af8:	9b4fe0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe000202afc:	f8a43023          	sd	a0,-128(s0)
        char *cvma = (char*)vma;
ffffffe000202b00:	fd843783          	ld	a5,-40(s0)
ffffffe000202b04:	f6f43c23          	sd	a5,-136(s0)
        char *cnew_vma = (char*)new_vma;
ffffffe000202b08:	f8043783          	ld	a5,-128(s0)
ffffffe000202b0c:	f6f43823          	sd	a5,-144(s0)
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
ffffffe000202b10:	fc043823          	sd	zero,-48(s0)
ffffffe000202b14:	0300006f          	j	ffffffe000202b44 <do_fork_cow+0x1f4>
            cnew_vma[i] = cvma[i];
ffffffe000202b18:	f7843703          	ld	a4,-136(s0)
ffffffe000202b1c:	fd043783          	ld	a5,-48(s0)
ffffffe000202b20:	00f70733          	add	a4,a4,a5
ffffffe000202b24:	f7043683          	ld	a3,-144(s0)
ffffffe000202b28:	fd043783          	ld	a5,-48(s0)
ffffffe000202b2c:	00f687b3          	add	a5,a3,a5
ffffffe000202b30:	00074703          	lbu	a4,0(a4)
ffffffe000202b34:	00e78023          	sb	a4,0(a5)
        for(uint64_t i = 0; i < sizeof(struct vm_area_struct); i++){
ffffffe000202b38:	fd043783          	ld	a5,-48(s0)
ffffffe000202b3c:	00178793          	addi	a5,a5,1
ffffffe000202b40:	fcf43823          	sd	a5,-48(s0)
ffffffe000202b44:	fd043703          	ld	a4,-48(s0)
ffffffe000202b48:	03f00793          	li	a5,63
ffffffe000202b4c:	fce7f6e3          	bgeu	a5,a4,ffffffe000202b18 <do_fork_cow+0x1c8>
        }
        // LogBLUE("new_vma->vm_start = 0x%llx, new_vma->vm_end = 0x%llx", new_vma->vm_start, new_vma->vm_end);
        // LogBLUE("vma->vm_start = 0x%llx, vma->vm_end = 0x%llx", vma->vm_start, vma->vm_end);
        add_mmap(&ptask->mm, new_vma);
ffffffe000202b50:	fc043783          	ld	a5,-64(s0)
ffffffe000202b54:	0b078793          	addi	a5,a5,176
ffffffe000202b58:	f8043583          	ld	a1,-128(s0)
ffffffe000202b5c:	00078513          	mv	a0,a5
ffffffe000202b60:	d61ff0ef          	jal	ra,ffffffe0002028c0 <add_mmap>

        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
ffffffe000202b64:	fd843783          	ld	a5,-40(s0)
ffffffe000202b68:	0087b703          	ld	a4,8(a5)
ffffffe000202b6c:	fffff7b7          	lui	a5,0xfffff
ffffffe000202b70:	00f777b3          	and	a5,a4,a5
ffffffe000202b74:	fcf43423          	sd	a5,-56(s0)
ffffffe000202b78:	0b40006f          	j	ffffffe000202c2c <do_fork_cow+0x2dc>
            uint64_t perm = check_load(current->pgd, addr);
ffffffe000202b7c:	00008797          	auipc	a5,0x8
ffffffe000202b80:	49478793          	addi	a5,a5,1172 # ffffffe00020b010 <current>
ffffffe000202b84:	0007b783          	ld	a5,0(a5)
ffffffe000202b88:	0a87b783          	ld	a5,168(a5)
ffffffe000202b8c:	fc843583          	ld	a1,-56(s0)
ffffffe000202b90:	00078513          	mv	a0,a5
ffffffe000202b94:	c25ff0ef          	jal	ra,ffffffe0002027b8 <check_load>
ffffffe000202b98:	00050793          	mv	a5,a0
ffffffe000202b9c:	f6f43423          	sd	a5,-152(s0)
            if (!perm) continue;
ffffffe000202ba0:	f6843783          	ld	a5,-152(s0)
ffffffe000202ba4:	06078a63          	beqz	a5,ffffffe000202c18 <do_fork_cow+0x2c8>
            uint64_t pte_entry = pte_entry_ret(current->pgd, addr); // 已经改了write bit
ffffffe000202ba8:	00008797          	auipc	a5,0x8
ffffffe000202bac:	46878793          	addi	a5,a5,1128 # ffffffe00020b010 <current>
ffffffe000202bb0:	0007b783          	ld	a5,0(a5)
ffffffe000202bb4:	0a87b783          	ld	a5,168(a5)
ffffffe000202bb8:	fc843583          	ld	a1,-56(s0)
ffffffe000202bbc:	00078513          	mv	a0,a5
ffffffe000202bc0:	0f8000ef          	jal	ra,ffffffe000202cb8 <pte_entry_ret>
ffffffe000202bc4:	f6a43023          	sd	a0,-160(s0)
            // char *cpage = (char*)addr;
            // for(uint64_t i = 0; i < PGSIZE; i++){
            //     cnew_page[i] = cpage[i];
            // }
            
            get_page((PA2VA(((pte_entry >> 10) << 12))));
ffffffe000202bc8:	f6043783          	ld	a5,-160(s0)
ffffffe000202bcc:	00a7d793          	srli	a5,a5,0xa
ffffffe000202bd0:	00c79713          	slli	a4,a5,0xc
ffffffe000202bd4:	fbf00793          	li	a5,-65
ffffffe000202bd8:	01f79793          	slli	a5,a5,0x1f
ffffffe000202bdc:	00f707b3          	add	a5,a4,a5
ffffffe000202be0:	00078513          	mv	a0,a5
ffffffe000202be4:	ecdfd0ef          	jal	ra,ffffffe000200ab0 <get_page>
            create_mapping(ptask->pgd, addr, ((pte_entry >> 10) << 12), PGSIZE, (pte_entry&0xff));
ffffffe000202be8:	fc043783          	ld	a5,-64(s0)
ffffffe000202bec:	0a87b503          	ld	a0,168(a5)
ffffffe000202bf0:	f6043783          	ld	a5,-160(s0)
ffffffe000202bf4:	00a7d793          	srli	a5,a5,0xa
ffffffe000202bf8:	00c79613          	slli	a2,a5,0xc
ffffffe000202bfc:	f6043783          	ld	a5,-160(s0)
ffffffe000202c00:	0ff7f793          	zext.b	a5,a5
ffffffe000202c04:	00078713          	mv	a4,a5
ffffffe000202c08:	000016b7          	lui	a3,0x1
ffffffe000202c0c:	fc843583          	ld	a1,-56(s0)
ffffffe000202c10:	784000ef          	jal	ra,ffffffe000203394 <create_mapping>
ffffffe000202c14:	0080006f          	j	ffffffe000202c1c <do_fork_cow+0x2cc>
            if (!perm) continue;
ffffffe000202c18:	00000013          	nop
        for(uint64_t addr = PGROUNDDOWN(vma->vm_start); addr <= PGROUNDDOWN(vma->vm_end); addr += PGSIZE){
ffffffe000202c1c:	fc843703          	ld	a4,-56(s0)
ffffffe000202c20:	000017b7          	lui	a5,0x1
ffffffe000202c24:	00f707b3          	add	a5,a4,a5
ffffffe000202c28:	fcf43423          	sd	a5,-56(s0)
ffffffe000202c2c:	fd843783          	ld	a5,-40(s0)
ffffffe000202c30:	0107b703          	ld	a4,16(a5) # 1010 <PGSIZE+0x10>
ffffffe000202c34:	fffff7b7          	lui	a5,0xfffff
ffffffe000202c38:	00f777b3          	and	a5,a4,a5
ffffffe000202c3c:	fc843703          	ld	a4,-56(s0)
ffffffe000202c40:	f2e7fee3          	bgeu	a5,a4,ffffffe000202b7c <do_fork_cow+0x22c>
    for(struct vm_area_struct *vma = current->mm.mmap; vma; vma = vma->vm_next){
ffffffe000202c44:	fd843783          	ld	a5,-40(s0)
ffffffe000202c48:	0187b783          	ld	a5,24(a5) # fffffffffffff018 <VM_END+0xfffff018>
ffffffe000202c4c:	fcf43c23          	sd	a5,-40(s0)
ffffffe000202c50:	fd843783          	ld	a5,-40(s0)
ffffffe000202c54:	ea0792e3          	bnez	a5,ffffffe000202af8 <do_fork_cow+0x1a8>
        }
    }


    // load_program(ptask);
    task[nr_tasks] = ptask;
ffffffe000202c58:	00003797          	auipc	a5,0x3
ffffffe000202c5c:	3b878793          	addi	a5,a5,952 # ffffffe000206010 <nr_tasks>
ffffffe000202c60:	0007b783          	ld	a5,0(a5)
ffffffe000202c64:	00008717          	auipc	a4,0x8
ffffffe000202c68:	3d470713          	addi	a4,a4,980 # ffffffe00020b038 <task>
ffffffe000202c6c:	00379793          	slli	a5,a5,0x3
ffffffe000202c70:	00f707b3          	add	a5,a4,a5
ffffffe000202c74:	fc043703          	ld	a4,-64(s0)
ffffffe000202c78:	00e7b023          	sd	a4,0(a5)
    nr_tasks++;
ffffffe000202c7c:	00003797          	auipc	a5,0x3
ffffffe000202c80:	39478793          	addi	a5,a5,916 # ffffffe000206010 <nr_tasks>
ffffffe000202c84:	0007b783          	ld	a5,0(a5)
ffffffe000202c88:	00178713          	addi	a4,a5,1
ffffffe000202c8c:	00003797          	auipc	a5,0x3
ffffffe000202c90:	38478793          	addi	a5,a5,900 # ffffffe000206010 <nr_tasks>
ffffffe000202c94:	00e7b023          	sd	a4,0(a5)
    asm volatile("sfence.vma zero, zero");
ffffffe000202c98:	12000073          	sfence.vma
    return ptask->pid;
ffffffe000202c9c:	fc043783          	ld	a5,-64(s0)
ffffffe000202ca0:	0187b783          	ld	a5,24(a5)
}
ffffffe000202ca4:	00078513          	mv	a0,a5
ffffffe000202ca8:	0a813083          	ld	ra,168(sp)
ffffffe000202cac:	0a013403          	ld	s0,160(sp)
ffffffe000202cb0:	0b010113          	addi	sp,sp,176
ffffffe000202cb4:	00008067          	ret

ffffffe000202cb8 <pte_entry_ret>:

uint64_t pte_entry_ret(uint64_t *pgtbl, uint64_t addr){
ffffffe000202cb8:	fb010113          	addi	sp,sp,-80
ffffffe000202cbc:	04813423          	sd	s0,72(sp)
ffffffe000202cc0:	05010413          	addi	s0,sp,80
ffffffe000202cc4:	faa43c23          	sd	a0,-72(s0)
ffffffe000202cc8:	fab43823          	sd	a1,-80(s0)
    uint64_t pgd_entry = *(pgtbl + ((addr >> 30) & 0x1ff));
ffffffe000202ccc:	fb043783          	ld	a5,-80(s0)
ffffffe000202cd0:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202cd4:	1ff7f793          	andi	a5,a5,511
ffffffe000202cd8:	00379793          	slli	a5,a5,0x3
ffffffe000202cdc:	fb843703          	ld	a4,-72(s0)
ffffffe000202ce0:	00f707b3          	add	a5,a4,a5
ffffffe000202ce4:	0007b783          	ld	a5,0(a5)
ffffffe000202ce8:	fef43423          	sd	a5,-24(s0)
    uint64_t *pmd = (uint64_t*)(PA2VA((uint64_t)((pgd_entry >> 10) << 12)));
ffffffe000202cec:	fe843783          	ld	a5,-24(s0)
ffffffe000202cf0:	00a7d793          	srli	a5,a5,0xa
ffffffe000202cf4:	00c79713          	slli	a4,a5,0xc
ffffffe000202cf8:	fbf00793          	li	a5,-65
ffffffe000202cfc:	01f79793          	slli	a5,a5,0x1f
ffffffe000202d00:	00f707b3          	add	a5,a4,a5
ffffffe000202d04:	fef43023          	sd	a5,-32(s0)
    uint64_t pmd_entry = *(pmd + ((addr >> 21) & 0x1ff));
ffffffe000202d08:	fb043783          	ld	a5,-80(s0)
ffffffe000202d0c:	0157d793          	srli	a5,a5,0x15
ffffffe000202d10:	1ff7f793          	andi	a5,a5,511
ffffffe000202d14:	00379793          	slli	a5,a5,0x3
ffffffe000202d18:	fe043703          	ld	a4,-32(s0)
ffffffe000202d1c:	00f707b3          	add	a5,a4,a5
ffffffe000202d20:	0007b783          	ld	a5,0(a5)
ffffffe000202d24:	fcf43c23          	sd	a5,-40(s0)
    uint64_t *pte = (uint64_t*)(PA2VA((uint64_t)((pmd_entry >> 10) << 12)));
ffffffe000202d28:	fd843783          	ld	a5,-40(s0)
ffffffe000202d2c:	00a7d793          	srli	a5,a5,0xa
ffffffe000202d30:	00c79713          	slli	a4,a5,0xc
ffffffe000202d34:	fbf00793          	li	a5,-65
ffffffe000202d38:	01f79793          	slli	a5,a5,0x1f
ffffffe000202d3c:	00f707b3          	add	a5,a4,a5
ffffffe000202d40:	fcf43823          	sd	a5,-48(s0)
    uint64_t pte_entry = *(pte + ((addr >> 12) & 0x1ff));
ffffffe000202d44:	fb043783          	ld	a5,-80(s0)
ffffffe000202d48:	00c7d793          	srli	a5,a5,0xc
ffffffe000202d4c:	1ff7f793          	andi	a5,a5,511
ffffffe000202d50:	00379793          	slli	a5,a5,0x3
ffffffe000202d54:	fd043703          	ld	a4,-48(s0)
ffffffe000202d58:	00f707b3          	add	a5,a4,a5
ffffffe000202d5c:	0007b783          	ld	a5,0(a5)
ffffffe000202d60:	fcf43423          	sd	a5,-56(s0)
    *(pte + ((addr >> 12) & 0x1ff)) = pte_entry & (~(1 << 2)); // clear wirte bit
ffffffe000202d64:	fb043783          	ld	a5,-80(s0)
ffffffe000202d68:	00c7d793          	srli	a5,a5,0xc
ffffffe000202d6c:	1ff7f793          	andi	a5,a5,511
ffffffe000202d70:	00379793          	slli	a5,a5,0x3
ffffffe000202d74:	fd043703          	ld	a4,-48(s0)
ffffffe000202d78:	00f707b3          	add	a5,a4,a5
ffffffe000202d7c:	fc843703          	ld	a4,-56(s0)
ffffffe000202d80:	ffb77713          	andi	a4,a4,-5
ffffffe000202d84:	00e7b023          	sd	a4,0(a5)
    // asm volatile("sfence.vma zero, zero");
    return pte_entry & (~(1 << 2));
ffffffe000202d88:	fc843783          	ld	a5,-56(s0)
ffffffe000202d8c:	ffb7f793          	andi	a5,a5,-5
}
ffffffe000202d90:	00078513          	mv	a0,a5
ffffffe000202d94:	04813403          	ld	s0,72(sp)
ffffffe000202d98:	05010113          	addi	sp,sp,80
ffffffe000202d9c:	00008067          	ret

ffffffe000202da0 <check_cow>:

//返回true表示是COW，返回false表示不是COW
uint64_t check_cow(uint64_t *pgtbl, uint64_t addr, struct mm_struct *mm){
ffffffe000202da0:	fb010113          	addi	sp,sp,-80
ffffffe000202da4:	04113423          	sd	ra,72(sp)
ffffffe000202da8:	04813023          	sd	s0,64(sp)
ffffffe000202dac:	05010413          	addi	s0,sp,80
ffffffe000202db0:	fca43423          	sd	a0,-56(s0)
ffffffe000202db4:	fcb43023          	sd	a1,-64(s0)
ffffffe000202db8:	fac43c23          	sd	a2,-72(s0)
    struct vm_area_struct *vma = find_vma(mm, addr);
ffffffe000202dbc:	fc043583          	ld	a1,-64(s0)
ffffffe000202dc0:	fb843503          	ld	a0,-72(s0)
ffffffe000202dc4:	f58fe0ef          	jal	ra,ffffffe00020151c <find_vma>
ffffffe000202dc8:	fea43423          	sd	a0,-24(s0)
    if (!vma){
ffffffe000202dcc:	fe843783          	ld	a5,-24(s0)
ffffffe000202dd0:	02079663          	bnez	a5,ffffffe000202dfc <check_cow+0x5c>
        Err("No VMA found at 0x%llx", addr);
ffffffe000202dd4:	fc043703          	ld	a4,-64(s0)
ffffffe000202dd8:	00002697          	auipc	a3,0x2
ffffffe000202ddc:	7e068693          	addi	a3,a3,2016 # ffffffe0002055b8 <__func__.1>
ffffffe000202de0:	18a00613          	li	a2,394
ffffffe000202de4:	00002597          	auipc	a1,0x2
ffffffe000202de8:	44458593          	addi	a1,a1,1092 # ffffffe000205228 <__func__.0+0x10>
ffffffe000202dec:	00002517          	auipc	a0,0x2
ffffffe000202df0:	69c50513          	addi	a0,a0,1692 # ffffffe000205488 <__func__.0+0x270>
ffffffe000202df4:	71c010ef          	jal	ra,ffffffe000204510 <printk>
ffffffe000202df8:	0000006f          	j	ffffffe000202df8 <check_cow+0x58>
        return 0;
    }

    uint64_t perm = check_load(pgtbl, addr);
ffffffe000202dfc:	fc043583          	ld	a1,-64(s0)
ffffffe000202e00:	fc843503          	ld	a0,-56(s0)
ffffffe000202e04:	9b5ff0ef          	jal	ra,ffffffe0002027b8 <check_load>
ffffffe000202e08:	00050793          	mv	a5,a0
ffffffe000202e0c:	fef43023          	sd	a5,-32(s0)

    if (perm & PTE_W){
ffffffe000202e10:	fe043783          	ld	a5,-32(s0)
ffffffe000202e14:	0047f793          	andi	a5,a5,4
ffffffe000202e18:	00078663          	beqz	a5,ffffffe000202e24 <check_cow+0x84>
        return 0;
ffffffe000202e1c:	00000793          	li	a5,0
ffffffe000202e20:	0880006f          	j	ffffffe000202ea8 <check_cow+0x108>
    }else if (vma->vm_flags & VM_WRITE){
ffffffe000202e24:	fe843783          	ld	a5,-24(s0)
ffffffe000202e28:	0287b783          	ld	a5,40(a5)
ffffffe000202e2c:	0047f793          	andi	a5,a5,4
ffffffe000202e30:	06078c63          	beqz	a5,ffffffe000202ea8 <check_cow+0x108>
        uint64_t entry = pte_entry_ret(pgtbl, addr);
ffffffe000202e34:	fc043583          	ld	a1,-64(s0)
ffffffe000202e38:	fc843503          	ld	a0,-56(s0)
ffffffe000202e3c:	e7dff0ef          	jal	ra,ffffffe000202cb8 <pte_entry_ret>
ffffffe000202e40:	fca43c23          	sd	a0,-40(s0)
        if(get_page_refcnt((void *)PA2VA((((entry >> 10) << 12) | (addr & 0xfff)))) == 1){
ffffffe000202e44:	fd843783          	ld	a5,-40(s0)
ffffffe000202e48:	00a7d793          	srli	a5,a5,0xa
ffffffe000202e4c:	00c79713          	slli	a4,a5,0xc
ffffffe000202e50:	fc043683          	ld	a3,-64(s0)
ffffffe000202e54:	000017b7          	lui	a5,0x1
ffffffe000202e58:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202e5c:	00f6f7b3          	and	a5,a3,a5
ffffffe000202e60:	00f76733          	or	a4,a4,a5
ffffffe000202e64:	fbf00793          	li	a5,-65
ffffffe000202e68:	01f79793          	slli	a5,a5,0x1f
ffffffe000202e6c:	00f707b3          	add	a5,a4,a5
ffffffe000202e70:	00078513          	mv	a0,a5
ffffffe000202e74:	cb1fd0ef          	jal	ra,ffffffe000200b24 <get_page_refcnt>
ffffffe000202e78:	00050713          	mv	a4,a0
ffffffe000202e7c:	00100793          	li	a5,1
ffffffe000202e80:	00f71e63          	bne	a4,a5,ffffffe000202e9c <check_cow+0xfc>
            change_perm(pgtbl, addr);
ffffffe000202e84:	fc043583          	ld	a1,-64(s0)
ffffffe000202e88:	fc843503          	ld	a0,-56(s0)
ffffffe000202e8c:	134000ef          	jal	ra,ffffffe000202fc0 <change_perm>
            return 0xFFF;
ffffffe000202e90:	000017b7          	lui	a5,0x1
ffffffe000202e94:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe000202e98:	0100006f          	j	ffffffe000202ea8 <check_cow+0x108>
        }
        return perm | PTE_W;
ffffffe000202e9c:	fe043783          	ld	a5,-32(s0)
ffffffe000202ea0:	0047e793          	ori	a5,a5,4
ffffffe000202ea4:	0040006f          	j	ffffffe000202ea8 <check_cow+0x108>
    }
}
ffffffe000202ea8:	00078513          	mv	a0,a5
ffffffe000202eac:	04813083          	ld	ra,72(sp)
ffffffe000202eb0:	04013403          	ld	s0,64(sp)
ffffffe000202eb4:	05010113          	addi	sp,sp,80
ffffffe000202eb8:	00008067          	ret

ffffffe000202ebc <page_cow>:

void page_cow(uint64_t *pgtbl, uint64_t addr, uint64_t perm){
ffffffe000202ebc:	fb010113          	addi	sp,sp,-80
ffffffe000202ec0:	04113423          	sd	ra,72(sp)
ffffffe000202ec4:	04813023          	sd	s0,64(sp)
ffffffe000202ec8:	05010413          	addi	s0,sp,80
ffffffe000202ecc:	fca43423          	sd	a0,-56(s0)
ffffffe000202ed0:	fcb43023          	sd	a1,-64(s0)
ffffffe000202ed4:	fac43c23          	sd	a2,-72(s0)
    char *new_page = (char*)alloc_page();
ffffffe000202ed8:	d61fd0ef          	jal	ra,ffffffe000200c38 <alloc_page>
ffffffe000202edc:	fea43023          	sd	a0,-32(s0)

    char *cpage = (char*)addr;
ffffffe000202ee0:	fc043783          	ld	a5,-64(s0)
ffffffe000202ee4:	fcf43c23          	sd	a5,-40(s0)
    LogBLUE("addr = 0x%llx, new_page = 0x%llx", addr, new_page);
ffffffe000202ee8:	fe043783          	ld	a5,-32(s0)
ffffffe000202eec:	fc043703          	ld	a4,-64(s0)
ffffffe000202ef0:	00002697          	auipc	a3,0x2
ffffffe000202ef4:	6d868693          	addi	a3,a3,1752 # ffffffe0002055c8 <__func__.0>
ffffffe000202ef8:	1a000613          	li	a2,416
ffffffe000202efc:	00002597          	auipc	a1,0x2
ffffffe000202f00:	32c58593          	addi	a1,a1,812 # ffffffe000205228 <__func__.0+0x10>
ffffffe000202f04:	00002517          	auipc	a0,0x2
ffffffe000202f08:	65c50513          	addi	a0,a0,1628 # ffffffe000205560 <__func__.0+0x348>
ffffffe000202f0c:	604010ef          	jal	ra,ffffffe000204510 <printk>
    // char *cnewpage = (char*)new_page;
    for (uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202f10:	fe043423          	sd	zero,-24(s0)
ffffffe000202f14:	0300006f          	j	ffffffe000202f44 <page_cow+0x88>
        new_page[i] = cpage[i];
ffffffe000202f18:	fd843703          	ld	a4,-40(s0)
ffffffe000202f1c:	fe843783          	ld	a5,-24(s0)
ffffffe000202f20:	00f70733          	add	a4,a4,a5
ffffffe000202f24:	fe043683          	ld	a3,-32(s0)
ffffffe000202f28:	fe843783          	ld	a5,-24(s0)
ffffffe000202f2c:	00f687b3          	add	a5,a3,a5
ffffffe000202f30:	00074703          	lbu	a4,0(a4)
ffffffe000202f34:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < PGSIZE; i++){
ffffffe000202f38:	fe843783          	ld	a5,-24(s0)
ffffffe000202f3c:	00178793          	addi	a5,a5,1
ffffffe000202f40:	fef43423          	sd	a5,-24(s0)
ffffffe000202f44:	fe843703          	ld	a4,-24(s0)
ffffffe000202f48:	000017b7          	lui	a5,0x1
ffffffe000202f4c:	fcf766e3          	bltu	a4,a5,ffffffe000202f18 <page_cow+0x5c>
    }
    uint64_t entry = pte_entry_ret(pgtbl, addr);
ffffffe000202f50:	fc043583          	ld	a1,-64(s0)
ffffffe000202f54:	fc843503          	ld	a0,-56(s0)
ffffffe000202f58:	d61ff0ef          	jal	ra,ffffffe000202cb8 <pte_entry_ret>
ffffffe000202f5c:	fca43823          	sd	a0,-48(s0)
    put_page(PA2VA(((entry >> 10) << 12)));
ffffffe000202f60:	fd043783          	ld	a5,-48(s0)
ffffffe000202f64:	00a7d793          	srli	a5,a5,0xa
ffffffe000202f68:	00c79713          	slli	a4,a5,0xc
ffffffe000202f6c:	fbf00793          	li	a5,-65
ffffffe000202f70:	01f79793          	slli	a5,a5,0x1f
ffffffe000202f74:	00f707b3          	add	a5,a4,a5
ffffffe000202f78:	00078513          	mv	a0,a5
ffffffe000202f7c:	c1dfd0ef          	jal	ra,ffffffe000200b98 <put_page>
    
    create_mapping(pgtbl, addr, VA2PA((uint64_t)new_page), PGSIZE, perm);
ffffffe000202f80:	fe043703          	ld	a4,-32(s0)
ffffffe000202f84:	04100793          	li	a5,65
ffffffe000202f88:	01f79793          	slli	a5,a5,0x1f
ffffffe000202f8c:	00f707b3          	add	a5,a4,a5
ffffffe000202f90:	fb843703          	ld	a4,-72(s0)
ffffffe000202f94:	000016b7          	lui	a3,0x1
ffffffe000202f98:	00078613          	mv	a2,a5
ffffffe000202f9c:	fc043583          	ld	a1,-64(s0)
ffffffe000202fa0:	fc843503          	ld	a0,-56(s0)
ffffffe000202fa4:	3f0000ef          	jal	ra,ffffffe000203394 <create_mapping>
    asm volatile("sfence.vma zero, zero");
ffffffe000202fa8:	12000073          	sfence.vma
    
}
ffffffe000202fac:	00000013          	nop
ffffffe000202fb0:	04813083          	ld	ra,72(sp)
ffffffe000202fb4:	04013403          	ld	s0,64(sp)
ffffffe000202fb8:	05010113          	addi	sp,sp,80
ffffffe000202fbc:	00008067          	ret

ffffffe000202fc0 <change_perm>:

void change_perm(uint64_t *pgtbl, uint64_t addr){
ffffffe000202fc0:	fb010113          	addi	sp,sp,-80
ffffffe000202fc4:	04813423          	sd	s0,72(sp)
ffffffe000202fc8:	05010413          	addi	s0,sp,80
ffffffe000202fcc:	faa43c23          	sd	a0,-72(s0)
ffffffe000202fd0:	fab43823          	sd	a1,-80(s0)
    uint64_t pgd_entry = *(pgtbl + ((addr >> 30) & 0x1ff));
ffffffe000202fd4:	fb043783          	ld	a5,-80(s0)
ffffffe000202fd8:	01e7d793          	srli	a5,a5,0x1e
ffffffe000202fdc:	1ff7f793          	andi	a5,a5,511
ffffffe000202fe0:	00379793          	slli	a5,a5,0x3
ffffffe000202fe4:	fb843703          	ld	a4,-72(s0)
ffffffe000202fe8:	00f707b3          	add	a5,a4,a5
ffffffe000202fec:	0007b783          	ld	a5,0(a5) # 1000 <PGSIZE>
ffffffe000202ff0:	fef43423          	sd	a5,-24(s0)
    uint64_t *pmd = (uint64_t*)(PA2VA((uint64_t)((pgd_entry >> 10) << 12)));
ffffffe000202ff4:	fe843783          	ld	a5,-24(s0)
ffffffe000202ff8:	00a7d793          	srli	a5,a5,0xa
ffffffe000202ffc:	00c79713          	slli	a4,a5,0xc
ffffffe000203000:	fbf00793          	li	a5,-65
ffffffe000203004:	01f79793          	slli	a5,a5,0x1f
ffffffe000203008:	00f707b3          	add	a5,a4,a5
ffffffe00020300c:	fef43023          	sd	a5,-32(s0)
    uint64_t pmd_entry = *(pmd + ((addr >> 21) & 0x1ff));
ffffffe000203010:	fb043783          	ld	a5,-80(s0)
ffffffe000203014:	0157d793          	srli	a5,a5,0x15
ffffffe000203018:	1ff7f793          	andi	a5,a5,511
ffffffe00020301c:	00379793          	slli	a5,a5,0x3
ffffffe000203020:	fe043703          	ld	a4,-32(s0)
ffffffe000203024:	00f707b3          	add	a5,a4,a5
ffffffe000203028:	0007b783          	ld	a5,0(a5)
ffffffe00020302c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t *pte = (uint64_t*)(PA2VA((uint64_t)((pmd_entry >> 10) << 12)));
ffffffe000203030:	fd843783          	ld	a5,-40(s0)
ffffffe000203034:	00a7d793          	srli	a5,a5,0xa
ffffffe000203038:	00c79713          	slli	a4,a5,0xc
ffffffe00020303c:	fbf00793          	li	a5,-65
ffffffe000203040:	01f79793          	slli	a5,a5,0x1f
ffffffe000203044:	00f707b3          	add	a5,a4,a5
ffffffe000203048:	fcf43823          	sd	a5,-48(s0)
    uint64_t pte_entry = *(pte + ((addr >> 12) & 0x1ff));
ffffffe00020304c:	fb043783          	ld	a5,-80(s0)
ffffffe000203050:	00c7d793          	srli	a5,a5,0xc
ffffffe000203054:	1ff7f793          	andi	a5,a5,511
ffffffe000203058:	00379793          	slli	a5,a5,0x3
ffffffe00020305c:	fd043703          	ld	a4,-48(s0)
ffffffe000203060:	00f707b3          	add	a5,a4,a5
ffffffe000203064:	0007b783          	ld	a5,0(a5)
ffffffe000203068:	fcf43423          	sd	a5,-56(s0)
    *(pte + ((addr >> 12) & 0x1ff)) = pte_entry | (1 << 2); // clear wirte bit
ffffffe00020306c:	fb043783          	ld	a5,-80(s0)
ffffffe000203070:	00c7d793          	srli	a5,a5,0xc
ffffffe000203074:	1ff7f793          	andi	a5,a5,511
ffffffe000203078:	00379793          	slli	a5,a5,0x3
ffffffe00020307c:	fd043703          	ld	a4,-48(s0)
ffffffe000203080:	00f707b3          	add	a5,a4,a5
ffffffe000203084:	fc843703          	ld	a4,-56(s0)
ffffffe000203088:	00476713          	ori	a4,a4,4
ffffffe00020308c:	00e7b023          	sd	a4,0(a5)
    asm volatile("sfence.vma zero, zero");
ffffffe000203090:	12000073          	sfence.vma
    return pte_entry | (1 << 2);
ffffffe000203094:	00000013          	nop
ffffffe000203098:	04813403          	ld	s0,72(sp)
ffffffe00020309c:	05010113          	addi	sp,sp,80
ffffffe0002030a0:	00008067          	ret

ffffffe0002030a4 <setup_vm>:
#include "printk.h"

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe0002030a4:	fd010113          	addi	sp,sp,-48
ffffffe0002030a8:	02113423          	sd	ra,40(sp)
ffffffe0002030ac:	02813023          	sd	s0,32(sp)
ffffffe0002030b0:	03010413          	addi	s0,sp,48
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
    memset(early_pgtbl, 0x0, PGSIZE);
ffffffe0002030b4:	00001637          	lui	a2,0x1
ffffffe0002030b8:	00000593          	li	a1,0
ffffffe0002030bc:	00009517          	auipc	a0,0x9
ffffffe0002030c0:	f4450513          	addi	a0,a0,-188 # ffffffe00020c000 <early_pgtbl>
ffffffe0002030c4:	56c010ef          	jal	ra,ffffffe000204630 <memset>
    uint64_t va = VM_START;
ffffffe0002030c8:	fff00793          	li	a5,-1
ffffffe0002030cc:	02579793          	slli	a5,a5,0x25
ffffffe0002030d0:	fef43423          	sd	a5,-24(s0)
    uint64_t pa = PHY_START;
ffffffe0002030d4:	00100793          	li	a5,1
ffffffe0002030d8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002030dc:	fef43023          	sd	a5,-32(s0)
    LogGREEN("early_pgtbl: 0x%llx\n", early_pgtbl);
ffffffe0002030e0:	00009717          	auipc	a4,0x9
ffffffe0002030e4:	f2070713          	addi	a4,a4,-224 # ffffffe00020c000 <early_pgtbl>
ffffffe0002030e8:	00002697          	auipc	a3,0x2
ffffffe0002030ec:	62868693          	addi	a3,a3,1576 # ffffffe000205710 <__func__.2>
ffffffe0002030f0:	01300613          	li	a2,19
ffffffe0002030f4:	00002597          	auipc	a1,0x2
ffffffe0002030f8:	4e458593          	addi	a1,a1,1252 # ffffffe0002055d8 <__func__.0+0x10>
ffffffe0002030fc:	00002517          	auipc	a0,0x2
ffffffe000203100:	4e450513          	addi	a0,a0,1252 # ffffffe0002055e0 <__func__.0+0x18>
ffffffe000203104:	40c010ef          	jal	ra,ffffffe000204510 <printk>
    uint64_t index = (pa >> 30) & 0x1ff;
ffffffe000203108:	fe043783          	ld	a5,-32(s0)
ffffffe00020310c:	01e7d793          	srli	a5,a5,0x1e
ffffffe000203110:	1ff7f793          	andi	a5,a5,511
ffffffe000203114:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe000203118:	fd843583          	ld	a1,-40(s0)
ffffffe00020311c:	00002517          	auipc	a0,0x2
ffffffe000203120:	4f450513          	addi	a0,a0,1268 # ffffffe000205610 <__func__.0+0x48>
ffffffe000203124:	3ec010ef          	jal	ra,ffffffe000204510 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe000203128:	fe043783          	ld	a5,-32(s0)
ffffffe00020312c:	0027d713          	srli	a4,a5,0x2
ffffffe000203130:	040007b7          	lui	a5,0x4000
ffffffe000203134:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000203138:	01c79793          	slli	a5,a5,0x1c
ffffffe00020313c:	00f777b3          	and	a5,a4,a5
ffffffe000203140:	00f7e713          	ori	a4,a5,15
ffffffe000203144:	00009697          	auipc	a3,0x9
ffffffe000203148:	ebc68693          	addi	a3,a3,-324 # ffffffe00020c000 <early_pgtbl>
ffffffe00020314c:	fd843783          	ld	a5,-40(s0)
ffffffe000203150:	00379793          	slli	a5,a5,0x3
ffffffe000203154:	00f687b3          	add	a5,a3,a5
ffffffe000203158:	00e7b023          	sd	a4,0(a5)

    index = (va >> 30) & 0x1ff;
ffffffe00020315c:	fe843783          	ld	a5,-24(s0)
ffffffe000203160:	01e7d793          	srli	a5,a5,0x1e
ffffffe000203164:	1ff7f793          	andi	a5,a5,511
ffffffe000203168:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe00020316c:	fd843583          	ld	a1,-40(s0)
ffffffe000203170:	00002517          	auipc	a0,0x2
ffffffe000203174:	4a050513          	addi	a0,a0,1184 # ffffffe000205610 <__func__.0+0x48>
ffffffe000203178:	398010ef          	jal	ra,ffffffe000204510 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe00020317c:	fe043783          	ld	a5,-32(s0)
ffffffe000203180:	0027d713          	srli	a4,a5,0x2
ffffffe000203184:	040007b7          	lui	a5,0x4000
ffffffe000203188:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe00020318c:	01c79793          	slli	a5,a5,0x1c
ffffffe000203190:	00f777b3          	and	a5,a4,a5
ffffffe000203194:	00f7e713          	ori	a4,a5,15
ffffffe000203198:	00009697          	auipc	a3,0x9
ffffffe00020319c:	e6868693          	addi	a3,a3,-408 # ffffffe00020c000 <early_pgtbl>
ffffffe0002031a0:	fd843783          	ld	a5,-40(s0)
ffffffe0002031a4:	00379793          	slli	a5,a5,0x3
ffffffe0002031a8:	00f687b3          	add	a5,a3,a5
ffffffe0002031ac:	00e7b023          	sd	a4,0(a5)

    printk("setup_vm done...\n");
ffffffe0002031b0:	00002517          	auipc	a0,0x2
ffffffe0002031b4:	47050513          	addi	a0,a0,1136 # ffffffe000205620 <__func__.0+0x58>
ffffffe0002031b8:	358010ef          	jal	ra,ffffffe000204510 <printk>
}
ffffffe0002031bc:	00000013          	nop
ffffffe0002031c0:	02813083          	ld	ra,40(sp)
ffffffe0002031c4:	02013403          	ld	s0,32(sp)
ffffffe0002031c8:	03010113          	addi	sp,sp,48
ffffffe0002031cc:	00008067          	ret

ffffffe0002031d0 <setup_vm_final>:
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

void setup_vm_final() {
ffffffe0002031d0:	fc010113          	addi	sp,sp,-64
ffffffe0002031d4:	02113c23          	sd	ra,56(sp)
ffffffe0002031d8:	02813823          	sd	s0,48(sp)
ffffffe0002031dc:	04010413          	addi	s0,sp,64
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe0002031e0:	00001637          	lui	a2,0x1
ffffffe0002031e4:	00000593          	li	a1,0
ffffffe0002031e8:	0000a517          	auipc	a0,0xa
ffffffe0002031ec:	e1850513          	addi	a0,a0,-488 # ffffffe00020d000 <swapper_pg_dir>
ffffffe0002031f0:	440010ef          	jal	ra,ffffffe000204630 <memset>
    LogYELLOW("_stext: %p, _etext: %p, _srodata: %p, _erodata: %p, _sdata: %p, _edata: %p, _sbss: %p, _ebss: %p\n", _stext, _etext, _srodata, _erodata, _sdata, _edata, _sbss, _ebss);
ffffffe0002031f4:	0000b797          	auipc	a5,0xb
ffffffe0002031f8:	e0c78793          	addi	a5,a5,-500 # ffffffe00020e000 <_ebss>
ffffffe0002031fc:	00f13c23          	sd	a5,24(sp)
ffffffe000203200:	00007797          	auipc	a5,0x7
ffffffe000203204:	e0078793          	addi	a5,a5,-512 # ffffffe00020a000 <_sbss>
ffffffe000203208:	00f13823          	sd	a5,16(sp)
ffffffe00020320c:	00003797          	auipc	a5,0x3
ffffffe000203210:	e0c78793          	addi	a5,a5,-500 # ffffffe000206018 <_edata>
ffffffe000203214:	00f13423          	sd	a5,8(sp)
ffffffe000203218:	00003797          	auipc	a5,0x3
ffffffe00020321c:	de878793          	addi	a5,a5,-536 # ffffffe000206000 <TIMECLOCK>
ffffffe000203220:	00f13023          	sd	a5,0(sp)
ffffffe000203224:	00002897          	auipc	a7,0x2
ffffffe000203228:	5ac88893          	addi	a7,a7,1452 # ffffffe0002057d0 <_erodata>
ffffffe00020322c:	00002817          	auipc	a6,0x2
ffffffe000203230:	dd480813          	addi	a6,a6,-556 # ffffffe000205000 <__func__.3>
ffffffe000203234:	00001797          	auipc	a5,0x1
ffffffe000203238:	46c78793          	addi	a5,a5,1132 # ffffffe0002046a0 <_etext>
ffffffe00020323c:	ffffd717          	auipc	a4,0xffffd
ffffffe000203240:	dc470713          	addi	a4,a4,-572 # ffffffe000200000 <_skernel>
ffffffe000203244:	00002697          	auipc	a3,0x2
ffffffe000203248:	4dc68693          	addi	a3,a3,1244 # ffffffe000205720 <__func__.1>
ffffffe00020324c:	02700613          	li	a2,39
ffffffe000203250:	00002597          	auipc	a1,0x2
ffffffe000203254:	38858593          	addi	a1,a1,904 # ffffffe0002055d8 <__func__.0+0x10>
ffffffe000203258:	00002517          	auipc	a0,0x2
ffffffe00020325c:	3e050513          	addi	a0,a0,992 # ffffffe000205638 <__func__.0+0x70>
ffffffe000203260:	2b0010ef          	jal	ra,ffffffe000204510 <printk>

    // No OpenSBI mapping required
    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, _stext, _stext - PA2VA_OFFSET, _srodata - _stext, PTE_X | PTE_R | PTE_V);;
ffffffe000203264:	ffffd597          	auipc	a1,0xffffd
ffffffe000203268:	d9c58593          	addi	a1,a1,-612 # ffffffe000200000 <_skernel>
ffffffe00020326c:	ffffd717          	auipc	a4,0xffffd
ffffffe000203270:	d9470713          	addi	a4,a4,-620 # ffffffe000200000 <_skernel>
ffffffe000203274:	04100793          	li	a5,65
ffffffe000203278:	01f79793          	slli	a5,a5,0x1f
ffffffe00020327c:	00f707b3          	add	a5,a4,a5
ffffffe000203280:	00078613          	mv	a2,a5
ffffffe000203284:	00002717          	auipc	a4,0x2
ffffffe000203288:	d7c70713          	addi	a4,a4,-644 # ffffffe000205000 <__func__.3>
ffffffe00020328c:	ffffd797          	auipc	a5,0xffffd
ffffffe000203290:	d7478793          	addi	a5,a5,-652 # ffffffe000200000 <_skernel>
ffffffe000203294:	40f707b3          	sub	a5,a4,a5
ffffffe000203298:	00b00713          	li	a4,11
ffffffe00020329c:	00078693          	mv	a3,a5
ffffffe0002032a0:	0000a517          	auipc	a0,0xa
ffffffe0002032a4:	d6050513          	addi	a0,a0,-672 # ffffffe00020d000 <swapper_pg_dir>
ffffffe0002032a8:	0ec000ef          	jal	ra,ffffffe000203394 <create_mapping>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, _srodata, _srodata - PA2VA_OFFSET, _sdata - _srodata, PTE_R | PTE_V);
ffffffe0002032ac:	00002597          	auipc	a1,0x2
ffffffe0002032b0:	d5458593          	addi	a1,a1,-684 # ffffffe000205000 <__func__.3>
ffffffe0002032b4:	00002717          	auipc	a4,0x2
ffffffe0002032b8:	d4c70713          	addi	a4,a4,-692 # ffffffe000205000 <__func__.3>
ffffffe0002032bc:	04100793          	li	a5,65
ffffffe0002032c0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002032c4:	00f707b3          	add	a5,a4,a5
ffffffe0002032c8:	00078613          	mv	a2,a5
ffffffe0002032cc:	00003717          	auipc	a4,0x3
ffffffe0002032d0:	d3470713          	addi	a4,a4,-716 # ffffffe000206000 <TIMECLOCK>
ffffffe0002032d4:	00002797          	auipc	a5,0x2
ffffffe0002032d8:	d2c78793          	addi	a5,a5,-724 # ffffffe000205000 <__func__.3>
ffffffe0002032dc:	40f707b3          	sub	a5,a4,a5
ffffffe0002032e0:	00300713          	li	a4,3
ffffffe0002032e4:	00078693          	mv	a3,a5
ffffffe0002032e8:	0000a517          	auipc	a0,0xa
ffffffe0002032ec:	d1850513          	addi	a0,a0,-744 # ffffffe00020d000 <swapper_pg_dir>
ffffffe0002032f0:	0a4000ef          	jal	ra,ffffffe000203394 <create_mapping>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir, _sdata, _sdata - PA2VA_OFFSET, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V);
ffffffe0002032f4:	00003597          	auipc	a1,0x3
ffffffe0002032f8:	d0c58593          	addi	a1,a1,-756 # ffffffe000206000 <TIMECLOCK>
ffffffe0002032fc:	00003717          	auipc	a4,0x3
ffffffe000203300:	d0470713          	addi	a4,a4,-764 # ffffffe000206000 <TIMECLOCK>
ffffffe000203304:	04100793          	li	a5,65
ffffffe000203308:	01f79793          	slli	a5,a5,0x1f
ffffffe00020330c:	00f707b3          	add	a5,a4,a5
ffffffe000203310:	00078613          	mv	a2,a5
ffffffe000203314:	00003717          	auipc	a4,0x3
ffffffe000203318:	cec70713          	addi	a4,a4,-788 # ffffffe000206000 <TIMECLOCK>
ffffffe00020331c:	ffffd797          	auipc	a5,0xffffd
ffffffe000203320:	ce478793          	addi	a5,a5,-796 # ffffffe000200000 <_skernel>
ffffffe000203324:	40f707b3          	sub	a5,a4,a5
ffffffe000203328:	08000737          	lui	a4,0x8000
ffffffe00020332c:	40f707b3          	sub	a5,a4,a5
ffffffe000203330:	00700713          	li	a4,7
ffffffe000203334:	00078693          	mv	a3,a5
ffffffe000203338:	0000a517          	auipc	a0,0xa
ffffffe00020333c:	cc850513          	addi	a0,a0,-824 # ffffffe00020d000 <swapper_pg_dir>
ffffffe000203340:	054000ef          	jal	ra,ffffffe000203394 <create_mapping>

    uint64_t _satp = ((((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12) | (uint64_t)0x8 << 60);
ffffffe000203344:	0000a717          	auipc	a4,0xa
ffffffe000203348:	cbc70713          	addi	a4,a4,-836 # ffffffe00020d000 <swapper_pg_dir>
ffffffe00020334c:	04100793          	li	a5,65
ffffffe000203350:	01f79793          	slli	a5,a5,0x1f
ffffffe000203354:	00f707b3          	add	a5,a4,a5
ffffffe000203358:	00c7d713          	srli	a4,a5,0xc
ffffffe00020335c:	fff00793          	li	a5,-1
ffffffe000203360:	03f79793          	slli	a5,a5,0x3f
ffffffe000203364:	00f767b3          	or	a5,a4,a5
ffffffe000203368:	fef43423          	sd	a5,-24(s0)

    // set satp with swapper_pg_dir
    csr_write(satp, _satp);
ffffffe00020336c:	fe843783          	ld	a5,-24(s0)
ffffffe000203370:	fef43023          	sd	a5,-32(s0)
ffffffe000203374:	fe043783          	ld	a5,-32(s0)
ffffffe000203378:	18079073          	csrw	satp,a5
    // *_erodata = 0x0;
    // LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);

    // YOUR CODE HERE
    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe00020337c:	12000073          	sfence.vma
    return;
ffffffe000203380:	00000013          	nop
}
ffffffe000203384:	03813083          	ld	ra,56(sp)
ffffffe000203388:	03013403          	ld	s0,48(sp)
ffffffe00020338c:	04010113          	addi	sp,sp,64
ffffffe000203390:	00008067          	ret

ffffffe000203394 <create_mapping>:


/* 创建多级页表映射关系 */
/* 不要修改该接口的参数和返回值 */
void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000203394:	f7010113          	addi	sp,sp,-144
ffffffe000203398:	08113423          	sd	ra,136(sp)
ffffffe00020339c:	08813023          	sd	s0,128(sp)
ffffffe0002033a0:	09010413          	addi	s0,sp,144
ffffffe0002033a4:	faa43423          	sd	a0,-88(s0)
ffffffe0002033a8:	fab43023          	sd	a1,-96(s0)
ffffffe0002033ac:	f8c43c23          	sd	a2,-104(s0)
ffffffe0002033b0:	f8d43823          	sd	a3,-112(s0)
ffffffe0002033b4:	f8e43423          	sd	a4,-120(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    // printk("Come into the create_mapping\n");
    LogBLUE("root: 0x%llx, [0x%llx, 0x%llx) -> [0x%llx, 0x%llx), perm: 0x%llx", pgtbl, pa, pa + sz, va, va + sz, perm);
ffffffe0002033b8:	f9843703          	ld	a4,-104(s0)
ffffffe0002033bc:	f9043783          	ld	a5,-112(s0)
ffffffe0002033c0:	00f706b3          	add	a3,a4,a5
ffffffe0002033c4:	fa043703          	ld	a4,-96(s0)
ffffffe0002033c8:	f9043783          	ld	a5,-112(s0)
ffffffe0002033cc:	00f707b3          	add	a5,a4,a5
ffffffe0002033d0:	f8843703          	ld	a4,-120(s0)
ffffffe0002033d4:	00e13423          	sd	a4,8(sp)
ffffffe0002033d8:	00f13023          	sd	a5,0(sp)
ffffffe0002033dc:	fa043883          	ld	a7,-96(s0)
ffffffe0002033e0:	00068813          	mv	a6,a3
ffffffe0002033e4:	f9843783          	ld	a5,-104(s0)
ffffffe0002033e8:	fa843703          	ld	a4,-88(s0)
ffffffe0002033ec:	00002697          	auipc	a3,0x2
ffffffe0002033f0:	34468693          	addi	a3,a3,836 # ffffffe000205730 <__func__.0>
ffffffe0002033f4:	05300613          	li	a2,83
ffffffe0002033f8:	00002597          	auipc	a1,0x2
ffffffe0002033fc:	1e058593          	addi	a1,a1,480 # ffffffe0002055d8 <__func__.0+0x10>
ffffffe000203400:	00002517          	auipc	a0,0x2
ffffffe000203404:	2b850513          	addi	a0,a0,696 # ffffffe0002056b8 <__func__.0+0xf0>
ffffffe000203408:	108010ef          	jal	ra,ffffffe000204510 <printk>
    uint64_t vlimit = va + sz;
ffffffe00020340c:	fa043703          	ld	a4,-96(s0)
ffffffe000203410:	f9043783          	ld	a5,-112(s0)
ffffffe000203414:	00f707b3          	add	a5,a4,a5
ffffffe000203418:	fcf43c23          	sd	a5,-40(s0)
    uint64_t *pgd, *pmd, *pte;
    pgd = pgtbl;
ffffffe00020341c:	fa843783          	ld	a5,-88(s0)
ffffffe000203420:	fcf43823          	sd	a5,-48(s0)

    while(va < vlimit){
ffffffe000203424:	19c0006f          	j	ffffffe0002035c0 <create_mapping+0x22c>
        uint64_t pgd_entry = *(pgd + ((va >> 30) & 0x1ff));
ffffffe000203428:	fa043783          	ld	a5,-96(s0)
ffffffe00020342c:	01e7d793          	srli	a5,a5,0x1e
ffffffe000203430:	1ff7f793          	andi	a5,a5,511
ffffffe000203434:	00379793          	slli	a5,a5,0x3
ffffffe000203438:	fd043703          	ld	a4,-48(s0)
ffffffe00020343c:	00f707b3          	add	a5,a4,a5
ffffffe000203440:	0007b783          	ld	a5,0(a5)
ffffffe000203444:	fef43423          	sd	a5,-24(s0)
        if (!(pgd_entry & PTE_V)) {
ffffffe000203448:	fe843783          	ld	a5,-24(s0)
ffffffe00020344c:	0017f793          	andi	a5,a5,1
ffffffe000203450:	06079063          	bnez	a5,ffffffe0002034b0 <create_mapping+0x11c>
            uint64_t ppmd = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppmd是PMD页表的物理地址
ffffffe000203454:	859fd0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe000203458:	00050793          	mv	a5,a0
ffffffe00020345c:	00078713          	mv	a4,a5
ffffffe000203460:	04100793          	li	a5,65
ffffffe000203464:	01f79793          	slli	a5,a5,0x1f
ffffffe000203468:	00f707b3          	add	a5,a4,a5
ffffffe00020346c:	fcf43423          	sd	a5,-56(s0)
            // LogBLUE("ppmd: 0x%llx", ppmd);
            *(pgd + ((va >> 30) & 0x1ff)) = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe000203470:	fc843783          	ld	a5,-56(s0)
ffffffe000203474:	00c7d793          	srli	a5,a5,0xc
ffffffe000203478:	00a79713          	slli	a4,a5,0xa
ffffffe00020347c:	fa043783          	ld	a5,-96(s0)
ffffffe000203480:	01e7d793          	srli	a5,a5,0x1e
ffffffe000203484:	1ff7f793          	andi	a5,a5,511
ffffffe000203488:	00379793          	slli	a5,a5,0x3
ffffffe00020348c:	fd043683          	ld	a3,-48(s0)
ffffffe000203490:	00f687b3          	add	a5,a3,a5
ffffffe000203494:	00176713          	ori	a4,a4,1
ffffffe000203498:	00e7b023          	sd	a4,0(a5)
            pgd_entry = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe00020349c:	fc843783          	ld	a5,-56(s0)
ffffffe0002034a0:	00c7d793          	srli	a5,a5,0xc
ffffffe0002034a4:	00a79793          	slli	a5,a5,0xa
ffffffe0002034a8:	0017e793          	ori	a5,a5,1
ffffffe0002034ac:	fef43423          	sd	a5,-24(s0)
        }
    
        pmd = (uint64_t*) (((pgd_entry >> 10) << 12) + PA2VA_OFFSET); // pmd此时是PMD页表的虚拟地址
ffffffe0002034b0:	fe843783          	ld	a5,-24(s0)
ffffffe0002034b4:	00a7d793          	srli	a5,a5,0xa
ffffffe0002034b8:	00c79713          	slli	a4,a5,0xc
ffffffe0002034bc:	fbf00793          	li	a5,-65
ffffffe0002034c0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002034c4:	00f707b3          	add	a5,a4,a5
ffffffe0002034c8:	fcf43023          	sd	a5,-64(s0)
        uint64_t pmd_entry = *(pmd + ((va >> 21) & 0x1ff));
ffffffe0002034cc:	fa043783          	ld	a5,-96(s0)
ffffffe0002034d0:	0157d793          	srli	a5,a5,0x15
ffffffe0002034d4:	1ff7f793          	andi	a5,a5,511
ffffffe0002034d8:	00379793          	slli	a5,a5,0x3
ffffffe0002034dc:	fc043703          	ld	a4,-64(s0)
ffffffe0002034e0:	00f707b3          	add	a5,a4,a5
ffffffe0002034e4:	0007b783          	ld	a5,0(a5)
ffffffe0002034e8:	fef43023          	sd	a5,-32(s0)
        if (!(pmd_entry & PTE_V)) {
ffffffe0002034ec:	fe043783          	ld	a5,-32(s0)
ffffffe0002034f0:	0017f793          	andi	a5,a5,1
ffffffe0002034f4:	06079063          	bnez	a5,ffffffe000203554 <create_mapping+0x1c0>
            uint64_t ppte = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppte是PTE页表的物理地址
ffffffe0002034f8:	fb4fd0ef          	jal	ra,ffffffe000200cac <kalloc>
ffffffe0002034fc:	00050793          	mv	a5,a0
ffffffe000203500:	00078713          	mv	a4,a5
ffffffe000203504:	04100793          	li	a5,65
ffffffe000203508:	01f79793          	slli	a5,a5,0x1f
ffffffe00020350c:	00f707b3          	add	a5,a4,a5
ffffffe000203510:	faf43c23          	sd	a5,-72(s0)
            // LogBLUE("ppte: 0x%llx", ppte);
            *(pmd + ((va >> 21) & 0x1ff)) = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000203514:	fb843783          	ld	a5,-72(s0)
ffffffe000203518:	00c7d793          	srli	a5,a5,0xc
ffffffe00020351c:	00a79713          	slli	a4,a5,0xa
ffffffe000203520:	fa043783          	ld	a5,-96(s0)
ffffffe000203524:	0157d793          	srli	a5,a5,0x15
ffffffe000203528:	1ff7f793          	andi	a5,a5,511
ffffffe00020352c:	00379793          	slli	a5,a5,0x3
ffffffe000203530:	fc043683          	ld	a3,-64(s0)
ffffffe000203534:	00f687b3          	add	a5,a3,a5
ffffffe000203538:	00176713          	ori	a4,a4,1
ffffffe00020353c:	00e7b023          	sd	a4,0(a5)
            pmd_entry = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000203540:	fb843783          	ld	a5,-72(s0)
ffffffe000203544:	00c7d793          	srli	a5,a5,0xc
ffffffe000203548:	00a79793          	slli	a5,a5,0xa
ffffffe00020354c:	0017e793          	ori	a5,a5,1
ffffffe000203550:	fef43023          	sd	a5,-32(s0)
        }
        
        pte = (uint64_t*) (((pmd_entry >> 10) << 12) + PA2VA_OFFSET); // pte此时是PTE页表的虚拟地址
ffffffe000203554:	fe043783          	ld	a5,-32(s0)
ffffffe000203558:	00a7d793          	srli	a5,a5,0xa
ffffffe00020355c:	00c79713          	slli	a4,a5,0xc
ffffffe000203560:	fbf00793          	li	a5,-65
ffffffe000203564:	01f79793          	slli	a5,a5,0x1f
ffffffe000203568:	00f707b3          	add	a5,a4,a5
ffffffe00020356c:	faf43823          	sd	a5,-80(s0)
        *(pte + ((va >> 12) & 0x1ff)) = ((pa >> 12) << 10) | perm ;
ffffffe000203570:	f9843783          	ld	a5,-104(s0)
ffffffe000203574:	00c7d793          	srli	a5,a5,0xc
ffffffe000203578:	00a79693          	slli	a3,a5,0xa
ffffffe00020357c:	fa043783          	ld	a5,-96(s0)
ffffffe000203580:	00c7d793          	srli	a5,a5,0xc
ffffffe000203584:	1ff7f793          	andi	a5,a5,511
ffffffe000203588:	00379793          	slli	a5,a5,0x3
ffffffe00020358c:	fb043703          	ld	a4,-80(s0)
ffffffe000203590:	00f707b3          	add	a5,a4,a5
ffffffe000203594:	f8843703          	ld	a4,-120(s0)
ffffffe000203598:	00e6e733          	or	a4,a3,a4
ffffffe00020359c:	00e7b023          	sd	a4,0(a5)


        // if(va <= 0xffffffe000209000)LogBLUE("va: 0x%llx, pa: 0x%llx, perm: 0x%llx", va, pa, perm);
        va += PGSIZE;
ffffffe0002035a0:	fa043703          	ld	a4,-96(s0)
ffffffe0002035a4:	000017b7          	lui	a5,0x1
ffffffe0002035a8:	00f707b3          	add	a5,a4,a5
ffffffe0002035ac:	faf43023          	sd	a5,-96(s0)
        pa += PGSIZE;
ffffffe0002035b0:	f9843703          	ld	a4,-104(s0)
ffffffe0002035b4:	000017b7          	lui	a5,0x1
ffffffe0002035b8:	00f707b3          	add	a5,a4,a5
ffffffe0002035bc:	f8f43c23          	sd	a5,-104(s0)
    while(va < vlimit){
ffffffe0002035c0:	fa043703          	ld	a4,-96(s0)
ffffffe0002035c4:	fd843783          	ld	a5,-40(s0)
ffffffe0002035c8:	e6f760e3          	bltu	a4,a5,ffffffe000203428 <create_mapping+0x94>
    }
    
}
ffffffe0002035cc:	00000013          	nop
ffffffe0002035d0:	00000013          	nop
ffffffe0002035d4:	08813083          	ld	ra,136(sp)
ffffffe0002035d8:	08013403          	ld	s0,128(sp)
ffffffe0002035dc:	09010113          	addi	sp,sp,144
ffffffe0002035e0:	00008067          	ret

ffffffe0002035e4 <start_kernel>:
extern void test();

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

int start_kernel() {
ffffffe0002035e4:	ff010113          	addi	sp,sp,-16
ffffffe0002035e8:	00113423          	sd	ra,8(sp)
ffffffe0002035ec:	00813023          	sd	s0,0(sp)
ffffffe0002035f0:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe0002035f4:	00002517          	auipc	a0,0x2
ffffffe0002035f8:	14c50513          	addi	a0,a0,332 # ffffffe000205740 <__func__.0+0x10>
ffffffe0002035fc:	715000ef          	jal	ra,ffffffe000204510 <printk>
    printk(" ZJU Operating System\n");
ffffffe000203600:	00002517          	auipc	a0,0x2
ffffffe000203604:	14850513          	addi	a0,a0,328 # ffffffe000205748 <__func__.0+0x18>
ffffffe000203608:	709000ef          	jal	ra,ffffffe000204510 <printk>
    schedule();
ffffffe00020360c:	a05fd0ef          	jal	ra,ffffffe000201010 <schedule>

    test();
ffffffe000203610:	01c000ef          	jal	ra,ffffffe00020362c <test>
    return 0;
ffffffe000203614:	00000793          	li	a5,0
}
ffffffe000203618:	00078513          	mv	a0,a5
ffffffe00020361c:	00813083          	ld	ra,8(sp)
ffffffe000203620:	00013403          	ld	s0,0(sp)
ffffffe000203624:	01010113          	addi	sp,sp,16
ffffffe000203628:	00008067          	ret

ffffffe00020362c <test>:
#include "printk.h"

void test() {
ffffffe00020362c:	fe010113          	addi	sp,sp,-32
ffffffe000203630:	00113c23          	sd	ra,24(sp)
ffffffe000203634:	00813823          	sd	s0,16(sp)
ffffffe000203638:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe00020363c:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe000203640:	fec42783          	lw	a5,-20(s0)
ffffffe000203644:	0017879b          	addiw	a5,a5,1 # 1001 <PGSIZE+0x1>
ffffffe000203648:	fef42623          	sw	a5,-20(s0)
ffffffe00020364c:	fec42783          	lw	a5,-20(s0)
ffffffe000203650:	00078713          	mv	a4,a5
ffffffe000203654:	05f5e7b7          	lui	a5,0x5f5e
ffffffe000203658:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe00020365c:	02f767bb          	remw	a5,a4,a5
ffffffe000203660:	0007879b          	sext.w	a5,a5
ffffffe000203664:	fc079ee3          	bnez	a5,ffffffe000203640 <test+0x14>
            printk("kernel is running!\n");
ffffffe000203668:	00002517          	auipc	a0,0x2
ffffffe00020366c:	0f850513          	addi	a0,a0,248 # ffffffe000205760 <__func__.0+0x30>
ffffffe000203670:	6a1000ef          	jal	ra,ffffffe000204510 <printk>
            i = 0;
ffffffe000203674:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000203678:	fc9ff06f          	j	ffffffe000203640 <test+0x14>

ffffffe00020367c <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe00020367c:	fe010113          	addi	sp,sp,-32
ffffffe000203680:	00113c23          	sd	ra,24(sp)
ffffffe000203684:	00813823          	sd	s0,16(sp)
ffffffe000203688:	02010413          	addi	s0,sp,32
ffffffe00020368c:	00050793          	mv	a5,a0
ffffffe000203690:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000203694:	fec42783          	lw	a5,-20(s0)
ffffffe000203698:	0ff7f793          	zext.b	a5,a5
ffffffe00020369c:	00078513          	mv	a0,a5
ffffffe0002036a0:	a38fe0ef          	jal	ra,ffffffe0002018d8 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe0002036a4:	fec42783          	lw	a5,-20(s0)
ffffffe0002036a8:	0ff7f793          	zext.b	a5,a5
ffffffe0002036ac:	0007879b          	sext.w	a5,a5
}
ffffffe0002036b0:	00078513          	mv	a0,a5
ffffffe0002036b4:	01813083          	ld	ra,24(sp)
ffffffe0002036b8:	01013403          	ld	s0,16(sp)
ffffffe0002036bc:	02010113          	addi	sp,sp,32
ffffffe0002036c0:	00008067          	ret

ffffffe0002036c4 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe0002036c4:	fe010113          	addi	sp,sp,-32
ffffffe0002036c8:	00813c23          	sd	s0,24(sp)
ffffffe0002036cc:	02010413          	addi	s0,sp,32
ffffffe0002036d0:	00050793          	mv	a5,a0
ffffffe0002036d4:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe0002036d8:	fec42783          	lw	a5,-20(s0)
ffffffe0002036dc:	0007871b          	sext.w	a4,a5
ffffffe0002036e0:	02000793          	li	a5,32
ffffffe0002036e4:	02f70263          	beq	a4,a5,ffffffe000203708 <isspace+0x44>
ffffffe0002036e8:	fec42783          	lw	a5,-20(s0)
ffffffe0002036ec:	0007871b          	sext.w	a4,a5
ffffffe0002036f0:	00800793          	li	a5,8
ffffffe0002036f4:	00e7de63          	bge	a5,a4,ffffffe000203710 <isspace+0x4c>
ffffffe0002036f8:	fec42783          	lw	a5,-20(s0)
ffffffe0002036fc:	0007871b          	sext.w	a4,a5
ffffffe000203700:	00d00793          	li	a5,13
ffffffe000203704:	00e7c663          	blt	a5,a4,ffffffe000203710 <isspace+0x4c>
ffffffe000203708:	00100793          	li	a5,1
ffffffe00020370c:	0080006f          	j	ffffffe000203714 <isspace+0x50>
ffffffe000203710:	00000793          	li	a5,0
}
ffffffe000203714:	00078513          	mv	a0,a5
ffffffe000203718:	01813403          	ld	s0,24(sp)
ffffffe00020371c:	02010113          	addi	sp,sp,32
ffffffe000203720:	00008067          	ret

ffffffe000203724 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe000203724:	fb010113          	addi	sp,sp,-80
ffffffe000203728:	04113423          	sd	ra,72(sp)
ffffffe00020372c:	04813023          	sd	s0,64(sp)
ffffffe000203730:	05010413          	addi	s0,sp,80
ffffffe000203734:	fca43423          	sd	a0,-56(s0)
ffffffe000203738:	fcb43023          	sd	a1,-64(s0)
ffffffe00020373c:	00060793          	mv	a5,a2
ffffffe000203740:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe000203744:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe000203748:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe00020374c:	fc843783          	ld	a5,-56(s0)
ffffffe000203750:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe000203754:	0100006f          	j	ffffffe000203764 <strtol+0x40>
        p++;
ffffffe000203758:	fd843783          	ld	a5,-40(s0)
ffffffe00020375c:	00178793          	addi	a5,a5,1
ffffffe000203760:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe000203764:	fd843783          	ld	a5,-40(s0)
ffffffe000203768:	0007c783          	lbu	a5,0(a5)
ffffffe00020376c:	0007879b          	sext.w	a5,a5
ffffffe000203770:	00078513          	mv	a0,a5
ffffffe000203774:	f51ff0ef          	jal	ra,ffffffe0002036c4 <isspace>
ffffffe000203778:	00050793          	mv	a5,a0
ffffffe00020377c:	fc079ee3          	bnez	a5,ffffffe000203758 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000203780:	fd843783          	ld	a5,-40(s0)
ffffffe000203784:	0007c783          	lbu	a5,0(a5)
ffffffe000203788:	00078713          	mv	a4,a5
ffffffe00020378c:	02d00793          	li	a5,45
ffffffe000203790:	00f71e63          	bne	a4,a5,ffffffe0002037ac <strtol+0x88>
        neg = true;
ffffffe000203794:	00100793          	li	a5,1
ffffffe000203798:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe00020379c:	fd843783          	ld	a5,-40(s0)
ffffffe0002037a0:	00178793          	addi	a5,a5,1
ffffffe0002037a4:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002037a8:	0240006f          	j	ffffffe0002037cc <strtol+0xa8>
    } else if (*p == '+') {
ffffffe0002037ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002037b0:	0007c783          	lbu	a5,0(a5)
ffffffe0002037b4:	00078713          	mv	a4,a5
ffffffe0002037b8:	02b00793          	li	a5,43
ffffffe0002037bc:	00f71863          	bne	a4,a5,ffffffe0002037cc <strtol+0xa8>
        p++;
ffffffe0002037c0:	fd843783          	ld	a5,-40(s0)
ffffffe0002037c4:	00178793          	addi	a5,a5,1
ffffffe0002037c8:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe0002037cc:	fbc42783          	lw	a5,-68(s0)
ffffffe0002037d0:	0007879b          	sext.w	a5,a5
ffffffe0002037d4:	06079c63          	bnez	a5,ffffffe00020384c <strtol+0x128>
        if (*p == '0') {
ffffffe0002037d8:	fd843783          	ld	a5,-40(s0)
ffffffe0002037dc:	0007c783          	lbu	a5,0(a5)
ffffffe0002037e0:	00078713          	mv	a4,a5
ffffffe0002037e4:	03000793          	li	a5,48
ffffffe0002037e8:	04f71e63          	bne	a4,a5,ffffffe000203844 <strtol+0x120>
            p++;
ffffffe0002037ec:	fd843783          	ld	a5,-40(s0)
ffffffe0002037f0:	00178793          	addi	a5,a5,1
ffffffe0002037f4:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe0002037f8:	fd843783          	ld	a5,-40(s0)
ffffffe0002037fc:	0007c783          	lbu	a5,0(a5)
ffffffe000203800:	00078713          	mv	a4,a5
ffffffe000203804:	07800793          	li	a5,120
ffffffe000203808:	00f70c63          	beq	a4,a5,ffffffe000203820 <strtol+0xfc>
ffffffe00020380c:	fd843783          	ld	a5,-40(s0)
ffffffe000203810:	0007c783          	lbu	a5,0(a5)
ffffffe000203814:	00078713          	mv	a4,a5
ffffffe000203818:	05800793          	li	a5,88
ffffffe00020381c:	00f71e63          	bne	a4,a5,ffffffe000203838 <strtol+0x114>
                base = 16;
ffffffe000203820:	01000793          	li	a5,16
ffffffe000203824:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe000203828:	fd843783          	ld	a5,-40(s0)
ffffffe00020382c:	00178793          	addi	a5,a5,1
ffffffe000203830:	fcf43c23          	sd	a5,-40(s0)
ffffffe000203834:	0180006f          	j	ffffffe00020384c <strtol+0x128>
            } else {
                base = 8;
ffffffe000203838:	00800793          	li	a5,8
ffffffe00020383c:	faf42e23          	sw	a5,-68(s0)
ffffffe000203840:	00c0006f          	j	ffffffe00020384c <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe000203844:	00a00793          	li	a5,10
ffffffe000203848:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe00020384c:	fd843783          	ld	a5,-40(s0)
ffffffe000203850:	0007c783          	lbu	a5,0(a5)
ffffffe000203854:	00078713          	mv	a4,a5
ffffffe000203858:	02f00793          	li	a5,47
ffffffe00020385c:	02e7f863          	bgeu	a5,a4,ffffffe00020388c <strtol+0x168>
ffffffe000203860:	fd843783          	ld	a5,-40(s0)
ffffffe000203864:	0007c783          	lbu	a5,0(a5)
ffffffe000203868:	00078713          	mv	a4,a5
ffffffe00020386c:	03900793          	li	a5,57
ffffffe000203870:	00e7ee63          	bltu	a5,a4,ffffffe00020388c <strtol+0x168>
            digit = *p - '0';
ffffffe000203874:	fd843783          	ld	a5,-40(s0)
ffffffe000203878:	0007c783          	lbu	a5,0(a5)
ffffffe00020387c:	0007879b          	sext.w	a5,a5
ffffffe000203880:	fd07879b          	addiw	a5,a5,-48
ffffffe000203884:	fcf42a23          	sw	a5,-44(s0)
ffffffe000203888:	0800006f          	j	ffffffe000203908 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe00020388c:	fd843783          	ld	a5,-40(s0)
ffffffe000203890:	0007c783          	lbu	a5,0(a5)
ffffffe000203894:	00078713          	mv	a4,a5
ffffffe000203898:	06000793          	li	a5,96
ffffffe00020389c:	02e7f863          	bgeu	a5,a4,ffffffe0002038cc <strtol+0x1a8>
ffffffe0002038a0:	fd843783          	ld	a5,-40(s0)
ffffffe0002038a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002038a8:	00078713          	mv	a4,a5
ffffffe0002038ac:	07a00793          	li	a5,122
ffffffe0002038b0:	00e7ee63          	bltu	a5,a4,ffffffe0002038cc <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe0002038b4:	fd843783          	ld	a5,-40(s0)
ffffffe0002038b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002038bc:	0007879b          	sext.w	a5,a5
ffffffe0002038c0:	fa97879b          	addiw	a5,a5,-87
ffffffe0002038c4:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002038c8:	0400006f          	j	ffffffe000203908 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe0002038cc:	fd843783          	ld	a5,-40(s0)
ffffffe0002038d0:	0007c783          	lbu	a5,0(a5)
ffffffe0002038d4:	00078713          	mv	a4,a5
ffffffe0002038d8:	04000793          	li	a5,64
ffffffe0002038dc:	06e7f863          	bgeu	a5,a4,ffffffe00020394c <strtol+0x228>
ffffffe0002038e0:	fd843783          	ld	a5,-40(s0)
ffffffe0002038e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002038e8:	00078713          	mv	a4,a5
ffffffe0002038ec:	05a00793          	li	a5,90
ffffffe0002038f0:	04e7ee63          	bltu	a5,a4,ffffffe00020394c <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe0002038f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002038f8:	0007c783          	lbu	a5,0(a5)
ffffffe0002038fc:	0007879b          	sext.w	a5,a5
ffffffe000203900:	fc97879b          	addiw	a5,a5,-55
ffffffe000203904:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000203908:	fd442783          	lw	a5,-44(s0)
ffffffe00020390c:	00078713          	mv	a4,a5
ffffffe000203910:	fbc42783          	lw	a5,-68(s0)
ffffffe000203914:	0007071b          	sext.w	a4,a4
ffffffe000203918:	0007879b          	sext.w	a5,a5
ffffffe00020391c:	02f75663          	bge	a4,a5,ffffffe000203948 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe000203920:	fbc42703          	lw	a4,-68(s0)
ffffffe000203924:	fe843783          	ld	a5,-24(s0)
ffffffe000203928:	02f70733          	mul	a4,a4,a5
ffffffe00020392c:	fd442783          	lw	a5,-44(s0)
ffffffe000203930:	00f707b3          	add	a5,a4,a5
ffffffe000203934:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe000203938:	fd843783          	ld	a5,-40(s0)
ffffffe00020393c:	00178793          	addi	a5,a5,1
ffffffe000203940:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe000203944:	f09ff06f          	j	ffffffe00020384c <strtol+0x128>
            break;
ffffffe000203948:	00000013          	nop
    }

    if (endptr) {
ffffffe00020394c:	fc043783          	ld	a5,-64(s0)
ffffffe000203950:	00078863          	beqz	a5,ffffffe000203960 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe000203954:	fc043783          	ld	a5,-64(s0)
ffffffe000203958:	fd843703          	ld	a4,-40(s0)
ffffffe00020395c:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe000203960:	fe744783          	lbu	a5,-25(s0)
ffffffe000203964:	0ff7f793          	zext.b	a5,a5
ffffffe000203968:	00078863          	beqz	a5,ffffffe000203978 <strtol+0x254>
ffffffe00020396c:	fe843783          	ld	a5,-24(s0)
ffffffe000203970:	40f007b3          	neg	a5,a5
ffffffe000203974:	0080006f          	j	ffffffe00020397c <strtol+0x258>
ffffffe000203978:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020397c:	00078513          	mv	a0,a5
ffffffe000203980:	04813083          	ld	ra,72(sp)
ffffffe000203984:	04013403          	ld	s0,64(sp)
ffffffe000203988:	05010113          	addi	sp,sp,80
ffffffe00020398c:	00008067          	ret

ffffffe000203990 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000203990:	fd010113          	addi	sp,sp,-48
ffffffe000203994:	02113423          	sd	ra,40(sp)
ffffffe000203998:	02813023          	sd	s0,32(sp)
ffffffe00020399c:	03010413          	addi	s0,sp,48
ffffffe0002039a0:	fca43c23          	sd	a0,-40(s0)
ffffffe0002039a4:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe0002039a8:	fd043783          	ld	a5,-48(s0)
ffffffe0002039ac:	00079863          	bnez	a5,ffffffe0002039bc <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe0002039b0:	00002797          	auipc	a5,0x2
ffffffe0002039b4:	dc878793          	addi	a5,a5,-568 # ffffffe000205778 <__func__.0+0x48>
ffffffe0002039b8:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe0002039bc:	fd043783          	ld	a5,-48(s0)
ffffffe0002039c0:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe0002039c4:	0240006f          	j	ffffffe0002039e8 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe0002039c8:	fe843783          	ld	a5,-24(s0)
ffffffe0002039cc:	00178713          	addi	a4,a5,1
ffffffe0002039d0:	fee43423          	sd	a4,-24(s0)
ffffffe0002039d4:	0007c783          	lbu	a5,0(a5)
ffffffe0002039d8:	0007871b          	sext.w	a4,a5
ffffffe0002039dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002039e0:	00070513          	mv	a0,a4
ffffffe0002039e4:	000780e7          	jalr	a5
    while (*p) {
ffffffe0002039e8:	fe843783          	ld	a5,-24(s0)
ffffffe0002039ec:	0007c783          	lbu	a5,0(a5)
ffffffe0002039f0:	fc079ce3          	bnez	a5,ffffffe0002039c8 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe0002039f4:	fe843703          	ld	a4,-24(s0)
ffffffe0002039f8:	fd043783          	ld	a5,-48(s0)
ffffffe0002039fc:	40f707b3          	sub	a5,a4,a5
ffffffe000203a00:	0007879b          	sext.w	a5,a5
}
ffffffe000203a04:	00078513          	mv	a0,a5
ffffffe000203a08:	02813083          	ld	ra,40(sp)
ffffffe000203a0c:	02013403          	ld	s0,32(sp)
ffffffe000203a10:	03010113          	addi	sp,sp,48
ffffffe000203a14:	00008067          	ret

ffffffe000203a18 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe000203a18:	f9010113          	addi	sp,sp,-112
ffffffe000203a1c:	06113423          	sd	ra,104(sp)
ffffffe000203a20:	06813023          	sd	s0,96(sp)
ffffffe000203a24:	07010413          	addi	s0,sp,112
ffffffe000203a28:	faa43423          	sd	a0,-88(s0)
ffffffe000203a2c:	fab43023          	sd	a1,-96(s0)
ffffffe000203a30:	00060793          	mv	a5,a2
ffffffe000203a34:	f8d43823          	sd	a3,-112(s0)
ffffffe000203a38:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe000203a3c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203a40:	0ff7f793          	zext.b	a5,a5
ffffffe000203a44:	02078663          	beqz	a5,ffffffe000203a70 <print_dec_int+0x58>
ffffffe000203a48:	fa043703          	ld	a4,-96(s0)
ffffffe000203a4c:	fff00793          	li	a5,-1
ffffffe000203a50:	03f79793          	slli	a5,a5,0x3f
ffffffe000203a54:	00f71e63          	bne	a4,a5,ffffffe000203a70 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe000203a58:	00002597          	auipc	a1,0x2
ffffffe000203a5c:	d2858593          	addi	a1,a1,-728 # ffffffe000205780 <__func__.0+0x50>
ffffffe000203a60:	fa843503          	ld	a0,-88(s0)
ffffffe000203a64:	f2dff0ef          	jal	ra,ffffffe000203990 <puts_wo_nl>
ffffffe000203a68:	00050793          	mv	a5,a0
ffffffe000203a6c:	2a00006f          	j	ffffffe000203d0c <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000203a70:	f9043783          	ld	a5,-112(s0)
ffffffe000203a74:	00c7a783          	lw	a5,12(a5)
ffffffe000203a78:	00079a63          	bnez	a5,ffffffe000203a8c <print_dec_int+0x74>
ffffffe000203a7c:	fa043783          	ld	a5,-96(s0)
ffffffe000203a80:	00079663          	bnez	a5,ffffffe000203a8c <print_dec_int+0x74>
        return 0;
ffffffe000203a84:	00000793          	li	a5,0
ffffffe000203a88:	2840006f          	j	ffffffe000203d0c <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000203a8c:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000203a90:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203a94:	0ff7f793          	zext.b	a5,a5
ffffffe000203a98:	02078063          	beqz	a5,ffffffe000203ab8 <print_dec_int+0xa0>
ffffffe000203a9c:	fa043783          	ld	a5,-96(s0)
ffffffe000203aa0:	0007dc63          	bgez	a5,ffffffe000203ab8 <print_dec_int+0xa0>
        neg = true;
ffffffe000203aa4:	00100793          	li	a5,1
ffffffe000203aa8:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000203aac:	fa043783          	ld	a5,-96(s0)
ffffffe000203ab0:	40f007b3          	neg	a5,a5
ffffffe000203ab4:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000203ab8:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000203abc:	f9f44783          	lbu	a5,-97(s0)
ffffffe000203ac0:	0ff7f793          	zext.b	a5,a5
ffffffe000203ac4:	02078863          	beqz	a5,ffffffe000203af4 <print_dec_int+0xdc>
ffffffe000203ac8:	fef44783          	lbu	a5,-17(s0)
ffffffe000203acc:	0ff7f793          	zext.b	a5,a5
ffffffe000203ad0:	00079e63          	bnez	a5,ffffffe000203aec <print_dec_int+0xd4>
ffffffe000203ad4:	f9043783          	ld	a5,-112(s0)
ffffffe000203ad8:	0057c783          	lbu	a5,5(a5)
ffffffe000203adc:	00079863          	bnez	a5,ffffffe000203aec <print_dec_int+0xd4>
ffffffe000203ae0:	f9043783          	ld	a5,-112(s0)
ffffffe000203ae4:	0047c783          	lbu	a5,4(a5)
ffffffe000203ae8:	00078663          	beqz	a5,ffffffe000203af4 <print_dec_int+0xdc>
ffffffe000203aec:	00100793          	li	a5,1
ffffffe000203af0:	0080006f          	j	ffffffe000203af8 <print_dec_int+0xe0>
ffffffe000203af4:	00000793          	li	a5,0
ffffffe000203af8:	fcf40ba3          	sb	a5,-41(s0)
ffffffe000203afc:	fd744783          	lbu	a5,-41(s0)
ffffffe000203b00:	0017f793          	andi	a5,a5,1
ffffffe000203b04:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000203b08:	fa043703          	ld	a4,-96(s0)
ffffffe000203b0c:	00a00793          	li	a5,10
ffffffe000203b10:	02f777b3          	remu	a5,a4,a5
ffffffe000203b14:	0ff7f713          	zext.b	a4,a5
ffffffe000203b18:	fe842783          	lw	a5,-24(s0)
ffffffe000203b1c:	0017869b          	addiw	a3,a5,1
ffffffe000203b20:	fed42423          	sw	a3,-24(s0)
ffffffe000203b24:	0307071b          	addiw	a4,a4,48
ffffffe000203b28:	0ff77713          	zext.b	a4,a4
ffffffe000203b2c:	ff078793          	addi	a5,a5,-16
ffffffe000203b30:	008787b3          	add	a5,a5,s0
ffffffe000203b34:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000203b38:	fa043703          	ld	a4,-96(s0)
ffffffe000203b3c:	00a00793          	li	a5,10
ffffffe000203b40:	02f757b3          	divu	a5,a4,a5
ffffffe000203b44:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000203b48:	fa043783          	ld	a5,-96(s0)
ffffffe000203b4c:	fa079ee3          	bnez	a5,ffffffe000203b08 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000203b50:	f9043783          	ld	a5,-112(s0)
ffffffe000203b54:	00c7a783          	lw	a5,12(a5)
ffffffe000203b58:	00078713          	mv	a4,a5
ffffffe000203b5c:	fff00793          	li	a5,-1
ffffffe000203b60:	02f71063          	bne	a4,a5,ffffffe000203b80 <print_dec_int+0x168>
ffffffe000203b64:	f9043783          	ld	a5,-112(s0)
ffffffe000203b68:	0037c783          	lbu	a5,3(a5)
ffffffe000203b6c:	00078a63          	beqz	a5,ffffffe000203b80 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000203b70:	f9043783          	ld	a5,-112(s0)
ffffffe000203b74:	0087a703          	lw	a4,8(a5)
ffffffe000203b78:	f9043783          	ld	a5,-112(s0)
ffffffe000203b7c:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000203b80:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000203b84:	f9043783          	ld	a5,-112(s0)
ffffffe000203b88:	0087a703          	lw	a4,8(a5)
ffffffe000203b8c:	fe842783          	lw	a5,-24(s0)
ffffffe000203b90:	fcf42823          	sw	a5,-48(s0)
ffffffe000203b94:	f9043783          	ld	a5,-112(s0)
ffffffe000203b98:	00c7a783          	lw	a5,12(a5)
ffffffe000203b9c:	fcf42623          	sw	a5,-52(s0)
ffffffe000203ba0:	fd042783          	lw	a5,-48(s0)
ffffffe000203ba4:	00078593          	mv	a1,a5
ffffffe000203ba8:	fcc42783          	lw	a5,-52(s0)
ffffffe000203bac:	00078613          	mv	a2,a5
ffffffe000203bb0:	0006069b          	sext.w	a3,a2
ffffffe000203bb4:	0005879b          	sext.w	a5,a1
ffffffe000203bb8:	00f6d463          	bge	a3,a5,ffffffe000203bc0 <print_dec_int+0x1a8>
ffffffe000203bbc:	00058613          	mv	a2,a1
ffffffe000203bc0:	0006079b          	sext.w	a5,a2
ffffffe000203bc4:	40f707bb          	subw	a5,a4,a5
ffffffe000203bc8:	0007871b          	sext.w	a4,a5
ffffffe000203bcc:	fd744783          	lbu	a5,-41(s0)
ffffffe000203bd0:	0007879b          	sext.w	a5,a5
ffffffe000203bd4:	40f707bb          	subw	a5,a4,a5
ffffffe000203bd8:	fef42023          	sw	a5,-32(s0)
ffffffe000203bdc:	0280006f          	j	ffffffe000203c04 <print_dec_int+0x1ec>
        putch(' ');
ffffffe000203be0:	fa843783          	ld	a5,-88(s0)
ffffffe000203be4:	02000513          	li	a0,32
ffffffe000203be8:	000780e7          	jalr	a5
        ++written;
ffffffe000203bec:	fe442783          	lw	a5,-28(s0)
ffffffe000203bf0:	0017879b          	addiw	a5,a5,1
ffffffe000203bf4:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000203bf8:	fe042783          	lw	a5,-32(s0)
ffffffe000203bfc:	fff7879b          	addiw	a5,a5,-1
ffffffe000203c00:	fef42023          	sw	a5,-32(s0)
ffffffe000203c04:	fe042783          	lw	a5,-32(s0)
ffffffe000203c08:	0007879b          	sext.w	a5,a5
ffffffe000203c0c:	fcf04ae3          	bgtz	a5,ffffffe000203be0 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000203c10:	fd744783          	lbu	a5,-41(s0)
ffffffe000203c14:	0ff7f793          	zext.b	a5,a5
ffffffe000203c18:	04078463          	beqz	a5,ffffffe000203c60 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000203c1c:	fef44783          	lbu	a5,-17(s0)
ffffffe000203c20:	0ff7f793          	zext.b	a5,a5
ffffffe000203c24:	00078663          	beqz	a5,ffffffe000203c30 <print_dec_int+0x218>
ffffffe000203c28:	02d00793          	li	a5,45
ffffffe000203c2c:	01c0006f          	j	ffffffe000203c48 <print_dec_int+0x230>
ffffffe000203c30:	f9043783          	ld	a5,-112(s0)
ffffffe000203c34:	0057c783          	lbu	a5,5(a5)
ffffffe000203c38:	00078663          	beqz	a5,ffffffe000203c44 <print_dec_int+0x22c>
ffffffe000203c3c:	02b00793          	li	a5,43
ffffffe000203c40:	0080006f          	j	ffffffe000203c48 <print_dec_int+0x230>
ffffffe000203c44:	02000793          	li	a5,32
ffffffe000203c48:	fa843703          	ld	a4,-88(s0)
ffffffe000203c4c:	00078513          	mv	a0,a5
ffffffe000203c50:	000700e7          	jalr	a4
        ++written;
ffffffe000203c54:	fe442783          	lw	a5,-28(s0)
ffffffe000203c58:	0017879b          	addiw	a5,a5,1
ffffffe000203c5c:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000203c60:	fe842783          	lw	a5,-24(s0)
ffffffe000203c64:	fcf42e23          	sw	a5,-36(s0)
ffffffe000203c68:	0280006f          	j	ffffffe000203c90 <print_dec_int+0x278>
        putch('0');
ffffffe000203c6c:	fa843783          	ld	a5,-88(s0)
ffffffe000203c70:	03000513          	li	a0,48
ffffffe000203c74:	000780e7          	jalr	a5
        ++written;
ffffffe000203c78:	fe442783          	lw	a5,-28(s0)
ffffffe000203c7c:	0017879b          	addiw	a5,a5,1
ffffffe000203c80:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000203c84:	fdc42783          	lw	a5,-36(s0)
ffffffe000203c88:	0017879b          	addiw	a5,a5,1
ffffffe000203c8c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000203c90:	f9043783          	ld	a5,-112(s0)
ffffffe000203c94:	00c7a703          	lw	a4,12(a5)
ffffffe000203c98:	fd744783          	lbu	a5,-41(s0)
ffffffe000203c9c:	0007879b          	sext.w	a5,a5
ffffffe000203ca0:	40f707bb          	subw	a5,a4,a5
ffffffe000203ca4:	0007871b          	sext.w	a4,a5
ffffffe000203ca8:	fdc42783          	lw	a5,-36(s0)
ffffffe000203cac:	0007879b          	sext.w	a5,a5
ffffffe000203cb0:	fae7cee3          	blt	a5,a4,ffffffe000203c6c <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203cb4:	fe842783          	lw	a5,-24(s0)
ffffffe000203cb8:	fff7879b          	addiw	a5,a5,-1
ffffffe000203cbc:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203cc0:	03c0006f          	j	ffffffe000203cfc <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000203cc4:	fd842783          	lw	a5,-40(s0)
ffffffe000203cc8:	ff078793          	addi	a5,a5,-16
ffffffe000203ccc:	008787b3          	add	a5,a5,s0
ffffffe000203cd0:	fc87c783          	lbu	a5,-56(a5)
ffffffe000203cd4:	0007871b          	sext.w	a4,a5
ffffffe000203cd8:	fa843783          	ld	a5,-88(s0)
ffffffe000203cdc:	00070513          	mv	a0,a4
ffffffe000203ce0:	000780e7          	jalr	a5
        ++written;
ffffffe000203ce4:	fe442783          	lw	a5,-28(s0)
ffffffe000203ce8:	0017879b          	addiw	a5,a5,1
ffffffe000203cec:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000203cf0:	fd842783          	lw	a5,-40(s0)
ffffffe000203cf4:	fff7879b          	addiw	a5,a5,-1
ffffffe000203cf8:	fcf42c23          	sw	a5,-40(s0)
ffffffe000203cfc:	fd842783          	lw	a5,-40(s0)
ffffffe000203d00:	0007879b          	sext.w	a5,a5
ffffffe000203d04:	fc07d0e3          	bgez	a5,ffffffe000203cc4 <print_dec_int+0x2ac>
    }

    return written;
ffffffe000203d08:	fe442783          	lw	a5,-28(s0)
}
ffffffe000203d0c:	00078513          	mv	a0,a5
ffffffe000203d10:	06813083          	ld	ra,104(sp)
ffffffe000203d14:	06013403          	ld	s0,96(sp)
ffffffe000203d18:	07010113          	addi	sp,sp,112
ffffffe000203d1c:	00008067          	ret

ffffffe000203d20 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000203d20:	f4010113          	addi	sp,sp,-192
ffffffe000203d24:	0a113c23          	sd	ra,184(sp)
ffffffe000203d28:	0a813823          	sd	s0,176(sp)
ffffffe000203d2c:	0c010413          	addi	s0,sp,192
ffffffe000203d30:	f4a43c23          	sd	a0,-168(s0)
ffffffe000203d34:	f4b43823          	sd	a1,-176(s0)
ffffffe000203d38:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000203d3c:	f8043023          	sd	zero,-128(s0)
ffffffe000203d40:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000203d44:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000203d48:	7a40006f          	j	ffffffe0002044ec <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000203d4c:	f8044783          	lbu	a5,-128(s0)
ffffffe000203d50:	72078e63          	beqz	a5,ffffffe00020448c <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000203d54:	f5043783          	ld	a5,-176(s0)
ffffffe000203d58:	0007c783          	lbu	a5,0(a5)
ffffffe000203d5c:	00078713          	mv	a4,a5
ffffffe000203d60:	02300793          	li	a5,35
ffffffe000203d64:	00f71863          	bne	a4,a5,ffffffe000203d74 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000203d68:	00100793          	li	a5,1
ffffffe000203d6c:	f8f40123          	sb	a5,-126(s0)
ffffffe000203d70:	7700006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe000203d74:	f5043783          	ld	a5,-176(s0)
ffffffe000203d78:	0007c783          	lbu	a5,0(a5)
ffffffe000203d7c:	00078713          	mv	a4,a5
ffffffe000203d80:	03000793          	li	a5,48
ffffffe000203d84:	00f71863          	bne	a4,a5,ffffffe000203d94 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe000203d88:	00100793          	li	a5,1
ffffffe000203d8c:	f8f401a3          	sb	a5,-125(s0)
ffffffe000203d90:	7500006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe000203d94:	f5043783          	ld	a5,-176(s0)
ffffffe000203d98:	0007c783          	lbu	a5,0(a5)
ffffffe000203d9c:	00078713          	mv	a4,a5
ffffffe000203da0:	06c00793          	li	a5,108
ffffffe000203da4:	04f70063          	beq	a4,a5,ffffffe000203de4 <vprintfmt+0xc4>
ffffffe000203da8:	f5043783          	ld	a5,-176(s0)
ffffffe000203dac:	0007c783          	lbu	a5,0(a5)
ffffffe000203db0:	00078713          	mv	a4,a5
ffffffe000203db4:	07a00793          	li	a5,122
ffffffe000203db8:	02f70663          	beq	a4,a5,ffffffe000203de4 <vprintfmt+0xc4>
ffffffe000203dbc:	f5043783          	ld	a5,-176(s0)
ffffffe000203dc0:	0007c783          	lbu	a5,0(a5)
ffffffe000203dc4:	00078713          	mv	a4,a5
ffffffe000203dc8:	07400793          	li	a5,116
ffffffe000203dcc:	00f70c63          	beq	a4,a5,ffffffe000203de4 <vprintfmt+0xc4>
ffffffe000203dd0:	f5043783          	ld	a5,-176(s0)
ffffffe000203dd4:	0007c783          	lbu	a5,0(a5)
ffffffe000203dd8:	00078713          	mv	a4,a5
ffffffe000203ddc:	06a00793          	li	a5,106
ffffffe000203de0:	00f71863          	bne	a4,a5,ffffffe000203df0 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000203de4:	00100793          	li	a5,1
ffffffe000203de8:	f8f400a3          	sb	a5,-127(s0)
ffffffe000203dec:	6f40006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000203df0:	f5043783          	ld	a5,-176(s0)
ffffffe000203df4:	0007c783          	lbu	a5,0(a5)
ffffffe000203df8:	00078713          	mv	a4,a5
ffffffe000203dfc:	02b00793          	li	a5,43
ffffffe000203e00:	00f71863          	bne	a4,a5,ffffffe000203e10 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000203e04:	00100793          	li	a5,1
ffffffe000203e08:	f8f402a3          	sb	a5,-123(s0)
ffffffe000203e0c:	6d40006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000203e10:	f5043783          	ld	a5,-176(s0)
ffffffe000203e14:	0007c783          	lbu	a5,0(a5)
ffffffe000203e18:	00078713          	mv	a4,a5
ffffffe000203e1c:	02000793          	li	a5,32
ffffffe000203e20:	00f71863          	bne	a4,a5,ffffffe000203e30 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000203e24:	00100793          	li	a5,1
ffffffe000203e28:	f8f40223          	sb	a5,-124(s0)
ffffffe000203e2c:	6b40006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000203e30:	f5043783          	ld	a5,-176(s0)
ffffffe000203e34:	0007c783          	lbu	a5,0(a5)
ffffffe000203e38:	00078713          	mv	a4,a5
ffffffe000203e3c:	02a00793          	li	a5,42
ffffffe000203e40:	00f71e63          	bne	a4,a5,ffffffe000203e5c <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe000203e44:	f4843783          	ld	a5,-184(s0)
ffffffe000203e48:	00878713          	addi	a4,a5,8
ffffffe000203e4c:	f4e43423          	sd	a4,-184(s0)
ffffffe000203e50:	0007a783          	lw	a5,0(a5)
ffffffe000203e54:	f8f42423          	sw	a5,-120(s0)
ffffffe000203e58:	6880006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000203e5c:	f5043783          	ld	a5,-176(s0)
ffffffe000203e60:	0007c783          	lbu	a5,0(a5)
ffffffe000203e64:	00078713          	mv	a4,a5
ffffffe000203e68:	03000793          	li	a5,48
ffffffe000203e6c:	04e7f663          	bgeu	a5,a4,ffffffe000203eb8 <vprintfmt+0x198>
ffffffe000203e70:	f5043783          	ld	a5,-176(s0)
ffffffe000203e74:	0007c783          	lbu	a5,0(a5)
ffffffe000203e78:	00078713          	mv	a4,a5
ffffffe000203e7c:	03900793          	li	a5,57
ffffffe000203e80:	02e7ec63          	bltu	a5,a4,ffffffe000203eb8 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe000203e84:	f5043783          	ld	a5,-176(s0)
ffffffe000203e88:	f5040713          	addi	a4,s0,-176
ffffffe000203e8c:	00a00613          	li	a2,10
ffffffe000203e90:	00070593          	mv	a1,a4
ffffffe000203e94:	00078513          	mv	a0,a5
ffffffe000203e98:	88dff0ef          	jal	ra,ffffffe000203724 <strtol>
ffffffe000203e9c:	00050793          	mv	a5,a0
ffffffe000203ea0:	0007879b          	sext.w	a5,a5
ffffffe000203ea4:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe000203ea8:	f5043783          	ld	a5,-176(s0)
ffffffe000203eac:	fff78793          	addi	a5,a5,-1
ffffffe000203eb0:	f4f43823          	sd	a5,-176(s0)
ffffffe000203eb4:	62c0006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe000203eb8:	f5043783          	ld	a5,-176(s0)
ffffffe000203ebc:	0007c783          	lbu	a5,0(a5)
ffffffe000203ec0:	00078713          	mv	a4,a5
ffffffe000203ec4:	02e00793          	li	a5,46
ffffffe000203ec8:	06f71863          	bne	a4,a5,ffffffe000203f38 <vprintfmt+0x218>
                fmt++;
ffffffe000203ecc:	f5043783          	ld	a5,-176(s0)
ffffffe000203ed0:	00178793          	addi	a5,a5,1
ffffffe000203ed4:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000203ed8:	f5043783          	ld	a5,-176(s0)
ffffffe000203edc:	0007c783          	lbu	a5,0(a5)
ffffffe000203ee0:	00078713          	mv	a4,a5
ffffffe000203ee4:	02a00793          	li	a5,42
ffffffe000203ee8:	00f71e63          	bne	a4,a5,ffffffe000203f04 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe000203eec:	f4843783          	ld	a5,-184(s0)
ffffffe000203ef0:	00878713          	addi	a4,a5,8
ffffffe000203ef4:	f4e43423          	sd	a4,-184(s0)
ffffffe000203ef8:	0007a783          	lw	a5,0(a5)
ffffffe000203efc:	f8f42623          	sw	a5,-116(s0)
ffffffe000203f00:	5e00006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000203f04:	f5043783          	ld	a5,-176(s0)
ffffffe000203f08:	f5040713          	addi	a4,s0,-176
ffffffe000203f0c:	00a00613          	li	a2,10
ffffffe000203f10:	00070593          	mv	a1,a4
ffffffe000203f14:	00078513          	mv	a0,a5
ffffffe000203f18:	80dff0ef          	jal	ra,ffffffe000203724 <strtol>
ffffffe000203f1c:	00050793          	mv	a5,a0
ffffffe000203f20:	0007879b          	sext.w	a5,a5
ffffffe000203f24:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000203f28:	f5043783          	ld	a5,-176(s0)
ffffffe000203f2c:	fff78793          	addi	a5,a5,-1
ffffffe000203f30:	f4f43823          	sd	a5,-176(s0)
ffffffe000203f34:	5ac0006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000203f38:	f5043783          	ld	a5,-176(s0)
ffffffe000203f3c:	0007c783          	lbu	a5,0(a5)
ffffffe000203f40:	00078713          	mv	a4,a5
ffffffe000203f44:	07800793          	li	a5,120
ffffffe000203f48:	02f70663          	beq	a4,a5,ffffffe000203f74 <vprintfmt+0x254>
ffffffe000203f4c:	f5043783          	ld	a5,-176(s0)
ffffffe000203f50:	0007c783          	lbu	a5,0(a5)
ffffffe000203f54:	00078713          	mv	a4,a5
ffffffe000203f58:	05800793          	li	a5,88
ffffffe000203f5c:	00f70c63          	beq	a4,a5,ffffffe000203f74 <vprintfmt+0x254>
ffffffe000203f60:	f5043783          	ld	a5,-176(s0)
ffffffe000203f64:	0007c783          	lbu	a5,0(a5)
ffffffe000203f68:	00078713          	mv	a4,a5
ffffffe000203f6c:	07000793          	li	a5,112
ffffffe000203f70:	30f71263          	bne	a4,a5,ffffffe000204274 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000203f74:	f5043783          	ld	a5,-176(s0)
ffffffe000203f78:	0007c783          	lbu	a5,0(a5)
ffffffe000203f7c:	00078713          	mv	a4,a5
ffffffe000203f80:	07000793          	li	a5,112
ffffffe000203f84:	00f70663          	beq	a4,a5,ffffffe000203f90 <vprintfmt+0x270>
ffffffe000203f88:	f8144783          	lbu	a5,-127(s0)
ffffffe000203f8c:	00078663          	beqz	a5,ffffffe000203f98 <vprintfmt+0x278>
ffffffe000203f90:	00100793          	li	a5,1
ffffffe000203f94:	0080006f          	j	ffffffe000203f9c <vprintfmt+0x27c>
ffffffe000203f98:	00000793          	li	a5,0
ffffffe000203f9c:	faf403a3          	sb	a5,-89(s0)
ffffffe000203fa0:	fa744783          	lbu	a5,-89(s0)
ffffffe000203fa4:	0017f793          	andi	a5,a5,1
ffffffe000203fa8:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000203fac:	fa744783          	lbu	a5,-89(s0)
ffffffe000203fb0:	0ff7f793          	zext.b	a5,a5
ffffffe000203fb4:	00078c63          	beqz	a5,ffffffe000203fcc <vprintfmt+0x2ac>
ffffffe000203fb8:	f4843783          	ld	a5,-184(s0)
ffffffe000203fbc:	00878713          	addi	a4,a5,8
ffffffe000203fc0:	f4e43423          	sd	a4,-184(s0)
ffffffe000203fc4:	0007b783          	ld	a5,0(a5)
ffffffe000203fc8:	01c0006f          	j	ffffffe000203fe4 <vprintfmt+0x2c4>
ffffffe000203fcc:	f4843783          	ld	a5,-184(s0)
ffffffe000203fd0:	00878713          	addi	a4,a5,8
ffffffe000203fd4:	f4e43423          	sd	a4,-184(s0)
ffffffe000203fd8:	0007a783          	lw	a5,0(a5)
ffffffe000203fdc:	02079793          	slli	a5,a5,0x20
ffffffe000203fe0:	0207d793          	srli	a5,a5,0x20
ffffffe000203fe4:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000203fe8:	f8c42783          	lw	a5,-116(s0)
ffffffe000203fec:	02079463          	bnez	a5,ffffffe000204014 <vprintfmt+0x2f4>
ffffffe000203ff0:	fe043783          	ld	a5,-32(s0)
ffffffe000203ff4:	02079063          	bnez	a5,ffffffe000204014 <vprintfmt+0x2f4>
ffffffe000203ff8:	f5043783          	ld	a5,-176(s0)
ffffffe000203ffc:	0007c783          	lbu	a5,0(a5)
ffffffe000204000:	00078713          	mv	a4,a5
ffffffe000204004:	07000793          	li	a5,112
ffffffe000204008:	00f70663          	beq	a4,a5,ffffffe000204014 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe00020400c:	f8040023          	sb	zero,-128(s0)
ffffffe000204010:	4d00006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000204014:	f5043783          	ld	a5,-176(s0)
ffffffe000204018:	0007c783          	lbu	a5,0(a5)
ffffffe00020401c:	00078713          	mv	a4,a5
ffffffe000204020:	07000793          	li	a5,112
ffffffe000204024:	00f70a63          	beq	a4,a5,ffffffe000204038 <vprintfmt+0x318>
ffffffe000204028:	f8244783          	lbu	a5,-126(s0)
ffffffe00020402c:	00078a63          	beqz	a5,ffffffe000204040 <vprintfmt+0x320>
ffffffe000204030:	fe043783          	ld	a5,-32(s0)
ffffffe000204034:	00078663          	beqz	a5,ffffffe000204040 <vprintfmt+0x320>
ffffffe000204038:	00100793          	li	a5,1
ffffffe00020403c:	0080006f          	j	ffffffe000204044 <vprintfmt+0x324>
ffffffe000204040:	00000793          	li	a5,0
ffffffe000204044:	faf40323          	sb	a5,-90(s0)
ffffffe000204048:	fa644783          	lbu	a5,-90(s0)
ffffffe00020404c:	0017f793          	andi	a5,a5,1
ffffffe000204050:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000204054:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000204058:	f5043783          	ld	a5,-176(s0)
ffffffe00020405c:	0007c783          	lbu	a5,0(a5)
ffffffe000204060:	00078713          	mv	a4,a5
ffffffe000204064:	05800793          	li	a5,88
ffffffe000204068:	00f71863          	bne	a4,a5,ffffffe000204078 <vprintfmt+0x358>
ffffffe00020406c:	00001797          	auipc	a5,0x1
ffffffe000204070:	72c78793          	addi	a5,a5,1836 # ffffffe000205798 <upperxdigits.1>
ffffffe000204074:	00c0006f          	j	ffffffe000204080 <vprintfmt+0x360>
ffffffe000204078:	00001797          	auipc	a5,0x1
ffffffe00020407c:	73878793          	addi	a5,a5,1848 # ffffffe0002057b0 <lowerxdigits.0>
ffffffe000204080:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000204084:	fe043783          	ld	a5,-32(s0)
ffffffe000204088:	00f7f793          	andi	a5,a5,15
ffffffe00020408c:	f9843703          	ld	a4,-104(s0)
ffffffe000204090:	00f70733          	add	a4,a4,a5
ffffffe000204094:	fdc42783          	lw	a5,-36(s0)
ffffffe000204098:	0017869b          	addiw	a3,a5,1
ffffffe00020409c:	fcd42e23          	sw	a3,-36(s0)
ffffffe0002040a0:	00074703          	lbu	a4,0(a4)
ffffffe0002040a4:	ff078793          	addi	a5,a5,-16
ffffffe0002040a8:	008787b3          	add	a5,a5,s0
ffffffe0002040ac:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe0002040b0:	fe043783          	ld	a5,-32(s0)
ffffffe0002040b4:	0047d793          	srli	a5,a5,0x4
ffffffe0002040b8:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe0002040bc:	fe043783          	ld	a5,-32(s0)
ffffffe0002040c0:	fc0792e3          	bnez	a5,ffffffe000204084 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe0002040c4:	f8c42783          	lw	a5,-116(s0)
ffffffe0002040c8:	00078713          	mv	a4,a5
ffffffe0002040cc:	fff00793          	li	a5,-1
ffffffe0002040d0:	02f71663          	bne	a4,a5,ffffffe0002040fc <vprintfmt+0x3dc>
ffffffe0002040d4:	f8344783          	lbu	a5,-125(s0)
ffffffe0002040d8:	02078263          	beqz	a5,ffffffe0002040fc <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe0002040dc:	f8842703          	lw	a4,-120(s0)
ffffffe0002040e0:	fa644783          	lbu	a5,-90(s0)
ffffffe0002040e4:	0007879b          	sext.w	a5,a5
ffffffe0002040e8:	0017979b          	slliw	a5,a5,0x1
ffffffe0002040ec:	0007879b          	sext.w	a5,a5
ffffffe0002040f0:	40f707bb          	subw	a5,a4,a5
ffffffe0002040f4:	0007879b          	sext.w	a5,a5
ffffffe0002040f8:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe0002040fc:	f8842703          	lw	a4,-120(s0)
ffffffe000204100:	fa644783          	lbu	a5,-90(s0)
ffffffe000204104:	0007879b          	sext.w	a5,a5
ffffffe000204108:	0017979b          	slliw	a5,a5,0x1
ffffffe00020410c:	0007879b          	sext.w	a5,a5
ffffffe000204110:	40f707bb          	subw	a5,a4,a5
ffffffe000204114:	0007871b          	sext.w	a4,a5
ffffffe000204118:	fdc42783          	lw	a5,-36(s0)
ffffffe00020411c:	f8f42a23          	sw	a5,-108(s0)
ffffffe000204120:	f8c42783          	lw	a5,-116(s0)
ffffffe000204124:	f8f42823          	sw	a5,-112(s0)
ffffffe000204128:	f9442783          	lw	a5,-108(s0)
ffffffe00020412c:	00078593          	mv	a1,a5
ffffffe000204130:	f9042783          	lw	a5,-112(s0)
ffffffe000204134:	00078613          	mv	a2,a5
ffffffe000204138:	0006069b          	sext.w	a3,a2
ffffffe00020413c:	0005879b          	sext.w	a5,a1
ffffffe000204140:	00f6d463          	bge	a3,a5,ffffffe000204148 <vprintfmt+0x428>
ffffffe000204144:	00058613          	mv	a2,a1
ffffffe000204148:	0006079b          	sext.w	a5,a2
ffffffe00020414c:	40f707bb          	subw	a5,a4,a5
ffffffe000204150:	fcf42c23          	sw	a5,-40(s0)
ffffffe000204154:	0280006f          	j	ffffffe00020417c <vprintfmt+0x45c>
                    putch(' ');
ffffffe000204158:	f5843783          	ld	a5,-168(s0)
ffffffe00020415c:	02000513          	li	a0,32
ffffffe000204160:	000780e7          	jalr	a5
                    ++written;
ffffffe000204164:	fec42783          	lw	a5,-20(s0)
ffffffe000204168:	0017879b          	addiw	a5,a5,1
ffffffe00020416c:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000204170:	fd842783          	lw	a5,-40(s0)
ffffffe000204174:	fff7879b          	addiw	a5,a5,-1
ffffffe000204178:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020417c:	fd842783          	lw	a5,-40(s0)
ffffffe000204180:	0007879b          	sext.w	a5,a5
ffffffe000204184:	fcf04ae3          	bgtz	a5,ffffffe000204158 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe000204188:	fa644783          	lbu	a5,-90(s0)
ffffffe00020418c:	0ff7f793          	zext.b	a5,a5
ffffffe000204190:	04078463          	beqz	a5,ffffffe0002041d8 <vprintfmt+0x4b8>
                    putch('0');
ffffffe000204194:	f5843783          	ld	a5,-168(s0)
ffffffe000204198:	03000513          	li	a0,48
ffffffe00020419c:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe0002041a0:	f5043783          	ld	a5,-176(s0)
ffffffe0002041a4:	0007c783          	lbu	a5,0(a5)
ffffffe0002041a8:	00078713          	mv	a4,a5
ffffffe0002041ac:	05800793          	li	a5,88
ffffffe0002041b0:	00f71663          	bne	a4,a5,ffffffe0002041bc <vprintfmt+0x49c>
ffffffe0002041b4:	05800793          	li	a5,88
ffffffe0002041b8:	0080006f          	j	ffffffe0002041c0 <vprintfmt+0x4a0>
ffffffe0002041bc:	07800793          	li	a5,120
ffffffe0002041c0:	f5843703          	ld	a4,-168(s0)
ffffffe0002041c4:	00078513          	mv	a0,a5
ffffffe0002041c8:	000700e7          	jalr	a4
                    written += 2;
ffffffe0002041cc:	fec42783          	lw	a5,-20(s0)
ffffffe0002041d0:	0027879b          	addiw	a5,a5,2
ffffffe0002041d4:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe0002041d8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002041dc:	fcf42a23          	sw	a5,-44(s0)
ffffffe0002041e0:	0280006f          	j	ffffffe000204208 <vprintfmt+0x4e8>
                    putch('0');
ffffffe0002041e4:	f5843783          	ld	a5,-168(s0)
ffffffe0002041e8:	03000513          	li	a0,48
ffffffe0002041ec:	000780e7          	jalr	a5
                    ++written;
ffffffe0002041f0:	fec42783          	lw	a5,-20(s0)
ffffffe0002041f4:	0017879b          	addiw	a5,a5,1
ffffffe0002041f8:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe0002041fc:	fd442783          	lw	a5,-44(s0)
ffffffe000204200:	0017879b          	addiw	a5,a5,1
ffffffe000204204:	fcf42a23          	sw	a5,-44(s0)
ffffffe000204208:	f8c42703          	lw	a4,-116(s0)
ffffffe00020420c:	fd442783          	lw	a5,-44(s0)
ffffffe000204210:	0007879b          	sext.w	a5,a5
ffffffe000204214:	fce7c8e3          	blt	a5,a4,ffffffe0002041e4 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000204218:	fdc42783          	lw	a5,-36(s0)
ffffffe00020421c:	fff7879b          	addiw	a5,a5,-1
ffffffe000204220:	fcf42823          	sw	a5,-48(s0)
ffffffe000204224:	03c0006f          	j	ffffffe000204260 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe000204228:	fd042783          	lw	a5,-48(s0)
ffffffe00020422c:	ff078793          	addi	a5,a5,-16
ffffffe000204230:	008787b3          	add	a5,a5,s0
ffffffe000204234:	f807c783          	lbu	a5,-128(a5)
ffffffe000204238:	0007871b          	sext.w	a4,a5
ffffffe00020423c:	f5843783          	ld	a5,-168(s0)
ffffffe000204240:	00070513          	mv	a0,a4
ffffffe000204244:	000780e7          	jalr	a5
                    ++written;
ffffffe000204248:	fec42783          	lw	a5,-20(s0)
ffffffe00020424c:	0017879b          	addiw	a5,a5,1
ffffffe000204250:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe000204254:	fd042783          	lw	a5,-48(s0)
ffffffe000204258:	fff7879b          	addiw	a5,a5,-1
ffffffe00020425c:	fcf42823          	sw	a5,-48(s0)
ffffffe000204260:	fd042783          	lw	a5,-48(s0)
ffffffe000204264:	0007879b          	sext.w	a5,a5
ffffffe000204268:	fc07d0e3          	bgez	a5,ffffffe000204228 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe00020426c:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000204270:	2700006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000204274:	f5043783          	ld	a5,-176(s0)
ffffffe000204278:	0007c783          	lbu	a5,0(a5)
ffffffe00020427c:	00078713          	mv	a4,a5
ffffffe000204280:	06400793          	li	a5,100
ffffffe000204284:	02f70663          	beq	a4,a5,ffffffe0002042b0 <vprintfmt+0x590>
ffffffe000204288:	f5043783          	ld	a5,-176(s0)
ffffffe00020428c:	0007c783          	lbu	a5,0(a5)
ffffffe000204290:	00078713          	mv	a4,a5
ffffffe000204294:	06900793          	li	a5,105
ffffffe000204298:	00f70c63          	beq	a4,a5,ffffffe0002042b0 <vprintfmt+0x590>
ffffffe00020429c:	f5043783          	ld	a5,-176(s0)
ffffffe0002042a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002042a4:	00078713          	mv	a4,a5
ffffffe0002042a8:	07500793          	li	a5,117
ffffffe0002042ac:	08f71063          	bne	a4,a5,ffffffe00020432c <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe0002042b0:	f8144783          	lbu	a5,-127(s0)
ffffffe0002042b4:	00078c63          	beqz	a5,ffffffe0002042cc <vprintfmt+0x5ac>
ffffffe0002042b8:	f4843783          	ld	a5,-184(s0)
ffffffe0002042bc:	00878713          	addi	a4,a5,8
ffffffe0002042c0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002042c4:	0007b783          	ld	a5,0(a5)
ffffffe0002042c8:	0140006f          	j	ffffffe0002042dc <vprintfmt+0x5bc>
ffffffe0002042cc:	f4843783          	ld	a5,-184(s0)
ffffffe0002042d0:	00878713          	addi	a4,a5,8
ffffffe0002042d4:	f4e43423          	sd	a4,-184(s0)
ffffffe0002042d8:	0007a783          	lw	a5,0(a5)
ffffffe0002042dc:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe0002042e0:	fa843583          	ld	a1,-88(s0)
ffffffe0002042e4:	f5043783          	ld	a5,-176(s0)
ffffffe0002042e8:	0007c783          	lbu	a5,0(a5)
ffffffe0002042ec:	0007871b          	sext.w	a4,a5
ffffffe0002042f0:	07500793          	li	a5,117
ffffffe0002042f4:	40f707b3          	sub	a5,a4,a5
ffffffe0002042f8:	00f037b3          	snez	a5,a5
ffffffe0002042fc:	0ff7f793          	zext.b	a5,a5
ffffffe000204300:	f8040713          	addi	a4,s0,-128
ffffffe000204304:	00070693          	mv	a3,a4
ffffffe000204308:	00078613          	mv	a2,a5
ffffffe00020430c:	f5843503          	ld	a0,-168(s0)
ffffffe000204310:	f08ff0ef          	jal	ra,ffffffe000203a18 <print_dec_int>
ffffffe000204314:	00050793          	mv	a5,a0
ffffffe000204318:	fec42703          	lw	a4,-20(s0)
ffffffe00020431c:	00f707bb          	addw	a5,a4,a5
ffffffe000204320:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000204324:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000204328:	1b80006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe00020432c:	f5043783          	ld	a5,-176(s0)
ffffffe000204330:	0007c783          	lbu	a5,0(a5)
ffffffe000204334:	00078713          	mv	a4,a5
ffffffe000204338:	06e00793          	li	a5,110
ffffffe00020433c:	04f71c63          	bne	a4,a5,ffffffe000204394 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe000204340:	f8144783          	lbu	a5,-127(s0)
ffffffe000204344:	02078463          	beqz	a5,ffffffe00020436c <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe000204348:	f4843783          	ld	a5,-184(s0)
ffffffe00020434c:	00878713          	addi	a4,a5,8
ffffffe000204350:	f4e43423          	sd	a4,-184(s0)
ffffffe000204354:	0007b783          	ld	a5,0(a5)
ffffffe000204358:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe00020435c:	fec42703          	lw	a4,-20(s0)
ffffffe000204360:	fb043783          	ld	a5,-80(s0)
ffffffe000204364:	00e7b023          	sd	a4,0(a5)
ffffffe000204368:	0240006f          	j	ffffffe00020438c <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe00020436c:	f4843783          	ld	a5,-184(s0)
ffffffe000204370:	00878713          	addi	a4,a5,8
ffffffe000204374:	f4e43423          	sd	a4,-184(s0)
ffffffe000204378:	0007b783          	ld	a5,0(a5)
ffffffe00020437c:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000204380:	fb843783          	ld	a5,-72(s0)
ffffffe000204384:	fec42703          	lw	a4,-20(s0)
ffffffe000204388:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe00020438c:	f8040023          	sb	zero,-128(s0)
ffffffe000204390:	1500006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000204394:	f5043783          	ld	a5,-176(s0)
ffffffe000204398:	0007c783          	lbu	a5,0(a5)
ffffffe00020439c:	00078713          	mv	a4,a5
ffffffe0002043a0:	07300793          	li	a5,115
ffffffe0002043a4:	02f71e63          	bne	a4,a5,ffffffe0002043e0 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe0002043a8:	f4843783          	ld	a5,-184(s0)
ffffffe0002043ac:	00878713          	addi	a4,a5,8
ffffffe0002043b0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002043b4:	0007b783          	ld	a5,0(a5)
ffffffe0002043b8:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe0002043bc:	fc043583          	ld	a1,-64(s0)
ffffffe0002043c0:	f5843503          	ld	a0,-168(s0)
ffffffe0002043c4:	dccff0ef          	jal	ra,ffffffe000203990 <puts_wo_nl>
ffffffe0002043c8:	00050793          	mv	a5,a0
ffffffe0002043cc:	fec42703          	lw	a4,-20(s0)
ffffffe0002043d0:	00f707bb          	addw	a5,a4,a5
ffffffe0002043d4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002043d8:	f8040023          	sb	zero,-128(s0)
ffffffe0002043dc:	1040006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe0002043e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002043e4:	0007c783          	lbu	a5,0(a5)
ffffffe0002043e8:	00078713          	mv	a4,a5
ffffffe0002043ec:	06300793          	li	a5,99
ffffffe0002043f0:	02f71e63          	bne	a4,a5,ffffffe00020442c <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe0002043f4:	f4843783          	ld	a5,-184(s0)
ffffffe0002043f8:	00878713          	addi	a4,a5,8
ffffffe0002043fc:	f4e43423          	sd	a4,-184(s0)
ffffffe000204400:	0007a783          	lw	a5,0(a5)
ffffffe000204404:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000204408:	fcc42703          	lw	a4,-52(s0)
ffffffe00020440c:	f5843783          	ld	a5,-168(s0)
ffffffe000204410:	00070513          	mv	a0,a4
ffffffe000204414:	000780e7          	jalr	a5
                ++written;
ffffffe000204418:	fec42783          	lw	a5,-20(s0)
ffffffe00020441c:	0017879b          	addiw	a5,a5,1
ffffffe000204420:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000204424:	f8040023          	sb	zero,-128(s0)
ffffffe000204428:	0b80006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe00020442c:	f5043783          	ld	a5,-176(s0)
ffffffe000204430:	0007c783          	lbu	a5,0(a5)
ffffffe000204434:	00078713          	mv	a4,a5
ffffffe000204438:	02500793          	li	a5,37
ffffffe00020443c:	02f71263          	bne	a4,a5,ffffffe000204460 <vprintfmt+0x740>
                putch('%');
ffffffe000204440:	f5843783          	ld	a5,-168(s0)
ffffffe000204444:	02500513          	li	a0,37
ffffffe000204448:	000780e7          	jalr	a5
                ++written;
ffffffe00020444c:	fec42783          	lw	a5,-20(s0)
ffffffe000204450:	0017879b          	addiw	a5,a5,1
ffffffe000204454:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000204458:	f8040023          	sb	zero,-128(s0)
ffffffe00020445c:	0840006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe000204460:	f5043783          	ld	a5,-176(s0)
ffffffe000204464:	0007c783          	lbu	a5,0(a5)
ffffffe000204468:	0007871b          	sext.w	a4,a5
ffffffe00020446c:	f5843783          	ld	a5,-168(s0)
ffffffe000204470:	00070513          	mv	a0,a4
ffffffe000204474:	000780e7          	jalr	a5
                ++written;
ffffffe000204478:	fec42783          	lw	a5,-20(s0)
ffffffe00020447c:	0017879b          	addiw	a5,a5,1
ffffffe000204480:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000204484:	f8040023          	sb	zero,-128(s0)
ffffffe000204488:	0580006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe00020448c:	f5043783          	ld	a5,-176(s0)
ffffffe000204490:	0007c783          	lbu	a5,0(a5)
ffffffe000204494:	00078713          	mv	a4,a5
ffffffe000204498:	02500793          	li	a5,37
ffffffe00020449c:	02f71063          	bne	a4,a5,ffffffe0002044bc <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe0002044a0:	f8043023          	sd	zero,-128(s0)
ffffffe0002044a4:	f8043423          	sd	zero,-120(s0)
ffffffe0002044a8:	00100793          	li	a5,1
ffffffe0002044ac:	f8f40023          	sb	a5,-128(s0)
ffffffe0002044b0:	fff00793          	li	a5,-1
ffffffe0002044b4:	f8f42623          	sw	a5,-116(s0)
ffffffe0002044b8:	0280006f          	j	ffffffe0002044e0 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe0002044bc:	f5043783          	ld	a5,-176(s0)
ffffffe0002044c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002044c4:	0007871b          	sext.w	a4,a5
ffffffe0002044c8:	f5843783          	ld	a5,-168(s0)
ffffffe0002044cc:	00070513          	mv	a0,a4
ffffffe0002044d0:	000780e7          	jalr	a5
            ++written;
ffffffe0002044d4:	fec42783          	lw	a5,-20(s0)
ffffffe0002044d8:	0017879b          	addiw	a5,a5,1
ffffffe0002044dc:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe0002044e0:	f5043783          	ld	a5,-176(s0)
ffffffe0002044e4:	00178793          	addi	a5,a5,1
ffffffe0002044e8:	f4f43823          	sd	a5,-176(s0)
ffffffe0002044ec:	f5043783          	ld	a5,-176(s0)
ffffffe0002044f0:	0007c783          	lbu	a5,0(a5)
ffffffe0002044f4:	84079ce3          	bnez	a5,ffffffe000203d4c <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe0002044f8:	fec42783          	lw	a5,-20(s0)
}
ffffffe0002044fc:	00078513          	mv	a0,a5
ffffffe000204500:	0b813083          	ld	ra,184(sp)
ffffffe000204504:	0b013403          	ld	s0,176(sp)
ffffffe000204508:	0c010113          	addi	sp,sp,192
ffffffe00020450c:	00008067          	ret

ffffffe000204510 <printk>:

int printk(const char* s, ...) {
ffffffe000204510:	f9010113          	addi	sp,sp,-112
ffffffe000204514:	02113423          	sd	ra,40(sp)
ffffffe000204518:	02813023          	sd	s0,32(sp)
ffffffe00020451c:	03010413          	addi	s0,sp,48
ffffffe000204520:	fca43c23          	sd	a0,-40(s0)
ffffffe000204524:	00b43423          	sd	a1,8(s0)
ffffffe000204528:	00c43823          	sd	a2,16(s0)
ffffffe00020452c:	00d43c23          	sd	a3,24(s0)
ffffffe000204530:	02e43023          	sd	a4,32(s0)
ffffffe000204534:	02f43423          	sd	a5,40(s0)
ffffffe000204538:	03043823          	sd	a6,48(s0)
ffffffe00020453c:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000204540:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000204544:	04040793          	addi	a5,s0,64
ffffffe000204548:	fcf43823          	sd	a5,-48(s0)
ffffffe00020454c:	fd043783          	ld	a5,-48(s0)
ffffffe000204550:	fc878793          	addi	a5,a5,-56
ffffffe000204554:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe000204558:	fe043783          	ld	a5,-32(s0)
ffffffe00020455c:	00078613          	mv	a2,a5
ffffffe000204560:	fd843583          	ld	a1,-40(s0)
ffffffe000204564:	fffff517          	auipc	a0,0xfffff
ffffffe000204568:	11850513          	addi	a0,a0,280 # ffffffe00020367c <putc>
ffffffe00020456c:	fb4ff0ef          	jal	ra,ffffffe000203d20 <vprintfmt>
ffffffe000204570:	00050793          	mv	a5,a0
ffffffe000204574:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000204578:	fec42783          	lw	a5,-20(s0)
}
ffffffe00020457c:	00078513          	mv	a0,a5
ffffffe000204580:	02813083          	ld	ra,40(sp)
ffffffe000204584:	02013403          	ld	s0,32(sp)
ffffffe000204588:	07010113          	addi	sp,sp,112
ffffffe00020458c:	00008067          	ret

ffffffe000204590 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000204590:	fe010113          	addi	sp,sp,-32
ffffffe000204594:	00813c23          	sd	s0,24(sp)
ffffffe000204598:	02010413          	addi	s0,sp,32
ffffffe00020459c:	00050793          	mv	a5,a0
ffffffe0002045a0:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe0002045a4:	fec42783          	lw	a5,-20(s0)
ffffffe0002045a8:	fff7879b          	addiw	a5,a5,-1
ffffffe0002045ac:	0007879b          	sext.w	a5,a5
ffffffe0002045b0:	02079713          	slli	a4,a5,0x20
ffffffe0002045b4:	02075713          	srli	a4,a4,0x20
ffffffe0002045b8:	00007797          	auipc	a5,0x7
ffffffe0002045bc:	a6078793          	addi	a5,a5,-1440 # ffffffe00020b018 <seed>
ffffffe0002045c0:	00e7b023          	sd	a4,0(a5)
}
ffffffe0002045c4:	00000013          	nop
ffffffe0002045c8:	01813403          	ld	s0,24(sp)
ffffffe0002045cc:	02010113          	addi	sp,sp,32
ffffffe0002045d0:	00008067          	ret

ffffffe0002045d4 <rand>:

int rand(void) {
ffffffe0002045d4:	ff010113          	addi	sp,sp,-16
ffffffe0002045d8:	00813423          	sd	s0,8(sp)
ffffffe0002045dc:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe0002045e0:	00007797          	auipc	a5,0x7
ffffffe0002045e4:	a3878793          	addi	a5,a5,-1480 # ffffffe00020b018 <seed>
ffffffe0002045e8:	0007b703          	ld	a4,0(a5)
ffffffe0002045ec:	00001797          	auipc	a5,0x1
ffffffe0002045f0:	1dc78793          	addi	a5,a5,476 # ffffffe0002057c8 <lowerxdigits.0+0x18>
ffffffe0002045f4:	0007b783          	ld	a5,0(a5)
ffffffe0002045f8:	02f707b3          	mul	a5,a4,a5
ffffffe0002045fc:	00178713          	addi	a4,a5,1
ffffffe000204600:	00007797          	auipc	a5,0x7
ffffffe000204604:	a1878793          	addi	a5,a5,-1512 # ffffffe00020b018 <seed>
ffffffe000204608:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe00020460c:	00007797          	auipc	a5,0x7
ffffffe000204610:	a0c78793          	addi	a5,a5,-1524 # ffffffe00020b018 <seed>
ffffffe000204614:	0007b783          	ld	a5,0(a5)
ffffffe000204618:	0217d793          	srli	a5,a5,0x21
ffffffe00020461c:	0007879b          	sext.w	a5,a5
}
ffffffe000204620:	00078513          	mv	a0,a5
ffffffe000204624:	00813403          	ld	s0,8(sp)
ffffffe000204628:	01010113          	addi	sp,sp,16
ffffffe00020462c:	00008067          	ret

ffffffe000204630 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe000204630:	fc010113          	addi	sp,sp,-64
ffffffe000204634:	02813c23          	sd	s0,56(sp)
ffffffe000204638:	04010413          	addi	s0,sp,64
ffffffe00020463c:	fca43c23          	sd	a0,-40(s0)
ffffffe000204640:	00058793          	mv	a5,a1
ffffffe000204644:	fcc43423          	sd	a2,-56(s0)
ffffffe000204648:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe00020464c:	fd843783          	ld	a5,-40(s0)
ffffffe000204650:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000204654:	fe043423          	sd	zero,-24(s0)
ffffffe000204658:	0280006f          	j	ffffffe000204680 <memset+0x50>
        s[i] = c;
ffffffe00020465c:	fe043703          	ld	a4,-32(s0)
ffffffe000204660:	fe843783          	ld	a5,-24(s0)
ffffffe000204664:	00f707b3          	add	a5,a4,a5
ffffffe000204668:	fd442703          	lw	a4,-44(s0)
ffffffe00020466c:	0ff77713          	zext.b	a4,a4
ffffffe000204670:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000204674:	fe843783          	ld	a5,-24(s0)
ffffffe000204678:	00178793          	addi	a5,a5,1
ffffffe00020467c:	fef43423          	sd	a5,-24(s0)
ffffffe000204680:	fe843703          	ld	a4,-24(s0)
ffffffe000204684:	fc843783          	ld	a5,-56(s0)
ffffffe000204688:	fcf76ae3          	bltu	a4,a5,ffffffe00020465c <memset+0x2c>
    }
    return dest;
ffffffe00020468c:	fd843783          	ld	a5,-40(s0)
}
ffffffe000204690:	00078513          	mv	a0,a5
ffffffe000204694:	03813403          	ld	s0,56(sp)
ffffffe000204698:	04010113          	addi	sp,sp,64
ffffffe00020469c:	00008067          	ret
