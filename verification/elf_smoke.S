.section .text
.globl _start
_start:
    # Check signed overflow wraparound and arithmetic-right-shift sign extension.
    lui   t1, 0x80000
    addi  t2, t1, 0
    srai  t3, t2, 31
    addi  t4, zero, -1
    bne   t3, t4, fail

    # Check the AXI-Lite store/load path using ordinary RAM.
    addi  t0, zero, 256
    sw    t3, 0(t0)
    lw    t5, 0(t0)
    bne   t5, t3, fail

    # Check signed comparison: -1 is less than +1.
    addi  t6, zero, -1
    addi  t1, zero, 1
    slt   t2, t6, t1
    beq   t2, zero, fail

    # Report PASS through the harness-specific completion address.
    lui   t0, 0x20000
    addi  t1, zero, 1
    sw    t1, 0(t0)
1:
    jal   zero, 1b

fail:
    # A zero completion token is deliberately interpreted as failure.
    lui   t0, 0x20000
    sw    zero, 0(t0)
2:
    jal   zero, 2b
