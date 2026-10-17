# ACT4 integration scaffold for TitoRV

This directory starts the integration with the official [RISC-V Architectural Certification Tests (ACT4)](https://github.com/riscv/riscv-arch-test). It is **not yet marked runnable or certified**. The UDB file includes the machine-mode parameters required by the official UDB loader, with privileged tests disabled. CI has successfully loaded the UDB configuration and validated `sail.json` against the Sail 0.16 JSON Schema. The Sail file is still based on the upstream ACT4 CVW RV32I model, with TitoRV's 128 KiB zero-based ACT4 simulation RAM, completion-token MMIO, and direct-only `mtvec` behavior reflected in the candidate. These checks establish config acceptance, not a validated behavioral model of TitoRV; a platform/CSR/trap audit and a real ACT4 generation run are still required.

## Target currently established

- XLEN: 32
- Initial test scope: unprivileged RV32I only
- Reset / test load address: `0x00000000`
- Instruction/data test memory: 128 KiB in the AXI-backed ELF simulation harness
- Implemented machine CSRs currently documented by TitoRV: `mstatus`, `mtvec`, `mscratch`, `mepc`, `mcause`
- Termination: write word `1` to `0x20000000` for pass; any other token at that address is failure in `tb_riscv_elf`

## Configuration basis and current blocker

See [`titorv-rv32i-scope.md`](./titorv-rv32i-scope.md) for the RTL-derived instruction/CSR scope and limitations that must drive the ACT4 configuration.

The UDB candidate declares `I` plus `Sm` parameters because UDB requires the machine-mode parameter set even when the initial selected tests are unprivileged. This configuration does not establish privileged compliance; `test_config.yaml` keeps privileged tests disabled. `test_config.yaml` disables privilege-mode tests. This is intended to keep the first test selection focused on unprivileged RV32I; it is **not** a claim that the RTL's extra SYSTEM/CSR behaviour is fully described by the config. The UDB file has passed the official UDB loader check in CI. The Sail candidate now disables vectored `mtvec` dispatch and HPM counter support to better reflect the inspected RTL. Static sanity checks guard these settings and the RAM/MMIO address map. ACT4 test generation has not yet been run.

The inspected RTL implements only five CSRs, has no interrupt handling, and redirects synchronous traps directly even when `mtvec.MODE` is written as vectored. The official UDB configuration has global behaviour controls such as `TRAP_ON_UNIMPLEMENTED_CSR` and `MTVEC_MODES`; Sail has its own privilege/CSR model. Therefore the minimal Sail candidate must be checked against Sail 0.16 and the ACT4-generated test expectations before any certification-style run.

## Files

- [`test_config.yaml`](./test_config.yaml): ACT4 framework settings; privileged tests disabled.
- [`titorv-rv32i.yaml`](./titorv-rv32i.yaml): UDB test-generation candidate for unprivileged RV32I with required machine-mode configuration; official loader validation passes in CI.
- [`sail.json`](./sail.json): Sail 0.16 schema-complete starting point with TitoRV RAM/MMIO addresses; still requires a TitoRV-specific CSR/trap/extension audit.
- [`link.ld`](./link.ld): ACT4-style linker script targeting the zero-based 128 KiB ACT4 simulation memory.
- [`rvmodel_macros.h`](./rvmodel_macros.h): minimal pass/fail termination macros using the current harness completion convention.
- [`termination_smoke.S`](./termination_smoke.S): assembly program used to exercise the pass/fail adapter.

The ELF CI workflow builds both smoke ELFs and checks that the harness accepts the pass token and rejects the failure token. This validates the adapter only; it does not execute ACT4-generated certification tests.

## Remaining work before ACT4 can be run

1. Audit the upstream-derived Sail platform, CSR, trap, and extension settings against TitoRV. Official UDB loading and Sail 0.16 schema validation pass, but they do not establish semantic equivalence.
2. Run ACT4 test generation with `include_priv_tests: false` and inspect the selected tests to confirm that no privileged/CSR tests are selected.
3. Check the generated `rvtest_config.h` and `rvtest_config.svh` and verify linker/load addresses against TitoRV's 64 KiB zero-based harness.
4. Integrate the official ACT4 framework and its required compiler/Sail dependencies in CI; generate unprivileged RV32I ELFs and execute each ELF on TitoRV with timeout/unexpected-trap diagnostics and per-test result capture.
5. Resolve the partial CSR/trap modelling gap before enabling privileged tests.

The existing 37 public RV32UI tests are a separate regression and are not an ACT4 run. A schema-valid config, successful generation, or termination-adapter test is not itself an architectural test pass. Do not claim certification until applicable ACT4 tests have executed successfully on the DUT and results have been reviewed.
