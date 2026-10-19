.option norvc
.section .text
.globl _start
_start:
    addi x1, x0, 5
    jal  x5, jal_target
    addi x2, x0, 99          # Wrong path: must be flushed.
    addi x2, x0, 98          # Wrong path: must be flushed.
jal_target:
    addi x2, x0, 7
    auipc x7, 0              # At PC 20, computes address 20.
    addi  x7, x7, 20         # JALR target is PC 40.
    jalr  x6, 0(x7)
    addi x3, x0, 99          # Wrong path after JALR.
    addi x3, x0, 98          # Wrong path after JALR.
jalr_target:
    sw   x2, 0(x0)           # AXI write stalls the pipeline.
    lw   x4, 0(x0)           # AXI read stalls the pipeline.
    bne  x4, x2, fail
    addi x5, x0, 1
    lui  x6, 0x20000
    sw   x5, 0(x6)           # Harness PASS token, counted on B response.

fail:
    addi x5, x0, 2
    lui  x6, 0x20000
    sw   x5, 0(x6)           # Harness deliberately fails on this token.
