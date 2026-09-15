# Tiny 2x2 CGRA

Standalone RTL for a small coarse-grained reconfigurable array intended for later integration with the TitoRV RISC-V core.

## Architecture

- 2x2 array: four processing elements (PE0..PE3)
- registered PE outputs, so every routing hop is synchronous and combinational loops are avoided
- eight 32-bit external operand ports; `MUL8` interprets only the low 8 bits as signed INT8 operands
- 32-bit interconnect and PE result registers
- eight configuration contexts per PE
- one context executes per clock while the array is running
- up to eight execution cycles per launch

Each 32-bit context word is encoded as:

- `[3:0]` operation
- `[7:4]` source A selector
- `[11:8]` source B selector
- `[12]` enable
- `[31:13]` reserved

Source selectors are zero, eight external inputs, any of the four registered PE outputs, or constant one.

Supported operations currently include NOP, ADD, SUB, signed INT8 multiply, AND, OR, XOR, signed MAX/MIN, shifts, and pass-through operations.

## Dot-product mapping

The included smoke test maps a four-element signed INT8 dot product in three contexts:

1. Four PEs perform four parallel multiplies.
2. PE0 and PE1 form two partial sums.
3. PE0 adds those partial sums to produce the final 32-bit result.

This demonstrates spatial parallelism, context-based reconfiguration, registered inter-PE routing, and multi-cycle dataflow without requiring a CGRA compiler.

## Repository structure

```text
rtl/
  cgra_pe.v       processing element
  cgra_array.v    2x2 array and routing network
  cgra_top.v      context memories and run controller

tb/
  tb_cgra.v       directed standalone smoke test

synth/
  synth.ys        generic Yosys synthesis script

docs/
  integration.md  planned TitoRV/AXI-Lite integration
```

## Verification

With Icarus Verilog installed:

```bash
make sim
```

The testbench configures the same dot-product schedule once, then runs two different operand vectors. Expected results are 20 and 100.

For generic synthesis with Yosys:

```bash
make synth
```

## Integration philosophy

The CGRA RTL deliberately does not depend on AXI. Once the standalone block is verified, an AXI-Lite wrapper will expose context memory, operand registers, START/BUSY/DONE and result registers to TitoRV. Keeping the CGRA core bus-independent makes it easier to verify, synthesize and reuse.
