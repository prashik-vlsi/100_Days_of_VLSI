# 100 Days of VLSI — Sand to Silicon

From logic gates to silicon — a structured, simulation-driven VLSI design and verification journey.

---

## Engineer

**Prashik Wankhede**
B.E. Electronics and Telecommunication
Aspiring VLSI Design & Verification Engineer
📍 Maharashtra, India
🔗 [GitHub](https://github.com/prashik-vlsi/100_Days_of_VLSI)

---

## Objective

To build industry-grade competency in RTL design, digital verification, and VLSI fundamentals
through 100 days of rigorous daily practice — targeting off-campus roles at Nvidia, Qualcomm,
AMD, Intel, Tessolve, and eInfochips.

---

## Tools & Environment

| Tool          | Purpose                              |
|---------------|--------------------------------------|
| iverilog      | Verilog compilation and simulation   |
| GTKWave       | Waveform analysis and verification   |
| GVim          | RTL coding and editing               |
| Ubuntu 22.04  | Development environment              |
| Git & GitHub  | Version control and documentation    |

---

## Progress Tracker

| Day    | Module                          | Concepts Covered                                                                 | Status |
|--------|---------------------------------|----------------------------------------------------------------------------------|--------|
| Day 01 | NOT Gate                        | Behavioral modeling, iverilog simulation                                         | ✅     |
| Day 02 | Logic Gates                     | AND, OR, NAND, NOR, XOR, XNOR — behavioral and structural                        | ✅     |
| Day 03 | Adders                          | Half Adder, Full Adder, Ripple Carry Adder                                       | ✅     |
| Day 04 | Comparator, MUX, DEMUX          | Behavioral and structural modeling                                               | ✅     |
| Day 05 | Subtractor, Encoder, Decoder    | Priority Encoder, combined combinational design                                  | ✅     |
| Day 06 | SR Latch, D Latch               | Level-sensitive sequential circuits                                              | ✅     |
| Day 07 | D FF, JK FF, Counters           | Edge-triggered FFs, SIPO, PISO, Ripple Counter, Synchronous Counter              | ✅     |
| Day 08 | Johnson, Ring Counter           | Feedback counters, lockup states, 2N vs N states                                 | ✅     |
| Day 09 | Moore FSM                       | Sequence detector, state diagram, output on state only                           | ✅     |
| Day 10 | Mealy FSM                       | 1011 sequence detector, output on state and input                                | ✅     |
| Day 11 | Memory                          | Single Port RAM, Dual Port RAM, ROM — behavioral models                          | ✅     |
| Day 12 | Synchronous FIFO                | FIFO design, full/empty flags, pointer logic                                     | ✅     |
| Day 13 | Asynchronous FIFO               | Gray code pointers, CDC, dual clock domains                                      | ✅     |
| Day 14 | Advanced CDC                    | Metastability, synchronizers, MTBF, pulse sync                                   | ✅     |
| Day 15 | RTL Timing & Synthesis          | Timing analysis, critical path, setup/hold                                       | ✅     |
| Day 16 | Low Power Design                | ICG clock gating cell, 4/4 tests passed                                          | ✅     |
| Day 17 | AXI4-Lite Slave                 | AXI4-Lite protocol, read/write channels, handshake                               | ✅     |
| Day 18 | ALU 8-bit Full Flags            | Arithmetic and logic ops, carry, zero, overflow, sign flags                      | ✅     |
| Day 19 | Barrel Shifter                  | LSL, LSR, ASR, ROL, ROR — parameterized, combinational, iverilog verified        | ✅     |

---

## Repository Structure

```
100_Days_of_VLSI/
└── Sand_to_Silicon_1_30/
    ├── Day01/
    ├── Day02/
    ├── Day03/
    ├── Day04/
    ├── Day05/
    ├── Day06/
    ├── Day07/
    ├── Day08/
    ├── Day09/
    ├── Day10/
    ├── Day11/
    ├── Day12/
    ├── Day13/
    ├── Day14/
    ├── Day15/
    ├── Day16/
    ├── Day17/
    ├── Day18/
    └── Day19_Barrel_Shifter/
```

---

## Key Concepts Mastered So Far

- CMOS static and dynamic behavior
- Combinational circuit design and verification
- Latch vs Flip-Flop — level vs edge triggering
- Shift register architectures — SIPO, PISO
- Counter design — ripple vs synchronous, propagation delay analysis
- Johnson Counter — 2N states, complement feedback
- Ring Counter — N states, direct feedback, lockup state awareness
- Moore and Mealy FSM design and verification
- Synchronous and Asynchronous FIFO — pointer logic, gray code, CDC
- Clock Domain Crossing — metastability, synchronizers, MTBF
- RTL Timing Analysis — setup/hold, critical path
- Low Power Design — ICG clock gating
- AXI4-Lite Slave — handshake protocol, read/write channels
- ALU design — arithmetic, logic, full flag generation
- Barrel Shifter — LSL, LSR, ASR, ROL, ROR, parameterized RTL
- Testbench writing, VCD dump, GTKWave waveform verification
- $signed() type casting — zero gate overhead, MSB routing change

---

## Daily Commitment

- Minimum one module designed, simulated, and verified per day
- Every module pushed to GitHub with testbench and waveform
- Interview-grade understanding — not just working code
- Targeting Nvidia, Qualcomm, AMD, Intel, Tessolve, eInfochips

*This repository is a living document. Updated daily.*
