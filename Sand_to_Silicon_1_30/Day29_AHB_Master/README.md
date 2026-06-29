# Day 29 — AHB-Lite Master

## 100 Days of VLSI | Sand to Silicon

**Engineer:** Prashik Wankhede
**Phase:** 2 — Protocols & Bus Interfaces
**Date:** June 2026
**Capstone:** NeuralEdge SoC — Weight Fetch Engine

---

## Overview

This module implements a fully functional
**AHB-Lite Master** compliant with the
ARM AMBA AHB-Lite specification (IHI0033).

The AHB-Lite Master drives high-speed
pipelined transfers to on-chip memory,
enabling NeuralEdge to fetch neural network
weights fast enough for real-time
ECG signal classification.

---

## Problem Statement

NeuralEdge requires continuous high-bandwidth
access to on-chip weight memory during
inference. The APB bus designed in Day 27-28
is insufficient — it cannot pipeline transfers
or support burst access.

AHB-Lite solves this by overlapping the
address phase of the next transfer with
the data phase of the current transfer,
achieving significantly higher throughput.

---

## Module Specification

### Top Level — ahb_master.v

```
Module    : ahb_master
Parameters: ADDR_WIDTH = 32
            DATA_WIDTH = 32
```

### Port List

| Port    | Direction | Width | Description        |
| ------- | --------- | ----- | ------------------ |
| HCLK    | input     | 1     | AHB clock          |
| HRESETn | input     | 1     | Active low reset   |
| HADDR   | output    | 32    | Transfer address   |
| HTRANS  | output    | 2     | Transfer type      |
| HWRITE  | output    | 1     | Transfer direction |
| HSIZE   | output    | 3     | Transfer size      |
| HBURST  | output    | 3     | Burst type         |
| HWDATA  | output    | 32    | Write data         |
| HRDATA  | input     | 32    | Read data          |
| HREADY  | input     | 1     | Transfer complete  |
| HRESP   | input     | 1     | Transfer response  |

---

## AHB-Lite Protocol — Key Concepts

### Pipelined Transfer Architecture

```
Cycle    1         2         3         4
         ┌─────────┬─────────┬─────────┐
HADDR    │ ADDR_A  │ ADDR_B  │ ADDR_C  │
         ├─────────┼─────────┼─────────┤
HRDATA   │  ----   │ DATA_A  │ DATA_B  │
         └─────────┴─────────┴─────────┘

Address phase of next transfer overlaps
data phase of current transfer.
This is what makes AHB faster than APB.
```

### HTRANS Encoding

| Value | Name   | Description            |
| ----- | ------ | ---------------------- |
| 2'b00 | IDLE   | No transfer            |
| 2'b01 | BUSY   | Master busy            |
| 2'b10 | NONSEQ | First beat of burst    |
| 2'b11 | SEQ    | Subsequent burst beats |

### HBURST Encoding

| Value  | Name   | Description            |
| ------ | ------ | ---------------------- |
| 3'b000 | SINGLE | Single transfer        |
| 3'b001 | INCR   | Incrementing undefined |
| 3'b011 | INCR4  | 4-beat incrementing    |
| 3'b101 | INCR8  | 8-beat incrementing    |
| 3'b111 | INCR16 | 16-beat incrementing   |

### HREADY Wait State Handling

```
         ┌─────┬─────┬─────┬─────┐
HCLK     │     │     │     │     │
         └─────┴─────┴─────┴─────┘
         ┌───────────────┐
HADDR    │    ADDR_A     │ ADDR_B
         └───────────────┘
              ┌─────┐
HREADY   ─────┘     └──────────────
         (slave inserts wait state)

Master holds address while HREADY low.
Advances only when HREADY high.
```

---

## Implementation Details

### State Machine

```
┌─────────────────────────────────────┐
│            AHB MASTER FSM           │
│                                     │
│  IDLE ──► ADDRESS ──► DATA          │
│    ▲          │         │           │
│    │          ▼         │           │
│    │      WAIT_STATE    │           │
│    │          │         │           │
│    └──────────┴─────────┘           │
└─────────────────────────────────────┘
```

### Burst Transfer — INCR4

```
Beat 1: HTRANS=NONSEQ, HADDR=BASE
Beat 2: HTRANS=SEQ,    HADDR=BASE+4
Beat 3: HTRANS=SEQ,    HADDR=BASE+8
Beat 4: HTRANS=SEQ,    HADDR=BASE+12
Beat 5: HTRANS=IDLE,   Burst complete
```

---

## Files

| File                 | Description                |
| -------------------- | -------------------------- |
| ahb_master.v         | AHB-Lite Master RTL        |
| ahb_master_tb.v      | Testbench — SINGLE + INCR4 |
| ahb_master.ys        | Yosys synthesis script     |
| ahb_master_netlist.v | Synthesized gate netlist   |
| ahb_master.sch       | Xschem block schematic     |
| waveform.vcd         | GTKWave simulation dump    |
| README.md            | This file                  |

---

## Synthesis Results — Yosys + OSU018

```
Tool    : Yosys
Library : OSU018 0.18μm standard cells
Target  : ahb_master

Results:
  Total cells     : 361
  DFF count       : 39  ($_DFFE_PN0P_)
  Combinational   : 322 (361 - 39)
  Critical path   : Not yet measured
                    OSU018 library not mapped
                    Generic cells used
                    Rerun with abc -liberty
                    osu018.lib for timing

Key observation:
  HTRANS logic maps to [X] cells
  Burst counter maps to [X] FFs
  AHB Master larger than APB —
  because of pipeline registers
  and burst counter logic
```

---

## Simulation — GTKWave Verification

### Test 1 — SINGLE Transfer Read

```
Action  : Master reads address 0x1000
HTRANS  : IDLE → NONSEQ → IDLE
HBURST  : SINGLE
HREADY  : High — no wait state
Result  : HRDATA captured correctly ✓
```

### Test 2 — INCR4 Burst Read

```
Action  : Master reads 4 words
          from address 0x2000
HTRANS  : NONSEQ → SEQ → SEQ → SEQ
HADDR   : 0x2000 → 0x2004 →
          0x2008 → 0x200C
Result  : All 4 words correct ✓
```

### Test 3 — Wait State Handling

```
Action  : Slave asserts HREADY low
          for 2 cycles during transfer
Master  : Holds HADDR stable
          Does not advance transfer
Result  : Data integrity maintained ✓
```

### Waveform Signals to Observe

**TERMINAL OUTPUT**
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/terminal_day_29.png?raw=true)

**waveform output**
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/waveform_day29.png?raw=true)

## SYNTHESISED IMAGE OUTPUT

![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/ahb_master.png?raw=true)

## APB vs AHB-Lite Comparison

| Feature    | APB                | AHB-Lite     |
| ---------- | ------------------ | ------------ |
| Phases     | 2 — Setup + Access | Pipelined    |
| Pipeline   | No                 | Yes          |
| Burst      | No                 | Yes          |
| Bandwidth  | Low                | High         |
| Complexity | Simple             | Moderate     |
| Use case   | Timers GPIO UART   | Memory DMA   |
| Key signal | PENABLE            | HTRANS       |
| Wait state | PREADY             | HREADY       |
| Error      | PSLVERR            | HRESP        |
| VitalGuard | Timer config       | —            |
| NeuralEdge | —                  | Weight fetch |

---

## Capstone Connection — NeuralEdge

```
┌─────────────────────────────────────────┐
│  NeuralEdge Inference Engine            │
│                                         │
│  ┌──────────────┐    ┌───────────────┐  │
│  │  AHB Master  │───►│ Weight Memory │  │
│  │  (Day 29)    │    │ (on chip SPRAM│  │
│  │              │◄───│  Day 11)      │  │
│  └──────┬───────┘    └───────────────┘  │
│         │                               │
│         ▼                               │
│  ┌──────────────┐                       │
│  │  MAC Unit    │                       │
│  │  (Day 20)    │                       │
│  │  multiply    │                       │
│  │  accumulate  │                       │
│  └──────────────┘                       │
│                                         │
│  AHB Master fetches weights fast        │
│  enough to keep MAC unit busy           │
│  No stalls. Real time inference.        │
└─────────────────────────────────────────┘
```

---

## Interview Questions Covered

### Q1: What is the difference between APB and AHB-Lite?

APB is a simple 2-phase bus — setup and access —
with no pipelining, suited for low bandwidth
peripherals like timers and GPIO.
AHB-Lite is pipelined — the address phase of
the next transfer overlaps the data phase of
the current transfer, giving higher bandwidth
for memory and DMA applications.

---

### Q2: What are the 4 HTRANS states and when is each used?

IDLE — no transfer in progress.
BUSY — master busy, no transfer.
NONSEQ — first beat of a new burst or single transfer.
SEQ — subsequent beats of a burst,
address increments automatically.

---

### Q3: What happens when a slave pulls HREADY low?

The master must hold the current address and
control signals stable and not advance to the
next transfer. The current transfer is extended
by one cycle for each clock that HREADY remains
low. When HREADY goes high, the transfer
completes and master advances.

---

## Key Learning — From My Mistakes

```
Mistake 1:
  Advanced HADDR while HREADY was low.
  This caused data corruption in burst.

  Fix:
  Master must hold HADDR stable
  whenever HREADY is low.
  Address only increments when
  HREADY is high.

  Lesson:
  Pipeline stall = hold everything.
  Never advance during a stall.

Mistake 2:
  Used NONSEQ for all burst beats.
  Slave could not detect burst end.

  Fix:
  Only first beat is NONSEQ.
  All subsequent beats are SEQ.
  IDLE after last beat signals end.

  Lesson:
  HTRANS tells slave exactly
  where we are in the burst.
  It carries burst position info.
```

---

_Part of 100 Days of VLSI — Sand to Silicon_
_github.com/prashik-vlsi/100_Days_of_VLSI_
_Built by Prashik Wankhede — Tier-3 to Industry_
