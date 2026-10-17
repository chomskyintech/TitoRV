.section .text
.globl _start
_start:
    li t0, 0
    li t1, 100
    li t2, 1
1:
    add t0, t0, t2
    addi t1, t1, -1
    bne t1, zero, 1b

    li t3, 1000
    bne t0, t3, fail
    j pass
fail:
    li t1, 2
    j finish
pass:
    li t1, 1
finish:
    lui t0, 0x20000
    sw t1, 0(t0)
2:
    j 2b
