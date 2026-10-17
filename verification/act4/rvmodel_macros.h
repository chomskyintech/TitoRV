#ifndef TITORV_ACT4_RVMODEL_MACROS_H
#define TITORV_ACT4_RVMODEL_MACROS_H

/*
 * TitoRV's current ELF simulation harness recognizes a word store to
 * 0x20000000. Token 1 is PASS; all other tokens are FAIL.
 * This is a harness adapter, not a certification claim.
 */

#define RVMODEL_HALT_PASS \
  li t0, 0x20000000;      \
  li t1, 1;               \
  sw t1, 0(t0);           \
1: j 1b;

#define RVMODEL_HALT_FAIL \
  li t0, 0x20000000;      \
  li t1, 2;               \
  sw t1, 0(t0);           \
2: j 2b;

/* ACT4 requires this hook for diagnostic strings. The current simulation
 * harness has no console-output device, so intentionally discard the string.
 */
#define RVMODEL_IO_WRITE_STR(_R1, _R2, _R3, _STR_PTR)

/* No extra data section is required by this minimal harness adapter. */
#define RVMODEL_DATA_SECTION

#endif
