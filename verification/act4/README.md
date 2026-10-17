# ACT4 integration scaffold for TitoRV

This directory starts the integration with the official [RISC-V Architectural Certification Tests (ACT4)](https://github.com/riscv/riscv-arch-test). It is deliberately **not marked runnable or certified yet**: ACT4 requires a validated Unified Database (UDB) configuration and a matching Sail model configuration, and these must reflect actual TitoRV behaviour rather than copied from a larger core.

## Target currently established

- XLEN: 32
- Base ISA target: RV32I
- Reset / test load address: `0x00000000`
- Instruction/data test memory: 64 KiB in the existing ELF harness
- Implemented machine CSRs currently documented by TitoRV: `mstatus`, `mtvec`, `mscratch`, `mepc`, `mcause`
- Termination: write word `1` to `0x20000000` for pass; any other token at that address is failure in `tb_riscv_elf`

## Files

- `link.ld`: ACT4-style linker script targeting the zero-based 64 KiB test memory.
- `rvmodel_macros.h`: minimal pass/fail termination macros using the current harness completion convention.

## Remaining work before ACT4 can be run

1. Create `titorv-rv32i.yaml` as a **fully configured UDB architecture configuration** containing only extensions and parameters supported by TitoRV. Do not copy a broad profile such as RV32GC/RVA profiles.
2. Add and validate `sail.json`, `rvtest_config.h`, and `rvtest_config.svh` for RV32I and the limited machine-mode implementation.
3. Add an ACT4 `test_config.yaml` and install the framework's supported toolchain, UDB dependencies, and Sail 0.16 reference model in CI.
4. Add a harness mode that recognizes the ACT4 pass/fail stores, detects timeout/unexpected traps, and captures the generated test result.
5. Start with unprivileged RV32I tests. Enable privileged tests only after the UDB and Sail configurations accurately describe TitoRV's limited trap/CSR implementation.

The existing 37 public RV32UI tests are a separate regression and are not an ACT4 run. A passing build or generated ELF alone is not a test pass. Do not claim certification until the applicable ACT4 suite has executed successfully on the DUT and its results have been reviewed.
