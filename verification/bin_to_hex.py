#!/usr/bin/env python3
"""Convert a flat little-endian RISC-V binary into $readmemh 32-bit words."""
import pathlib
import sys

if len(sys.argv) != 3:
    raise SystemExit("usage: bin_to_hex.py input.bin output.hex")

source = pathlib.Path(sys.argv[1]).read_bytes()
if len(source) % 4:
    source += b"\x00" * (4 - len(source) % 4)

words = [
    int.from_bytes(source[offset : offset + 4], "little")
    for offset in range(0, len(source), 4)
]
pathlib.Path(sys.argv[2]).write_text(
    "".join(f"{word:08x}\n" for word in words), encoding="ascii"
)
