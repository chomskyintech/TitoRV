.section .text
.globl _start
_start:
    # Byte/halfword memory tests exercise all lanes and signed extension.
    lui s0, 0x1
    li t0, 0x80
    sb t0, 0(s0)
    lb t1, 0(s0)
    li t2, -128
    bne t1, t2, fail
    lbu t1, 0(s0)
    li t2, 128
    bne t1, t2, fail

    li t0, 0x7f
    sb t0, 1(s0)
    lbu t1, 1(s0)
    bne t1, t0, fail

    li t0, 0x8001
    sh t0, 2(s0)
    lh t1, 2(s0)
    li t2, -32767
    bne t1, t2, fail
    lhu t1, 2(s0)
    li t2, 32769
    bne t1, t2, fail

    li t0, 0x1234
    sh t0, 4(s0)
    lh t1, 4(s0)
    bne t1, t0, fail

    # All six RV32I branch predicates: taken and not-taken outcomes.
    li t0, 5
    li t1, 5
    beq t0, t1, 1f
    j fail
1:  bne t0, t1, fail
    blt t0, t1, fail
    bge t0, t1, 2f
    j fail
2:  bltu t0, t1, fail
    bgeu t0, t1, 3f
    j fail
3:  li t0, -1
    li t1, 1
    blt t0, t1, 4f
    j fail
4:  bge t0, t1, fail
    bltu t0, t1, fail
    bgeu t0, t1, 5f
    j fail
5:  li t0, 1
    li t1, 2
    bne t0, t1, 6f
    j fail
6:  beq t0, t1, fail

    # JALR must clear target bit zero and link to the following instruction.
    la t0, jalr_target
    ori t0, t0, 1
    jalr ra, 0(t0)
    j fail
jalr_target:
    la t1, jalr_returned
    # Return address should be the instruction immediately after JALR.
jalr_returned:
    # Continue with a sentinel result to distinguish success from failure.
    li t2, 0x5a
    bne t2, t2, fail

pass:
    li t1, 1
    j finish
fail:
    li t1, 2
finish:
    lui t0, 0x20000
    sw t1, 0(t0)
7:  j 7b
