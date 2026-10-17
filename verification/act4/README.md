# ACT4 integration scaffold for TitoRV

This directory starts the integration with the official [RISC-V Architectural Certification Tests (ACT4)](https://github.com/riscv/riscv-arch-test). It is deliberately **not marked runnable or certified yet**: ACT4 requires a validated Unified Database (UDB) configuration and a matching Sail model configuration, and these must reflect actual TitoRV behaviour rather than being copied from a larger core.

## Target currently established

- XLEN: 32
- Base ISA target: RV32I
- Reset / test load address: `0x00000000`
- Instruction/data test memory: 64 KiB in the existing ELF harness
- Implemented machine CSRs currently documented by TitoRV: `mstatus`, `mtvec`, `mscratch`, `mepc`, `mcause`
- Termination: write word `1` to `0x20000000` for pass; any other token at that address is failure in `tb_riscv_elf`

## Configuration basis and current blocker

See [`titorv-rv32i-scope.md`](./titorv-rv32i-scope.md) for the RTL-derived instruction/CSR scope and limitations that must drive the ACT4 configuration.

The first configuration pass must **not** treat the core as a conventional full machine-mode implementation. The inspected RTL implements only five CSRs, has no interrupt handling, and redirects synchronous traps directly even when `mtvec.MODE` is written as vectored. The official UDB configuration has global behaviour controls such as `TRAP_ON_UNIMPLEMENTED_CSR` and `MTVEC_MODES`; the Sail configuration has its own privilege/CSR model. A copied configuration that enables the normal machine CSR set would therefore risk generating expected behaviour that TitoRV does not implement.

Until this mismatch is resolved, keep privileged and CSR tests excluded. The initial test selection must be explicitly limited to unprivileged RV32I, and the UDB/Sail configuration must still be validated as a coherent pair before any generated test result is treated as meaningful.

## Files

- [`test_config.yaml`](./test_config.yaml): initial ACT4 framework settings for the unprivileged RV32I stage; it references UDB and Sail configuration files that are not yet present/validated, so it is not runnable yet.
- `link.ld`: ACT4-style linker script targeting the zero-based 64 KiB test memory.
- `rvmodel_macros.h`: minimal pass/fail termination macros using the current harness completion convention.
- `termination_smoke.S`: small assembly program used to exercise the pass/fail adapter.

The ELF CI workflow builds both smoke ELFs and checks that the harness accepts the pass token and rejects the failure token. This validates the adapter only; it does not execute ACT4-generated certification tests.

## Remaining work before ACT4 can be run

1. Resolve the CSR/trap modelling gap: either constrain the RTL to a configuration the UDB/Sail models can express accurately, or prove a valid UDB/Sail representation for the existing partial CSR bank. Do not claim a match based only on schema parsing.
2. Create `titorv-rv32i.yaml` as a **fully configured UDB architecture configuration** containing only justified extensions and parameters. Do not copy a broad profile such as RV32GC/RVA profiles.
3. Create and validate a matching Sail 0.16 configuration; ACT4 generates `rvtest_config.h` and `rvtest_config.svh` from a valid UDB configuration during setup, so those generated outputs should be checked rather than hand-authored.
4. Install the framework's supported toolchain, UDB dependencies, and Sail 0.16 reference model in CI, then generate and run the unprivileged RV32I ELFs.
5. Extend the harness for ACT4-generated ELFs as needed, including timeout/unexpected-trap diagnostics and per-test result capture; the current smoke test validates only pass/fail termination tokens.
6. Enable privileged tests only after the UDB and Sail configurations accurately describe TitoRV's trap/CSR implementation.

The existing 37 public RV32UI tests are a separate regression and are not an ACT4 run. A passing build or generated ELF alone is not a test pass. Do not claim certification until the applicable ACT4 suite has executed successfully on the DUT and its results have been reviewed.
