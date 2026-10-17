/* TitoRV ACT4 compile-time configuration.
 * Initial scope: RV32I, XLEN=32, single hart; privileged tests are disabled.
 */
#ifndef TITORV_RVTEST_CONFIG_H
#define TITORV_RVTEST_CONFIG_H
#define XLEN 32
#define MXLEN 32
#define SXLEN 0
#define UXLEN 0
/* ACT4's environment macros use UDB_MXLEN to select XLEN-sized load/store
 * operations. Define it explicitly for this RV32 target.
 */
#define UDB_MXLEN 32
#define RVMODEL_MXLEN 32
#define RVMODEL_PMP_ENTRIES 0
#endif
