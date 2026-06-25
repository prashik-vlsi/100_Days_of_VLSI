# 100 Days of VLSI — Sand to Silicon
From logic gates to silicon — a structured, 
simulation-driven VLSI design and verification journey.

---

## Engineer
**Prashik Wankhede**
B.E. Electronics and Telecommunication
Aspiring VLSI Design & Verification Engineer
📍 Maharashtra, India
🔗 [GitHub](https://github.com/prashik-vlsi/100_Days_of_VLSI)

---

## Objective
To build industry-grade competency in RTL design,
digital verification, and VLSI fundamentals through
100 days of rigorous daily practice — targeting
off-campus roles at Nvidia, Qualcomm, AMD, Intel,
Tessolve, and eInfochips.

---

## Capstone Projects
| Project | Description | Target Date |
|---------|-------------|-------------|
| VitalGuard | ECG Signal Processor SoC — cardiac monitoring for rural India | 1 Sept 2025 |
| ShieldHer | Women Safety Alert SoC — distress detection + GSM SOS | 10 Sept 2025 |
| NeuralEdge | Edge AI Inference Accelerator SoC — MAC unit + AXI4-Lite | 21 Sept 2025 |

---

## Tools & Environment
| Tool | Purpose |
|------|---------|
| iverilog | Verilog compilation and simulation |
| GTKWave | Waveform analysis and verification |
| GVim | RTL coding and editing |
| Xschem | Schematic capture |
| Yosys | RTL synthesis |
| OpenSTA | Static timing analysis |
| Magic VLSI | Layout and DRC |
| KLayout | GDSII viewing and DRC |
| Qflow | RTL to GDSII flow |
| Ngspice | SPICE simulation |
| Ubuntu 22.04 | Development environment |
| Git & GitHub | Version control and documentation |

---

## Progress Tracker

### Phase 1 — RTL Design & Verification ✅ COMPLETE
| Day | Module | Concepts Covered | Status |
|-----|--------|-----------------|--------|
| Day 01 | NOT Gate | Behavioral modeling, iverilog simulation | ✅ |
| Day 02 | Logic Gates | AND, OR, NAND, NOR, XOR, XNOR — behavioral and structural | ✅ |
| Day 03 | Adders | Half Adder, Full Adder, Ripple Carry Adder | ✅ |
| Day 04 | Comparator, MUX, DEMUX | Behavioral and structural modeling | ✅ |
| Day 05 | Subtractor, Encoder, Decoder | Priority Encoder, combined combinational design | ✅ |
| Day 06 | SR Latch, D Latch | Level-sensitive sequential circuits | ✅ |
| Day 07 | D FF, JK FF, Counters | Edge-triggered FFs, SIPO, PISO, Ripple Counter, Sync Counter | ✅ |
| Day 08 | Johnson, Ring Counter | Feedback counters, lockup states, 2N vs N states | ✅ |
| Day 09 | Moore FSM | Sequence detector, state diagram, output on state only | ✅ |
| Day 10 | Mealy FSM | 1011 sequence detector, output on state and input | ✅ |
| Day 11 | Memory | Single Port RAM, Dual Port RAM, ROM — behavioral models | ✅ |
| Day 12 | Synchronous FIFO | FIFO design, full/empty flags, pointer logic | ✅ |
| Day 13 | Asynchronous FIFO | Gray code pointers, CDC, dual clock domains | ✅ |
| Day 14 | Advanced CDC | Metastability, synchronizers, MTBF, pulse sync | ✅ |
| Day 15 | RTL Timing & Synthesis | Timing analysis, critical path, setup/hold | ✅ |
| Day 16 | Low Power Design | ICG clock gating cell, 4/4 tests passed | ✅ |
| Day 17 | AXI4-Lite Slave | AXI4-Lite protocol, read/write channels, handshake | ✅ |
| Day 18 | ALU 8-bit Full Flags | Arithmetic and logic ops, carry, zero, overflow, sign flags | ✅ |
| Day 19 | Barrel Shifter | LSL, LSR, ASR, ROL, ROR — parameterized, combinational | ✅ |
| Day 20 | Multiplier | Array multiplier, Booth encoding, signed/unsigned | ✅ |

### Phase 2 — Protocols & Bus Interfaces 🔄 IN PROGRESS
| Day | Module | Concepts Covered | Status |
|-----|--------|-----------------|--------|
| Day 21 | UART Transmitter | Baud rate, start/stop bits, parity, 8N1 format | ✅ |
| Day 22 | UART Receiver | Oversampling 16x, start detection, loopback verified | ✅ |
| Day 23 | SPI Master | CPOL/CPHA modes, SCLK MOSI MISO CS, Xschem schematic | ✅ |
| Day 24 | SPI Slave | CS detection, MISO drive, Master-Slave loopback | ✅ |
| Day 25 | I2C Master | Start/stop, ACK/NACK, address phase | ✅ |
| Day 26 | I2C Slave | Address decode, data transfer, ACK generation | ⬜ |
| Day 27 | APB Bus | Setup/access phase, PREADY, PSEL, PENABLE | ⬜ |
| Day 28 | APB Slave Peripheral | Register map, timer peripheral, APB handshake | ⬜ |
| Day 29 | AHB-Lite Master | Address/data phase, HREADY, burst transfers | ⬜ |
| Day 30 | AHB-Lite Slave | HRESP, HREADYOUT, slave response | ⬜ |
| Day 31 | AXI4-Lite Write | Write address, write data, write response channels | ⬜ |
| Day 32 | AXI4-Lite Read | Read address, read data channels, VALID/READY | ⬜ |
| Day 33 | CDC 2FF Synchronizer | Two flop sync, MTBF, metastability window | ⬜ |
| Day 34 | CDC Gray Code | Gray code counter, async FIFO CDC | ⬜ |
| Day 35 | Reset Strategy | Sync vs async reset, reset tree | ⬜ |
| Day 36 | Reset Synchronizer | Assert async deassert sync, reset CDC | ⬜ |
| Day 37 | Clock Gating | ICG cell, enable conditioning, power saving | ⬜ |
| Day 38 | Power Gating | Multi-Vt, retention, power domains | ⬜ |
| Day 39 | Phase 2 Project | UART + FIFO + APB integrated — VitalGuard block 2 | ⬜ |
| Day 40 | Phase 2 Review | All protocols, interview preparation | ⬜ |

### Phase 3 — Synthesis & Static Timing ⬜ UPCOMING
| Day | Module | Concepts Covered | Status |
|-----|--------|-----------------|--------|
| Day 41 | STA Fundamentals | Setup/hold, slack, WNS/TNS | ⬜ |
| Day 42 | STA Advanced | Clock skew, CPPR, OCV | ⬜ |
| Day 43 | Yosys Synthesis | read_verilog, synth, write_verilog | ⬜ |
| Day 44 | Yosys Advanced | Reports, area timing power | ⬜ |
| Day 45 | SDC Constraints | create_clock, input/output delay | ⬜ |
| Day 46 | SDC Advanced | Output delay, timing exceptions | ⬜ |
| Day 47 | OpenSTA Basic | Timing analysis on netlist | ⬜ |
| Day 48 | OpenSTA Advanced | Critical path, ECO fixes | ⬜ |
| Day 49 | DFT Basics | Scan chain, ATPG, fault models | ⬜ |
| Day 50 | DFT Advanced | Fault coverage, BIST | ⬜ |
| Day 51 | Synthesis RTL Coding | Latch inference, mux mapping | ⬜ |
| Day 52 | Synthesis Optimization | Area power timing tradeoffs | ⬜ |
| Day 53 | Area Power Timing | Read synthesis reports | ⬜ |
| Day 54 | Synthesis Debugging | Fix violations | ⬜ |
| Day 55 | OpenTimer | Timing graph, critical path | ⬜ |
| Day 56 | OpenTimer Advanced | Path based analysis | ⬜ |
| Day 57 | Ngspice Basic | CMOS inverter DC transient | ⬜ |
| Day 58 | Ngspice Advanced | SPICE parameters, corners | ⬜ |
| Day 59 | Xschem Advanced | VitalGuard block schematic | ⬜ |
| Day 60 | Phase 3 Project | Synthesize UART, full STA | ⬜ |

### Phase 4 — Physical Design ⬜ UPCOMING
| Day | Module | Concepts Covered | Status |
|-----|--------|-----------------|--------|
| Day 61 | Standard Cells | LEF/DEF, cell library concepts | ⬜ |
| Day 62 | Standard Cells Advanced | Timing Liberty files | ⬜ |
| Day 63 | Floorplanning | Die area, IO ring, power planning | ⬜ |
| Day 64 | Floorplanning Advanced | Power planning, IR drop | ⬜ |
| Day 65 | Placement | RePlAce, density, congestion | ⬜ |
| Day 66 | Placement Advanced | Timing driven placement | ⬜ |
| Day 67 | Clock Tree Synthesis | Skew, latency, TritonCTS | ⬜ |
| Day 68 | CTS Advanced | Useful skew, balancing | ⬜ |
| Day 69 | Routing Basic | Global and detail routing | ⬜ |
| Day 70 | Routing Advanced | DRC violations, fixing | ⬜ |
| Day 71 | Magic VLSI Basic | Draw inverter layout, DRC | ⬜ |
| Day 72 | Magic VLSI Advanced | NAND gate layout | ⬜ |
| Day 73 | LVS Basic | Netlist vs layout | ⬜ |
| Day 74 | LVS Advanced | Magic LVS full flow | ⬜ |
| Day 75 | Parasitic Extraction | RC parasitics | ⬜ |
| Day 76 | Back Annotation | Post layout STA | ⬜ |
| Day 77 | Qflow Basic | RTL to GDSII simple design | ⬜ |
| Day 78 | Qflow Advanced | Full flow optimization | ⬜ |
| Day 79 | KLayout Basic | GDSII viewing, DRC | ⬜ |
| Day 80 | KLayout Advanced | Final DRC signoff | ⬜ |

### Phase 5 — Verification, UVM & Capstone ⬜ UPCOMING
| Day | Module | Concepts Covered | Status |
|-----|--------|-----------------|--------|
| Day 81 | SystemVerilog Basic | Interfaces, always_ff, always_comb | ⬜ |
| Day 82 | SystemVerilog Advanced | Logic types, packages | ⬜ |
| Day 83 | SystemVerilog Expert | Clocking blocks | ⬜ |
| Day 84 | SVA Basic | Immediate assertions | ⬜ |
| Day 85 | SVA Advanced | Concurrent assertions | ⬜ |
| Day 86 | SVA Expert | Sequences, properties | ⬜ |
| Day 87 | Constrained Random Basic | rand, randc, randomize() | ⬜ |
| Day 88 | Constrained Random Advanced | Constraints, distributions | ⬜ |
| Day 89 | Functional Coverage | covergroup, coverpoint | ⬜ |
| Day 90 | Coverage Advanced | Cross coverage, closure | ⬜ |
| Day 91 | UVM Architecture | Phases, factory pattern | ⬜ |
| Day 92 | UVM Components | Driver, monitor, scoreboard | ⬜ |
| Day 93 | UVM Agent Env | Full UVM testbench | ⬜ |
| Day 94 | UVM Advanced | Sequences, virtual sequencer | ⬜ |
| Day 95 | Capstone Day 1 | VitalGuard RTL integration | ⬜ |
| Day 96 | Capstone Day 2 | Yosys synthesis, STA | ⬜ |
| Day 97 | Capstone Day 3 | Magic layout, KLayout DRC | ⬜ |
| Day 98 | GitHub Polish Day 1 | README, waveforms, GDSII | ⬜ |
| Day 99 | GitHub Polish Day 2 | Documentation, recruiter ready | ⬜ |
| Day 100 | Full Mock Interview | All 5 phases, timed, no hints | ⬜ |

---

## Key Concepts Mastered So Far

### RTL Design
- CMOS static and dynamic behavior
- Combinational circuit design and verification
- Latch vs Flip-Flop — level vs edge triggering
- Shift register architectures — SIPO, PISO
- Counter design — ripple vs synchronous
- Johnson Counter — 2N states, complement feedback
- Ring Counter — N states, lockup state awareness
- Moore and Mealy FSM design and verification
- Synchronous and Asynchronous FIFO
- Clock Domain Crossing — metastability, MTBF
- RTL Timing Analysis — setup/hold, critical path
- Low Power Design — ICG clock gating
- ALU — arithmetic, logic, full flag generation
- Barrel Shifter — LSL LSR ASR ROL ROR
- Multiplier — array, Booth encoding

### Protocols
- UART — TX RX baud rate parity 8N1 loopback
- SPI — Master Slave CPOL CPHA full duplex

### Tools Used
- iverilog — simulation
- GTKWave — waveform verification
- GVim — RTL coding
- Xschem — schematic capture

---

## Repository Structure
100_Days_of_VLSI/

└── Sand_to_Silicon_1_30/
├── Day01/
├── Day02/
├── Day03/
├── Day04/
├── Day05/
├── Day06/
├─ Day07/
├── Day08/
├── Day09/
├── Day10/
├── Day11/
├── Day12/
├── Day13/
├── Day14/
├─ Day15/
├── Day16/
├── Day17_AXI4Lite/
├── Day18_ALU/
├── Day19_Barrel_Shifter/
├── Day20_Multiplier/
├── Day21_UART_TX/
├── Day22_UART_RX/
├── Day23_SPI_Master/
└── Day24_SPI_Slave/

---

## Milestone Dates
| Milestone | Date |
|-----------|------|
| Phase 1 Complete | 25 June 2025 ✅ |
| Phase 2 Complete | 15 July 2025 |
| Phase 3 Complete | 4 August 2025 |
| Phase 4 Complete | 24 August 2025 |
| Phase 5 Complete | 1 September 2025 |
| VitalGuard GDSII submitted to OpenMPW | 1 September 2025 |
| ShieldHer Complete | 10 September 2025 |
| NeuralEdge Complete | 21 September 2025 |
| NPTEL Exam | 18 October 2025 |
| Interview Ready | 17 November 2025 |
| Internship Target | January 2026 |
| Full Time Offer Target | September 2026 |

---

## Target Companies
| Company | Role | Type |
|---------|------|------|
| Tessolve | Jr VLSI Engineer | First target |
| eInfochips | RTL Engineer | First target |
| HCL VLSI | Design Engineer | First target |
| Qualcomm India | VLSI Engineer | Dream target |
| Intel India | Graduate Engineer | Dream target |
| AMD India | Design Engineer | Dream target |
| Nvidia India | VLSI Engineer | Ultimate target |

---

## Daily Commitment
- Minimum one module designed, simulated, verified per day
- Every module pushed to GitHub with testbench and waveform
- Interview-grade understanding — not just working code
- Targeting Nvidia, Qualcomm, AMD, Intel, Tessolve, eInfochips

---

*This repository is a living document.
Updated daily.
Sand to Silicon — 100 days of real engineering.*
