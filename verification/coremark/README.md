# TitoRV CoreMark simulation validation

This integration builds the upstream EEMBC CoreMark sources for RV32I and runs
the validation-seed configuration on TitoRV's RTL simulation harness.

The harness exposes a simulation-only cycle counter at MMIO address
`0x20000004`; the program completion token remains at `0x20000000`.
CoreMark's validation CRCs are checked, and the startup code reports PASS only
when `main` returns success.

**This is not an official CoreMark performance result.** The timer counts RTL
simulation cycles, not calibrated seconds on a physical target, so the run
must not be reported as CoreMark/MHz or CoreMark score. Use this flow to verify
the benchmark workload executes correctly; use the existing custom workloads
for cycle-level comparisons.
