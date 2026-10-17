/* SPDX-License-Identifier: BSD-3-Clause */
/* Minimal environment adapter for public riscv-tests RV32UI instruction tests. */
#ifndef TITORV_RISCV_TEST_H
#define TITORV_RISCV_TEST_H

#define RVTEST_RV32U \
.macro init; \
.endm

#define RVTEST_CODE_BEGIN \
.section .text.init; \
.align 2; \
.globl _start; \
_start: \
init;

#define RVTEST_CODE_END

#define TESTNUM gp

#define RVTEST_PASS \
li a7, 93; \
li a0, 0; \
ecall

#define RVTEST_FAIL \
sll a0, TESTNUM, 1; \
or a0, a0, 1; \
li a7, 93; \
ecall

#define RVTEST_DATA_BEGIN \
.align 4; \
.global begin_signature; \
begin_signature:

#define RVTEST_DATA_END \
.align 4; \
.global end_signature; \
end_signature:

#endif
