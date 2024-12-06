
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_skernel>:
    .extern start_kernel
    .section .text.init
    .globl _start
_start:
    la sp, boot_stack_top
    80200000:	00003117          	auipc	sp,0x3
    80200004:	01013103          	ld	sp,16(sp) # 80203010 <_GLOBAL_OFFSET_TABLE_+0x8>

    # set stvec = _traps
    la t0, _traps
    80200008:	00003297          	auipc	t0,0x3
    8020000c:	0102b283          	ld	t0,16(t0) # 80203018 <_GLOBAL_OFFSET_TABLE_+0x10>
    csrw stvec, t0
    80200010:	10529073          	csrw	stvec,t0
    # set sie[STIE] = 1
    addi t0, zero, 0x20
    80200014:	02000293          	li	t0,32
    csrw sie, t0
    80200018:	10429073          	csrw	sie,t0
    # set first time interrupt
    rdtime t0
    8020001c:	c01022f3          	rdtime	t0
    li t1, 10000000
    80200020:	00989337          	lui	t1,0x989
    80200024:	6803031b          	addiw	t1,t1,1664 # 989680 <_skernel-0x7f876980>
    add t0, t0, t1
    80200028:	006282b3          	add	t0,t0,t1
    add a0, zero, t0
    8020002c:	00500533          	add	a0,zero,t0
    addi a1, zero, 0
    80200030:	00000593          	li	a1,0
    addi a2, zero, 0
    80200034:	00000613          	li	a2,0
    addi a3, zero, 0
    80200038:	00000693          	li	a3,0
    addi a4, zero, 0
    8020003c:	00000713          	li	a4,0
    addi a5, zero, 0
    80200040:	00000793          	li	a5,0
    li a7, 0x54494d45
    80200044:	544958b7          	lui	a7,0x54495
    80200048:	d458889b          	addiw	a7,a7,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    addi a6, zero, 0
    8020004c:	00000813          	li	a6,0
    ecall
    80200050:	00000073          	ecall
    # set sstatus[SIE] = 1
    csrwi sstatus, 0x2
    80200054:	10015073          	csrwi	sstatus,2

    jal start_kernel
    80200058:	558000ef          	jal	ra,802005b0 <start_kernel>

000000008020005c <_traps>:
    .section .text.entry
    .align 2
    .globl _traps 
_traps:
    # 1. save 32 registers and sepc to stack
    addi sp, sp, -256
    8020005c:	f0010113          	addi	sp,sp,-256
    sd x1, 0(sp)
    80200060:	00113023          	sd	ra,0(sp)
    sd x2, 8(sp)
    80200064:	00213423          	sd	sp,8(sp)
    sd x3, 16(sp)
    80200068:	00313823          	sd	gp,16(sp)
    sd x4, 24(sp)
    8020006c:	00413c23          	sd	tp,24(sp)
    sd x5, 32(sp)
    80200070:	02513023          	sd	t0,32(sp)
    sd x6, 40(sp)
    80200074:	02613423          	sd	t1,40(sp)
    sd x7, 48(sp)
    80200078:	02713823          	sd	t2,48(sp)
    sd x8, 56(sp)
    8020007c:	02813c23          	sd	s0,56(sp)
    sd x9, 64(sp)
    80200080:	04913023          	sd	s1,64(sp)
    sd x10, 72(sp)
    80200084:	04a13423          	sd	a0,72(sp)
    sd x11, 80(sp)
    80200088:	04b13823          	sd	a1,80(sp)
    sd x12, 88(sp)
    8020008c:	04c13c23          	sd	a2,88(sp)
    sd x13, 96(sp)
    80200090:	06d13023          	sd	a3,96(sp)
    sd x14, 104(sp)
    80200094:	06e13423          	sd	a4,104(sp)
    sd x15, 112(sp)
    80200098:	06f13823          	sd	a5,112(sp)
    sd x16, 120(sp)
    8020009c:	07013c23          	sd	a6,120(sp)
    sd x17, 128(sp)
    802000a0:	09113023          	sd	a7,128(sp)
    sd x18, 136(sp)
    802000a4:	09213423          	sd	s2,136(sp)
    sd x19, 144(sp)
    802000a8:	09313823          	sd	s3,144(sp)
    sd x20, 152(sp)
    802000ac:	09413c23          	sd	s4,152(sp)
    sd x21, 160(sp)
    802000b0:	0b513023          	sd	s5,160(sp)
    sd x22, 168(sp)
    802000b4:	0b613423          	sd	s6,168(sp)
    sd x23, 176(sp)
    802000b8:	0b713823          	sd	s7,176(sp)
    sd x24, 184(sp)
    802000bc:	0b813c23          	sd	s8,184(sp)
    sd x25, 192(sp)
    802000c0:	0d913023          	sd	s9,192(sp)
    sd x26, 200(sp)
    802000c4:	0da13423          	sd	s10,200(sp)
    sd x27, 208(sp)
    802000c8:	0db13823          	sd	s11,208(sp)
    sd x28, 216(sp)
    802000cc:	0dc13c23          	sd	t3,216(sp)
    sd x29, 224(sp)
    802000d0:	0fd13023          	sd	t4,224(sp)
    sd x30, 232(sp)
    802000d4:	0fe13423          	sd	t5,232(sp)
    sd x31, 240(sp)
    802000d8:	0ff13823          	sd	t6,240(sp)
    csrr t0, sepc
    802000dc:	141022f3          	csrr	t0,sepc
    sd t0, 248(sp)
    802000e0:	0e513c23          	sd	t0,248(sp)
    # 2. call trap_handler
    csrr a0, scause
    802000e4:	14202573          	csrr	a0,scause
    csrr a1, sepc
    802000e8:	141025f3          	csrr	a1,sepc
    call trap_handler
    802000ec:	39c000ef          	jal	ra,80200488 <trap_handler>

    csrr a0, sstatus
    802000f0:	10002573          	csrr	a0,sstatus
    csrr a1, sscratch
    802000f4:	140025f3          	csrr	a1,sscratch
    addi a2, zero, 0x666
    802000f8:	66600613          	li	a2,1638
    call csr_change
    802000fc:	420000ef          	jal	ra,8020051c <csr_change>

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack
    ld t0, 248(sp)
    80200100:	0f813283          	ld	t0,248(sp)
    csrw sepc, t0
    80200104:	14129073          	csrw	sepc,t0
    ld x1, 0(sp)
    80200108:	00013083          	ld	ra,0(sp)
    
    ld x3, 16(sp)
    8020010c:	01013183          	ld	gp,16(sp)
    ld x4, 24(sp)
    80200110:	01813203          	ld	tp,24(sp)
    ld x5, 32(sp)
    80200114:	02013283          	ld	t0,32(sp)
    ld x6, 40(sp)
    80200118:	02813303          	ld	t1,40(sp)
    ld x7, 48(sp)
    8020011c:	03013383          	ld	t2,48(sp)
    ld x8, 56(sp)
    80200120:	03813403          	ld	s0,56(sp)
    ld x9, 64(sp)
    80200124:	04013483          	ld	s1,64(sp)
    ld x10, 72(sp)
    80200128:	04813503          	ld	a0,72(sp)
    ld x11, 80(sp)
    8020012c:	05013583          	ld	a1,80(sp)
    ld x12, 88(sp)
    80200130:	05813603          	ld	a2,88(sp)
    ld x13, 96(sp)
    80200134:	06013683          	ld	a3,96(sp)
    ld x14, 104(sp)
    80200138:	06813703          	ld	a4,104(sp)
    ld x15, 112(sp)
    8020013c:	07013783          	ld	a5,112(sp)
    ld x16, 120(sp)
    80200140:	07813803          	ld	a6,120(sp)
    ld x17, 128(sp)
    80200144:	08013883          	ld	a7,128(sp)
    ld x18, 136(sp)
    80200148:	08813903          	ld	s2,136(sp)
    ld x19, 144(sp)
    8020014c:	09013983          	ld	s3,144(sp)
    ld x20, 152(sp)
    80200150:	09813a03          	ld	s4,152(sp)
    ld x21, 160(sp)
    80200154:	0a013a83          	ld	s5,160(sp)
    ld x22, 168(sp)
    80200158:	0a813b03          	ld	s6,168(sp)
    ld x23, 176(sp)
    8020015c:	0b013b83          	ld	s7,176(sp)
    ld x24, 184(sp)
    80200160:	0b813c03          	ld	s8,184(sp)
    ld x25, 192(sp)
    80200164:	0c013c83          	ld	s9,192(sp)
    ld x26, 200(sp)
    80200168:	0c813d03          	ld	s10,200(sp)
    ld x27, 208(sp)
    8020016c:	0d013d83          	ld	s11,208(sp)
    ld x28, 216(sp)
    80200170:	0d813e03          	ld	t3,216(sp)
    ld x29, 224(sp)
    80200174:	0e013e83          	ld	t4,224(sp)
    ld x30, 232(sp)
    80200178:	0e813f03          	ld	t5,232(sp)
    ld x31, 240(sp)
    8020017c:	0f013f83          	ld	t6,240(sp)
    ld x2, 8(sp)
    80200180:	00813103          	ld	sp,8(sp)
    addi sp, sp, 256
    80200184:	10010113          	addi	sp,sp,256
    # 4. return from trap
    80200188:	10200073          	sret

000000008020018c <get_cycles>:
#include "stdint.h"
#include "sbi.h"
// QEMU 中时钟的频率是 10MHz，也就是 1 秒钟相当于 10000000 个时钟周期
uint64_t TIMECLOCK = 10000000;

uint64_t get_cycles() {
    8020018c:	fe010113          	addi	sp,sp,-32
    80200190:	00813c23          	sd	s0,24(sp)
    80200194:	02010413          	addi	s0,sp,32
    // 编写内联汇编，使用 rdtime 获取 time 寄存器中（也就是 mtime 寄存器）的值并返回
    // #error Unimplemented
    uint64_t cycles;
    asm volatile("rdtime %0" : "=r"(cycles));
    80200198:	c01027f3          	rdtime	a5
    8020019c:	fef43423          	sd	a5,-24(s0)
    return cycles;
    802001a0:	fe843783          	ld	a5,-24(s0)
}
    802001a4:	00078513          	mv	a0,a5
    802001a8:	01813403          	ld	s0,24(sp)
    802001ac:	02010113          	addi	sp,sp,32
    802001b0:	00008067          	ret

00000000802001b4 <clock_set_next_event>:

void clock_set_next_event() {
    802001b4:	fe010113          	addi	sp,sp,-32
    802001b8:	00113c23          	sd	ra,24(sp)
    802001bc:	00813823          	sd	s0,16(sp)
    802001c0:	02010413          	addi	s0,sp,32
    // 下一次时钟中断的时间点
    uint64_t next = get_cycles() + TIMECLOCK;
    802001c4:	fc9ff0ef          	jal	ra,8020018c <get_cycles>
    802001c8:	00050713          	mv	a4,a0
    802001cc:	00003797          	auipc	a5,0x3
    802001d0:	e3478793          	addi	a5,a5,-460 # 80203000 <TIMECLOCK>
    802001d4:	0007b783          	ld	a5,0(a5)
    802001d8:	00f707b3          	add	a5,a4,a5
    802001dc:	fef43423          	sd	a5,-24(s0)

    // 使用 sbi_set_timer 来完成对下一次时钟中断的设置
    sbi_set_timer(next);
    802001e0:	fe843503          	ld	a0,-24(s0)
    802001e4:	218000ef          	jal	ra,802003fc <sbi_set_timer>
    802001e8:	00000013          	nop
    802001ec:	01813083          	ld	ra,24(sp)
    802001f0:	01013403          	ld	s0,16(sp)
    802001f4:	02010113          	addi	sp,sp,32
    802001f8:	00008067          	ret

00000000802001fc <sbi_ecall>:
#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    802001fc:	f8010113          	addi	sp,sp,-128
    80200200:	06813c23          	sd	s0,120(sp)
    80200204:	06913823          	sd	s1,112(sp)
    80200208:	07213423          	sd	s2,104(sp)
    8020020c:	07313023          	sd	s3,96(sp)
    80200210:	08010413          	addi	s0,sp,128
    80200214:	faa43c23          	sd	a0,-72(s0)
    80200218:	fab43823          	sd	a1,-80(s0)
    8020021c:	fac43423          	sd	a2,-88(s0)
    80200220:	fad43023          	sd	a3,-96(s0)
    80200224:	f8e43c23          	sd	a4,-104(s0)
    80200228:	f8f43823          	sd	a5,-112(s0)
    8020022c:	f9043423          	sd	a6,-120(s0)
    80200230:	f9143023          	sd	a7,-128(s0)
    
    struct sbiret sbiRet;

    asm volatile (
    80200234:	fb843e03          	ld	t3,-72(s0)
    80200238:	fb043e83          	ld	t4,-80(s0)
    8020023c:	fa843f03          	ld	t5,-88(s0)
    80200240:	fa043f83          	ld	t6,-96(s0)
    80200244:	f9843283          	ld	t0,-104(s0)
    80200248:	f9043483          	ld	s1,-112(s0)
    8020024c:	f8843903          	ld	s2,-120(s0)
    80200250:	f8043983          	ld	s3,-128(s0)
    80200254:	01c008b3          	add	a7,zero,t3
    80200258:	01d00833          	add	a6,zero,t4
    8020025c:	01e00533          	add	a0,zero,t5
    80200260:	01f005b3          	add	a1,zero,t6
    80200264:	00500633          	add	a2,zero,t0
    80200268:	009006b3          	add	a3,zero,s1
    8020026c:	01200733          	add	a4,zero,s2
    80200270:	013007b3          	add	a5,zero,s3
    80200274:	00000073          	ecall
    80200278:	00050e93          	mv	t4,a0
    8020027c:	00058e13          	mv	t3,a1
    80200280:	fdd43023          	sd	t4,-64(s0)
    80200284:	fdc43423          	sd	t3,-56(s0)
        : "=r"(sbiRet.error), "=r"(sbiRet.value)
        : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );

    return sbiRet;
    80200288:	fc043783          	ld	a5,-64(s0)
    8020028c:	fcf43823          	sd	a5,-48(s0)
    80200290:	fc843783          	ld	a5,-56(s0)
    80200294:	fcf43c23          	sd	a5,-40(s0)
    80200298:	fd043703          	ld	a4,-48(s0)
    8020029c:	fd843783          	ld	a5,-40(s0)
    802002a0:	00070313          	mv	t1,a4
    802002a4:	00078393          	mv	t2,a5
    802002a8:	00030713          	mv	a4,t1
    802002ac:	00038793          	mv	a5,t2
}
    802002b0:	00070513          	mv	a0,a4
    802002b4:	00078593          	mv	a1,a5
    802002b8:	07813403          	ld	s0,120(sp)
    802002bc:	07013483          	ld	s1,112(sp)
    802002c0:	06813903          	ld	s2,104(sp)
    802002c4:	06013983          	ld	s3,96(sp)
    802002c8:	08010113          	addi	sp,sp,128
    802002cc:	00008067          	ret

00000000802002d0 <sbi_debug_console_write_byte>:

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    802002d0:	fc010113          	addi	sp,sp,-64
    802002d4:	02113c23          	sd	ra,56(sp)
    802002d8:	02813823          	sd	s0,48(sp)
    802002dc:	03213423          	sd	s2,40(sp)
    802002e0:	03313023          	sd	s3,32(sp)
    802002e4:	04010413          	addi	s0,sp,64
    802002e8:	00050793          	mv	a5,a0
    802002ec:	fcf407a3          	sb	a5,-49(s0)
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
    802002f0:	fcf44603          	lbu	a2,-49(s0)
    802002f4:	00000893          	li	a7,0
    802002f8:	00000813          	li	a6,0
    802002fc:	00000793          	li	a5,0
    80200300:	00000713          	li	a4,0
    80200304:	00000693          	li	a3,0
    80200308:	00200593          	li	a1,2
    8020030c:	44424537          	lui	a0,0x44424
    80200310:	34e50513          	addi	a0,a0,846 # 4442434e <_skernel-0x3bddbcb2>
    80200314:	ee9ff0ef          	jal	ra,802001fc <sbi_ecall>
    80200318:	00050713          	mv	a4,a0
    8020031c:	00058793          	mv	a5,a1
    80200320:	fce43823          	sd	a4,-48(s0)
    80200324:	fcf43c23          	sd	a5,-40(s0)
    80200328:	fd043703          	ld	a4,-48(s0)
    8020032c:	fd843783          	ld	a5,-40(s0)
    80200330:	00070913          	mv	s2,a4
    80200334:	00078993          	mv	s3,a5
    80200338:	00090713          	mv	a4,s2
    8020033c:	00098793          	mv	a5,s3
}
    80200340:	00070513          	mv	a0,a4
    80200344:	00078593          	mv	a1,a5
    80200348:	03813083          	ld	ra,56(sp)
    8020034c:	03013403          	ld	s0,48(sp)
    80200350:	02813903          	ld	s2,40(sp)
    80200354:	02013983          	ld	s3,32(sp)
    80200358:	04010113          	addi	sp,sp,64
    8020035c:	00008067          	ret

0000000080200360 <sbi_system_reset>:

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    80200360:	fc010113          	addi	sp,sp,-64
    80200364:	02113c23          	sd	ra,56(sp)
    80200368:	02813823          	sd	s0,48(sp)
    8020036c:	03213423          	sd	s2,40(sp)
    80200370:	03313023          	sd	s3,32(sp)
    80200374:	04010413          	addi	s0,sp,64
    80200378:	00050793          	mv	a5,a0
    8020037c:	00058713          	mv	a4,a1
    80200380:	fcf42623          	sw	a5,-52(s0)
    80200384:	00070793          	mv	a5,a4
    80200388:	fcf42423          	sw	a5,-56(s0)
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
    8020038c:	fcc46603          	lwu	a2,-52(s0)
    80200390:	fc846683          	lwu	a3,-56(s0)
    80200394:	00000893          	li	a7,0
    80200398:	00000813          	li	a6,0
    8020039c:	00000793          	li	a5,0
    802003a0:	00000713          	li	a4,0
    802003a4:	00000593          	li	a1,0
    802003a8:	53525537          	lui	a0,0x53525
    802003ac:	35450513          	addi	a0,a0,852 # 53525354 <_skernel-0x2ccdacac>
    802003b0:	e4dff0ef          	jal	ra,802001fc <sbi_ecall>
    802003b4:	00050713          	mv	a4,a0
    802003b8:	00058793          	mv	a5,a1
    802003bc:	fce43823          	sd	a4,-48(s0)
    802003c0:	fcf43c23          	sd	a5,-40(s0)
    802003c4:	fd043703          	ld	a4,-48(s0)
    802003c8:	fd843783          	ld	a5,-40(s0)
    802003cc:	00070913          	mv	s2,a4
    802003d0:	00078993          	mv	s3,a5
    802003d4:	00090713          	mv	a4,s2
    802003d8:	00098793          	mv	a5,s3
}
    802003dc:	00070513          	mv	a0,a4
    802003e0:	00078593          	mv	a1,a5
    802003e4:	03813083          	ld	ra,56(sp)
    802003e8:	03013403          	ld	s0,48(sp)
    802003ec:	02813903          	ld	s2,40(sp)
    802003f0:	02013983          	ld	s3,32(sp)
    802003f4:	04010113          	addi	sp,sp,64
    802003f8:	00008067          	ret

00000000802003fc <sbi_set_timer>:

struct sbiret sbi_set_timer(uint64_t stime_value){
    802003fc:	fc010113          	addi	sp,sp,-64
    80200400:	02113c23          	sd	ra,56(sp)
    80200404:	02813823          	sd	s0,48(sp)
    80200408:	03213423          	sd	s2,40(sp)
    8020040c:	03313023          	sd	s3,32(sp)
    80200410:	04010413          	addi	s0,sp,64
    80200414:	fca43423          	sd	a0,-56(s0)
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
    80200418:	00000893          	li	a7,0
    8020041c:	00000813          	li	a6,0
    80200420:	00000793          	li	a5,0
    80200424:	00000713          	li	a4,0
    80200428:	00000693          	li	a3,0
    8020042c:	fc843603          	ld	a2,-56(s0)
    80200430:	00000593          	li	a1,0
    80200434:	54495537          	lui	a0,0x54495
    80200438:	d4550513          	addi	a0,a0,-699 # 54494d45 <_skernel-0x2bd6b2bb>
    8020043c:	dc1ff0ef          	jal	ra,802001fc <sbi_ecall>
    80200440:	00050713          	mv	a4,a0
    80200444:	00058793          	mv	a5,a1
    80200448:	fce43823          	sd	a4,-48(s0)
    8020044c:	fcf43c23          	sd	a5,-40(s0)
    80200450:	fd043703          	ld	a4,-48(s0)
    80200454:	fd843783          	ld	a5,-40(s0)
    80200458:	00070913          	mv	s2,a4
    8020045c:	00078993          	mv	s3,a5
    80200460:	00090713          	mv	a4,s2
    80200464:	00098793          	mv	a5,s3
    80200468:	00070513          	mv	a0,a4
    8020046c:	00078593          	mv	a1,a5
    80200470:	03813083          	ld	ra,56(sp)
    80200474:	03013403          	ld	s0,48(sp)
    80200478:	02813903          	ld	s2,40(sp)
    8020047c:	02013983          	ld	s3,32(sp)
    80200480:	04010113          	addi	sp,sp,64
    80200484:	00008067          	ret

0000000080200488 <trap_handler>:
#include "stdint.h"
#include "printk.h"
#include "clock.h"
#include "defs.h"
void trap_handler(uint64_t scause, uint64_t sepc) {
    80200488:	fe010113          	addi	sp,sp,-32
    8020048c:	00113c23          	sd	ra,24(sp)
    80200490:	00813823          	sd	s0,16(sp)
    80200494:	02010413          	addi	s0,sp,32
    80200498:	fea43423          	sd	a0,-24(s0)
    8020049c:	feb43023          	sd	a1,-32(s0)
    // 通过 `scause` 判断 trap 类型
    if(scause == 0x8000000000000005){
    802004a0:	fe843703          	ld	a4,-24(s0)
    802004a4:	fff00793          	li	a5,-1
    802004a8:	03f79793          	slli	a5,a5,0x3f
    802004ac:	00578793          	addi	a5,a5,5
    802004b0:	00f71a63          	bne	a4,a5,802004c4 <trap_handler+0x3c>
        printk("timer interrupt\n");
    802004b4:	00002517          	auipc	a0,0x2
    802004b8:	b4c50513          	addi	a0,a0,-1204 # 80202000 <_srodata>
    802004bc:	01c010ef          	jal	ra,802014d8 <printk>
        clock_set_next_event();
    802004c0:	cf5ff0ef          	jal	ra,802001b4 <clock_set_next_event>
    // 如果是 timer interrupt 则打印输出相关信息，并通过 `clock_set_next_event()` 设置下一次时钟中断
    
    // `clock_set_next_event()` 见 4.3.4 节
    
    // 其他 interrupt / exception 可以直接忽略，推荐打印出来供以后调试
    printk((scause & 0x8000000000000000) > 0 ? "Interrupt: " : "Exception: ");
    802004c4:	fe843783          	ld	a5,-24(s0)
    802004c8:	0007d863          	bgez	a5,802004d8 <trap_handler+0x50>
    802004cc:	00002797          	auipc	a5,0x2
    802004d0:	b4c78793          	addi	a5,a5,-1204 # 80202018 <_srodata+0x18>
    802004d4:	00c0006f          	j	802004e0 <trap_handler+0x58>
    802004d8:	00002797          	auipc	a5,0x2
    802004dc:	b5078793          	addi	a5,a5,-1200 # 80202028 <_srodata+0x28>
    802004e0:	00078513          	mv	a0,a5
    802004e4:	7f5000ef          	jal	ra,802014d8 <printk>
    printk("scause: 0x%lx\n", scause);
    802004e8:	fe843583          	ld	a1,-24(s0)
    802004ec:	00002517          	auipc	a0,0x2
    802004f0:	b4c50513          	addi	a0,a0,-1204 # 80202038 <_srodata+0x38>
    802004f4:	7e5000ef          	jal	ra,802014d8 <printk>
    printk("sepc: 0x%lx\n", sepc);
    802004f8:	fe043583          	ld	a1,-32(s0)
    802004fc:	00002517          	auipc	a0,0x2
    80200500:	b4c50513          	addi	a0,a0,-1204 # 80202048 <_srodata+0x48>
    80200504:	7d5000ef          	jal	ra,802014d8 <printk>

}
    80200508:	00000013          	nop
    8020050c:	01813083          	ld	ra,24(sp)
    80200510:	01013403          	ld	s0,16(sp)
    80200514:	02010113          	addi	sp,sp,32
    80200518:	00008067          	ret

000000008020051c <csr_change>:

void csr_change(uint64_t sstatus, uint64_t sscratch, uint64_t value) {
    8020051c:	fb010113          	addi	sp,sp,-80
    80200520:	04113423          	sd	ra,72(sp)
    80200524:	04813023          	sd	s0,64(sp)
    80200528:	05010413          	addi	s0,sp,80
    8020052c:	fca43423          	sd	a0,-56(s0)
    80200530:	fcb43023          	sd	a1,-64(s0)
    80200534:	fac43c23          	sd	a2,-72(s0)
    printk("sscratch: 0x%lx\n", csr_read(sscratch));
    80200538:	140027f3          	csrr	a5,sscratch
    8020053c:	fef43423          	sd	a5,-24(s0)
    80200540:	fe843783          	ld	a5,-24(s0)
    80200544:	00078593          	mv	a1,a5
    80200548:	00002517          	auipc	a0,0x2
    8020054c:	b1050513          	addi	a0,a0,-1264 # 80202058 <_srodata+0x58>
    80200550:	789000ef          	jal	ra,802014d8 <printk>
    csr_write(sscratch, value);
    80200554:	fb843783          	ld	a5,-72(s0)
    80200558:	fef43023          	sd	a5,-32(s0)
    8020055c:	fe043783          	ld	a5,-32(s0)
    80200560:	14079073          	csrw	sscratch,a5
    printk("sstatus: 0x%lx\n", csr_read(sstatus));
    80200564:	100027f3          	csrr	a5,sstatus
    80200568:	fcf43c23          	sd	a5,-40(s0)
    8020056c:	fd843783          	ld	a5,-40(s0)
    80200570:	00078593          	mv	a1,a5
    80200574:	00002517          	auipc	a0,0x2
    80200578:	afc50513          	addi	a0,a0,-1284 # 80202070 <_srodata+0x70>
    8020057c:	75d000ef          	jal	ra,802014d8 <printk>
    printk("sscratch: 0x%lx\n", csr_read(sscratch));
    80200580:	140027f3          	csrr	a5,sscratch
    80200584:	fcf43823          	sd	a5,-48(s0)
    80200588:	fd043783          	ld	a5,-48(s0)
    8020058c:	00078593          	mv	a1,a5
    80200590:	00002517          	auipc	a0,0x2
    80200594:	ac850513          	addi	a0,a0,-1336 # 80202058 <_srodata+0x58>
    80200598:	741000ef          	jal	ra,802014d8 <printk>
    8020059c:	00000013          	nop
    802005a0:	04813083          	ld	ra,72(sp)
    802005a4:	04013403          	ld	s0,64(sp)
    802005a8:	05010113          	addi	sp,sp,80
    802005ac:	00008067          	ret

00000000802005b0 <start_kernel>:
#include "printk.h"

extern void test();

int start_kernel() {
    802005b0:	ff010113          	addi	sp,sp,-16
    802005b4:	00113423          	sd	ra,8(sp)
    802005b8:	00813023          	sd	s0,0(sp)
    802005bc:	01010413          	addi	s0,sp,16
    printk("2024");
    802005c0:	00002517          	auipc	a0,0x2
    802005c4:	ac050513          	addi	a0,a0,-1344 # 80202080 <_srodata+0x80>
    802005c8:	711000ef          	jal	ra,802014d8 <printk>
    printk(" ZJU Operating System\n");
    802005cc:	00002517          	auipc	a0,0x2
    802005d0:	abc50513          	addi	a0,a0,-1348 # 80202088 <_srodata+0x88>
    802005d4:	705000ef          	jal	ra,802014d8 <printk>

    test();
    802005d8:	01c000ef          	jal	ra,802005f4 <test>
    return 0;
    802005dc:	00000793          	li	a5,0
}
    802005e0:	00078513          	mv	a0,a5
    802005e4:	00813083          	ld	ra,8(sp)
    802005e8:	00013403          	ld	s0,0(sp)
    802005ec:	01010113          	addi	sp,sp,16
    802005f0:	00008067          	ret

00000000802005f4 <test>:
#include "printk.h"

void test() {
    802005f4:	fe010113          	addi	sp,sp,-32
    802005f8:	00113c23          	sd	ra,24(sp)
    802005fc:	00813823          	sd	s0,16(sp)
    80200600:	02010413          	addi	s0,sp,32
    int i = 0;
    80200604:	fe042623          	sw	zero,-20(s0)
    while (1) {
        if ((++i) % 100000000 == 0) {
    80200608:	fec42783          	lw	a5,-20(s0)
    8020060c:	0017879b          	addiw	a5,a5,1
    80200610:	fef42623          	sw	a5,-20(s0)
    80200614:	fec42783          	lw	a5,-20(s0)
    80200618:	00078713          	mv	a4,a5
    8020061c:	05f5e7b7          	lui	a5,0x5f5e
    80200620:	1007879b          	addiw	a5,a5,256 # 5f5e100 <_skernel-0x7a2a1f00>
    80200624:	02f767bb          	remw	a5,a4,a5
    80200628:	0007879b          	sext.w	a5,a5
    8020062c:	fc079ee3          	bnez	a5,80200608 <test+0x14>
            printk("kernel is running!\n");
    80200630:	00002517          	auipc	a0,0x2
    80200634:	a7050513          	addi	a0,a0,-1424 # 802020a0 <_srodata+0xa0>
    80200638:	6a1000ef          	jal	ra,802014d8 <printk>
            i = 0;
    8020063c:	fe042623          	sw	zero,-20(s0)
        if ((++i) % 100000000 == 0) {
    80200640:	fc9ff06f          	j	80200608 <test+0x14>

0000000080200644 <putc>:
// credit: 45gfg9 <45gfg9@45gfg9.net>

#include "printk.h"
#include "sbi.h"

int putc(int c) {
    80200644:	fe010113          	addi	sp,sp,-32
    80200648:	00113c23          	sd	ra,24(sp)
    8020064c:	00813823          	sd	s0,16(sp)
    80200650:	02010413          	addi	s0,sp,32
    80200654:	00050793          	mv	a5,a0
    80200658:	fef42623          	sw	a5,-20(s0)
    sbi_debug_console_write_byte(c);
    8020065c:	fec42783          	lw	a5,-20(s0)
    80200660:	0ff7f793          	zext.b	a5,a5
    80200664:	00078513          	mv	a0,a5
    80200668:	c69ff0ef          	jal	ra,802002d0 <sbi_debug_console_write_byte>
    return (char)c;
    8020066c:	fec42783          	lw	a5,-20(s0)
    80200670:	0ff7f793          	zext.b	a5,a5
    80200674:	0007879b          	sext.w	a5,a5
}
    80200678:	00078513          	mv	a0,a5
    8020067c:	01813083          	ld	ra,24(sp)
    80200680:	01013403          	ld	s0,16(sp)
    80200684:	02010113          	addi	sp,sp,32
    80200688:	00008067          	ret

000000008020068c <isspace>:
    bool sign;
    int width;
    int prec;
};

int isspace(int c) {
    8020068c:	fe010113          	addi	sp,sp,-32
    80200690:	00813c23          	sd	s0,24(sp)
    80200694:	02010413          	addi	s0,sp,32
    80200698:	00050793          	mv	a5,a0
    8020069c:	fef42623          	sw	a5,-20(s0)
    return c == ' ' || (c >= '\t' && c <= '\r');
    802006a0:	fec42783          	lw	a5,-20(s0)
    802006a4:	0007871b          	sext.w	a4,a5
    802006a8:	02000793          	li	a5,32
    802006ac:	02f70263          	beq	a4,a5,802006d0 <isspace+0x44>
    802006b0:	fec42783          	lw	a5,-20(s0)
    802006b4:	0007871b          	sext.w	a4,a5
    802006b8:	00800793          	li	a5,8
    802006bc:	00e7de63          	bge	a5,a4,802006d8 <isspace+0x4c>
    802006c0:	fec42783          	lw	a5,-20(s0)
    802006c4:	0007871b          	sext.w	a4,a5
    802006c8:	00d00793          	li	a5,13
    802006cc:	00e7c663          	blt	a5,a4,802006d8 <isspace+0x4c>
    802006d0:	00100793          	li	a5,1
    802006d4:	0080006f          	j	802006dc <isspace+0x50>
    802006d8:	00000793          	li	a5,0
}
    802006dc:	00078513          	mv	a0,a5
    802006e0:	01813403          	ld	s0,24(sp)
    802006e4:	02010113          	addi	sp,sp,32
    802006e8:	00008067          	ret

00000000802006ec <strtol>:

long strtol(const char *restrict nptr, char **restrict endptr, int base) {
    802006ec:	fb010113          	addi	sp,sp,-80
    802006f0:	04113423          	sd	ra,72(sp)
    802006f4:	04813023          	sd	s0,64(sp)
    802006f8:	05010413          	addi	s0,sp,80
    802006fc:	fca43423          	sd	a0,-56(s0)
    80200700:	fcb43023          	sd	a1,-64(s0)
    80200704:	00060793          	mv	a5,a2
    80200708:	faf42e23          	sw	a5,-68(s0)
    long ret = 0;
    8020070c:	fe043423          	sd	zero,-24(s0)
    bool neg = false;
    80200710:	fe0403a3          	sb	zero,-25(s0)
    const char *p = nptr;
    80200714:	fc843783          	ld	a5,-56(s0)
    80200718:	fcf43c23          	sd	a5,-40(s0)

    while (isspace(*p)) {
    8020071c:	0100006f          	j	8020072c <strtol+0x40>
        p++;
    80200720:	fd843783          	ld	a5,-40(s0)
    80200724:	00178793          	addi	a5,a5,1
    80200728:	fcf43c23          	sd	a5,-40(s0)
    while (isspace(*p)) {
    8020072c:	fd843783          	ld	a5,-40(s0)
    80200730:	0007c783          	lbu	a5,0(a5)
    80200734:	0007879b          	sext.w	a5,a5
    80200738:	00078513          	mv	a0,a5
    8020073c:	f51ff0ef          	jal	ra,8020068c <isspace>
    80200740:	00050793          	mv	a5,a0
    80200744:	fc079ee3          	bnez	a5,80200720 <strtol+0x34>
    }

    if (*p == '-') {
    80200748:	fd843783          	ld	a5,-40(s0)
    8020074c:	0007c783          	lbu	a5,0(a5)
    80200750:	00078713          	mv	a4,a5
    80200754:	02d00793          	li	a5,45
    80200758:	00f71e63          	bne	a4,a5,80200774 <strtol+0x88>
        neg = true;
    8020075c:	00100793          	li	a5,1
    80200760:	fef403a3          	sb	a5,-25(s0)
        p++;
    80200764:	fd843783          	ld	a5,-40(s0)
    80200768:	00178793          	addi	a5,a5,1
    8020076c:	fcf43c23          	sd	a5,-40(s0)
    80200770:	0240006f          	j	80200794 <strtol+0xa8>
    } else if (*p == '+') {
    80200774:	fd843783          	ld	a5,-40(s0)
    80200778:	0007c783          	lbu	a5,0(a5)
    8020077c:	00078713          	mv	a4,a5
    80200780:	02b00793          	li	a5,43
    80200784:	00f71863          	bne	a4,a5,80200794 <strtol+0xa8>
        p++;
    80200788:	fd843783          	ld	a5,-40(s0)
    8020078c:	00178793          	addi	a5,a5,1
    80200790:	fcf43c23          	sd	a5,-40(s0)
    }

    if (base == 0) {
    80200794:	fbc42783          	lw	a5,-68(s0)
    80200798:	0007879b          	sext.w	a5,a5
    8020079c:	06079c63          	bnez	a5,80200814 <strtol+0x128>
        if (*p == '0') {
    802007a0:	fd843783          	ld	a5,-40(s0)
    802007a4:	0007c783          	lbu	a5,0(a5)
    802007a8:	00078713          	mv	a4,a5
    802007ac:	03000793          	li	a5,48
    802007b0:	04f71e63          	bne	a4,a5,8020080c <strtol+0x120>
            p++;
    802007b4:	fd843783          	ld	a5,-40(s0)
    802007b8:	00178793          	addi	a5,a5,1
    802007bc:	fcf43c23          	sd	a5,-40(s0)
            if (*p == 'x' || *p == 'X') {
    802007c0:	fd843783          	ld	a5,-40(s0)
    802007c4:	0007c783          	lbu	a5,0(a5)
    802007c8:	00078713          	mv	a4,a5
    802007cc:	07800793          	li	a5,120
    802007d0:	00f70c63          	beq	a4,a5,802007e8 <strtol+0xfc>
    802007d4:	fd843783          	ld	a5,-40(s0)
    802007d8:	0007c783          	lbu	a5,0(a5)
    802007dc:	00078713          	mv	a4,a5
    802007e0:	05800793          	li	a5,88
    802007e4:	00f71e63          	bne	a4,a5,80200800 <strtol+0x114>
                base = 16;
    802007e8:	01000793          	li	a5,16
    802007ec:	faf42e23          	sw	a5,-68(s0)
                p++;
    802007f0:	fd843783          	ld	a5,-40(s0)
    802007f4:	00178793          	addi	a5,a5,1
    802007f8:	fcf43c23          	sd	a5,-40(s0)
    802007fc:	0180006f          	j	80200814 <strtol+0x128>
            } else {
                base = 8;
    80200800:	00800793          	li	a5,8
    80200804:	faf42e23          	sw	a5,-68(s0)
    80200808:	00c0006f          	j	80200814 <strtol+0x128>
            }
        } else {
            base = 10;
    8020080c:	00a00793          	li	a5,10
    80200810:	faf42e23          	sw	a5,-68(s0)
        }
    }

    while (1) {
        int digit;
        if (*p >= '0' && *p <= '9') {
    80200814:	fd843783          	ld	a5,-40(s0)
    80200818:	0007c783          	lbu	a5,0(a5)
    8020081c:	00078713          	mv	a4,a5
    80200820:	02f00793          	li	a5,47
    80200824:	02e7f863          	bgeu	a5,a4,80200854 <strtol+0x168>
    80200828:	fd843783          	ld	a5,-40(s0)
    8020082c:	0007c783          	lbu	a5,0(a5)
    80200830:	00078713          	mv	a4,a5
    80200834:	03900793          	li	a5,57
    80200838:	00e7ee63          	bltu	a5,a4,80200854 <strtol+0x168>
            digit = *p - '0';
    8020083c:	fd843783          	ld	a5,-40(s0)
    80200840:	0007c783          	lbu	a5,0(a5)
    80200844:	0007879b          	sext.w	a5,a5
    80200848:	fd07879b          	addiw	a5,a5,-48
    8020084c:	fcf42a23          	sw	a5,-44(s0)
    80200850:	0800006f          	j	802008d0 <strtol+0x1e4>
        } else if (*p >= 'a' && *p <= 'z') {
    80200854:	fd843783          	ld	a5,-40(s0)
    80200858:	0007c783          	lbu	a5,0(a5)
    8020085c:	00078713          	mv	a4,a5
    80200860:	06000793          	li	a5,96
    80200864:	02e7f863          	bgeu	a5,a4,80200894 <strtol+0x1a8>
    80200868:	fd843783          	ld	a5,-40(s0)
    8020086c:	0007c783          	lbu	a5,0(a5)
    80200870:	00078713          	mv	a4,a5
    80200874:	07a00793          	li	a5,122
    80200878:	00e7ee63          	bltu	a5,a4,80200894 <strtol+0x1a8>
            digit = *p - ('a' - 10);
    8020087c:	fd843783          	ld	a5,-40(s0)
    80200880:	0007c783          	lbu	a5,0(a5)
    80200884:	0007879b          	sext.w	a5,a5
    80200888:	fa97879b          	addiw	a5,a5,-87
    8020088c:	fcf42a23          	sw	a5,-44(s0)
    80200890:	0400006f          	j	802008d0 <strtol+0x1e4>
        } else if (*p >= 'A' && *p <= 'Z') {
    80200894:	fd843783          	ld	a5,-40(s0)
    80200898:	0007c783          	lbu	a5,0(a5)
    8020089c:	00078713          	mv	a4,a5
    802008a0:	04000793          	li	a5,64
    802008a4:	06e7f863          	bgeu	a5,a4,80200914 <strtol+0x228>
    802008a8:	fd843783          	ld	a5,-40(s0)
    802008ac:	0007c783          	lbu	a5,0(a5)
    802008b0:	00078713          	mv	a4,a5
    802008b4:	05a00793          	li	a5,90
    802008b8:	04e7ee63          	bltu	a5,a4,80200914 <strtol+0x228>
            digit = *p - ('A' - 10);
    802008bc:	fd843783          	ld	a5,-40(s0)
    802008c0:	0007c783          	lbu	a5,0(a5)
    802008c4:	0007879b          	sext.w	a5,a5
    802008c8:	fc97879b          	addiw	a5,a5,-55
    802008cc:	fcf42a23          	sw	a5,-44(s0)
        } else {
            break;
        }

        if (digit >= base) {
    802008d0:	fd442783          	lw	a5,-44(s0)
    802008d4:	00078713          	mv	a4,a5
    802008d8:	fbc42783          	lw	a5,-68(s0)
    802008dc:	0007071b          	sext.w	a4,a4
    802008e0:	0007879b          	sext.w	a5,a5
    802008e4:	02f75663          	bge	a4,a5,80200910 <strtol+0x224>
            break;
        }

        ret = ret * base + digit;
    802008e8:	fbc42703          	lw	a4,-68(s0)
    802008ec:	fe843783          	ld	a5,-24(s0)
    802008f0:	02f70733          	mul	a4,a4,a5
    802008f4:	fd442783          	lw	a5,-44(s0)
    802008f8:	00f707b3          	add	a5,a4,a5
    802008fc:	fef43423          	sd	a5,-24(s0)
        p++;
    80200900:	fd843783          	ld	a5,-40(s0)
    80200904:	00178793          	addi	a5,a5,1
    80200908:	fcf43c23          	sd	a5,-40(s0)
    while (1) {
    8020090c:	f09ff06f          	j	80200814 <strtol+0x128>
            break;
    80200910:	00000013          	nop
    }

    if (endptr) {
    80200914:	fc043783          	ld	a5,-64(s0)
    80200918:	00078863          	beqz	a5,80200928 <strtol+0x23c>
        *endptr = (char *)p;
    8020091c:	fc043783          	ld	a5,-64(s0)
    80200920:	fd843703          	ld	a4,-40(s0)
    80200924:	00e7b023          	sd	a4,0(a5)
    }

    return neg ? -ret : ret;
    80200928:	fe744783          	lbu	a5,-25(s0)
    8020092c:	0ff7f793          	zext.b	a5,a5
    80200930:	00078863          	beqz	a5,80200940 <strtol+0x254>
    80200934:	fe843783          	ld	a5,-24(s0)
    80200938:	40f007b3          	neg	a5,a5
    8020093c:	0080006f          	j	80200944 <strtol+0x258>
    80200940:	fe843783          	ld	a5,-24(s0)
}
    80200944:	00078513          	mv	a0,a5
    80200948:	04813083          	ld	ra,72(sp)
    8020094c:	04013403          	ld	s0,64(sp)
    80200950:	05010113          	addi	sp,sp,80
    80200954:	00008067          	ret

0000000080200958 <puts_wo_nl>:

// puts without newline
static int puts_wo_nl(int (*putch)(int), const char *s) {
    80200958:	fd010113          	addi	sp,sp,-48
    8020095c:	02113423          	sd	ra,40(sp)
    80200960:	02813023          	sd	s0,32(sp)
    80200964:	03010413          	addi	s0,sp,48
    80200968:	fca43c23          	sd	a0,-40(s0)
    8020096c:	fcb43823          	sd	a1,-48(s0)
    if (!s) {
    80200970:	fd043783          	ld	a5,-48(s0)
    80200974:	00079863          	bnez	a5,80200984 <puts_wo_nl+0x2c>
        s = "(null)";
    80200978:	00001797          	auipc	a5,0x1
    8020097c:	74078793          	addi	a5,a5,1856 # 802020b8 <_srodata+0xb8>
    80200980:	fcf43823          	sd	a5,-48(s0)
    }
    const char *p = s;
    80200984:	fd043783          	ld	a5,-48(s0)
    80200988:	fef43423          	sd	a5,-24(s0)
    while (*p) {
    8020098c:	0240006f          	j	802009b0 <puts_wo_nl+0x58>
        putch(*p++);
    80200990:	fe843783          	ld	a5,-24(s0)
    80200994:	00178713          	addi	a4,a5,1
    80200998:	fee43423          	sd	a4,-24(s0)
    8020099c:	0007c783          	lbu	a5,0(a5)
    802009a0:	0007871b          	sext.w	a4,a5
    802009a4:	fd843783          	ld	a5,-40(s0)
    802009a8:	00070513          	mv	a0,a4
    802009ac:	000780e7          	jalr	a5
    while (*p) {
    802009b0:	fe843783          	ld	a5,-24(s0)
    802009b4:	0007c783          	lbu	a5,0(a5)
    802009b8:	fc079ce3          	bnez	a5,80200990 <puts_wo_nl+0x38>
    }
    return p - s;
    802009bc:	fe843703          	ld	a4,-24(s0)
    802009c0:	fd043783          	ld	a5,-48(s0)
    802009c4:	40f707b3          	sub	a5,a4,a5
    802009c8:	0007879b          	sext.w	a5,a5
}
    802009cc:	00078513          	mv	a0,a5
    802009d0:	02813083          	ld	ra,40(sp)
    802009d4:	02013403          	ld	s0,32(sp)
    802009d8:	03010113          	addi	sp,sp,48
    802009dc:	00008067          	ret

00000000802009e0 <print_dec_int>:

static int print_dec_int(int (*putch)(int), unsigned long num, bool is_signed, struct fmt_flags *flags) {
    802009e0:	f9010113          	addi	sp,sp,-112
    802009e4:	06113423          	sd	ra,104(sp)
    802009e8:	06813023          	sd	s0,96(sp)
    802009ec:	07010413          	addi	s0,sp,112
    802009f0:	faa43423          	sd	a0,-88(s0)
    802009f4:	fab43023          	sd	a1,-96(s0)
    802009f8:	00060793          	mv	a5,a2
    802009fc:	f8d43823          	sd	a3,-112(s0)
    80200a00:	f8f40fa3          	sb	a5,-97(s0)
    if (is_signed && num == 0x8000000000000000UL) {
    80200a04:	f9f44783          	lbu	a5,-97(s0)
    80200a08:	0ff7f793          	zext.b	a5,a5
    80200a0c:	02078663          	beqz	a5,80200a38 <print_dec_int+0x58>
    80200a10:	fa043703          	ld	a4,-96(s0)
    80200a14:	fff00793          	li	a5,-1
    80200a18:	03f79793          	slli	a5,a5,0x3f
    80200a1c:	00f71e63          	bne	a4,a5,80200a38 <print_dec_int+0x58>
        // special case for 0x8000000000000000
        return puts_wo_nl(putch, "-9223372036854775808");
    80200a20:	00001597          	auipc	a1,0x1
    80200a24:	6a058593          	addi	a1,a1,1696 # 802020c0 <_srodata+0xc0>
    80200a28:	fa843503          	ld	a0,-88(s0)
    80200a2c:	f2dff0ef          	jal	ra,80200958 <puts_wo_nl>
    80200a30:	00050793          	mv	a5,a0
    80200a34:	2a00006f          	j	80200cd4 <print_dec_int+0x2f4>
    }

    if (flags->prec == 0 && num == 0) {
    80200a38:	f9043783          	ld	a5,-112(s0)
    80200a3c:	00c7a783          	lw	a5,12(a5)
    80200a40:	00079a63          	bnez	a5,80200a54 <print_dec_int+0x74>
    80200a44:	fa043783          	ld	a5,-96(s0)
    80200a48:	00079663          	bnez	a5,80200a54 <print_dec_int+0x74>
        return 0;
    80200a4c:	00000793          	li	a5,0
    80200a50:	2840006f          	j	80200cd4 <print_dec_int+0x2f4>
    }

    bool neg = false;
    80200a54:	fe0407a3          	sb	zero,-17(s0)

    if (is_signed && (long)num < 0) {
    80200a58:	f9f44783          	lbu	a5,-97(s0)
    80200a5c:	0ff7f793          	zext.b	a5,a5
    80200a60:	02078063          	beqz	a5,80200a80 <print_dec_int+0xa0>
    80200a64:	fa043783          	ld	a5,-96(s0)
    80200a68:	0007dc63          	bgez	a5,80200a80 <print_dec_int+0xa0>
        neg = true;
    80200a6c:	00100793          	li	a5,1
    80200a70:	fef407a3          	sb	a5,-17(s0)
        num = -num;
    80200a74:	fa043783          	ld	a5,-96(s0)
    80200a78:	40f007b3          	neg	a5,a5
    80200a7c:	faf43023          	sd	a5,-96(s0)
    }

    char buf[20];
    int decdigits = 0;
    80200a80:	fe042423          	sw	zero,-24(s0)

    bool has_sign_char = is_signed && (neg || flags->sign || flags->spaceflag);
    80200a84:	f9f44783          	lbu	a5,-97(s0)
    80200a88:	0ff7f793          	zext.b	a5,a5
    80200a8c:	02078863          	beqz	a5,80200abc <print_dec_int+0xdc>
    80200a90:	fef44783          	lbu	a5,-17(s0)
    80200a94:	0ff7f793          	zext.b	a5,a5
    80200a98:	00079e63          	bnez	a5,80200ab4 <print_dec_int+0xd4>
    80200a9c:	f9043783          	ld	a5,-112(s0)
    80200aa0:	0057c783          	lbu	a5,5(a5)
    80200aa4:	00079863          	bnez	a5,80200ab4 <print_dec_int+0xd4>
    80200aa8:	f9043783          	ld	a5,-112(s0)
    80200aac:	0047c783          	lbu	a5,4(a5)
    80200ab0:	00078663          	beqz	a5,80200abc <print_dec_int+0xdc>
    80200ab4:	00100793          	li	a5,1
    80200ab8:	0080006f          	j	80200ac0 <print_dec_int+0xe0>
    80200abc:	00000793          	li	a5,0
    80200ac0:	fcf40ba3          	sb	a5,-41(s0)
    80200ac4:	fd744783          	lbu	a5,-41(s0)
    80200ac8:	0017f793          	andi	a5,a5,1
    80200acc:	fcf40ba3          	sb	a5,-41(s0)

    do {
        buf[decdigits++] = num % 10 + '0';
    80200ad0:	fa043703          	ld	a4,-96(s0)
    80200ad4:	00a00793          	li	a5,10
    80200ad8:	02f777b3          	remu	a5,a4,a5
    80200adc:	0ff7f713          	zext.b	a4,a5
    80200ae0:	fe842783          	lw	a5,-24(s0)
    80200ae4:	0017869b          	addiw	a3,a5,1
    80200ae8:	fed42423          	sw	a3,-24(s0)
    80200aec:	0307071b          	addiw	a4,a4,48
    80200af0:	0ff77713          	zext.b	a4,a4
    80200af4:	ff078793          	addi	a5,a5,-16
    80200af8:	008787b3          	add	a5,a5,s0
    80200afc:	fce78423          	sb	a4,-56(a5)
        num /= 10;
    80200b00:	fa043703          	ld	a4,-96(s0)
    80200b04:	00a00793          	li	a5,10
    80200b08:	02f757b3          	divu	a5,a4,a5
    80200b0c:	faf43023          	sd	a5,-96(s0)
    } while (num);
    80200b10:	fa043783          	ld	a5,-96(s0)
    80200b14:	fa079ee3          	bnez	a5,80200ad0 <print_dec_int+0xf0>

    if (flags->prec == -1 && flags->zeroflag) {
    80200b18:	f9043783          	ld	a5,-112(s0)
    80200b1c:	00c7a783          	lw	a5,12(a5)
    80200b20:	00078713          	mv	a4,a5
    80200b24:	fff00793          	li	a5,-1
    80200b28:	02f71063          	bne	a4,a5,80200b48 <print_dec_int+0x168>
    80200b2c:	f9043783          	ld	a5,-112(s0)
    80200b30:	0037c783          	lbu	a5,3(a5)
    80200b34:	00078a63          	beqz	a5,80200b48 <print_dec_int+0x168>
        flags->prec = flags->width;
    80200b38:	f9043783          	ld	a5,-112(s0)
    80200b3c:	0087a703          	lw	a4,8(a5)
    80200b40:	f9043783          	ld	a5,-112(s0)
    80200b44:	00e7a623          	sw	a4,12(a5)
    }

    int written = 0;
    80200b48:	fe042223          	sw	zero,-28(s0)

    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200b4c:	f9043783          	ld	a5,-112(s0)
    80200b50:	0087a703          	lw	a4,8(a5)
    80200b54:	fe842783          	lw	a5,-24(s0)
    80200b58:	fcf42823          	sw	a5,-48(s0)
    80200b5c:	f9043783          	ld	a5,-112(s0)
    80200b60:	00c7a783          	lw	a5,12(a5)
    80200b64:	fcf42623          	sw	a5,-52(s0)
    80200b68:	fd042783          	lw	a5,-48(s0)
    80200b6c:	00078593          	mv	a1,a5
    80200b70:	fcc42783          	lw	a5,-52(s0)
    80200b74:	00078613          	mv	a2,a5
    80200b78:	0006069b          	sext.w	a3,a2
    80200b7c:	0005879b          	sext.w	a5,a1
    80200b80:	00f6d463          	bge	a3,a5,80200b88 <print_dec_int+0x1a8>
    80200b84:	00058613          	mv	a2,a1
    80200b88:	0006079b          	sext.w	a5,a2
    80200b8c:	40f707bb          	subw	a5,a4,a5
    80200b90:	0007871b          	sext.w	a4,a5
    80200b94:	fd744783          	lbu	a5,-41(s0)
    80200b98:	0007879b          	sext.w	a5,a5
    80200b9c:	40f707bb          	subw	a5,a4,a5
    80200ba0:	fef42023          	sw	a5,-32(s0)
    80200ba4:	0280006f          	j	80200bcc <print_dec_int+0x1ec>
        putch(' ');
    80200ba8:	fa843783          	ld	a5,-88(s0)
    80200bac:	02000513          	li	a0,32
    80200bb0:	000780e7          	jalr	a5
        ++written;
    80200bb4:	fe442783          	lw	a5,-28(s0)
    80200bb8:	0017879b          	addiw	a5,a5,1
    80200bbc:	fef42223          	sw	a5,-28(s0)
    for (int i = flags->width - __MAX(decdigits, flags->prec) - has_sign_char; i > 0; i--) {
    80200bc0:	fe042783          	lw	a5,-32(s0)
    80200bc4:	fff7879b          	addiw	a5,a5,-1
    80200bc8:	fef42023          	sw	a5,-32(s0)
    80200bcc:	fe042783          	lw	a5,-32(s0)
    80200bd0:	0007879b          	sext.w	a5,a5
    80200bd4:	fcf04ae3          	bgtz	a5,80200ba8 <print_dec_int+0x1c8>
    }

    if (has_sign_char) {
    80200bd8:	fd744783          	lbu	a5,-41(s0)
    80200bdc:	0ff7f793          	zext.b	a5,a5
    80200be0:	04078463          	beqz	a5,80200c28 <print_dec_int+0x248>
        putch(neg ? '-' : flags->sign ? '+' : ' ');
    80200be4:	fef44783          	lbu	a5,-17(s0)
    80200be8:	0ff7f793          	zext.b	a5,a5
    80200bec:	00078663          	beqz	a5,80200bf8 <print_dec_int+0x218>
    80200bf0:	02d00793          	li	a5,45
    80200bf4:	01c0006f          	j	80200c10 <print_dec_int+0x230>
    80200bf8:	f9043783          	ld	a5,-112(s0)
    80200bfc:	0057c783          	lbu	a5,5(a5)
    80200c00:	00078663          	beqz	a5,80200c0c <print_dec_int+0x22c>
    80200c04:	02b00793          	li	a5,43
    80200c08:	0080006f          	j	80200c10 <print_dec_int+0x230>
    80200c0c:	02000793          	li	a5,32
    80200c10:	fa843703          	ld	a4,-88(s0)
    80200c14:	00078513          	mv	a0,a5
    80200c18:	000700e7          	jalr	a4
        ++written;
    80200c1c:	fe442783          	lw	a5,-28(s0)
    80200c20:	0017879b          	addiw	a5,a5,1
    80200c24:	fef42223          	sw	a5,-28(s0)
    }

    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200c28:	fe842783          	lw	a5,-24(s0)
    80200c2c:	fcf42e23          	sw	a5,-36(s0)
    80200c30:	0280006f          	j	80200c58 <print_dec_int+0x278>
        putch('0');
    80200c34:	fa843783          	ld	a5,-88(s0)
    80200c38:	03000513          	li	a0,48
    80200c3c:	000780e7          	jalr	a5
        ++written;
    80200c40:	fe442783          	lw	a5,-28(s0)
    80200c44:	0017879b          	addiw	a5,a5,1
    80200c48:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits; i < flags->prec - has_sign_char; i++) {
    80200c4c:	fdc42783          	lw	a5,-36(s0)
    80200c50:	0017879b          	addiw	a5,a5,1
    80200c54:	fcf42e23          	sw	a5,-36(s0)
    80200c58:	f9043783          	ld	a5,-112(s0)
    80200c5c:	00c7a703          	lw	a4,12(a5)
    80200c60:	fd744783          	lbu	a5,-41(s0)
    80200c64:	0007879b          	sext.w	a5,a5
    80200c68:	40f707bb          	subw	a5,a4,a5
    80200c6c:	0007871b          	sext.w	a4,a5
    80200c70:	fdc42783          	lw	a5,-36(s0)
    80200c74:	0007879b          	sext.w	a5,a5
    80200c78:	fae7cee3          	blt	a5,a4,80200c34 <print_dec_int+0x254>
    }

    for (int i = decdigits - 1; i >= 0; i--) {
    80200c7c:	fe842783          	lw	a5,-24(s0)
    80200c80:	fff7879b          	addiw	a5,a5,-1
    80200c84:	fcf42c23          	sw	a5,-40(s0)
    80200c88:	03c0006f          	j	80200cc4 <print_dec_int+0x2e4>
        putch(buf[i]);
    80200c8c:	fd842783          	lw	a5,-40(s0)
    80200c90:	ff078793          	addi	a5,a5,-16
    80200c94:	008787b3          	add	a5,a5,s0
    80200c98:	fc87c783          	lbu	a5,-56(a5)
    80200c9c:	0007871b          	sext.w	a4,a5
    80200ca0:	fa843783          	ld	a5,-88(s0)
    80200ca4:	00070513          	mv	a0,a4
    80200ca8:	000780e7          	jalr	a5
        ++written;
    80200cac:	fe442783          	lw	a5,-28(s0)
    80200cb0:	0017879b          	addiw	a5,a5,1
    80200cb4:	fef42223          	sw	a5,-28(s0)
    for (int i = decdigits - 1; i >= 0; i--) {
    80200cb8:	fd842783          	lw	a5,-40(s0)
    80200cbc:	fff7879b          	addiw	a5,a5,-1
    80200cc0:	fcf42c23          	sw	a5,-40(s0)
    80200cc4:	fd842783          	lw	a5,-40(s0)
    80200cc8:	0007879b          	sext.w	a5,a5
    80200ccc:	fc07d0e3          	bgez	a5,80200c8c <print_dec_int+0x2ac>
    }

    return written;
    80200cd0:	fe442783          	lw	a5,-28(s0)
}
    80200cd4:	00078513          	mv	a0,a5
    80200cd8:	06813083          	ld	ra,104(sp)
    80200cdc:	06013403          	ld	s0,96(sp)
    80200ce0:	07010113          	addi	sp,sp,112
    80200ce4:	00008067          	ret

0000000080200ce8 <vprintfmt>:

int vprintfmt(int (*putch)(int), const char *fmt, va_list vl) {
    80200ce8:	f4010113          	addi	sp,sp,-192
    80200cec:	0a113c23          	sd	ra,184(sp)
    80200cf0:	0a813823          	sd	s0,176(sp)
    80200cf4:	0c010413          	addi	s0,sp,192
    80200cf8:	f4a43c23          	sd	a0,-168(s0)
    80200cfc:	f4b43823          	sd	a1,-176(s0)
    80200d00:	f4c43423          	sd	a2,-184(s0)
    static const char lowerxdigits[] = "0123456789abcdef";
    static const char upperxdigits[] = "0123456789ABCDEF";

    struct fmt_flags flags = {};
    80200d04:	f8043023          	sd	zero,-128(s0)
    80200d08:	f8043423          	sd	zero,-120(s0)

    int written = 0;
    80200d0c:	fe042623          	sw	zero,-20(s0)

    for (; *fmt; fmt++) {
    80200d10:	7a40006f          	j	802014b4 <vprintfmt+0x7cc>
        if (flags.in_format) {
    80200d14:	f8044783          	lbu	a5,-128(s0)
    80200d18:	72078e63          	beqz	a5,80201454 <vprintfmt+0x76c>
            if (*fmt == '#') {
    80200d1c:	f5043783          	ld	a5,-176(s0)
    80200d20:	0007c783          	lbu	a5,0(a5)
    80200d24:	00078713          	mv	a4,a5
    80200d28:	02300793          	li	a5,35
    80200d2c:	00f71863          	bne	a4,a5,80200d3c <vprintfmt+0x54>
                flags.sharpflag = true;
    80200d30:	00100793          	li	a5,1
    80200d34:	f8f40123          	sb	a5,-126(s0)
    80200d38:	7700006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == '0') {
    80200d3c:	f5043783          	ld	a5,-176(s0)
    80200d40:	0007c783          	lbu	a5,0(a5)
    80200d44:	00078713          	mv	a4,a5
    80200d48:	03000793          	li	a5,48
    80200d4c:	00f71863          	bne	a4,a5,80200d5c <vprintfmt+0x74>
                flags.zeroflag = true;
    80200d50:	00100793          	li	a5,1
    80200d54:	f8f401a3          	sb	a5,-125(s0)
    80200d58:	7500006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == 'l' || *fmt == 'z' || *fmt == 't' || *fmt == 'j') {
    80200d5c:	f5043783          	ld	a5,-176(s0)
    80200d60:	0007c783          	lbu	a5,0(a5)
    80200d64:	00078713          	mv	a4,a5
    80200d68:	06c00793          	li	a5,108
    80200d6c:	04f70063          	beq	a4,a5,80200dac <vprintfmt+0xc4>
    80200d70:	f5043783          	ld	a5,-176(s0)
    80200d74:	0007c783          	lbu	a5,0(a5)
    80200d78:	00078713          	mv	a4,a5
    80200d7c:	07a00793          	li	a5,122
    80200d80:	02f70663          	beq	a4,a5,80200dac <vprintfmt+0xc4>
    80200d84:	f5043783          	ld	a5,-176(s0)
    80200d88:	0007c783          	lbu	a5,0(a5)
    80200d8c:	00078713          	mv	a4,a5
    80200d90:	07400793          	li	a5,116
    80200d94:	00f70c63          	beq	a4,a5,80200dac <vprintfmt+0xc4>
    80200d98:	f5043783          	ld	a5,-176(s0)
    80200d9c:	0007c783          	lbu	a5,0(a5)
    80200da0:	00078713          	mv	a4,a5
    80200da4:	06a00793          	li	a5,106
    80200da8:	00f71863          	bne	a4,a5,80200db8 <vprintfmt+0xd0>
                // l: long, z: size_t, t: ptrdiff_t, j: intmax_t
                flags.longflag = true;
    80200dac:	00100793          	li	a5,1
    80200db0:	f8f400a3          	sb	a5,-127(s0)
    80200db4:	6f40006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == '+') {
    80200db8:	f5043783          	ld	a5,-176(s0)
    80200dbc:	0007c783          	lbu	a5,0(a5)
    80200dc0:	00078713          	mv	a4,a5
    80200dc4:	02b00793          	li	a5,43
    80200dc8:	00f71863          	bne	a4,a5,80200dd8 <vprintfmt+0xf0>
                flags.sign = true;
    80200dcc:	00100793          	li	a5,1
    80200dd0:	f8f402a3          	sb	a5,-123(s0)
    80200dd4:	6d40006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == ' ') {
    80200dd8:	f5043783          	ld	a5,-176(s0)
    80200ddc:	0007c783          	lbu	a5,0(a5)
    80200de0:	00078713          	mv	a4,a5
    80200de4:	02000793          	li	a5,32
    80200de8:	00f71863          	bne	a4,a5,80200df8 <vprintfmt+0x110>
                flags.spaceflag = true;
    80200dec:	00100793          	li	a5,1
    80200df0:	f8f40223          	sb	a5,-124(s0)
    80200df4:	6b40006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == '*') {
    80200df8:	f5043783          	ld	a5,-176(s0)
    80200dfc:	0007c783          	lbu	a5,0(a5)
    80200e00:	00078713          	mv	a4,a5
    80200e04:	02a00793          	li	a5,42
    80200e08:	00f71e63          	bne	a4,a5,80200e24 <vprintfmt+0x13c>
                flags.width = va_arg(vl, int);
    80200e0c:	f4843783          	ld	a5,-184(s0)
    80200e10:	00878713          	addi	a4,a5,8
    80200e14:	f4e43423          	sd	a4,-184(s0)
    80200e18:	0007a783          	lw	a5,0(a5)
    80200e1c:	f8f42423          	sw	a5,-120(s0)
    80200e20:	6880006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt >= '1' && *fmt <= '9') {
    80200e24:	f5043783          	ld	a5,-176(s0)
    80200e28:	0007c783          	lbu	a5,0(a5)
    80200e2c:	00078713          	mv	a4,a5
    80200e30:	03000793          	li	a5,48
    80200e34:	04e7f663          	bgeu	a5,a4,80200e80 <vprintfmt+0x198>
    80200e38:	f5043783          	ld	a5,-176(s0)
    80200e3c:	0007c783          	lbu	a5,0(a5)
    80200e40:	00078713          	mv	a4,a5
    80200e44:	03900793          	li	a5,57
    80200e48:	02e7ec63          	bltu	a5,a4,80200e80 <vprintfmt+0x198>
                flags.width = strtol(fmt, (char **)&fmt, 10);
    80200e4c:	f5043783          	ld	a5,-176(s0)
    80200e50:	f5040713          	addi	a4,s0,-176
    80200e54:	00a00613          	li	a2,10
    80200e58:	00070593          	mv	a1,a4
    80200e5c:	00078513          	mv	a0,a5
    80200e60:	88dff0ef          	jal	ra,802006ec <strtol>
    80200e64:	00050793          	mv	a5,a0
    80200e68:	0007879b          	sext.w	a5,a5
    80200e6c:	f8f42423          	sw	a5,-120(s0)
                fmt--;
    80200e70:	f5043783          	ld	a5,-176(s0)
    80200e74:	fff78793          	addi	a5,a5,-1
    80200e78:	f4f43823          	sd	a5,-176(s0)
    80200e7c:	62c0006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == '.') {
    80200e80:	f5043783          	ld	a5,-176(s0)
    80200e84:	0007c783          	lbu	a5,0(a5)
    80200e88:	00078713          	mv	a4,a5
    80200e8c:	02e00793          	li	a5,46
    80200e90:	06f71863          	bne	a4,a5,80200f00 <vprintfmt+0x218>
                fmt++;
    80200e94:	f5043783          	ld	a5,-176(s0)
    80200e98:	00178793          	addi	a5,a5,1
    80200e9c:	f4f43823          	sd	a5,-176(s0)
                if (*fmt == '*') {
    80200ea0:	f5043783          	ld	a5,-176(s0)
    80200ea4:	0007c783          	lbu	a5,0(a5)
    80200ea8:	00078713          	mv	a4,a5
    80200eac:	02a00793          	li	a5,42
    80200eb0:	00f71e63          	bne	a4,a5,80200ecc <vprintfmt+0x1e4>
                    flags.prec = va_arg(vl, int);
    80200eb4:	f4843783          	ld	a5,-184(s0)
    80200eb8:	00878713          	addi	a4,a5,8
    80200ebc:	f4e43423          	sd	a4,-184(s0)
    80200ec0:	0007a783          	lw	a5,0(a5)
    80200ec4:	f8f42623          	sw	a5,-116(s0)
    80200ec8:	5e00006f          	j	802014a8 <vprintfmt+0x7c0>
                } else {
                    flags.prec = strtol(fmt, (char **)&fmt, 10);
    80200ecc:	f5043783          	ld	a5,-176(s0)
    80200ed0:	f5040713          	addi	a4,s0,-176
    80200ed4:	00a00613          	li	a2,10
    80200ed8:	00070593          	mv	a1,a4
    80200edc:	00078513          	mv	a0,a5
    80200ee0:	80dff0ef          	jal	ra,802006ec <strtol>
    80200ee4:	00050793          	mv	a5,a0
    80200ee8:	0007879b          	sext.w	a5,a5
    80200eec:	f8f42623          	sw	a5,-116(s0)
                    fmt--;
    80200ef0:	f5043783          	ld	a5,-176(s0)
    80200ef4:	fff78793          	addi	a5,a5,-1
    80200ef8:	f4f43823          	sd	a5,-176(s0)
    80200efc:	5ac0006f          	j	802014a8 <vprintfmt+0x7c0>
                }
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80200f00:	f5043783          	ld	a5,-176(s0)
    80200f04:	0007c783          	lbu	a5,0(a5)
    80200f08:	00078713          	mv	a4,a5
    80200f0c:	07800793          	li	a5,120
    80200f10:	02f70663          	beq	a4,a5,80200f3c <vprintfmt+0x254>
    80200f14:	f5043783          	ld	a5,-176(s0)
    80200f18:	0007c783          	lbu	a5,0(a5)
    80200f1c:	00078713          	mv	a4,a5
    80200f20:	05800793          	li	a5,88
    80200f24:	00f70c63          	beq	a4,a5,80200f3c <vprintfmt+0x254>
    80200f28:	f5043783          	ld	a5,-176(s0)
    80200f2c:	0007c783          	lbu	a5,0(a5)
    80200f30:	00078713          	mv	a4,a5
    80200f34:	07000793          	li	a5,112
    80200f38:	30f71263          	bne	a4,a5,8020123c <vprintfmt+0x554>
                bool is_long = *fmt == 'p' || flags.longflag;
    80200f3c:	f5043783          	ld	a5,-176(s0)
    80200f40:	0007c783          	lbu	a5,0(a5)
    80200f44:	00078713          	mv	a4,a5
    80200f48:	07000793          	li	a5,112
    80200f4c:	00f70663          	beq	a4,a5,80200f58 <vprintfmt+0x270>
    80200f50:	f8144783          	lbu	a5,-127(s0)
    80200f54:	00078663          	beqz	a5,80200f60 <vprintfmt+0x278>
    80200f58:	00100793          	li	a5,1
    80200f5c:	0080006f          	j	80200f64 <vprintfmt+0x27c>
    80200f60:	00000793          	li	a5,0
    80200f64:	faf403a3          	sb	a5,-89(s0)
    80200f68:	fa744783          	lbu	a5,-89(s0)
    80200f6c:	0017f793          	andi	a5,a5,1
    80200f70:	faf403a3          	sb	a5,-89(s0)

                unsigned long num = is_long ? va_arg(vl, unsigned long) : va_arg(vl, unsigned int);
    80200f74:	fa744783          	lbu	a5,-89(s0)
    80200f78:	0ff7f793          	zext.b	a5,a5
    80200f7c:	00078c63          	beqz	a5,80200f94 <vprintfmt+0x2ac>
    80200f80:	f4843783          	ld	a5,-184(s0)
    80200f84:	00878713          	addi	a4,a5,8
    80200f88:	f4e43423          	sd	a4,-184(s0)
    80200f8c:	0007b783          	ld	a5,0(a5)
    80200f90:	01c0006f          	j	80200fac <vprintfmt+0x2c4>
    80200f94:	f4843783          	ld	a5,-184(s0)
    80200f98:	00878713          	addi	a4,a5,8
    80200f9c:	f4e43423          	sd	a4,-184(s0)
    80200fa0:	0007a783          	lw	a5,0(a5)
    80200fa4:	02079793          	slli	a5,a5,0x20
    80200fa8:	0207d793          	srli	a5,a5,0x20
    80200fac:	fef43023          	sd	a5,-32(s0)

                if (flags.prec == 0 && num == 0 && *fmt != 'p') {
    80200fb0:	f8c42783          	lw	a5,-116(s0)
    80200fb4:	02079463          	bnez	a5,80200fdc <vprintfmt+0x2f4>
    80200fb8:	fe043783          	ld	a5,-32(s0)
    80200fbc:	02079063          	bnez	a5,80200fdc <vprintfmt+0x2f4>
    80200fc0:	f5043783          	ld	a5,-176(s0)
    80200fc4:	0007c783          	lbu	a5,0(a5)
    80200fc8:	00078713          	mv	a4,a5
    80200fcc:	07000793          	li	a5,112
    80200fd0:	00f70663          	beq	a4,a5,80200fdc <vprintfmt+0x2f4>
                    flags.in_format = false;
    80200fd4:	f8040023          	sb	zero,-128(s0)
    80200fd8:	4d00006f          	j	802014a8 <vprintfmt+0x7c0>
                    continue;
                }

                // 0x prefix for pointers, or, if # flag is set and non-zero
                bool prefix = *fmt == 'p' || (flags.sharpflag && num != 0);
    80200fdc:	f5043783          	ld	a5,-176(s0)
    80200fe0:	0007c783          	lbu	a5,0(a5)
    80200fe4:	00078713          	mv	a4,a5
    80200fe8:	07000793          	li	a5,112
    80200fec:	00f70a63          	beq	a4,a5,80201000 <vprintfmt+0x318>
    80200ff0:	f8244783          	lbu	a5,-126(s0)
    80200ff4:	00078a63          	beqz	a5,80201008 <vprintfmt+0x320>
    80200ff8:	fe043783          	ld	a5,-32(s0)
    80200ffc:	00078663          	beqz	a5,80201008 <vprintfmt+0x320>
    80201000:	00100793          	li	a5,1
    80201004:	0080006f          	j	8020100c <vprintfmt+0x324>
    80201008:	00000793          	li	a5,0
    8020100c:	faf40323          	sb	a5,-90(s0)
    80201010:	fa644783          	lbu	a5,-90(s0)
    80201014:	0017f793          	andi	a5,a5,1
    80201018:	faf40323          	sb	a5,-90(s0)

                int hexdigits = 0;
    8020101c:	fc042e23          	sw	zero,-36(s0)
                const char *xdigits = *fmt == 'X' ? upperxdigits : lowerxdigits;
    80201020:	f5043783          	ld	a5,-176(s0)
    80201024:	0007c783          	lbu	a5,0(a5)
    80201028:	00078713          	mv	a4,a5
    8020102c:	05800793          	li	a5,88
    80201030:	00f71863          	bne	a4,a5,80201040 <vprintfmt+0x358>
    80201034:	00001797          	auipc	a5,0x1
    80201038:	0a478793          	addi	a5,a5,164 # 802020d8 <upperxdigits.1>
    8020103c:	00c0006f          	j	80201048 <vprintfmt+0x360>
    80201040:	00001797          	auipc	a5,0x1
    80201044:	0b078793          	addi	a5,a5,176 # 802020f0 <lowerxdigits.0>
    80201048:	f8f43c23          	sd	a5,-104(s0)
                char buf[2 * sizeof(unsigned long)];

                do {
                    buf[hexdigits++] = xdigits[num & 0xf];
    8020104c:	fe043783          	ld	a5,-32(s0)
    80201050:	00f7f793          	andi	a5,a5,15
    80201054:	f9843703          	ld	a4,-104(s0)
    80201058:	00f70733          	add	a4,a4,a5
    8020105c:	fdc42783          	lw	a5,-36(s0)
    80201060:	0017869b          	addiw	a3,a5,1
    80201064:	fcd42e23          	sw	a3,-36(s0)
    80201068:	00074703          	lbu	a4,0(a4)
    8020106c:	ff078793          	addi	a5,a5,-16
    80201070:	008787b3          	add	a5,a5,s0
    80201074:	f8e78023          	sb	a4,-128(a5)
                    num >>= 4;
    80201078:	fe043783          	ld	a5,-32(s0)
    8020107c:	0047d793          	srli	a5,a5,0x4
    80201080:	fef43023          	sd	a5,-32(s0)
                } while (num);
    80201084:	fe043783          	ld	a5,-32(s0)
    80201088:	fc0792e3          	bnez	a5,8020104c <vprintfmt+0x364>

                if (flags.prec == -1 && flags.zeroflag) {
    8020108c:	f8c42783          	lw	a5,-116(s0)
    80201090:	00078713          	mv	a4,a5
    80201094:	fff00793          	li	a5,-1
    80201098:	02f71663          	bne	a4,a5,802010c4 <vprintfmt+0x3dc>
    8020109c:	f8344783          	lbu	a5,-125(s0)
    802010a0:	02078263          	beqz	a5,802010c4 <vprintfmt+0x3dc>
                    flags.prec = flags.width - 2 * prefix;
    802010a4:	f8842703          	lw	a4,-120(s0)
    802010a8:	fa644783          	lbu	a5,-90(s0)
    802010ac:	0007879b          	sext.w	a5,a5
    802010b0:	0017979b          	slliw	a5,a5,0x1
    802010b4:	0007879b          	sext.w	a5,a5
    802010b8:	40f707bb          	subw	a5,a4,a5
    802010bc:	0007879b          	sext.w	a5,a5
    802010c0:	f8f42623          	sw	a5,-116(s0)
                }

                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    802010c4:	f8842703          	lw	a4,-120(s0)
    802010c8:	fa644783          	lbu	a5,-90(s0)
    802010cc:	0007879b          	sext.w	a5,a5
    802010d0:	0017979b          	slliw	a5,a5,0x1
    802010d4:	0007879b          	sext.w	a5,a5
    802010d8:	40f707bb          	subw	a5,a4,a5
    802010dc:	0007871b          	sext.w	a4,a5
    802010e0:	fdc42783          	lw	a5,-36(s0)
    802010e4:	f8f42a23          	sw	a5,-108(s0)
    802010e8:	f8c42783          	lw	a5,-116(s0)
    802010ec:	f8f42823          	sw	a5,-112(s0)
    802010f0:	f9442783          	lw	a5,-108(s0)
    802010f4:	00078593          	mv	a1,a5
    802010f8:	f9042783          	lw	a5,-112(s0)
    802010fc:	00078613          	mv	a2,a5
    80201100:	0006069b          	sext.w	a3,a2
    80201104:	0005879b          	sext.w	a5,a1
    80201108:	00f6d463          	bge	a3,a5,80201110 <vprintfmt+0x428>
    8020110c:	00058613          	mv	a2,a1
    80201110:	0006079b          	sext.w	a5,a2
    80201114:	40f707bb          	subw	a5,a4,a5
    80201118:	fcf42c23          	sw	a5,-40(s0)
    8020111c:	0280006f          	j	80201144 <vprintfmt+0x45c>
                    putch(' ');
    80201120:	f5843783          	ld	a5,-168(s0)
    80201124:	02000513          	li	a0,32
    80201128:	000780e7          	jalr	a5
                    ++written;
    8020112c:	fec42783          	lw	a5,-20(s0)
    80201130:	0017879b          	addiw	a5,a5,1
    80201134:	fef42623          	sw	a5,-20(s0)
                for (int i = flags.width - 2 * prefix - __MAX(hexdigits, flags.prec); i > 0; i--) {
    80201138:	fd842783          	lw	a5,-40(s0)
    8020113c:	fff7879b          	addiw	a5,a5,-1
    80201140:	fcf42c23          	sw	a5,-40(s0)
    80201144:	fd842783          	lw	a5,-40(s0)
    80201148:	0007879b          	sext.w	a5,a5
    8020114c:	fcf04ae3          	bgtz	a5,80201120 <vprintfmt+0x438>
                }

                if (prefix) {
    80201150:	fa644783          	lbu	a5,-90(s0)
    80201154:	0ff7f793          	zext.b	a5,a5
    80201158:	04078463          	beqz	a5,802011a0 <vprintfmt+0x4b8>
                    putch('0');
    8020115c:	f5843783          	ld	a5,-168(s0)
    80201160:	03000513          	li	a0,48
    80201164:	000780e7          	jalr	a5
                    putch(*fmt == 'X' ? 'X' : 'x');
    80201168:	f5043783          	ld	a5,-176(s0)
    8020116c:	0007c783          	lbu	a5,0(a5)
    80201170:	00078713          	mv	a4,a5
    80201174:	05800793          	li	a5,88
    80201178:	00f71663          	bne	a4,a5,80201184 <vprintfmt+0x49c>
    8020117c:	05800793          	li	a5,88
    80201180:	0080006f          	j	80201188 <vprintfmt+0x4a0>
    80201184:	07800793          	li	a5,120
    80201188:	f5843703          	ld	a4,-168(s0)
    8020118c:	00078513          	mv	a0,a5
    80201190:	000700e7          	jalr	a4
                    written += 2;
    80201194:	fec42783          	lw	a5,-20(s0)
    80201198:	0027879b          	addiw	a5,a5,2
    8020119c:	fef42623          	sw	a5,-20(s0)
                }

                for (int i = hexdigits; i < flags.prec; i++) {
    802011a0:	fdc42783          	lw	a5,-36(s0)
    802011a4:	fcf42a23          	sw	a5,-44(s0)
    802011a8:	0280006f          	j	802011d0 <vprintfmt+0x4e8>
                    putch('0');
    802011ac:	f5843783          	ld	a5,-168(s0)
    802011b0:	03000513          	li	a0,48
    802011b4:	000780e7          	jalr	a5
                    ++written;
    802011b8:	fec42783          	lw	a5,-20(s0)
    802011bc:	0017879b          	addiw	a5,a5,1
    802011c0:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits; i < flags.prec; i++) {
    802011c4:	fd442783          	lw	a5,-44(s0)
    802011c8:	0017879b          	addiw	a5,a5,1
    802011cc:	fcf42a23          	sw	a5,-44(s0)
    802011d0:	f8c42703          	lw	a4,-116(s0)
    802011d4:	fd442783          	lw	a5,-44(s0)
    802011d8:	0007879b          	sext.w	a5,a5
    802011dc:	fce7c8e3          	blt	a5,a4,802011ac <vprintfmt+0x4c4>
                }

                for (int i = hexdigits - 1; i >= 0; i--) {
    802011e0:	fdc42783          	lw	a5,-36(s0)
    802011e4:	fff7879b          	addiw	a5,a5,-1
    802011e8:	fcf42823          	sw	a5,-48(s0)
    802011ec:	03c0006f          	j	80201228 <vprintfmt+0x540>
                    putch(buf[i]);
    802011f0:	fd042783          	lw	a5,-48(s0)
    802011f4:	ff078793          	addi	a5,a5,-16
    802011f8:	008787b3          	add	a5,a5,s0
    802011fc:	f807c783          	lbu	a5,-128(a5)
    80201200:	0007871b          	sext.w	a4,a5
    80201204:	f5843783          	ld	a5,-168(s0)
    80201208:	00070513          	mv	a0,a4
    8020120c:	000780e7          	jalr	a5
                    ++written;
    80201210:	fec42783          	lw	a5,-20(s0)
    80201214:	0017879b          	addiw	a5,a5,1
    80201218:	fef42623          	sw	a5,-20(s0)
                for (int i = hexdigits - 1; i >= 0; i--) {
    8020121c:	fd042783          	lw	a5,-48(s0)
    80201220:	fff7879b          	addiw	a5,a5,-1
    80201224:	fcf42823          	sw	a5,-48(s0)
    80201228:	fd042783          	lw	a5,-48(s0)
    8020122c:	0007879b          	sext.w	a5,a5
    80201230:	fc07d0e3          	bgez	a5,802011f0 <vprintfmt+0x508>
                }

                flags.in_format = false;
    80201234:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'x' || *fmt == 'X' || *fmt == 'p') {
    80201238:	2700006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    8020123c:	f5043783          	ld	a5,-176(s0)
    80201240:	0007c783          	lbu	a5,0(a5)
    80201244:	00078713          	mv	a4,a5
    80201248:	06400793          	li	a5,100
    8020124c:	02f70663          	beq	a4,a5,80201278 <vprintfmt+0x590>
    80201250:	f5043783          	ld	a5,-176(s0)
    80201254:	0007c783          	lbu	a5,0(a5)
    80201258:	00078713          	mv	a4,a5
    8020125c:	06900793          	li	a5,105
    80201260:	00f70c63          	beq	a4,a5,80201278 <vprintfmt+0x590>
    80201264:	f5043783          	ld	a5,-176(s0)
    80201268:	0007c783          	lbu	a5,0(a5)
    8020126c:	00078713          	mv	a4,a5
    80201270:	07500793          	li	a5,117
    80201274:	08f71063          	bne	a4,a5,802012f4 <vprintfmt+0x60c>
                long num = flags.longflag ? va_arg(vl, long) : va_arg(vl, int);
    80201278:	f8144783          	lbu	a5,-127(s0)
    8020127c:	00078c63          	beqz	a5,80201294 <vprintfmt+0x5ac>
    80201280:	f4843783          	ld	a5,-184(s0)
    80201284:	00878713          	addi	a4,a5,8
    80201288:	f4e43423          	sd	a4,-184(s0)
    8020128c:	0007b783          	ld	a5,0(a5)
    80201290:	0140006f          	j	802012a4 <vprintfmt+0x5bc>
    80201294:	f4843783          	ld	a5,-184(s0)
    80201298:	00878713          	addi	a4,a5,8
    8020129c:	f4e43423          	sd	a4,-184(s0)
    802012a0:	0007a783          	lw	a5,0(a5)
    802012a4:	faf43423          	sd	a5,-88(s0)

                written += print_dec_int(putch, num, *fmt != 'u', &flags);
    802012a8:	fa843583          	ld	a1,-88(s0)
    802012ac:	f5043783          	ld	a5,-176(s0)
    802012b0:	0007c783          	lbu	a5,0(a5)
    802012b4:	0007871b          	sext.w	a4,a5
    802012b8:	07500793          	li	a5,117
    802012bc:	40f707b3          	sub	a5,a4,a5
    802012c0:	00f037b3          	snez	a5,a5
    802012c4:	0ff7f793          	zext.b	a5,a5
    802012c8:	f8040713          	addi	a4,s0,-128
    802012cc:	00070693          	mv	a3,a4
    802012d0:	00078613          	mv	a2,a5
    802012d4:	f5843503          	ld	a0,-168(s0)
    802012d8:	f08ff0ef          	jal	ra,802009e0 <print_dec_int>
    802012dc:	00050793          	mv	a5,a0
    802012e0:	fec42703          	lw	a4,-20(s0)
    802012e4:	00f707bb          	addw	a5,a4,a5
    802012e8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802012ec:	f8040023          	sb	zero,-128(s0)
            } else if (*fmt == 'd' || *fmt == 'i' || *fmt == 'u') {
    802012f0:	1b80006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == 'n') {
    802012f4:	f5043783          	ld	a5,-176(s0)
    802012f8:	0007c783          	lbu	a5,0(a5)
    802012fc:	00078713          	mv	a4,a5
    80201300:	06e00793          	li	a5,110
    80201304:	04f71c63          	bne	a4,a5,8020135c <vprintfmt+0x674>
                if (flags.longflag) {
    80201308:	f8144783          	lbu	a5,-127(s0)
    8020130c:	02078463          	beqz	a5,80201334 <vprintfmt+0x64c>
                    long *n = va_arg(vl, long *);
    80201310:	f4843783          	ld	a5,-184(s0)
    80201314:	00878713          	addi	a4,a5,8
    80201318:	f4e43423          	sd	a4,-184(s0)
    8020131c:	0007b783          	ld	a5,0(a5)
    80201320:	faf43823          	sd	a5,-80(s0)
                    *n = written;
    80201324:	fec42703          	lw	a4,-20(s0)
    80201328:	fb043783          	ld	a5,-80(s0)
    8020132c:	00e7b023          	sd	a4,0(a5)
    80201330:	0240006f          	j	80201354 <vprintfmt+0x66c>
                } else {
                    int *n = va_arg(vl, int *);
    80201334:	f4843783          	ld	a5,-184(s0)
    80201338:	00878713          	addi	a4,a5,8
    8020133c:	f4e43423          	sd	a4,-184(s0)
    80201340:	0007b783          	ld	a5,0(a5)
    80201344:	faf43c23          	sd	a5,-72(s0)
                    *n = written;
    80201348:	fb843783          	ld	a5,-72(s0)
    8020134c:	fec42703          	lw	a4,-20(s0)
    80201350:	00e7a023          	sw	a4,0(a5)
                }
                flags.in_format = false;
    80201354:	f8040023          	sb	zero,-128(s0)
    80201358:	1500006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == 's') {
    8020135c:	f5043783          	ld	a5,-176(s0)
    80201360:	0007c783          	lbu	a5,0(a5)
    80201364:	00078713          	mv	a4,a5
    80201368:	07300793          	li	a5,115
    8020136c:	02f71e63          	bne	a4,a5,802013a8 <vprintfmt+0x6c0>
                const char *s = va_arg(vl, const char *);
    80201370:	f4843783          	ld	a5,-184(s0)
    80201374:	00878713          	addi	a4,a5,8
    80201378:	f4e43423          	sd	a4,-184(s0)
    8020137c:	0007b783          	ld	a5,0(a5)
    80201380:	fcf43023          	sd	a5,-64(s0)
                written += puts_wo_nl(putch, s);
    80201384:	fc043583          	ld	a1,-64(s0)
    80201388:	f5843503          	ld	a0,-168(s0)
    8020138c:	dccff0ef          	jal	ra,80200958 <puts_wo_nl>
    80201390:	00050793          	mv	a5,a0
    80201394:	fec42703          	lw	a4,-20(s0)
    80201398:	00f707bb          	addw	a5,a4,a5
    8020139c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013a0:	f8040023          	sb	zero,-128(s0)
    802013a4:	1040006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == 'c') {
    802013a8:	f5043783          	ld	a5,-176(s0)
    802013ac:	0007c783          	lbu	a5,0(a5)
    802013b0:	00078713          	mv	a4,a5
    802013b4:	06300793          	li	a5,99
    802013b8:	02f71e63          	bne	a4,a5,802013f4 <vprintfmt+0x70c>
                int ch = va_arg(vl, int);
    802013bc:	f4843783          	ld	a5,-184(s0)
    802013c0:	00878713          	addi	a4,a5,8
    802013c4:	f4e43423          	sd	a4,-184(s0)
    802013c8:	0007a783          	lw	a5,0(a5)
    802013cc:	fcf42623          	sw	a5,-52(s0)
                putch(ch);
    802013d0:	fcc42703          	lw	a4,-52(s0)
    802013d4:	f5843783          	ld	a5,-168(s0)
    802013d8:	00070513          	mv	a0,a4
    802013dc:	000780e7          	jalr	a5
                ++written;
    802013e0:	fec42783          	lw	a5,-20(s0)
    802013e4:	0017879b          	addiw	a5,a5,1
    802013e8:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    802013ec:	f8040023          	sb	zero,-128(s0)
    802013f0:	0b80006f          	j	802014a8 <vprintfmt+0x7c0>
            } else if (*fmt == '%') {
    802013f4:	f5043783          	ld	a5,-176(s0)
    802013f8:	0007c783          	lbu	a5,0(a5)
    802013fc:	00078713          	mv	a4,a5
    80201400:	02500793          	li	a5,37
    80201404:	02f71263          	bne	a4,a5,80201428 <vprintfmt+0x740>
                putch('%');
    80201408:	f5843783          	ld	a5,-168(s0)
    8020140c:	02500513          	li	a0,37
    80201410:	000780e7          	jalr	a5
                ++written;
    80201414:	fec42783          	lw	a5,-20(s0)
    80201418:	0017879b          	addiw	a5,a5,1
    8020141c:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    80201420:	f8040023          	sb	zero,-128(s0)
    80201424:	0840006f          	j	802014a8 <vprintfmt+0x7c0>
            } else {
                putch(*fmt);
    80201428:	f5043783          	ld	a5,-176(s0)
    8020142c:	0007c783          	lbu	a5,0(a5)
    80201430:	0007871b          	sext.w	a4,a5
    80201434:	f5843783          	ld	a5,-168(s0)
    80201438:	00070513          	mv	a0,a4
    8020143c:	000780e7          	jalr	a5
                ++written;
    80201440:	fec42783          	lw	a5,-20(s0)
    80201444:	0017879b          	addiw	a5,a5,1
    80201448:	fef42623          	sw	a5,-20(s0)
                flags.in_format = false;
    8020144c:	f8040023          	sb	zero,-128(s0)
    80201450:	0580006f          	j	802014a8 <vprintfmt+0x7c0>
            }
        } else if (*fmt == '%') {
    80201454:	f5043783          	ld	a5,-176(s0)
    80201458:	0007c783          	lbu	a5,0(a5)
    8020145c:	00078713          	mv	a4,a5
    80201460:	02500793          	li	a5,37
    80201464:	02f71063          	bne	a4,a5,80201484 <vprintfmt+0x79c>
            flags = (struct fmt_flags) {.in_format = true, .prec = -1};
    80201468:	f8043023          	sd	zero,-128(s0)
    8020146c:	f8043423          	sd	zero,-120(s0)
    80201470:	00100793          	li	a5,1
    80201474:	f8f40023          	sb	a5,-128(s0)
    80201478:	fff00793          	li	a5,-1
    8020147c:	f8f42623          	sw	a5,-116(s0)
    80201480:	0280006f          	j	802014a8 <vprintfmt+0x7c0>
        } else {
            putch(*fmt);
    80201484:	f5043783          	ld	a5,-176(s0)
    80201488:	0007c783          	lbu	a5,0(a5)
    8020148c:	0007871b          	sext.w	a4,a5
    80201490:	f5843783          	ld	a5,-168(s0)
    80201494:	00070513          	mv	a0,a4
    80201498:	000780e7          	jalr	a5
            ++written;
    8020149c:	fec42783          	lw	a5,-20(s0)
    802014a0:	0017879b          	addiw	a5,a5,1
    802014a4:	fef42623          	sw	a5,-20(s0)
    for (; *fmt; fmt++) {
    802014a8:	f5043783          	ld	a5,-176(s0)
    802014ac:	00178793          	addi	a5,a5,1
    802014b0:	f4f43823          	sd	a5,-176(s0)
    802014b4:	f5043783          	ld	a5,-176(s0)
    802014b8:	0007c783          	lbu	a5,0(a5)
    802014bc:	84079ce3          	bnez	a5,80200d14 <vprintfmt+0x2c>
        }
    }

    return written;
    802014c0:	fec42783          	lw	a5,-20(s0)
}
    802014c4:	00078513          	mv	a0,a5
    802014c8:	0b813083          	ld	ra,184(sp)
    802014cc:	0b013403          	ld	s0,176(sp)
    802014d0:	0c010113          	addi	sp,sp,192
    802014d4:	00008067          	ret

00000000802014d8 <printk>:

int printk(const char* s, ...) {
    802014d8:	f9010113          	addi	sp,sp,-112
    802014dc:	02113423          	sd	ra,40(sp)
    802014e0:	02813023          	sd	s0,32(sp)
    802014e4:	03010413          	addi	s0,sp,48
    802014e8:	fca43c23          	sd	a0,-40(s0)
    802014ec:	00b43423          	sd	a1,8(s0)
    802014f0:	00c43823          	sd	a2,16(s0)
    802014f4:	00d43c23          	sd	a3,24(s0)
    802014f8:	02e43023          	sd	a4,32(s0)
    802014fc:	02f43423          	sd	a5,40(s0)
    80201500:	03043823          	sd	a6,48(s0)
    80201504:	03143c23          	sd	a7,56(s0)
    int res = 0;
    80201508:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
    8020150c:	04040793          	addi	a5,s0,64
    80201510:	fcf43823          	sd	a5,-48(s0)
    80201514:	fd043783          	ld	a5,-48(s0)
    80201518:	fc878793          	addi	a5,a5,-56
    8020151c:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
    80201520:	fe043783          	ld	a5,-32(s0)
    80201524:	00078613          	mv	a2,a5
    80201528:	fd843583          	ld	a1,-40(s0)
    8020152c:	fffff517          	auipc	a0,0xfffff
    80201530:	11850513          	addi	a0,a0,280 # 80200644 <putc>
    80201534:	fb4ff0ef          	jal	ra,80200ce8 <vprintfmt>
    80201538:	00050793          	mv	a5,a0
    8020153c:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
    80201540:	fec42783          	lw	a5,-20(s0)
}
    80201544:	00078513          	mv	a0,a5
    80201548:	02813083          	ld	ra,40(sp)
    8020154c:	02013403          	ld	s0,32(sp)
    80201550:	07010113          	addi	sp,sp,112
    80201554:	00008067          	ret
