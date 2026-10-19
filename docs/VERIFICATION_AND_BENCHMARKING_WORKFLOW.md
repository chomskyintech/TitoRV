# TitoRV Verification and Benchmarking Workflow

**Repository:** [chomskyintech/TitoRV](https://github.com/chomskyintech/TitoRV)  
**Scope:** RTL correctness, compiled ELF execution, RV32I tests, ACT4-generated test execution, retirement accounting, and RTL microbenchmarks.  
**Status date:** 19 October 2026.

This document records the workflow built around TitoRV's pipelined RV32I core: why each layer was added, how it is exercised in CI, what the results demonstrate, and what they do not demonstrate.

## 1. Verification strategy

The work was deliberately layered. No single smoke test was treated as proof of ISA compliance or performance.

1. **Source/ISA audit** — inventory the implemented instruction and system paths and record gaps.
2. **Directed RTL tests** — test known corner cases and regressions with small programs.
3. **Compiled ELF harness** — load compiled RISC-V programs into the simulated core and observe architectural effects.
4. **Public RV32UI tests** — run a pinned set of upstream instruction tests.
5. **ACT4 generation and execution** — generate architectural certification test ELFs using the RISC-V architectural test infrastructure and execute them in a DUT-specific simulation harness.
6. **Retirement accounting** — count architecturally completed instructions rather than treating cycles or internal pipeline activity as instructions.
7. **Deterministic microbenchmarks** — measure repeatable cycle, retirement, CPI, and stall behaviour for selected workloads.
8. **CI evidence and artifacts** — preserve logs, summaries, expected-count assertions, and workflow links for review.

The layers are complementary. Passing a directed test means that particular scenario passed; it does not imply exhaustive coverage.

## 2. Core and testbench context

The target is TitoRV's 32-bit in-order pipelined processor in `tapeout_project/riscv_core.v`. It fetches instructions through an instruction-memory interface and uses a single-outstanding AXI-Lite data interface. The simulation harness compiles assembly/C test programs into ELF files, loads the program into the simulated memory map, runs the RTL, and checks a completion convention or expected architectural result.

Relevant source areas include:

- `tapeout_project/riscv_core.v` — processor RTL and retirement signals.
- `tapeout_project/riscv_elf_tb.sv` — ELF execution harness and retirement/cycle accounting.
- `verification/` — directed tests and ACT4 configuration/environment.
- `verification/benchmarks/` — assembly microbenchmarks and retirement-count regressions.
- `.github/workflows/` — automated correctness, smoke, ACT4, and benchmark jobs.
- `docs/ISA_SUPPORT.md` — ISA support audit and explicit limitations.

Paths may evolve as the repository is reorganised; check the current tree before relying on a path.

## 3. Stage A — audit the implemented ISA

We first documented the RTL's intended instruction support and compared it with existing regression coverage. The audit covered RV32I upper-immediate instructions, integer immediate/register operations, branches, jumps, byte/halfword/word loads and stores, selected machine-mode CSRs, and basic trap/return paths.

The audit was kept separate from a compliance claim. It noted that implementation of an opcode path is not proof that all encodings, operand boundaries, hazard combinations, exception conditions, or memory-ordering cases are correct.

Reference: [ISA support audit](https://github.com/chomskyintech/TitoRV/blob/master/docs/ISA_SUPPORT.md).

## 4. Stage B — directed RTL correctness regressions

Small directed programs isolate a specific behaviour and make failures easier to diagnose than a large benchmark. The regression set grew to include:

- ALU results and boundary/sign-extension cases, including a discovered and fixed SRA sign-extension defect.
- Branch taken/not-taken behaviour and wrong-path instruction squash.
- JAL/JALR redirect and link-register behaviour, including JALR target bit-0 clearing.
- Load/store round trips and selected byte/halfword lane and signedness checks.
- Selected CSR read/write/set/clear operations.
- Selected trap-entry and MRET scenarios.
- Expected completion-token checks so a program cannot silently time out and be counted as passing.

When a test exposed a defect, the change was followed by a targeted regression and the relevant broader CI checks. A green run is only evidence for the scenarios actually exercised.

## 5. Stage C — compiled ELF execution harness

A fixed instruction ROM is useful for early tests, but it does not scale to upstream tests or generated certification tests. We added an ELF-oriented testbench and build flow so test programs could be compiled, linked, loaded, and executed against the RTL.

The harness needed to agree with the RTL's memory map and completion behaviour. The custom smoke convention uses a store of the value `1` to address `0x20000000` as a PASS token. The public `riscv-tests` adapter uses the `a7=93`, `a0=0` ecall-exit convention. These are harness conventions, not interchangeable with ACT4's official `RVMODEL_HALT_PASS` protocol.

This distinction matters: a program that ends under the local testbench convention is not automatically running under the official architectural-test environment.

## 6. Stage D — public RV32UI tests

CI builds and runs 37 pinned public instruction tests from [riscv-software-src/riscv-tests](https://github.com/riscv-software-src/riscv-tests), using upstream revision `d7e86f701b929b5d801f8cda1a4871ab05f452bb`.

The tests cover selected cases for common RV32I integer instructions, branches/jumps, and loads/stores. The environment adapter avoids unrelated privileged-startup requirements and uses the ecall-exit convention described above.

Historical recorded run: [RV32UI workflow run #40](https://github.com/chomskyintech/TitoRV/actions/runs/38987135936) reported 37/37 passing. Always inspect the linked run and current branch status before describing this as the latest result.

Limitations: these are instruction-level tests with selected operands, not exhaustive proof of every encoding or pipeline interaction. Their self-checking control flow also executes on the DUT.

## 7. Stage E — ACT4 generation and execution

The ACT4 integration required more than compiling a test. The environment had to provide a DUT-compatible memory layout, model macros, linker script, supported-architecture configuration, signature handling, and a termination protocol. We validated the architecture configuration against the official UDB/schema tooling and used Sail as the reference-model/configuration component in the workflow.

Issues encountered during integration included:

- Missing configuration parameter `MTVEC_BASE_ALIGNMENT_DIRECT`.
- Generated test output exceeding the original 64-KiB test memory, including a large `I-beq-00` signature.
- The generator expecting CLINT support that the core does not implement.
- Differences between the local ELF smoke completion token and ACT4's required model halt/pass protocol.

The memory/linker configuration was expanded to 128 KiB to accommodate generated tests. Generator compatibility work was kept separate from the declared RTL capabilities: a compatibility shim must not be interpreted as evidence that the core implements a peripheral it does not have. Privileged tests were disabled where they were outside the supported target/environment rather than silently claiming those features.

Recorded result: ACT4 Run #13 generated and executed the configured RV32I ELF set successfully; the log reported a PASS token after 5,414 cycles and 39 passed / 0 failed. See [ACT4 Run #13](https://github.com/chomskyintech/TitoRV/actions/runs/39068180080).

**Interpretation:** this is evidence that the configured generated tests executed and passed in this harness. It is not, by itself, a certification PDF, a certification award, or proof of full RV32I compliance. Certification claims must follow the applicable RISC-V International process and its requirements; a GitHub Actions pass is not an official certificate.

## 8. Stage F — architecturally completed instruction counting

Cycle counts alone do not say how many instructions the core completed. To make the benchmark measurements more meaningful, the RTL exposes retirement observability:

- `retire_valid`
- `retire_pc`
- `retire_insn`

The ELF testbench counts retirement events at the falling edge of the clock. The intended event is architectural completion, not simply instruction decode or issue.

For the current implementation:
- Ordinary instructions retire at execute.
- Loads retire when the AXI read response completes.
- Stores retire when the AXI write response completes.
- MRET is counted.
- Synchronous traps are not counted as retired instructions.

These definitions are important for interpreting CPI. If a future RTL change moves the point of architectural completion, the retirement interface and its tests must be reviewed together.

### Exact-count regressions

Two tiny assembly programs protect the counter against common accounting mistakes:

- `retirement_count.S` expects exactly 10 retired instructions and includes a taken branch/wrong-path check, a load/store round trip, and the PASS token.
- `retirement_controlflow.S` expects exactly 12 retirements and exercises JAL/JALR redirects, wrong-path instructions, and AXI-stalled load/store completion.

CI fails if the actual retirement count differs from the expected count. The control-flow/AXI regression also requires a nonzero stall count in the emitted metrics. This makes retirement and stall reporting testable rather than relying on visual inspection of a log.

Merged change: [PR #15 — Test retirement counts across jumps and AXI stalls](https://github.com/chomskyintech/TitoRV/pull/15), merge commit `f0ab5218034568677041170962d35925cc261814`.

Post-merge checks verified on that commit:
- [Directed correctness](https://github.com/chomskyintech/TitoRV/actions/runs/39310708087)
- [Microbenchmarks](https://github.com/chomskyintech/TitoRV/actions/runs/39310708172)
- [RV32I smoke](https://github.com/chomskyintech/TitoRV/actions/runs/39310708644)

These three post-merge checks completed successfully. Trap-entry/MRET-specific retirement accounting remains a separate area to verify explicitly.

## 9. Stage G — deterministic RTL microbenchmarks

The benchmark suite is designed for repeatable comparisons of the RTL, not to claim the performance of a fabricated processor. Workloads include ALU dependency chains, branch mixes, memory round trips, control-flow/memory-width cases, and randomized ALU/control-flow/memory mixes.

The harness reports cycle count, retirement count, architectural CPI, and stall/load/store counters where available. For a workload:

`CPI = cycles / retired`

`IPC = retired / cycles`

The label `CPI_arch` is used for the cycles-per-retired-instruction ratio. A field historically named `CPI_proxy` in logs is an integer retirement-count field; it should not be mistaken for a second CPI calculation.

### Recorded baseline

The following values were recorded by the baseline microbenchmark workflow and are RTL simulation results:

| Workload | Cycles | Retired | CPI_arch | Stalls | Loads | Stores |
|---|---:|---:|---:|---:|---:|---:|
| `alu_dependency` | 5,014 | 3,009 | 1.666 | 3 | 0 | 1 |
| `branch_mix` | 8,514 | 5,509 | 1.545 | 3 | 0 | 1 |
| `memory_roundtrip` | 1,415 | 610 | 2.320 | 603 | 100 | 101 |
| `controlflow_mem_widths` | 116 | 61 | 1.902 | 33 | 6 | 5 |
| `alu_randomized` | 392 | 385 | 1.018 | 3 | 0 | 1 |
| `controlflow_memory_randomized` | 1,498 | 1,077 | 1.391 | 411 | 100 | 37 |
| `retirement_count` | 23 | 10 | 2.300 | — | — | — |

The table is a baseline for comparisons made with the same RTL, simulator, workload, and measurement definitions. Small changes in workload, tool versions, or harness semantics can make results incomparable.

The earlier CoreMark RTL simulation recorded 1,387,069 cycles and 830,871 retirements (IPC 0.5990, CPI 1.6694). This is an RTL simulation count, **not an official CoreMark score**. An official score requires the prescribed benchmark build, execution environment, validation, and reporting rules; do not compare raw RTL simulation cycles directly with published hardware CoreMark scores.

Relevant baseline workflow: [microbenchmark run #38](https://github.com/chomskyintech/TitoRV/actions/runs/39309062784). Results should be regenerated after meaningful RTL, harness, or toolchain changes.

## 10. How to reproduce and review results

Use the repository's current documented build targets and CI workflows rather than copying stale simulator commands from a log. The general review sequence is:

1. Check out the exact commit under investigation.
2. Confirm toolchain, simulator, linker/memory-map, and test revisions used by the workflow.
3. Run the directed-correctness and RV32I smoke jobs.
4. Run ELF smoke and the pinned public RV32UI tests.
5. Run ACT4 configuration validation, generation, and execution; inspect the generated-test list, per-test results, PASS/FAIL protocol, and uploaded logs.
6. Run microbenchmarks and inspect both workload outputs and the retirement-count assertions.
7. Compare measurements only against a baseline with matching workload and measurement semantics.
8. Record the commit SHA, workflow run URL, job conclusion, and artifact/log links with any published result.

A successful job should be verified at the job/run level. A merged pull request or a successful earlier branch run does not prove that every post-merge workflow has completed.

## 11. Current limitations and next work

The workflow provides increasingly broad evidence, but these gaps remain:

- No claim of full RV32I compliance should be made solely from these tests.
- The ACT4 run is not an official certificate and does not establish certification status.
- Privileged/interrupt behaviour and the interaction of trap entry, MRET, and retirement accounting need explicit targeted verification.
- Misaligned accesses, AXI response errors, a wider range of backpressure patterns, memory ordering, and all pipeline hazard combinations are not exhaustively covered.
- The benchmark harness and tool versions should be pinned and documented sufficiently to reproduce results over time.
- CoreMark must remain labelled as an RTL simulation result unless the official scoring/validation procedure is completed.

## 12. Evidence index

- [Repository](https://github.com/chomskyintech/TitoRV)
- [ISA support audit](https://github.com/chomskyintech/TitoRV/blob/master/docs/ISA_SUPPORT.md)
- [ACT4 Run #13](https://github.com/chomskyintech/TitoRV/actions/runs/39068180080)
- [Baseline microbenchmark run #38](https://github.com/chomskyintech/TitoRV/actions/runs/39309062784)
- [PR #15 — retirement/control-flow regression](https://github.com/chomskyintech/TitoRV/pull/15)
- [Post-merge microbenchmarks](https://github.com/chomskyintech/TitoRV/actions/runs/39310708172)
- [Post-merge directed correctness](https://github.com/chomskyintech/TitoRV/actions/runs/39310708087)
- [Post-merge RV32I smoke](https://github.com/chomskyintech/TitoRV/actions/runs/39310708644)
