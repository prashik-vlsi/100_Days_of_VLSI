RV32I Day 07 — Exercises Q5 through Q10
========================================

Contents
--------
Q5_Comparator/
  branch_comp.sv       RV32I branch comparison: BEQ/BNE/BLT/BGE/BLTU/BGEU
  tb_branch_comp.sv    Directed self-checking tests, including signed/unsigned edge cases

Q6_Arithmetic/
  arith_unit.sv       32-bit combinational ADD/SUB unit
  tb_arith_unit.sv    Addition, subtraction, wraparound and boundary tests

Q7_Case_Constructs/
  alu_decode.sv           ALU operation decode using unique case and casez
  irq_priority_case.sv    Priority encoder using priority casez
  tb_case_constructs.sv   Tests both decoders
  Note: casez treats Z/? bits as don't-cares. Use carefully; it can mask unknowns.
        unique case expresses an exclusivity expectation to tools.
        priority case expresses priority intent and can issue completeness diagnostics.

Q8_Latch_Prevention/
  imm_gen.sv                   Combinational RV32I immediate generator with defaults
  tb_imm_gen.sv                Tests I/S/B/U/J immediate extraction
  latch_inference_example.sv   Deliberately incomplete assignment; educational anti-pattern only

Q9_Integrated_ALU/
  rv32i_alu.sv       Integrated 32-bit ALU: ADD/SUB/SLL/SLT/SLTU/XOR/SRL/SRA/OR/AND
  tb_rv32i_alu.sv    Self-checking tests for each operation and zero flag

Q10_Integrated_Branch/
  branch_unit.sv       Branch comparator integrated with branch/PC selection
  tb_branch_unit.sv    Branch taken/not-taken and sequential-PC tests
  Dependency: compile branch_comp.sv from Q5 with this DUT and testbench.

Simulation
----------
Use SystemVerilog mode and select the indicated testbench as top module.

Q5:
  branch_comp.sv + tb_branch_comp.sv
  top = tb_branch_comp

Q6:
  arith_unit.sv + tb_arith_unit.sv
  top = tb_arith_unit

Q7:
  alu_decode.sv + irq_priority_case.sv + tb_case_constructs.sv
  top = tb_case_constructs

Q8:
  imm_gen.sv + tb_imm_gen.sv
  top = tb_imm_gen

Q9:
  rv32i_alu.sv + tb_rv32i_alu.sv
  top = tb_rv32i_alu

Q10:
  Q5_Comparator/branch_comp.sv
  Q10_Integrated_Branch/branch_unit.sv
  Q10_Integrated_Branch/tb_branch_unit.sv
  top = tb_branch_unit

Important engineering notes
----------------------------
1. These are educational combinational blocks, not a complete RV32I core.
2. Q5 equality/inequality are bitwise value comparisons; signedness matters for relational comparisons.
3. Q6 and Q9 results are 32-bit modulo-2^32 results; arithmetic overflow is not separately flagged.
4. Q7 case constructs are demonstrated in separate roles. The ALU decode is a simplified teaching decoder, not a complete legality checker for every RV32I encoding.
5. Q8 immediate generator sign-extends I/S/B/J immediates and places U immediates in bits [31:12].
6. latch_inference_example.sv is intentionally incomplete. Do not include it in the normal Q8 simulation or synthesis flow.
7. Q10 assumes branch_imm is already correctly generated and aligned by the upstream immediate generator.
8. Testbenches use directed vectors. They are not exhaustive formal verification.
