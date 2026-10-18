#include <stdarg.h>

/* Output is intentionally suppressed in RTL simulation; CRC return status
 * is checked by the patched upstream main and the startup PASS/FAIL token.
 */
int ee_printf(const char *fmt, ...)
{
    (void)fmt;
    return 0;
}
