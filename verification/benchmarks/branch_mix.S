.section .text
.globl _start
_start:
    li t0, 0
    li t1, 1000
    li t2, 0
1:
    addi t0, t0, 1
    andi t3, t0, 1
    beq t3, zero, 2f
    addi t2, t2, 1
2:
    addi t1, t1, -1
    bne t1, zero, 1b

    li t4, 500
    bne t2, t4, fail
    j pass
fail:
    li t1, 2
    j finish
pass:
    li t1, 1
finish:
    lui t0, 0x20000
    sw t1, 0(t0)
3:
    j 3b
