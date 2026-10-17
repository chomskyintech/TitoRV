# TitoRV verification status

This document describes the standalone directed regressions for `tapeout_project/riscv_core.v`. These simulations supplement the existing AXI/UVM work; they do not establish full RV32I or privileged-architecture compliance.

## Automated CI regressions

The `TitoRV directed correctness` GitHub Actions workflow currently runs:

- Nine directed illegal-encoding/system-exception cases.
- A machine CSR regression covering register/immediate forms of `CSRRW`, `CSRRS`, and `CSRRC`, plus selected WARL/readback behaviour.
- Three machine trap-entry/`MRET` cases: `EBREAK`, `ECALL`, and illegal instruction.
- Three control-flow wrong-path squash cases for branch, jump, and return paths.

The workflow compiles with Icarus Verilog and treats mismatches/timeouts as failures. See the testbenches `riscv_correctness_tb.sv`, `riscv_csr_tb.sv`, `riscv_trap_tb.sv`, and `riscv_controlflow_tb.sv`.

The separate ELF smoke workflow builds and runs 37 public RV32UI instruction tests from `riscv-software-src/riscv-tests`, pinned to upstream revision `d7e86f701b929b5d801f8cda1a4871ab05f452bb`. The tests cover selected cases for integer arithmetic/logical instructions, branches/jumps, and byte/halfword/word loads and stores. They use a minimal test-environment adapter and an ecall exit convention; this is not the official ACT4 test environment or pass/fail protocol.

## Latest verified run

On commit `ce71f08e8fb6726f68a22c6ac2fc58ad6646b19d`, the following GitHub Actions runs completed successfully:

- [Directed correctness #158](https://github.com/chomskyintech/TitoRV/actions/runs/38987230232) — includes the machine CSR, trap/`MRET`, and control-flow regressions.
- [ELF execution harness #42](https://github.com/chomskyintech/TitoRV/actions/runs/38987230251) — includes the 37 public RV32UI tests.
- [RV32I baseline smoke #36](https://github.com/chomskyintech/TitoRV/actions/runs/38987230214).

These results demonstrate that the checked regressions pass on that commit. They do not demonstrate complete RV32I compliance, full privileged-specification behaviour, or ACT4 certification.

## Next verification steps

1. Expand directed edge-case tests for ALU signedness and immediate boundaries, memory byte lanes, misaligned accesses, AXI response errors/backpressure, and instruction hazards.
2. Integrate the RISC-V Architectural Certification Tests (ACT4) with a suitable DUT configuration, linker/model configuration, signature capture, and official termination protocol: https://github.com/riscv/riscv-arch-test
3. Run the applicable certification tests and resolve failures before making any compliance claim.

ACT4 tests execute on the user's testbench and do not replace microarchitectural verification.