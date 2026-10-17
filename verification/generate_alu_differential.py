#!/usr/bin/env python3
"""Generate a deterministic randomized RV32I ALU test with a Python reference model.

The generated assembly computes expected results independently in Python and
compares all tested architectural registers against those values in the DUT.
"""
from __future__ import annotations

import random
import sys
from pathlib import Path

MASK = 0xFFFFFFFF
REGS = list(range(1, 21))
OPS = [
    "add", "sub", "and", "or", "xor", "slt", "sltu",
    "sll", "srl", "sra", "addi", "andi", "ori", "xori",
    "slti", "sltiu", "slli", "srli", "srai",
]


def signed(value: int) -> int:
    value &= MASK
    return value - (1 << 32) if value & 0x80000000 else value


def u32(value: int) -> int:
    return value & MASK


def main() -> None:
    seed = int(sys.argv[1], 0) if len(sys.argv) > 1 else 20261017
    output = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("/tmp/alu_random.S")
    rng = random.Random(seed)
    regs = {r: rng.getrandbits(32) for r in REGS}
    lines = [
        ".section .text",
        ".globl _start",
        "_start:",
        f"    # Seeded randomized ALU differential test; seed={seed}",
    ]
    for reg in REGS:
        lines.append(f"    li x{reg}, {signed(regs[reg])}")

    for index in range(300):
        op = rng.choice(OPS)
        rd = rng.choice(REGS)
        rs1 = rng.choice(REGS + [0])
        a = regs.get(rs1, 0)
        if op.endswith("i") or op in ("slli", "srli", "srai"):
            imm = rng.randint(0, 31) if op in ("slli", "srli", "srai") else rng.randint(-2048, 2047)
            lines.append(f"    {op} x{rd}, x{rs1}, {imm}")
            if op == "addi":
                value = a + imm
            elif op == "andi":
                value = a & u32(imm)
            elif op == "ori":
                value = a | u32(imm)
            elif op == "xori":
                value = a ^ u32(imm)
            elif op == "slti":
                value = int(signed(a) < imm)
            elif op == "sltiu":
                value = int(a < u32(imm))
            elif op == "slli":
                value = a << imm
            elif op == "srli":
                value = a >> imm
            else:
                value = signed(a) >> imm
        else:
            rs2 = rng.choice(REGS + [0])
            b = regs.get(rs2, 0)
            lines.append(f"    {op} x{rd}, x{rs1}, x{rs2}")
            if op == "add":
                value = a + b
            elif op == "sub":
                value = a - b
            elif op == "and":
                value = a & b
            elif op == "or":
                value = a | b
            elif op == "xor":
                value = a ^ b
            elif op == "slt":
                value = int(signed(a) < signed(b))
            elif op == "sltu":
                value = int(a < b)
            elif op == "sll":
                value = a << (b & 31)
            elif op == "srl":
                value = a >> (b & 31)
            else:
                value = signed(a) >> (b & 31)
        regs[rd] = u32(value)

    lines.append("    # Compare the DUT state with the independent Python model.")
    for reg in REGS:
        lines.extend([
            f"    li x31, {signed(regs[reg])}",
            f"    bne x{reg}, x31, fail",
        ])
    lines.extend([
        "pass:",
        "    li x6, 1",
        "    j finish",
        "fail:",
        "    li x6, 2",
        "finish:",
        "    lui x5, 0x20000",
        "    sw x6, 0(x5)",
        "1:  j 1b",
        "",
    ])
    output.write_text("\n".join(lines), encoding="utf-8")
    print(f"Generated {len(OPS)}-operation-family ALU differential test: seed={seed}, instructions=300, checked_registers={len(REGS)}, output={output}")


if __name__ == "__main__":
    main()
