# ACT4 integration scaffold for TitoRV

This directory starts the integration with the official [RISC-V Architectural Certification Tests (ACT4)](https://github.com/riscv/riscv-arch-test). It is deliberately **not marked runnable or certified yet**: ACT4 requires a validated Unified Database (UDB) configuration and a matching Sail model configuration, and these must reflect actual TitoRV behaviour rather than copied from a larger core.

## Target currently established

- XLEN: 32
- Base ISA target: RV32I
- Reset / test load address: `0x00000000`
- Instruction/data test memory: 64 KiB in the existing ELF harness
- Implemented machine CSRs currently documented by TitoRV: `mstatus`, `mtvec`, `mscratch`, `mepc`, `mcause`
- Termination: write word `1` to `0x20000000` for pass; any other token at that address is failure in `tb_riscv_elf`

## Configuration basis

See [`titorv-rv32i-scope.md`](./titorv-rv32i-scope.md) for the RTL-derived instruction/CSR scope and limitations that must drive the ACT4 configuration. In particular, do not enable privileged or CSR tests just because the core has a partial machine-mode CSR bank; the implementation does not provide the full standard machine CSR/interrupt environment.

## Files

- [`test_config.yaml`](./test_config.yaml): initial ACT4 framework settings for the unprivileged RV32I stage; it references UDB and Sail configuration files that are not yet present/validated, so it is not runnable yet.
- `link.ld`: ACT4-style linker script targeting the zero-based 64 KiB test memory.
- `rvmodel_macros.h`: minimal pass/fail termination macros using the current harness completion convention.
- `termination_smoke.S`: small assembly program used to exercise the pass/fail adapter.

The ELF CI workflow builds both smoke ELFs and checks that the harness accepts the pass token and rejects the failure token. This validates the adapter only; it does not execute ACT4-generated certification tests.

## Remaining work before ACT4 can be run

1. Create `titorv-rv32i.yaml` as a **fully configured UDB architecture configuration** containing only extensions and parameters supported by TitoRV. Do not copy a broad profile such as RV32GC/RVA profiles.
2. Create and validate a matching Sail 0.16 configuration; ACT4 generates `rvtest_config.h` and `rvtest_config.svh` from a valid UDB configuration during setup, so those generated outputs should be checked rather than hand-authored.
3. Install the framework's supported toolchain, UDB dependencies, and Sail 0.16 reference model in CI, then generate and run the unprivileged RV32I ELFs.
4. Extend the harness for ACT4-generated ELFs as needed, including timeout/unexpected-trap diagnostics and per-test result capture; the current smoke test validates only pass/fail termination tokens.
5. Enable privileged tests only after the UDB and Sail configurations accurately describe TitoRV's limited trap/CSR implementation.

The existing 37 public RV32UI tests are a separate regression and are not an ACT4 run. A passing build or generated ELF alone is not a test pass. Do not claim certification until the applicable ACT4 suite has executed successfully on the DUT and its results have been reviewed.
