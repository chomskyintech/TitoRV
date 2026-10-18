#!/usr/bin/env python3
"""Prepare the upstream CoreMark barebones port for simulation-only RV32I validation.

This deliberately does not produce an official CoreMark performance score:
the timer exposes simulated core cycles, not seconds on a calibrated target.
"""
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
port = root / "barebones" / "core_portme.c"
source = port.read_text()

clock_error = '''#error \\
    "You must implement a method to measure time in barebones_clock()! This function should return current time.\\n"'''
clock_impl = '''return *(volatile ee_u32 *)0x20000004; /* simulation cycle counter MMIO */'''
if clock_error not in source:
    raise SystemExit("Could not locate upstream barebones_clock placeholder")
source = source.replace(clock_error, clock_impl, 1)

init_error = '''#error \\
    "Call board initialization routines in portable init (if needed), in particular initialize UART!\\n"'''
if init_error not in source:
    raise SystemExit("Could not locate upstream portable_init placeholder")
source = source.replace(init_error, "", 1)
source = re.sub(
    r"#define EE_TICKS_PER_SEC\\s+.*",
    "#define EE_TICKS_PER_SEC 1 /* simulation cycles, not seconds */",
    source
)
port.write_text(source)

# In simulation, one tick is one RTL clock cycle. This is not wall-clock seconds.
port_header = root / "barebones" / "core_portme.h"
header = port_header.read_text()
header = re.sub(
    r"#define EE_TICKS_PER_SEC\s+.*",
    "#define EE_TICKS_PER_SEC 1 /* simulation cycles, not seconds */",
    header
)
if "#include <stddef.h>" not in header:
    header = header.replace(
        "#define CORE_PORTME_H",
        "#define CORE_PORTME_H" + chr(10) + "#include <stddef.h>" + chr(10)
    )
if "define FLAGS_STR" not in header:
    header = header.replace(
        "#define CORE_PORTME_H",
        "#define CORE_PORTME_H" + chr(10) +
        "#ifndef FLAGS_STR" + chr(10) +
        "#define FLAGS_STR " + chr(34) + "TitoRV simulation validation" + chr(34) + chr(10) +
        "#endif" + chr(10)
    )
port_header.write_text(header)

# Make validation failures observable to the startup stub. Upstream CoreMark
# reports CRC errors but its barebones main return code is always zero.
main = root / "core_main.c"
text = main.read_text()
old = "    return MAIN_RETURN_VAL;\n}"
if old not in text:
    raise SystemExit("Could not locate final CoreMark main return")
before, after = text.rsplit(old, 1)
text = before + "    return (total_errors == 0) ? MAIN_RETURN_VAL : 1;\n}" + after
main.write_text(text)
