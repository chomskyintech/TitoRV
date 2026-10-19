# TitoRV RTL Benchmark Baseline

**Status:** initial simulation baseline  
**RTL source commit:** `8bfd727f61241b6fad8246bcae264e20383c3fcb` (merge commit for the retirement-metrics change)  
**Benchmark harness:** `.github/workflows/riscv-baseline-microbenchmarks.yml`  
**Execution environment:** GitHub Actions `ubuntu-latest`; RISC-V bare-metal GCC/binutils and Icarus Verilog installed from the runner's Ubuntu package repositories. Exact package versions are not pinned by this workflow, so the environment is not yet fully version-locked.

## Results

These are RTL simulation results captured from the benchmark workflow associated with the same source tree before merge. They are a reference point for later comparisons, not claims about clock frequency, FPGA throughput, silicon performance, or an official CoreMark score.

| Benchmark | Simulated cycles | Retired instructions | CPI_arch | CPI_proxy | Stall cycles | Loads | Stores |
|---|---:|---:|---:|---:|---:|---:|---:|
| alu_dependency | 5,014 | 3,009 | 1.666 | 3,009 | 3 | 0 | 1 |
| branch_mix | 8,514 | 5,509 | 1.545 | 5,509 | 3 | 0 | 1 |
| memory_roundtrip | 1,415 | 610 | 2.320 | 610 | 603 | 100 | 101 |
| controlflow_mem_widths | 116 | 61 | 1.902 | 61 | 33 | 6 | 5 |
| alu_randomized | 392 | 385 | 1.018 | 385 | 3 | 0 | 1 |
| controlflow_memory_randomized | 1,498 | 1,077 | 1.391 | 1,077 | 411 | 100 | 37 |
| retirement_count | 23 | 10 | 2.300 | 10 | — | — | — |

The directed `retirement_count` test checks exactly 10 retirements, including a taken branch (the wrong-path instruction must not retire), a load/store round trip, and the final PASS-token store. The CI workflow requires `RETIREMENT-COUNT-CHECK expected=10 actual=10` and a PASS token before succeeding.

## CoreMark simulation

A prior CoreMark RV32I RTL simulation recorded:

- Simulated cycles: **1,387,069**
- Retired instructions: **830,871**
- Simulation IPC: **0.5990**
- Simulation CPI: **1.6694**

This is a functional RTL simulation measurement only. It is **not** an official CoreMark score and cannot be compared directly with published scores from hardware or differently configured simulators.

## Metric definitions

- **Retired instructions:** counted at the core's retirement-completion event. Ordinary instructions complete at execute; loads and stores complete on AXI response handshakes.
- **CPI_arch:** simulated RTL cycles divided by retired instructions.
- **IPC:** retired instructions divided by simulated RTL cycles.
- **CPI_proxy:** legacy proxy retained for continuity; it is not an architectural retirement count and should not be used as the primary performance metric.
- Flush bubbles are excluded from retirement; architectural NOP instructions are counted.

## Reproduction

1. Open the [baseline microbenchmark workflow](https://github.com/chomskyintech/TitoRV/actions/workflows/riscv-baseline-microbenchmarks.yml).
2. Run it on the desired commit, or inspect the run triggered by the commit above.
3. Download the `titorv-baseline-microbenchmarks` artifact. It contains per-benchmark logs and `summary.csv`.
4. Confirm the retirement-count check and PASS token in `retirement_count.log`.
5. Record the exact commit SHA and workflow run URL alongside any future comparison.

Workflow run for the merge commit: [run #38](https://github.com/chomskyintech/TitoRV/actions/runs/39309062784). At the time this report was drafted, that post-merge run was still in progress; its final result should be checked before treating this exact commit's rerun as independently confirmed.

## Limitations and next steps

This baseline is useful for regression detection, not yet a fully controlled performance study. To strengthen reproducibility, pin or record tool versions in CI and archive a machine-readable result with the source SHA. Before drawing microarchitectural conclusions, extend directed retirement coverage to jumps, synchronous traps/returns, and pipeline/AXI stall cases, then compare before/after changes on the same toolchain and benchmark inputs.
