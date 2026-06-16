# Engineering Learning Log: Day18

**Date:** June 15, 2026  
**Focus:** Digital Design, Sequential Circuits, Architecture Widths, and Testbench Verification Environments.

---

## Executive Summary

Today, a major milestone was achieved by executing a complete design-to-verification workflow for two major processor components: a combinational **32-bit ALU** (Arithmetic Logic Unit) and a sequential **64-bit MAC** (Multiply-Accumulate) Unit. The entire cycle—from structural coding, bit-width calculation, syntax troubleshooting, testbench composition, up to waveform extraction—was successfully completed in a single intensive sprint.

---

## Core Technical Concepts Mastered

### 1. Bit-Width Calculation & Overflow Prevention

- **The Rule of Multiplication:** Learned that multiplying an $N$-bit number by an $M$-bit number yields an output width up to $(N + M)$ bits.
- **Application:** Designed a MAC unit with 32-bit inputs ($A$ and $B$). Correctly assigned a **64-bit width** to the Accumulator register to guarantee that consecutive multiplications and accumulations never lose upper bits due to structural truncation.

### 2. Separation of Concerns: RTL vs. Testbench

- **Design Under Test (DUT):** Understood that synthesis-ready hardware files (`alu.v`, `mac.v`) represent the internal logic of a silicon chip. They must remain pure and free from virtual simulator inputs or timing artifacts.
- **Testbench Environment:** Mastered how to build separate virtual wrappers (`alu_tb.v`, `mac_tb.v`).
  - Input ports to the DUT are driven as **`reg`** variables inside the testbench because their states are controlled by stimulus blocks.
  - Output ports coming out of the DUT are monitored via **`wire`** nets since they are driven solely by the hardware logic.

### 3. Sequential Hardware Control Logic

- Implemented clock-edge-triggered execution using `always @(posedge clk)`.
- Applied **Non-Blocking Assignments (`<=`)** to accurately instantiate flip-flop registers, ensuring concurrent register transitions rather than linear procedural execution.
- Implemented synchronous hardware initialization routines using active-high reset control logic (`if(rst)`).

### 4. Value Change Dump (VCD) & Waveform Parsing

- Integrated hardware visualization hooks (`$dumpfile` and `$dumpvars`) to stream binary state transitions into local `.vcd` trace files during simulator execution.
- Decoded data representations inside **GTKWave**: Learned that hex notations represent data compaction (e.g., Decimal $15 + 10 = 25$ corresponds directly to Hexadecimal value `19` inside a 32-bit bus layout). Mastered formatting alterations using GUI tools to alternate between Hex and Signed/Unsigned Decimal radices.

---

## Debugging and Problem-Solving Highlights

- **Syntax Isolation:** Successfully diagnosed a cascading syntax error caused by a missing structural closure (`endmodule`) inside an RTL component file.
- **Resolution:** Mastered how compilers construct nested module scopes when delimiter pairing goes unresolved, and learned to check structural boundaries whenever a compiler claims a directive like `` `timescale `` is nested unlawfully.

---

## Hardware Blocks Developed & Verified

### Architecture Comparison

| Feature             | 32-bit ALU                            | 64-bit MAC Unit                                       |
| :------------------ | :------------------------------------ | :---------------------------------------------------- |
| **Circuit Type**    | Pure Combinational                    | Synchronous Sequential                                |
| **Clock/Reset**     | No                                    | Yes (50 MHz Clock Vector)                             |
| **Primary Formula** | Output based on 4-bit Opcode selector | $\text{accum} \Leftarrow (A \times B) + \text{accum}$ |
| **Output Type**     | 32-bit Single Result + Flags          | 64-bit Cumulative Output                              |

---

## Verification Logs Validation

All simulated test vectors match expected algebraic behavior precisely:

- Checked addition logic verification trace ($15 + 10 = 25$).
- Evaluated Two's Complement subtraction underflows showing inverted Carry-out execution bounds.
- Verified multi-cycle scalar retention within the MAC loop ($20 \rightarrow 26 \rightarrow 126$).

**Status:** Sign-off Complete. Design is structurally verified and ready for physical synthesis preparation.
