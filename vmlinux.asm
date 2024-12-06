
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
    .extern setup_vm
    .extern setup_vm_final
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
ffffffe000200000:	00006117          	auipc	sp,0x6
ffffffe000200004:	00010113          	mv	sp,sp
    
    call setup_vm
ffffffe000200008:	721000ef          	jal	ra,ffffffe000200f28 <setup_vm>
    call relocate
ffffffe00020000c:	064000ef          	jal	ra,ffffffe000200070 <relocate>

    call mm_init
ffffffe000200010:	3f8000ef          	jal	ra,ffffffe000200408 <mm_init>

    call setup_vm_final
ffffffe000200014:	040010ef          	jal	ra,ffffffe000201054 <setup_vm_final>

    call task_init
ffffffe000200018:	440000ef          	jal	ra,ffffffe000200458 <task_init>

    # set stvec = _traps
    la t0, _traps
ffffffe00020001c:	00000297          	auipc	t0,0x0
ffffffe000200020:	08828293          	addi	t0,t0,136 # ffffffe0002000a4 <_traps>
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
    csrwi sstatus, 0x2
ffffffe000200068:	10015073          	csrwi	sstatus,2

    jal start_kernel
ffffffe00020006c:	3fc010ef          	jal	ra,ffffffe000201468 <start_kernel>

ffffffe000200070 <relocate>:
    # jal _srodata

relocate:
    li t0, 0xffffffdf80000000
ffffffe000200070:	fbf0029b          	addiw	t0,zero,-65
ffffffe000200074:	01f29293          	slli	t0,t0,0x1f
    # set ra = ra + PA2VA_OFFSET
    add ra, ra, t0
ffffffe000200078:	005080b3          	add	ra,ra,t0
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)
    add sp, sp, t0
ffffffe00020007c:	00510133          	add	sp,sp,t0
    # la a0, _traps
    # add a0, a0, t0
    # csrw stvec, a0

    # need a fence to ensure the new translations are in use
    sfence.vma zero, zero
ffffffe000200080:	12000073          	sfence.vma

    # set satp with early_pgtbl
    la t1, early_pgtbl
ffffffe000200084:	00007317          	auipc	t1,0x7
ffffffe000200088:	f7c30313          	addi	t1,t1,-132 # ffffffe000207000 <early_pgtbl>
    
    # MODE = 0X8
    li t2, 0x8000000000000000
ffffffe00020008c:	fff0039b          	addiw	t2,zero,-1
ffffffe000200090:	03f39393          	slli	t2,t2,0x3f
    srli t1, t1, 12
ffffffe000200094:	00c35313          	srli	t1,t1,0xc
    add t1, t1, t2
ffffffe000200098:	00730333          	add	t1,t1,t2
    csrw satp, t1
ffffffe00020009c:	18031073          	csrw	satp,t1
    # csrs satp, t2
    ###################### 
    #   YOUR CODE HERE   #
    ######################

    ret
ffffffe0002000a0:	00008067          	ret

ffffffe0002000a4 <_traps>:
    .align 2
    .globl _traps 

_traps:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -256
ffffffe0002000a4:	f0010113          	addi	sp,sp,-256 # ffffffe000205f00 <_sbss+0xf00>
    sd x1, 0(sp)
ffffffe0002000a8:	00113023          	sd	ra,0(sp)
    sd x2, 8(sp)
ffffffe0002000ac:	00213423          	sd	sp,8(sp)
    sd x3, 16(sp)
ffffffe0002000b0:	00313823          	sd	gp,16(sp)
    sd x4, 24(sp)
ffffffe0002000b4:	00413c23          	sd	tp,24(sp)
    sd x5, 32(sp)
ffffffe0002000b8:	02513023          	sd	t0,32(sp)
    sd x6, 40(sp)
ffffffe0002000bc:	02613423          	sd	t1,40(sp)
    sd x7, 48(sp)
ffffffe0002000c0:	02713823          	sd	t2,48(sp)
    sd x8, 56(sp)
ffffffe0002000c4:	02813c23          	sd	s0,56(sp)
    sd x9, 64(sp)
ffffffe0002000c8:	04913023          	sd	s1,64(sp)
    sd x10, 72(sp)
ffffffe0002000cc:	04a13423          	sd	a0,72(sp)
    sd x11, 80(sp)
ffffffe0002000d0:	04b13823          	sd	a1,80(sp)
    sd x12, 88(sp)
ffffffe0002000d4:	04c13c23          	sd	a2,88(sp)
    sd x13, 96(sp)
ffffffe0002000d8:	06d13023          	sd	a3,96(sp)
    sd x14, 104(sp)
ffffffe0002000dc:	06e13423          	sd	a4,104(sp)
    sd x15, 112(sp)
ffffffe0002000e0:	06f13823          	sd	a5,112(sp)
    sd x16, 120(sp)
ffffffe0002000e4:	07013c23          	sd	a6,120(sp)
    sd x17, 128(sp)
ffffffe0002000e8:	09113023          	sd	a7,128(sp)
    sd x18, 136(sp)
ffffffe0002000ec:	09213423          	sd	s2,136(sp)
    sd x19, 144(sp)
ffffffe0002000f0:	09313823          	sd	s3,144(sp)
    sd x20, 152(sp)
ffffffe0002000f4:	09413c23          	sd	s4,152(sp)
    sd x21, 160(sp)
ffffffe0002000f8:	0b513023          	sd	s5,160(sp)
    sd x22, 168(sp)
ffffffe0002000fc:	0b613423          	sd	s6,168(sp)
    sd x23, 176(sp)
ffffffe000200100:	0b713823          	sd	s7,176(sp)
    sd x24, 184(sp)
ffffffe000200104:	0b813c23          	sd	s8,184(sp)
    sd x25, 192(sp)
ffffffe000200108:	0d913023          	sd	s9,192(sp)
    sd x26, 200(sp)
ffffffe00020010c:	0da13423          	sd	s10,200(sp)
    sd x27, 208(sp)
ffffffe000200110:	0db13823          	sd	s11,208(sp)
    sd x28, 216(sp)
ffffffe000200114:	0dc13c23          	sd	t3,216(sp)
    sd x29, 224(sp)
ffffffe000200118:	0fd13023          	sd	t4,224(sp)
    sd x30, 232(sp)
ffffffe00020011c:	0fe13423          	sd	t5,232(sp)
    sd x31, 240(sp)
ffffffe000200120:	0ff13823          	sd	t6,240(sp)
    csrr t0, sepc
ffffffe000200124:	141022f3          	csrr	t0,sepc
    sd t0, 248(sp)
ffffffe000200128:	0e513c23          	sd	t0,248(sp)
    # 2. call trap_handler
    csrr a0, scause
ffffffe00020012c:	14202573          	csrr	a0,scause
    csrr a1, sepc
ffffffe000200130:	141025f3          	csrr	a1,sepc
    call trap_handler
ffffffe000200134:	399000ef          	jal	ra,ffffffe000200ccc <trap_handler>
    # call csr_change

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    # ld t0, 248(sp)
    # csrw sepc, t0
    ld x1, 0(sp)
ffffffe000200138:	00013083          	ld	ra,0(sp)
    
    ld x3, 16(sp)
ffffffe00020013c:	01013183          	ld	gp,16(sp)
    ld x4, 24(sp)
ffffffe000200140:	01813203          	ld	tp,24(sp)
    ld x5, 32(sp)
ffffffe000200144:	02013283          	ld	t0,32(sp)
    ld x6, 40(sp)
ffffffe000200148:	02813303          	ld	t1,40(sp)
    ld x7, 48(sp)
ffffffe00020014c:	03013383          	ld	t2,48(sp)
    ld x8, 56(sp)
ffffffe000200150:	03813403          	ld	s0,56(sp)
    ld x9, 64(sp)
ffffffe000200154:	04013483          	ld	s1,64(sp)
    ld x10, 72(sp)
ffffffe000200158:	04813503          	ld	a0,72(sp)
    ld x11, 80(sp)
ffffffe00020015c:	05013583          	ld	a1,80(sp)
    ld x12, 88(sp)
ffffffe000200160:	05813603          	ld	a2,88(sp)
    ld x13, 96(sp)
ffffffe000200164:	06013683          	ld	a3,96(sp)
    ld x14, 104(sp)
ffffffe000200168:	06813703          	ld	a4,104(sp)
    ld x15, 112(sp)
ffffffe00020016c:	07013783          	ld	a5,112(sp)
    ld x16, 120(sp)
ffffffe000200170:	07813803          	ld	a6,120(sp)
    ld x17, 128(sp)
ffffffe000200174:	08013883          	ld	a7,128(sp)
    ld x18, 136(sp)
ffffffe000200178:	08813903          	ld	s2,136(sp)
    ld x19, 144(sp)
ffffffe00020017c:	09013983          	ld	s3,144(sp)
    ld x20, 152(sp)
ffffffe000200180:	09813a03          	ld	s4,152(sp)
    ld x21, 160(sp)
ffffffe000200184:	0a013a83          	ld	s5,160(sp)
    ld x22, 168(sp)
ffffffe000200188:	0a813b03          	ld	s6,168(sp)
    ld x23, 176(sp)
ffffffe00020018c:	0b013b83          	ld	s7,176(sp)
    ld x24, 184(sp)
ffffffe000200190:	0b813c03          	ld	s8,184(sp)
    ld x25, 192(sp)
ffffffe000200194:	0c013c83          	ld	s9,192(sp)
    ld x26, 200(sp)
ffffffe000200198:	0c813d03          	ld	s10,200(sp)
    ld x27, 208(sp)
ffffffe00020019c:	0d013d83          	ld	s11,208(sp)
    ld x28, 216(sp)
ffffffe0002001a0:	0d813e03          	ld	t3,216(sp)
    ld x29, 224(sp)
ffffffe0002001a4:	0e013e83          	ld	t4,224(sp)
    ld x30, 232(sp)
ffffffe0002001a8:	0e813f03          	ld	t5,232(sp)
    ld x31, 240(sp)
ffffffe0002001ac:	0f013f83          	ld	t6,240(sp)
    ld x2, 8(sp)
ffffffe0002001b0:	00813103          	ld	sp,8(sp)
    addi sp, sp, 256
ffffffe0002001b4:	10010113          	addi	sp,sp,256
    # 4. return from trap
    sret
ffffffe0002001b8:	10200073          	sret

ffffffe0002001bc <__dummy>:

    .extern dummy
    .globl __dummy
__dummy:
    la t0, dummy
ffffffe0002001bc:	00000297          	auipc	t0,0x0
ffffffe0002001c0:	40428293          	addi	t0,t0,1028 # ffffffe0002005c0 <dummy>
    csrw sepc, t0
ffffffe0002001c4:	14129073          	csrw	sepc,t0
    sret
ffffffe0002001c8:	10200073          	sret

ffffffe0002001cc <__switch_to>:
    .globl __switch_to
__switch_to:
    # save state to prev process
    # YOUR CODE HERE    
    #保存当前线程的 ra，sp，s0~s11 到当前线程的 thread_struct 中
    sd ra, 32(a0)
ffffffe0002001cc:	02153023          	sd	ra,32(a0)
    sd sp, 40(a0)
ffffffe0002001d0:	02253423          	sd	sp,40(a0)
    sd s0, 48(a0)
ffffffe0002001d4:	02853823          	sd	s0,48(a0)
    sd s1, 56(a0)
ffffffe0002001d8:	02953c23          	sd	s1,56(a0)
    sd s2, 64(a0)
ffffffe0002001dc:	05253023          	sd	s2,64(a0)
    sd s3, 72(a0)
ffffffe0002001e0:	05353423          	sd	s3,72(a0)
    sd s4, 80(a0)
ffffffe0002001e4:	05453823          	sd	s4,80(a0)
    sd s5, 88(a0)
ffffffe0002001e8:	05553c23          	sd	s5,88(a0)
    sd s6, 96(a0)
ffffffe0002001ec:	07653023          	sd	s6,96(a0)
    sd s7, 104(a0)
ffffffe0002001f0:	07753423          	sd	s7,104(a0)
    sd s8, 112(a0)
ffffffe0002001f4:	07853823          	sd	s8,112(a0)
    sd s9, 120(a0)
ffffffe0002001f8:	07953c23          	sd	s9,120(a0)
    sd s10, 128(a0)
ffffffe0002001fc:	09a53023          	sd	s10,128(a0)
    sd s11, 136(a0)
ffffffe000200200:	09b53423          	sd	s11,136(a0)

    ld ra, 32(a1)
ffffffe000200204:	0205b083          	ld	ra,32(a1)
    ld sp, 40(a1)
ffffffe000200208:	0285b103          	ld	sp,40(a1)
    ld s0, 48(a1)
ffffffe00020020c:	0305b403          	ld	s0,48(a1)
    ld s1, 56(a1)
ffffffe000200210:	0385b483          	ld	s1,56(a1)
    ld s2, 64(a1)
ffffffe000200214:	0405b903          	ld	s2,64(a1)
    ld s3, 72(a1)
ffffffe000200218:	0485b983          	ld	s3,72(a1)
    ld s4, 80(a1)
ffffffe00020021c:	0505ba03          	ld	s4,80(a1)
    ld s5, 88(a1)
ffffffe000200220:	0585ba83          	ld	s5,88(a1)
    ld s6, 96(a1)
ffffffe000200224:	0605bb03          	ld	s6,96(a1)
    ld s7, 104(a1)
ffffffe000200228:	0685bb83          	ld	s7,104(a1)
    ld s8, 112(a1)
ffffffe00020022c:	0705bc03          	ld	s8,112(a1)
    ld s9, 120(a1)
ffffffe000200230:	0785bc83          	ld	s9,120(a1)
    ld s10, 128(a1)
ffffffe000200234:	0805bd03          	ld	s10,128(a1)
    ld s11, 136(a1)
ffffffe000200238:	0885bd83          	ld	s11,136(a1)
ffffffe00020023c:	00008067          	ret

ffffffe000200240 <get_cycles>:
#include "sbi.h"

// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
ffffffe000200240:	fe010113          	addi	sp,sp,-32
ffffffe000200244:	00813c23          	sd	s0,24(sp)
ffffffe000200248:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    // #error Unimplemented
    uint64_t cycles;
    asm volatile("rdtime %0" : "=r"(cycles));
ffffffe00020024c:	c01027f3          	rdtime	a5
ffffffe000200250:	fef43423          	sd	a5,-24(s0)
    return cycles;
ffffffe000200254:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200258:	00078513          	mv	a0,a5
ffffffe00020025c:	01813403          	ld	s0,24(sp)
ffffffe000200260:	02010113          	addi	sp,sp,32
ffffffe000200264:	00008067          	ret

ffffffe000200268 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200268:	fe010113          	addi	sp,sp,-32
ffffffe00020026c:	00113c23          	sd	ra,24(sp)
ffffffe000200270:	00813823          	sd	s0,16(sp)
ffffffe000200274:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
ffffffe000200278:	fc9ff0ef          	jal	ra,ffffffe000200240 <get_cycles>
ffffffe00020027c:	00050713          	mv	a4,a0
ffffffe000200280:	00004797          	auipc	a5,0x4
ffffffe000200284:	d8078793          	addi	a5,a5,-640 # ffffffe000204000 <TIMECLOCK>
ffffffe000200288:	0007b783          	ld	a5,0(a5)
ffffffe00020028c:	00f707b3          	add	a5,a4,a5
ffffffe000200290:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
ffffffe000200294:	fe843503          	ld	a0,-24(s0)
ffffffe000200298:	1a9000ef          	jal	ra,ffffffe000200c40 <sbi_set_timer>
ffffffe00020029c:	00000013          	nop
ffffffe0002002a0:	01813083          	ld	ra,24(sp)
ffffffe0002002a4:	01013403          	ld	s0,16(sp)
ffffffe0002002a8:	02010113          	addi	sp,sp,32
ffffffe0002002ac:	00008067          	ret

ffffffe0002002b0 <kalloc>:

struct {
    struct run *freelist;
} kmem;

void *kalloc() {
ffffffe0002002b0:	fe010113          	addi	sp,sp,-32
ffffffe0002002b4:	00113c23          	sd	ra,24(sp)
ffffffe0002002b8:	00813823          	sd	s0,16(sp)
ffffffe0002002bc:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
ffffffe0002002c0:	00006797          	auipc	a5,0x6
ffffffe0002002c4:	d4078793          	addi	a5,a5,-704 # ffffffe000206000 <kmem>
ffffffe0002002c8:	0007b783          	ld	a5,0(a5)
ffffffe0002002cc:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
ffffffe0002002d0:	fe843783          	ld	a5,-24(s0)
ffffffe0002002d4:	0007b703          	ld	a4,0(a5)
ffffffe0002002d8:	00006797          	auipc	a5,0x6
ffffffe0002002dc:	d2878793          	addi	a5,a5,-728 # ffffffe000206000 <kmem>
ffffffe0002002e0:	00e7b023          	sd	a4,0(a5)
    
    memset((void *)r, 0x0, PGSIZE);
ffffffe0002002e4:	00001637          	lui	a2,0x1
ffffffe0002002e8:	00000593          	li	a1,0
ffffffe0002002ec:	fe843503          	ld	a0,-24(s0)
ffffffe0002002f0:	2d0020ef          	jal	ra,ffffffe0002025c0 <memset>
    return (void *)r;
ffffffe0002002f4:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002002f8:	00078513          	mv	a0,a5
ffffffe0002002fc:	01813083          	ld	ra,24(sp)
ffffffe000200300:	01013403          	ld	s0,16(sp)
ffffffe000200304:	02010113          	addi	sp,sp,32
ffffffe000200308:	00008067          	ret

ffffffe00020030c <kfree>:

void kfree(void *addr) {
ffffffe00020030c:	fd010113          	addi	sp,sp,-48
ffffffe000200310:	02113423          	sd	ra,40(sp)
ffffffe000200314:	02813023          	sd	s0,32(sp)
ffffffe000200318:	03010413          	addi	s0,sp,48
ffffffe00020031c:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    *(uintptr_t *)&addr = (uintptr_t)addr & ~(PGSIZE - 1);
ffffffe000200320:	fd843783          	ld	a5,-40(s0)
ffffffe000200324:	00078693          	mv	a3,a5
ffffffe000200328:	fd840793          	addi	a5,s0,-40
ffffffe00020032c:	fffff737          	lui	a4,0xfffff
ffffffe000200330:	00e6f733          	and	a4,a3,a4
ffffffe000200334:	00e7b023          	sd	a4,0(a5)

    memset(addr, 0x0, (uint64_t)PGSIZE);
ffffffe000200338:	fd843783          	ld	a5,-40(s0)
ffffffe00020033c:	00001637          	lui	a2,0x1
ffffffe000200340:	00000593          	li	a1,0
ffffffe000200344:	00078513          	mv	a0,a5
ffffffe000200348:	278020ef          	jal	ra,ffffffe0002025c0 <memset>

    r = (struct run *)addr;
ffffffe00020034c:	fd843783          	ld	a5,-40(s0)
ffffffe000200350:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
ffffffe000200354:	00006797          	auipc	a5,0x6
ffffffe000200358:	cac78793          	addi	a5,a5,-852 # ffffffe000206000 <kmem>
ffffffe00020035c:	0007b703          	ld	a4,0(a5)
ffffffe000200360:	fe843783          	ld	a5,-24(s0)
ffffffe000200364:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
ffffffe000200368:	00006797          	auipc	a5,0x6
ffffffe00020036c:	c9878793          	addi	a5,a5,-872 # ffffffe000206000 <kmem>
ffffffe000200370:	fe843703          	ld	a4,-24(s0)
ffffffe000200374:	00e7b023          	sd	a4,0(a5)

    return;
ffffffe000200378:	00000013          	nop
}
ffffffe00020037c:	02813083          	ld	ra,40(sp)
ffffffe000200380:	02013403          	ld	s0,32(sp)
ffffffe000200384:	03010113          	addi	sp,sp,48
ffffffe000200388:	00008067          	ret

ffffffe00020038c <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe00020038c:	fd010113          	addi	sp,sp,-48
ffffffe000200390:	02113423          	sd	ra,40(sp)
ffffffe000200394:	02813023          	sd	s0,32(sp)
ffffffe000200398:	03010413          	addi	s0,sp,48
ffffffe00020039c:	fca43c23          	sd	a0,-40(s0)
ffffffe0002003a0:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uintptr_t)start);
ffffffe0002003a4:	fd843703          	ld	a4,-40(s0)
ffffffe0002003a8:	000017b7          	lui	a5,0x1
ffffffe0002003ac:	fff78793          	addi	a5,a5,-1 # fff <PGSIZE-0x1>
ffffffe0002003b0:	00f70733          	add	a4,a4,a5
ffffffe0002003b4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002003b8:	00f777b3          	and	a5,a4,a5
ffffffe0002003bc:	fef43423          	sd	a5,-24(s0)
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003c0:	01c0006f          	j	ffffffe0002003dc <kfreerange+0x50>
        kfree((void *)addr);
ffffffe0002003c4:	fe843503          	ld	a0,-24(s0)
ffffffe0002003c8:	f45ff0ef          	jal	ra,ffffffe00020030c <kfree>
    for (; (uintptr_t)(addr) + PGSIZE <= (uintptr_t)end; addr += PGSIZE) {
ffffffe0002003cc:	fe843703          	ld	a4,-24(s0)
ffffffe0002003d0:	000017b7          	lui	a5,0x1
ffffffe0002003d4:	00f707b3          	add	a5,a4,a5
ffffffe0002003d8:	fef43423          	sd	a5,-24(s0)
ffffffe0002003dc:	fe843703          	ld	a4,-24(s0)
ffffffe0002003e0:	000017b7          	lui	a5,0x1
ffffffe0002003e4:	00f70733          	add	a4,a4,a5
ffffffe0002003e8:	fd043783          	ld	a5,-48(s0)
ffffffe0002003ec:	fce7fce3          	bgeu	a5,a4,ffffffe0002003c4 <kfreerange+0x38>
    }
}
ffffffe0002003f0:	00000013          	nop
ffffffe0002003f4:	00000013          	nop
ffffffe0002003f8:	02813083          	ld	ra,40(sp)
ffffffe0002003fc:	02013403          	ld	s0,32(sp)
ffffffe000200400:	03010113          	addi	sp,sp,48
ffffffe000200404:	00008067          	ret

ffffffe000200408 <mm_init>:

void mm_init(void) {
ffffffe000200408:	ff010113          	addi	sp,sp,-16
ffffffe00020040c:	00113423          	sd	ra,8(sp)
ffffffe000200410:	00813023          	sd	s0,0(sp)
ffffffe000200414:	01010413          	addi	s0,sp,16
    printk("...mm_init start!\n");
ffffffe000200418:	00003517          	auipc	a0,0x3
ffffffe00020041c:	be850513          	addi	a0,a0,-1048 # ffffffe000203000 <_srodata>
ffffffe000200420:	080020ef          	jal	ra,ffffffe0002024a0 <printk>
    kfreerange(_ekernel, (char *)(PHY_END+PA2VA_OFFSET));  // CHANGE TO VM_END
ffffffe000200424:	c0100793          	li	a5,-1023
ffffffe000200428:	01b79593          	slli	a1,a5,0x1b
ffffffe00020042c:	00009517          	auipc	a0,0x9
ffffffe000200430:	bd450513          	addi	a0,a0,-1068 # ffffffe000209000 <_ebss>
ffffffe000200434:	f59ff0ef          	jal	ra,ffffffe00020038c <kfreerange>
    printk("...mm_init done!\n");
ffffffe000200438:	00003517          	auipc	a0,0x3
ffffffe00020043c:	be050513          	addi	a0,a0,-1056 # ffffffe000203018 <_srodata+0x18>
ffffffe000200440:	060020ef          	jal	ra,ffffffe0002024a0 <printk>
}
ffffffe000200444:	00000013          	nop
ffffffe000200448:	00813083          	ld	ra,8(sp)
ffffffe00020044c:	00013403          	ld	s0,0(sp)
ffffffe000200450:	01010113          	addi	sp,sp,16
ffffffe000200454:	00008067          	ret

ffffffe000200458 <task_init>:

struct task_struct *idle;           // idle process
struct task_struct *current;        // 指向当前运行线程的 task_struct
struct task_struct *task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
ffffffe000200458:	fe010113          	addi	sp,sp,-32
ffffffe00020045c:	00113c23          	sd	ra,24(sp)
ffffffe000200460:	00813823          	sd	s0,16(sp)
ffffffe000200464:	02010413          	addi	s0,sp,32
    srand(2024);
ffffffe000200468:	7e800513          	li	a0,2024
ffffffe00020046c:	0b4020ef          	jal	ra,ffffffe000202520 <srand>

    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
ffffffe000200470:	e41ff0ef          	jal	ra,ffffffe0002002b0 <kalloc>
ffffffe000200474:	00050713          	mv	a4,a0
ffffffe000200478:	00006797          	auipc	a5,0x6
ffffffe00020047c:	b9078793          	addi	a5,a5,-1136 # ffffffe000206008 <idle>
ffffffe000200480:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe000200484:	00006797          	auipc	a5,0x6
ffffffe000200488:	b8478793          	addi	a5,a5,-1148 # ffffffe000206008 <idle>
ffffffe00020048c:	0007b783          	ld	a5,0(a5)
ffffffe000200490:	0007b023          	sd	zero,0(a5)
    // 3. 由于 idle 不参与调度，可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe000200494:	00006797          	auipc	a5,0x6
ffffffe000200498:	b7478793          	addi	a5,a5,-1164 # ffffffe000206008 <idle>
ffffffe00020049c:	0007b783          	ld	a5,0(a5)
ffffffe0002004a0:	0007b423          	sd	zero,8(a5)
    idle->priority = 0;
ffffffe0002004a4:	00006797          	auipc	a5,0x6
ffffffe0002004a8:	b6478793          	addi	a5,a5,-1180 # ffffffe000206008 <idle>
ffffffe0002004ac:	0007b783          	ld	a5,0(a5)
ffffffe0002004b0:	0007b823          	sd	zero,16(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe0002004b4:	00006797          	auipc	a5,0x6
ffffffe0002004b8:	b5478793          	addi	a5,a5,-1196 # ffffffe000206008 <idle>
ffffffe0002004bc:	0007b783          	ld	a5,0(a5)
ffffffe0002004c0:	0007bc23          	sd	zero,24(a5)

    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe0002004c4:	00006797          	auipc	a5,0x6
ffffffe0002004c8:	b4478793          	addi	a5,a5,-1212 # ffffffe000206008 <idle>
ffffffe0002004cc:	0007b703          	ld	a4,0(a5)
ffffffe0002004d0:	00006797          	auipc	a5,0x6
ffffffe0002004d4:	b4078793          	addi	a5,a5,-1216 # ffffffe000206010 <current>
ffffffe0002004d8:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe0002004dc:	00006797          	auipc	a5,0x6
ffffffe0002004e0:	b2c78793          	addi	a5,a5,-1236 # ffffffe000206008 <idle>
ffffffe0002004e4:	0007b703          	ld	a4,0(a5)
ffffffe0002004e8:	00006797          	auipc	a5,0x6
ffffffe0002004ec:	b3878793          	addi	a5,a5,-1224 # ffffffe000206020 <task>
ffffffe0002004f0:	00e7b023          	sd	a4,0(a5)

    /* YOUR CODE HERE */

    // 1. 参考 idle 的设置，为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    for (int i = 1; i < NR_TASKS; i++){
ffffffe0002004f4:	00100793          	li	a5,1
ffffffe0002004f8:	fef42623          	sw	a5,-20(s0)
ffffffe0002004fc:	0940006f          	j	ffffffe000200590 <task_init+0x138>
        struct task_struct *ptask = (struct task_struct*)kalloc();
ffffffe000200500:	db1ff0ef          	jal	ra,ffffffe0002002b0 <kalloc>
ffffffe000200504:	fea43023          	sd	a0,-32(s0)
        // 2. 其中每个线程的 state 为 TASK_RUNNING, 此外，counter 和 priority 进行如下赋值：
        //     - counter  = 0;
        //     - priority = rand() 产生的随机数（控制范围在 [PRIORITY_MIN, PRIORITY_MAX] 之间）
        ptask->state = TASK_RUNNING;
ffffffe000200508:	fe043783          	ld	a5,-32(s0)
ffffffe00020050c:	0007b023          	sd	zero,0(a5)
        ptask->counter = 0;
ffffffe000200510:	fe043783          	ld	a5,-32(s0)
ffffffe000200514:	0007b423          	sd	zero,8(a5)
        ptask->priority = (uint64_t)rand() % (PRIORITY_MAX - PRIORITY_MIN + 1) + PRIORITY_MIN;
ffffffe000200518:	04c020ef          	jal	ra,ffffffe000202564 <rand>
ffffffe00020051c:	00050793          	mv	a5,a0
ffffffe000200520:	00078713          	mv	a4,a5
ffffffe000200524:	00a00793          	li	a5,10
ffffffe000200528:	02f777b3          	remu	a5,a4,a5
ffffffe00020052c:	00178713          	addi	a4,a5,1
ffffffe000200530:	fe043783          	ld	a5,-32(s0)
ffffffe000200534:	00e7b823          	sd	a4,16(a5)
        // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 thread_struct 中的 ra 和 sp
        //     - ra 设置为 __dummy（见 4.2.2）的地址
        //     - sp 设置为该线程申请的物理页的高地址
        ptask->pid = i;
ffffffe000200538:	fec42703          	lw	a4,-20(s0)
ffffffe00020053c:	fe043783          	ld	a5,-32(s0)
ffffffe000200540:	00e7bc23          	sd	a4,24(a5)
        ptask->thread.ra = (uint64_t)__dummy;
ffffffe000200544:	00000717          	auipc	a4,0x0
ffffffe000200548:	c7870713          	addi	a4,a4,-904 # ffffffe0002001bc <__dummy>
ffffffe00020054c:	fe043783          	ld	a5,-32(s0)
ffffffe000200550:	02e7b023          	sd	a4,32(a5)
        ptask->thread.sp = (uint64_t)ptask + PGSIZE;
ffffffe000200554:	fe043703          	ld	a4,-32(s0)
ffffffe000200558:	000017b7          	lui	a5,0x1
ffffffe00020055c:	00f70733          	add	a4,a4,a5
ffffffe000200560:	fe043783          	ld	a5,-32(s0)
ffffffe000200564:	02e7b423          	sd	a4,40(a5) # 1028 <PGSIZE+0x28>
        task[i] = ptask;
ffffffe000200568:	00006717          	auipc	a4,0x6
ffffffe00020056c:	ab870713          	addi	a4,a4,-1352 # ffffffe000206020 <task>
ffffffe000200570:	fec42783          	lw	a5,-20(s0)
ffffffe000200574:	00379793          	slli	a5,a5,0x3
ffffffe000200578:	00f707b3          	add	a5,a4,a5
ffffffe00020057c:	fe043703          	ld	a4,-32(s0)
ffffffe000200580:	00e7b023          	sd	a4,0(a5)
    for (int i = 1; i < NR_TASKS; i++){
ffffffe000200584:	fec42783          	lw	a5,-20(s0)
ffffffe000200588:	0017879b          	addiw	a5,a5,1
ffffffe00020058c:	fef42623          	sw	a5,-20(s0)
ffffffe000200590:	fec42783          	lw	a5,-20(s0)
ffffffe000200594:	0007871b          	sext.w	a4,a5
ffffffe000200598:	01f00793          	li	a5,31
ffffffe00020059c:	f6e7d2e3          	bge	a5,a4,ffffffe000200500 <task_init+0xa8>
    }
    /* YOUR CODE HERE */

    printk("...task_init done!\n");
ffffffe0002005a0:	00003517          	auipc	a0,0x3
ffffffe0002005a4:	a9050513          	addi	a0,a0,-1392 # ffffffe000203030 <_srodata+0x30>
ffffffe0002005a8:	6f9010ef          	jal	ra,ffffffe0002024a0 <printk>
}
ffffffe0002005ac:	00000013          	nop
ffffffe0002005b0:	01813083          	ld	ra,24(sp)
ffffffe0002005b4:	01013403          	ld	s0,16(sp)
ffffffe0002005b8:	02010113          	addi	sp,sp,32
ffffffe0002005bc:	00008067          	ret

ffffffe0002005c0 <dummy>:
int tasks_output_index = 0;
char expected_output[] = "2222222222111111133334222222222211111113";
#include "sbi.h"
#endif

void dummy() {
ffffffe0002005c0:	fd010113          	addi	sp,sp,-48
ffffffe0002005c4:	02113423          	sd	ra,40(sp)
ffffffe0002005c8:	02813023          	sd	s0,32(sp)
ffffffe0002005cc:	03010413          	addi	s0,sp,48
    uint64_t MOD = 1000000007;
ffffffe0002005d0:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe0002005d4:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <PHY_SIZE+0x339aca07>
ffffffe0002005d8:	fcf43c23          	sd	a5,-40(s0)
    uint64_t auto_inc_local_var = 0;
ffffffe0002005dc:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1;
ffffffe0002005e0:	fff00793          	li	a5,-1
ffffffe0002005e4:	fef42223          	sw	a5,-28(s0)
    while (1) {
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe0002005e8:	fe442783          	lw	a5,-28(s0)
ffffffe0002005ec:	0007871b          	sext.w	a4,a5
ffffffe0002005f0:	fff00793          	li	a5,-1
ffffffe0002005f4:	00f70e63          	beq	a4,a5,ffffffe000200610 <dummy+0x50>
ffffffe0002005f8:	00006797          	auipc	a5,0x6
ffffffe0002005fc:	a1878793          	addi	a5,a5,-1512 # ffffffe000206010 <current>
ffffffe000200600:	0007b783          	ld	a5,0(a5)
ffffffe000200604:	0087b703          	ld	a4,8(a5)
ffffffe000200608:	fe442783          	lw	a5,-28(s0)
ffffffe00020060c:	fcf70ee3          	beq	a4,a5,ffffffe0002005e8 <dummy+0x28>
ffffffe000200610:	00006797          	auipc	a5,0x6
ffffffe000200614:	a0078793          	addi	a5,a5,-1536 # ffffffe000206010 <current>
ffffffe000200618:	0007b783          	ld	a5,0(a5)
ffffffe00020061c:	0087b783          	ld	a5,8(a5)
ffffffe000200620:	fc0784e3          	beqz	a5,ffffffe0002005e8 <dummy+0x28>
            if (current->counter == 1) {
ffffffe000200624:	00006797          	auipc	a5,0x6
ffffffe000200628:	9ec78793          	addi	a5,a5,-1556 # ffffffe000206010 <current>
ffffffe00020062c:	0007b783          	ld	a5,0(a5)
ffffffe000200630:	0087b703          	ld	a4,8(a5)
ffffffe000200634:	00100793          	li	a5,1
ffffffe000200638:	00f71e63          	bne	a4,a5,ffffffe000200654 <dummy+0x94>
                --(current->counter);   // forced the counter to be zero if this thread is going to be scheduled
ffffffe00020063c:	00006797          	auipc	a5,0x6
ffffffe000200640:	9d478793          	addi	a5,a5,-1580 # ffffffe000206010 <current>
ffffffe000200644:	0007b783          	ld	a5,0(a5)
ffffffe000200648:	0087b703          	ld	a4,8(a5)
ffffffe00020064c:	fff70713          	addi	a4,a4,-1
ffffffe000200650:	00e7b423          	sd	a4,8(a5)
            }                           // in case that the new counter is also 1, leading the information not printed.
            last_counter = current->counter;
ffffffe000200654:	00006797          	auipc	a5,0x6
ffffffe000200658:	9bc78793          	addi	a5,a5,-1604 # ffffffe000206010 <current>
ffffffe00020065c:	0007b783          	ld	a5,0(a5)
ffffffe000200660:	0087b783          	ld	a5,8(a5)
ffffffe000200664:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = (auto_inc_local_var + 1) % MOD;
ffffffe000200668:	fe843783          	ld	a5,-24(s0)
ffffffe00020066c:	00178713          	addi	a4,a5,1
ffffffe000200670:	fd843783          	ld	a5,-40(s0)
ffffffe000200674:	02f777b3          	remu	a5,a4,a5
ffffffe000200678:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var);
ffffffe00020067c:	00006797          	auipc	a5,0x6
ffffffe000200680:	99478793          	addi	a5,a5,-1644 # ffffffe000206010 <current>
ffffffe000200684:	0007b783          	ld	a5,0(a5)
ffffffe000200688:	0187b783          	ld	a5,24(a5)
ffffffe00020068c:	fe843603          	ld	a2,-24(s0)
ffffffe000200690:	00078593          	mv	a1,a5
ffffffe000200694:	00003517          	auipc	a0,0x3
ffffffe000200698:	9b450513          	addi	a0,a0,-1612 # ffffffe000203048 <_srodata+0x48>
ffffffe00020069c:	605010ef          	jal	ra,ffffffe0002024a0 <printk>
        if ((last_counter == -1 || current->counter != last_counter) && current->counter > 0) {
ffffffe0002006a0:	f49ff06f          	j	ffffffe0002005e8 <dummy+0x28>

ffffffe0002006a4 <switch_to>:
            #endif
        }
    }
}

void switch_to(struct task_struct *next) {
ffffffe0002006a4:	fd010113          	addi	sp,sp,-48
ffffffe0002006a8:	02113423          	sd	ra,40(sp)
ffffffe0002006ac:	02813023          	sd	s0,32(sp)
ffffffe0002006b0:	03010413          	addi	s0,sp,48
ffffffe0002006b4:	fca43c23          	sd	a0,-40(s0)
    if(current == next) {
ffffffe0002006b8:	00006797          	auipc	a5,0x6
ffffffe0002006bc:	95878793          	addi	a5,a5,-1704 # ffffffe000206010 <current>
ffffffe0002006c0:	0007b783          	ld	a5,0(a5)
ffffffe0002006c4:	fd843703          	ld	a4,-40(s0)
ffffffe0002006c8:	06f70c63          	beq	a4,a5,ffffffe000200740 <switch_to+0x9c>
        return;
    }else{
        printk("switch_to: %d -> %d\n", current->pid, next->pid);
ffffffe0002006cc:	00006797          	auipc	a5,0x6
ffffffe0002006d0:	94478793          	addi	a5,a5,-1724 # ffffffe000206010 <current>
ffffffe0002006d4:	0007b783          	ld	a5,0(a5)
ffffffe0002006d8:	0187b703          	ld	a4,24(a5)
ffffffe0002006dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002006e0:	0187b783          	ld	a5,24(a5)
ffffffe0002006e4:	00078613          	mv	a2,a5
ffffffe0002006e8:	00070593          	mv	a1,a4
ffffffe0002006ec:	00003517          	auipc	a0,0x3
ffffffe0002006f0:	98c50513          	addi	a0,a0,-1652 # ffffffe000203078 <_srodata+0x78>
ffffffe0002006f4:	5ad010ef          	jal	ra,ffffffe0002024a0 <printk>
        struct task_struct *prev = current;
ffffffe0002006f8:	00006797          	auipc	a5,0x6
ffffffe0002006fc:	91878793          	addi	a5,a5,-1768 # ffffffe000206010 <current>
ffffffe000200700:	0007b783          	ld	a5,0(a5)
ffffffe000200704:	fef43423          	sd	a5,-24(s0)
        current = next;
ffffffe000200708:	00006797          	auipc	a5,0x6
ffffffe00020070c:	90878793          	addi	a5,a5,-1784 # ffffffe000206010 <current>
ffffffe000200710:	fd843703          	ld	a4,-40(s0)
ffffffe000200714:	00e7b023          	sd	a4,0(a5)
        printk("switch ing\n");
ffffffe000200718:	00003517          	auipc	a0,0x3
ffffffe00020071c:	97850513          	addi	a0,a0,-1672 # ffffffe000203090 <_srodata+0x90>
ffffffe000200720:	581010ef          	jal	ra,ffffffe0002024a0 <printk>
        __switch_to(prev, next);
ffffffe000200724:	fd843583          	ld	a1,-40(s0)
ffffffe000200728:	fe843503          	ld	a0,-24(s0)
ffffffe00020072c:	aa1ff0ef          	jal	ra,ffffffe0002001cc <__switch_to>
        printk("switch done\n");
ffffffe000200730:	00003517          	auipc	a0,0x3
ffffffe000200734:	97050513          	addi	a0,a0,-1680 # ffffffe0002030a0 <_srodata+0xa0>
ffffffe000200738:	569010ef          	jal	ra,ffffffe0002024a0 <printk>
ffffffe00020073c:	0080006f          	j	ffffffe000200744 <switch_to+0xa0>
        return;
ffffffe000200740:	00000013          	nop
    }
}
ffffffe000200744:	02813083          	ld	ra,40(sp)
ffffffe000200748:	02013403          	ld	s0,32(sp)
ffffffe00020074c:	03010113          	addi	sp,sp,48
ffffffe000200750:	00008067          	ret

ffffffe000200754 <do_timer>:

void do_timer() {
ffffffe000200754:	ff010113          	addi	sp,sp,-16
ffffffe000200758:	00113423          	sd	ra,8(sp)
ffffffe00020075c:	00813023          	sd	s0,0(sp)
ffffffe000200760:	01010413          	addi	s0,sp,16
    // 1. 如果当前线程是 idle 线程或当前线程时间片耗尽则直接进行调度
    // 2. 否则对当前线程的运行剩余时间减 1，若剩余时间仍然大于 0 则直接返回，否则进行调度
    printk("do_timer: current->pid = %d\n", current->pid);
ffffffe000200764:	00006797          	auipc	a5,0x6
ffffffe000200768:	8ac78793          	addi	a5,a5,-1876 # ffffffe000206010 <current>
ffffffe00020076c:	0007b783          	ld	a5,0(a5)
ffffffe000200770:	0187b783          	ld	a5,24(a5)
ffffffe000200774:	00078593          	mv	a1,a5
ffffffe000200778:	00003517          	auipc	a0,0x3
ffffffe00020077c:	93850513          	addi	a0,a0,-1736 # ffffffe0002030b0 <_srodata+0xb0>
ffffffe000200780:	521010ef          	jal	ra,ffffffe0002024a0 <printk>
    // YOUR CODE HERE
    if (current == idle || current->counter == 0) {
ffffffe000200784:	00006797          	auipc	a5,0x6
ffffffe000200788:	88c78793          	addi	a5,a5,-1908 # ffffffe000206010 <current>
ffffffe00020078c:	0007b703          	ld	a4,0(a5)
ffffffe000200790:	00006797          	auipc	a5,0x6
ffffffe000200794:	87878793          	addi	a5,a5,-1928 # ffffffe000206008 <idle>
ffffffe000200798:	0007b783          	ld	a5,0(a5)
ffffffe00020079c:	00f70c63          	beq	a4,a5,ffffffe0002007b4 <do_timer+0x60>
ffffffe0002007a0:	00006797          	auipc	a5,0x6
ffffffe0002007a4:	87078793          	addi	a5,a5,-1936 # ffffffe000206010 <current>
ffffffe0002007a8:	0007b783          	ld	a5,0(a5)
ffffffe0002007ac:	0087b783          	ld	a5,8(a5)
ffffffe0002007b0:	00079c63          	bnez	a5,ffffffe0002007c8 <do_timer+0x74>
        printk("do_timer: schedule\n");
ffffffe0002007b4:	00003517          	auipc	a0,0x3
ffffffe0002007b8:	91c50513          	addi	a0,a0,-1764 # ffffffe0002030d0 <_srodata+0xd0>
ffffffe0002007bc:	4e5010ef          	jal	ra,ffffffe0002024a0 <printk>
        schedule();
ffffffe0002007c0:	058000ef          	jal	ra,ffffffe000200818 <schedule>
        if (current->counter == 0) {
            printk("do_timer: schedule2\n");
            schedule();
        }
    }
}
ffffffe0002007c4:	0400006f          	j	ffffffe000200804 <do_timer+0xb0>
        current->counter --;
ffffffe0002007c8:	00006797          	auipc	a5,0x6
ffffffe0002007cc:	84878793          	addi	a5,a5,-1976 # ffffffe000206010 <current>
ffffffe0002007d0:	0007b783          	ld	a5,0(a5)
ffffffe0002007d4:	0087b703          	ld	a4,8(a5)
ffffffe0002007d8:	fff70713          	addi	a4,a4,-1
ffffffe0002007dc:	00e7b423          	sd	a4,8(a5)
        if (current->counter == 0) {
ffffffe0002007e0:	00006797          	auipc	a5,0x6
ffffffe0002007e4:	83078793          	addi	a5,a5,-2000 # ffffffe000206010 <current>
ffffffe0002007e8:	0007b783          	ld	a5,0(a5)
ffffffe0002007ec:	0087b783          	ld	a5,8(a5)
ffffffe0002007f0:	00079a63          	bnez	a5,ffffffe000200804 <do_timer+0xb0>
            printk("do_timer: schedule2\n");
ffffffe0002007f4:	00003517          	auipc	a0,0x3
ffffffe0002007f8:	8f450513          	addi	a0,a0,-1804 # ffffffe0002030e8 <_srodata+0xe8>
ffffffe0002007fc:	4a5010ef          	jal	ra,ffffffe0002024a0 <printk>
            schedule();
ffffffe000200800:	018000ef          	jal	ra,ffffffe000200818 <schedule>
}
ffffffe000200804:	00000013          	nop
ffffffe000200808:	00813083          	ld	ra,8(sp)
ffffffe00020080c:	00013403          	ld	s0,0(sp)
ffffffe000200810:	01010113          	addi	sp,sp,16
ffffffe000200814:	00008067          	ret

ffffffe000200818 <schedule>:

void schedule() {
ffffffe000200818:	fe010113          	addi	sp,sp,-32
ffffffe00020081c:	00113c23          	sd	ra,24(sp)
ffffffe000200820:	00813823          	sd	s0,16(sp)
ffffffe000200824:	02010413          	addi	s0,sp,32
    // YOUR CODE HERE
    int maxCounter = -1;
ffffffe000200828:	fff00793          	li	a5,-1
ffffffe00020082c:	fef42623          	sw	a5,-20(s0)
    int index = -1;
ffffffe000200830:	fff00793          	li	a5,-1
ffffffe000200834:	fef42423          	sw	a5,-24(s0)
    for (int i = 1; i < NR_TASKS; ++i) {
ffffffe000200838:	00100793          	li	a5,1
ffffffe00020083c:	fef42223          	sw	a5,-28(s0)
ffffffe000200840:	0dc0006f          	j	ffffffe00020091c <schedule+0x104>
        printk("schedule: %d -> %d\n", task[i]->pid, task[i] -> counter);
ffffffe000200844:	00005717          	auipc	a4,0x5
ffffffe000200848:	7dc70713          	addi	a4,a4,2012 # ffffffe000206020 <task>
ffffffe00020084c:	fe442783          	lw	a5,-28(s0)
ffffffe000200850:	00379793          	slli	a5,a5,0x3
ffffffe000200854:	00f707b3          	add	a5,a4,a5
ffffffe000200858:	0007b783          	ld	a5,0(a5)
ffffffe00020085c:	0187b683          	ld	a3,24(a5)
ffffffe000200860:	00005717          	auipc	a4,0x5
ffffffe000200864:	7c070713          	addi	a4,a4,1984 # ffffffe000206020 <task>
ffffffe000200868:	fe442783          	lw	a5,-28(s0)
ffffffe00020086c:	00379793          	slli	a5,a5,0x3
ffffffe000200870:	00f707b3          	add	a5,a4,a5
ffffffe000200874:	0007b783          	ld	a5,0(a5)
ffffffe000200878:	0087b783          	ld	a5,8(a5)
ffffffe00020087c:	00078613          	mv	a2,a5
ffffffe000200880:	00068593          	mv	a1,a3
ffffffe000200884:	00003517          	auipc	a0,0x3
ffffffe000200888:	87c50513          	addi	a0,a0,-1924 # ffffffe000203100 <_srodata+0x100>
ffffffe00020088c:	415010ef          	jal	ra,ffffffe0002024a0 <printk>
        if (task[i]->state == TASK_RUNNING && (int)task[i]->counter > maxCounter) {
ffffffe000200890:	00005717          	auipc	a4,0x5
ffffffe000200894:	79070713          	addi	a4,a4,1936 # ffffffe000206020 <task>
ffffffe000200898:	fe442783          	lw	a5,-28(s0)
ffffffe00020089c:	00379793          	slli	a5,a5,0x3
ffffffe0002008a0:	00f707b3          	add	a5,a4,a5
ffffffe0002008a4:	0007b783          	ld	a5,0(a5)
ffffffe0002008a8:	0007b783          	ld	a5,0(a5)
ffffffe0002008ac:	06079263          	bnez	a5,ffffffe000200910 <schedule+0xf8>
ffffffe0002008b0:	00005717          	auipc	a4,0x5
ffffffe0002008b4:	77070713          	addi	a4,a4,1904 # ffffffe000206020 <task>
ffffffe0002008b8:	fe442783          	lw	a5,-28(s0)
ffffffe0002008bc:	00379793          	slli	a5,a5,0x3
ffffffe0002008c0:	00f707b3          	add	a5,a4,a5
ffffffe0002008c4:	0007b783          	ld	a5,0(a5)
ffffffe0002008c8:	0087b783          	ld	a5,8(a5)
ffffffe0002008cc:	0007871b          	sext.w	a4,a5
ffffffe0002008d0:	fec42783          	lw	a5,-20(s0)
ffffffe0002008d4:	0007879b          	sext.w	a5,a5
ffffffe0002008d8:	02e7dc63          	bge	a5,a4,ffffffe000200910 <schedule+0xf8>
            printk("mamba\n");
ffffffe0002008dc:	00003517          	auipc	a0,0x3
ffffffe0002008e0:	83c50513          	addi	a0,a0,-1988 # ffffffe000203118 <_srodata+0x118>
ffffffe0002008e4:	3bd010ef          	jal	ra,ffffffe0002024a0 <printk>
            maxCounter = task[i]->counter;
ffffffe0002008e8:	00005717          	auipc	a4,0x5
ffffffe0002008ec:	73870713          	addi	a4,a4,1848 # ffffffe000206020 <task>
ffffffe0002008f0:	fe442783          	lw	a5,-28(s0)
ffffffe0002008f4:	00379793          	slli	a5,a5,0x3
ffffffe0002008f8:	00f707b3          	add	a5,a4,a5
ffffffe0002008fc:	0007b783          	ld	a5,0(a5)
ffffffe000200900:	0087b783          	ld	a5,8(a5)
ffffffe000200904:	fef42623          	sw	a5,-20(s0)
            index = i;
ffffffe000200908:	fe442783          	lw	a5,-28(s0)
ffffffe00020090c:	fef42423          	sw	a5,-24(s0)
    for (int i = 1; i < NR_TASKS; ++i) {
ffffffe000200910:	fe442783          	lw	a5,-28(s0)
ffffffe000200914:	0017879b          	addiw	a5,a5,1
ffffffe000200918:	fef42223          	sw	a5,-28(s0)
ffffffe00020091c:	fe442783          	lw	a5,-28(s0)
ffffffe000200920:	0007871b          	sext.w	a4,a5
ffffffe000200924:	01f00793          	li	a5,31
ffffffe000200928:	f0e7dee3          	bge	a5,a4,ffffffe000200844 <schedule+0x2c>
        }
    }

    if (maxCounter == 0) {
ffffffe00020092c:	fec42783          	lw	a5,-20(s0)
ffffffe000200930:	0007879b          	sext.w	a5,a5
ffffffe000200934:	0c079c63          	bnez	a5,ffffffe000200a0c <schedule+0x1f4>
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe000200938:	00100793          	li	a5,1
ffffffe00020093c:	fef42023          	sw	a5,-32(s0)
ffffffe000200940:	0b40006f          	j	ffffffe0002009f4 <schedule+0x1dc>
            if (task[i]->state == TASK_RUNNING) {
ffffffe000200944:	00005717          	auipc	a4,0x5
ffffffe000200948:	6dc70713          	addi	a4,a4,1756 # ffffffe000206020 <task>
ffffffe00020094c:	fe042783          	lw	a5,-32(s0)
ffffffe000200950:	00379793          	slli	a5,a5,0x3
ffffffe000200954:	00f707b3          	add	a5,a4,a5
ffffffe000200958:	0007b783          	ld	a5,0(a5)
ffffffe00020095c:	0007b783          	ld	a5,0(a5)
ffffffe000200960:	02079e63          	bnez	a5,ffffffe00020099c <schedule+0x184>
                task[i]->counter = task[i]->priority;
ffffffe000200964:	00005717          	auipc	a4,0x5
ffffffe000200968:	6bc70713          	addi	a4,a4,1724 # ffffffe000206020 <task>
ffffffe00020096c:	fe042783          	lw	a5,-32(s0)
ffffffe000200970:	00379793          	slli	a5,a5,0x3
ffffffe000200974:	00f707b3          	add	a5,a4,a5
ffffffe000200978:	0007b703          	ld	a4,0(a5)
ffffffe00020097c:	00005697          	auipc	a3,0x5
ffffffe000200980:	6a468693          	addi	a3,a3,1700 # ffffffe000206020 <task>
ffffffe000200984:	fe042783          	lw	a5,-32(s0)
ffffffe000200988:	00379793          	slli	a5,a5,0x3
ffffffe00020098c:	00f687b3          	add	a5,a3,a5
ffffffe000200990:	0007b783          	ld	a5,0(a5)
ffffffe000200994:	01073703          	ld	a4,16(a4)
ffffffe000200998:	00e7b423          	sd	a4,8(a5)
            }
            printk("schedule2: %d -> %d\n", task[i]->pid, task[i] -> counter);
ffffffe00020099c:	00005717          	auipc	a4,0x5
ffffffe0002009a0:	68470713          	addi	a4,a4,1668 # ffffffe000206020 <task>
ffffffe0002009a4:	fe042783          	lw	a5,-32(s0)
ffffffe0002009a8:	00379793          	slli	a5,a5,0x3
ffffffe0002009ac:	00f707b3          	add	a5,a4,a5
ffffffe0002009b0:	0007b783          	ld	a5,0(a5)
ffffffe0002009b4:	0187b683          	ld	a3,24(a5)
ffffffe0002009b8:	00005717          	auipc	a4,0x5
ffffffe0002009bc:	66870713          	addi	a4,a4,1640 # ffffffe000206020 <task>
ffffffe0002009c0:	fe042783          	lw	a5,-32(s0)
ffffffe0002009c4:	00379793          	slli	a5,a5,0x3
ffffffe0002009c8:	00f707b3          	add	a5,a4,a5
ffffffe0002009cc:	0007b783          	ld	a5,0(a5)
ffffffe0002009d0:	0087b783          	ld	a5,8(a5)
ffffffe0002009d4:	00078613          	mv	a2,a5
ffffffe0002009d8:	00068593          	mv	a1,a3
ffffffe0002009dc:	00002517          	auipc	a0,0x2
ffffffe0002009e0:	74450513          	addi	a0,a0,1860 # ffffffe000203120 <_srodata+0x120>
ffffffe0002009e4:	2bd010ef          	jal	ra,ffffffe0002024a0 <printk>
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe0002009e8:	fe042783          	lw	a5,-32(s0)
ffffffe0002009ec:	0017879b          	addiw	a5,a5,1
ffffffe0002009f0:	fef42023          	sw	a5,-32(s0)
ffffffe0002009f4:	fe042783          	lw	a5,-32(s0)
ffffffe0002009f8:	0007871b          	sext.w	a4,a5
ffffffe0002009fc:	01f00793          	li	a5,31
ffffffe000200a00:	f4e7d2e3          	bge	a5,a4,ffffffe000200944 <schedule+0x12c>
        }
        schedule();
ffffffe000200a04:	e15ff0ef          	jal	ra,ffffffe000200818 <schedule>
    } else {
        switch_to(task[index]);
    }
ffffffe000200a08:	0240006f          	j	ffffffe000200a2c <schedule+0x214>
        switch_to(task[index]);
ffffffe000200a0c:	00005717          	auipc	a4,0x5
ffffffe000200a10:	61470713          	addi	a4,a4,1556 # ffffffe000206020 <task>
ffffffe000200a14:	fe842783          	lw	a5,-24(s0)
ffffffe000200a18:	00379793          	slli	a5,a5,0x3
ffffffe000200a1c:	00f707b3          	add	a5,a4,a5
ffffffe000200a20:	0007b783          	ld	a5,0(a5)
ffffffe000200a24:	00078513          	mv	a0,a5
ffffffe000200a28:	c7dff0ef          	jal	ra,ffffffe0002006a4 <switch_to>
ffffffe000200a2c:	00000013          	nop
ffffffe000200a30:	01813083          	ld	ra,24(sp)
ffffffe000200a34:	01013403          	ld	s0,16(sp)
ffffffe000200a38:	02010113          	addi	sp,sp,32
ffffffe000200a3c:	00008067          	ret

ffffffe000200a40 <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
ffffffe000200a40:	f8010113          	addi	sp,sp,-128
ffffffe000200a44:	06813c23          	sd	s0,120(sp)
ffffffe000200a48:	06913823          	sd	s1,112(sp)
ffffffe000200a4c:	07213423          	sd	s2,104(sp)
ffffffe000200a50:	07313023          	sd	s3,96(sp)
ffffffe000200a54:	08010413          	addi	s0,sp,128
ffffffe000200a58:	faa43c23          	sd	a0,-72(s0)
ffffffe000200a5c:	fab43823          	sd	a1,-80(s0)
ffffffe000200a60:	fac43423          	sd	a2,-88(s0)
ffffffe000200a64:	fad43023          	sd	a3,-96(s0)
ffffffe000200a68:	f8e43c23          	sd	a4,-104(s0)
ffffffe000200a6c:	f8f43823          	sd	a5,-112(s0)
ffffffe000200a70:	f9043423          	sd	a6,-120(s0)
ffffffe000200a74:	f9143023          	sd	a7,-128(s0)
    
    struct sbiret sbiRet;

    asm volatile (
ffffffe000200a78:	fb843e03          	ld	t3,-72(s0)
ffffffe000200a7c:	fb043e83          	ld	t4,-80(s0)
ffffffe000200a80:	fa843f03          	ld	t5,-88(s0)
ffffffe000200a84:	fa043f83          	ld	t6,-96(s0)
ffffffe000200a88:	f9843283          	ld	t0,-104(s0)
ffffffe000200a8c:	f9043483          	ld	s1,-112(s0)
ffffffe000200a90:	f8843903          	ld	s2,-120(s0)
ffffffe000200a94:	f8043983          	ld	s3,-128(s0)
ffffffe000200a98:	01c008b3          	add	a7,zero,t3
ffffffe000200a9c:	01d00833          	add	a6,zero,t4
ffffffe000200aa0:	01e00533          	add	a0,zero,t5
ffffffe000200aa4:	01f005b3          	add	a1,zero,t6
ffffffe000200aa8:	00500633          	add	a2,zero,t0
ffffffe000200aac:	009006b3          	add	a3,zero,s1
ffffffe000200ab0:	01200733          	add	a4,zero,s2
ffffffe000200ab4:	013007b3          	add	a5,zero,s3
ffffffe000200ab8:	00000073          	ecall
ffffffe000200abc:	00050e93          	mv	t4,a0
ffffffe000200ac0:	00058e13          	mv	t3,a1
ffffffe000200ac4:	fdd43023          	sd	t4,-64(s0)
ffffffe000200ac8:	fdc43423          	sd	t3,-56(s0)
        : "=r"(sbiRet.error), "=r"(sbiRet.value)
        : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );

    return sbiRet;
ffffffe000200acc:	fc043783          	ld	a5,-64(s0)
ffffffe000200ad0:	fcf43823          	sd	a5,-48(s0)
ffffffe000200ad4:	fc843783          	ld	a5,-56(s0)
ffffffe000200ad8:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200adc:	fd043703          	ld	a4,-48(s0)
ffffffe000200ae0:	fd843783          	ld	a5,-40(s0)
ffffffe000200ae4:	00070313          	mv	t1,a4
ffffffe000200ae8:	00078393          	mv	t2,a5
ffffffe000200aec:	00030713          	mv	a4,t1
ffffffe000200af0:	00038793          	mv	a5,t2
}
ffffffe000200af4:	00070513          	mv	a0,a4
ffffffe000200af8:	00078593          	mv	a1,a5
ffffffe000200afc:	07813403          	ld	s0,120(sp)
ffffffe000200b00:	07013483          	ld	s1,112(sp)
ffffffe000200b04:	06813903          	ld	s2,104(sp)
ffffffe000200b08:	06013983          	ld	s3,96(sp)
ffffffe000200b0c:	08010113          	addi	sp,sp,128
ffffffe000200b10:	00008067          	ret

ffffffe000200b14 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
ffffffe000200b14:	fc010113          	addi	sp,sp,-64
ffffffe000200b18:	02113c23          	sd	ra,56(sp)
ffffffe000200b1c:	02813823          	sd	s0,48(sp)
ffffffe000200b20:	03213423          	sd	s2,40(sp)
ffffffe000200b24:	03313023          	sd	s3,32(sp)
ffffffe000200b28:	04010413          	addi	s0,sp,64
ffffffe000200b2c:	00050793          	mv	a5,a0
ffffffe000200b30:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
ffffffe000200b34:	fcf44603          	lbu	a2,-49(s0)
ffffffe000200b38:	00000893          	li	a7,0
ffffffe000200b3c:	00000813          	li	a6,0
ffffffe000200b40:	00000793          	li	a5,0
ffffffe000200b44:	00000713          	li	a4,0
ffffffe000200b48:	00000693          	li	a3,0
ffffffe000200b4c:	00200593          	li	a1,2
ffffffe000200b50:	44424537          	lui	a0,0x44424
ffffffe000200b54:	34e50513          	addi	a0,a0,846 # 4442434e <PHY_SIZE+0x3c42434e>
ffffffe000200b58:	ee9ff0ef          	jal	ra,ffffffe000200a40 <sbi_ecall>
ffffffe000200b5c:	00050713          	mv	a4,a0
ffffffe000200b60:	00058793          	mv	a5,a1
ffffffe000200b64:	fce43823          	sd	a4,-48(s0)
ffffffe000200b68:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200b6c:	fd043703          	ld	a4,-48(s0)
ffffffe000200b70:	fd843783          	ld	a5,-40(s0)
ffffffe000200b74:	00070913          	mv	s2,a4
ffffffe000200b78:	00078993          	mv	s3,a5
ffffffe000200b7c:	00090713          	mv	a4,s2
ffffffe000200b80:	00098793          	mv	a5,s3
}
ffffffe000200b84:	00070513          	mv	a0,a4
ffffffe000200b88:	00078593          	mv	a1,a5
ffffffe000200b8c:	03813083          	ld	ra,56(sp)
ffffffe000200b90:	03013403          	ld	s0,48(sp)
ffffffe000200b94:	02813903          	ld	s2,40(sp)
ffffffe000200b98:	02013983          	ld	s3,32(sp)
ffffffe000200b9c:	04010113          	addi	sp,sp,64
ffffffe000200ba0:	00008067          	ret

ffffffe000200ba4 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
ffffffe000200ba4:	fc010113          	addi	sp,sp,-64
ffffffe000200ba8:	02113c23          	sd	ra,56(sp)
ffffffe000200bac:	02813823          	sd	s0,48(sp)
ffffffe000200bb0:	03213423          	sd	s2,40(sp)
ffffffe000200bb4:	03313023          	sd	s3,32(sp)
ffffffe000200bb8:	04010413          	addi	s0,sp,64
ffffffe000200bbc:	00050793          	mv	a5,a0
ffffffe000200bc0:	00058713          	mv	a4,a1
ffffffe000200bc4:	fcf42623          	sw	a5,-52(s0)
ffffffe000200bc8:	00070793          	mv	a5,a4
ffffffe000200bcc:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
ffffffe000200bd0:	fcc46603          	lwu	a2,-52(s0)
ffffffe000200bd4:	fc846683          	lwu	a3,-56(s0)
ffffffe000200bd8:	00000893          	li	a7,0
ffffffe000200bdc:	00000813          	li	a6,0
ffffffe000200be0:	00000793          	li	a5,0
ffffffe000200be4:	00000713          	li	a4,0
ffffffe000200be8:	00000593          	li	a1,0
ffffffe000200bec:	53525537          	lui	a0,0x53525
ffffffe000200bf0:	35450513          	addi	a0,a0,852 # 53525354 <PHY_SIZE+0x4b525354>
ffffffe000200bf4:	e4dff0ef          	jal	ra,ffffffe000200a40 <sbi_ecall>
ffffffe000200bf8:	00050713          	mv	a4,a0
ffffffe000200bfc:	00058793          	mv	a5,a1
ffffffe000200c00:	fce43823          	sd	a4,-48(s0)
ffffffe000200c04:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200c08:	fd043703          	ld	a4,-48(s0)
ffffffe000200c0c:	fd843783          	ld	a5,-40(s0)
ffffffe000200c10:	00070913          	mv	s2,a4
ffffffe000200c14:	00078993          	mv	s3,a5
ffffffe000200c18:	00090713          	mv	a4,s2
ffffffe000200c1c:	00098793          	mv	a5,s3
}
ffffffe000200c20:	00070513          	mv	a0,a4
ffffffe000200c24:	00078593          	mv	a1,a5
ffffffe000200c28:	03813083          	ld	ra,56(sp)
ffffffe000200c2c:	03013403          	ld	s0,48(sp)
ffffffe000200c30:	02813903          	ld	s2,40(sp)
ffffffe000200c34:	02013983          	ld	s3,32(sp)
ffffffe000200c38:	04010113          	addi	sp,sp,64
ffffffe000200c3c:	00008067          	ret

ffffffe000200c40 <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
ffffffe000200c40:	fc010113          	addi	sp,sp,-64
ffffffe000200c44:	02113c23          	sd	ra,56(sp)
ffffffe000200c48:	02813823          	sd	s0,48(sp)
ffffffe000200c4c:	03213423          	sd	s2,40(sp)
ffffffe000200c50:	03313023          	sd	s3,32(sp)
ffffffe000200c54:	04010413          	addi	s0,sp,64
ffffffe000200c58:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
ffffffe000200c5c:	00000893          	li	a7,0
ffffffe000200c60:	00000813          	li	a6,0
ffffffe000200c64:	00000793          	li	a5,0
ffffffe000200c68:	00000713          	li	a4,0
ffffffe000200c6c:	00000693          	li	a3,0
ffffffe000200c70:	fc843603          	ld	a2,-56(s0)
ffffffe000200c74:	00000593          	li	a1,0
ffffffe000200c78:	54495537          	lui	a0,0x54495
ffffffe000200c7c:	d4550513          	addi	a0,a0,-699 # 54494d45 <PHY_SIZE+0x4c494d45>
ffffffe000200c80:	dc1ff0ef          	jal	ra,ffffffe000200a40 <sbi_ecall>
ffffffe000200c84:	00050713          	mv	a4,a0
ffffffe000200c88:	00058793          	mv	a5,a1
ffffffe000200c8c:	fce43823          	sd	a4,-48(s0)
ffffffe000200c90:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200c94:	fd043703          	ld	a4,-48(s0)
ffffffe000200c98:	fd843783          	ld	a5,-40(s0)
ffffffe000200c9c:	00070913          	mv	s2,a4
ffffffe000200ca0:	00078993          	mv	s3,a5
ffffffe000200ca4:	00090713          	mv	a4,s2
ffffffe000200ca8:	00098793          	mv	a5,s3
ffffffe000200cac:	00070513          	mv	a0,a4
ffffffe000200cb0:	00078593          	mv	a1,a5
ffffffe000200cb4:	03813083          	ld	ra,56(sp)
ffffffe000200cb8:	03013403          	ld	s0,48(sp)
ffffffe000200cbc:	02813903          	ld	s2,40(sp)
ffffffe000200cc0:	02013983          	ld	s3,32(sp)
ffffffe000200cc4:	04010113          	addi	sp,sp,64
ffffffe000200cc8:	00008067          	ret

ffffffe000200ccc <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "defs.h"
#include "proc.h"
void trap_handler(uint64_t scause, uint64_t sepc) {
ffffffe000200ccc:	fc010113          	addi	sp,sp,-64
ffffffe000200cd0:	02113c23          	sd	ra,56(sp)
ffffffe000200cd4:	02813823          	sd	s0,48(sp)
ffffffe000200cd8:	04010413          	addi	s0,sp,64
ffffffe000200cdc:	fca43423          	sd	a0,-56(s0)
ffffffe000200ce0:	fcb43023          	sd	a1,-64(s0)
    // 通过 `scause` 判断 trap 类型
    if(scause == 0x8000000000000005){
ffffffe000200ce4:	fc843703          	ld	a4,-56(s0)
ffffffe000200ce8:	fff00793          	li	a5,-1
ffffffe000200cec:	03f79793          	slli	a5,a5,0x3f
ffffffe000200cf0:	00578793          	addi	a5,a5,5
ffffffe000200cf4:	04f71c63          	bne	a4,a5,ffffffe000200d4c <trap_handler+0x80>
        LogRED("Timer Interrupt");
ffffffe000200cf8:	00002697          	auipc	a3,0x2
ffffffe000200cfc:	59068693          	addi	a3,a3,1424 # ffffffe000203288 <__func__.0>
ffffffe000200d00:	00900613          	li	a2,9
ffffffe000200d04:	00002597          	auipc	a1,0x2
ffffffe000200d08:	43458593          	addi	a1,a1,1076 # ffffffe000203138 <_srodata+0x138>
ffffffe000200d0c:	00002517          	auipc	a0,0x2
ffffffe000200d10:	43450513          	addi	a0,a0,1076 # ffffffe000203140 <_srodata+0x140>
ffffffe000200d14:	78c010ef          	jal	ra,ffffffe0002024a0 <printk>
        LogPURPLE("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
ffffffe000200d18:	fc043783          	ld	a5,-64(s0)
ffffffe000200d1c:	fc843703          	ld	a4,-56(s0)
ffffffe000200d20:	00002697          	auipc	a3,0x2
ffffffe000200d24:	56868693          	addi	a3,a3,1384 # ffffffe000203288 <__func__.0>
ffffffe000200d28:	00a00613          	li	a2,10
ffffffe000200d2c:	00002597          	auipc	a1,0x2
ffffffe000200d30:	40c58593          	addi	a1,a1,1036 # ffffffe000203138 <_srodata+0x138>
ffffffe000200d34:	00002517          	auipc	a0,0x2
ffffffe000200d38:	43450513          	addi	a0,a0,1076 # ffffffe000203168 <_srodata+0x168>
ffffffe000200d3c:	764010ef          	jal	ra,ffffffe0002024a0 <printk>
        clock_set_next_event();
ffffffe000200d40:	d28ff0ef          	jal	ra,ffffffe000200268 <clock_set_next_event>
        do_timer();
ffffffe000200d44:	a11ff0ef          	jal	ra,ffffffe000200754 <do_timer>
ffffffe000200d48:	1680006f          	j	ffffffe000200eb0 <trap_handler+0x1e4>
    }else if(scause == 0x000000000000000c){
ffffffe000200d4c:	fc843703          	ld	a4,-56(s0)
ffffffe000200d50:	00c00793          	li	a5,12
ffffffe000200d54:	0af71863          	bne	a4,a5,ffffffe000200e04 <trap_handler+0x138>
        LogRED("Instruction Page Fault");
ffffffe000200d58:	00002697          	auipc	a3,0x2
ffffffe000200d5c:	53068693          	addi	a3,a3,1328 # ffffffe000203288 <__func__.0>
ffffffe000200d60:	00e00613          	li	a2,14
ffffffe000200d64:	00002597          	auipc	a1,0x2
ffffffe000200d68:	3d458593          	addi	a1,a1,980 # ffffffe000203138 <_srodata+0x138>
ffffffe000200d6c:	00002517          	auipc	a0,0x2
ffffffe000200d70:	44450513          	addi	a0,a0,1092 # ffffffe0002031b0 <_srodata+0x1b0>
ffffffe000200d74:	72c010ef          	jal	ra,ffffffe0002024a0 <printk>
        LogPURPLE("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
ffffffe000200d78:	fc043783          	ld	a5,-64(s0)
ffffffe000200d7c:	fc843703          	ld	a4,-56(s0)
ffffffe000200d80:	00002697          	auipc	a3,0x2
ffffffe000200d84:	50868693          	addi	a3,a3,1288 # ffffffe000203288 <__func__.0>
ffffffe000200d88:	00f00613          	li	a2,15
ffffffe000200d8c:	00002597          	auipc	a1,0x2
ffffffe000200d90:	3ac58593          	addi	a1,a1,940 # ffffffe000203138 <_srodata+0x138>
ffffffe000200d94:	00002517          	auipc	a0,0x2
ffffffe000200d98:	3d450513          	addi	a0,a0,980 # ffffffe000203168 <_srodata+0x168>
ffffffe000200d9c:	704010ef          	jal	ra,ffffffe0002024a0 <printk>
        if(sepc < VM_START){
ffffffe000200da0:	fc043703          	ld	a4,-64(s0)
ffffffe000200da4:	fff00793          	li	a5,-1
ffffffe000200da8:	02579793          	slli	a5,a5,0x25
ffffffe000200dac:	10f77263          	bgeu	a4,a5,ffffffe000200eb0 <trap_handler+0x1e4>
            LogGREEN("[Physical Address: 0x%llx] -> [Virtual Address: 0x%llx]", sepc, sepc + 0xffffffdf80000000);
ffffffe000200db0:	fc043703          	ld	a4,-64(s0)
ffffffe000200db4:	fbf00793          	li	a5,-65
ffffffe000200db8:	01f79793          	slli	a5,a5,0x1f
ffffffe000200dbc:	00f707b3          	add	a5,a4,a5
ffffffe000200dc0:	fc043703          	ld	a4,-64(s0)
ffffffe000200dc4:	00002697          	auipc	a3,0x2
ffffffe000200dc8:	4c468693          	addi	a3,a3,1220 # ffffffe000203288 <__func__.0>
ffffffe000200dcc:	01100613          	li	a2,17
ffffffe000200dd0:	00002597          	auipc	a1,0x2
ffffffe000200dd4:	36858593          	addi	a1,a1,872 # ffffffe000203138 <_srodata+0x138>
ffffffe000200dd8:	00002517          	auipc	a0,0x2
ffffffe000200ddc:	40850513          	addi	a0,a0,1032 # ffffffe0002031e0 <_srodata+0x1e0>
ffffffe000200de0:	6c0010ef          	jal	ra,ffffffe0002024a0 <printk>
            csr_write(sepc, sepc + 0xffffffdf80000000);
ffffffe000200de4:	fc043703          	ld	a4,-64(s0)
ffffffe000200de8:	fbf00793          	li	a5,-65
ffffffe000200dec:	01f79793          	slli	a5,a5,0x1f
ffffffe000200df0:	00f707b3          	add	a5,a4,a5
ffffffe000200df4:	fef43423          	sd	a5,-24(s0)
ffffffe000200df8:	fe843783          	ld	a5,-24(s0)
ffffffe000200dfc:	14179073          	csrw	sepc,a5

            return;
ffffffe000200e00:	0e00006f          	j	ffffffe000200ee0 <trap_handler+0x214>
        }
    }else if(scause == 0x000000000000000f){
ffffffe000200e04:	fc843703          	ld	a4,-56(s0)
ffffffe000200e08:	00f00793          	li	a5,15
ffffffe000200e0c:	04f71863          	bne	a4,a5,ffffffe000200e5c <trap_handler+0x190>
        LogRED("Store/AMO Page Fault");
ffffffe000200e10:	00002697          	auipc	a3,0x2
ffffffe000200e14:	47868693          	addi	a3,a3,1144 # ffffffe000203288 <__func__.0>
ffffffe000200e18:	01700613          	li	a2,23
ffffffe000200e1c:	00002597          	auipc	a1,0x2
ffffffe000200e20:	31c58593          	addi	a1,a1,796 # ffffffe000203138 <_srodata+0x138>
ffffffe000200e24:	00002517          	auipc	a0,0x2
ffffffe000200e28:	40c50513          	addi	a0,a0,1036 # ffffffe000203230 <_srodata+0x230>
ffffffe000200e2c:	674010ef          	jal	ra,ffffffe0002024a0 <printk>
        LogPURPLE("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
ffffffe000200e30:	fc043783          	ld	a5,-64(s0)
ffffffe000200e34:	fc843703          	ld	a4,-56(s0)
ffffffe000200e38:	00002697          	auipc	a3,0x2
ffffffe000200e3c:	45068693          	addi	a3,a3,1104 # ffffffe000203288 <__func__.0>
ffffffe000200e40:	01800613          	li	a2,24
ffffffe000200e44:	00002597          	auipc	a1,0x2
ffffffe000200e48:	2f458593          	addi	a1,a1,756 # ffffffe000203138 <_srodata+0x138>
ffffffe000200e4c:	00002517          	auipc	a0,0x2
ffffffe000200e50:	31c50513          	addi	a0,a0,796 # ffffffe000203168 <_srodata+0x168>
ffffffe000200e54:	64c010ef          	jal	ra,ffffffe0002024a0 <printk>
ffffffe000200e58:	0580006f          	j	ffffffe000200eb0 <trap_handler+0x1e4>
    }else if(scause == 0x000000000000000d){
ffffffe000200e5c:	fc843703          	ld	a4,-56(s0)
ffffffe000200e60:	00d00793          	li	a5,13
ffffffe000200e64:	04f71663          	bne	a4,a5,ffffffe000200eb0 <trap_handler+0x1e4>
        LogRED("Load Page Fault");
ffffffe000200e68:	00002697          	auipc	a3,0x2
ffffffe000200e6c:	42068693          	addi	a3,a3,1056 # ffffffe000203288 <__func__.0>
ffffffe000200e70:	01a00613          	li	a2,26
ffffffe000200e74:	00002597          	auipc	a1,0x2
ffffffe000200e78:	2c458593          	addi	a1,a1,708 # ffffffe000203138 <_srodata+0x138>
ffffffe000200e7c:	00002517          	auipc	a0,0x2
ffffffe000200e80:	3e450513          	addi	a0,a0,996 # ffffffe000203260 <_srodata+0x260>
ffffffe000200e84:	61c010ef          	jal	ra,ffffffe0002024a0 <printk>
        LogPURPLE("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
ffffffe000200e88:	fc043783          	ld	a5,-64(s0)
ffffffe000200e8c:	fc843703          	ld	a4,-56(s0)
ffffffe000200e90:	00002697          	auipc	a3,0x2
ffffffe000200e94:	3f868693          	addi	a3,a3,1016 # ffffffe000203288 <__func__.0>
ffffffe000200e98:	01b00613          	li	a2,27
ffffffe000200e9c:	00002597          	auipc	a1,0x2
ffffffe000200ea0:	29c58593          	addi	a1,a1,668 # ffffffe000203138 <_srodata+0x138>
ffffffe000200ea4:	00002517          	auipc	a0,0x2
ffffffe000200ea8:	2c450513          	addi	a0,a0,708 # ffffffe000203168 <_srodata+0x168>
ffffffe000200eac:	5f4010ef          	jal	ra,ffffffe0002024a0 <printk>
    }
    if (scause & 0x8000000000000000) {
ffffffe000200eb0:	fc843783          	ld	a5,-56(s0)
ffffffe000200eb4:	0007dc63          	bgez	a5,ffffffe000200ecc <trap_handler+0x200>
        csr_write(sepc, sepc);
ffffffe000200eb8:	fc043783          	ld	a5,-64(s0)
ffffffe000200ebc:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200ec0:	fd843783          	ld	a5,-40(s0)
ffffffe000200ec4:	14179073          	csrw	sepc,a5
ffffffe000200ec8:	0180006f          	j	ffffffe000200ee0 <trap_handler+0x214>
    } else {
        csr_write(sepc, sepc + 4);
ffffffe000200ecc:	fc043783          	ld	a5,-64(s0)
ffffffe000200ed0:	00478793          	addi	a5,a5,4
ffffffe000200ed4:	fef43023          	sd	a5,-32(s0)
ffffffe000200ed8:	fe043783          	ld	a5,-32(s0)
ffffffe000200edc:	14179073          	csrw	sepc,a5
    }
    // LogGREEN("trap_handler: scause: 0x%llx, sepc: 0x%llx\n", scause, sepc);
}
ffffffe000200ee0:	03813083          	ld	ra,56(sp)
ffffffe000200ee4:	03013403          	ld	s0,48(sp)
ffffffe000200ee8:	04010113          	addi	sp,sp,64
ffffffe000200eec:	00008067          	ret

ffffffe000200ef0 <csr_change>:

void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
ffffffe000200ef0:	fc010113          	addi	sp,sp,-64
ffffffe000200ef4:	02813c23          	sd	s0,56(sp)
ffffffe000200ef8:	04010413          	addi	s0,sp,64
ffffffe000200efc:	fca43c23          	sd	a0,-40(s0)
ffffffe000200f00:	fcb43823          	sd	a1,-48(s0)
ffffffe000200f04:	fcc43423          	sd	a2,-56(s0)
    // printk("sscratch: 0x%lx\n", csr_read(sscratch));
    csr_write(sscratch, value);
ffffffe000200f08:	fc843783          	ld	a5,-56(s0)
ffffffe000200f0c:	fef43423          	sd	a5,-24(s0)
ffffffe000200f10:	fe843783          	ld	a5,-24(s0)
ffffffe000200f14:	14079073          	csrw	sscratch,a5
    // printk("sstatus: 0x%lx\n", csr_read(sstatus));
    // printk("sscratch: 0x%lx\n", csr_read(sscratch));
ffffffe000200f18:	00000013          	nop
ffffffe000200f1c:	03813403          	ld	s0,56(sp)
ffffffe000200f20:	04010113          	addi	sp,sp,64
ffffffe000200f24:	00008067          	ret

ffffffe000200f28 <setup_vm>:
#include "printk.h"

/* early_pgtbl: 用于 setup_vm 进行 1GiB 的映射 */
uint64_t early_pgtbl[512] __attribute__((__aligned__(0x1000)));

void setup_vm() {
ffffffe000200f28:	fd010113          	addi	sp,sp,-48
ffffffe000200f2c:	02113423          	sd	ra,40(sp)
ffffffe000200f30:	02813023          	sd	s0,32(sp)
ffffffe000200f34:	03010413          	addi	s0,sp,48
     *     high bit 可以忽略
     *     中间 9 bit 作为 early_pgtbl 的 index
     *     低 30 bit 作为页内偏移，这里注意到 30 = 9 + 9 + 12，即我们只使用根页表，根页表的每个 entry 都对应 1GiB 的区域
     * 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    **/
    memset(early_pgtbl, 0x0, PGSIZE);
ffffffe000200f38:	00001637          	lui	a2,0x1
ffffffe000200f3c:	00000593          	li	a1,0
ffffffe000200f40:	00006517          	auipc	a0,0x6
ffffffe000200f44:	0c050513          	addi	a0,a0,192 # ffffffe000207000 <early_pgtbl>
ffffffe000200f48:	678010ef          	jal	ra,ffffffe0002025c0 <memset>
    uint64_t va = VM_START;
ffffffe000200f4c:	fff00793          	li	a5,-1
ffffffe000200f50:	02579793          	slli	a5,a5,0x25
ffffffe000200f54:	fef43423          	sd	a5,-24(s0)
    uint64_t pa = PHY_START;
ffffffe000200f58:	00100793          	li	a5,1
ffffffe000200f5c:	01f79793          	slli	a5,a5,0x1f
ffffffe000200f60:	fef43023          	sd	a5,-32(s0)
    LogGREEN("early_pgtbl: 0x%llx\n", early_pgtbl);
ffffffe000200f64:	00006717          	auipc	a4,0x6
ffffffe000200f68:	09c70713          	addi	a4,a4,156 # ffffffe000207000 <early_pgtbl>
ffffffe000200f6c:	00002697          	auipc	a3,0x2
ffffffe000200f70:	46468693          	addi	a3,a3,1124 # ffffffe0002033d0 <__func__.2>
ffffffe000200f74:	01300613          	li	a2,19
ffffffe000200f78:	00002597          	auipc	a1,0x2
ffffffe000200f7c:	32058593          	addi	a1,a1,800 # ffffffe000203298 <__func__.0+0x10>
ffffffe000200f80:	00002517          	auipc	a0,0x2
ffffffe000200f84:	32050513          	addi	a0,a0,800 # ffffffe0002032a0 <__func__.0+0x18>
ffffffe000200f88:	518010ef          	jal	ra,ffffffe0002024a0 <printk>
    uint64_t index = (pa >> 30) & 0x1ff;
ffffffe000200f8c:	fe043783          	ld	a5,-32(s0)
ffffffe000200f90:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200f94:	1ff7f793          	andi	a5,a5,511
ffffffe000200f98:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe000200f9c:	fd843583          	ld	a1,-40(s0)
ffffffe000200fa0:	00002517          	auipc	a0,0x2
ffffffe000200fa4:	33050513          	addi	a0,a0,816 # ffffffe0002032d0 <__func__.0+0x48>
ffffffe000200fa8:	4f8010ef          	jal	ra,ffffffe0002024a0 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe000200fac:	fe043783          	ld	a5,-32(s0)
ffffffe000200fb0:	0027d713          	srli	a4,a5,0x2
ffffffe000200fb4:	040007b7          	lui	a5,0x4000
ffffffe000200fb8:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000200fbc:	01c79793          	slli	a5,a5,0x1c
ffffffe000200fc0:	00f777b3          	and	a5,a4,a5
ffffffe000200fc4:	00f7e713          	ori	a4,a5,15
ffffffe000200fc8:	00006697          	auipc	a3,0x6
ffffffe000200fcc:	03868693          	addi	a3,a3,56 # ffffffe000207000 <early_pgtbl>
ffffffe000200fd0:	fd843783          	ld	a5,-40(s0)
ffffffe000200fd4:	00379793          	slli	a5,a5,0x3
ffffffe000200fd8:	00f687b3          	add	a5,a3,a5
ffffffe000200fdc:	00e7b023          	sd	a4,0(a5)

    index = (va >> 30) & 0x1ff;
ffffffe000200fe0:	fe843783          	ld	a5,-24(s0)
ffffffe000200fe4:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200fe8:	1ff7f793          	andi	a5,a5,511
ffffffe000200fec:	fcf43c23          	sd	a5,-40(s0)
    printk("index: %d\n", index);
ffffffe000200ff0:	fd843583          	ld	a1,-40(s0)
ffffffe000200ff4:	00002517          	auipc	a0,0x2
ffffffe000200ff8:	2dc50513          	addi	a0,a0,732 # ffffffe0002032d0 <__func__.0+0x48>
ffffffe000200ffc:	4a4010ef          	jal	ra,ffffffe0002024a0 <printk>
    early_pgtbl[index] = ((pa & 0x00FFFFFFC0000000) >> 2)| PTE_V | PTE_R | PTE_W | PTE_X; // PPN2 + 10BITS
ffffffe000201000:	fe043783          	ld	a5,-32(s0)
ffffffe000201004:	0027d713          	srli	a4,a5,0x2
ffffffe000201008:	040007b7          	lui	a5,0x4000
ffffffe00020100c:	fff78793          	addi	a5,a5,-1 # 3ffffff <OPENSBI_SIZE+0x3dfffff>
ffffffe000201010:	01c79793          	slli	a5,a5,0x1c
ffffffe000201014:	00f777b3          	and	a5,a4,a5
ffffffe000201018:	00f7e713          	ori	a4,a5,15
ffffffe00020101c:	00006697          	auipc	a3,0x6
ffffffe000201020:	fe468693          	addi	a3,a3,-28 # ffffffe000207000 <early_pgtbl>
ffffffe000201024:	fd843783          	ld	a5,-40(s0)
ffffffe000201028:	00379793          	slli	a5,a5,0x3
ffffffe00020102c:	00f687b3          	add	a5,a3,a5
ffffffe000201030:	00e7b023          	sd	a4,0(a5)

    printk("setup_vm done...\n");
ffffffe000201034:	00002517          	auipc	a0,0x2
ffffffe000201038:	2ac50513          	addi	a0,a0,684 # ffffffe0002032e0 <__func__.0+0x58>
ffffffe00020103c:	464010ef          	jal	ra,ffffffe0002024a0 <printk>
}
ffffffe000201040:	00000013          	nop
ffffffe000201044:	02813083          	ld	ra,40(sp)
ffffffe000201048:	02013403          	ld	s0,32(sp)
ffffffe00020104c:	03010113          	addi	sp,sp,48
ffffffe000201050:	00008067          	ret

ffffffe000201054 <setup_vm_final>:
uint64_t swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

void setup_vm_final() {
ffffffe000201054:	fc010113          	addi	sp,sp,-64
ffffffe000201058:	02113c23          	sd	ra,56(sp)
ffffffe00020105c:	02813823          	sd	s0,48(sp)
ffffffe000201060:	04010413          	addi	s0,sp,64
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000201064:	00001637          	lui	a2,0x1
ffffffe000201068:	00000593          	li	a1,0
ffffffe00020106c:	00007517          	auipc	a0,0x7
ffffffe000201070:	f9450513          	addi	a0,a0,-108 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201074:	54c010ef          	jal	ra,ffffffe0002025c0 <memset>
    LogYELLOW("_stext: %p, _etext: %p, _srodata: %p, _erodata: %p, _sdata: %p, _edata: %p, _sbss: %p, _ebss: %p\n", _stext, _etext, _srodata, _erodata, _sdata, _edata, _sbss, _ebss);
ffffffe000201078:	00008797          	auipc	a5,0x8
ffffffe00020107c:	f8878793          	addi	a5,a5,-120 # ffffffe000209000 <_ebss>
ffffffe000201080:	00f13c23          	sd	a5,24(sp)
ffffffe000201084:	00004797          	auipc	a5,0x4
ffffffe000201088:	f7c78793          	addi	a5,a5,-132 # ffffffe000205000 <_sbss>
ffffffe00020108c:	00f13823          	sd	a5,16(sp)
ffffffe000201090:	00003797          	auipc	a5,0x3
ffffffe000201094:	f7878793          	addi	a5,a5,-136 # ffffffe000204008 <_edata>
ffffffe000201098:	00f13423          	sd	a5,8(sp)
ffffffe00020109c:	00003797          	auipc	a5,0x3
ffffffe0002010a0:	f6478793          	addi	a5,a5,-156 # ffffffe000204000 <TIMECLOCK>
ffffffe0002010a4:	00f13023          	sd	a5,0(sp)
ffffffe0002010a8:	00002897          	auipc	a7,0x2
ffffffe0002010ac:	46088893          	addi	a7,a7,1120 # ffffffe000203508 <_erodata>
ffffffe0002010b0:	00002817          	auipc	a6,0x2
ffffffe0002010b4:	f5080813          	addi	a6,a6,-176 # ffffffe000203000 <_srodata>
ffffffe0002010b8:	00001797          	auipc	a5,0x1
ffffffe0002010bc:	57878793          	addi	a5,a5,1400 # ffffffe000202630 <_etext>
ffffffe0002010c0:	fffff717          	auipc	a4,0xfffff
ffffffe0002010c4:	f4070713          	addi	a4,a4,-192 # ffffffe000200000 <_skernel>
ffffffe0002010c8:	00002697          	auipc	a3,0x2
ffffffe0002010cc:	31868693          	addi	a3,a3,792 # ffffffe0002033e0 <__func__.1>
ffffffe0002010d0:	02700613          	li	a2,39
ffffffe0002010d4:	00002597          	auipc	a1,0x2
ffffffe0002010d8:	1c458593          	addi	a1,a1,452 # ffffffe000203298 <__func__.0+0x10>
ffffffe0002010dc:	00002517          	auipc	a0,0x2
ffffffe0002010e0:	21c50513          	addi	a0,a0,540 # ffffffe0002032f8 <__func__.0+0x70>
ffffffe0002010e4:	3bc010ef          	jal	ra,ffffffe0002024a0 <printk>

    // No OpenSBI mapping required
    // mapping kernel text X|-|R|V
    create_mapping(swapper_pg_dir, _stext, _stext - PA2VA_OFFSET, _srodata - _stext, PTE_X | PTE_R | PTE_V);;
ffffffe0002010e8:	fffff597          	auipc	a1,0xfffff
ffffffe0002010ec:	f1858593          	addi	a1,a1,-232 # ffffffe000200000 <_skernel>
ffffffe0002010f0:	fffff717          	auipc	a4,0xfffff
ffffffe0002010f4:	f1070713          	addi	a4,a4,-240 # ffffffe000200000 <_skernel>
ffffffe0002010f8:	04100793          	li	a5,65
ffffffe0002010fc:	01f79793          	slli	a5,a5,0x1f
ffffffe000201100:	00f707b3          	add	a5,a4,a5
ffffffe000201104:	00078613          	mv	a2,a5
ffffffe000201108:	00002717          	auipc	a4,0x2
ffffffe00020110c:	ef870713          	addi	a4,a4,-264 # ffffffe000203000 <_srodata>
ffffffe000201110:	fffff797          	auipc	a5,0xfffff
ffffffe000201114:	ef078793          	addi	a5,a5,-272 # ffffffe000200000 <_skernel>
ffffffe000201118:	40f707b3          	sub	a5,a4,a5
ffffffe00020111c:	00b00713          	li	a4,11
ffffffe000201120:	00078693          	mv	a3,a5
ffffffe000201124:	00007517          	auipc	a0,0x7
ffffffe000201128:	edc50513          	addi	a0,a0,-292 # ffffffe000208000 <swapper_pg_dir>
ffffffe00020112c:	0ec000ef          	jal	ra,ffffffe000201218 <create_mapping>

    // mapping kernel rodata -|-|R|V
    create_mapping(swapper_pg_dir, _srodata, _srodata - PA2VA_OFFSET, _sdata - _srodata, PTE_R | PTE_V);
ffffffe000201130:	00002597          	auipc	a1,0x2
ffffffe000201134:	ed058593          	addi	a1,a1,-304 # ffffffe000203000 <_srodata>
ffffffe000201138:	00002717          	auipc	a4,0x2
ffffffe00020113c:	ec870713          	addi	a4,a4,-312 # ffffffe000203000 <_srodata>
ffffffe000201140:	04100793          	li	a5,65
ffffffe000201144:	01f79793          	slli	a5,a5,0x1f
ffffffe000201148:	00f707b3          	add	a5,a4,a5
ffffffe00020114c:	00078613          	mv	a2,a5
ffffffe000201150:	00003717          	auipc	a4,0x3
ffffffe000201154:	eb070713          	addi	a4,a4,-336 # ffffffe000204000 <TIMECLOCK>
ffffffe000201158:	00002797          	auipc	a5,0x2
ffffffe00020115c:	ea878793          	addi	a5,a5,-344 # ffffffe000203000 <_srodata>
ffffffe000201160:	40f707b3          	sub	a5,a4,a5
ffffffe000201164:	00300713          	li	a4,3
ffffffe000201168:	00078693          	mv	a3,a5
ffffffe00020116c:	00007517          	auipc	a0,0x7
ffffffe000201170:	e9450513          	addi	a0,a0,-364 # ffffffe000208000 <swapper_pg_dir>
ffffffe000201174:	0a4000ef          	jal	ra,ffffffe000201218 <create_mapping>

    // mapping other memory -|W|R|V
    create_mapping(swapper_pg_dir, _sdata, _sdata - PA2VA_OFFSET, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V);
ffffffe000201178:	00003597          	auipc	a1,0x3
ffffffe00020117c:	e8858593          	addi	a1,a1,-376 # ffffffe000204000 <TIMECLOCK>
ffffffe000201180:	00003717          	auipc	a4,0x3
ffffffe000201184:	e8070713          	addi	a4,a4,-384 # ffffffe000204000 <TIMECLOCK>
ffffffe000201188:	04100793          	li	a5,65
ffffffe00020118c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201190:	00f707b3          	add	a5,a4,a5
ffffffe000201194:	00078613          	mv	a2,a5
ffffffe000201198:	00003717          	auipc	a4,0x3
ffffffe00020119c:	e6870713          	addi	a4,a4,-408 # ffffffe000204000 <TIMECLOCK>
ffffffe0002011a0:	fffff797          	auipc	a5,0xfffff
ffffffe0002011a4:	e6078793          	addi	a5,a5,-416 # ffffffe000200000 <_skernel>
ffffffe0002011a8:	40f707b3          	sub	a5,a4,a5
ffffffe0002011ac:	08000737          	lui	a4,0x8000
ffffffe0002011b0:	40f707b3          	sub	a5,a4,a5
ffffffe0002011b4:	00700713          	li	a4,7
ffffffe0002011b8:	00078693          	mv	a3,a5
ffffffe0002011bc:	00007517          	auipc	a0,0x7
ffffffe0002011c0:	e4450513          	addi	a0,a0,-444 # ffffffe000208000 <swapper_pg_dir>
ffffffe0002011c4:	054000ef          	jal	ra,ffffffe000201218 <create_mapping>

    uint64_t _satp = ((((uint64_t)swapper_pg_dir - PA2VA_OFFSET) >> 12) | (uint64_t)0x8 << 60);
ffffffe0002011c8:	00007717          	auipc	a4,0x7
ffffffe0002011cc:	e3870713          	addi	a4,a4,-456 # ffffffe000208000 <swapper_pg_dir>
ffffffe0002011d0:	04100793          	li	a5,65
ffffffe0002011d4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002011d8:	00f707b3          	add	a5,a4,a5
ffffffe0002011dc:	00c7d713          	srli	a4,a5,0xc
ffffffe0002011e0:	fff00793          	li	a5,-1
ffffffe0002011e4:	03f79793          	slli	a5,a5,0x3f
ffffffe0002011e8:	00f767b3          	or	a5,a4,a5
ffffffe0002011ec:	fef43423          	sd	a5,-24(s0)

    // set satp with swapper_pg_dir
    csr_write(satp, _satp);
ffffffe0002011f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002011f4:	fef43023          	sd	a5,-32(s0)
ffffffe0002011f8:	fe043783          	ld	a5,-32(s0)
ffffffe0002011fc:	18079073          	csrw	satp,a5
    // *_erodata = 0x0;
    // LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);

    // YOUR CODE HERE
    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000201200:	12000073          	sfence.vma
    return;
ffffffe000201204:	00000013          	nop
}
ffffffe000201208:	03813083          	ld	ra,56(sp)
ffffffe00020120c:	03013403          	ld	s0,48(sp)
ffffffe000201210:	04010113          	addi	sp,sp,64
ffffffe000201214:	00008067          	ret

ffffffe000201218 <create_mapping>:


void create_mapping(uint64_t *pgtbl, uint64_t va, uint64_t pa, uint64_t sz, uint64_t perm) {
ffffffe000201218:	f7010113          	addi	sp,sp,-144
ffffffe00020121c:	08113423          	sd	ra,136(sp)
ffffffe000201220:	08813023          	sd	s0,128(sp)
ffffffe000201224:	09010413          	addi	s0,sp,144
ffffffe000201228:	faa43423          	sd	a0,-88(s0)
ffffffe00020122c:	fab43023          	sd	a1,-96(s0)
ffffffe000201230:	f8c43c23          	sd	a2,-104(s0)
ffffffe000201234:	f8d43823          	sd	a3,-112(s0)
ffffffe000201238:	f8e43423          	sd	a4,-120(s0)
     * 
     * 创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
     * 可以使用 V bit 来判断页表项是否存在
    **/
    // printk("Come into the create_mapping\n");
    LogBLUE("root: 0x%llx, [0x%llx, 0x%llx) -> [0x%llx, 0x%llx), perm: 0x%llx", pgtbl, pa, pa + sz, va, va + sz, perm);
ffffffe00020123c:	f9843703          	ld	a4,-104(s0)
ffffffe000201240:	f9043783          	ld	a5,-112(s0)
ffffffe000201244:	00f706b3          	add	a3,a4,a5
ffffffe000201248:	fa043703          	ld	a4,-96(s0)
ffffffe00020124c:	f9043783          	ld	a5,-112(s0)
ffffffe000201250:	00f707b3          	add	a5,a4,a5
ffffffe000201254:	f8843703          	ld	a4,-120(s0)
ffffffe000201258:	00e13423          	sd	a4,8(sp)
ffffffe00020125c:	00f13023          	sd	a5,0(sp)
ffffffe000201260:	fa043883          	ld	a7,-96(s0)
ffffffe000201264:	00068813          	mv	a6,a3
ffffffe000201268:	f9843783          	ld	a5,-104(s0)
ffffffe00020126c:	fa843703          	ld	a4,-88(s0)
ffffffe000201270:	00002697          	auipc	a3,0x2
ffffffe000201274:	18068693          	addi	a3,a3,384 # ffffffe0002033f0 <__func__.0>
ffffffe000201278:	05100613          	li	a2,81
ffffffe00020127c:	00002597          	auipc	a1,0x2
ffffffe000201280:	01c58593          	addi	a1,a1,28 # ffffffe000203298 <__func__.0+0x10>
ffffffe000201284:	00002517          	auipc	a0,0x2
ffffffe000201288:	0f450513          	addi	a0,a0,244 # ffffffe000203378 <__func__.0+0xf0>
ffffffe00020128c:	214010ef          	jal	ra,ffffffe0002024a0 <printk>
    uint64_t vlimit = va + sz;
ffffffe000201290:	fa043703          	ld	a4,-96(s0)
ffffffe000201294:	f9043783          	ld	a5,-112(s0)
ffffffe000201298:	00f707b3          	add	a5,a4,a5
ffffffe00020129c:	fcf43c23          	sd	a5,-40(s0)
    uint64_t *pgd, *pmd, *pte;
    pgd = pgtbl;
ffffffe0002012a0:	fa843783          	ld	a5,-88(s0)
ffffffe0002012a4:	fcf43823          	sd	a5,-48(s0)

    while(va < vlimit){
ffffffe0002012a8:	19c0006f          	j	ffffffe000201444 <create_mapping+0x22c>
        uint64_t pgd_entry = *(pgd + ((va >> 30) & 0x1ff));
ffffffe0002012ac:	fa043783          	ld	a5,-96(s0)
ffffffe0002012b0:	01e7d793          	srli	a5,a5,0x1e
ffffffe0002012b4:	1ff7f793          	andi	a5,a5,511
ffffffe0002012b8:	00379793          	slli	a5,a5,0x3
ffffffe0002012bc:	fd043703          	ld	a4,-48(s0)
ffffffe0002012c0:	00f707b3          	add	a5,a4,a5
ffffffe0002012c4:	0007b783          	ld	a5,0(a5)
ffffffe0002012c8:	fef43423          	sd	a5,-24(s0)
        if (!(pgd_entry & PTE_V)) {
ffffffe0002012cc:	fe843783          	ld	a5,-24(s0)
ffffffe0002012d0:	0017f793          	andi	a5,a5,1
ffffffe0002012d4:	06079063          	bnez	a5,ffffffe000201334 <create_mapping+0x11c>
            uint64_t ppmd = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppmd是PMD页表的物理地址
ffffffe0002012d8:	fd9fe0ef          	jal	ra,ffffffe0002002b0 <kalloc>
ffffffe0002012dc:	00050793          	mv	a5,a0
ffffffe0002012e0:	00078713          	mv	a4,a5
ffffffe0002012e4:	04100793          	li	a5,65
ffffffe0002012e8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002012ec:	00f707b3          	add	a5,a4,a5
ffffffe0002012f0:	fcf43423          	sd	a5,-56(s0)
            // LogBLUE("ppmd: 0x%llx", ppmd);
            *(pgd + ((va >> 30) & 0x1ff)) = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe0002012f4:	fc843783          	ld	a5,-56(s0)
ffffffe0002012f8:	00c7d793          	srli	a5,a5,0xc
ffffffe0002012fc:	00a79713          	slli	a4,a5,0xa
ffffffe000201300:	fa043783          	ld	a5,-96(s0)
ffffffe000201304:	01e7d793          	srli	a5,a5,0x1e
ffffffe000201308:	1ff7f793          	andi	a5,a5,511
ffffffe00020130c:	00379793          	slli	a5,a5,0x3
ffffffe000201310:	fd043683          	ld	a3,-48(s0)
ffffffe000201314:	00f687b3          	add	a5,a3,a5
ffffffe000201318:	00176713          	ori	a4,a4,1
ffffffe00020131c:	00e7b023          	sd	a4,0(a5)
            pgd_entry = ((uint64_t)ppmd >> 12) << 10 | PTE_V;
ffffffe000201320:	fc843783          	ld	a5,-56(s0)
ffffffe000201324:	00c7d793          	srli	a5,a5,0xc
ffffffe000201328:	00a79793          	slli	a5,a5,0xa
ffffffe00020132c:	0017e793          	ori	a5,a5,1
ffffffe000201330:	fef43423          	sd	a5,-24(s0)
        }
    
        pmd = (uint64_t*) (((pgd_entry >> 10) << 12) + PA2VA_OFFSET); // pmd此时是PMD页表的虚拟地址
ffffffe000201334:	fe843783          	ld	a5,-24(s0)
ffffffe000201338:	00a7d793          	srli	a5,a5,0xa
ffffffe00020133c:	00c79713          	slli	a4,a5,0xc
ffffffe000201340:	fbf00793          	li	a5,-65
ffffffe000201344:	01f79793          	slli	a5,a5,0x1f
ffffffe000201348:	00f707b3          	add	a5,a4,a5
ffffffe00020134c:	fcf43023          	sd	a5,-64(s0)
        uint64_t pmd_entry = *(pmd + ((va >> 21) & 0x1ff));
ffffffe000201350:	fa043783          	ld	a5,-96(s0)
ffffffe000201354:	0157d793          	srli	a5,a5,0x15
ffffffe000201358:	1ff7f793          	andi	a5,a5,511
ffffffe00020135c:	00379793          	slli	a5,a5,0x3
ffffffe000201360:	fc043703          	ld	a4,-64(s0)
ffffffe000201364:	00f707b3          	add	a5,a4,a5
ffffffe000201368:	0007b783          	ld	a5,0(a5)
ffffffe00020136c:	fef43023          	sd	a5,-32(s0)
        if (!(pmd_entry & PTE_V)) {
ffffffe000201370:	fe043783          	ld	a5,-32(s0)
ffffffe000201374:	0017f793          	andi	a5,a5,1
ffffffe000201378:	06079063          	bnez	a5,ffffffe0002013d8 <create_mapping+0x1c0>
            uint64_t ppte = (uint64_t)kalloc() - PA2VA_OFFSET;  // ppte是PTE页表的物理地址
ffffffe00020137c:	f35fe0ef          	jal	ra,ffffffe0002002b0 <kalloc>
ffffffe000201380:	00050793          	mv	a5,a0
ffffffe000201384:	00078713          	mv	a4,a5
ffffffe000201388:	04100793          	li	a5,65
ffffffe00020138c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201390:	00f707b3          	add	a5,a4,a5
ffffffe000201394:	faf43c23          	sd	a5,-72(s0)
            // LogBLUE("ppte: 0x%llx", ppte);
            *(pmd + ((va >> 21) & 0x1ff)) = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe000201398:	fb843783          	ld	a5,-72(s0)
ffffffe00020139c:	00c7d793          	srli	a5,a5,0xc
ffffffe0002013a0:	00a79713          	slli	a4,a5,0xa
ffffffe0002013a4:	fa043783          	ld	a5,-96(s0)
ffffffe0002013a8:	0157d793          	srli	a5,a5,0x15
ffffffe0002013ac:	1ff7f793          	andi	a5,a5,511
ffffffe0002013b0:	00379793          	slli	a5,a5,0x3
ffffffe0002013b4:	fc043683          	ld	a3,-64(s0)
ffffffe0002013b8:	00f687b3          	add	a5,a3,a5
ffffffe0002013bc:	00176713          	ori	a4,a4,1
ffffffe0002013c0:	00e7b023          	sd	a4,0(a5)
            pmd_entry = ((uint64_t)ppte >> 12) << 10 | PTE_V;
ffffffe0002013c4:	fb843783          	ld	a5,-72(s0)
ffffffe0002013c8:	00c7d793          	srli	a5,a5,0xc
ffffffe0002013cc:	00a79793          	slli	a5,a5,0xa
ffffffe0002013d0:	0017e793          	ori	a5,a5,1
ffffffe0002013d4:	fef43023          	sd	a5,-32(s0)
        }
        
        pte = (uint64_t*) (((pmd_entry >> 10) << 12) + PA2VA_OFFSET); // pte此时是PTE页表的虚拟地址
ffffffe0002013d8:	fe043783          	ld	a5,-32(s0)
ffffffe0002013dc:	00a7d793          	srli	a5,a5,0xa
ffffffe0002013e0:	00c79713          	slli	a4,a5,0xc
ffffffe0002013e4:	fbf00793          	li	a5,-65
ffffffe0002013e8:	01f79793          	slli	a5,a5,0x1f
ffffffe0002013ec:	00f707b3          	add	a5,a4,a5
ffffffe0002013f0:	faf43823          	sd	a5,-80(s0)
        *(pte + ((va >> 12) & 0x1ff)) = ((pa >> 12) << 10) | perm ;
ffffffe0002013f4:	f9843783          	ld	a5,-104(s0)
ffffffe0002013f8:	00c7d793          	srli	a5,a5,0xc
ffffffe0002013fc:	00a79693          	slli	a3,a5,0xa
ffffffe000201400:	fa043783          	ld	a5,-96(s0)
ffffffe000201404:	00c7d793          	srli	a5,a5,0xc
ffffffe000201408:	1ff7f793          	andi	a5,a5,511
ffffffe00020140c:	00379793          	slli	a5,a5,0x3
ffffffe000201410:	fb043703          	ld	a4,-80(s0)
ffffffe000201414:	00f707b3          	add	a5,a4,a5
ffffffe000201418:	f8843703          	ld	a4,-120(s0)
ffffffe00020141c:	00e6e733          	or	a4,a3,a4
ffffffe000201420:	00e7b023          	sd	a4,0(a5)


        // if(va <= 0xffffffe000209000)LogBLUE("va: 0x%llx, pa: 0x%llx, perm: 0x%llx", va, pa, perm);
        va += PGSIZE;
ffffffe000201424:	fa043703          	ld	a4,-96(s0)
ffffffe000201428:	000017b7          	lui	a5,0x1
ffffffe00020142c:	00f707b3          	add	a5,a4,a5
ffffffe000201430:	faf43023          	sd	a5,-96(s0)
        pa += PGSIZE;
ffffffe000201434:	f9843703          	ld	a4,-104(s0)
ffffffe000201438:	000017b7          	lui	a5,0x1
ffffffe00020143c:	00f707b3          	add	a5,a4,a5
ffffffe000201440:	f8f43c23          	sd	a5,-104(s0)
    while(va < vlimit){
ffffffe000201444:	fa043703          	ld	a4,-96(s0)
ffffffe000201448:	fd843783          	ld	a5,-40(s0)
ffffffe00020144c:	e6f760e3          	bltu	a4,a5,ffffffe0002012ac <create_mapping+0x94>
    }
}
ffffffe000201450:	00000013          	nop
ffffffe000201454:	00000013          	nop
ffffffe000201458:	08813083          	ld	ra,136(sp)
ffffffe00020145c:	08013403          	ld	s0,128(sp)
ffffffe000201460:	09010113          	addi	sp,sp,144
ffffffe000201464:	00008067          	ret

ffffffe000201468 <start_kernel>:
extern void test();

extern char _stext[], _srodata[], _sdata[], _sbss[];
extern char _etext[], _erodata[], _edata[], _ebss[];

int start_kernel() {
ffffffe000201468:	ff010113          	addi	sp,sp,-16
ffffffe00020146c:	00113423          	sd	ra,8(sp)
ffffffe000201470:	00813023          	sd	s0,0(sp)
ffffffe000201474:	01010413          	addi	s0,sp,16
    printk("2024");
ffffffe000201478:	00002517          	auipc	a0,0x2
ffffffe00020147c:	f8850513          	addi	a0,a0,-120 # ffffffe000203400 <__func__.0+0x10>
ffffffe000201480:	020010ef          	jal	ra,ffffffe0002024a0 <printk>
    printk(" ZJU Operating System\n");
ffffffe000201484:	00002517          	auipc	a0,0x2
ffffffe000201488:	f8450513          	addi	a0,a0,-124 # ffffffe000203408 <__func__.0+0x18>
ffffffe00020148c:	014010ef          	jal	ra,ffffffe0002024a0 <printk>
    LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);
ffffffe000201490:	fffff797          	auipc	a5,0xfffff
ffffffe000201494:	b7078793          	addi	a5,a5,-1168 # ffffffe000200000 <_skernel>
ffffffe000201498:	0007c783          	lbu	a5,0(a5)
ffffffe00020149c:	0007871b          	sext.w	a4,a5
ffffffe0002014a0:	00001797          	auipc	a5,0x1
ffffffe0002014a4:	19078793          	addi	a5,a5,400 # ffffffe000202630 <_etext>
ffffffe0002014a8:	0007c783          	lbu	a5,0(a5)
ffffffe0002014ac:	0007869b          	sext.w	a3,a5
ffffffe0002014b0:	00002797          	auipc	a5,0x2
ffffffe0002014b4:	b5078793          	addi	a5,a5,-1200 # ffffffe000203000 <_srodata>
ffffffe0002014b8:	0007c783          	lbu	a5,0(a5)
ffffffe0002014bc:	0007861b          	sext.w	a2,a5
ffffffe0002014c0:	00002797          	auipc	a5,0x2
ffffffe0002014c4:	04878793          	addi	a5,a5,72 # ffffffe000203508 <_erodata>
ffffffe0002014c8:	0007c783          	lbu	a5,0(a5)
ffffffe0002014cc:	0007879b          	sext.w	a5,a5
ffffffe0002014d0:	00078893          	mv	a7,a5
ffffffe0002014d4:	00060813          	mv	a6,a2
ffffffe0002014d8:	00068793          	mv	a5,a3
ffffffe0002014dc:	00002697          	auipc	a3,0x2
ffffffe0002014e0:	fac68693          	addi	a3,a3,-84 # ffffffe000203488 <__func__.0>
ffffffe0002014e4:	00b00613          	li	a2,11
ffffffe0002014e8:	00002597          	auipc	a1,0x2
ffffffe0002014ec:	f3858593          	addi	a1,a1,-200 # ffffffe000203420 <__func__.0+0x30>
ffffffe0002014f0:	00002517          	auipc	a0,0x2
ffffffe0002014f4:	f3850513          	addi	a0,a0,-200 # ffffffe000203428 <__func__.0+0x38>
ffffffe0002014f8:	7a9000ef          	jal	ra,ffffffe0002024a0 <printk>
    *_stext = 0x0;
ffffffe0002014fc:	fffff797          	auipc	a5,0xfffff
ffffffe000201500:	b0478793          	addi	a5,a5,-1276 # ffffffe000200000 <_skernel>
ffffffe000201504:	00078023          	sb	zero,0(a5)
    *_etext = 0x1;
ffffffe000201508:	00001797          	auipc	a5,0x1
ffffffe00020150c:	12878793          	addi	a5,a5,296 # ffffffe000202630 <_etext>
ffffffe000201510:	00100713          	li	a4,1
ffffffe000201514:	00e78023          	sb	a4,0(a5)
    *_srodata = 0x0;
ffffffe000201518:	00002797          	auipc	a5,0x2
ffffffe00020151c:	ae878793          	addi	a5,a5,-1304 # ffffffe000203000 <_srodata>
ffffffe000201520:	00078023          	sb	zero,0(a5)
    *_erodata = 0x1;
ffffffe000201524:	00002797          	auipc	a5,0x2
ffffffe000201528:	fe478793          	addi	a5,a5,-28 # ffffffe000203508 <_erodata>
ffffffe00020152c:	00100713          	li	a4,1
ffffffe000201530:	00e78023          	sb	a4,0(a5)
    LogDEEPGREEN("*_stext: 0x%llx, *_etext: 0x%llx, *_srodata: 0x%llx, *_erodata: 0x%llx", *_stext, *_etext, *_srodata, *_erodata);
ffffffe000201534:	fffff797          	auipc	a5,0xfffff
ffffffe000201538:	acc78793          	addi	a5,a5,-1332 # ffffffe000200000 <_skernel>
ffffffe00020153c:	0007c783          	lbu	a5,0(a5)
ffffffe000201540:	0007871b          	sext.w	a4,a5
ffffffe000201544:	00001797          	auipc	a5,0x1
ffffffe000201548:	0ec78793          	addi	a5,a5,236 # ffffffe000202630 <_etext>
ffffffe00020154c:	0007c783          	lbu	a5,0(a5)
ffffffe000201550:	0007869b          	sext.w	a3,a5
ffffffe000201554:	00002797          	auipc	a5,0x2
ffffffe000201558:	aac78793          	addi	a5,a5,-1364 # ffffffe000203000 <_srodata>
ffffffe00020155c:	0007c783          	lbu	a5,0(a5)
ffffffe000201560:	0007861b          	sext.w	a2,a5
ffffffe000201564:	00002797          	auipc	a5,0x2
ffffffe000201568:	fa478793          	addi	a5,a5,-92 # ffffffe000203508 <_erodata>
ffffffe00020156c:	0007c783          	lbu	a5,0(a5)
ffffffe000201570:	0007879b          	sext.w	a5,a5
ffffffe000201574:	00078893          	mv	a7,a5
ffffffe000201578:	00060813          	mv	a6,a2
ffffffe00020157c:	00068793          	mv	a5,a3
ffffffe000201580:	00002697          	auipc	a3,0x2
ffffffe000201584:	f0868693          	addi	a3,a3,-248 # ffffffe000203488 <__func__.0>
ffffffe000201588:	01000613          	li	a2,16
ffffffe00020158c:	00002597          	auipc	a1,0x2
ffffffe000201590:	e9458593          	addi	a1,a1,-364 # ffffffe000203420 <__func__.0+0x30>
ffffffe000201594:	00002517          	auipc	a0,0x2
ffffffe000201598:	e9450513          	addi	a0,a0,-364 # ffffffe000203428 <__func__.0+0x38>
ffffffe00020159c:	705000ef          	jal	ra,ffffffe0002024a0 <printk>
    test();
ffffffe0002015a0:	01c000ef          	jal	ra,ffffffe0002015bc <test>
    return 0;
ffffffe0002015a4:	00000793          	li	a5,0
}
ffffffe0002015a8:	00078513          	mv	a0,a5
ffffffe0002015ac:	00813083          	ld	ra,8(sp)
ffffffe0002015b0:	00013403          	ld	s0,0(sp)
ffffffe0002015b4:	01010113          	addi	sp,sp,16
ffffffe0002015b8:	00008067          	ret

ffffffe0002015bc <test>:
#include "printk.h"

void test() {
ffffffe0002015bc:	fe010113          	addi	sp,sp,-32
ffffffe0002015c0:	00113c23          	sd	ra,24(sp)
ffffffe0002015c4:	00813823          	sd	s0,16(sp)
ffffffe0002015c8:	02010413          	addi	s0,sp,32
    int i = 0;
ffffffe0002015cc:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
ffffffe0002015d0:	fec42783          	lw	a5,-20(s0)
ffffffe0002015d4:	0017879b          	addiw	a5,a5,1
ffffffe0002015d8:	fef42623          	sw	a5,-20(s0)
ffffffe0002015dc:	fec42783          	lw	a5,-20(s0)
ffffffe0002015e0:	00078713          	mv	a4,a5
ffffffe0002015e4:	05f5e7b7          	lui	a5,0x5f5e
ffffffe0002015e8:	1007879b          	addiw	a5,a5,256 # 5f5e100 <OPENSBI_SIZE+0x5d5e100>
ffffffe0002015ec:	02f767bb          	remw	a5,a4,a5
ffffffe0002015f0:	0007879b          	sext.w	a5,a5
ffffffe0002015f4:	fc079ee3          	bnez	a5,ffffffe0002015d0 <test+0x14>
            printk("kernel is running!\n");
ffffffe0002015f8:	00002517          	auipc	a0,0x2
ffffffe0002015fc:	ea050513          	addi	a0,a0,-352 # ffffffe000203498 <__func__.0+0x10>
ffffffe000201600:	6a1000ef          	jal	ra,ffffffe0002024a0 <printk>
            i = 0;
ffffffe000201604:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
ffffffe000201608:	fc9ff06f          	j	ffffffe0002015d0 <test+0x14>

ffffffe00020160c <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
ffffffe00020160c:	fe010113          	addi	sp,sp,-32
ffffffe000201610:	00113c23          	sd	ra,24(sp)
ffffffe000201614:	00813823          	sd	s0,16(sp)
ffffffe000201618:	02010413          	addi	s0,sp,32
ffffffe00020161c:	00050793          	mv	a5,a0
ffffffe000201620:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
ffffffe000201624:	fec42783          	lw	a5,-20(s0)
ffffffe000201628:	0ff7f793          	zext.b	a5,a5
ffffffe00020162c:	00078513          	mv	a0,a5
ffffffe000201630:	ce4ff0ef          	jal	ra,ffffffe000200b14 <sbi_debug_console_write_byte>
    return (char)c;
ffffffe000201634:	fec42783          	lw	a5,-20(s0)
ffffffe000201638:	0ff7f793          	zext.b	a5,a5
ffffffe00020163c:	0007879b          	sext.w	a5,a5
}
ffffffe000201640:	00078513          	mv	a0,a5
ffffffe000201644:	01813083          	ld	ra,24(sp)
ffffffe000201648:	01013403          	ld	s0,16(sp)
ffffffe00020164c:	02010113          	addi	sp,sp,32
ffffffe000201650:	00008067          	ret

ffffffe000201654 <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
ffffffe000201654:	fe010113          	addi	sp,sp,-32
ffffffe000201658:	00813c23          	sd	s0,24(sp)
ffffffe00020165c:	02010413          	addi	s0,sp,32
ffffffe000201660:	00050793          	mv	a5,a0
ffffffe000201664:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
ffffffe000201668:	fec42783          	lw	a5,-20(s0)
ffffffe00020166c:	0007871b          	sext.w	a4,a5
ffffffe000201670:	02000793          	li	a5,32
ffffffe000201674:	02f70263          	beq	a4,a5,ffffffe000201698 <isspace+0x44>
ffffffe000201678:	fec42783          	lw	a5,-20(s0)
ffffffe00020167c:	0007871b          	sext.w	a4,a5
ffffffe000201680:	00800793          	li	a5,8
ffffffe000201684:	00e7de63          	bge	a5,a4,ffffffe0002016a0 <isspace+0x4c>
ffffffe000201688:	fec42783          	lw	a5,-20(s0)
ffffffe00020168c:	0007871b          	sext.w	a4,a5
ffffffe000201690:	00d00793          	li	a5,13
ffffffe000201694:	00e7c663          	blt	a5,a4,ffffffe0002016a0 <isspace+0x4c>
ffffffe000201698:	00100793          	li	a5,1
ffffffe00020169c:	0080006f          	j	ffffffe0002016a4 <isspace+0x50>
ffffffe0002016a0:	00000793          	li	a5,0
}
ffffffe0002016a4:	00078513          	mv	a0,a5
ffffffe0002016a8:	01813403          	ld	s0,24(sp)
ffffffe0002016ac:	02010113          	addi	sp,sp,32
ffffffe0002016b0:	00008067          	ret

ffffffe0002016b4 <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
ffffffe0002016b4:	fb010113          	addi	sp,sp,-80
ffffffe0002016b8:	04113423          	sd	ra,72(sp)
ffffffe0002016bc:	04813023          	sd	s0,64(sp)
ffffffe0002016c0:	05010413          	addi	s0,sp,80
ffffffe0002016c4:	fca43423          	sd	a0,-56(s0)
ffffffe0002016c8:	fcb43023          	sd	a1,-64(s0)
ffffffe0002016cc:	00060793          	mv	a5,a2
ffffffe0002016d0:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
ffffffe0002016d4:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
ffffffe0002016d8:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
ffffffe0002016dc:	fc843783          	ld	a5,-56(s0)
ffffffe0002016e0:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
ffffffe0002016e4:	0100006f          	j	ffffffe0002016f4 <strtol+0x40>
        p++;
ffffffe0002016e8:	fd843783          	ld	a5,-40(s0)
ffffffe0002016ec:	00178793          	addi	a5,a5,1
ffffffe0002016f0:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
ffffffe0002016f4:	fd843783          	ld	a5,-40(s0)
ffffffe0002016f8:	0007c783          	lbu	a5,0(a5)
ffffffe0002016fc:	0007879b          	sext.w	a5,a5
ffffffe000201700:	00078513          	mv	a0,a5
ffffffe000201704:	f51ff0ef          	jal	ra,ffffffe000201654 <isspace>
ffffffe000201708:	00050793          	mv	a5,a0
ffffffe00020170c:	fc079ee3          	bnez	a5,ffffffe0002016e8 <strtol+0x34>
    }

    if (*p == '-') {
ffffffe000201710:	fd843783          	ld	a5,-40(s0)
ffffffe000201714:	0007c783          	lbu	a5,0(a5)
ffffffe000201718:	00078713          	mv	a4,a5
ffffffe00020171c:	02d00793          	li	a5,45
ffffffe000201720:	00f71e63          	bne	a4,a5,ffffffe00020173c <strtol+0x88>
        neg = true;
ffffffe000201724:	00100793          	li	a5,1
ffffffe000201728:	fef403a3          	sb	a5,-25(s0)
        p++;
ffffffe00020172c:	fd843783          	ld	a5,-40(s0)
ffffffe000201730:	00178793          	addi	a5,a5,1
ffffffe000201734:	fcf43c23          	sd	a5,-40(s0)
ffffffe000201738:	0240006f          	j	ffffffe00020175c <strtol+0xa8>
    } else if (*p == '+') {
ffffffe00020173c:	fd843783          	ld	a5,-40(s0)
ffffffe000201740:	0007c783          	lbu	a5,0(a5)
ffffffe000201744:	00078713          	mv	a4,a5
ffffffe000201748:	02b00793          	li	a5,43
ffffffe00020174c:	00f71863          	bne	a4,a5,ffffffe00020175c <strtol+0xa8>
        p++;
ffffffe000201750:	fd843783          	ld	a5,-40(s0)
ffffffe000201754:	00178793          	addi	a5,a5,1
ffffffe000201758:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
ffffffe00020175c:	fbc42783          	lw	a5,-68(s0)
ffffffe000201760:	0007879b          	sext.w	a5,a5
ffffffe000201764:	06079c63          	bnez	a5,ffffffe0002017dc <strtol+0x128>
        if (*p == '0') {
ffffffe000201768:	fd843783          	ld	a5,-40(s0)
ffffffe00020176c:	0007c783          	lbu	a5,0(a5)
ffffffe000201770:	00078713          	mv	a4,a5
ffffffe000201774:	03000793          	li	a5,48
ffffffe000201778:	04f71e63          	bne	a4,a5,ffffffe0002017d4 <strtol+0x120>
            p++;
ffffffe00020177c:	fd843783          	ld	a5,-40(s0)
ffffffe000201780:	00178793          	addi	a5,a5,1
ffffffe000201784:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
ffffffe000201788:	fd843783          	ld	a5,-40(s0)
ffffffe00020178c:	0007c783          	lbu	a5,0(a5)
ffffffe000201790:	00078713          	mv	a4,a5
ffffffe000201794:	07800793          	li	a5,120
ffffffe000201798:	00f70c63          	beq	a4,a5,ffffffe0002017b0 <strtol+0xfc>
ffffffe00020179c:	fd843783          	ld	a5,-40(s0)
ffffffe0002017a0:	0007c783          	lbu	a5,0(a5)
ffffffe0002017a4:	00078713          	mv	a4,a5
ffffffe0002017a8:	05800793          	li	a5,88
ffffffe0002017ac:	00f71e63          	bne	a4,a5,ffffffe0002017c8 <strtol+0x114>
                base = 16;
ffffffe0002017b0:	01000793          	li	a5,16
ffffffe0002017b4:	faf42e23          	sw	a5,-68(s0)
                p++;
ffffffe0002017b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002017bc:	00178793          	addi	a5,a5,1
ffffffe0002017c0:	fcf43c23          	sd	a5,-40(s0)
ffffffe0002017c4:	0180006f          	j	ffffffe0002017dc <strtol+0x128>
            } else {
                base = 8;
ffffffe0002017c8:	00800793          	li	a5,8
ffffffe0002017cc:	faf42e23          	sw	a5,-68(s0)
ffffffe0002017d0:	00c0006f          	j	ffffffe0002017dc <strtol+0x128>
            }
        } else {
            base = 10;
ffffffe0002017d4:	00a00793          	li	a5,10
ffffffe0002017d8:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
ffffffe0002017dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002017e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002017e4:	00078713          	mv	a4,a5
ffffffe0002017e8:	02f00793          	li	a5,47
ffffffe0002017ec:	02e7f863          	bgeu	a5,a4,ffffffe00020181c <strtol+0x168>
ffffffe0002017f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002017f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002017f8:	00078713          	mv	a4,a5
ffffffe0002017fc:	03900793          	li	a5,57
ffffffe000201800:	00e7ee63          	bltu	a5,a4,ffffffe00020181c <strtol+0x168>
            digit = *p - '0';
ffffffe000201804:	fd843783          	ld	a5,-40(s0)
ffffffe000201808:	0007c783          	lbu	a5,0(a5)
ffffffe00020180c:	0007879b          	sext.w	a5,a5
ffffffe000201810:	fd07879b          	addiw	a5,a5,-48
ffffffe000201814:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201818:	0800006f          	j	ffffffe000201898 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
ffffffe00020181c:	fd843783          	ld	a5,-40(s0)
ffffffe000201820:	0007c783          	lbu	a5,0(a5)
ffffffe000201824:	00078713          	mv	a4,a5
ffffffe000201828:	06000793          	li	a5,96
ffffffe00020182c:	02e7f863          	bgeu	a5,a4,ffffffe00020185c <strtol+0x1a8>
ffffffe000201830:	fd843783          	ld	a5,-40(s0)
ffffffe000201834:	0007c783          	lbu	a5,0(a5)
ffffffe000201838:	00078713          	mv	a4,a5
ffffffe00020183c:	07a00793          	li	a5,122
ffffffe000201840:	00e7ee63          	bltu	a5,a4,ffffffe00020185c <strtol+0x1a8>
            digit = *p - ('a' - 10);
ffffffe000201844:	fd843783          	ld	a5,-40(s0)
ffffffe000201848:	0007c783          	lbu	a5,0(a5)
ffffffe00020184c:	0007879b          	sext.w	a5,a5
ffffffe000201850:	fa97879b          	addiw	a5,a5,-87
ffffffe000201854:	fcf42a23          	sw	a5,-44(s0)
ffffffe000201858:	0400006f          	j	ffffffe000201898 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
ffffffe00020185c:	fd843783          	ld	a5,-40(s0)
ffffffe000201860:	0007c783          	lbu	a5,0(a5)
ffffffe000201864:	00078713          	mv	a4,a5
ffffffe000201868:	04000793          	li	a5,64
ffffffe00020186c:	06e7f863          	bgeu	a5,a4,ffffffe0002018dc <strtol+0x228>
ffffffe000201870:	fd843783          	ld	a5,-40(s0)
ffffffe000201874:	0007c783          	lbu	a5,0(a5)
ffffffe000201878:	00078713          	mv	a4,a5
ffffffe00020187c:	05a00793          	li	a5,90
ffffffe000201880:	04e7ee63          	bltu	a5,a4,ffffffe0002018dc <strtol+0x228>
            digit = *p - ('A' - 10);
ffffffe000201884:	fd843783          	ld	a5,-40(s0)
ffffffe000201888:	0007c783          	lbu	a5,0(a5)
ffffffe00020188c:	0007879b          	sext.w	a5,a5
ffffffe000201890:	fc97879b          	addiw	a5,a5,-55
ffffffe000201894:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
ffffffe000201898:	fd442783          	lw	a5,-44(s0)
ffffffe00020189c:	00078713          	mv	a4,a5
ffffffe0002018a0:	fbc42783          	lw	a5,-68(s0)
ffffffe0002018a4:	0007071b          	sext.w	a4,a4
ffffffe0002018a8:	0007879b          	sext.w	a5,a5
ffffffe0002018ac:	02f75663          	bge	a4,a5,ffffffe0002018d8 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
ffffffe0002018b0:	fbc42703          	lw	a4,-68(s0)
ffffffe0002018b4:	fe843783          	ld	a5,-24(s0)
ffffffe0002018b8:	02f70733          	mul	a4,a4,a5
ffffffe0002018bc:	fd442783          	lw	a5,-44(s0)
ffffffe0002018c0:	00f707b3          	add	a5,a4,a5
ffffffe0002018c4:	fef43423          	sd	a5,-24(s0)
        p++;
ffffffe0002018c8:	fd843783          	ld	a5,-40(s0)
ffffffe0002018cc:	00178793          	addi	a5,a5,1
ffffffe0002018d0:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
ffffffe0002018d4:	f09ff06f          	j	ffffffe0002017dc <strtol+0x128>
            break;
ffffffe0002018d8:	00000013          	nop
    }

    if (endptr) {
ffffffe0002018dc:	fc043783          	ld	a5,-64(s0)
ffffffe0002018e0:	00078863          	beqz	a5,ffffffe0002018f0 <strtol+0x23c>
        *endptr = (char *)p;
ffffffe0002018e4:	fc043783          	ld	a5,-64(s0)
ffffffe0002018e8:	fd843703          	ld	a4,-40(s0)
ffffffe0002018ec:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
ffffffe0002018f0:	fe744783          	lbu	a5,-25(s0)
ffffffe0002018f4:	0ff7f793          	zext.b	a5,a5
ffffffe0002018f8:	00078863          	beqz	a5,ffffffe000201908 <strtol+0x254>
ffffffe0002018fc:	fe843783          	ld	a5,-24(s0)
ffffffe000201900:	40f007b3          	neg	a5,a5
ffffffe000201904:	0080006f          	j	ffffffe00020190c <strtol+0x258>
ffffffe000201908:	fe843783          	ld	a5,-24(s0)
}
ffffffe00020190c:	00078513          	mv	a0,a5
ffffffe000201910:	04813083          	ld	ra,72(sp)
ffffffe000201914:	04013403          	ld	s0,64(sp)
ffffffe000201918:	05010113          	addi	sp,sp,80
ffffffe00020191c:	00008067          	ret

ffffffe000201920 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
ffffffe000201920:	fd010113          	addi	sp,sp,-48
ffffffe000201924:	02113423          	sd	ra,40(sp)
ffffffe000201928:	02813023          	sd	s0,32(sp)
ffffffe00020192c:	03010413          	addi	s0,sp,48
ffffffe000201930:	fca43c23          	sd	a0,-40(s0)
ffffffe000201934:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
ffffffe000201938:	fd043783          	ld	a5,-48(s0)
ffffffe00020193c:	00079863          	bnez	a5,ffffffe00020194c <puts_wo_nl+0x2c>
        s = "(null)";
ffffffe000201940:	00002797          	auipc	a5,0x2
ffffffe000201944:	b7078793          	addi	a5,a5,-1168 # ffffffe0002034b0 <__func__.0+0x28>
ffffffe000201948:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
ffffffe00020194c:	fd043783          	ld	a5,-48(s0)
ffffffe000201950:	fef43423          	sd	a5,-24(s0)
    while (*p) {
ffffffe000201954:	0240006f          	j	ffffffe000201978 <puts_wo_nl+0x58>
        putch(*p++);
ffffffe000201958:	fe843783          	ld	a5,-24(s0)
ffffffe00020195c:	00178713          	addi	a4,a5,1
ffffffe000201960:	fee43423          	sd	a4,-24(s0)
ffffffe000201964:	0007c783          	lbu	a5,0(a5)
ffffffe000201968:	0007871b          	sext.w	a4,a5
ffffffe00020196c:	fd843783          	ld	a5,-40(s0)
ffffffe000201970:	00070513          	mv	a0,a4
ffffffe000201974:	000780e7          	jalr	a5
    while (*p) {
ffffffe000201978:	fe843783          	ld	a5,-24(s0)
ffffffe00020197c:	0007c783          	lbu	a5,0(a5)
ffffffe000201980:	fc079ce3          	bnez	a5,ffffffe000201958 <puts_wo_nl+0x38>
    }
    return p - s;
ffffffe000201984:	fe843703          	ld	a4,-24(s0)
ffffffe000201988:	fd043783          	ld	a5,-48(s0)
ffffffe00020198c:	40f707b3          	sub	a5,a4,a5
ffffffe000201990:	0007879b          	sext.w	a5,a5
}
ffffffe000201994:	00078513          	mv	a0,a5
ffffffe000201998:	02813083          	ld	ra,40(sp)
ffffffe00020199c:	02013403          	ld	s0,32(sp)
ffffffe0002019a0:	03010113          	addi	sp,sp,48
ffffffe0002019a4:	00008067          	ret

ffffffe0002019a8 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
ffffffe0002019a8:	f9010113          	addi	sp,sp,-112
ffffffe0002019ac:	06113423          	sd	ra,104(sp)
ffffffe0002019b0:	06813023          	sd	s0,96(sp)
ffffffe0002019b4:	07010413          	addi	s0,sp,112
ffffffe0002019b8:	faa43423          	sd	a0,-88(s0)
ffffffe0002019bc:	fab43023          	sd	a1,-96(s0)
ffffffe0002019c0:	00060793          	mv	a5,a2
ffffffe0002019c4:	f8d43823          	sd	a3,-112(s0)
ffffffe0002019c8:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
ffffffe0002019cc:	f9f44783          	lbu	a5,-97(s0)
ffffffe0002019d0:	0ff7f793          	zext.b	a5,a5
ffffffe0002019d4:	02078663          	beqz	a5,ffffffe000201a00 <print_dec_int+0x58>
ffffffe0002019d8:	fa043703          	ld	a4,-96(s0)
ffffffe0002019dc:	fff00793          	li	a5,-1
ffffffe0002019e0:	03f79793          	slli	a5,a5,0x3f
ffffffe0002019e4:	00f71e63          	bne	a4,a5,ffffffe000201a00 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
ffffffe0002019e8:	00002597          	auipc	a1,0x2
ffffffe0002019ec:	ad058593          	addi	a1,a1,-1328 # ffffffe0002034b8 <__func__.0+0x30>
ffffffe0002019f0:	fa843503          	ld	a0,-88(s0)
ffffffe0002019f4:	f2dff0ef          	jal	ra,ffffffe000201920 <puts_wo_nl>
ffffffe0002019f8:	00050793          	mv	a5,a0
ffffffe0002019fc:	2a00006f          	j	ffffffe000201c9c <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
ffffffe000201a00:	f9043783          	ld	a5,-112(s0)
ffffffe000201a04:	00c7a783          	lw	a5,12(a5)
ffffffe000201a08:	00079a63          	bnez	a5,ffffffe000201a1c <print_dec_int+0x74>
ffffffe000201a0c:	fa043783          	ld	a5,-96(s0)
ffffffe000201a10:	00079663          	bnez	a5,ffffffe000201a1c <print_dec_int+0x74>
        return 0;
ffffffe000201a14:	00000793          	li	a5,0
ffffffe000201a18:	2840006f          	j	ffffffe000201c9c <print_dec_int+0x2f4>
    }

    bool neg = false;
ffffffe000201a1c:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
ffffffe000201a20:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201a24:	0ff7f793          	zext.b	a5,a5
ffffffe000201a28:	02078063          	beqz	a5,ffffffe000201a48 <print_dec_int+0xa0>
ffffffe000201a2c:	fa043783          	ld	a5,-96(s0)
ffffffe000201a30:	0007dc63          	bgez	a5,ffffffe000201a48 <print_dec_int+0xa0>
        neg = true;
ffffffe000201a34:	00100793          	li	a5,1
ffffffe000201a38:	fef407a3          	sb	a5,-17(s0)
        num = -num;
ffffffe000201a3c:	fa043783          	ld	a5,-96(s0)
ffffffe000201a40:	40f007b3          	neg	a5,a5
ffffffe000201a44:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
ffffffe000201a48:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
ffffffe000201a4c:	f9f44783          	lbu	a5,-97(s0)
ffffffe000201a50:	0ff7f793          	zext.b	a5,a5
ffffffe000201a54:	02078863          	beqz	a5,ffffffe000201a84 <print_dec_int+0xdc>
ffffffe000201a58:	fef44783          	lbu	a5,-17(s0)
ffffffe000201a5c:	0ff7f793          	zext.b	a5,a5
ffffffe000201a60:	00079e63          	bnez	a5,ffffffe000201a7c <print_dec_int+0xd4>
ffffffe000201a64:	f9043783          	ld	a5,-112(s0)
ffffffe000201a68:	0057c783          	lbu	a5,5(a5)
ffffffe000201a6c:	00079863          	bnez	a5,ffffffe000201a7c <print_dec_int+0xd4>
ffffffe000201a70:	f9043783          	ld	a5,-112(s0)
ffffffe000201a74:	0047c783          	lbu	a5,4(a5)
ffffffe000201a78:	00078663          	beqz	a5,ffffffe000201a84 <print_dec_int+0xdc>
ffffffe000201a7c:	00100793          	li	a5,1
ffffffe000201a80:	0080006f          	j	ffffffe000201a88 <print_dec_int+0xe0>
ffffffe000201a84:	00000793          	li	a5,0
ffffffe000201a88:	fcf40ba3          	sb	a5,-41(s0)
ffffffe000201a8c:	fd744783          	lbu	a5,-41(s0)
ffffffe000201a90:	0017f793          	andi	a5,a5,1
ffffffe000201a94:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
ffffffe000201a98:	fa043703          	ld	a4,-96(s0)
ffffffe000201a9c:	00a00793          	li	a5,10
ffffffe000201aa0:	02f777b3          	remu	a5,a4,a5
ffffffe000201aa4:	0ff7f713          	zext.b	a4,a5
ffffffe000201aa8:	fe842783          	lw	a5,-24(s0)
ffffffe000201aac:	0017869b          	addiw	a3,a5,1
ffffffe000201ab0:	fed42423          	sw	a3,-24(s0)
ffffffe000201ab4:	0307071b          	addiw	a4,a4,48
ffffffe000201ab8:	0ff77713          	zext.b	a4,a4
ffffffe000201abc:	ff078793          	addi	a5,a5,-16
ffffffe000201ac0:	008787b3          	add	a5,a5,s0
ffffffe000201ac4:	fce78423          	sb	a4,-56(a5)
        num /= 10;
ffffffe000201ac8:	fa043703          	ld	a4,-96(s0)
ffffffe000201acc:	00a00793          	li	a5,10
ffffffe000201ad0:	02f757b3          	divu	a5,a4,a5
ffffffe000201ad4:	faf43023          	sd	a5,-96(s0)
    } while (num);
ffffffe000201ad8:	fa043783          	ld	a5,-96(s0)
ffffffe000201adc:	fa079ee3          	bnez	a5,ffffffe000201a98 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
ffffffe000201ae0:	f9043783          	ld	a5,-112(s0)
ffffffe000201ae4:	00c7a783          	lw	a5,12(a5)
ffffffe000201ae8:	00078713          	mv	a4,a5
ffffffe000201aec:	fff00793          	li	a5,-1
ffffffe000201af0:	02f71063          	bne	a4,a5,ffffffe000201b10 <print_dec_int+0x168>
ffffffe000201af4:	f9043783          	ld	a5,-112(s0)
ffffffe000201af8:	0037c783          	lbu	a5,3(a5)
ffffffe000201afc:	00078a63          	beqz	a5,ffffffe000201b10 <print_dec_int+0x168>
        flags->prec = flags->width;
ffffffe000201b00:	f9043783          	ld	a5,-112(s0)
ffffffe000201b04:	0087a703          	lw	a4,8(a5)
ffffffe000201b08:	f9043783          	ld	a5,-112(s0)
ffffffe000201b0c:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
ffffffe000201b10:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201b14:	f9043783          	ld	a5,-112(s0)
ffffffe000201b18:	0087a703          	lw	a4,8(a5)
ffffffe000201b1c:	fe842783          	lw	a5,-24(s0)
ffffffe000201b20:	fcf42823          	sw	a5,-48(s0)
ffffffe000201b24:	f9043783          	ld	a5,-112(s0)
ffffffe000201b28:	00c7a783          	lw	a5,12(a5)
ffffffe000201b2c:	fcf42623          	sw	a5,-52(s0)
ffffffe000201b30:	fd042783          	lw	a5,-48(s0)
ffffffe000201b34:	00078593          	mv	a1,a5
ffffffe000201b38:	fcc42783          	lw	a5,-52(s0)
ffffffe000201b3c:	00078613          	mv	a2,a5
ffffffe000201b40:	0006069b          	sext.w	a3,a2
ffffffe000201b44:	0005879b          	sext.w	a5,a1
ffffffe000201b48:	00f6d463          	bge	a3,a5,ffffffe000201b50 <print_dec_int+0x1a8>
ffffffe000201b4c:	00058613          	mv	a2,a1
ffffffe000201b50:	0006079b          	sext.w	a5,a2
ffffffe000201b54:	40f707bb          	subw	a5,a4,a5
ffffffe000201b58:	0007871b          	sext.w	a4,a5
ffffffe000201b5c:	fd744783          	lbu	a5,-41(s0)
ffffffe000201b60:	0007879b          	sext.w	a5,a5
ffffffe000201b64:	40f707bb          	subw	a5,a4,a5
ffffffe000201b68:	fef42023          	sw	a5,-32(s0)
ffffffe000201b6c:	0280006f          	j	ffffffe000201b94 <print_dec_int+0x1ec>
        putch(' ');
ffffffe000201b70:	fa843783          	ld	a5,-88(s0)
ffffffe000201b74:	02000513          	li	a0,32
ffffffe000201b78:	000780e7          	jalr	a5
        ++written;
ffffffe000201b7c:	fe442783          	lw	a5,-28(s0)
ffffffe000201b80:	0017879b          	addiw	a5,a5,1
ffffffe000201b84:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
ffffffe000201b88:	fe042783          	lw	a5,-32(s0)
ffffffe000201b8c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201b90:	fef42023          	sw	a5,-32(s0)
ffffffe000201b94:	fe042783          	lw	a5,-32(s0)
ffffffe000201b98:	0007879b          	sext.w	a5,a5
ffffffe000201b9c:	fcf04ae3          	bgtz	a5,ffffffe000201b70 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
ffffffe000201ba0:	fd744783          	lbu	a5,-41(s0)
ffffffe000201ba4:	0ff7f793          	zext.b	a5,a5
ffffffe000201ba8:	04078463          	beqz	a5,ffffffe000201bf0 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
ffffffe000201bac:	fef44783          	lbu	a5,-17(s0)
ffffffe000201bb0:	0ff7f793          	zext.b	a5,a5
ffffffe000201bb4:	00078663          	beqz	a5,ffffffe000201bc0 <print_dec_int+0x218>
ffffffe000201bb8:	02d00793          	li	a5,45
ffffffe000201bbc:	01c0006f          	j	ffffffe000201bd8 <print_dec_int+0x230>
ffffffe000201bc0:	f9043783          	ld	a5,-112(s0)
ffffffe000201bc4:	0057c783          	lbu	a5,5(a5)
ffffffe000201bc8:	00078663          	beqz	a5,ffffffe000201bd4 <print_dec_int+0x22c>
ffffffe000201bcc:	02b00793          	li	a5,43
ffffffe000201bd0:	0080006f          	j	ffffffe000201bd8 <print_dec_int+0x230>
ffffffe000201bd4:	02000793          	li	a5,32
ffffffe000201bd8:	fa843703          	ld	a4,-88(s0)
ffffffe000201bdc:	00078513          	mv	a0,a5
ffffffe000201be0:	000700e7          	jalr	a4
        ++written;
ffffffe000201be4:	fe442783          	lw	a5,-28(s0)
ffffffe000201be8:	0017879b          	addiw	a5,a5,1
ffffffe000201bec:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000201bf0:	fe842783          	lw	a5,-24(s0)
ffffffe000201bf4:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201bf8:	0280006f          	j	ffffffe000201c20 <print_dec_int+0x278>
        putch('0');
ffffffe000201bfc:	fa843783          	ld	a5,-88(s0)
ffffffe000201c00:	03000513          	li	a0,48
ffffffe000201c04:	000780e7          	jalr	a5
        ++written;
ffffffe000201c08:	fe442783          	lw	a5,-28(s0)
ffffffe000201c0c:	0017879b          	addiw	a5,a5,1
ffffffe000201c10:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
ffffffe000201c14:	fdc42783          	lw	a5,-36(s0)
ffffffe000201c18:	0017879b          	addiw	a5,a5,1
ffffffe000201c1c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201c20:	f9043783          	ld	a5,-112(s0)
ffffffe000201c24:	00c7a703          	lw	a4,12(a5)
ffffffe000201c28:	fd744783          	lbu	a5,-41(s0)
ffffffe000201c2c:	0007879b          	sext.w	a5,a5
ffffffe000201c30:	40f707bb          	subw	a5,a4,a5
ffffffe000201c34:	0007871b          	sext.w	a4,a5
ffffffe000201c38:	fdc42783          	lw	a5,-36(s0)
ffffffe000201c3c:	0007879b          	sext.w	a5,a5
ffffffe000201c40:	fae7cee3          	blt	a5,a4,ffffffe000201bfc <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000201c44:	fe842783          	lw	a5,-24(s0)
ffffffe000201c48:	fff7879b          	addiw	a5,a5,-1
ffffffe000201c4c:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201c50:	03c0006f          	j	ffffffe000201c8c <print_dec_int+0x2e4>
        putch(buf[i]);
ffffffe000201c54:	fd842783          	lw	a5,-40(s0)
ffffffe000201c58:	ff078793          	addi	a5,a5,-16
ffffffe000201c5c:	008787b3          	add	a5,a5,s0
ffffffe000201c60:	fc87c783          	lbu	a5,-56(a5)
ffffffe000201c64:	0007871b          	sext.w	a4,a5
ffffffe000201c68:	fa843783          	ld	a5,-88(s0)
ffffffe000201c6c:	00070513          	mv	a0,a4
ffffffe000201c70:	000780e7          	jalr	a5
        ++written;
ffffffe000201c74:	fe442783          	lw	a5,-28(s0)
ffffffe000201c78:	0017879b          	addiw	a5,a5,1
ffffffe000201c7c:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
ffffffe000201c80:	fd842783          	lw	a5,-40(s0)
ffffffe000201c84:	fff7879b          	addiw	a5,a5,-1
ffffffe000201c88:	fcf42c23          	sw	a5,-40(s0)
ffffffe000201c8c:	fd842783          	lw	a5,-40(s0)
ffffffe000201c90:	0007879b          	sext.w	a5,a5
ffffffe000201c94:	fc07d0e3          	bgez	a5,ffffffe000201c54 <print_dec_int+0x2ac>
    }

    return written;
ffffffe000201c98:	fe442783          	lw	a5,-28(s0)
}
ffffffe000201c9c:	00078513          	mv	a0,a5
ffffffe000201ca0:	06813083          	ld	ra,104(sp)
ffffffe000201ca4:	06013403          	ld	s0,96(sp)
ffffffe000201ca8:	07010113          	addi	sp,sp,112
ffffffe000201cac:	00008067          	ret

ffffffe000201cb0 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
ffffffe000201cb0:	f4010113          	addi	sp,sp,-192
ffffffe000201cb4:	0a113c23          	sd	ra,184(sp)
ffffffe000201cb8:	0a813823          	sd	s0,176(sp)
ffffffe000201cbc:	0c010413          	addi	s0,sp,192
ffffffe000201cc0:	f4a43c23          	sd	a0,-168(s0)
ffffffe000201cc4:	f4b43823          	sd	a1,-176(s0)
ffffffe000201cc8:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
ffffffe000201ccc:	f8043023          	sd	zero,-128(s0)
ffffffe000201cd0:	f8043423          	sd	zero,-120(s0)

    int written = 0;
ffffffe000201cd4:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
ffffffe000201cd8:	7a40006f          	j	ffffffe00020247c <vprintfmt+0x7cc>
        if (flags.in_format) {
ffffffe000201cdc:	f8044783          	lbu	a5,-128(s0)
ffffffe000201ce0:	72078e63          	beqz	a5,ffffffe00020241c <vprintfmt+0x76c>
            if (*fmt == '#') {
ffffffe000201ce4:	f5043783          	ld	a5,-176(s0)
ffffffe000201ce8:	0007c783          	lbu	a5,0(a5)
ffffffe000201cec:	00078713          	mv	a4,a5
ffffffe000201cf0:	02300793          	li	a5,35
ffffffe000201cf4:	00f71863          	bne	a4,a5,ffffffe000201d04 <vprintfmt+0x54>
                flags.sharpflag = true;
ffffffe000201cf8:	00100793          	li	a5,1
ffffffe000201cfc:	f8f40123          	sb	a5,-126(s0)
ffffffe000201d00:	7700006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
ffffffe000201d04:	f5043783          	ld	a5,-176(s0)
ffffffe000201d08:	0007c783          	lbu	a5,0(a5)
ffffffe000201d0c:	00078713          	mv	a4,a5
ffffffe000201d10:	03000793          	li	a5,48
ffffffe000201d14:	00f71863          	bne	a4,a5,ffffffe000201d24 <vprintfmt+0x74>
                flags.zeroflag = true;
ffffffe000201d18:	00100793          	li	a5,1
ffffffe000201d1c:	f8f401a3          	sb	a5,-125(s0)
ffffffe000201d20:	7500006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
ffffffe000201d24:	f5043783          	ld	a5,-176(s0)
ffffffe000201d28:	0007c783          	lbu	a5,0(a5)
ffffffe000201d2c:	00078713          	mv	a4,a5
ffffffe000201d30:	06c00793          	li	a5,108
ffffffe000201d34:	04f70063          	beq	a4,a5,ffffffe000201d74 <vprintfmt+0xc4>
ffffffe000201d38:	f5043783          	ld	a5,-176(s0)
ffffffe000201d3c:	0007c783          	lbu	a5,0(a5)
ffffffe000201d40:	00078713          	mv	a4,a5
ffffffe000201d44:	07a00793          	li	a5,122
ffffffe000201d48:	02f70663          	beq	a4,a5,ffffffe000201d74 <vprintfmt+0xc4>
ffffffe000201d4c:	f5043783          	ld	a5,-176(s0)
ffffffe000201d50:	0007c783          	lbu	a5,0(a5)
ffffffe000201d54:	00078713          	mv	a4,a5
ffffffe000201d58:	07400793          	li	a5,116
ffffffe000201d5c:	00f70c63          	beq	a4,a5,ffffffe000201d74 <vprintfmt+0xc4>
ffffffe000201d60:	f5043783          	ld	a5,-176(s0)
ffffffe000201d64:	0007c783          	lbu	a5,0(a5)
ffffffe000201d68:	00078713          	mv	a4,a5
ffffffe000201d6c:	06a00793          	li	a5,106
ffffffe000201d70:	00f71863          	bne	a4,a5,ffffffe000201d80 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
ffffffe000201d74:	00100793          	li	a5,1
ffffffe000201d78:	f8f400a3          	sb	a5,-127(s0)
ffffffe000201d7c:	6f40006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
ffffffe000201d80:	f5043783          	ld	a5,-176(s0)
ffffffe000201d84:	0007c783          	lbu	a5,0(a5)
ffffffe000201d88:	00078713          	mv	a4,a5
ffffffe000201d8c:	02b00793          	li	a5,43
ffffffe000201d90:	00f71863          	bne	a4,a5,ffffffe000201da0 <vprintfmt+0xf0>
                flags.sign = true;
ffffffe000201d94:	00100793          	li	a5,1
ffffffe000201d98:	f8f402a3          	sb	a5,-123(s0)
ffffffe000201d9c:	6d40006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
ffffffe000201da0:	f5043783          	ld	a5,-176(s0)
ffffffe000201da4:	0007c783          	lbu	a5,0(a5)
ffffffe000201da8:	00078713          	mv	a4,a5
ffffffe000201dac:	02000793          	li	a5,32
ffffffe000201db0:	00f71863          	bne	a4,a5,ffffffe000201dc0 <vprintfmt+0x110>
                flags.spaceflag = true;
ffffffe000201db4:	00100793          	li	a5,1
ffffffe000201db8:	f8f40223          	sb	a5,-124(s0)
ffffffe000201dbc:	6b40006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
ffffffe000201dc0:	f5043783          	ld	a5,-176(s0)
ffffffe000201dc4:	0007c783          	lbu	a5,0(a5)
ffffffe000201dc8:	00078713          	mv	a4,a5
ffffffe000201dcc:	02a00793          	li	a5,42
ffffffe000201dd0:	00f71e63          	bne	a4,a5,ffffffe000201dec <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
ffffffe000201dd4:	f4843783          	ld	a5,-184(s0)
ffffffe000201dd8:	00878713          	addi	a4,a5,8
ffffffe000201ddc:	f4e43423          	sd	a4,-184(s0)
ffffffe000201de0:	0007a783          	lw	a5,0(a5)
ffffffe000201de4:	f8f42423          	sw	a5,-120(s0)
ffffffe000201de8:	6880006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
ffffffe000201dec:	f5043783          	ld	a5,-176(s0)
ffffffe000201df0:	0007c783          	lbu	a5,0(a5)
ffffffe000201df4:	00078713          	mv	a4,a5
ffffffe000201df8:	03000793          	li	a5,48
ffffffe000201dfc:	04e7f663          	bgeu	a5,a4,ffffffe000201e48 <vprintfmt+0x198>
ffffffe000201e00:	f5043783          	ld	a5,-176(s0)
ffffffe000201e04:	0007c783          	lbu	a5,0(a5)
ffffffe000201e08:	00078713          	mv	a4,a5
ffffffe000201e0c:	03900793          	li	a5,57
ffffffe000201e10:	02e7ec63          	bltu	a5,a4,ffffffe000201e48 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
ffffffe000201e14:	f5043783          	ld	a5,-176(s0)
ffffffe000201e18:	f5040713          	addi	a4,s0,-176
ffffffe000201e1c:	00a00613          	li	a2,10
ffffffe000201e20:	00070593          	mv	a1,a4
ffffffe000201e24:	00078513          	mv	a0,a5
ffffffe000201e28:	88dff0ef          	jal	ra,ffffffe0002016b4 <strtol>
ffffffe000201e2c:	00050793          	mv	a5,a0
ffffffe000201e30:	0007879b          	sext.w	a5,a5
ffffffe000201e34:	f8f42423          	sw	a5,-120(s0)
                fmt--;
ffffffe000201e38:	f5043783          	ld	a5,-176(s0)
ffffffe000201e3c:	fff78793          	addi	a5,a5,-1
ffffffe000201e40:	f4f43823          	sd	a5,-176(s0)
ffffffe000201e44:	62c0006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
ffffffe000201e48:	f5043783          	ld	a5,-176(s0)
ffffffe000201e4c:	0007c783          	lbu	a5,0(a5)
ffffffe000201e50:	00078713          	mv	a4,a5
ffffffe000201e54:	02e00793          	li	a5,46
ffffffe000201e58:	06f71863          	bne	a4,a5,ffffffe000201ec8 <vprintfmt+0x218>
                fmt++;
ffffffe000201e5c:	f5043783          	ld	a5,-176(s0)
ffffffe000201e60:	00178793          	addi	a5,a5,1
ffffffe000201e64:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
ffffffe000201e68:	f5043783          	ld	a5,-176(s0)
ffffffe000201e6c:	0007c783          	lbu	a5,0(a5)
ffffffe000201e70:	00078713          	mv	a4,a5
ffffffe000201e74:	02a00793          	li	a5,42
ffffffe000201e78:	00f71e63          	bne	a4,a5,ffffffe000201e94 <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
ffffffe000201e7c:	f4843783          	ld	a5,-184(s0)
ffffffe000201e80:	00878713          	addi	a4,a5,8
ffffffe000201e84:	f4e43423          	sd	a4,-184(s0)
ffffffe000201e88:	0007a783          	lw	a5,0(a5)
ffffffe000201e8c:	f8f42623          	sw	a5,-116(s0)
ffffffe000201e90:	5e00006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
ffffffe000201e94:	f5043783          	ld	a5,-176(s0)
ffffffe000201e98:	f5040713          	addi	a4,s0,-176
ffffffe000201e9c:	00a00613          	li	a2,10
ffffffe000201ea0:	00070593          	mv	a1,a4
ffffffe000201ea4:	00078513          	mv	a0,a5
ffffffe000201ea8:	80dff0ef          	jal	ra,ffffffe0002016b4 <strtol>
ffffffe000201eac:	00050793          	mv	a5,a0
ffffffe000201eb0:	0007879b          	sext.w	a5,a5
ffffffe000201eb4:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
ffffffe000201eb8:	f5043783          	ld	a5,-176(s0)
ffffffe000201ebc:	fff78793          	addi	a5,a5,-1
ffffffe000201ec0:	f4f43823          	sd	a5,-176(s0)
ffffffe000201ec4:	5ac0006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000201ec8:	f5043783          	ld	a5,-176(s0)
ffffffe000201ecc:	0007c783          	lbu	a5,0(a5)
ffffffe000201ed0:	00078713          	mv	a4,a5
ffffffe000201ed4:	07800793          	li	a5,120
ffffffe000201ed8:	02f70663          	beq	a4,a5,ffffffe000201f04 <vprintfmt+0x254>
ffffffe000201edc:	f5043783          	ld	a5,-176(s0)
ffffffe000201ee0:	0007c783          	lbu	a5,0(a5)
ffffffe000201ee4:	00078713          	mv	a4,a5
ffffffe000201ee8:	05800793          	li	a5,88
ffffffe000201eec:	00f70c63          	beq	a4,a5,ffffffe000201f04 <vprintfmt+0x254>
ffffffe000201ef0:	f5043783          	ld	a5,-176(s0)
ffffffe000201ef4:	0007c783          	lbu	a5,0(a5)
ffffffe000201ef8:	00078713          	mv	a4,a5
ffffffe000201efc:	07000793          	li	a5,112
ffffffe000201f00:	30f71263          	bne	a4,a5,ffffffe000202204 <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
ffffffe000201f04:	f5043783          	ld	a5,-176(s0)
ffffffe000201f08:	0007c783          	lbu	a5,0(a5)
ffffffe000201f0c:	00078713          	mv	a4,a5
ffffffe000201f10:	07000793          	li	a5,112
ffffffe000201f14:	00f70663          	beq	a4,a5,ffffffe000201f20 <vprintfmt+0x270>
ffffffe000201f18:	f8144783          	lbu	a5,-127(s0)
ffffffe000201f1c:	00078663          	beqz	a5,ffffffe000201f28 <vprintfmt+0x278>
ffffffe000201f20:	00100793          	li	a5,1
ffffffe000201f24:	0080006f          	j	ffffffe000201f2c <vprintfmt+0x27c>
ffffffe000201f28:	00000793          	li	a5,0
ffffffe000201f2c:	faf403a3          	sb	a5,-89(s0)
ffffffe000201f30:	fa744783          	lbu	a5,-89(s0)
ffffffe000201f34:	0017f793          	andi	a5,a5,1
ffffffe000201f38:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
ffffffe000201f3c:	fa744783          	lbu	a5,-89(s0)
ffffffe000201f40:	0ff7f793          	zext.b	a5,a5
ffffffe000201f44:	00078c63          	beqz	a5,ffffffe000201f5c <vprintfmt+0x2ac>
ffffffe000201f48:	f4843783          	ld	a5,-184(s0)
ffffffe000201f4c:	00878713          	addi	a4,a5,8
ffffffe000201f50:	f4e43423          	sd	a4,-184(s0)
ffffffe000201f54:	0007b783          	ld	a5,0(a5)
ffffffe000201f58:	01c0006f          	j	ffffffe000201f74 <vprintfmt+0x2c4>
ffffffe000201f5c:	f4843783          	ld	a5,-184(s0)
ffffffe000201f60:	00878713          	addi	a4,a5,8
ffffffe000201f64:	f4e43423          	sd	a4,-184(s0)
ffffffe000201f68:	0007a783          	lw	a5,0(a5)
ffffffe000201f6c:	02079793          	slli	a5,a5,0x20
ffffffe000201f70:	0207d793          	srli	a5,a5,0x20
ffffffe000201f74:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
ffffffe000201f78:	f8c42783          	lw	a5,-116(s0)
ffffffe000201f7c:	02079463          	bnez	a5,ffffffe000201fa4 <vprintfmt+0x2f4>
ffffffe000201f80:	fe043783          	ld	a5,-32(s0)
ffffffe000201f84:	02079063          	bnez	a5,ffffffe000201fa4 <vprintfmt+0x2f4>
ffffffe000201f88:	f5043783          	ld	a5,-176(s0)
ffffffe000201f8c:	0007c783          	lbu	a5,0(a5)
ffffffe000201f90:	00078713          	mv	a4,a5
ffffffe000201f94:	07000793          	li	a5,112
ffffffe000201f98:	00f70663          	beq	a4,a5,ffffffe000201fa4 <vprintfmt+0x2f4>
                    flags.in_format = false;
ffffffe000201f9c:	f8040023          	sb	zero,-128(s0)
ffffffe000201fa0:	4d00006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
ffffffe000201fa4:	f5043783          	ld	a5,-176(s0)
ffffffe000201fa8:	0007c783          	lbu	a5,0(a5)
ffffffe000201fac:	00078713          	mv	a4,a5
ffffffe000201fb0:	07000793          	li	a5,112
ffffffe000201fb4:	00f70a63          	beq	a4,a5,ffffffe000201fc8 <vprintfmt+0x318>
ffffffe000201fb8:	f8244783          	lbu	a5,-126(s0)
ffffffe000201fbc:	00078a63          	beqz	a5,ffffffe000201fd0 <vprintfmt+0x320>
ffffffe000201fc0:	fe043783          	ld	a5,-32(s0)
ffffffe000201fc4:	00078663          	beqz	a5,ffffffe000201fd0 <vprintfmt+0x320>
ffffffe000201fc8:	00100793          	li	a5,1
ffffffe000201fcc:	0080006f          	j	ffffffe000201fd4 <vprintfmt+0x324>
ffffffe000201fd0:	00000793          	li	a5,0
ffffffe000201fd4:	faf40323          	sb	a5,-90(s0)
ffffffe000201fd8:	fa644783          	lbu	a5,-90(s0)
ffffffe000201fdc:	0017f793          	andi	a5,a5,1
ffffffe000201fe0:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
ffffffe000201fe4:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
ffffffe000201fe8:	f5043783          	ld	a5,-176(s0)
ffffffe000201fec:	0007c783          	lbu	a5,0(a5)
ffffffe000201ff0:	00078713          	mv	a4,a5
ffffffe000201ff4:	05800793          	li	a5,88
ffffffe000201ff8:	00f71863          	bne	a4,a5,ffffffe000202008 <vprintfmt+0x358>
ffffffe000201ffc:	00001797          	auipc	a5,0x1
ffffffe000202000:	4d478793          	addi	a5,a5,1236 # ffffffe0002034d0 <upperxdigits.1>
ffffffe000202004:	00c0006f          	j	ffffffe000202010 <vprintfmt+0x360>
ffffffe000202008:	00001797          	auipc	a5,0x1
ffffffe00020200c:	4e078793          	addi	a5,a5,1248 # ffffffe0002034e8 <lowerxdigits.0>
ffffffe000202010:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
ffffffe000202014:	fe043783          	ld	a5,-32(s0)
ffffffe000202018:	00f7f793          	andi	a5,a5,15
ffffffe00020201c:	f9843703          	ld	a4,-104(s0)
ffffffe000202020:	00f70733          	add	a4,a4,a5
ffffffe000202024:	fdc42783          	lw	a5,-36(s0)
ffffffe000202028:	0017869b          	addiw	a3,a5,1
ffffffe00020202c:	fcd42e23          	sw	a3,-36(s0)
ffffffe000202030:	00074703          	lbu	a4,0(a4)
ffffffe000202034:	ff078793          	addi	a5,a5,-16
ffffffe000202038:	008787b3          	add	a5,a5,s0
ffffffe00020203c:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
ffffffe000202040:	fe043783          	ld	a5,-32(s0)
ffffffe000202044:	0047d793          	srli	a5,a5,0x4
ffffffe000202048:	fef43023          	sd	a5,-32(s0)
                } while (num);
ffffffe00020204c:	fe043783          	ld	a5,-32(s0)
ffffffe000202050:	fc0792e3          	bnez	a5,ffffffe000202014 <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
ffffffe000202054:	f8c42783          	lw	a5,-116(s0)
ffffffe000202058:	00078713          	mv	a4,a5
ffffffe00020205c:	fff00793          	li	a5,-1
ffffffe000202060:	02f71663          	bne	a4,a5,ffffffe00020208c <vprintfmt+0x3dc>
ffffffe000202064:	f8344783          	lbu	a5,-125(s0)
ffffffe000202068:	02078263          	beqz	a5,ffffffe00020208c <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
ffffffe00020206c:	f8842703          	lw	a4,-120(s0)
ffffffe000202070:	fa644783          	lbu	a5,-90(s0)
ffffffe000202074:	0007879b          	sext.w	a5,a5
ffffffe000202078:	0017979b          	slliw	a5,a5,0x1
ffffffe00020207c:	0007879b          	sext.w	a5,a5
ffffffe000202080:	40f707bb          	subw	a5,a4,a5
ffffffe000202084:	0007879b          	sext.w	a5,a5
ffffffe000202088:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe00020208c:	f8842703          	lw	a4,-120(s0)
ffffffe000202090:	fa644783          	lbu	a5,-90(s0)
ffffffe000202094:	0007879b          	sext.w	a5,a5
ffffffe000202098:	0017979b          	slliw	a5,a5,0x1
ffffffe00020209c:	0007879b          	sext.w	a5,a5
ffffffe0002020a0:	40f707bb          	subw	a5,a4,a5
ffffffe0002020a4:	0007871b          	sext.w	a4,a5
ffffffe0002020a8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002020ac:	f8f42a23          	sw	a5,-108(s0)
ffffffe0002020b0:	f8c42783          	lw	a5,-116(s0)
ffffffe0002020b4:	f8f42823          	sw	a5,-112(s0)
ffffffe0002020b8:	f9442783          	lw	a5,-108(s0)
ffffffe0002020bc:	00078593          	mv	a1,a5
ffffffe0002020c0:	f9042783          	lw	a5,-112(s0)
ffffffe0002020c4:	00078613          	mv	a2,a5
ffffffe0002020c8:	0006069b          	sext.w	a3,a2
ffffffe0002020cc:	0005879b          	sext.w	a5,a1
ffffffe0002020d0:	00f6d463          	bge	a3,a5,ffffffe0002020d8 <vprintfmt+0x428>
ffffffe0002020d4:	00058613          	mv	a2,a1
ffffffe0002020d8:	0006079b          	sext.w	a5,a2
ffffffe0002020dc:	40f707bb          	subw	a5,a4,a5
ffffffe0002020e0:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002020e4:	0280006f          	j	ffffffe00020210c <vprintfmt+0x45c>
                    putch(' ');
ffffffe0002020e8:	f5843783          	ld	a5,-168(s0)
ffffffe0002020ec:	02000513          	li	a0,32
ffffffe0002020f0:	000780e7          	jalr	a5
                    ++written;
ffffffe0002020f4:	fec42783          	lw	a5,-20(s0)
ffffffe0002020f8:	0017879b          	addiw	a5,a5,1
ffffffe0002020fc:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
ffffffe000202100:	fd842783          	lw	a5,-40(s0)
ffffffe000202104:	fff7879b          	addiw	a5,a5,-1
ffffffe000202108:	fcf42c23          	sw	a5,-40(s0)
ffffffe00020210c:	fd842783          	lw	a5,-40(s0)
ffffffe000202110:	0007879b          	sext.w	a5,a5
ffffffe000202114:	fcf04ae3          	bgtz	a5,ffffffe0002020e8 <vprintfmt+0x438>
                }

                if (prefix) {
ffffffe000202118:	fa644783          	lbu	a5,-90(s0)
ffffffe00020211c:	0ff7f793          	zext.b	a5,a5
ffffffe000202120:	04078463          	beqz	a5,ffffffe000202168 <vprintfmt+0x4b8>
                    putch('0');
ffffffe000202124:	f5843783          	ld	a5,-168(s0)
ffffffe000202128:	03000513          	li	a0,48
ffffffe00020212c:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
ffffffe000202130:	f5043783          	ld	a5,-176(s0)
ffffffe000202134:	0007c783          	lbu	a5,0(a5)
ffffffe000202138:	00078713          	mv	a4,a5
ffffffe00020213c:	05800793          	li	a5,88
ffffffe000202140:	00f71663          	bne	a4,a5,ffffffe00020214c <vprintfmt+0x49c>
ffffffe000202144:	05800793          	li	a5,88
ffffffe000202148:	0080006f          	j	ffffffe000202150 <vprintfmt+0x4a0>
ffffffe00020214c:	07800793          	li	a5,120
ffffffe000202150:	f5843703          	ld	a4,-168(s0)
ffffffe000202154:	00078513          	mv	a0,a5
ffffffe000202158:	000700e7          	jalr	a4
                    written += 2;
ffffffe00020215c:	fec42783          	lw	a5,-20(s0)
ffffffe000202160:	0027879b          	addiw	a5,a5,2
ffffffe000202164:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe000202168:	fdc42783          	lw	a5,-36(s0)
ffffffe00020216c:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202170:	0280006f          	j	ffffffe000202198 <vprintfmt+0x4e8>
                    putch('0');
ffffffe000202174:	f5843783          	ld	a5,-168(s0)
ffffffe000202178:	03000513          	li	a0,48
ffffffe00020217c:	000780e7          	jalr	a5
                    ++written;
ffffffe000202180:	fec42783          	lw	a5,-20(s0)
ffffffe000202184:	0017879b          	addiw	a5,a5,1
ffffffe000202188:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
ffffffe00020218c:	fd442783          	lw	a5,-44(s0)
ffffffe000202190:	0017879b          	addiw	a5,a5,1
ffffffe000202194:	fcf42a23          	sw	a5,-44(s0)
ffffffe000202198:	f8c42703          	lw	a4,-116(s0)
ffffffe00020219c:	fd442783          	lw	a5,-44(s0)
ffffffe0002021a0:	0007879b          	sext.w	a5,a5
ffffffe0002021a4:	fce7c8e3          	blt	a5,a4,ffffffe000202174 <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe0002021a8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002021ac:	fff7879b          	addiw	a5,a5,-1
ffffffe0002021b0:	fcf42823          	sw	a5,-48(s0)
ffffffe0002021b4:	03c0006f          	j	ffffffe0002021f0 <vprintfmt+0x540>
                    putch(buf[i]);
ffffffe0002021b8:	fd042783          	lw	a5,-48(s0)
ffffffe0002021bc:	ff078793          	addi	a5,a5,-16
ffffffe0002021c0:	008787b3          	add	a5,a5,s0
ffffffe0002021c4:	f807c783          	lbu	a5,-128(a5)
ffffffe0002021c8:	0007871b          	sext.w	a4,a5
ffffffe0002021cc:	f5843783          	ld	a5,-168(s0)
ffffffe0002021d0:	00070513          	mv	a0,a4
ffffffe0002021d4:	000780e7          	jalr	a5
                    ++written;
ffffffe0002021d8:	fec42783          	lw	a5,-20(s0)
ffffffe0002021dc:	0017879b          	addiw	a5,a5,1
ffffffe0002021e0:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
ffffffe0002021e4:	fd042783          	lw	a5,-48(s0)
ffffffe0002021e8:	fff7879b          	addiw	a5,a5,-1
ffffffe0002021ec:	fcf42823          	sw	a5,-48(s0)
ffffffe0002021f0:	fd042783          	lw	a5,-48(s0)
ffffffe0002021f4:	0007879b          	sext.w	a5,a5
ffffffe0002021f8:	fc07d0e3          	bgez	a5,ffffffe0002021b8 <vprintfmt+0x508>
                }

                flags.in_format = false;
ffffffe0002021fc:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
ffffffe000202200:	2700006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe000202204:	f5043783          	ld	a5,-176(s0)
ffffffe000202208:	0007c783          	lbu	a5,0(a5)
ffffffe00020220c:	00078713          	mv	a4,a5
ffffffe000202210:	06400793          	li	a5,100
ffffffe000202214:	02f70663          	beq	a4,a5,ffffffe000202240 <vprintfmt+0x590>
ffffffe000202218:	f5043783          	ld	a5,-176(s0)
ffffffe00020221c:	0007c783          	lbu	a5,0(a5)
ffffffe000202220:	00078713          	mv	a4,a5
ffffffe000202224:	06900793          	li	a5,105
ffffffe000202228:	00f70c63          	beq	a4,a5,ffffffe000202240 <vprintfmt+0x590>
ffffffe00020222c:	f5043783          	ld	a5,-176(s0)
ffffffe000202230:	0007c783          	lbu	a5,0(a5)
ffffffe000202234:	00078713          	mv	a4,a5
ffffffe000202238:	07500793          	li	a5,117
ffffffe00020223c:	08f71063          	bne	a4,a5,ffffffe0002022bc <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000202240:	f8144783          	lbu	a5,-127(s0)
ffffffe000202244:	00078c63          	beqz	a5,ffffffe00020225c <vprintfmt+0x5ac>
ffffffe000202248:	f4843783          	ld	a5,-184(s0)
ffffffe00020224c:	00878713          	addi	a4,a5,8
ffffffe000202250:	f4e43423          	sd	a4,-184(s0)
ffffffe000202254:	0007b783          	ld	a5,0(a5)
ffffffe000202258:	0140006f          	j	ffffffe00020226c <vprintfmt+0x5bc>
ffffffe00020225c:	f4843783          	ld	a5,-184(s0)
ffffffe000202260:	00878713          	addi	a4,a5,8
ffffffe000202264:	f4e43423          	sd	a4,-184(s0)
ffffffe000202268:	0007a783          	lw	a5,0(a5)
ffffffe00020226c:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
ffffffe000202270:	fa843583          	ld	a1,-88(s0)
ffffffe000202274:	f5043783          	ld	a5,-176(s0)
ffffffe000202278:	0007c783          	lbu	a5,0(a5)
ffffffe00020227c:	0007871b          	sext.w	a4,a5
ffffffe000202280:	07500793          	li	a5,117
ffffffe000202284:	40f707b3          	sub	a5,a4,a5
ffffffe000202288:	00f037b3          	snez	a5,a5
ffffffe00020228c:	0ff7f793          	zext.b	a5,a5
ffffffe000202290:	f8040713          	addi	a4,s0,-128
ffffffe000202294:	00070693          	mv	a3,a4
ffffffe000202298:	00078613          	mv	a2,a5
ffffffe00020229c:	f5843503          	ld	a0,-168(s0)
ffffffe0002022a0:	f08ff0ef          	jal	ra,ffffffe0002019a8 <print_dec_int>
ffffffe0002022a4:	00050793          	mv	a5,a0
ffffffe0002022a8:	fec42703          	lw	a4,-20(s0)
ffffffe0002022ac:	00f707bb          	addw	a5,a4,a5
ffffffe0002022b0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002022b4:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
ffffffe0002022b8:	1b80006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
ffffffe0002022bc:	f5043783          	ld	a5,-176(s0)
ffffffe0002022c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002022c4:	00078713          	mv	a4,a5
ffffffe0002022c8:	06e00793          	li	a5,110
ffffffe0002022cc:	04f71c63          	bne	a4,a5,ffffffe000202324 <vprintfmt+0x674>
                if (flags.longflag) {
ffffffe0002022d0:	f8144783          	lbu	a5,-127(s0)
ffffffe0002022d4:	02078463          	beqz	a5,ffffffe0002022fc <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
ffffffe0002022d8:	f4843783          	ld	a5,-184(s0)
ffffffe0002022dc:	00878713          	addi	a4,a5,8
ffffffe0002022e0:	f4e43423          	sd	a4,-184(s0)
ffffffe0002022e4:	0007b783          	ld	a5,0(a5)
ffffffe0002022e8:	faf43823          	sd	a5,-80(s0)
                    *n = written;
ffffffe0002022ec:	fec42703          	lw	a4,-20(s0)
ffffffe0002022f0:	fb043783          	ld	a5,-80(s0)
ffffffe0002022f4:	00e7b023          	sd	a4,0(a5)
ffffffe0002022f8:	0240006f          	j	ffffffe00020231c <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
ffffffe0002022fc:	f4843783          	ld	a5,-184(s0)
ffffffe000202300:	00878713          	addi	a4,a5,8
ffffffe000202304:	f4e43423          	sd	a4,-184(s0)
ffffffe000202308:	0007b783          	ld	a5,0(a5)
ffffffe00020230c:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
ffffffe000202310:	fb843783          	ld	a5,-72(s0)
ffffffe000202314:	fec42703          	lw	a4,-20(s0)
ffffffe000202318:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
ffffffe00020231c:	f8040023          	sb	zero,-128(s0)
ffffffe000202320:	1500006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
ffffffe000202324:	f5043783          	ld	a5,-176(s0)
ffffffe000202328:	0007c783          	lbu	a5,0(a5)
ffffffe00020232c:	00078713          	mv	a4,a5
ffffffe000202330:	07300793          	li	a5,115
ffffffe000202334:	02f71e63          	bne	a4,a5,ffffffe000202370 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
ffffffe000202338:	f4843783          	ld	a5,-184(s0)
ffffffe00020233c:	00878713          	addi	a4,a5,8
ffffffe000202340:	f4e43423          	sd	a4,-184(s0)
ffffffe000202344:	0007b783          	ld	a5,0(a5)
ffffffe000202348:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
ffffffe00020234c:	fc043583          	ld	a1,-64(s0)
ffffffe000202350:	f5843503          	ld	a0,-168(s0)
ffffffe000202354:	dccff0ef          	jal	ra,ffffffe000201920 <puts_wo_nl>
ffffffe000202358:	00050793          	mv	a5,a0
ffffffe00020235c:	fec42703          	lw	a4,-20(s0)
ffffffe000202360:	00f707bb          	addw	a5,a4,a5
ffffffe000202364:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202368:	f8040023          	sb	zero,-128(s0)
ffffffe00020236c:	1040006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
ffffffe000202370:	f5043783          	ld	a5,-176(s0)
ffffffe000202374:	0007c783          	lbu	a5,0(a5)
ffffffe000202378:	00078713          	mv	a4,a5
ffffffe00020237c:	06300793          	li	a5,99
ffffffe000202380:	02f71e63          	bne	a4,a5,ffffffe0002023bc <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
ffffffe000202384:	f4843783          	ld	a5,-184(s0)
ffffffe000202388:	00878713          	addi	a4,a5,8
ffffffe00020238c:	f4e43423          	sd	a4,-184(s0)
ffffffe000202390:	0007a783          	lw	a5,0(a5)
ffffffe000202394:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
ffffffe000202398:	fcc42703          	lw	a4,-52(s0)
ffffffe00020239c:	f5843783          	ld	a5,-168(s0)
ffffffe0002023a0:	00070513          	mv	a0,a4
ffffffe0002023a4:	000780e7          	jalr	a5
                ++written;
ffffffe0002023a8:	fec42783          	lw	a5,-20(s0)
ffffffe0002023ac:	0017879b          	addiw	a5,a5,1
ffffffe0002023b0:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002023b4:	f8040023          	sb	zero,-128(s0)
ffffffe0002023b8:	0b80006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
ffffffe0002023bc:	f5043783          	ld	a5,-176(s0)
ffffffe0002023c0:	0007c783          	lbu	a5,0(a5)
ffffffe0002023c4:	00078713          	mv	a4,a5
ffffffe0002023c8:	02500793          	li	a5,37
ffffffe0002023cc:	02f71263          	bne	a4,a5,ffffffe0002023f0 <vprintfmt+0x740>
                putch('%');
ffffffe0002023d0:	f5843783          	ld	a5,-168(s0)
ffffffe0002023d4:	02500513          	li	a0,37
ffffffe0002023d8:	000780e7          	jalr	a5
                ++written;
ffffffe0002023dc:	fec42783          	lw	a5,-20(s0)
ffffffe0002023e0:	0017879b          	addiw	a5,a5,1
ffffffe0002023e4:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe0002023e8:	f8040023          	sb	zero,-128(s0)
ffffffe0002023ec:	0840006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
ffffffe0002023f0:	f5043783          	ld	a5,-176(s0)
ffffffe0002023f4:	0007c783          	lbu	a5,0(a5)
ffffffe0002023f8:	0007871b          	sext.w	a4,a5
ffffffe0002023fc:	f5843783          	ld	a5,-168(s0)
ffffffe000202400:	00070513          	mv	a0,a4
ffffffe000202404:	000780e7          	jalr	a5
                ++written;
ffffffe000202408:	fec42783          	lw	a5,-20(s0)
ffffffe00020240c:	0017879b          	addiw	a5,a5,1
ffffffe000202410:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
ffffffe000202414:	f8040023          	sb	zero,-128(s0)
ffffffe000202418:	0580006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
ffffffe00020241c:	f5043783          	ld	a5,-176(s0)
ffffffe000202420:	0007c783          	lbu	a5,0(a5)
ffffffe000202424:	00078713          	mv	a4,a5
ffffffe000202428:	02500793          	li	a5,37
ffffffe00020242c:	02f71063          	bne	a4,a5,ffffffe00020244c <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
ffffffe000202430:	f8043023          	sd	zero,-128(s0)
ffffffe000202434:	f8043423          	sd	zero,-120(s0)
ffffffe000202438:	00100793          	li	a5,1
ffffffe00020243c:	f8f40023          	sb	a5,-128(s0)
ffffffe000202440:	fff00793          	li	a5,-1
ffffffe000202444:	f8f42623          	sw	a5,-116(s0)
ffffffe000202448:	0280006f          	j	ffffffe000202470 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
ffffffe00020244c:	f5043783          	ld	a5,-176(s0)
ffffffe000202450:	0007c783          	lbu	a5,0(a5)
ffffffe000202454:	0007871b          	sext.w	a4,a5
ffffffe000202458:	f5843783          	ld	a5,-168(s0)
ffffffe00020245c:	00070513          	mv	a0,a4
ffffffe000202460:	000780e7          	jalr	a5
            ++written;
ffffffe000202464:	fec42783          	lw	a5,-20(s0)
ffffffe000202468:	0017879b          	addiw	a5,a5,1
ffffffe00020246c:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
ffffffe000202470:	f5043783          	ld	a5,-176(s0)
ffffffe000202474:	00178793          	addi	a5,a5,1
ffffffe000202478:	f4f43823          	sd	a5,-176(s0)
ffffffe00020247c:	f5043783          	ld	a5,-176(s0)
ffffffe000202480:	0007c783          	lbu	a5,0(a5)
ffffffe000202484:	84079ce3          	bnez	a5,ffffffe000201cdc <vprintfmt+0x2c>
        }
    }

    return written;
ffffffe000202488:	fec42783          	lw	a5,-20(s0)
}
ffffffe00020248c:	00078513          	mv	a0,a5
ffffffe000202490:	0b813083          	ld	ra,184(sp)
ffffffe000202494:	0b013403          	ld	s0,176(sp)
ffffffe000202498:	0c010113          	addi	sp,sp,192
ffffffe00020249c:	00008067          	ret

ffffffe0002024a0 <printk>:

int printk(const char* s, ...) {
ffffffe0002024a0:	f9010113          	addi	sp,sp,-112
ffffffe0002024a4:	02113423          	sd	ra,40(sp)
ffffffe0002024a8:	02813023          	sd	s0,32(sp)
ffffffe0002024ac:	03010413          	addi	s0,sp,48
ffffffe0002024b0:	fca43c23          	sd	a0,-40(s0)
ffffffe0002024b4:	00b43423          	sd	a1,8(s0)
ffffffe0002024b8:	00c43823          	sd	a2,16(s0)
ffffffe0002024bc:	00d43c23          	sd	a3,24(s0)
ffffffe0002024c0:	02e43023          	sd	a4,32(s0)
ffffffe0002024c4:	02f43423          	sd	a5,40(s0)
ffffffe0002024c8:	03043823          	sd	a6,48(s0)
ffffffe0002024cc:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe0002024d0:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe0002024d4:	04040793          	addi	a5,s0,64
ffffffe0002024d8:	fcf43823          	sd	a5,-48(s0)
ffffffe0002024dc:	fd043783          	ld	a5,-48(s0)
ffffffe0002024e0:	fc878793          	addi	a5,a5,-56
ffffffe0002024e4:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe0002024e8:	fe043783          	ld	a5,-32(s0)
ffffffe0002024ec:	00078613          	mv	a2,a5
ffffffe0002024f0:	fd843583          	ld	a1,-40(s0)
ffffffe0002024f4:	fffff517          	auipc	a0,0xfffff
ffffffe0002024f8:	11850513          	addi	a0,a0,280 # ffffffe00020160c <putc>
ffffffe0002024fc:	fb4ff0ef          	jal	ra,ffffffe000201cb0 <vprintfmt>
ffffffe000202500:	00050793          	mv	a5,a0
ffffffe000202504:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000202508:	fec42783          	lw	a5,-20(s0)
}
ffffffe00020250c:	00078513          	mv	a0,a5
ffffffe000202510:	02813083          	ld	ra,40(sp)
ffffffe000202514:	02013403          	ld	s0,32(sp)
ffffffe000202518:	07010113          	addi	sp,sp,112
ffffffe00020251c:	00008067          	ret

ffffffe000202520 <srand>:
#include "stdint.h"
#include "stdlib.h"

static uint64_t seed;

void srand(unsigned s) {
ffffffe000202520:	fe010113          	addi	sp,sp,-32
ffffffe000202524:	00813c23          	sd	s0,24(sp)
ffffffe000202528:	02010413          	addi	s0,sp,32
ffffffe00020252c:	00050793          	mv	a5,a0
ffffffe000202530:	fef42623          	sw	a5,-20(s0)
    seed = s - 1;
ffffffe000202534:	fec42783          	lw	a5,-20(s0)
ffffffe000202538:	fff7879b          	addiw	a5,a5,-1
ffffffe00020253c:	0007879b          	sext.w	a5,a5
ffffffe000202540:	02079713          	slli	a4,a5,0x20
ffffffe000202544:	02075713          	srli	a4,a4,0x20
ffffffe000202548:	00004797          	auipc	a5,0x4
ffffffe00020254c:	ad078793          	addi	a5,a5,-1328 # ffffffe000206018 <seed>
ffffffe000202550:	00e7b023          	sd	a4,0(a5)
}
ffffffe000202554:	00000013          	nop
ffffffe000202558:	01813403          	ld	s0,24(sp)
ffffffe00020255c:	02010113          	addi	sp,sp,32
ffffffe000202560:	00008067          	ret

ffffffe000202564 <rand>:

int rand(void) {
ffffffe000202564:	ff010113          	addi	sp,sp,-16
ffffffe000202568:	00813423          	sd	s0,8(sp)
ffffffe00020256c:	01010413          	addi	s0,sp,16
    seed = 6364136223846793005ULL * seed + 1;
ffffffe000202570:	00004797          	auipc	a5,0x4
ffffffe000202574:	aa878793          	addi	a5,a5,-1368 # ffffffe000206018 <seed>
ffffffe000202578:	0007b703          	ld	a4,0(a5)
ffffffe00020257c:	00001797          	auipc	a5,0x1
ffffffe000202580:	f8478793          	addi	a5,a5,-124 # ffffffe000203500 <lowerxdigits.0+0x18>
ffffffe000202584:	0007b783          	ld	a5,0(a5)
ffffffe000202588:	02f707b3          	mul	a5,a4,a5
ffffffe00020258c:	00178713          	addi	a4,a5,1
ffffffe000202590:	00004797          	auipc	a5,0x4
ffffffe000202594:	a8878793          	addi	a5,a5,-1400 # ffffffe000206018 <seed>
ffffffe000202598:	00e7b023          	sd	a4,0(a5)
    return seed >> 33;
ffffffe00020259c:	00004797          	auipc	a5,0x4
ffffffe0002025a0:	a7c78793          	addi	a5,a5,-1412 # ffffffe000206018 <seed>
ffffffe0002025a4:	0007b783          	ld	a5,0(a5)
ffffffe0002025a8:	0217d793          	srli	a5,a5,0x21
ffffffe0002025ac:	0007879b          	sext.w	a5,a5
}
ffffffe0002025b0:	00078513          	mv	a0,a5
ffffffe0002025b4:	00813403          	ld	s0,8(sp)
ffffffe0002025b8:	01010113          	addi	sp,sp,16
ffffffe0002025bc:	00008067          	ret

ffffffe0002025c0 <memset>:
#include "string.h"
#include "stdint.h"

void *memset(void *dest, int c, uint64_t n) {
ffffffe0002025c0:	fc010113          	addi	sp,sp,-64
ffffffe0002025c4:	02813c23          	sd	s0,56(sp)
ffffffe0002025c8:	04010413          	addi	s0,sp,64
ffffffe0002025cc:	fca43c23          	sd	a0,-40(s0)
ffffffe0002025d0:	00058793          	mv	a5,a1
ffffffe0002025d4:	fcc43423          	sd	a2,-56(s0)
ffffffe0002025d8:	fcf42a23          	sw	a5,-44(s0)
    char *s = (char *)dest;
ffffffe0002025dc:	fd843783          	ld	a5,-40(s0)
ffffffe0002025e0:	fef43023          	sd	a5,-32(s0)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe0002025e4:	fe043423          	sd	zero,-24(s0)
ffffffe0002025e8:	0280006f          	j	ffffffe000202610 <memset+0x50>
        s[i] = c;
ffffffe0002025ec:	fe043703          	ld	a4,-32(s0)
ffffffe0002025f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002025f4:	00f707b3          	add	a5,a4,a5
ffffffe0002025f8:	fd442703          	lw	a4,-44(s0)
ffffffe0002025fc:	0ff77713          	zext.b	a4,a4
ffffffe000202600:	00e78023          	sb	a4,0(a5)
    for (uint64_t i = 0; i < n; ++i) {
ffffffe000202604:	fe843783          	ld	a5,-24(s0)
ffffffe000202608:	00178793          	addi	a5,a5,1
ffffffe00020260c:	fef43423          	sd	a5,-24(s0)
ffffffe000202610:	fe843703          	ld	a4,-24(s0)
ffffffe000202614:	fc843783          	ld	a5,-56(s0)
ffffffe000202618:	fcf76ae3          	bltu	a4,a5,ffffffe0002025ec <memset+0x2c>
    }
    return dest;
ffffffe00020261c:	fd843783          	ld	a5,-40(s0)
}
ffffffe000202620:	00078513          	mv	a0,a5
ffffffe000202624:	03813403          	ld	s0,56(sp)
ffffffe000202628:	04010113          	addi	sp,sp,64
ffffffe00020262c:	00008067          	ret
