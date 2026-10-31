# Day 06 — SystemVerilog Combinational RTL & RV32I Datapath Fundamentals

## Overview

Day 06 focused on applying SystemVerilog combinational RTL constructs to practical RV32I datapath components. The objective was to move beyond language-level syntax and establish a disciplined RTL development workflow consisting of design, self-checking verification, simulation, and waveform inspection.

The work concentrated on combinational datapath selection, effective-address generation, control-driven behavior, and verification using Verilator and GTKWave.

## Learning Objectives

- Develop synthesizable combinational RTL using SystemVerilog.
- Apply `always_comb` to hardware-oriented logic.
- Use blocking assignments appropriately in combinational processes.
- Understand how multiplexers perform datapath selection in a processor.
- Apply combinational arithmetic to RV32I address generation.
- Develop self-checking testbenches for RTL modules.
- Validate functionality through both automated checks and waveform inspection.
- Strengthen the distinction between RTL functionality and testbench verification.

## Combinational RTL Fundamentals

Combinational hardware produces outputs solely from the current input values and does not retain state between evaluations.

SystemVerilog's combinational constructs provide clearer design intent than traditional Verilog coding styles. During this session, emphasis was placed on complete output assignment, deterministic behavior, and avoiding unintended storage inference.

A key RTL convention reinforced during the exercises was the use of blocking assignments for combinational procedural logic.

## RV32I ALU Operand Selection

A 32-bit ALU operand-selection multiplexer was developed to model the selection of the ALU's second operand within an RV32I datapath.

The block selects between register-sourced data and an immediate operand according to a control signal. This represents an important datapath function because different RV32I instruction classes require different ALU operand sources.

The exercise reinforced:

- 32-bit datapath multiplexing
- Control-driven operand selection
- Complete combinational assignment
- Separation between control generation and datapath operation
- Self-checking functional verification

## RV32I Program Counter Selection

A 32-bit PC source multiplexer was implemented to model next-PC selection.

The design selects between sequential program execution and an alternate control-flow target. This introduced the role of multiplexers in instruction-fetch control and demonstrated how processor control signals redirect datapath values.

Verification covered both selection paths and confirmed the expected behavior through simulation and waveform analysis.

This block forms a foundation for later integration with branch and jump control logic.

## RV32I Effective Address Generation

An effective-address generation block was developed for RV32I memory operations.

Load and store instructions calculate their memory address using a base register and a sign-extended immediate offset. The exercise applied combinational arithmetic to this processor datapath operation.

Verification considered:

- Positive address offsets
- Zero offsets
- Negative offsets
- 32-bit arithmetic wraparound

This exercise also reinforced the architectural distinction between the roles of `rs1` and `rs2` in memory instructions. The base address is derived from `rs1`, while `rs2` serves as store data for store operations.

## Conditional RTL

Conditional decision logic was reviewed in the context of processor control.

An RV32I-oriented branch decision example was used to reinforce the relationship between conditional RTL and control-flow decisions. Since conditional constructs had previously been covered in Verilog, the focus was placed on their application in SystemVerilog RTL rather than repeating basic syntax.

## Case-Based Control Decoding

Case-based combinational logic was applied to an RV32I-oriented ALU control-decoding example.

The exercise demonstrated why case structures are well suited to decoding encoded control fields and selecting among multiple operations.

The current decoder is intentionally limited in scope and serves as a control-decoding exercise rather than a complete RV32I instruction decoder. Full RV32I ALU decoding requires additional instruction fields to distinguish operations that share the same function encoding.

## Verification Methodology

Each significant RTL block was paired with a self-checking testbench.

Rather than relying exclusively on waveform observation, the testbenches compare DUT outputs against expected results and report explicit pass or fail conditions.

The verification workflow established during this session was:

**Stimulus → DUT Evaluation → Expected-Value Comparison → PASS/FAIL → Waveform Inspection**

This approach is more scalable than manual waveform-only verification and provides a foundation for more advanced SystemVerilog verification techniques.

## Simulation and Waveform Workflow

The SystemVerilog execution workflow was improved to support separate design and testbench files.

The runner now provides a reusable flow for:

- Selecting the working directory
- Selecting the design source
- Selecting the corresponding testbench
- Selecting the simulation top module
- Compiling with Verilator
- Executing the simulation
- Reporting clean simulation results
- Generating VCD waveform data
- Optionally opening the waveform in GTKWave

This separates RTL source code from verification code and provides a cleaner workflow for progressively larger designs.

## Waveform Verification

GTKWave was used to inspect the PC multiplexer behavior.

The waveform confirmed that changes in the control signal correctly redirected the next-PC output between the sequential PC value and the alternate target address.

Waveform analysis was treated as a debugging and signal-observation mechanism, while the self-checking testbench remained responsible for determining functional correctness.

## Engineering Practices Reinforced

Several practical RTL-development principles were reinforced during Day 06:

- Keep design and testbench files separate.
- Use explicit module interfaces.
- Treat control signals and datapath signals according to their architectural roles.
- Use blocking assignments for combinational procedural logic.
- Ensure every combinational output is assigned for all relevant execution paths.
- Verify DUT outputs rather than merely checking applied stimulus.
- Allow combinational logic to settle before checking results in simulation.
- Prefer self-checking verification over manual output inspection.
- Use hexadecimal representation for processor addresses and datapath values where appropriate.
- Use waveform inspection to complement, not replace, automated verification.
- Distinguish successful compilation from successful functional verification.

## RV32I Relevance

The components developed during this session correspond to fundamental processor datapath operations:

| Component | RV32I Role |
|---|---|
| ALU Operand Multiplexer | Selects register or immediate ALU operand |
| PC Source Multiplexer | Selects the next instruction address |
| Effective Address Generator | Calculates load/store memory addresses |
| Branch Decision Logic | Supports conditional control-flow decisions |
| ALU Control Decoding | Converts instruction information into datapath control |

Although individually small, these blocks represent building elements that will later be integrated into a complete RV32I processor datapath and control architecture.

## Tools Used

- SystemVerilog
- Verilator
- GTKWave
- Bash
- VCD waveform generation
- Linux-based RTL development environment

## Day 06 Outcome

Day 06 established a complete small-scale RTL workflow from specification through verification.

The session progressed from basic combinational selection to processor-oriented datapath components while introducing disciplined self-checking verification and waveform analysis.

The primary outcome was not simply implementation of individual modules, but development of a repeatable engineering process:

**Specification → RTL → Compile → Self-Checking Testbench → Simulation → Waveform Analysis → Verification**

This workflow will be reused as the design complexity increases toward ALU development, control decoding, sequential RTL, register structures, finite-state machines, and ultimately RV32I processor integration.

## Status

**Day 06: Completed**

**Primary Focus:** Combinational RTL and RV32I Datapath Fundamentals  
**Verification:** Self-checking simulation and waveform inspection  
**Next Direction:** Multi-operation combinational datapath and control logic