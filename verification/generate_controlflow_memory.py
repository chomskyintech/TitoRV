#!/usr/bin/env python3
"""Generate seeded RV32I branch and memory tests with a Python reference model."""
from __future__ import annotations
import random
import sys
from pathlib import Path

MASK = 0xffffffff
BRANCHES = {
    "beq": "bne", "bne": "beq", "blt": "bge",
    "bge": "blt", "bltu": "bgeu", "bgeu": "bltu",
}

def s32(v: int) -> int:
    v &= MASK
    return v - (1 << 32) if v & 0x80000000 else v

def main() -> None:
    seed = int(sys.argv[1], 0) if len(sys.argv) > 1 else 20261018
    output = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("verification/benchmarks/controlflow_memory_randomized.S")
    rng = random.Random(seed)
    lines = [".section .text", ".globl _start", "_start:", f"    # Seed={seed}: randomized branch and memory differential test"]
    regs = {}
    for r in range(1, 17):
        regs[r] = rng.getrandbits(32)
        lines.append(f"    li x{r}, {s32(regs[r])}")
    lines += ["    li x20, 4096", "    li x21, 0"]
    # Check both taken and not-taken behavior for all six branch predicates.
    for i in range(120):
        op = rng.choice(list(BRANCHES))
        a, b = rng.choice(list(regs.values())), rng.choice(list(regs.values()))
        # Bias equality cases into the sample.
        if i % 5 == 0:
            b = a
        r1, r2 = 1 + (i % 16), 1 + ((i * 7 + 3) % 16)
        if r1 == r2:
            r2 = (r2 % 16) + 1
        regs[r1], regs[r2] = a, b
        lines.append(f"    li x{r1}, {s32(a)}")
        lines.append(f"    li x{r2}, {s32(b)}")
        if op == "beq": truth = a == b
        elif op == "bne": truth = a != b
        elif op == "blt": truth = s32(a) < s32(b)
        elif op == "bge": truth = s32(a) >= s32(b)
        elif op == "bltu": truth = a < b
        else: truth = a >= b
        fail_op = BRANCHES[op] if truth else op
        lines.append(f"    {fail_op} x{r1}, x{r2}, fail")
    # Generate stores to a byte-addressed reference memory, then validate signed/unsigned reads.
    mem = [0] * 128
    stores = []
    for i in range(36):
        kind = rng.choice(["sb", "sh", "sw"])
        width = {"sb": 1, "sh": 2, "sw": 4}[kind]
        off = rng.randrange(0, 128 - width + 1)
        off -= off % width
        value = rng.getrandbits(32)
        reg = 1 + (i % 16)
        lines.append(f"    li x{reg}, {s32(value)}")
        lines.append(f"    {kind} x{reg}, {off}(x20)")
        for j in range(width):
            mem[off+j] = (value >> (8*j)) & 0xff
        stores.append((off, width))
    loads = [("lb",1),("lbu",1),("lh",2),("lhu",2),("lw",4)]
    for i in range(100):
        op, width = rng.choice(loads)
        off = rng.randrange(0, 128 - width + 1)
        off -= off % width
        value = sum(mem[off+j] << (8*j) for j in range(width))
        if op in ("lb", "lh") and value & (1 << (width*8-1)):
            value |= MASK ^ ((1 << (width*8))-1)
        rd = 1 + (i % 16)
        lines += [f"    {op} x{rd}, {off}(x20)", f"    li x31, {s32(value)}", f"    bne x{rd}, x31, fail"]
    lines += [
        "    li x6, 1", "    j finish", "fail:", "    li x6, 2",
        "finish:", "    lui x5, 0x20000", "    sw x6, 0(x5)", "1: j 1b", ""
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(lines), encoding="utf-8")
    print(f"Generated seeded control-flow/memory differential test: seed={seed}, branch_checks=120, stores={len(stores)}, load_checks=100, output={output}")

if __name__ == "__main__":
    main()
