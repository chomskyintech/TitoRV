OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
  ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00040000
}

SECTIONS
{
  .text : {
    KEEP(*(.text.init))
    *(.text .text.*)
  } > ram
  .rodata : { *(.rodata .rodata.* .srodata .srodata.*) } > ram
  .data : {
    __data_start = .;
    *(.data .data.* .sdata .sdata.*)
    __data_end = .;
  } > ram
  .bss (NOLOAD) : {
    . = ALIGN(4);
    __bss_start = .;
    *(.sbss .sbss.* .bss .bss.* COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > ram
  . = ALIGN(16);
  __image_end = .;
  __stack_top = 0x0003fff0;
  ASSERT(__image_end < __stack_top - 0x4000, "CoreMark image leaves insufficient stack")
  /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}
