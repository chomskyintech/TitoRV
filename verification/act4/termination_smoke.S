#include "rvmodel_macros.h"

.section .text.init
.align 2
.globl rvtest_entry_point
rvtest_entry_point:
#ifdef TEST_FAIL
  RVMODEL_HALT_FAIL
#else
  RVMODEL_HALT_PASS
#endif
