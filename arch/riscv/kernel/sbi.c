#include "stdint.h"
#include "sbi.h"

struct sbiret sbi_ecall(uint64_t eid, uint64_t fid,
                        uint64_t arg0, uint64_t arg1, uint64_t arg2,
                        uint64_t arg3, uint64_t arg4, uint64_t arg5) {
    
    struct sbiret sbiRet;

    asm volatile (
        "add a7, zero, %2\n"
        "add a6, zero, %3\n"
        "add a0, zero, %4\n"
        "add a1, zero, %5\n"
        "add a2, zero, %6\n"
        "add a3, zero, %7\n"
        "add a4, zero, %8\n"
        "add a5, zero, %9\n"
        "ecall\n"
        "addi %0, a0, 0\n"
        "addi %1, a1, 0\n"
        : "=r"(sbiRet.error), "=r"(sbiRet.value)
        : "r"(eid), "r"(fid), "r"(arg0), "r"(arg1), "r"(arg2), "r"(arg3), "r"(arg4), "r"(arg5)
        : "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7"
    );

    return sbiRet;
}

struct sbiret sbi_debug_console_write_byte(uint8_t byte) {
    return sbi_ecall(0x4442434E, 0x2, byte, 0, 0, 0, 0, 0);
}

struct sbiret sbi_system_reset(uint32_t reset_type, uint32_t reset_reason) {
    return sbi_ecall(0x53525354, 0x0, reset_type, reset_reason, 0, 0, 0, 0);
}

struct sbiret sbi_set_timer(uint64_t stime_value){
    return sbi_ecall(0x54494d45, 0x0, stime_value, 0, 0, 0, 0, 0);
}