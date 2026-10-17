/* Link public riscv-tests RV32UI ELFs into TitoRV's zero-based 64 KiB memory. */
OUTPUT_ARCH(riscv)
ENTRY(_start)

SECTIONS
{
    . = 0x00000000;

    .text : ALIGN(4)
    {
        *(.text.init)
        *(.text .text.*)
    }

    .rodata : ALIGN(4)
    {
        *(.rodata .rodata.*)
    }

    .data : ALIGN(4)
    {
        *(.data .data.*)
        *(.sdata .sdata.*)
    }

    .tohost : ALIGN(64)
    {
        *(.tohost)
    }

    .bss (NOLOAD) : ALIGN(4)
    {
        *(.bss .bss.*)
        *(COMMON)
    }
}
