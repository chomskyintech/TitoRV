.section .text
.globl _start
_start:
    # Arithmetic and immediate ALU checks.
    lui   t1, 0x80000
    srai  t3, t1, 31
    addi  t4, zero, -1
    bne   t3, t4, fail_arith
    addi  t2, t1, -1
    lui   t5, 0x80000
    addi  t5, t5, -1
    bne   t2, t5, fail_arith

    addi  s0, zero, 0x55
    addi  s1, zero, 0x0f
    andi  s2, s0, 0x0f
    addi  t0, zero, 5
    bne   s2, t0, fail_arith
    xori  s2, s0, 0x0f
    addi  t0, zero, 0x5a
    bne   s2, t0, fail_arith
    ori   s2, s1, 0x50
    addi  t0, zero, 0x5f
    bne   s2, t0, fail_arith
    slli  s2, s1, 2
    addi  t0, zero, 60
    bne   s2, t0, fail_arith
    srli  s2, s2, 2
    bne   s2, s1, fail_arith
    sra   s2, t3, s1
    bne   s2, t4, fail_arith
    slti  s2, t3, 0
    addi  t0, zero, 1
    bne   s2, t0, fail_arith
    sltiu s2, t3, 1
    bne   s2, zero, fail_arith

    # Register-register ALU operations.
    xor   s2, s0, s1
    addi  t0, zero, 0x5a
    bne   s2, t0, fail_arith
    or    s2, s1, s0
    addi  t0, zero, 0x5f
    bne   s2, t0, fail_arith
    and   s2, s0, s1
    addi  t0, zero, 5
    bne   s2, t0, fail_arith
    sll   s2, s1, t0
    addi  t0, zero, 0x1e0
    bne   s2, t0, fail_arith
    addi  t0, zero, 5
    srl   s2, s2, t0
    addi  t0, zero, 15
    bne   s2, t0, fail_arith
    slt   s2, t3, t4
    addi  t0, zero, 1
    bne   s2, t0, fail_arith
    sltu  s2, t3, t4
    bne   s2, zero, fail_arith

    # Exercise all six conditional branches, taken and not taken.
    beq   s0, s0, beq_taken
    j     fail_branch
beq_taken:
    bne   s0, s0, fail_branch
    bne   s0, s1, bne_taken
    j     fail_branch
bne_taken:
    beq   s0, s1, fail_branch

    blt   t3, t4, blt_taken
    j     fail_branch
blt_taken:
    blt   t4, t3, fail_branch
    bge   t4, t3, bge_taken
    j     fail_branch
bge_taken:
    bge   t3, t4, fail_branch

    bltu  t4, t3, bltu_taken
    j     fail_branch
bltu_taken:
    bltu  t3, t4, fail_branch
    bgeu  t3, t4, bgeu_taken
    j     fail_branch
bgeu_taken:
    bgeu  t4, t3, fail_branch

    # Word, byte, and halfword accesses through the AXI-Lite interface.
    addi  t0, zero, 256
    sw    t3, 0(t0)
    lw    t5, 0(t0)
    bne   t5, t3, fail_memory

    addi  t1, zero, 128
    sb    t1, 1(t0)
    lbu   t2, 1(t0)
    bne   t2, t1, fail_memory
    lb    t2, 1(t0)
    addi  t5, zero, -128
    bne   t2, t5, fail_memory

    lui   t1, 0x8
    addi  t1, t1, 1
    sh    t1, 2(t0)
    lh    t2, 2(t0)
    lui   t5, 0xffff8
    addi  t5, t5, 1
    bne   t2, t5, fail_memory
    lhu   t2, 2(t0)
    lui   t5, 0x8
    addi  t5, t5, 1
    bne   t2, t5, fail_memory

    # AUIPC must return the address of its own instruction.
auipc_here:
    auipc t1, 0
    la    t2, auipc_here
    bne   t1, t2, fail_jump

    # JAL must link to PC+4 and squash the sequential instruction.
    jal   t3, jal_target
jal_fallthrough:
    j     fail_jump
jal_target:
    la    t1, jal_fallthrough
    bne   t3, t1, fail_jump

    # JALR clears target bit 0, links PC+4, and squashes fall-through.
    la    t0, jalr_target
    addi  t0, t0, 1
    jalr  t4, 0(t0)
jalr_fallthrough:
    j     fail_jump
jalr_target:
    la    t1, jalr_fallthrough
    bne   t4, t1, fail_jump

    # Report PASS through the harness-specific completion address.
    lui   t0, 0x20000
    addi  t1, zero, 1
    sw    t1, 0(t0)
pass_loop:
    j     pass_loop

fail_arith:
    addi  t6, zero, 16
    j     fail
fail_branch:
    addi  t6, zero, 32
    j     fail
fail_memory:
    addi  t6, zero, 48
    j     fail
fail_jump:
    addi  t6, zero, 64
fail:
    lui   t0, 0x20000
    sw    t6, 0(t0)
fail_loop:
    j     fail_loop
