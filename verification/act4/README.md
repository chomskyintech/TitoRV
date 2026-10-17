# ACT4 integration scaffold for TitoRV

This directory starts the integration with the official [RISC-V Architectural Certification Tests (ACT4)](https://github.com/riscv/riscv-arch-test). It is **not yet marked runnable or certified**. The initial UDB and Sail files have now been added as RV32I-only candidates; they still require validation by the official framework and reference-model toolchain before their output can be trusted.

## Target currently established

- XLEN: 32
- Initial test scope: unprivileged RV32I only
- Reset / test load address: `0x00000000`
- Instruction/data test memory: 64 KiB in the existing ELF harness
- Implemented machine CSRs currently documented by TitoRV: `mstatus`, `mtvec`, `mscratch`, `mepc`, `mcause`
- Termination: write word `1` to `0x20000000` for pass; any other token at that address is failure in `tb_riscv_elf`

## Configuration basis and current blocker

See [`titorv-rv32i-scope.md`](./titorv-rv32i-scope.md) for the RTL-derived instruction/CSR scope and limitations that must drive the ACT4 configuration.

The initial UDB candidate declares only the base `I` extension, and `test_config.yaml` disables privilege-mode tests. This is intended to keep the first test selection focused on unprivileged RV32I; it is **not** a claim that the RTL's extra SYSTEM/CSR behaviour is fully described by the config. The candidate UDB file has not yet been checked with the official UDB validator or ACT4 generator.

The inspected RTL implements only five CSRs, has no interrupt handling, and redirects synchronous traps directly even when `mtvec.MODE` is written as vectored. The official UDB configuration has global behaviour controls such as `TRAP_ON_UNIMPLEMENTED_CSR` and `MTVEC_MODES`; Sail has its own privilege/CSR model. Therefore the minimal Sail candidate must be checked against Sail 0.16 and the ACT4-generated test expectations before any certification-style run.

## Files

- [`test_config.yaml`](./test_config.yaml): ACT4 framework settings; privileged tests disabled.
- [`titorv-rv32i.yaml`](./titorv-rv32i.yaml): initial UDB candidate declaring RV32I only; not yet officially validated.
- [`sail.json`](./sail.json): minimal Sail 0.16 candidate for XLEN 32; not yet validated by Sail.
- [`link.ld`](./link.ld): ACT4-style linker script targeting the zero-based 64 KiB test memory.
- [`rvmodel_macros.h`](./rvmodel_macros.h): minimal pass/fail termination macros using the current harness completion convention.
- [`termination_smoke.S`](./termination_smoke.S): assembly program used to exercise the pass/fail adapter.

The ELF CI workflow builds both smoke ELFs and checks that the harness accepts the pass token and rejects the failure token. This validates the adapter only; it does not execute ACT4-generated certification tests.

## Remaining work before ACT4 can be run

1. Validate `titorv-rv32i.yaml` with the official UDB tooling and validate `sail.json` with Sail 0.16; fix schema or semantic issues reported by either tool.
2. Run ACT4 test generation with `include_priv_tests: false` and inspect the selected tests to confirm that no privileged/CSR tests are selected.
3. Check the generated `rvtest_config.h` and `rvtest_config.svh` and verify linker/load addresses against TitoRV's 64 KiB zero-based harness.
4. Add the official framework, UDB dependencies, and Sail 0.16 to CI; generate the unprivileged RV32I ELFs and execute each ELF on TitoRV with timeout/unexpected-trap diagnostics and per-test result capture.
5. Resolve the partial CSR/trap modelling gap before enabling privileged tests.

The existing 37 public RV32UI tests are a separate regression and are not an ACT4 run. A schema-valid config, successful generation, or termination-adapter test is not itself an architectural test pass. Do not claim certification until applicable ACT4 tests have executed successfully on the DUT and results have been reviewed.
