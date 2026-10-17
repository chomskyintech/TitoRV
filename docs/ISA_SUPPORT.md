# TitoRV ISA Support Audit

**Audited branch:** `verification/riscv-directed-tests`  
**RTL under audit:** `tapeout_project/riscv_core.v`  
**Status:** source-level support inventory plus directed simulation evidence. This is not a RISC-V compliance claim.

## Summary

TitoRV is a 32-bit, in-order pipelined core with an instruction-memory interface and a single-outstanding AXI-Lite data interface. The RTL implements most RV32I integer instruction decode paths, subword memory transfers, selected machine-mode CSR operations, and a basic machine-mode trap path. The whole architecture is **not yet established as RV32I-compliant**: the ELF smoke regression is directed, memory-ordering behaviour is not comprehensively verified, and no RISC-V Architectural Certification Tests (ACT4) have been run.

## Implemented RV32I instruction classes

| Class | Encodings / operations implemented in RTL | ELF regression coverage |
|---|---|---|
| Upper immediates | `LUI`, `AUIPC` | LUI is used to form values and addresses; AUIPC is checked against its instruction address |
| Integer register-immediate | `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI` | Directed result checks |
| Integer register-register | `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND` | Directed result checks |
| Conditional branches | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` | Taken and not-taken paths |
| Jumps | `JAL`, `JALR` | Link values, JALR bit-0 clearing, and fall-through squash |
| Loads | `LB`, `LH`, `LW`, `LBU`, `LHU` | Word round trip plus signed/unsigned byte and halfword loads |
| Stores | `SB`, `SH`, `SW` | Word store/load and byte/halfword lane checks |

The table records implemented paths and regression coverage; it does not imply every immediate, boundary, hazard, or misalignment case has been tested.

## Public RV32UI instruction regression

The ELF CI workflow builds and runs 37 public instruction tests from [`riscv-software-src/riscv-tests`](https://github.com/riscv-software-src/riscv-tests), pinned to upstream revision `d7e86f701b929b5d801f8cda1a4871ab05f452bb`. The test sources are built as RV32I and linked into TitoRV's zero-based 64 KiB memory map. A minimal environment adapter avoids unrelated privileged-startup code; tests terminate through the standard `a7=93` / `a0=0` ecall exit convention.

**Latest pinned CI run:** all 37 tests passed in workflow run [#40](https://github.com/chomskyintech/TitoRV/actions/runs/38987135936). The baseline smoke and directed-correctness workflows also passed on the same commit.

Covered upstream tests: `add`, `addi`, `and`, `andi`, `auipc`, `beq`, `bge`, `bgeu`, `blt`, `bltu`, `bne`, `jal`, `jalr`, `lb`, `lbu`, `lh`, `lhu`, `lui`, `lw`, `or`, `ori`, `sb`, `sh`, `sll`, `slli`, `slt`, `slti`, `sltiu`, `sltu`, `sra`, `srai`, `srl`, `srli`, `sub`, `sw`, `xor`, and `xori`.

These are public instruction-level unit tests, not ACT4 certification. They cover selected operand cases and depend on the same processor for the tests' self-checking branches and control flow.

## Additional system behaviour

- The RTL has a small machine-mode CSR bank: `mstatus`, `mtvec`, `mscratch`, `mepc`, and `mcause`.
- Implemented CSR instruction forms include register and immediate variants of `CSRRW`, `CSRRS`, and `CSRRC`, restricted to those supported CSRs.
- `ECALL`, `EBREAK`, and `MRET` have a basic machine-mode trap/return path. Existing directed CI tests cover selected illegal encodings, CSR operations, trap entry, and MRET.
- The opcode class for `FENCE` is accepted by the decoder, but complete memory-ordering semantics have not been independently established by the current tests.

These system features should not be confused with complete privileged-architecture or Zicsr compliance.

## Known gaps and limits

- **No ACT4 result yet.** The custom smoke ELF uses a store of `1` to `0x20000000` as its completion token; public `riscv-tests` use a minimal ecall-exit adapter. Neither setup is the official ACT4 `RVMODEL_HALT_PASS` protocol.
- **No exhaustive instruction proof.** The current tests use selected values and sequences; they do not exhaustively cover all opcode/funct combinations, immediate boundaries, signedness edges, or interactions between every instruction pair.
- **Memory corner cases need work.** Misaligned accesses, all byte-lane combinations, response errors, and more varied AXI-Lite backpressure patterns are not comprehensively tested by the ELF harness.
- **Exceptions and interrupts are incomplete.** The current trap path is limited and does not establish full privileged-specification behaviour, interrupt handling, or all architectural exception conditions.
- **Pipeline hazards need broader validation.** Directed programs test representative data dependencies and control-flow squashing, not every dependency and timing combination.
- **Other extensions are out of scope.** RV32M multiply/divide, compressed instructions, atomics, and floating point are not part of this RV32I target and are not implemented as part of this work.

## Verification workflow

1. Run the ELF execution harness with a compiled RV32I program and make every failure token distinct from the PASS token.
2. Run directed correctness, CSR/trap, control-flow squash, and baseline smoke workflows.
3. Expand corner-case coverage for ALU boundaries, memory lanes, hazards, and illegal/reserved encodings.
4. Integrate the RISC-V Architectural Certification Tests with an appropriate test environment, linker/configuration, signature reporting, and the official termination protocol.
5. Claim compliance only after the applicable certification suite and additional microarchitectural verification pass.

A green smoke test is useful regression evidence, not a substitute for architectural certification.
