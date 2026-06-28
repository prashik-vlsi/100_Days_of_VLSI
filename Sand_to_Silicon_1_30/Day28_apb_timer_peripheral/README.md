# Day 28 — APB Timer Peripheral

### 100 Days of VLSI — VitalGuard SoC Project

**Engineer:** Prashik Wankhede
**GitHub:** [github.com/prashik-vlsi/100_Days_of_VLSI](https://github.com/prashik-vlsi/100_Days_of_VLSI)
**Tools:** iverilog · GTKWave · GVim · Yosys · Ubuntu 22.04
**Date:** 28 June 2026

---

## VitalGuard SoC Context

VitalGuard is a cardiac monitoring SoC designed for rural India.
The APB Timer Peripheral built today is the **ECG sampling engine clock source**.
It fires a `done_out` pulse every 10ms — triggering the ECG analog front end to capture one sample.
An incorrect timer means corrupted ECG data and wrong patient diagnosis.

**This module is safety-critical.**

---

## Module Overview

| Parameter    | Value                                  |
| ------------ | -------------------------------------- |
| Module       | `apb_timer_peripheral`                 |
| Protocol     | ARM AMBA APB (Advanced Peripheral Bus) |
| Data Width   | 32-bit parameterized                   |
| Addr Width   | 32-bit parameterized                   |
| Registers    | 3 — Load, Control, Status              |
| Error Handle | PSLVERR on invalid address             |
| Wait States  | PREADY — slave busy signaling          |
| Synthesis    | Yosys — 356 cells                      |
| Simulation   | iverilog + GTKWave                     |

---

## Register Map

| Address | Register | Access | Description                     |
| ------- | -------- | ------ | ------------------------------- |
| `0x00`  | LOAD_REG | W      | Timer load value — count cycles |
| `0x04`  | CTRL_REG | W      | bit[0] = 1 start / 0 stop       |
| `0x08`  | STAT_REG | R      | bit[0] = 1 when timer done      |

**Note:** STAT_REG is hardware-set. Processor cannot write it.
Writing to any other address asserts PSLVERR.

---

## Port List

```verilog
module apb_timer_peripheral #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // Clock and Reset
    input  wire                   clk,
    input  wire                   rst_n,

    // APB Interface — Master to Slave
    input  wire [ADDR_WIDTH-1:0]  paddr,
    input  wire                   psel,
    input  wire                   penable,
    input  wire                   pwrite,
    input  wire [DATA_WIDTH-1:0]  pwdata,

    // APB Interface — Slave to Master
    output reg  [DATA_WIDTH-1:0]  prdata,
    output reg                    pready,
    output reg                    pslverr,

    // Timer Output — VitalGuard ECG Engine
    output reg                    done_out
);
```

---

## Architecture

```
                    ┌─────────────────────────────────────┐
                    │       apb_timer_peripheral           │
                    │                                      │
  paddr ──────────► │  ┌──────────────┐                   │
  psel  ──────────► │  │  APB Write   │──► load_reg       │
  penable ────────► │  │  Decoder     │──► ctrl_reg       │
  pwrite ─────────► │  └──────────────┘                   │
  pwdata ─────────► │                                      │
                    │  ┌──────────────┐                   │
                    │  │  APB Read    │◄── load_reg       │──► prdata
                    │  │  Decoder     │◄── ctrl_reg       │
                    │  └──────────────┘◄── stat_reg       │
                    │                                      │
                    │  ┌──────────────┐                   │
                    │  │    Timer     │                   │
                    │  │  Countdown   │──► stat_reg       │──► done_out
                    │  │    Logic     │                   │
                    │  └──────────────┘                   │
                    │   load_reg → timer_count             │
                    │   ctrl_reg controls start/stop       │
                    └─────────────────────────────────────┘
```

---

## APB Transaction Protocol

### Write Transaction — 3 Phases

```
Phase 1 (Setup)  : psel=1, pwrite=1, paddr=addr, pwdata=data
Phase 2 (Enable) : penable=1
Phase 3 (Idle)   : psel=0, penable=0, pwrite=0
```

### Read Transaction — 3 Phases

```
Phase 1 (Setup)  : psel=1, pwrite=0, paddr=addr
Phase 2 (Enable) : penable=1 → prdata valid
Phase 3 (Idle)   : psel=0, penable=0
```

### Error Response

```
Invalid address  : PSLVERR=1 for one cycle → auto-cleared
```

---

## Timer Operation

```
Step 1 — Processor writes count value N to LOAD_REG  (0x00)
Step 2 — Processor writes 1 to CTRL_REG             (0x04)
Step 3 — timer_count loads from load_reg             (start)
Step 4 — timer_count decrements every clock cycle
Step 5 — timer_count hits 1 → stat_reg=1, done_out=1
Step 6 — ECG engine receives done_out pulse
Step 7 — Processor reads STAT_REG (0x08) → confirms done
```

**VitalGuard ECG:** At 50MHz clock, load value 500,000 gives exactly 10ms sampling window.

---

## Simulation Results

### Terminal Output

```
Time=0       | done_out=0 | pslverr=0 | prdata=00000000 | pready=0
Time=15000   | done_out=0 | pslverr=0 | prdata=00000000 | pready=1
Time=125000  | done_out=1 | pslverr=0 | prdata=00000000 | pready=1
done_out fired — ECG sampling window complete
Time=145000  | done_out=1 | pslverr=0 | prdata=00000001 | pready=1
stat_reg = 1
Time=175000  | done_out=1 | pslverr=1 | prdata=00000001 | pready=1
pslverr = 0
$finish called at 195000
```

### Verification Checklist

| Test Case                         | Expected     | Result  |
| --------------------------------- | ------------ | ------- |
| Reset — all signals zero          | All 0        | ✅ PASS |
| Write load value 5 to 0x00        | load_reg = 5 | ✅ PASS |
| Write 1 to 0x04 — start timer     | ctrl_reg = 1 | ✅ PASS |
| Timer counts down and fires       | done_out = 1 | ✅ PASS |
| Read 0x08 — status register       | prdata = 1   | ✅ PASS |
| Write to invalid address 0xFF     | pslverr = 1  | ✅ PASS |
| PSLVERR auto-clears after 1 cycle | pslverr = 0  | ✅ PASS |

---

## Waveform — GTKWave

![Image Alt](https://raw.githubusercontent.com/prashik-vlsi/100_Days_of_VLSI/0284b6b5900162d6200f83c32c78902b2ed23dff/Wavefrom_images/Day28_waveform.png)

## Synthesized Image

![Image Alt](https://raw.githubusercontent.com/prashik-vlsi/100_Days_of_VLSI/0284b6b5900162d6200f83c32c78902b2ed23dff/Wavefrom_images/synthesised28.png)

### Key Waveform Observations

| Signal        | Behavior                                     |
| ------------- | -------------------------------------------- |
| `tb_rst_n`    | Low then high — clean reset                  |
| `tb_paddr`    | 0x00 → 0x04 → 0x08 → 0xFF — all transactions |
| `tb_pwdata`   | 0x05 then 0x01 — load and start              |
| `tb_pready`   | Goes high after reset — slave ready          |
| `tb_done_out` | Fires at ~125ns — timer complete             |
| `tb_prdata`   | Returns 0x00000001 — stat_reg confirmed      |
| `tb_pslverr`  | Single pulse on 0xFF access — error caught   |

---

## Yosys Synthesis Report

### Script — `abp_peripheral.ys`

```
read_verilog abp_peripheral.v
hierarchy -top apb_timer_peripheral
synth -top apb_timer_peripheral
dfflibmap -liberty ./stdcells.lib
abc -liberty ./stdcells.lib
clean
write_verilog apb_timer_netlist.v
stat
```

### Synthesis Statistics

```
=== apb_timer_peripheral ===

   Number of wires      :   240
   Number of wire bits  :   426
   Number of cells      :   356

   $_ANDNOT_            :    93   ← address decode
   $_AND_               :    11
   $_DFFE_PN0P_         :    98   ← flip flops
   $_DFF_PN0_           :     2
   $_MUX_               :    34   ← data mux
   $_NAND_              :     4
   $_NOR_               :    24
   $_NOT_               :     7
   $_ORNOT_             :    11
   $_OR_                :    41
   $_XNOR_              :     1
   $_XOR_               :    30   ← timer arithmetic

   Problems found       :     0   ✅
```

### Flip Flop Breakdown

| Register    | Width  | Cells  |
| ----------- | ------ | ------ |
| load_reg    | 32-bit | 32     |
| timer_count | 32-bit | 32     |
| prdata      | 32-bit | 32     |
| ctrl_reg    | 1-bit  | 1      |
| stat_reg    | 1-bit  | 1      |
| done_out    | 1-bit  | 1      |
| **Total**   |        | **99** |

---

## Key Concepts Learned

### 1. APB Register Map Design

Every APB peripheral maps registers to addresses. Processor accesses hardware only through these addresses. Internal registers are not directly accessible.

### 2. PSLVERR Error Response

PSLVERR is the APB error flag. Slave asserts it for one cycle when master accesses an invalid address. Master must check PSLVERR after every transaction in safety-critical systems like VitalGuard.

### 3. PREADY Wait States

PREADY=0 freezes the master. Used when slave needs extra cycles to prepare data. Slow peripherals like Flash memory use multiple wait states.

### 4. Hardware Status Register

Status registers are written by hardware — not the processor. The timer hardware detects count=0 and sets stat_reg automatically. Processor only reads it.

### 5. Multiple Driver Rule

Each signal must be driven from exactly one always block. Two always blocks driving the same signal causes X in simulation and fails synthesis.

---

## Interview Questions

**Q: What is PSLVERR in APB? When does a slave assert it?**
A: PSLVERR is the APB slave error response signal. Slave asserts it for one clock cycle when master accesses an invalid address or performs an illegal operation — such as writing to a read-only register. Master must check PSLVERR after enable phase and retry or abort the transaction.

**Q: What is PREADY? How does it implement wait states?**
A: PREADY is the slave ready signal. When PREADY=0 the master is frozen and cannot proceed. Slave holds PREADY low for as many cycles as needed to prepare data, then asserts it high to complete the transaction. This implements variable wait states without changing the master logic.

**Q: Who sets the status register in an APB timer peripheral?**
A: The hardware sets the status register — not the processor. When the timer countdown reaches zero, the internal logic asserts stat_reg automatically. The processor only reads it to check if the timer has completed.

**Q: Why is the timer counter the same width as the load register?**
A: Because the counter must be able to hold any value loaded into the load register. If load_reg is 32-bit, timer_count must also be 32-bit. A narrower counter would overflow and give incorrect timing — critical failure in a medical device like VitalGuard.

---

## File Structure

```
day_28_apb_peripheral/
├── abp_peripheral.v          — RTL — APB Timer Peripheral
├── abp_peripheral_tb.v       — Testbench — all scenarios
├── abp_peripheral.ys         — Yosys synthesis script
├── apb_timer_netlist.v       — Generated gate netlist
├── apb_timer_clean.dot       — Schematic dot file
├── apb_timer_clean.png       — Schematic PNG
├── peripheral.vcd            — Simulation waveform
└── README.md                 — This file
```

---

## Capstone Connection

| Project    | Module Used          | Purpose                          |
| ---------- | -------------------- | -------------------------------- |
| VitalGuard | APB Timer Peripheral | ECG sampling window — 10ms timer |
| ShieldHer  | APB Timer Peripheral | Watchdog timer — distress detect |

---

## Progress

```
Day 28 / 100 complete
VitalGuard SoC — 45% blocks complete
Tapeout — 65 days remaining
```

---

_VitalGuard SoC — Cardiac monitoring for rural India_
_Built with iverilog · GTKWave · Yosys · GVim · Ubuntu 22.04_
