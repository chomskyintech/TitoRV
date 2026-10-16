# TitoRV correctness smoke test

This is a standalone directed simulation test for the RTL currently under
`tapeout_project/riscv_core.v`. It does not replace the existing UVM/AXI tests
and does not claim full RISC-V ISA compliance.

## What it checks

- `ADDI`, `ADD`, `SUB`, and `LUI` results
- `x0` remains zero
- A word store and a word load through the core's AXI-Lite master
- Read-after-write consistency for the tested memory word
- A completion signature, automatic pass/fail checks, and a timeout

The current `tapeout_project/riscv_core.v` decoder is only a subset of RV32I.
It does not currently implement the full base ISA, CSRs, or architectural
exception/interrupt handling. The first run's trace showed the first ROM
instruction being executed twice because the registered `instr_addr` and the
pipeline's instruction capture are misaligned for the combinational instruction
memory interface. The test starts with `addi x1, x1, 5` so duplicate execution
changes x1 from 5 to 10 and should be reported as a failure.

## Run in Vivado/XSim

1. Add `tapeout_project/riscv_core.v` and `tapeout_project/riscv_correctness_tb.sv`
   to a simulation sourceset.
2. Set `tb_riscv_correctness` as the simulation top.
3. Run behavioral simulation.
4. A successful run ends with `PASS: directed instruction, register, load/store,
   and x0 checks passed.` A timeout or mismatch calls `$fatal`.

The testbench has its own instruction ROM and AXI-Lite memory model. Do not add
`tapeout_project/instr_mem.v`, `design.sv`, or the existing UVM `testbench.sv`
to this standalone simulation unless you intentionally adapt the testbench.

## Next steps toward architectural certification

1. Expand directed tests to cover every instruction and edge case that the
   RTL actually implements.
2. Fix unsupported or incorrect ISA behavior before claiming the corresponding
   extension.
3. Add a DUT configuration, linker script, and model macros for the RISC-V
   Architectural Certification Tests (ACT4): https://github.com/riscv/riscv-arch-test
4. Integrate an ELF loader or ELF-to-hex flow and a signature/termination
   mechanism so the ACT4-generated self-checking ELFs can run on this DUT.

ACT4 tests are run on the user's own testbench; they do not provide a complete
microarchitectural verification environment by themselves.
