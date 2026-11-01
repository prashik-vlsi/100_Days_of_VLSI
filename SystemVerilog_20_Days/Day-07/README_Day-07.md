# Day 07 — Combinational RTL Design for an RV32I Processor

**Track:** SystemVerilog | RTL Design | Functional Verification  
**Application:** RV32I datapath and control logic  
**Implementation style:** Combinational, synthesizable SystemVerilog  
**Simulation environment:** Verilator with self-checking testbenches

---

## 1. Overview

This module of the *100 Days of VLSI — Sand to Silicon* learning track focuses on designing, understanding, and verifying combinational logic blocks that appear in an RV32I processor.

The emphasis is not merely on writing syntactically correct SystemVerilog. Each exercise connects a digital-design concept to a processor function, identifies the intended hardware behaviour, and uses simulation to check the RTL against expected results.

The work covers data selection, priority resolution, instruction decoding, comparison, arithmetic, ALU control, immediate generation, and branch decision logic.

> **Scope:** These are educational RTL blocks and integration exercises. They do not, individually or collectively, constitute a complete RV32I processor or a fully compliant RISC-V privileged architecture implementation.

## 2. Learning Objectives

By the end of this module, the intended competencies are:

- Distinguish continuous assignments from procedural combinational logic and choose an appropriate coding style.
- Describe multiplexers, encoders, priority encoders, decoders, comparators, and arithmetic units using synthesizable SystemVerilog.
- Relate combinational blocks to RV32I instruction execution and datapath control.
- Understand signed and unsigned comparisons in two's-complement datapaths.
- Decode instruction fields and generate ALU operation controls.
- Use `case`, `casez`, `unique case`, and `priority case` with a clear understanding of their semantics.
- Prevent unintended latch inference through complete combinational assignments.
- Build self-checking testbenches using tasks, directed vectors, case inequality (`!==`), error counters, and simulation summaries.
- Integrate individual blocks into larger ALU and branch-execution structures.

## 3. Topic Coverage and RV32I Relevance

| Topic | Digital-design concept | RV32I connection |
|---|---|---|
| 1. `assign` vs `always_comb` | Continuous wiring versus procedural combinational logic | Instruction-field extraction and combinational control |
| 2. Multiplexers | Selection among multiple data inputs | ALU operand selection, write-back selection, and next-PC selection |
| 3. Encoders and priority encoders | Binary encoding and priority resolution | Simplified interrupt-request priority selection |
| 4. Decoders | Binary instruction classification and control generation | Opcode decoding and ALU control decoding |
| 5. Comparators | Equality, inequality, signed and unsigned relational comparison | BEQ, BNE, BLT, BGE, BLTU, and BGEU |
| 6. Arithmetic combinational circuits | Addition, subtraction, carry/wraparound behaviour | ADD/SUB execution in the integer datapath |
| 7. `casez`, `unique case`, `priority case` | Pattern matching, exclusivity intent, and priority intent | ALU operation decoding and priority selection |
| 8. Latch inference and prevention | Complete assignment and combinational storage avoidance | Immediate generation and control logic |
| 9. Integrated exercise | Multi-operation ALU | RV32I arithmetic, logical, shift, and set-less-than operations |
| 10. Integrated exercise | Branch comparison and PC selection | Branch-taken decision and next-PC generation |

## 4. Design and Verification Exercises

The Day-07 exercise set contains the following RTL modules and testbenches. The source files are kept together in the `Day-07` directory; there are no per-exercise subdirectories.

| Exercise | Design file(s) | Testbench | Purpose |
|---|---|---|---|
| Q1 | `rv32i_instr_info.sv` | `tb_rv32i_instr_info.sv` | Extract instruction fields and classify selected RV32I opcodes |
| Q2 | Existing MUX exercise files | Existing testbench | Implement and verify data selection |
| Q3 | `irq_encoder.sv` | `tb_irq_encoder.sv` | Select the highest-priority asserted interrupt request |
| Q4 | Existing decoder / ALU-control files | Existing testbench | Decode instruction classes and ALU control information |
| Q5 | `branch_comp.sv` | `tb_branch_comp.sv` | Implement the six RV32I branch comparisons |
| Q6 | `arith_unit.sv` | `tb_arith_unit.sv` | Implement a 32-bit combinational ADD/SUB unit |
| Q7 | `alu_decode.sv`, `irq_priority_case.sv` | `tb_case_constructs.sv` | Demonstrate ALU decoding and priority/pattern case constructs |
| Q8 | `imm_gen.sv` | `tb_imm_gen.sv` | Generate sign-extended I/S/B/J immediates and U-type immediates |
| Q9 | `rv32i_alu.sv` | `tb_rv32i_alu.sv` | Integrate common RV32I ALU operations |
| Q10 | `branch_unit.sv` | `tb_branch_unit.sv` | Integrate branch comparison with next-PC selection |

**Dependency:** `branch_unit.sv` instantiates `branch_comp.sv`; compile both design files with `tb_branch_unit.sv` for Q10.

**Latch demonstration:** `latch_inference_example.sv` is intentionally incomplete and is included only to illustrate an undesirable coding pattern. Do not include it in the normal Q8 simulation or synthesis run.

## 5. Technical Notes

### 5.1 `assign` and `always_comb`

- Use continuous assignments for simple combinational wiring, such as extracting fixed instruction fields.
- Use `always_comb` for procedural combinational logic involving conditions, cases, and multiple related assignments.
- Assign every output on every possible path in an `always_comb` block.
- Use blocking assignments (`=`) for procedural combinational logic.

### 5.2 Multiplexers

A multiplexer selects one input according to a select signal. In an RV32I datapath, multiplexers are used to choose such values as the ALU's second operand and the next PC value. Cascaded selection logic can contribute to a critical combinational timing path.

### 5.3 Encoders and Priority Encoders

A basic encoder assumes a one-hot input condition. A priority encoder defines which input wins when multiple requests are asserted.

The `irq_encoder` exercise uses the priority order:

`irq[7] > irq[6] > irq[5] > irq[4] > irq[3] > irq[2] > irq[1] > irq[0]`

The `valid` output distinguishes the no-request condition from a valid request for IRQ0, whose encoded ID is also `3'b000`.

### 5.4 RV32I Branch Comparisons

The branch `funct3` field determines the comparison:

| `funct3` | Instruction | Comparison |
|---|---|---|
| `000` | BEQ | `rs1 == rs2` |
| `001` | BNE | `rs1 != rs2` |
| `100` | BLT | signed `rs1 < rs2` |
| `101` | BGE | signed `rs1 >= rs2` |
| `110` | BLTU | unsigned `rs1 < rs2` |
| `111` | BGEU | unsigned `rs1 >= rs2` |

Signedness is not a property of the bit pattern itself. It determines how a relational operation interprets that pattern. For example, `32'hFFFF_FFFF` represents -1 as a signed 32-bit two's-complement value, but 4,294,967,295 as an unsigned value.

### 5.5 Arithmetic and ALU Operations

The arithmetic unit returns a 32-bit result. Any carry or borrow beyond bit 31 is not represented in the result, so the result follows modulo-\(2^{32}\) arithmetic.

The integrated ALU exercise uses this operation encoding:

| `alu_op` | Operation |
|---:|---|
| 0 | ADD |
| 1 | SUB |
| 2 | SLL |
| 3 | SLT |
| 4 | SLTU |
| 5 | XOR |
| 6 | SRL |
| 7 | SRA |
| 8 | OR |
| 9 | AND |

For shift operations, the RV32I register shift amount is taken from `b[4:0]`.

### 5.6 SystemVerilog Case Constructs

- `case` performs exact matching of the case expression against the case items.
- `casez` treats `Z` and `?` bits as don't-care positions for matching. Use it carefully because it can hide unknown-value problems.
- `unique case` communicates that at most one item is expected to match and enables tool checks for violations.
- `priority case` communicates that the first matching item has priority and enables tool checks related to priority/completeness.

These constructs express different design intent; they should not be treated as interchangeable syntax.

### 5.7 Latch Inference

A latch is inferred when a procedural output must retain its previous value for a condition in which it is not assigned. For combinational logic, provide default assignments before conditional or case statements and ensure every output is assigned on every path.

The immediate generator uses a default immediate value before decoding the opcode. The separate latch example intentionally omits an assignment and is included only as a negative example.

## 6. Verification Approach

The supplied testbenches use directed tests and self-checking comparisons.

Typical verification structure:

1. Apply input values.
2. Allow combinational logic to settle.
3. Compare DUT outputs against expected values using `!==`.
4. Increment an error counter on mismatches.
5. Print a final test summary.

The test vectors target normal operation, boundary values, simultaneous requests, unsupported encodings, signed/unsigned differences, and taken/not-taken branch conditions.

A passing directed testbench is useful evidence, but it is not proof of exhaustive correctness. It does not replace constrained-random testing, assertions, formal verification, or integration testing.

## 7. Running the Simulations

Use the repository's existing SystemVerilog runner:

```bash
./run_systemverilog.sh
```

Select the relevant DUT and testbench files and set the testbench module as the top module.

### Source selection

| Exercise | Files to compile | Top module |
|---|---|---|
| Q1 | `rv32i_instr_info.sv`, `tb_rv32i_instr_info.sv` | `tb_rv32i_instr_info` |
| Q3 | `irq_encoder.sv`, `tb_irq_encoder.sv` | `tb_irq_encoder` |
| Q5 | `branch_comp.sv`, `tb_branch_comp.sv` | `tb_branch_comp` |
| Q6 | `arith_unit.sv`, `tb_arith_unit.sv` | `tb_arith_unit` |
| Q7 | `alu_decode.sv`, `irq_priority_case.sv`, `tb_case_constructs.sv` | `tb_case_constructs` |
| Q8 | `imm_gen.sv`, `tb_imm_gen.sv` | `tb_imm_gen` |
| Q9 | `rv32i_alu.sv`, `tb_rv32i_alu.sv` | `tb_rv32i_alu` |
| Q10 | `branch_comp.sv`, `branch_unit.sv`, `tb_branch_unit.sv` | `tb_branch_unit` |

Q2 and Q4 use the existing files already present in the learning repository. Do not compile `latch_inference_example.sv` as part of the normal Q8 test.

## 8. Completion and Evidence Tracking

Use this checklist to record actual implementation and simulation progress. Update a status only after reviewing the corresponding source and simulation output.

| Exercise | Work item | Status |
|---|---|---|
| Q1 | Instruction-field extraction and opcode classification; refactored DUT regression | Review / regression to confirm |
| Q2 | Multiplexer design and verification | Previously studied; confirm repository evidence |
| Q3 | 8-to-3 interrupt priority encoder and testbench | Implemented; retain simulation log |
| Q4 | Existing RV32I decoder and ALU-control work | Previously implemented; retain simulation log |
| Q5 | Branch comparator and signed/unsigned comparison tests | Supplied; run and review |
| Q6 | ADD/SUB arithmetic unit and boundary tests | Supplied; run and review |
| Q7 | Case-construct demonstration and ALU decoder tests | Supplied; run and review |
| Q8 | Immediate generator and latch-prevention review | Supplied; run and review |
| Q9 | Integrated RV32I ALU | Supplied; run and review |
| Q10 | Integrated branch unit and next-PC selection | Supplied; run and review |

## 9. Engineering Takeaways

The main lesson from combinational RTL design is that code describes hardware, not software execution steps. Coding style affects the hardware inferred by synthesis:

- A complete combinational process describes logic without state.
- An incomplete assignment can describe storage and infer a latch.
- A priority chain describes ordered selection.
- A MUX describes controlled data selection.
- Signed and unsigned operators can produce different results for identical bit patterns.
- Default assignments define safe behaviour for unsupported control encodings.
- Directed self-checking tests make expected behaviour explicit and expose regressions.

## 10. Next Step

After the supplied exercises have been simulated and reviewed, consolidate the verified blocks into a coherent RV32I datapath. The next level of work should include integration with the register file, immediate generator, ALU control, branch logic, PC selection, and a processor-level verification environment.

---

**Repository:** `prashik-vlsi/100_Days_of_VLSI`  
**Learning track:** SystemVerilog / RV32I processor development  
**Module:** Day 07 — Combinational RTL Design
