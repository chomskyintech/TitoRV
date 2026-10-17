/* ACT4 linker layout for TitoRV's existing 128 KiB zero-based ACT4 ELF harness.
 * Keep the matching Sail memory region and harness bounds synchronized.
 */
RAM_ORIGIN = 0x00000000;
RAM_LENGTH = 0x00020000;
TEST_BASE = RAM_ORIGIN;
NUM_HARTS = 1;
STACK_SIZE = 0x1000;

OUTPUT_ARCH("riscv")
ENTRY(rvtest_entry_point)

MEMORY
{
  ram (rwx) : ORIGIN = RAM_ORIGIN, LENGTH = RAM_LENGTH
}

PROVIDE(__stack_size = STACK_SIZE);
PROVIDE(__num_harts = NUM_HARTS);

SECTIONS
{
  ASSERT(TEST_BASE >= ORIGIN(ram) &&
         TEST_BASE < ORIGIN(ram) + LENGTH(ram),
         "TEST_BASE is outside TitoRV's RAM")

  .text.init TEST_BASE : { *(.text.init) } > ram
  .text.rvtest . : { *(.text.rvtest) *(.text.rvtest.*) } > ram

  .rodata . : { *(.rodata) *(.rodata.*) *(.srodata) *(.srodata.*) } > ram
  .data . : { *(.data) *(.data.*) *(.sdata) *(.sdata.*) } > ram

  .bss . : {
    __bss_start = .;
    *(.sbss) *(.sbss.*) *(.bss) *(.bss.*) *(COMMON)
    . = ALIGN(16);
    __bss_end = .;
  } > ram

  . = ALIGN(16);
  __stack_bottom = .;
  . += __stack_size * __num_harts;
  __stack_top = .;

  .text.rvmodel . : {
    *(.text.rvmodel) *(.text.rvmodel.*) *(.text) *(.text.*)
  } > ram

  . = ALIGN(4);
  _end = .;

  ASSERT(_end <= ORIGIN(ram) + LENGTH(ram),
         "ACT4 ELF exceeds the 128 KiB ACT4 test memory")
}
