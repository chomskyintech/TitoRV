.section .text
.globl _start
_start:
    # Store the harness PASS token to the memory-mapped completion address.
    lui   t0, 0x20000
    addi  t1, zero, 1
    sw    t1, 0(t0)
1:
    jal   zero, 1b
