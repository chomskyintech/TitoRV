.option norvc
.section .text
.globl _start
_start:
    addi x1, x0, 5
    addi x2, x0, 5
    beq  x1, x2, branch_taken
    addi x3, x0, 99          # Must be flushed; must not retire.
branch_taken:
    addi x3, x0, 7
    sw   x3, 0(x0)
    lw   x4, 0(x0)
    bne  x4, x3, fail
    addi x5, x0, 1
    lui  x6, 0x20000
    sw   x5, 0(x6)           # Harness PASS token; counted at B response.

fail:
    addi x5, x0, 2
    lui  x6, 0x20000
    sw   x5, 0(x6)           # Harness deliberately fails on this token.
