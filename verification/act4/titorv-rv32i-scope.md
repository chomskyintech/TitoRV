# TitoRV architectural scope for ACT4 configuration

This file records the RTL facts that must drive the ACT4 UDB and Sail configuration. It is intentionally separate from a claim of ISA compliance: configuration entries must not be treated as proof that the corresponding behaviour is correct.

## Build and execution assumptions

- XLEN: 32 bits.
- Reset PC / ELF load base: `0x00000000`.
- ELF simulation harness memory: 32,768 32-bit words (128 KiB), zero-based AXI-backed instruction/data memory. This is external simulation-platform capacity, not an on-core SRAM claim.
- Single hart.
- Harness termination: a 32-bit store to `0x20000000`; value `1` means pass and any other value is a failure.
- Current ACT4 adapter smoke test checks only that termination convention.

## Base integer instruction decoder

The current RTL implements these RV32I instruction families:

- U-type: LUI, AUIPC.
- Control flow: JAL, JALR (funct3=000), BEQ, BNE, BLT, BGE, BLTU, BGEU.
- Loads: LB, LH, LW, LBU, LHU.
- Stores: SB, SH, SW.
- Immediate arithmetic/logical: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI.
- Register arithmetic/logical: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND.

## SYSTEM / privileged behaviour

The RTL additionally recognises:

- CSR access instructions CSRRW/CSRRS/CSRRC and immediate forms, but only for `mstatus`, `mtvec`, `mscratch`, `mepc`, and `mcause`.
- ECALL from M-mode, EBREAK, and MRET.
- Illegal-instruction trap cause 2 for unsupported SYSTEM encodings and malformed encodings in the explicitly checked instruction classes.

Important limitations that must be reflected in configuration and test selection:

- `mstatus` models MIE, MPIE and MPP; MPP is forced to machine mode.
- `mtvec` stores direct/vectored mode bits, but synchronous trap entry always redirects to the aligned BASE (direct behaviour).
- No `misa`, `mtval`, `mie`, `mip`, `mvendorid`, `marchid`, `mimpid`, PMP, S-mode, U-mode, or interrupt source is implemented in the inspected RTL.
- FENCE opcode encodings are accepted by the decoder but have no explicit execution action. FENCE.I is not implemented as an instruction-specific operation.
- Misaligned data accesses are not explicitly trapped by the RTL; do not configure them as trapping until a directed test proves the intended behaviour.
- The exported `trap_valid`, `trap_pc`, and `trap_cause` outputs are sticky diagnostics; they do not alone describe all architectural trap-state behaviour.

## Configuration gate

Before adding an ACT4 test configuration, validate a UDB configuration and a matching Sail 0.16 configuration against these facts. Start with the unprivileged RV32I tests and keep privileged/CSR tests excluded until every relevant UDB and Sail parameter is justified and checked. A config that merely parses, a generated ELF, or a successful termination-adapter test is not an architectural test pass.
