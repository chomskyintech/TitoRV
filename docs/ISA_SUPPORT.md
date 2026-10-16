# TitoRV ISA Support Audit

**Audited branch:** `verification/riscv-directed-tests`  
**Audited RTL:** `tapeout_project/riscv_core.v`  
**Status:** preliminary source-level audit; not a RISC-V compliance claim.

## Summary

TitoRV is currently a small 32-bit, in-order pipelined core with an instruction-memory interface and a single-outstanding AXI-Lite data interface. The RTL implements a limited subset of RV32I-style behaviour. It must not yet be described as a complete RV32I processor.

## Intended instruction subset

| Instruction | Encoding class | Observed behaviour |
|---|---|---|
| `LUI` | U-type, opcode `0110111` | Writes the upper 20-bit immediate shifted left by 12 to `rd`. |
| `ADDI` | I-type, opcode `0010011`, `funct3=000` | Adds sign-extended 12-bit immediate to `rs1`. |
| `ADD` | R-type, opcode `0110011`, `funct3=000`, `funct7=0000000` | Adds `rs1` and `rs2`. |
| `SUB` | R-type, opcode `0110011`, `funct3=000`, `funct7=0100000` | Subtracts `rs2` from `rs1`. |
| `BEQ` | B-type, opcode `1100011`, `funct3=000` | Redirects control flow when `rs1 == rs2`. |
| `JAL` | J-type, opcode `1101111` | Jumps to `PC + sign-extended offset` and writes `PC + 4` to `rd`. |
| `LW` | I-type, opcode `0000011`, `funct3=010` | Issues an AXI-Lite word read and writes returned data to `rd`. |
| `SW` | S-type, opcode `0100011`, `funct3=010` | Issues an AXI-Lite word write with all four byte strobes asserted. |

The table above describes the intended subset, not fully validated instruction decoding. The caveats below are important.

## Known decode and architectural limitations

- **Opcode/funct validation is incomplete.** For the OP-IMM opcode, the ALU currently performs addition for every `funct3`; it does not reject or correctly implement encodings such as `SLTI`, `XORI`, `ORI`, `ANDI`, or shifts. Do not treat those encodings as supported.
- **R-type validation is incomplete.** For `funct3=000`, the core subtracts when `funct7=0100000` and otherwise adds; it does not validate all remaining `funct7` bits before executing ADD-like behaviour. Other R-type `funct3` values also fall through to addition.
- **Load/store width validation is incomplete.** The load and store paths issue 32-bit transfers without checking `funct3`. Byte and halfword operations, sign/zero extension, and subword store strobes are not implemented.
- **Only BEQ is implemented for conditional branches.** BNE, BLT, BGE, BLTU, and BGEU are not implemented.
- **JALR is not implemented.** AUIPC is not implemented.
- **The wider RV32I instruction set is incomplete.** This includes logical operations, shifts, comparisons/set-less-than, and other missing base instructions.
- **Exceptions and traps are not established by the current tests.** Illegal-instruction handling, misaligned access handling, and architectural trap behaviour have not been demonstrated.
- **Memory system assumptions are limited.** The current testbench uses a simple instruction ROM and a single-outstanding AXI-Lite data-memory model. It does not establish correctness for caches, multiple outstanding requests, or a complete system memory map.
- **Pipeline hazards need broader validation.** The current directed suite covers selected instruction sequences, branches, jumps, and memory stalls; it does not exhaustively prove all data/control hazard combinations.

## Evidence currently available

The repository's directed correctness testbench checks selected arithmetic/register operations, LUI, BEQ taken and untaken, JAL/link behaviour, word load/store, `x0`, and AXI-Lite backpressure/delayed responses. The corresponding GitHub Actions run passed.

That is evidence for those scenarios only. It is **not** a RISC-V Architectural Certification Test result and does not establish full RV32I compliance.

## Recommended next work

1. Make instruction decoding strict: validate opcode, `funct3`, and `funct7`; ensure unsupported encodings do not accidentally execute as ADD/ADDI or word loads/stores.
2. Decide the target profile (for example, a clearly documented custom subset or full RV32I).
3. Add directed tests for each implemented instruction and edge case.
4. If targeting RV32I, implement the missing base instructions and architectural exception behaviour before running an appropriate RISC-V architectural test suite.
5. Keep this document updated as features are implemented and verified.
