
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .extern task_init
    .extern mm_init
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
    80200000:	00003117          	auipc	sp,0x3
    80200004:	05013103          	ld	sp,80(sp) # 80203050 <_GLOBAL_OFFSET_TABLE_+0x18>

    call mm_init
    80200008:	3c8000ef          	jal	ra,802003d0 <mm_init>
    call task_init
    8020000c:	408000ef          	jal	ra,80200414 <task_init>

    # set stvec = _traps
    la t0, _traps
    80200010:	00003297          	auipc	t0,0x3
    80200014:	0502b283          	ld	t0,80(t0) # 80203060 <_GLOBAL_OFFSET_TABLE_+0x28>
    csrw stvec, t0
    80200018:	10529073          	csrw	stvec,t0
    # set sie[STIE] = 1
    addi t0, zero, 0x20
    8020001c:	02000293          	li	t0,32
    csrw sie, t0
    80200020:	10429073          	csrw	sie,t0
    # set first time interrupt
    rdtime t0
    80200024:	c01022f3          	rdtime	t0
    li t1, 10000000
    80200028:	00989337          	lui	t1,0x989
    8020002c:	6803031b          	addiw	t1,t1,1664 # 989680 <_skernel-0x7f876980>
    add t0, t0, t1
    80200030:	006282b3          	add	t0,t0,t1
    add a0, zero, t0
    80200034:	00500533          	add	a0,zero,t0
    addi a1, zero, 0
    80200038:	00000593          	li	a1,0
    addi a2, zero, 0
    8020003c:	00000613          	li	a2,0
    addi a3, zero, 0
    80200040:	00000693          	li	a3,0
    addi a4, zero, 0
    80200044:	00000713          	li	a4,0
    addi a5, zero, 0
    80200048:	00000793          	li	a5,0
    li a7, 0x54494d45
    8020004c:	544958b7          	lui	a7,0x54495
    80200050:	d458889b          	addiw	a7,a7,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    addi a6, zero, 0
    80200054:	00000813          	li	a6,0
    ecall
    80200058:	00000073          	ecall
    # set sstatus[SIE] = 1
    csrwi sstatus, 0x2
    8020005c:	10015073          	csrwi	sstatus,2

    jal start_kernel
    80200060:	635000ef          	jal	ra,80200e94 <start_kernel>

0000000080200064 <_traps>:
    .align 2
    .globl _traps 

_traps:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -256
    80200064:	f0010113          	addi	sp,sp,-256
    sd x1, 0(sp)
    80200068:	00113023          	sd	ra,0(sp)
    sd x2, 8(sp)
    8020006c:	00213423          	sd	sp,8(sp)
    sd x3, 16(sp)
    80200070:	00313823          	sd	gp,16(sp)
    sd x4, 24(sp)
    80200074:	00413c23          	sd	tp,24(sp)
    sd x5, 32(sp)
    80200078:	02513023          	sd	t0,32(sp)
    sd x6, 40(sp)
    8020007c:	02613423          	sd	t1,40(sp)
    sd x7, 48(sp)
    80200080:	02713823          	sd	t2,48(sp)
    sd x8, 56(sp)
    80200084:	02813c23          	sd	s0,56(sp)
    sd x9, 64(sp)
    80200088:	04913023          	sd	s1,64(sp)
    sd x10, 72(sp)
    8020008c:	04a13423          	sd	a0,72(sp)
    sd x11, 80(sp)
    80200090:	04b13823          	sd	a1,80(sp)
    sd x12, 88(sp)
    80200094:	04c13c23          	sd	a2,88(sp)
    sd x13, 96(sp)
    80200098:	06d13023          	sd	a3,96(sp)
    sd x14, 104(sp)
    8020009c:	06e13423          	sd	a4,104(sp)
    sd x15, 112(sp)
    802000a0:	06f13823          	sd	a5,112(sp)
    sd x16, 120(sp)
    802000a4:	07013c23          	sd	a6,120(sp)
    sd x17, 128(sp)
    802000a8:	09113023          	sd	a7,128(sp)
    sd x18, 136(sp)
    802000ac:	09213423          	sd	s2,136(sp)
    sd x19, 144(sp)
    802000b0:	09313823          	sd	s3,144(sp)
    sd x20, 152(sp)
    802000b4:	09413c23          	sd	s4,152(sp)
    sd x21, 160(sp)
    802000b8:	0b513023          	sd	s5,160(sp)
    sd x22, 168(sp)
    802000bc:	0b613423          	sd	s6,168(sp)
    sd x23, 176(sp)
    802000c0:	0b713823          	sd	s7,176(sp)
    sd x24, 184(sp)
    802000c4:	0b813c23          	sd	s8,184(sp)
    sd x25, 192(sp)
    802000c8:	0d913023          	sd	s9,192(sp)
    sd x26, 200(sp)
    802000cc:	0da13423          	sd	s10,200(sp)
    sd x27, 208(sp)
    802000d0:	0db13823          	sd	s11,208(sp)
    sd x28, 216(sp)
    802000d4:	0dc13c23          	sd	t3,216(sp)
    sd x29, 224(sp)
    802000d8:	0fd13023          	sd	t4,224(sp)
    sd x30, 232(sp)
    802000dc:	0fe13423          	sd	t5,232(sp)
    sd x31, 240(sp)
    802000e0:	0ff13823          	sd	t6,240(sp)
    csrr t0, sepc
    802000e4:	141022f3          	csrr	t0,sepc
    sd t0, 248(sp)
    802000e8:	0e513c23          	sd	t0,248(sp)
    # 2. call trap_handler
    csrr a0, scause
    802000ec:	14202573          	csrr	a0,scause
    csrr a1, sepc
    802000f0:	141025f3          	csrr	a1,sepc
    call trap_handler
    802000f4:	4b9000ef          	jal	ra,80200dac <trap_handler>
    # csrr a1, sscratch
    # addi a2, zero, 0x666
    # call csr_change

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld t0, 248(sp)
    802000f8:	0f813283          	ld	t0,248(sp)
    csrw sepc, t0
    802000fc:	14129073          	csrw	sepc,t0
    ld x1, 0(sp)
    80200100:	00013083          	ld	ra,0(sp)
    
    ld x3, 16(sp)
    80200104:	01013183          	ld	gp,16(sp)
    ld x4, 24(sp)
    80200108:	01813203          	ld	tp,24(sp)
    ld x5, 32(sp)
    8020010c:	02013283          	ld	t0,32(sp)
    ld x6, 40(sp)
    80200110:	02813303          	ld	t1,40(sp)
    ld x7, 48(sp)
    80200114:	03013383          	ld	t2,48(sp)
    ld x8, 56(sp)
    80200118:	03813403          	ld	s0,56(sp)
    ld x9, 64(sp)
    8020011c:	04013483          	ld	s1,64(sp)
    ld x10, 72(sp)
    80200120:	04813503          	ld	a0,72(sp)
    ld x11, 80(sp)
    80200124:	05013583          	ld	a1,80(sp)
    ld x12, 88(sp)
    80200128:	05813603          	ld	a2,88(sp)
    ld x13, 96(sp)
    8020012c:	06013683          	ld	a3,96(sp)
    ld x14, 104(sp)
    80200130:	06813703          	ld	a4,104(sp)
    ld x15, 112(sp)
    80200134:	07013783          	ld	a5,112(sp)
    ld x16, 120(sp)
    80200138:	07813803          	ld	a6,120(sp)
    ld x17, 128(sp)
    8020013c:	08013883          	ld	a7,128(sp)
    ld x18, 136(sp)
    80200140:	08813903          	ld	s2,136(sp)
    ld x19, 144(sp)
    80200144:	09013983          	ld	s3,144(sp)
    ld x20, 152(sp)
    80200148:	09813a03          	ld	s4,152(sp)
    ld x21, 160(sp)
    8020014c:	0a013a83          	ld	s5,160(sp)
    ld x22, 168(sp)
    80200150:	0a813b03          	ld	s6,168(sp)
    ld x23, 176(sp)
    80200154:	0b013b83          	ld	s7,176(sp)
    ld x24, 184(sp)
    80200158:	0b813c03          	ld	s8,184(sp)
    ld x25, 192(sp)
    8020015c:	0c013c83          	ld	s9,192(sp)
    ld x26, 200(sp)
    80200160:	0c813d03          	ld	s10,200(sp)
    ld x27, 208(sp)
    80200164:	0d013d83          	ld	s11,208(sp)
    ld x28, 216(sp)
    80200168:	0d813e03          	ld	t3,216(sp)
    ld x29, 224(sp)
    8020016c:	0e013e83          	ld	t4,224(sp)
    ld x30, 232(sp)
    80200170:	0e813f03          	ld	t5,232(sp)
    ld x31, 240(sp)
    80200174:	0f013f83          	ld	t6,240(sp)
    ld x2, 8(sp)
    80200178:	00813103          	ld	sp,8(sp)
    addi sp, sp, 256
    8020017c:	10010113          	addi	sp,sp,256
    # 4. return from trap
    sret
    80200180:	10200073          	sret

0000000080200184 <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:
    la t0, dummy
    80200184:	00003297          	auipc	t0,0x3
    80200188:	ed42b283          	ld	t0,-300(t0) # 80203058 <_GLOBAL_OFFSET_TABLE_+0x20>
    csrw sepc, t0
    8020018c:	14129073          	csrw	sepc,t0
    sret
    80200190:	10200073          	sret

0000000080200194 <__switch_to>:
    .globl __switch_to
__switch_to:
    # save state to prev process
    # YOUR CODE HERE    
    #保存当前线程的 ra，sp，s0~s11 到当前线程的 thread_struct 中
    sd ra, 32(a0)
    80200194:	02153023          	sd	ra,32(a0)
    sd sp, 40(a0)
    80200198:	02253423          	sd	sp,40(a0)
    sd s0, 48(a0)
    8020019c:	02853823          	sd	s0,48(a0)
    sd s1, 56(a0)
    802001a0:	02953c23          	sd	s1,56(a0)
    sd s2, 64(a0)
    802001a4:	05253023          	sd	s2,64(a0)
    sd s3, 72(a0)
    802001a8:	05353423          	sd	s3,72(a0)
    sd s4, 80(a0)
    802001ac:	05453823          	sd	s4,80(a0)
    sd s5, 88(a0)
    802001b0:	05553c23          	sd	s5,88(a0)
    sd s6, 96(a0)
    802001b4:	07653023          	sd	s6,96(a0)
    sd s7, 104(a0)
    802001b8:	07753423          	sd	s7,104(a0)
    sd s8, 112(a0)
    802001bc:	07853823          	sd	s8,112(a0)
    sd s9, 120(a0)
    802001c0:	07953c23          	sd	s9,120(a0)
    sd s10, 128(a0)
    802001c4:	09a53023          	sd	s10,128(a0)
    sd s11, 136(a0)
    802001c8:	09b53423          	sd	s11,136(a0)

    ld ra, 32(a1)
    802001cc:	0205b083          	ld	ra,32(a1)
    ld sp, 40(a1)
    802001d0:	0285b103          	ld	sp,40(a1)
    ld s0, 48(a1)
    802001d4:	0305b403          	ld	s0,48(a1)
    ld s1, 56(a1)
    802001d8:	0385b483          	ld	s1,56(a1)
    ld s2, 64(a1)
    802001dc:	0405b903          	ld	s2,64(a1)
    ld s3, 72(a1)
    802001e0:	0485b983          	ld	s3,72(a1)
    ld s4, 80(a1)
    802001e4:	0505ba03          	ld	s4,80(a1)
    ld s5, 88(a1)
    802001e8:	0585ba83          	ld	s5,88(a1)
    ld s6, 96(a1)
    802001ec:	0605bb03          	ld	s6,96(a1)
    ld s7, 104(a1)
    802001f0:	0685bb83          	ld	s7,104(a1)
    ld s8, 112(a1)
    802001f4:	0705bc03          	ld	s8,112(a1)
    ld s9, 120(a1)
    802001f8:	0785bc83          	ld	s9,120(a1)
    ld s10, 128(a1)
    802001fc:	0805bd03          	ld	s10,128(a1)
    ld s11, 136(a1)
    80200200:	0885bd83          	ld	s11,136(a1)
    80200204:	00008067          	ret

0000000080200208 <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    80200208:	fe010113          	addi	sp,sp,-32
    8020020c:	00813c23          	sd	s0,24(sp)
    80200210:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    // #error Unimplemented
    uint64_t cycles;
    asm volatile("rdtime %0" : "=r"(cycles));
    80200214:	c01027f3          	rdtime	a5
    80200218:	fef43423          	sd	a5,-24(s0)
    return cycles;
    8020021c:	fe843783          	ld	a5,-24(s0)
}
    80200220:	00078513          	mv	a0,a5
    80200224:	01813403          	ld	s0,24(sp)
    80200228:	02010113          	addi	sp,sp,32
    8020022c:	00008067          	ret

0000000080200230 <clock_set_next_event>:

void clock_set_next_event() {
    80200230:	fe010113          	addi	sp,sp,-32
    80200234:	00113c23          	sd	ra,24(sp)
    80200238:	00813823          	sd	s0,16(sp)
    8020023c:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    80200240:	fc9ff0ef          	jal	ra,80200208 <get_cycles>
    80200244:	00050713          	mv	a4,a0
    80200248:	00003797          	auipc	a5,0x3
    8020024c:	db878793          	addi	a5,a5,-584 # 80203000 <TIMECLOCK>
    80200250:	0007b783          	ld	a5,0(a5)
    80200254:	00f707b3          	add	a5,a4,a5
    80200258:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    8020025c:	fe843503          	ld	a0,-24(s0)
    80200260:	2c1000ef          	jal	ra,80200d20 <sbi_set_timer>
    80200264:	00000013          	nop
    80200268:	01813083          	ld	ra,24(sp)
    8020026c:	01013403          	ld	s0,16(sp)
    80200270:	02010113          	addi	sp,sp,32
    80200274:	00008067          	ret

0000000080200278 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
    80200278:	fe010113          	addi	sp,sp,-32
    8020027c:	00113c23          	sd	ra,24(sp)
    80200280:	00813823          	sd	s0,16(sp)
    80200284:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
    80200288:	00005797          	auipc	a5,0x5
    8020028c:	d7878793          	addi	a5,a5,-648 # 80205000 <kmem>
    80200290:	0007b783          	ld	a5,0(a5)
    80200294:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
    80200298:	fe843783          	ld	a5,-24(s0)
    8020029c:	0007b703          	ld	a4,0(a5)
    802002a0:	00005797          	auipc	a5,0x5
    802002a4:	d6078793          	addi	a5,a5,-672 # 80205000 <kmem>
    802002a8:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
    802002ac:	00001637          	lui	a2,0x1
    802002b0:	00000593          	li	a1,0
    802002b4:	fe843503          	ld	a0,-24(s0)
    802002b8:	425010ef          	jal	ra,80201edc <memset>
    return (void *)r;
    802002bc:	fe843783          	ld	a5,-24(s0)
}
    802002c0:	00078513          	mv	a0,a5
    802002c4:	01813083          	ld	ra,24(sp)
    802002c8:	01013403          	ld	s0,16(sp)
    802002cc:	02010113          	addi	sp,sp,32
    802002d0:	00008067          	ret

00000000802002d4 <kfree>:

void kfree(void *addr) {
    802002d4:	fd010113          	addi	sp,sp,-48
    802002d8:	02113423          	sd	ra,40(sp)
    802002dc:	02813023          	sd	s0,32(sp)
    802002e0:	03010413          	addi	s0,sp,48
    802002e4:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
    802002e8:	fd843783          	ld	a5,-40(s0)
    802002ec:	00078693          	mv	a3,a5
    802002f0:	fd840793          	addi	a5,s0,-40
    802002f4:	fffff737          	lui	a4,0xfffff
    802002f8:	00e6f733          	and	a4,a3,a4
    802002fc:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
    80200300:	fd843783          	ld	a5,-40(s0)
    80200304:	00001637          	lui	a2,0x1
    80200308:	00000593          	li	a1,0
    8020030c:	00078513          	mv	a0,a5
    80200310:	3cd010ef          	jal	ra,80201edc <memset>

    r = (struct run *)addr;
    80200314:	fd843783          	ld	a5,-40(s0)
    80200318:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
    8020031c:	00005797          	auipc	a5,0x5
    80200320:	ce478793          	addi	a5,a5,-796 # 80205000 <kmem>
    80200324:	0007b703          	ld	a4,0(a5)
    80200328:	fe843783          	ld	a5,-24(s0)
    8020032c:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
    80200330:	00005797          	auipc	a5,0x5
    80200334:	cd078793          	addi	a5,a5,-816 # 80205000 <kmem>
    80200338:	fe843703          	ld	a4,-24(s0)
    8020033c:	00e7b023          	sd	a4,0(a5)

    return;
    80200340:	00000013          	nop
}
    80200344:	02813083          	ld	ra,40(sp)
    80200348:	02013403          	ld	s0,32(sp)
    8020034c:	03010113          	addi	sp,sp,48
    80200350:	00008067          	ret

0000000080200354 <kfreerange>:

void kfreerange(char *start, char *end) {
    80200354:	fd010113          	addi	sp,sp,-48
    80200358:	02113423          	sd	ra,40(sp)
    8020035c:	02813023          	sd	s0,32(sp)
    80200360:	03010413          	addi	s0,sp,48
    80200364:	fca43c23          	sd	a0,-40(s0)
    80200368:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
    8020036c:	fd843703          	ld	a4,-40(s0)
    80200370:	000017b7          	lui	a5,0x1
    80200374:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0x801ff001>
    80200378:	00f70733          	add	a4,a4,a5
    8020037c:	fffff7b7          	lui	a5,0xfffff
    80200380:	00f777b3          	and	a5,a4,a5
    80200384:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200388:	01c0006f          	j	802003a4 <kfreerange+0x50>
        kfree((void *)addr);
    8020038c:	fe843503          	ld	a0,-24(s0)
    80200390:	f45ff0ef          	jal	ra,802002d4 <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
    80200394:	fe843703          	ld	a4,-24(s0)
    80200398:	000017b7          	lui	a5,0x1
    8020039c:	00f707b3          	add	a5,a4,a5
    802003a0:	fef43423          	sd	a5,-24(s0)
    802003a4:	fe843703          	ld	a4,-24(s0)
    802003a8:	000017b7          	lui	a5,0x1
    802003ac:	00f70733          	add	a4,a4,a5
    802003b0:	fd043783          	ld	a5,-48(s0)
    802003b4:	fce7fce3          	bgeu	a5,a4,8020038c <kfreerange+0x38>
    }
}
    802003b8:	00000013          	nop
    802003bc:	00000013          	nop
    802003c0:	02813083          	ld	ra,40(sp)
    802003c4:	02013403          	ld	s0,32(sp)
    802003c8:	03010113          	addi	sp,sp,48
    802003cc:	00008067          	ret

00000000802003d0 <mm_init>:

void mm_init(void) {
    802003d0:	ff010113          	addi	sp,sp,-16
    802003d4:	00113423          	sd	ra,8(sp)
    802003d8:	00813023          	sd	s0,0(sp)
    802003dc:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)PHY_END);
    802003e0:	01100793          	li	a5,17
    802003e4:	01b79593          	slli	a1,a5,0x1b
    802003e8:	00003517          	auipc	a0,0x3
    802003ec:	c5853503          	ld	a0,-936(a0) # 80203040 <_GLOBAL_OFFSET_TABLE_+0x8>
    802003f0:	f65ff0ef          	jal	ra,80200354 <kfreerange>
    printk("...mm_init done!\n");
    802003f4:	00002517          	auipc	a0,0x2
    802003f8:	c0c50513          	addi	a0,a0,-1012 # 80202000 <_srodata>
    802003fc:	1c1010ef          	jal	ra,80201dbc <printk>
}
    80200400:	00000013          	nop
    80200404:	00813083          	ld	ra,8(sp)
    80200408:	00013403          	ld	s0,0(sp)
    8020040c:	01010113          	addi	sp,sp,16
    80200410:	00008067          	ret

0000000080200414 <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
    80200414:	fe010113          	addi	sp,sp,-32
    80200418:	00113c23          	sd	ra,24(sp)
    8020041c:	00813823          	sd	s0,16(sp)
    80200420:	02010413          	addi	s0,sp,32
    srand(2024);
    80200424:	7e800513          	li	a0,2024
    80200428:	215010ef          	jal	ra,80201e3c <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
    8020042c:	e4dff0ef          	jal	ra,80200278 <kalloc>
    80200430:	00050713          	mv	a4,a0
    80200434:	00005797          	auipc	a5,0x5
    80200438:	bd478793          	addi	a5,a5,-1068 # 80205008 <idle>
    8020043c:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
    80200440:	00005797          	auipc	a5,0x5
    80200444:	bc878793          	addi	a5,a5,-1080 # 80205008 <idle>
    80200448:	0007b783          	ld	a5,0(a5)
    8020044c:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
    80200450:	00005797          	auipc	a5,0x5
    80200454:	bb878793          	addi	a5,a5,-1096 # 80205008 <idle>
    80200458:	0007b783          	ld	a5,0(a5)
    8020045c:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
    80200460:	00005797          	auipc	a5,0x5
    80200464:	ba878793          	addi	a5,a5,-1112 # 80205008 <idle>
    80200468:	0007b783          	ld	a5,0(a5)
    8020046c:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
    80200470:	00005797          	auipc	a5,0x5
    80200474:	b9878793          	addi	a5,a5,-1128 # 80205008 <idle>
    80200478:	0007b783          	ld	a5,0(a5)
    8020047c:	0007bc23          	sd	zero,24(a5)

    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
    80200480:	00005797          	auipc	a5,0x5
    80200484:	b8878793          	addi	a5,a5,-1144 # 80205008 <idle>
    80200488:	0007b703          	ld	a4,0(a5)
    8020048c:	00005797          	auipc	a5,0x5
    80200490:	b8478793          	addi	a5,a5,-1148 # 80205010 <current>
    80200494:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
    80200498:	00005797          	auipc	a5,0x5
    8020049c:	b7078793          	addi	a5,a5,-1168 # 80205008 <idle>
    802004a0:	0007b703          	ld	a4,0(a5)
    802004a4:	00005797          	auipc	a5,0x5
    802004a8:	b7478793          	addi	a5,a5,-1164 # 80205018 <task>
    802004ac:	00e7b023          	sd	a4,0(a5)

    /* YOUR CODE HERE */

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    for (int i = 1; i < NR_TASKS; i++){
    802004b0:	00100793          	li	a5,1
    802004b4:	fef42623          	sw	a5,-20(s0)
    802004b8:	0940006f          	j	8020054c <task_init+0x138>
        struct task_struct *ptask = (struct task_struct*)kalloc();
    802004bc:	dbdff0ef          	jal	ra,80200278 <kalloc>
    802004c0:	fea43023          	sd	a0,-32(s0)
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
        ptask->state = TASK_RUNNING;
    802004c4:	fe043783          	ld	a5,-32(s0)
    802004c8:	0007b023          	sd	zero,0(a5)
        ptask->counter = 0;
    802004cc:	fe043783          	ld	a5,-32(s0)
    802004d0:	0007b423          	sd	zero,8(a5)
        ptask->priority = (uint64_t)rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
    802004d4:	1ad010ef          	jal	ra,80201e80 <rand>
    802004d8:	00050793          	mv	a5,a0
    802004dc:	00078713          	mv	a4,a5
    802004e0:	00a00793          	li	a5,10
    802004e4:	02f777b3          	remu	a5,a4,a5
    802004e8:	00178713          	addi	a4,a5,1
    802004ec:	fe043783          	ld	a5,-32(s0)
    802004f0:	00e7b823          	sd	a4,16(a5)
        // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址
        ptask->pid = i;
    802004f4:	fec42703          	lw	a4,-20(s0)
    802004f8:	fe043783          	ld	a5,-32(s0)
    802004fc:	00e7bc23          	sd	a4,24(a5)
        ptask->thread.ra = (uint64_t)__dummy;
    80200500:	00003717          	auipc	a4,0x3
    80200504:	b4873703          	ld	a4,-1208(a4) # 80203048 <_GLOBAL_OFFSET_TABLE_+0x10>
    80200508:	fe043783          	ld	a5,-32(s0)
    8020050c:	02e7b023          	sd	a4,32(a5)
        ptask->thread.sp = (uint64_t)ptask + PGSIZE;
    80200510:	fe043703          	ld	a4,-32(s0)
    80200514:	000017b7          	lui	a5,0x1
    80200518:	00f70733          	add	a4,a4,a5
    8020051c:	fe043783          	ld	a5,-32(s0)
    80200520:	02e7b423          	sd	a4,40(a5) # 1028 <_skernel-0x801fefd8>
        task[i] = ptask;
    80200524:	00005717          	auipc	a4,0x5
    80200528:	af470713          	addi	a4,a4,-1292 # 80205018 <task>
    8020052c:	fec42783          	lw	a5,-20(s0)
    80200530:	00379793          	slli	a5,a5,0x3
    80200534:	00f707b3          	add	a5,a4,a5
    80200538:	fe043703          	ld	a4,-32(s0)
    8020053c:	00e7b023          	sd	a4,0(a5)
    for (int i = 1; i < NR_TASKS; i++){
    80200540:	fec42783          	lw	a5,-20(s0)
    80200544:	0017879b          	addiw	a5,a5,1
    80200548:	fef42623          	sw	a5,-20(s0)
    8020054c:	fec42783          	lw	a5,-20(s0)
    80200550:	0007871b          	sext.w	a4,a5
    80200554:	00400793          	li	a5,4
    80200558:	f6e7d2e3          	bge	a5,a4,802004bc <task_init+0xa8>
    }
    /* YOUR CODE HERE */

    printk("...task_init done!\n");
    8020055c:	00002517          	auipc	a0,0x2
    80200560:	abc50513          	addi	a0,a0,-1348 # 80202018 <_srodata+0x18>
    80200564:	059010ef          	jal	ra,80201dbc <printk>
}
    80200568:	00000013          	nop
    8020056c:	01813083          	ld	ra,24(sp)
    80200570:	01013403          	ld	s0,16(sp)
    80200574:	02010113          	addi	sp,sp,32
    80200578:	00008067          	ret

000000008020057c <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
    8020057c:	fd010113          	addi	sp,sp,-48
    80200580:	02113423          	sd	ra,40(sp)
    80200584:	02813023          	sd	s0,32(sp)
    80200588:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
    8020058c:	3b9ad7b7          	lui	a5,0x3b9ad
    80200590:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0x448535f9>
    80200594:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
    80200598:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
    8020059c:	fff00793          	li	a5,-1
    802005a0:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    802005a4:	fe442783          	lw	a5,-28(s0)
    802005a8:	0007871b          	sext.w	a4,a5
    802005ac:	fff00793          	li	a5,-1
    802005b0:	00f70e63          	beq	a4,a5,802005cc <dummy+0x50>
    802005b4:	00005797          	auipc	a5,0x5
    802005b8:	a5c78793          	addi	a5,a5,-1444 # 80205010 <current>
    802005bc:	0007b783          	ld	a5,0(a5)
    802005c0:	0087b703          	ld	a4,8(a5)
    802005c4:	fe442783          	lw	a5,-28(s0)
    802005c8:	fcf70ee3          	beq	a4,a5,802005a4 <dummy+0x28>
    802005cc:	00005797          	auipc	a5,0x5
    802005d0:	a4478793          	addi	a5,a5,-1468 # 80205010 <current>
    802005d4:	0007b783          	ld	a5,0(a5)
    802005d8:	0087b783          	ld	a5,8(a5)
    802005dc:	fc0784e3          	beqz	a5,802005a4 <dummy+0x28>
            if (current->counter == 1) {
    802005e0:	00005797          	auipc	a5,0x5
    802005e4:	a3078793          	addi	a5,a5,-1488 # 80205010 <current>
    802005e8:	0007b783          	ld	a5,0(a5)
    802005ec:	0087b703          	ld	a4,8(a5)
    802005f0:	00100793          	li	a5,1
    802005f4:	00f71e63          	bne	a4,a5,80200610 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
    802005f8:	00005797          	auipc	a5,0x5
    802005fc:	a1878793          	addi	a5,a5,-1512 # 80205010 <current>
    80200600:	0007b783          	ld	a5,0(a5)
    80200604:	0087b703          	ld	a4,8(a5)
    80200608:	fff70713          	addi	a4,a4,-1
    8020060c:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
    80200610:	00005797          	auipc	a5,0x5
    80200614:	a0078793          	addi	a5,a5,-1536 # 80205010 <current>
    80200618:	0007b783          	ld	a5,0(a5)
    8020061c:	0087b783          	ld	a5,8(a5)
    80200620:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
    80200624:	fe843783          	ld	a5,-24(s0)
    80200628:	00178713          	addi	a4,a5,1
    8020062c:	fd843783          	ld	a5,-40(s0)
    80200630:	02f777b3          	remu	a5,a4,a5
    80200634:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
    80200638:	00005797          	auipc	a5,0x5
    8020063c:	9d878793          	addi	a5,a5,-1576 # 80205010 <current>
    80200640:	0007b783          	ld	a5,0(a5)
    80200644:	0187b783          	ld	a5,24(a5)
    80200648:	fe843603          	ld	a2,-24(s0)
    8020064c:	00078593          	mv	a1,a5
    80200650:	00002517          	auipc	a0,0x2
    80200654:	9e050513          	addi	a0,a0,-1568 # 80202030 <_srodata+0x30>
    80200658:	764010ef          	jal	ra,80201dbc <printk>
            #if TEST_SCHED
            tasks_output[tasks_output_index++] = current->pid + '0';
    8020065c:	00005797          	auipc	a5,0x5
    80200660:	9b478793          	addi	a5,a5,-1612 # 80205010 <current>
    80200664:	0007b783          	ld	a5,0(a5)
    80200668:	0187b783          	ld	a5,24(a5)
    8020066c:	0ff7f713          	zext.b	a4,a5
    80200670:	00005797          	auipc	a5,0x5
    80200674:	9f878793          	addi	a5,a5,-1544 # 80205068 <tasks_output_index>
    80200678:	0007a783          	lw	a5,0(a5)
    8020067c:	0017869b          	addiw	a3,a5,1
    80200680:	0006861b          	sext.w	a2,a3
    80200684:	00005697          	auipc	a3,0x5
    80200688:	9e468693          	addi	a3,a3,-1564 # 80205068 <tasks_output_index>
    8020068c:	00c6a023          	sw	a2,0(a3)
    80200690:	0307071b          	addiw	a4,a4,48
    80200694:	0ff77713          	zext.b	a4,a4
    80200698:	00005697          	auipc	a3,0x5
    8020069c:	9a868693          	addi	a3,a3,-1624 # 80205040 <tasks_output>
    802006a0:	00f687b3          	add	a5,a3,a5
    802006a4:	00e78023          	sb	a4,0(a5)
            if (tasks_output_index == MAX_OUTPUT) {
    802006a8:	00005797          	auipc	a5,0x5
    802006ac:	9c078793          	addi	a5,a5,-1600 # 80205068 <tasks_output_index>
    802006b0:	0007a783          	lw	a5,0(a5)
    802006b4:	00078713          	mv	a4,a5
    802006b8:	02800793          	li	a5,40
    802006bc:	eef714e3          	bne	a4,a5,802005a4 <dummy+0x28>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
    802006c0:	fe042023          	sw	zero,-32(s0)
    802006c4:	0800006f          	j	80200744 <dummy+0x1c8>
                    if (tasks_output[i] != expected_output[i]) {
    802006c8:	00005717          	auipc	a4,0x5
    802006cc:	97870713          	addi	a4,a4,-1672 # 80205040 <tasks_output>
    802006d0:	fe042783          	lw	a5,-32(s0)
    802006d4:	00f707b3          	add	a5,a4,a5
    802006d8:	0007c683          	lbu	a3,0(a5)
    802006dc:	00003717          	auipc	a4,0x3
    802006e0:	92c70713          	addi	a4,a4,-1748 # 80203008 <expected_output>
    802006e4:	fe042783          	lw	a5,-32(s0)
    802006e8:	00f707b3          	add	a5,a4,a5
    802006ec:	0007c783          	lbu	a5,0(a5)
    802006f0:	00068713          	mv	a4,a3
    802006f4:	04f70263          	beq	a4,a5,80200738 <dummy+0x1bc>
                        printk("\033[31mTest failed!\033[0m\n");
    802006f8:	00002517          	auipc	a0,0x2
    802006fc:	96850513          	addi	a0,a0,-1688 # 80202060 <_srodata+0x60>
    80200700:	6bc010ef          	jal	ra,80201dbc <printk>
                        printk("\033[31m    Expected: %s\033[0m\n", expected_output);
    80200704:	00003597          	auipc	a1,0x3
    80200708:	90458593          	addi	a1,a1,-1788 # 80203008 <expected_output>
    8020070c:	00002517          	auipc	a0,0x2
    80200710:	96c50513          	addi	a0,a0,-1684 # 80202078 <_srodata+0x78>
    80200714:	6a8010ef          	jal	ra,80201dbc <printk>
                        printk("\033[31m    Got:      %s\033[0m\n", tasks_output);
    80200718:	00005597          	auipc	a1,0x5
    8020071c:	92858593          	addi	a1,a1,-1752 # 80205040 <tasks_output>
    80200720:	00002517          	auipc	a0,0x2
    80200724:	97850513          	addi	a0,a0,-1672 # 80202098 <_srodata+0x98>
    80200728:	694010ef          	jal	ra,80201dbc <printk>
                        sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
    8020072c:	00000593          	li	a1,0
    80200730:	00000513          	li	a0,0
    80200734:	550000ef          	jal	ra,80200c84 <sbi_system_reset>
                for (int i = 0; i < MAX_OUTPUT; ++i) {
    80200738:	fe042783          	lw	a5,-32(s0)
    8020073c:	0017879b          	addiw	a5,a5,1
    80200740:	fef42023          	sw	a5,-32(s0)
    80200744:	fe042783          	lw	a5,-32(s0)
    80200748:	0007871b          	sext.w	a4,a5
    8020074c:	02700793          	li	a5,39
    80200750:	f6e7dce3          	bge	a5,a4,802006c8 <dummy+0x14c>
                    }
                }
                printk("\033[32mTest passed!\033[0m\n");
    80200754:	00002517          	auipc	a0,0x2
    80200758:	96450513          	addi	a0,a0,-1692 # 802020b8 <_srodata+0xb8>
    8020075c:	660010ef          	jal	ra,80201dbc <printk>
                printk("\033[32m    Output: %s\033[0m\n", expected_output);
    80200760:	00003597          	auipc	a1,0x3
    80200764:	8a858593          	addi	a1,a1,-1880 # 80203008 <expected_output>
    80200768:	00002517          	auipc	a0,0x2
    8020076c:	96850513          	addi	a0,a0,-1688 # 802020d0 <_srodata+0xd0>
    80200770:	64c010ef          	jal	ra,80201dbc <printk>
                sbi_system_reset(SBI_SRST_RESET_TYPE_SHUTDOWN, SBI_SRST_RESET_REASON_NONE);
    80200774:	00000593          	li	a1,0
    80200778:	00000513          	li	a0,0
    8020077c:	508000ef          	jal	ra,80200c84 <sbi_system_reset>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
    80200780:	e25ff06f          	j	802005a4 <dummy+0x28>

0000000080200784 <switch_to>:
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
    80200784:	fd010113          	addi	sp,sp,-48
    80200788:	02113423          	sd	ra,40(sp)
    8020078c:	02813023          	sd	s0,32(sp)
    80200790:	03010413          	addi	s0,sp,48
    80200794:	fca43c23          	sd	a0,-40(s0)
    if(current == next) {
    80200798:	00005797          	auipc	a5,0x5
    8020079c:	87878793          	addi	a5,a5,-1928 # 80205010 <current>
    802007a0:	0007b783          	ld	a5,0(a5)
    802007a4:	fd843703          	ld	a4,-40(s0)
    802007a8:	06f70c63          	beq	a4,a5,80200820 <switch_to+0x9c>
        return;
    }else{
        printk("switch_to: %d -> %d\n", current->pid, next->pid);
    802007ac:	00005797          	auipc	a5,0x5
    802007b0:	86478793          	addi	a5,a5,-1948 # 80205010 <current>
    802007b4:	0007b783          	ld	a5,0(a5)
    802007b8:	0187b703          	ld	a4,24(a5)
    802007bc:	fd843783          	ld	a5,-40(s0)
    802007c0:	0187b783          	ld	a5,24(a5)
    802007c4:	00078613          	mv	a2,a5
    802007c8:	00070593          	mv	a1,a4
    802007cc:	00002517          	auipc	a0,0x2
    802007d0:	92450513          	addi	a0,a0,-1756 # 802020f0 <_srodata+0xf0>
    802007d4:	5e8010ef          	jal	ra,80201dbc <printk>
        struct task_struct *prev = current;
    802007d8:	00005797          	auipc	a5,0x5
    802007dc:	83878793          	addi	a5,a5,-1992 # 80205010 <current>
    802007e0:	0007b783          	ld	a5,0(a5)
    802007e4:	fef43423          	sd	a5,-24(s0)
        current = next;
    802007e8:	00005797          	auipc	a5,0x5
    802007ec:	82878793          	addi	a5,a5,-2008 # 80205010 <current>
    802007f0:	fd843703          	ld	a4,-40(s0)
    802007f4:	00e7b023          	sd	a4,0(a5)
        printk("switch ing\n");
    802007f8:	00002517          	auipc	a0,0x2
    802007fc:	91050513          	addi	a0,a0,-1776 # 80202108 <_srodata+0x108>
    80200800:	5bc010ef          	jal	ra,80201dbc <printk>
        __switch_to(prev, next);
    80200804:	fd843583          	ld	a1,-40(s0)
    80200808:	fe843503          	ld	a0,-24(s0)
    8020080c:	989ff0ef          	jal	ra,80200194 <__switch_to>
        printk("switch done\n");
    80200810:	00002517          	auipc	a0,0x2
    80200814:	90850513          	addi	a0,a0,-1784 # 80202118 <_srodata+0x118>
    80200818:	5a4010ef          	jal	ra,80201dbc <printk>
    8020081c:	0080006f          	j	80200824 <switch_to+0xa0>
        return;
    80200820:	00000013          	nop
    }
}
    80200824:	02813083          	ld	ra,40(sp)
    80200828:	02013403          	ld	s0,32(sp)
    8020082c:	03010113          	addi	sp,sp,48
    80200830:	00008067          	ret

0000000080200834 <do_timer>:

void do_timer() {
    80200834:	ff010113          	addi	sp,sp,-16
    80200838:	00113423          	sd	ra,8(sp)
    8020083c:	00813023          	sd	s0,0(sp)
    80200840:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    printk("do_timer: current->pid = %d\n", current->pid);
    80200844:	00004797          	auipc	a5,0x4
    80200848:	7cc78793          	addi	a5,a5,1996 # 80205010 <current>
    8020084c:	0007b783          	ld	a5,0(a5)
    80200850:	0187b783          	ld	a5,24(a5)
    80200854:	00078593          	mv	a1,a5
    80200858:	00002517          	auipc	a0,0x2
    8020085c:	8d050513          	addi	a0,a0,-1840 # 80202128 <_srodata+0x128>
    80200860:	55c010ef          	jal	ra,80201dbc <printk>
    // YOUR CODE HERE
    if (current == idle || current->counter == 0) {
    80200864:	00004797          	auipc	a5,0x4
    80200868:	7ac78793          	addi	a5,a5,1964 # 80205010 <current>
    8020086c:	0007b703          	ld	a4,0(a5)
    80200870:	00004797          	auipc	a5,0x4
    80200874:	79878793          	addi	a5,a5,1944 # 80205008 <idle>
    80200878:	0007b783          	ld	a5,0(a5)
    8020087c:	00f70c63          	beq	a4,a5,80200894 <do_timer+0x60>
    80200880:	00004797          	auipc	a5,0x4
    80200884:	79078793          	addi	a5,a5,1936 # 80205010 <current>
    80200888:	0007b783          	ld	a5,0(a5)
    8020088c:	0087b783          	ld	a5,8(a5)
    80200890:	00079c63          	bnez	a5,802008a8 <do_timer+0x74>
        printk("do_timer: schedule\n");
    80200894:	00002517          	auipc	a0,0x2
    80200898:	8b450513          	addi	a0,a0,-1868 # 80202148 <_srodata+0x148>
    8020089c:	520010ef          	jal	ra,80201dbc <printk>
        schedule();
    802008a0:	058000ef          	jal	ra,802008f8 <schedule>
        if (current->counter == 0) {
            printk("do_timer: schedule2\n");
            schedule();
        }
    }
}
    802008a4:	0400006f          	j	802008e4 <do_timer+0xb0>
        current->counter --;
    802008a8:	00004797          	auipc	a5,0x4
    802008ac:	76878793          	addi	a5,a5,1896 # 80205010 <current>
    802008b0:	0007b783          	ld	a5,0(a5)
    802008b4:	0087b703          	ld	a4,8(a5)
    802008b8:	fff70713          	addi	a4,a4,-1
    802008bc:	00e7b423          	sd	a4,8(a5)
        if (current->counter == 0) {
    802008c0:	00004797          	auipc	a5,0x4
    802008c4:	75078793          	addi	a5,a5,1872 # 80205010 <current>
    802008c8:	0007b783          	ld	a5,0(a5)
    802008cc:	0087b783          	ld	a5,8(a5)
    802008d0:	00079a63          	bnez	a5,802008e4 <do_timer+0xb0>
            printk("do_timer: schedule2\n");
    802008d4:	00002517          	auipc	a0,0x2
    802008d8:	88c50513          	addi	a0,a0,-1908 # 80202160 <_srodata+0x160>
    802008dc:	4e0010ef          	jal	ra,80201dbc <printk>
            schedule();
    802008e0:	018000ef          	jal	ra,802008f8 <schedule>
}
    802008e4:	00000013          	nop
    802008e8:	00813083          	ld	ra,8(sp)
    802008ec:	00013403          	ld	s0,0(sp)
    802008f0:	01010113          	addi	sp,sp,16
    802008f4:	00008067          	ret

00000000802008f8 <schedule>:

void schedule() {
    802008f8:	fe010113          	addi	sp,sp,-32
    802008fc:	00113c23          	sd	ra,24(sp)
    80200900:	00813823          	sd	s0,16(sp)
    80200904:	02010413          	addi	s0,sp,32
    // YOUR CODE HERE
    int maxCounter = -1;
    80200908:	fff00793          	li	a5,-1
    8020090c:	fef42623          	sw	a5,-20(s0)
    int index = -1;
    80200910:	fff00793          	li	a5,-1
    80200914:	fef42423          	sw	a5,-24(s0)
    for (int i = 1; i < NR_TASKS; ++i) {
    80200918:	00100793          	li	a5,1
    8020091c:	fef42223          	sw	a5,-28(s0)
    80200920:	0dc0006f          	j	802009fc <schedule+0x104>
        printk("schedule: %d -> %d\n", task[i]->pid, task[i] -> counter);
    80200924:	00004717          	auipc	a4,0x4
    80200928:	6f470713          	addi	a4,a4,1780 # 80205018 <task>
    8020092c:	fe442783          	lw	a5,-28(s0)
    80200930:	00379793          	slli	a5,a5,0x3
    80200934:	00f707b3          	add	a5,a4,a5
    80200938:	0007b783          	ld	a5,0(a5)
    8020093c:	0187b683          	ld	a3,24(a5)
    80200940:	00004717          	auipc	a4,0x4
    80200944:	6d870713          	addi	a4,a4,1752 # 80205018 <task>
    80200948:	fe442783          	lw	a5,-28(s0)
    8020094c:	00379793          	slli	a5,a5,0x3
    80200950:	00f707b3          	add	a5,a4,a5
    80200954:	0007b783          	ld	a5,0(a5)
    80200958:	0087b783          	ld	a5,8(a5)
    8020095c:	00078613          	mv	a2,a5
    80200960:	00068593          	mv	a1,a3
    80200964:	00002517          	auipc	a0,0x2
    80200968:	81450513          	addi	a0,a0,-2028 # 80202178 <_srodata+0x178>
    8020096c:	450010ef          	jal	ra,80201dbc <printk>
        if (task[i]->state == TASK_RUNNING && (int)task[i]->counter > maxCounter) {
    80200970:	00004717          	auipc	a4,0x4
    80200974:	6a870713          	addi	a4,a4,1704 # 80205018 <task>
    80200978:	fe442783          	lw	a5,-28(s0)
    8020097c:	00379793          	slli	a5,a5,0x3
    80200980:	00f707b3          	add	a5,a4,a5
    80200984:	0007b783          	ld	a5,0(a5)
    80200988:	0007b783          	ld	a5,0(a5)
    8020098c:	06079263          	bnez	a5,802009f0 <schedule+0xf8>
    80200990:	00004717          	auipc	a4,0x4
    80200994:	68870713          	addi	a4,a4,1672 # 80205018 <task>
    80200998:	fe442783          	lw	a5,-28(s0)
    8020099c:	00379793          	slli	a5,a5,0x3
    802009a0:	00f707b3          	add	a5,a4,a5
    802009a4:	0007b783          	ld	a5,0(a5)
    802009a8:	0087b783          	ld	a5,8(a5)
    802009ac:	0007871b          	sext.w	a4,a5
    802009b0:	fec42783          	lw	a5,-20(s0)
    802009b4:	0007879b          	sext.w	a5,a5
    802009b8:	02e7dc63          	bge	a5,a4,802009f0 <schedule+0xf8>
            printk("mamba\n");
    802009bc:	00001517          	auipc	a0,0x1
    802009c0:	7d450513          	addi	a0,a0,2004 # 80202190 <_srodata+0x190>
    802009c4:	3f8010ef          	jal	ra,80201dbc <printk>
            maxCounter = task[i]->counter;
    802009c8:	00004717          	auipc	a4,0x4
    802009cc:	65070713          	addi	a4,a4,1616 # 80205018 <task>
    802009d0:	fe442783          	lw	a5,-28(s0)
    802009d4:	00379793          	slli	a5,a5,0x3
    802009d8:	00f707b3          	add	a5,a4,a5
    802009dc:	0007b783          	ld	a5,0(a5)
    802009e0:	0087b783          	ld	a5,8(a5)
    802009e4:	fef42623          	sw	a5,-20(s0)
            index = i;
    802009e8:	fe442783          	lw	a5,-28(s0)
    802009ec:	fef42423          	sw	a5,-24(s0)
    for (int i = 1; i < NR_TASKS; ++i) {
    802009f0:	fe442783          	lw	a5,-28(s0)
    802009f4:	0017879b          	addiw	a5,a5,1
    802009f8:	fef42223          	sw	a5,-28(s0)
    802009fc:	fe442783          	lw	a5,-28(s0)
    80200a00:	0007871b          	sext.w	a4,a5
    80200a04:	00400793          	li	a5,4
    80200a08:	f0e7dee3          	bge	a5,a4,80200924 <schedule+0x2c>
        }
    }

    if (maxCounter == 0) {
    80200a0c:	fec42783          	lw	a5,-20(s0)
    80200a10:	0007879b          	sext.w	a5,a5
    80200a14:	0c079c63          	bnez	a5,80200aec <schedule+0x1f4>
        for (int i = 1; i < NR_TASKS; ++i) {
    80200a18:	00100793          	li	a5,1
    80200a1c:	fef42023          	sw	a5,-32(s0)
    80200a20:	0b40006f          	j	80200ad4 <schedule+0x1dc>
            if (task[i]->state == TASK_RUNNING) {
    80200a24:	00004717          	auipc	a4,0x4
    80200a28:	5f470713          	addi	a4,a4,1524 # 80205018 <task>
    80200a2c:	fe042783          	lw	a5,-32(s0)
    80200a30:	00379793          	slli	a5,a5,0x3
    80200a34:	00f707b3          	add	a5,a4,a5
    80200a38:	0007b783          	ld	a5,0(a5)
    80200a3c:	0007b783          	ld	a5,0(a5)
    80200a40:	02079e63          	bnez	a5,80200a7c <schedule+0x184>
                task[i]->counter = task[i]->priority;
    80200a44:	00004717          	auipc	a4,0x4
    80200a48:	5d470713          	addi	a4,a4,1492 # 80205018 <task>
    80200a4c:	fe042783          	lw	a5,-32(s0)
    80200a50:	00379793          	slli	a5,a5,0x3
    80200a54:	00f707b3          	add	a5,a4,a5
    80200a58:	0007b703          	ld	a4,0(a5)
    80200a5c:	00004697          	auipc	a3,0x4
    80200a60:	5bc68693          	addi	a3,a3,1468 # 80205018 <task>
    80200a64:	fe042783          	lw	a5,-32(s0)
    80200a68:	00379793          	slli	a5,a5,0x3
    80200a6c:	00f687b3          	add	a5,a3,a5
    80200a70:	0007b783          	ld	a5,0(a5)
    80200a74:	01073703          	ld	a4,16(a4)
    80200a78:	00e7b423          	sd	a4,8(a5)
            }
            printk("schedule2: %d -> %d\n", task[i]->pid, task[i] -> counter);
    80200a7c:	00004717          	auipc	a4,0x4
    80200a80:	59c70713          	addi	a4,a4,1436 # 80205018 <task>
    80200a84:	fe042783          	lw	a5,-32(s0)
    80200a88:	00379793          	slli	a5,a5,0x3
    80200a8c:	00f707b3          	add	a5,a4,a5
    80200a90:	0007b783          	ld	a5,0(a5)
    80200a94:	0187b683          	ld	a3,24(a5)
    80200a98:	00004717          	auipc	a4,0x4
    80200a9c:	58070713          	addi	a4,a4,1408 # 80205018 <task>
    80200aa0:	fe042783          	lw	a5,-32(s0)
    80200aa4:	00379793          	slli	a5,a5,0x3
    80200aa8:	00f707b3          	add	a5,a4,a5
    80200aac:	0007b783          	ld	a5,0(a5)
    80200ab0:	0087b783          	ld	a5,8(a5)
    80200ab4:	00078613          	mv	a2,a5
    80200ab8:	00068593          	mv	a1,a3
    80200abc:	00001517          	auipc	a0,0x1
    80200ac0:	6dc50513          	addi	a0,a0,1756 # 80202198 <_srodata+0x198>
    80200ac4:	2f8010ef          	jal	ra,80201dbc <printk>
        for (int i = 1; i < NR_TASKS; ++i) {
    80200ac8:	fe042783          	lw	a5,-32(s0)
    80200acc:	0017879b          	addiw	a5,a5,1
    80200ad0:	fef42023          	sw	a5,-32(s0)
    80200ad4:	fe042783          	lw	a5,-32(s0)
    80200ad8:	0007871b          	sext.w	a4,a5
    80200adc:	00400793          	li	a5,4
    80200ae0:	f4e7d2e3          	bge	a5,a4,80200a24 <schedule+0x12c>
        }
        schedule();
    80200ae4:	e15ff0ef          	jal	ra,802008f8 <schedule>
    } else {
        switch_to(task[index]);
    }
    80200ae8:	0240006f          	j	80200b0c <schedule+0x214>
        switch_to(task[index]);
    80200aec:	00004717          	auipc	a4,0x4
    80200af0:	52c70713          	addi	a4,a4,1324 # 80205018 <task>
    80200af4:	fe842783          	lw	a5,-24(s0)
    80200af8:	00379793          	slli	a5,a5,0x3
    80200afc:	00f707b3          	add	a5,a4,a5
    80200b00:	0007b783          	ld	a5,0(a5)
    80200b04:	00078513          	mv	a0,a5
    80200b08:	c7dff0ef          	jal	ra,80200784 <switch_to>
    80200b0c:	00000013          	nop
    80200b10:	01813083          	ld	ra,24(sp)
    80200b14:	01013403          	ld	s0,16(sp)
    80200b18:	02010113          	addi	sp,sp,32
    80200b1c:	00008067          	ret

0000000080200b20 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    80200b20:	f8010113          	addi	sp,sp,-128
    80200b24:	06813c23          	sd	s0,120(sp)
    80200b28:	06913823          	sd	s1,112(sp)
    80200b2c:	07213423          	sd	s2,104(sp)
    80200b30:	07313023          	sd	s3,96(sp)
    80200b34:	08010413          	addi	s0,sp,128
    80200b38:	faa43c23          	sd	a0,-72(s0)
    80200b3c:	fab43823          	sd	a1,-80(s0)
    80200b40:	fac43423          	sd	a2,-88(s0)
    80200b44:	fad43023          	sd	a3,-96(s0)
    80200b48:	f8e43c23          	sd	a4,-104(s0)
    80200b4c:	f8f43823          	sd	a5,-112(s0)
    80200b50:	f9043423          	sd	a6,-120(s0)
    80200b54:	f9143023          	sd	a7,-128(s0)
    
    struct sbiret sbiRet;

    asm volatile (
    80200b58:	fb843e03          	ld	t3,-72(s0)
    80200b5c:	fb043e83          	ld	t4,-80(s0)
    80200b60:	fa843f03          	ld	t5,-88(s0)
    80200b64:	fa043f83          	ld	t6,-96(s0)
    80200b68:	f9843283          	ld	t0,-104(s0)
    80200b6c:	f9043483          	ld	s1,-112(s0)
    80200b70:	f8843903          	ld	s2,-120(s0)
    80200b74:	f8043983          	ld	s3,-128(s0)
    80200b78:	01c008b3          	add	a7,zero,t3
    80200b7c:	01d00833          	add	a6,zero,t4
    80200b80:	01e00533          	add	a0,zero,t5
    80200b84:	01f005b3          	add	a1,zero,t6
    80200b88:	00500633          	add	a2,zero,t0
    80200b8c:	009006b3          	add	a3,zero,s1
    80200b90:	01200733          	add	a4,zero,s2
    80200b94:	013007b3          	add	a5,zero,s3
    80200b98:	00000073          	ecall
    80200b9c:	00050e93          	mv	t4,a0
    80200ba0:	00058e13          	mv	t3,a1
    80200ba4:	fdd43023          	sd	t4,-64(s0)
    80200ba8:	fdc43423          	sd	t3,-56(s0)
        : "=r"(sbiRet.error), "=r"(sbiRet.value)
        : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );

    return sbiRet;
    80200bac:	fc043783          	ld	a5,-64(s0)
    80200bb0:	fcf43823          	sd	a5,-48(s0)
    80200bb4:	fc843783          	ld	a5,-56(s0)
    80200bb8:	fcf43c23          	sd	a5,-40(s0)
    80200bbc:	fd043703          	ld	a4,-48(s0)
    80200bc0:	fd843783          	ld	a5,-40(s0)
    80200bc4:	00070313          	mv	t1,a4
    80200bc8:	00078393          	mv	t2,a5
    80200bcc:	00030713          	mv	a4,t1
    80200bd0:	00038793          	mv	a5,t2
}
    80200bd4:	00070513          	mv	a0,a4
    80200bd8:	00078593          	mv	a1,a5
    80200bdc:	07813403          	ld	s0,120(sp)
    80200be0:	07013483          	ld	s1,112(sp)
    80200be4:	06813903          	ld	s2,104(sp)
    80200be8:	06013983          	ld	s3,96(sp)
    80200bec:	08010113          	addi	sp,sp,128
    80200bf0:	00008067          	ret

0000000080200bf4 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    80200bf4:	fc010113          	addi	sp,sp,-64
    80200bf8:	02113c23          	sd	ra,56(sp)
    80200bfc:	02813823          	sd	s0,48(sp)
    80200c00:	03213423          	sd	s2,40(sp)
    80200c04:	03313023          	sd	s3,32(sp)
    80200c08:	04010413          	addi	s0,sp,64
    80200c0c:	00050793          	mv	a5,a0
    80200c10:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
    80200c14:	fcf44603          	lbu	a2,-49(s0)
    80200c18:	00000893          	li	a7,0
    80200c1c:	00000813          	li	a6,0
    80200c20:	00000793          	li	a5,0
    80200c24:	00000713          	li	a4,0
    80200c28:	00000693          	li	a3,0
    80200c2c:	00200593          	li	a1,2
    80200c30:	44424537          	lui	a0,0x44424
    80200c34:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200c38:	ee9ff0ef          	jal	ra,80200b20 <sbi_ecall>
    80200c3c:	00050713          	mv	a4,a0
    80200c40:	00058793          	mv	a5,a1
    80200c44:	fce43823          	sd	a4,-48(s0)
    80200c48:	fcf43c23          	sd	a5,-40(s0)
    80200c4c:	fd043703          	ld	a4,-48(s0)
    80200c50:	fd843783          	ld	a5,-40(s0)
    80200c54:	00070913          	mv	s2,a4
    80200c58:	00078993          	mv	s3,a5
    80200c5c:	00090713          	mv	a4,s2
    80200c60:	00098793          	mv	a5,s3
}
    80200c64:	00070513          	mv	a0,a4
    80200c68:	00078593          	mv	a1,a5
    80200c6c:	03813083          	ld	ra,56(sp)
    80200c70:	03013403          	ld	s0,48(sp)
    80200c74:	02813903          	ld	s2,40(sp)
    80200c78:	02013983          	ld	s3,32(sp)
    80200c7c:	04010113          	addi	sp,sp,64
    80200c80:	00008067          	ret

0000000080200c84 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200c84:	fc010113          	addi	sp,sp,-64
    80200c88:	02113c23          	sd	ra,56(sp)
    80200c8c:	02813823          	sd	s0,48(sp)
    80200c90:	03213423          	sd	s2,40(sp)
    80200c94:	03313023          	sd	s3,32(sp)
    80200c98:	04010413          	addi	s0,sp,64
    80200c9c:	00050793          	mv	a5,a0
    80200ca0:	00058713          	mv	a4,a1
    80200ca4:	fcf42623          	sw	a5,-52(s0)
    80200ca8:	00070793          	mv	a5,a4
    80200cac:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
    80200cb0:	fcc46603          	lwu	a2,-52(s0)
    80200cb4:	fc846683          	lwu	a3,-56(s0)
    80200cb8:	00000893          	li	a7,0
    80200cbc:	00000813          	li	a6,0
    80200cc0:	00000793          	li	a5,0
    80200cc4:	00000713          	li	a4,0
    80200cc8:	00000593          	li	a1,0
    80200ccc:	53525537          	lui	a0,0x53525
    80200cd0:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    80200cd4:	e4dff0ef          	jal	ra,80200b20 <sbi_ecall>
    80200cd8:	00050713          	mv	a4,a0
    80200cdc:	00058793          	mv	a5,a1
    80200ce0:	fce43823          	sd	a4,-48(s0)
    80200ce4:	fcf43c23          	sd	a5,-40(s0)
    80200ce8:	fd043703          	ld	a4,-48(s0)
    80200cec:	fd843783          	ld	a5,-40(s0)
    80200cf0:	00070913          	mv	s2,a4
    80200cf4:	00078993          	mv	s3,a5
    80200cf8:	00090713          	mv	a4,s2
    80200cfc:	00098793          	mv	a5,s3
}
    80200d00:	00070513          	mv	a0,a4
    80200d04:	00078593          	mv	a1,a5
    80200d08:	03813083          	ld	ra,56(sp)
    80200d0c:	03013403          	ld	s0,48(sp)
    80200d10:	02813903          	ld	s2,40(sp)
    80200d14:	02013983          	ld	s3,32(sp)
    80200d18:	04010113          	addi	sp,sp,64
    80200d1c:	00008067          	ret

0000000080200d20 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
    80200d20:	fc010113          	addi	sp,sp,-64
    80200d24:	02113c23          	sd	ra,56(sp)
    80200d28:	02813823          	sd	s0,48(sp)
    80200d2c:	03213423          	sd	s2,40(sp)
    80200d30:	03313023          	sd	s3,32(sp)
    80200d34:	04010413          	addi	s0,sp,64
    80200d38:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
    80200d3c:	00000893          	li	a7,0
    80200d40:	00000813          	li	a6,0
    80200d44:	00000793          	li	a5,0
    80200d48:	00000713          	li	a4,0
    80200d4c:	00000693          	li	a3,0
    80200d50:	fc843603          	ld	a2,-56(s0)
    80200d54:	00000593          	li	a1,0
    80200d58:	54495537          	lui	a0,0x54495
    80200d5c:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    80200d60:	dc1ff0ef          	jal	ra,80200b20 <sbi_ecall>
    80200d64:	00050713          	mv	a4,a0
    80200d68:	00058793          	mv	a5,a1
    80200d6c:	fce43823          	sd	a4,-48(s0)
    80200d70:	fcf43c23          	sd	a5,-40(s0)
    80200d74:	fd043703          	ld	a4,-48(s0)
    80200d78:	fd843783          	ld	a5,-40(s0)
    80200d7c:	00070913          	mv	s2,a4
    80200d80:	00078993          	mv	s3,a5
    80200d84:	00090713          	mv	a4,s2
    80200d88:	00098793          	mv	a5,s3
    80200d8c:	00070513          	mv	a0,a4
    80200d90:	00078593          	mv	a1,a5
    80200d94:	03813083          	ld	ra,56(sp)
    80200d98:	03013403          	ld	s0,48(sp)
    80200d9c:	02813903          	ld	s2,40(sp)
    80200da0:	02013983          	ld	s3,32(sp)
    80200da4:	04010113          	addi	sp,sp,64
    80200da8:	00008067          	ret

0000000080200dac <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "defs.h"
#include "proc.h"
void trap_handler(uint64_t scause, uint64_t sepc) {
    80200dac:	fe010113          	addi	sp,sp,-32
    80200db0:	00113c23          	sd	ra,24(sp)
    80200db4:	00813823          	sd	s0,16(sp)
    80200db8:	02010413          	addi	s0,sp,32
    80200dbc:	fea43423          	sd	a0,-24(s0)
    80200dc0:	feb43023          	sd	a1,-32(s0)
    // 通过 `scause` 判断 trap 类型
    if(scause == 0x8000000000000005){
    80200dc4:	fe843703          	ld	a4,-24(s0)
    80200dc8:	fff00793          	li	a5,-1
    80200dcc:	03f79793          	slli	a5,a5,0x3f
    80200dd0:	00578793          	addi	a5,a5,5
    80200dd4:	00f71c63          	bne	a4,a5,80200dec <trap_handler+0x40>
        printk("timer interrupt\n");
    80200dd8:	00001517          	auipc	a0,0x1
    80200ddc:	3d850513          	addi	a0,a0,984 # 802021b0 <_srodata+0x1b0>
    80200de0:	7dd000ef          	jal	ra,80201dbc <printk>
        clock_set_next_event();
    80200de4:	c4cff0ef          	jal	ra,80200230 <clock_set_next_event>
        do_timer();
    80200de8:	a4dff0ef          	jal	ra,80200834 <do_timer>
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
    // printk((scause & 0x8000000000000000) > 0 ? "Interrupt: " : "Exception: ");
    // printk("scause: 0x%lx\n", scause);
    // printk("sepc: 0x%lx\n", sepc);

}
    80200dec:	00000013          	nop
    80200df0:	01813083          	ld	ra,24(sp)
    80200df4:	01013403          	ld	s0,16(sp)
    80200df8:	02010113          	addi	sp,sp,32
    80200dfc:	00008067          	ret

0000000080200e00 <csr_change>:

void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
    80200e00:	fb010113          	addi	sp,sp,-80
    80200e04:	04113423          	sd	ra,72(sp)
    80200e08:	04813023          	sd	s0,64(sp)
    80200e0c:	05010413          	addi	s0,sp,80
    80200e10:	fca43423          	sd	a0,-56(s0)
    80200e14:	fcb43023          	sd	a1,-64(s0)
    80200e18:	fac43c23          	sd	a2,-72(s0)
    printk("sscratch: 0x%lx\n", csr_read(sscratch));
    80200e1c:	140027f3          	csrr	a5,sscratch
    80200e20:	fef43423          	sd	a5,-24(s0)
    80200e24:	fe843783          	ld	a5,-24(s0)
    80200e28:	00078593          	mv	a1,a5
    80200e2c:	00001517          	auipc	a0,0x1
    80200e30:	39c50513          	addi	a0,a0,924 # 802021c8 <_srodata+0x1c8>
    80200e34:	789000ef          	jal	ra,80201dbc <printk>
    csr_write(sscratch, value);
    80200e38:	fb843783          	ld	a5,-72(s0)
    80200e3c:	fef43023          	sd	a5,-32(s0)
    80200e40:	fe043783          	ld	a5,-32(s0)
    80200e44:	14079073          	csrw	sscratch,a5
    printk("sstatus: 0x%lx\n", csr_read(sstatus));
    80200e48:	100027f3          	csrr	a5,sstatus
    80200e4c:	fcf43c23          	sd	a5,-40(s0)
    80200e50:	fd843783          	ld	a5,-40(s0)
    80200e54:	00078593          	mv	a1,a5
    80200e58:	00001517          	auipc	a0,0x1
    80200e5c:	38850513          	addi	a0,a0,904 # 802021e0 <_srodata+0x1e0>
    80200e60:	75d000ef          	jal	ra,80201dbc <printk>
    printk("sscratch: 0x%lx\n", csr_read(sscratch));
    80200e64:	140027f3          	csrr	a5,sscratch
    80200e68:	fcf43823          	sd	a5,-48(s0)
    80200e6c:	fd043783          	ld	a5,-48(s0)
    80200e70:	00078593          	mv	a1,a5
    80200e74:	00001517          	auipc	a0,0x1
    80200e78:	35450513          	addi	a0,a0,852 # 802021c8 <_srodata+0x1c8>
    80200e7c:	741000ef          	jal	ra,80201dbc <printk>
    80200e80:	00000013          	nop
    80200e84:	04813083          	ld	ra,72(sp)
    80200e88:	04013403          	ld	s0,64(sp)
    80200e8c:	05010113          	addi	sp,sp,80
    80200e90:	00008067          	ret

0000000080200e94 <start_kernel>:
#include "printk.h"

extern void test();

int start_kernel() {
    80200e94:	ff010113          	addi	sp,sp,-16
    80200e98:	00113423          	sd	ra,8(sp)
    80200e9c:	00813023          	sd	s0,0(sp)
    80200ea0:	01010413          	addi	s0,sp,16
    printk("2024");
    80200ea4:	00001517          	auipc	a0,0x1
    80200ea8:	34c50513          	addi	a0,a0,844 # 802021f0 <_srodata+0x1f0>
    80200eac:	711000ef          	jal	ra,80201dbc <printk>
    printk(" ZJU Operating System\n");
    80200eb0:	00001517          	auipc	a0,0x1
    80200eb4:	34850513          	addi	a0,a0,840 # 802021f8 <_srodata+0x1f8>
    80200eb8:	705000ef          	jal	ra,80201dbc <printk>

    test();
    80200ebc:	01c000ef          	jal	ra,80200ed8 <test>
    return 0;
    80200ec0:	00000793          	li	a5,0
}
    80200ec4:	00078513          	mv	a0,a5
    80200ec8:	00813083          	ld	ra,8(sp)
    80200ecc:	00013403          	ld	s0,0(sp)
    80200ed0:	01010113          	addi	sp,sp,16
    80200ed4:	00008067          	ret

0000000080200ed8 <test>:
#include "printk.h"

void test() {
    80200ed8:	fe010113          	addi	sp,sp,-32
    80200edc:	00113c23          	sd	ra,24(sp)
    80200ee0:	00813823          	sd	s0,16(sp)
    80200ee4:	02010413          	addi	s0,sp,32
    int i = 0;
    80200ee8:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    80200eec:	fec42783          	lw	a5,-20(s0)
    80200ef0:	0017879b          	addiw	a5,a5,1
    80200ef4:	fef42623          	sw	a5,-20(s0)
    80200ef8:	fec42783          	lw	a5,-20(s0)
    80200efc:	00078713          	mv	a4,a5
    80200f00:	05f5e7b7          	lui	a5,0x5f5e
    80200f04:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    80200f08:	02f767bb          	remw	a5,a4,a5
    80200f0c:	0007879b          	sext.w	a5,a5
    80200f10:	fc079ee3          	bnez	a5,80200eec <test+0x14>
            printk("kernel is running!\n");
    80200f14:	00001517          	auipc	a0,0x1
    80200f18:	2fc50513          	addi	a0,a0,764 # 80202210 <_srodata+0x210>
    80200f1c:	6a1000ef          	jal	ra,80201dbc <printk>
            i = 0;
    80200f20:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    80200f24:	fc9ff06f          	j	80200eec <test+0x14>

0000000080200f28 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200f28:	fe010113          	addi	sp,sp,-32
    80200f2c:	00113c23          	sd	ra,24(sp)
    80200f30:	00813823          	sd	s0,16(sp)
    80200f34:	02010413          	addi	s0,sp,32
    80200f38:	00050793          	mv	a5,a0
    80200f3c:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    80200f40:	fec42783          	lw	a5,-20(s0)
    80200f44:	0ff7f793          	zext.b	a5,a5
    80200f48:	00078513          	mv	a0,a5
    80200f4c:	ca9ff0ef          	jal	ra,80200bf4 <sbi_debug_console_write_byte>
    return (char)c;
    80200f50:	fec42783          	lw	a5,-20(s0)
    80200f54:	0ff7f793          	zext.b	a5,a5
    80200f58:	0007879b          	sext.w	a5,a5
}
    80200f5c:	00078513          	mv	a0,a5
    80200f60:	01813083          	ld	ra,24(sp)
    80200f64:	01013403          	ld	s0,16(sp)
    80200f68:	02010113          	addi	sp,sp,32
    80200f6c:	00008067          	ret

0000000080200f70 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    80200f70:	fe010113          	addi	sp,sp,-32
    80200f74:	00813c23          	sd	s0,24(sp)
    80200f78:	02010413          	addi	s0,sp,32
    80200f7c:	00050793          	mv	a5,a0
    80200f80:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    80200f84:	fec42783          	lw	a5,-20(s0)
    80200f88:	0007871b          	sext.w	a4,a5
    80200f8c:	02000793          	li	a5,32
    80200f90:	02f70263          	beq	a4,a5,80200fb4 <isspace+0x44>
    80200f94:	fec42783          	lw	a5,-20(s0)
    80200f98:	0007871b          	sext.w	a4,a5
    80200f9c:	00800793          	li	a5,8
    80200fa0:	00e7de63          	bge	a5,a4,80200fbc <isspace+0x4c>
    80200fa4:	fec42783          	lw	a5,-20(s0)
    80200fa8:	0007871b          	sext.w	a4,a5
    80200fac:	00d00793          	li	a5,13
    80200fb0:	00e7c663          	blt	a5,a4,80200fbc <isspace+0x4c>
    80200fb4:	00100793          	li	a5,1
    80200fb8:	0080006f          	j	80200fc0 <isspace+0x50>
    80200fbc:	00000793          	li	a5,0
}
    80200fc0:	00078513          	mv	a0,a5
    80200fc4:	01813403          	ld	s0,24(sp)
    80200fc8:	02010113          	addi	sp,sp,32
    80200fcc:	00008067          	ret

0000000080200fd0 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    80200fd0:	fb010113          	addi	sp,sp,-80
    80200fd4:	04113423          	sd	ra,72(sp)
    80200fd8:	04813023          	sd	s0,64(sp)
    80200fdc:	05010413          	addi	s0,sp,80
    80200fe0:	fca43423          	sd	a0,-56(s0)
    80200fe4:	fcb43023          	sd	a1,-64(s0)
    80200fe8:	00060793          	mv	a5,a2
    80200fec:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    80200ff0:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200ff4:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200ff8:	fc843783          	ld	a5,-56(s0)
    80200ffc:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    80201000:	0100006f          	j	80201010 <strtol+0x40>
        p++;
    80201004:	fd843783          	ld	a5,-40(s0)
    80201008:	00178793          	addi	a5,a5,1
    8020100c:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    80201010:	fd843783          	ld	a5,-40(s0)
    80201014:	0007c783          	lbu	a5,0(a5)
    80201018:	0007879b          	sext.w	a5,a5
    8020101c:	00078513          	mv	a0,a5
    80201020:	f51ff0ef          	jal	ra,80200f70 <isspace>
    80201024:	00050793          	mv	a5,a0
    80201028:	fc079ee3          	bnez	a5,80201004 <strtol+0x34>
    }

    if (*p == '-') {
    8020102c:	fd843783          	ld	a5,-40(s0)
    80201030:	0007c783          	lbu	a5,0(a5)
    80201034:	00078713          	mv	a4,a5
    80201038:	02d00793          	li	a5,45
    8020103c:	00f71e63          	bne	a4,a5,80201058 <strtol+0x88>
        neg = true;
    80201040:	00100793          	li	a5,1
    80201044:	fef403a3          	sb	a5,-25(s0)
        p++;
    80201048:	fd843783          	ld	a5,-40(s0)
    8020104c:	00178793          	addi	a5,a5,1
    80201050:	fcf43c23          	sd	a5,-40(s0)
    80201054:	0240006f          	j	80201078 <strtol+0xa8>
    } else if (*p == '+') {
    80201058:	fd843783          	ld	a5,-40(s0)
    8020105c:	0007c783          	lbu	a5,0(a5)
    80201060:	00078713          	mv	a4,a5
    80201064:	02b00793          	li	a5,43
    80201068:	00f71863          	bne	a4,a5,80201078 <strtol+0xa8>
        p++;
    8020106c:	fd843783          	ld	a5,-40(s0)
    80201070:	00178793          	addi	a5,a5,1
    80201074:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80201078:	fbc42783          	lw	a5,-68(s0)
    8020107c:	0007879b          	sext.w	a5,a5
    80201080:	06079c63          	bnez	a5,802010f8 <strtol+0x128>
        if (*p == '0') {
    80201084:	fd843783          	ld	a5,-40(s0)
    80201088:	0007c783          	lbu	a5,0(a5)
    8020108c:	00078713          	mv	a4,a5
    80201090:	03000793          	li	a5,48
    80201094:	04f71e63          	bne	a4,a5,802010f0 <strtol+0x120>
            p++;
    80201098:	fd843783          	ld	a5,-40(s0)
    8020109c:	00178793          	addi	a5,a5,1
    802010a0:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    802010a4:	fd843783          	ld	a5,-40(s0)
    802010a8:	0007c783          	lbu	a5,0(a5)
    802010ac:	00078713          	mv	a4,a5
    802010b0:	07800793          	li	a5,120
    802010b4:	00f70c63          	beq	a4,a5,802010cc <strtol+0xfc>
    802010b8:	fd843783          	ld	a5,-40(s0)
    802010bc:	0007c783          	lbu	a5,0(a5)
    802010c0:	00078713          	mv	a4,a5
    802010c4:	05800793          	li	a5,88
    802010c8:	00f71e63          	bne	a4,a5,802010e4 <strtol+0x114>
                base = 16;
    802010cc:	01000793          	li	a5,16
    802010d0:	faf42e23          	sw	a5,-68(s0)
                p++;
    802010d4:	fd843783          	ld	a5,-40(s0)
    802010d8:	00178793          	addi	a5,a5,1
    802010dc:	fcf43c23          	sd	a5,-40(s0)
    802010e0:	0180006f          	j	802010f8 <strtol+0x128>
            } else {
                base = 8;
    802010e4:	00800793          	li	a5,8
    802010e8:	faf42e23          	sw	a5,-68(s0)
    802010ec:	00c0006f          	j	802010f8 <strtol+0x128>
            }
        } else {
            base = 10;
    802010f0:	00a00793          	li	a5,10
    802010f4:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    802010f8:	fd843783          	ld	a5,-40(s0)
    802010fc:	0007c783          	lbu	a5,0(a5)
    80201100:	00078713          	mv	a4,a5
    80201104:	02f00793          	li	a5,47
    80201108:	02e7f863          	bgeu	a5,a4,80201138 <strtol+0x168>
    8020110c:	fd843783          	ld	a5,-40(s0)
    80201110:	0007c783          	lbu	a5,0(a5)
    80201114:	00078713          	mv	a4,a5
    80201118:	03900793          	li	a5,57
    8020111c:	00e7ee63          	bltu	a5,a4,80201138 <strtol+0x168>
            digit = *p - '0';
    80201120:	fd843783          	ld	a5,-40(s0)
    80201124:	0007c783          	lbu	a5,0(a5)
    80201128:	0007879b          	sext.w	a5,a5
    8020112c:	fd07879b          	addiw	a5,a5,-48
    80201130:	fcf42a23          	sw	a5,-44(s0)
    80201134:	0800006f          	j	802011b4 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80201138:	fd843783          	ld	a5,-40(s0)
    8020113c:	0007c783          	lbu	a5,0(a5)
    80201140:	00078713          	mv	a4,a5
    80201144:	06000793          	li	a5,96
    80201148:	02e7f863          	bgeu	a5,a4,80201178 <strtol+0x1a8>
    8020114c:	fd843783          	ld	a5,-40(s0)
    80201150:	0007c783          	lbu	a5,0(a5)
    80201154:	00078713          	mv	a4,a5
    80201158:	07a00793          	li	a5,122
    8020115c:	00e7ee63          	bltu	a5,a4,80201178 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    80201160:	fd843783          	ld	a5,-40(s0)
    80201164:	0007c783          	lbu	a5,0(a5)
    80201168:	0007879b          	sext.w	a5,a5
    8020116c:	fa97879b          	addiw	a5,a5,-87
    80201170:	fcf42a23          	sw	a5,-44(s0)
    80201174:	0400006f          	j	802011b4 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80201178:	fd843783          	ld	a5,-40(s0)
    8020117c:	0007c783          	lbu	a5,0(a5)
    80201180:	00078713          	mv	a4,a5
    80201184:	04000793          	li	a5,64
    80201188:	06e7f863          	bgeu	a5,a4,802011f8 <strtol+0x228>
    8020118c:	fd843783          	ld	a5,-40(s0)
    80201190:	0007c783          	lbu	a5,0(a5)
    80201194:	00078713          	mv	a4,a5
    80201198:	05a00793          	li	a5,90
    8020119c:	04e7ee63          	bltu	a5,a4,802011f8 <strtol+0x228>
            digit = *p - ('A' - 10);
    802011a0:	fd843783          	ld	a5,-40(s0)
    802011a4:	0007c783          	lbu	a5,0(a5)
    802011a8:	0007879b          	sext.w	a5,a5
    802011ac:	fc97879b          	addiw	a5,a5,-55
    802011b0:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    802011b4:	fd442783          	lw	a5,-44(s0)
    802011b8:	00078713          	mv	a4,a5
    802011bc:	fbc42783          	lw	a5,-68(s0)
    802011c0:	0007071b          	sext.w	a4,a4
    802011c4:	0007879b          	sext.w	a5,a5
    802011c8:	02f75663          	bge	a4,a5,802011f4 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    802011cc:	fbc42703          	lw	a4,-68(s0)
    802011d0:	fe843783          	ld	a5,-24(s0)
    802011d4:	02f70733          	mul	a4,a4,a5
    802011d8:	fd442783          	lw	a5,-44(s0)
    802011dc:	00f707b3          	add	a5,a4,a5
    802011e0:	fef43423          	sd	a5,-24(s0)
        p++;
    802011e4:	fd843783          	ld	a5,-40(s0)
    802011e8:	00178793          	addi	a5,a5,1
    802011ec:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    802011f0:	f09ff06f          	j	802010f8 <strtol+0x128>
            break;
    802011f4:	00000013          	nop
    }

    if (endptr) {
    802011f8:	fc043783          	ld	a5,-64(s0)
    802011fc:	00078863          	beqz	a5,8020120c <strtol+0x23c>
        *endptr = (char *)p;
    80201200:	fc043783          	ld	a5,-64(s0)
    80201204:	fd843703          	ld	a4,-40(s0)
    80201208:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    8020120c:	fe744783          	lbu	a5,-25(s0)
    80201210:	0ff7f793          	zext.b	a5,a5
    80201214:	00078863          	beqz	a5,80201224 <strtol+0x254>
    80201218:	fe843783          	ld	a5,-24(s0)
    8020121c:	40f007b3          	neg	a5,a5
    80201220:	0080006f          	j	80201228 <strtol+0x258>
    80201224:	fe843783          	ld	a5,-24(s0)
}
    80201228:	00078513          	mv	a0,a5
    8020122c:	04813083          	ld	ra,72(sp)
    80201230:	04013403          	ld	s0,64(sp)
    80201234:	05010113          	addi	sp,sp,80
    80201238:	00008067          	ret

000000008020123c <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    8020123c:	fd010113          	addi	sp,sp,-48
    80201240:	02113423          	sd	ra,40(sp)
    80201244:	02813023          	sd	s0,32(sp)
    80201248:	03010413          	addi	s0,sp,48
    8020124c:	fca43c23          	sd	a0,-40(s0)
    80201250:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80201254:	fd043783          	ld	a5,-48(s0)
    80201258:	00079863          	bnez	a5,80201268 <puts_wo_nl+0x2c>
        s = "(null)";
    8020125c:	00001797          	auipc	a5,0x1
    80201260:	fcc78793          	addi	a5,a5,-52 # 80202228 <_srodata+0x228>
    80201264:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80201268:	fd043783          	ld	a5,-48(s0)
    8020126c:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    80201270:	0240006f          	j	80201294 <puts_wo_nl+0x58>
        putch(*p++);
    80201274:	fe843783          	ld	a5,-24(s0)
    80201278:	00178713          	addi	a4,a5,1
    8020127c:	fee43423          	sd	a4,-24(s0)
    80201280:	0007c783          	lbu	a5,0(a5)
    80201284:	0007871b          	sext.w	a4,a5
    80201288:	fd843783          	ld	a5,-40(s0)
    8020128c:	00070513          	mv	a0,a4
    80201290:	000780e7          	jalr	a5
    while (*p) {
    80201294:	fe843783          	ld	a5,-24(s0)
    80201298:	0007c783          	lbu	a5,0(a5)
    8020129c:	fc079ce3          	bnez	a5,80201274 <puts_wo_nl+0x38>
    }
    return p - s;
    802012a0:	fe843703          	ld	a4,-24(s0)
    802012a4:	fd043783          	ld	a5,-48(s0)
    802012a8:	40f707b3          	sub	a5,a4,a5
    802012ac:	0007879b          	sext.w	a5,a5
}
    802012b0:	00078513          	mv	a0,a5
    802012b4:	02813083          	ld	ra,40(sp)
    802012b8:	02013403          	ld	s0,32(sp)
    802012bc:	03010113          	addi	sp,sp,48
    802012c0:	00008067          	ret

00000000802012c4 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    802012c4:	f9010113          	addi	sp,sp,-112
    802012c8:	06113423          	sd	ra,104(sp)
    802012cc:	06813023          	sd	s0,96(sp)
    802012d0:	07010413          	addi	s0,sp,112
    802012d4:	faa43423          	sd	a0,-88(s0)
    802012d8:	fab43023          	sd	a1,-96(s0)
    802012dc:	00060793          	mv	a5,a2
    802012e0:	f8d43823          	sd	a3,-112(s0)
    802012e4:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    802012e8:	f9f44783          	lbu	a5,-97(s0)
    802012ec:	0ff7f793          	zext.b	a5,a5
    802012f0:	02078663          	beqz	a5,8020131c <print_dec_int+0x58>
    802012f4:	fa043703          	ld	a4,-96(s0)
    802012f8:	fff00793          	li	a5,-1
    802012fc:	03f79793          	slli	a5,a5,0x3f
    80201300:	00f71e63          	bne	a4,a5,8020131c <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    80201304:	00001597          	auipc	a1,0x1
    80201308:	f2c58593          	addi	a1,a1,-212 # 80202230 <_srodata+0x230>
    8020130c:	fa843503          	ld	a0,-88(s0)
    80201310:	f2dff0ef          	jal	ra,8020123c <puts_wo_nl>
    80201314:	00050793          	mv	a5,a0
    80201318:	2a00006f          	j	802015b8 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    8020131c:	f9043783          	ld	a5,-112(s0)
    80201320:	00c7a783          	lw	a5,12(a5)
    80201324:	00079a63          	bnez	a5,80201338 <print_dec_int+0x74>
    80201328:	fa043783          	ld	a5,-96(s0)
    8020132c:	00079663          	bnez	a5,80201338 <print_dec_int+0x74>
        return 0;
    80201330:	00000793          	li	a5,0
    80201334:	2840006f          	j	802015b8 <print_dec_int+0x2f4>
    }

    bool neg = false;
    80201338:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    8020133c:	f9f44783          	lbu	a5,-97(s0)
    80201340:	0ff7f793          	zext.b	a5,a5
    80201344:	02078063          	beqz	a5,80201364 <print_dec_int+0xa0>
    80201348:	fa043783          	ld	a5,-96(s0)
    8020134c:	0007dc63          	bgez	a5,80201364 <print_dec_int+0xa0>
        neg = true;
    80201350:	00100793          	li	a5,1
    80201354:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80201358:	fa043783          	ld	a5,-96(s0)
    8020135c:	40f007b3          	neg	a5,a5
    80201360:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80201364:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80201368:	f9f44783          	lbu	a5,-97(s0)
    8020136c:	0ff7f793          	zext.b	a5,a5
    80201370:	02078863          	beqz	a5,802013a0 <print_dec_int+0xdc>
    80201374:	fef44783          	lbu	a5,-17(s0)
    80201378:	0ff7f793          	zext.b	a5,a5
    8020137c:	00079e63          	bnez	a5,80201398 <print_dec_int+0xd4>
    80201380:	f9043783          	ld	a5,-112(s0)
    80201384:	0057c783          	lbu	a5,5(a5)
    80201388:	00079863          	bnez	a5,80201398 <print_dec_int+0xd4>
    8020138c:	f9043783          	ld	a5,-112(s0)
    80201390:	0047c783          	lbu	a5,4(a5)
    80201394:	00078663          	beqz	a5,802013a0 <print_dec_int+0xdc>
    80201398:	00100793          	li	a5,1
    8020139c:	0080006f          	j	802013a4 <print_dec_int+0xe0>
    802013a0:	00000793          	li	a5,0
    802013a4:	fcf40ba3          	sb	a5,-41(s0)
    802013a8:	fd744783          	lbu	a5,-41(s0)
    802013ac:	0017f793          	andi	a5,a5,1
    802013b0:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    802013b4:	fa043703          	ld	a4,-96(s0)
    802013b8:	00a00793          	li	a5,10
    802013bc:	02f777b3          	remu	a5,a4,a5
    802013c0:	0ff7f713          	zext.b	a4,a5
    802013c4:	fe842783          	lw	a5,-24(s0)
    802013c8:	0017869b          	addiw	a3,a5,1
    802013cc:	fed42423          	sw	a3,-24(s0)
    802013d0:	0307071b          	addiw	a4,a4,48
    802013d4:	0ff77713          	zext.b	a4,a4
    802013d8:	ff078793          	addi	a5,a5,-16
    802013dc:	008787b3          	add	a5,a5,s0
    802013e0:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    802013e4:	fa043703          	ld	a4,-96(s0)
    802013e8:	00a00793          	li	a5,10
    802013ec:	02f757b3          	divu	a5,a4,a5
    802013f0:	faf43023          	sd	a5,-96(s0)
    } while (num);
    802013f4:	fa043783          	ld	a5,-96(s0)
    802013f8:	fa079ee3          	bnez	a5,802013b4 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    802013fc:	f9043783          	ld	a5,-112(s0)
    80201400:	00c7a783          	lw	a5,12(a5)
    80201404:	00078713          	mv	a4,a5
    80201408:	fff00793          	li	a5,-1
    8020140c:	02f71063          	bne	a4,a5,8020142c <print_dec_int+0x168>
    80201410:	f9043783          	ld	a5,-112(s0)
    80201414:	0037c783          	lbu	a5,3(a5)
    80201418:	00078a63          	beqz	a5,8020142c <print_dec_int+0x168>
        flags->prec = flags->width;
    8020141c:	f9043783          	ld	a5,-112(s0)
    80201420:	0087a703          	lw	a4,8(a5)
    80201424:	f9043783          	ld	a5,-112(s0)
    80201428:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    8020142c:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80201430:	f9043783          	ld	a5,-112(s0)
    80201434:	0087a703          	lw	a4,8(a5)
    80201438:	fe842783          	lw	a5,-24(s0)
    8020143c:	fcf42823          	sw	a5,-48(s0)
    80201440:	f9043783          	ld	a5,-112(s0)
    80201444:	00c7a783          	lw	a5,12(a5)
    80201448:	fcf42623          	sw	a5,-52(s0)
    8020144c:	fd042783          	lw	a5,-48(s0)
    80201450:	00078593          	mv	a1,a5
    80201454:	fcc42783          	lw	a5,-52(s0)
    80201458:	00078613          	mv	a2,a5
    8020145c:	0006069b          	sext.w	a3,a2
    80201460:	0005879b          	sext.w	a5,a1
    80201464:	00f6d463          	bge	a3,a5,8020146c <print_dec_int+0x1a8>
    80201468:	00058613          	mv	a2,a1
    8020146c:	0006079b          	sext.w	a5,a2
    80201470:	40f707bb          	subw	a5,a4,a5
    80201474:	0007871b          	sext.w	a4,a5
    80201478:	fd744783          	lbu	a5,-41(s0)
    8020147c:	0007879b          	sext.w	a5,a5
    80201480:	40f707bb          	subw	a5,a4,a5
    80201484:	fef42023          	sw	a5,-32(s0)
    80201488:	0280006f          	j	802014b0 <print_dec_int+0x1ec>
        putch(' ');
    8020148c:	fa843783          	ld	a5,-88(s0)
    80201490:	02000513          	li	a0,32
    80201494:	000780e7          	jalr	a5
        ++written;
    80201498:	fe442783          	lw	a5,-28(s0)
    8020149c:	0017879b          	addiw	a5,a5,1
    802014a0:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    802014a4:	fe042783          	lw	a5,-32(s0)
    802014a8:	fff7879b          	addiw	a5,a5,-1
    802014ac:	fef42023          	sw	a5,-32(s0)
    802014b0:	fe042783          	lw	a5,-32(s0)
    802014b4:	0007879b          	sext.w	a5,a5
    802014b8:	fcf04ae3          	bgtz	a5,8020148c <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    802014bc:	fd744783          	lbu	a5,-41(s0)
    802014c0:	0ff7f793          	zext.b	a5,a5
    802014c4:	04078463          	beqz	a5,8020150c <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    802014c8:	fef44783          	lbu	a5,-17(s0)
    802014cc:	0ff7f793          	zext.b	a5,a5
    802014d0:	00078663          	beqz	a5,802014dc <print_dec_int+0x218>
    802014d4:	02d00793          	li	a5,45
    802014d8:	01c0006f          	j	802014f4 <print_dec_int+0x230>
    802014dc:	f9043783          	ld	a5,-112(s0)
    802014e0:	0057c783          	lbu	a5,5(a5)
    802014e4:	00078663          	beqz	a5,802014f0 <print_dec_int+0x22c>
    802014e8:	02b00793          	li	a5,43
    802014ec:	0080006f          	j	802014f4 <print_dec_int+0x230>
    802014f0:	02000793          	li	a5,32
    802014f4:	fa843703          	ld	a4,-88(s0)
    802014f8:	00078513          	mv	a0,a5
    802014fc:	000700e7          	jalr	a4
        ++written;
    80201500:	fe442783          	lw	a5,-28(s0)
    80201504:	0017879b          	addiw	a5,a5,1
    80201508:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    8020150c:	fe842783          	lw	a5,-24(s0)
    80201510:	fcf42e23          	sw	a5,-36(s0)
    80201514:	0280006f          	j	8020153c <print_dec_int+0x278>
        putch('0');
    80201518:	fa843783          	ld	a5,-88(s0)
    8020151c:	03000513          	li	a0,48
    80201520:	000780e7          	jalr	a5
        ++written;
    80201524:	fe442783          	lw	a5,-28(s0)
    80201528:	0017879b          	addiw	a5,a5,1
    8020152c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80201530:	fdc42783          	lw	a5,-36(s0)
    80201534:	0017879b          	addiw	a5,a5,1
    80201538:	fcf42e23          	sw	a5,-36(s0)
    8020153c:	f9043783          	ld	a5,-112(s0)
    80201540:	00c7a703          	lw	a4,12(a5)
    80201544:	fd744783          	lbu	a5,-41(s0)
    80201548:	0007879b          	sext.w	a5,a5
    8020154c:	40f707bb          	subw	a5,a4,a5
    80201550:	0007871b          	sext.w	a4,a5
    80201554:	fdc42783          	lw	a5,-36(s0)
    80201558:	0007879b          	sext.w	a5,a5
    8020155c:	fae7cee3          	blt	a5,a4,80201518 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80201560:	fe842783          	lw	a5,-24(s0)
    80201564:	fff7879b          	addiw	a5,a5,-1
    80201568:	fcf42c23          	sw	a5,-40(s0)
    8020156c:	03c0006f          	j	802015a8 <print_dec_int+0x2e4>
        putch(buf[i]);
    80201570:	fd842783          	lw	a5,-40(s0)
    80201574:	ff078793          	addi	a5,a5,-16
    80201578:	008787b3          	add	a5,a5,s0
    8020157c:	fc87c783          	lbu	a5,-56(a5)
    80201580:	0007871b          	sext.w	a4,a5
    80201584:	fa843783          	ld	a5,-88(s0)
    80201588:	00070513          	mv	a0,a4
    8020158c:	000780e7          	jalr	a5
        ++written;
    80201590:	fe442783          	lw	a5,-28(s0)
    80201594:	0017879b          	addiw	a5,a5,1
    80201598:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    8020159c:	fd842783          	lw	a5,-40(s0)
    802015a0:	fff7879b          	addiw	a5,a5,-1
    802015a4:	fcf42c23          	sw	a5,-40(s0)
    802015a8:	fd842783          	lw	a5,-40(s0)
    802015ac:	0007879b          	sext.w	a5,a5
    802015b0:	fc07d0e3          	bgez	a5,80201570 <print_dec_int+0x2ac>
    }

    return written;
    802015b4:	fe442783          	lw	a5,-28(s0)
}
    802015b8:	00078513          	mv	a0,a5
    802015bc:	06813083          	ld	ra,104(sp)
    802015c0:	06013403          	ld	s0,96(sp)
    802015c4:	07010113          	addi	sp,sp,112
    802015c8:	00008067          	ret

00000000802015cc <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    802015cc:	f4010113          	addi	sp,sp,-192
    802015d0:	0a113c23          	sd	ra,184(sp)
    802015d4:	0a813823          	sd	s0,176(sp)
    802015d8:	0c010413          	addi	s0,sp,192
    802015dc:	f4a43c23          	sd	a0,-168(s0)
    802015e0:	f4b43823          	sd	a1,-176(s0)
    802015e4:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    802015e8:	f8043023          	sd	zero,-128(s0)
    802015ec:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    802015f0:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    802015f4:	7a40006f          	j	80201d98 <vprintfmt+0x7cc>
        if (flags.in_format) {
    802015f8:	f8044783          	lbu	a5,-128(s0)
    802015fc:	72078e63          	beqz	a5,80201d38 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80201600:	f5043783          	ld	a5,-176(s0)
    80201604:	0007c783          	lbu	a5,0(a5)
    80201608:	00078713          	mv	a4,a5
    8020160c:	02300793          	li	a5,35
    80201610:	00f71863          	bne	a4,a5,80201620 <vprintfmt+0x54>
                flags.sharpflag = true;
    80201614:	00100793          	li	a5,1
    80201618:	f8f40123          	sb	a5,-126(s0)
    8020161c:	7700006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80201620:	f5043783          	ld	a5,-176(s0)
    80201624:	0007c783          	lbu	a5,0(a5)
    80201628:	00078713          	mv	a4,a5
    8020162c:	03000793          	li	a5,48
    80201630:	00f71863          	bne	a4,a5,80201640 <vprintfmt+0x74>
                flags.zeroflag = true;
    80201634:	00100793          	li	a5,1
    80201638:	f8f401a3          	sb	a5,-125(s0)
    8020163c:	7500006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80201640:	f5043783          	ld	a5,-176(s0)
    80201644:	0007c783          	lbu	a5,0(a5)
    80201648:	00078713          	mv	a4,a5
    8020164c:	06c00793          	li	a5,108
    80201650:	04f70063          	beq	a4,a5,80201690 <vprintfmt+0xc4>
    80201654:	f5043783          	ld	a5,-176(s0)
    80201658:	0007c783          	lbu	a5,0(a5)
    8020165c:	00078713          	mv	a4,a5
    80201660:	07a00793          	li	a5,122
    80201664:	02f70663          	beq	a4,a5,80201690 <vprintfmt+0xc4>
    80201668:	f5043783          	ld	a5,-176(s0)
    8020166c:	0007c783          	lbu	a5,0(a5)
    80201670:	00078713          	mv	a4,a5
    80201674:	07400793          	li	a5,116
    80201678:	00f70c63          	beq	a4,a5,80201690 <vprintfmt+0xc4>
    8020167c:	f5043783          	ld	a5,-176(s0)
    80201680:	0007c783          	lbu	a5,0(a5)
    80201684:	00078713          	mv	a4,a5
    80201688:	06a00793          	li	a5,106
    8020168c:	00f71863          	bne	a4,a5,8020169c <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80201690:	00100793          	li	a5,1
    80201694:	f8f400a3          	sb	a5,-127(s0)
    80201698:	6f40006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    8020169c:	f5043783          	ld	a5,-176(s0)
    802016a0:	0007c783          	lbu	a5,0(a5)
    802016a4:	00078713          	mv	a4,a5
    802016a8:	02b00793          	li	a5,43
    802016ac:	00f71863          	bne	a4,a5,802016bc <vprintfmt+0xf0>
                flags.sign = true;
    802016b0:	00100793          	li	a5,1
    802016b4:	f8f402a3          	sb	a5,-123(s0)
    802016b8:	6d40006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    802016bc:	f5043783          	ld	a5,-176(s0)
    802016c0:	0007c783          	lbu	a5,0(a5)
    802016c4:	00078713          	mv	a4,a5
    802016c8:	02000793          	li	a5,32
    802016cc:	00f71863          	bne	a4,a5,802016dc <vprintfmt+0x110>
                flags.spaceflag = true;
    802016d0:	00100793          	li	a5,1
    802016d4:	f8f40223          	sb	a5,-124(s0)
    802016d8:	6b40006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    802016dc:	f5043783          	ld	a5,-176(s0)
    802016e0:	0007c783          	lbu	a5,0(a5)
    802016e4:	00078713          	mv	a4,a5
    802016e8:	02a00793          	li	a5,42
    802016ec:	00f71e63          	bne	a4,a5,80201708 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    802016f0:	f4843783          	ld	a5,-184(s0)
    802016f4:	00878713          	addi	a4,a5,8
    802016f8:	f4e43423          	sd	a4,-184(s0)
    802016fc:	0007a783          	lw	a5,0(a5)
    80201700:	f8f42423          	sw	a5,-120(s0)
    80201704:	6880006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80201708:	f5043783          	ld	a5,-176(s0)
    8020170c:	0007c783          	lbu	a5,0(a5)
    80201710:	00078713          	mv	a4,a5
    80201714:	03000793          	li	a5,48
    80201718:	04e7f663          	bgeu	a5,a4,80201764 <vprintfmt+0x198>
    8020171c:	f5043783          	ld	a5,-176(s0)
    80201720:	0007c783          	lbu	a5,0(a5)
    80201724:	00078713          	mv	a4,a5
    80201728:	03900793          	li	a5,57
    8020172c:	02e7ec63          	bltu	a5,a4,80201764 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80201730:	f5043783          	ld	a5,-176(s0)
    80201734:	f5040713          	addi	a4,s0,-176
    80201738:	00a00613          	li	a2,10
    8020173c:	00070593          	mv	a1,a4
    80201740:	00078513          	mv	a0,a5
    80201744:	88dff0ef          	jal	ra,80200fd0 <strtol>
    80201748:	00050793          	mv	a5,a0
    8020174c:	0007879b          	sext.w	a5,a5
    80201750:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80201754:	f5043783          	ld	a5,-176(s0)
    80201758:	fff78793          	addi	a5,a5,-1
    8020175c:	f4f43823          	sd	a5,-176(s0)
    80201760:	62c0006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80201764:	f5043783          	ld	a5,-176(s0)
    80201768:	0007c783          	lbu	a5,0(a5)
    8020176c:	00078713          	mv	a4,a5
    80201770:	02e00793          	li	a5,46
    80201774:	06f71863          	bne	a4,a5,802017e4 <vprintfmt+0x218>
                fmt++;
    80201778:	f5043783          	ld	a5,-176(s0)
    8020177c:	00178793          	addi	a5,a5,1
    80201780:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80201784:	f5043783          	ld	a5,-176(s0)
    80201788:	0007c783          	lbu	a5,0(a5)
    8020178c:	00078713          	mv	a4,a5
    80201790:	02a00793          	li	a5,42
    80201794:	00f71e63          	bne	a4,a5,802017b0 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80201798:	f4843783          	ld	a5,-184(s0)
    8020179c:	00878713          	addi	a4,a5,8
    802017a0:	f4e43423          	sd	a4,-184(s0)
    802017a4:	0007a783          	lw	a5,0(a5)
    802017a8:	f8f42623          	sw	a5,-116(s0)
    802017ac:	5e00006f          	j	80201d8c <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    802017b0:	f5043783          	ld	a5,-176(s0)
    802017b4:	f5040713          	addi	a4,s0,-176
    802017b8:	00a00613          	li	a2,10
    802017bc:	00070593          	mv	a1,a4
    802017c0:	00078513          	mv	a0,a5
    802017c4:	80dff0ef          	jal	ra,80200fd0 <strtol>
    802017c8:	00050793          	mv	a5,a0
    802017cc:	0007879b          	sext.w	a5,a5
    802017d0:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    802017d4:	f5043783          	ld	a5,-176(s0)
    802017d8:	fff78793          	addi	a5,a5,-1
    802017dc:	f4f43823          	sd	a5,-176(s0)
    802017e0:	5ac0006f          	j	80201d8c <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    802017e4:	f5043783          	ld	a5,-176(s0)
    802017e8:	0007c783          	lbu	a5,0(a5)
    802017ec:	00078713          	mv	a4,a5
    802017f0:	07800793          	li	a5,120
    802017f4:	02f70663          	beq	a4,a5,80201820 <vprintfmt+0x254>
    802017f8:	f5043783          	ld	a5,-176(s0)
    802017fc:	0007c783          	lbu	a5,0(a5)
    80201800:	00078713          	mv	a4,a5
    80201804:	05800793          	li	a5,88
    80201808:	00f70c63          	beq	a4,a5,80201820 <vprintfmt+0x254>
    8020180c:	f5043783          	ld	a5,-176(s0)
    80201810:	0007c783          	lbu	a5,0(a5)
    80201814:	00078713          	mv	a4,a5
    80201818:	07000793          	li	a5,112
    8020181c:	30f71263          	bne	a4,a5,80201b20 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80201820:	f5043783          	ld	a5,-176(s0)
    80201824:	0007c783          	lbu	a5,0(a5)
    80201828:	00078713          	mv	a4,a5
    8020182c:	07000793          	li	a5,112
    80201830:	00f70663          	beq	a4,a5,8020183c <vprintfmt+0x270>
    80201834:	f8144783          	lbu	a5,-127(s0)
    80201838:	00078663          	beqz	a5,80201844 <vprintfmt+0x278>
    8020183c:	00100793          	li	a5,1
    80201840:	0080006f          	j	80201848 <vprintfmt+0x27c>
    80201844:	00000793          	li	a5,0
    80201848:	faf403a3          	sb	a5,-89(s0)
    8020184c:	fa744783          	lbu	a5,-89(s0)
    80201850:	0017f793          	andi	a5,a5,1
    80201854:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80201858:	fa744783          	lbu	a5,-89(s0)
    8020185c:	0ff7f793          	zext.b	a5,a5
    80201860:	00078c63          	beqz	a5,80201878 <vprintfmt+0x2ac>
    80201864:	f4843783          	ld	a5,-184(s0)
    80201868:	00878713          	addi	a4,a5,8
    8020186c:	f4e43423          	sd	a4,-184(s0)
    80201870:	0007b783          	ld	a5,0(a5)
    80201874:	01c0006f          	j	80201890 <vprintfmt+0x2c4>
    80201878:	f4843783          	ld	a5,-184(s0)
    8020187c:	00878713          	addi	a4,a5,8
    80201880:	f4e43423          	sd	a4,-184(s0)
    80201884:	0007a783          	lw	a5,0(a5)
    80201888:	02079793          	slli	a5,a5,0x20
    8020188c:	0207d793          	srli	a5,a5,0x20
    80201890:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80201894:	f8c42783          	lw	a5,-116(s0)
    80201898:	02079463          	bnez	a5,802018c0 <vprintfmt+0x2f4>
    8020189c:	fe043783          	ld	a5,-32(s0)
    802018a0:	02079063          	bnez	a5,802018c0 <vprintfmt+0x2f4>
    802018a4:	f5043783          	ld	a5,-176(s0)
    802018a8:	0007c783          	lbu	a5,0(a5)
    802018ac:	00078713          	mv	a4,a5
    802018b0:	07000793          	li	a5,112
    802018b4:	00f70663          	beq	a4,a5,802018c0 <vprintfmt+0x2f4>
                    flags.in_format = false;
    802018b8:	f8040023          	sb	zero,-128(s0)
    802018bc:	4d00006f          	j	80201d8c <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    802018c0:	f5043783          	ld	a5,-176(s0)
    802018c4:	0007c783          	lbu	a5,0(a5)
    802018c8:	00078713          	mv	a4,a5
    802018cc:	07000793          	li	a5,112
    802018d0:	00f70a63          	beq	a4,a5,802018e4 <vprintfmt+0x318>
    802018d4:	f8244783          	lbu	a5,-126(s0)
    802018d8:	00078a63          	beqz	a5,802018ec <vprintfmt+0x320>
    802018dc:	fe043783          	ld	a5,-32(s0)
    802018e0:	00078663          	beqz	a5,802018ec <vprintfmt+0x320>
    802018e4:	00100793          	li	a5,1
    802018e8:	0080006f          	j	802018f0 <vprintfmt+0x324>
    802018ec:	00000793          	li	a5,0
    802018f0:	faf40323          	sb	a5,-90(s0)
    802018f4:	fa644783          	lbu	a5,-90(s0)
    802018f8:	0017f793          	andi	a5,a5,1
    802018fc:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    80201900:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80201904:	f5043783          	ld	a5,-176(s0)
    80201908:	0007c783          	lbu	a5,0(a5)
    8020190c:	00078713          	mv	a4,a5
    80201910:	05800793          	li	a5,88
    80201914:	00f71863          	bne	a4,a5,80201924 <vprintfmt+0x358>
    80201918:	00001797          	auipc	a5,0x1
    8020191c:	93078793          	addi	a5,a5,-1744 # 80202248 <upperxdigits.1>
    80201920:	00c0006f          	j	8020192c <vprintfmt+0x360>
    80201924:	00001797          	auipc	a5,0x1
    80201928:	93c78793          	addi	a5,a5,-1732 # 80202260 <lowerxdigits.0>
    8020192c:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    80201930:	fe043783          	ld	a5,-32(s0)
    80201934:	00f7f793          	andi	a5,a5,15
    80201938:	f9843703          	ld	a4,-104(s0)
    8020193c:	00f70733          	add	a4,a4,a5
    80201940:	fdc42783          	lw	a5,-36(s0)
    80201944:	0017869b          	addiw	a3,a5,1
    80201948:	fcd42e23          	sw	a3,-36(s0)
    8020194c:	00074703          	lbu	a4,0(a4)
    80201950:	ff078793          	addi	a5,a5,-16
    80201954:	008787b3          	add	a5,a5,s0
    80201958:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    8020195c:	fe043783          	ld	a5,-32(s0)
    80201960:	0047d793          	srli	a5,a5,0x4
    80201964:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201968:	fe043783          	ld	a5,-32(s0)
    8020196c:	fc0792e3          	bnez	a5,80201930 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    80201970:	f8c42783          	lw	a5,-116(s0)
    80201974:	00078713          	mv	a4,a5
    80201978:	fff00793          	li	a5,-1
    8020197c:	02f71663          	bne	a4,a5,802019a8 <vprintfmt+0x3dc>
    80201980:	f8344783          	lbu	a5,-125(s0)
    80201984:	02078263          	beqz	a5,802019a8 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    80201988:	f8842703          	lw	a4,-120(s0)
    8020198c:	fa644783          	lbu	a5,-90(s0)
    80201990:	0007879b          	sext.w	a5,a5
    80201994:	0017979b          	slliw	a5,a5,0x1
    80201998:	0007879b          	sext.w	a5,a5
    8020199c:	40f707bb          	subw	a5,a4,a5
    802019a0:	0007879b          	sext.w	a5,a5
    802019a4:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802019a8:	f8842703          	lw	a4,-120(s0)
    802019ac:	fa644783          	lbu	a5,-90(s0)
    802019b0:	0007879b          	sext.w	a5,a5
    802019b4:	0017979b          	slliw	a5,a5,0x1
    802019b8:	0007879b          	sext.w	a5,a5
    802019bc:	40f707bb          	subw	a5,a4,a5
    802019c0:	0007871b          	sext.w	a4,a5
    802019c4:	fdc42783          	lw	a5,-36(s0)
    802019c8:	f8f42a23          	sw	a5,-108(s0)
    802019cc:	f8c42783          	lw	a5,-116(s0)
    802019d0:	f8f42823          	sw	a5,-112(s0)
    802019d4:	f9442783          	lw	a5,-108(s0)
    802019d8:	00078593          	mv	a1,a5
    802019dc:	f9042783          	lw	a5,-112(s0)
    802019e0:	00078613          	mv	a2,a5
    802019e4:	0006069b          	sext.w	a3,a2
    802019e8:	0005879b          	sext.w	a5,a1
    802019ec:	00f6d463          	bge	a3,a5,802019f4 <vprintfmt+0x428>
    802019f0:	00058613          	mv	a2,a1
    802019f4:	0006079b          	sext.w	a5,a2
    802019f8:	40f707bb          	subw	a5,a4,a5
    802019fc:	fcf42c23          	sw	a5,-40(s0)
    80201a00:	0280006f          	j	80201a28 <vprintfmt+0x45c>
                    putch(' ');
    80201a04:	f5843783          	ld	a5,-168(s0)
    80201a08:	02000513          	li	a0,32
    80201a0c:	000780e7          	jalr	a5
                    ++written;
    80201a10:	fec42783          	lw	a5,-20(s0)
    80201a14:	0017879b          	addiw	a5,a5,1
    80201a18:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201a1c:	fd842783          	lw	a5,-40(s0)
    80201a20:	fff7879b          	addiw	a5,a5,-1
    80201a24:	fcf42c23          	sw	a5,-40(s0)
    80201a28:	fd842783          	lw	a5,-40(s0)
    80201a2c:	0007879b          	sext.w	a5,a5
    80201a30:	fcf04ae3          	bgtz	a5,80201a04 <vprintfmt+0x438>
                }

                if (prefix) {
    80201a34:	fa644783          	lbu	a5,-90(s0)
    80201a38:	0ff7f793          	zext.b	a5,a5
    80201a3c:	04078463          	beqz	a5,80201a84 <vprintfmt+0x4b8>
                    putch('0');
    80201a40:	f5843783          	ld	a5,-168(s0)
    80201a44:	03000513          	li	a0,48
    80201a48:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    80201a4c:	f5043783          	ld	a5,-176(s0)
    80201a50:	0007c783          	lbu	a5,0(a5)
    80201a54:	00078713          	mv	a4,a5
    80201a58:	05800793          	li	a5,88
    80201a5c:	00f71663          	bne	a4,a5,80201a68 <vprintfmt+0x49c>
    80201a60:	05800793          	li	a5,88
    80201a64:	0080006f          	j	80201a6c <vprintfmt+0x4a0>
    80201a68:	07800793          	li	a5,120
    80201a6c:	f5843703          	ld	a4,-168(s0)
    80201a70:	00078513          	mv	a0,a5
    80201a74:	000700e7          	jalr	a4
                    written += 2;
    80201a78:	fec42783          	lw	a5,-20(s0)
    80201a7c:	0027879b          	addiw	a5,a5,2
    80201a80:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    80201a84:	fdc42783          	lw	a5,-36(s0)
    80201a88:	fcf42a23          	sw	a5,-44(s0)
    80201a8c:	0280006f          	j	80201ab4 <vprintfmt+0x4e8>
                    putch('0');
    80201a90:	f5843783          	ld	a5,-168(s0)
    80201a94:	03000513          	li	a0,48
    80201a98:	000780e7          	jalr	a5
                    ++written;
    80201a9c:	fec42783          	lw	a5,-20(s0)
    80201aa0:	0017879b          	addiw	a5,a5,1
    80201aa4:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    80201aa8:	fd442783          	lw	a5,-44(s0)
    80201aac:	0017879b          	addiw	a5,a5,1
    80201ab0:	fcf42a23          	sw	a5,-44(s0)
    80201ab4:	f8c42703          	lw	a4,-116(s0)
    80201ab8:	fd442783          	lw	a5,-44(s0)
    80201abc:	0007879b          	sext.w	a5,a5
    80201ac0:	fce7c8e3          	blt	a5,a4,80201a90 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    80201ac4:	fdc42783          	lw	a5,-36(s0)
    80201ac8:	fff7879b          	addiw	a5,a5,-1
    80201acc:	fcf42823          	sw	a5,-48(s0)
    80201ad0:	03c0006f          	j	80201b0c <vprintfmt+0x540>
                    putch(buf[i]);
    80201ad4:	fd042783          	lw	a5,-48(s0)
    80201ad8:	ff078793          	addi	a5,a5,-16
    80201adc:	008787b3          	add	a5,a5,s0
    80201ae0:	f807c783          	lbu	a5,-128(a5)
    80201ae4:	0007871b          	sext.w	a4,a5
    80201ae8:	f5843783          	ld	a5,-168(s0)
    80201aec:	00070513          	mv	a0,a4
    80201af0:	000780e7          	jalr	a5
                    ++written;
    80201af4:	fec42783          	lw	a5,-20(s0)
    80201af8:	0017879b          	addiw	a5,a5,1
    80201afc:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    80201b00:	fd042783          	lw	a5,-48(s0)
    80201b04:	fff7879b          	addiw	a5,a5,-1
    80201b08:	fcf42823          	sw	a5,-48(s0)
    80201b0c:	fd042783          	lw	a5,-48(s0)
    80201b10:	0007879b          	sext.w	a5,a5
    80201b14:	fc07d0e3          	bgez	a5,80201ad4 <vprintfmt+0x508>
                }

                flags.in_format = false;
    80201b18:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201b1c:	2700006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201b20:	f5043783          	ld	a5,-176(s0)
    80201b24:	0007c783          	lbu	a5,0(a5)
    80201b28:	00078713          	mv	a4,a5
    80201b2c:	06400793          	li	a5,100
    80201b30:	02f70663          	beq	a4,a5,80201b5c <vprintfmt+0x590>
    80201b34:	f5043783          	ld	a5,-176(s0)
    80201b38:	0007c783          	lbu	a5,0(a5)
    80201b3c:	00078713          	mv	a4,a5
    80201b40:	06900793          	li	a5,105
    80201b44:	00f70c63          	beq	a4,a5,80201b5c <vprintfmt+0x590>
    80201b48:	f5043783          	ld	a5,-176(s0)
    80201b4c:	0007c783          	lbu	a5,0(a5)
    80201b50:	00078713          	mv	a4,a5
    80201b54:	07500793          	li	a5,117
    80201b58:	08f71063          	bne	a4,a5,80201bd8 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    80201b5c:	f8144783          	lbu	a5,-127(s0)
    80201b60:	00078c63          	beqz	a5,80201b78 <vprintfmt+0x5ac>
    80201b64:	f4843783          	ld	a5,-184(s0)
    80201b68:	00878713          	addi	a4,a5,8
    80201b6c:	f4e43423          	sd	a4,-184(s0)
    80201b70:	0007b783          	ld	a5,0(a5)
    80201b74:	0140006f          	j	80201b88 <vprintfmt+0x5bc>
    80201b78:	f4843783          	ld	a5,-184(s0)
    80201b7c:	00878713          	addi	a4,a5,8
    80201b80:	f4e43423          	sd	a4,-184(s0)
    80201b84:	0007a783          	lw	a5,0(a5)
    80201b88:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    80201b8c:	fa843583          	ld	a1,-88(s0)
    80201b90:	f5043783          	ld	a5,-176(s0)
    80201b94:	0007c783          	lbu	a5,0(a5)
    80201b98:	0007871b          	sext.w	a4,a5
    80201b9c:	07500793          	li	a5,117
    80201ba0:	40f707b3          	sub	a5,a4,a5
    80201ba4:	00f037b3          	snez	a5,a5
    80201ba8:	0ff7f793          	zext.b	a5,a5
    80201bac:	f8040713          	addi	a4,s0,-128
    80201bb0:	00070693          	mv	a3,a4
    80201bb4:	00078613          	mv	a2,a5
    80201bb8:	f5843503          	ld	a0,-168(s0)
    80201bbc:	f08ff0ef          	jal	ra,802012c4 <print_dec_int>
    80201bc0:	00050793          	mv	a5,a0
    80201bc4:	fec42703          	lw	a4,-20(s0)
    80201bc8:	00f707bb          	addw	a5,a4,a5
    80201bcc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201bd0:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    80201bd4:	1b80006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    80201bd8:	f5043783          	ld	a5,-176(s0)
    80201bdc:	0007c783          	lbu	a5,0(a5)
    80201be0:	00078713          	mv	a4,a5
    80201be4:	06e00793          	li	a5,110
    80201be8:	04f71c63          	bne	a4,a5,80201c40 <vprintfmt+0x674>
                if (flags.longflag) {
    80201bec:	f8144783          	lbu	a5,-127(s0)
    80201bf0:	02078463          	beqz	a5,80201c18 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    80201bf4:	f4843783          	ld	a5,-184(s0)
    80201bf8:	00878713          	addi	a4,a5,8
    80201bfc:	f4e43423          	sd	a4,-184(s0)
    80201c00:	0007b783          	ld	a5,0(a5)
    80201c04:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201c08:	fec42703          	lw	a4,-20(s0)
    80201c0c:	fb043783          	ld	a5,-80(s0)
    80201c10:	00e7b023          	sd	a4,0(a5)
    80201c14:	0240006f          	j	80201c38 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    80201c18:	f4843783          	ld	a5,-184(s0)
    80201c1c:	00878713          	addi	a4,a5,8
    80201c20:	f4e43423          	sd	a4,-184(s0)
    80201c24:	0007b783          	ld	a5,0(a5)
    80201c28:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    80201c2c:	fb843783          	ld	a5,-72(s0)
    80201c30:	fec42703          	lw	a4,-20(s0)
    80201c34:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201c38:	f8040023          	sb	zero,-128(s0)
    80201c3c:	1500006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    80201c40:	f5043783          	ld	a5,-176(s0)
    80201c44:	0007c783          	lbu	a5,0(a5)
    80201c48:	00078713          	mv	a4,a5
    80201c4c:	07300793          	li	a5,115
    80201c50:	02f71e63          	bne	a4,a5,80201c8c <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201c54:	f4843783          	ld	a5,-184(s0)
    80201c58:	00878713          	addi	a4,a5,8
    80201c5c:	f4e43423          	sd	a4,-184(s0)
    80201c60:	0007b783          	ld	a5,0(a5)
    80201c64:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201c68:	fc043583          	ld	a1,-64(s0)
    80201c6c:	f5843503          	ld	a0,-168(s0)
    80201c70:	dccff0ef          	jal	ra,8020123c <puts_wo_nl>
    80201c74:	00050793          	mv	a5,a0
    80201c78:	fec42703          	lw	a4,-20(s0)
    80201c7c:	00f707bb          	addw	a5,a4,a5
    80201c80:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201c84:	f8040023          	sb	zero,-128(s0)
    80201c88:	1040006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    80201c8c:	f5043783          	ld	a5,-176(s0)
    80201c90:	0007c783          	lbu	a5,0(a5)
    80201c94:	00078713          	mv	a4,a5
    80201c98:	06300793          	li	a5,99
    80201c9c:	02f71e63          	bne	a4,a5,80201cd8 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    80201ca0:	f4843783          	ld	a5,-184(s0)
    80201ca4:	00878713          	addi	a4,a5,8
    80201ca8:	f4e43423          	sd	a4,-184(s0)
    80201cac:	0007a783          	lw	a5,0(a5)
    80201cb0:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    80201cb4:	fcc42703          	lw	a4,-52(s0)
    80201cb8:	f5843783          	ld	a5,-168(s0)
    80201cbc:	00070513          	mv	a0,a4
    80201cc0:	000780e7          	jalr	a5
                ++written;
    80201cc4:	fec42783          	lw	a5,-20(s0)
    80201cc8:	0017879b          	addiw	a5,a5,1
    80201ccc:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201cd0:	f8040023          	sb	zero,-128(s0)
    80201cd4:	0b80006f          	j	80201d8c <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    80201cd8:	f5043783          	ld	a5,-176(s0)
    80201cdc:	0007c783          	lbu	a5,0(a5)
    80201ce0:	00078713          	mv	a4,a5
    80201ce4:	02500793          	li	a5,37
    80201ce8:	02f71263          	bne	a4,a5,80201d0c <vprintfmt+0x740>
                putch('%');
    80201cec:	f5843783          	ld	a5,-168(s0)
    80201cf0:	02500513          	li	a0,37
    80201cf4:	000780e7          	jalr	a5
                ++written;
    80201cf8:	fec42783          	lw	a5,-20(s0)
    80201cfc:	0017879b          	addiw	a5,a5,1
    80201d00:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201d04:	f8040023          	sb	zero,-128(s0)
    80201d08:	0840006f          	j	80201d8c <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    80201d0c:	f5043783          	ld	a5,-176(s0)
    80201d10:	0007c783          	lbu	a5,0(a5)
    80201d14:	0007871b          	sext.w	a4,a5
    80201d18:	f5843783          	ld	a5,-168(s0)
    80201d1c:	00070513          	mv	a0,a4
    80201d20:	000780e7          	jalr	a5
                ++written;
    80201d24:	fec42783          	lw	a5,-20(s0)
    80201d28:	0017879b          	addiw	a5,a5,1
    80201d2c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201d30:	f8040023          	sb	zero,-128(s0)
    80201d34:	0580006f          	j	80201d8c <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201d38:	f5043783          	ld	a5,-176(s0)
    80201d3c:	0007c783          	lbu	a5,0(a5)
    80201d40:	00078713          	mv	a4,a5
    80201d44:	02500793          	li	a5,37
    80201d48:	02f71063          	bne	a4,a5,80201d68 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201d4c:	f8043023          	sd	zero,-128(s0)
    80201d50:	f8043423          	sd	zero,-120(s0)
    80201d54:	00100793          	li	a5,1
    80201d58:	f8f40023          	sb	a5,-128(s0)
    80201d5c:	fff00793          	li	a5,-1
    80201d60:	f8f42623          	sw	a5,-116(s0)
    80201d64:	0280006f          	j	80201d8c <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201d68:	f5043783          	ld	a5,-176(s0)
    80201d6c:	0007c783          	lbu	a5,0(a5)
    80201d70:	0007871b          	sext.w	a4,a5
    80201d74:	f5843783          	ld	a5,-168(s0)
    80201d78:	00070513          	mv	a0,a4
    80201d7c:	000780e7          	jalr	a5
            ++written;
    80201d80:	fec42783          	lw	a5,-20(s0)
    80201d84:	0017879b          	addiw	a5,a5,1
    80201d88:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    80201d8c:	f5043783          	ld	a5,-176(s0)
    80201d90:	00178793          	addi	a5,a5,1
    80201d94:	f4f43823          	sd	a5,-176(s0)
    80201d98:	f5043783          	ld	a5,-176(s0)
    80201d9c:	0007c783          	lbu	a5,0(a5)
    80201da0:	84079ce3          	bnez	a5,802015f8 <vprintfmt+0x2c>
        }
    }

    return written;
    80201da4:	fec42783          	lw	a5,-20(s0)
}
    80201da8:	00078513          	mv	a0,a5
    80201dac:	0b813083          	ld	ra,184(sp)
    80201db0:	0b013403          	ld	s0,176(sp)
    80201db4:	0c010113          	addi	sp,sp,192
    80201db8:	00008067          	ret

0000000080201dbc <printk>:

int printk(const char* s, ...) {
    80201dbc:	f9010113          	addi	sp,sp,-112
    80201dc0:	02113423          	sd	ra,40(sp)
    80201dc4:	02813023          	sd	s0,32(sp)
    80201dc8:	03010413          	addi	s0,sp,48
    80201dcc:	fca43c23          	sd	a0,-40(s0)
    80201dd0:	00b43423          	sd	a1,8(s0)
    80201dd4:	00c43823          	sd	a2,16(s0)
    80201dd8:	00d43c23          	sd	a3,24(s0)
    80201ddc:	02e43023          	sd	a4,32(s0)
    80201de0:	02f43423          	sd	a5,40(s0)
    80201de4:	03043823          	sd	a6,48(s0)
    80201de8:	03143c23          	sd	a7,56(s0)
    int res = 0;
    80201dec:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    80201df0:	04040793          	addi	a5,s0,64
    80201df4:	fcf43823          	sd	a5,-48(s0)
    80201df8:	fd043783          	ld	a5,-48(s0)
    80201dfc:	fc878793          	addi	a5,a5,-56
    80201e00:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201e04:	fe043783          	ld	a5,-32(s0)
    80201e08:	00078613          	mv	a2,a5
    80201e0c:	fd843583          	ld	a1,-40(s0)
    80201e10:	fffff517          	auipc	a0,0xfffff
    80201e14:	11850513          	addi	a0,a0,280 # 80200f28 <putc>
    80201e18:	fb4ff0ef          	jal	ra,802015cc <vprintfmt>
    80201e1c:	00050793          	mv	a5,a0
    80201e20:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201e24:	fec42783          	lw	a5,-20(s0)
}
    80201e28:	00078513          	mv	a0,a5
    80201e2c:	02813083          	ld	ra,40(sp)
    80201e30:	02013403          	ld	s0,32(sp)
    80201e34:	07010113          	addi	sp,sp,112
    80201e38:	00008067          	ret

0000000080201e3c <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
    80201e3c:	fe010113          	addi	sp,sp,-32
    80201e40:	00813c23          	sd	s0,24(sp)
    80201e44:	02010413          	addi	s0,sp,32
    80201e48:	00050793          	mv	a5,a0
    80201e4c:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
    80201e50:	fec42783          	lw	a5,-20(s0)
    80201e54:	fff7879b          	addiw	a5,a5,-1
    80201e58:	0007879b          	sext.w	a5,a5
    80201e5c:	02079713          	slli	a4,a5,0x20
    80201e60:	02075713          	srli	a4,a4,0x20
    80201e64:	00003797          	auipc	a5,0x3
    80201e68:	20c78793          	addi	a5,a5,524 # 80205070 <seed>
    80201e6c:	00e7b023          	sd	a4,0(a5)
}
    80201e70:	00000013          	nop
    80201e74:	01813403          	ld	s0,24(sp)
    80201e78:	02010113          	addi	sp,sp,32
    80201e7c:	00008067          	ret

0000000080201e80 <rand>:

int rand(void) {
    80201e80:	ff010113          	addi	sp,sp,-16
    80201e84:	00813423          	sd	s0,8(sp)
    80201e88:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
    80201e8c:	00003797          	auipc	a5,0x3
    80201e90:	1e478793          	addi	a5,a5,484 # 80205070 <seed>
    80201e94:	0007b703          	ld	a4,0(a5)
    80201e98:	00000797          	auipc	a5,0x0
    80201e9c:	3e078793          	addi	a5,a5,992 # 80202278 <lowerxdigits.0+0x18>
    80201ea0:	0007b783          	ld	a5,0(a5)
    80201ea4:	02f707b3          	mul	a5,a4,a5
    80201ea8:	00178713          	addi	a4,a5,1
    80201eac:	00003797          	auipc	a5,0x3
    80201eb0:	1c478793          	addi	a5,a5,452 # 80205070 <seed>
    80201eb4:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
    80201eb8:	00003797          	auipc	a5,0x3
    80201ebc:	1b878793          	addi	a5,a5,440 # 80205070 <seed>
    80201ec0:	0007b783          	ld	a5,0(a5)
    80201ec4:	0217d793          	srli	a5,a5,0x21
    80201ec8:	0007879b          	sext.w	a5,a5
}
    80201ecc:	00078513          	mv	a0,a5
    80201ed0:	00813403          	ld	s0,8(sp)
    80201ed4:	01010113          	addi	sp,sp,16
    80201ed8:	00008067          	ret

0000000080201edc <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
    80201edc:	fc010113          	addi	sp,sp,-64
    80201ee0:	02813c23          	sd	s0,56(sp)
    80201ee4:	04010413          	addi	s0,sp,64
    80201ee8:	fca43c23          	sd	a0,-40(s0)
    80201eec:	00058793          	mv	a5,a1
    80201ef0:	fcc43423          	sd	a2,-56(s0)
    80201ef4:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
    80201ef8:	fd843783          	ld	a5,-40(s0)
    80201efc:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
    80201f00:	fe043423          	sd	zero,-24(s0)
    80201f04:	0280006f          	j	80201f2c <memset+0x50>
        s[i] = c;
    80201f08:	fe043703          	ld	a4,-32(s0)
    80201f0c:	fe843783          	ld	a5,-24(s0)
    80201f10:	00f707b3          	add	a5,a4,a5
    80201f14:	fd442703          	lw	a4,-44(s0)
    80201f18:	0ff77713          	zext.b	a4,a4
    80201f1c:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
    80201f20:	fe843783          	ld	a5,-24(s0)
    80201f24:	00178793          	addi	a5,a5,1
    80201f28:	fef43423          	sd	a5,-24(s0)
    80201f2c:	fe843703          	ld	a4,-24(s0)
    80201f30:	fc843783          	ld	a5,-56(s0)
    80201f34:	fcf76ae3          	bltu	a4,a5,80201f08 <memset+0x2c>
    }
    return dest;
    80201f38:	fd843783          	ld	a5,-40(s0)
}
    80201f3c:	00078513          	mv	a0,a5
    80201f40:	03813403          	ld	s0,56(sp)
    80201f44:	04010113          	addi	sp,sp,64
    80201f48:	00008067          	ret
