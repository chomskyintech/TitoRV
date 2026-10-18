.section .text.init
.globl _start
.type _start, @function
_start:
    la sp, __stack_top
    /* Disable small-data accesses; the build also uses -msmall-data-limit=0. */
    la t0, __bss_start
    la t1, __bss_end
1:
    bgeu t0, t1, 2f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 1b
2:
    call main
    /* Harness convention: 1 = CoreMark validation pass, 2 = failure. */
    lui t0, 0x20000
    li t1, 1
    beq a0, zero, 3f
    li t1, 2
3:
    sw t1, 0(t0)
4:
    j 4b
.size _start, .-_start
