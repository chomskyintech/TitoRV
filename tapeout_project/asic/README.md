# ASIC tapeout preparation

This directory is the synthesis-oriented version of the dissertation RISC-V/AXI-Lite project. The original UVM regression environment remains in `tapeout_project/` and is intentionally kept separate.

## Directory purpose

- `rtl/riscv_core.v` - cleaned synthesizable CPU RTL. Simulation-only `$display` statements were removed, instruction fetch timing was corrected, load/store issue handling was fixed so memory operations are not re-issued, and taken branches/JAL flush younger pipeline state.
- `rtl/instr_mem.v` - deterministic combinational boot ROM. The constrained-random `$urandom_range` program generator remains a verification concern and is not part of the ASIC RTL.
- `rtl/riscv_system_top.v` - CPU + instruction ROM wrapper with an external AXI-Lite master interface.
- `rtl/axi_lite_ram.v` - small synthesizable AXI-Lite data RAM used for the first tapeout target.
- `rtl/tapeout_top.v` - self-contained CPU + ROM + AXI-Lite RAM integration. `debug_out` exposes x4[7:0]; `pass` asserts after the boot program has written/read the expected values.
- `sim/tb_smoke.v` - minimal non-UVM smoke test for the synthesis-oriented design.
- `synth/synth.ys` - generic Yosys synthesis/check script. It is technology-independent; a PDK-specific flow will replace/map cells later.

## Deterministic boot program

The ROM executes:

1. `addi x1, x0, 5`
2. `addi x2, x0, 10`
3. `add  x3, x1, x2`
4. `sw   x3, 0(x0)`
5. `sw   x2, 4(x0)`
6. `lw   x4, 0(x0)`
7. `lw   x5, 4(x0)`
8. `jal  x0, 0`

Expected final values are x4 = 15 and x5 = 10. The `pass` output checks those two values.

## What is deliberately not in ASIC RTL

UVM classes, sequences, scoreboard, coverage, assertions, random program generation, waveform dumping, delays, `$display`, `$finish`, and simulator configuration files are verification infrastructure. They are not synthesized into silicon.

## Next step

Run syntax/smoke simulation, then Yosys synthesis to get the first technology-independent cell/area estimate. After that the design can be adapted to a specific shuttle/PDK wrapper and taken through OpenROAD physical implementation.
