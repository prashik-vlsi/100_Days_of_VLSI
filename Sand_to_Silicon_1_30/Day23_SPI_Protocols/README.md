# Day 23 — SPI Master (Mode 0 — Full Duplex 8-bit Transfer)

## Topic

SPI Master — CPOL/CPHA Mode Configuration, Shift Register Ring Architecture,
SCLK Generation via Clock Divider, Full Duplex MOSI/MISO Transfer,
3-State FSM Control, Chip Select Management, and Xschem Block Diagram Capture.

---

## Theory

The Serial Peripheral Interface (SPI) is a synchronous serial communication
protocol developed by Motorola. It enables full duplex communication between
a Master device and one or more Slave devices over four dedicated signal lines.
Unlike UART, SPI is synchronous — the Master generates the clock and all
data transfer is locked to it.

In the ShieldHer Women Safety SoC, the SPI Master interfaces with the NEO-6M
GPS module to retrieve location coordinates on distress detection. In the
NeuralEdge Edge AI Accelerator, the SPI Master handles sensor data input to
the MAC unit inference pipeline.

A complete SPI Master consists of three major blocks:

### 1. Clock Divider (SCLK Generator)

The system clock is divided down to generate SCLK. A 4-bit counter `sclk_cnt`
increments every system clock cycle. When it reaches the divider threshold,
SCLK toggles and the counter resets. This produces a clean, symmetric SCLK
with configurable frequency.

### 2. Shift Register Engine

An internal N-bit shift register holds the data being transmitted. On each
falling edge of SCLK, the MSB is driven onto MOSI and the register shifts
left by one position. On each rising edge of SCLK, the incoming MISO bit
is sampled into the LSB of the shift register. This forms a closed ring
between Master and Slave — enabling simultaneous bidirectional transfer.

### 3. Control FSM

A 3-state synchronous FSM manages the complete transfer lifecycle — from
Chip Select assertion to done flag generation.

---

## Key Concepts

### SPI Signal Definitions

| Signal | Full Name           | Direction      | Purpose                   |
| ------ | ------------------- | -------------- | ------------------------- |
| SCLK   | Serial Clock        | Master → Slave | Master drives clock       |
| MOSI   | Master Out Slave In | Master → Slave | Data from Master to Slave |
| MISO   | Master In Slave Out | Slave → Master | Data from Slave to Master |
| CS_n   | Chip Select         | Master → Slave | Active LOW slave select   |

### CPOL and CPHA — 4 SPI Modes

| Mode | CPOL | CPHA | Clock Idle | Sample Edge          |
| ---- | ---- | ---- | ---------- | -------------------- |
| 0    | 0    | 0    | LOW        | Rising ← This design |
| 1    | 0    | 1    | LOW        | Falling              |
| 2    | 1    | 0    | HIGH       | Falling              |
| 3    | 1    | 1    | HIGH       | Rising               |

### Why Drive and Sample on Opposite Edges

Driving MOSI on the falling edge and sampling MISO on the rising edge
provides a half clock cycle of settling time. This satisfies the setup
time (t_su) and hold time (t_h) requirements of the receiving flip-flop
and prevents metastability caused by sampling a transitioning signal.

### Full Duplex Shift Register Ring

Master shift_reg ──► MOSI ──► Slave shift_reg

Master shift_reg ◄── MISO ◄── Slave shift_reg
On every SCLK edge, both registers shift simultaneously. One byte leaves
the Master and one byte enters the Master in the same 8-clock transaction.

---

## UART Frame Format Equivalent — SPI Transaction Structure

| Phase     | Action                                      |
| --------- | ------------------------------------------- |
| IDLE      | CS_n HIGH, SCLK idle LOW, waiting for start |
| CS Assert | CS_n goes LOW, shift_reg loaded             |
| Bit 7     | MSB driven on MOSI, MISO sampled            |
| Bit 6–1   | Remaining bits shifted out and in           |
| Bit 0     | LSB transferred                             |
| DONE      | done asserted, CS_n deasserted HIGH         |

---

## Functional Blocks

### Clock Divider

**Purpose:** Generate SCLK from system clock  
**Implementation:** 4-bit counter `sclk_cnt`, toggles SCLK at count 4  
**Result:** SCLK period = 8 × system clock period

### Shift Register

**Purpose:** Serialize TX data and deserialize RX data  
**TX Implementation:** `MOSI <= shift_reg[WIDTH-1]; shift_reg <= shift_reg << 1;`  
**RX Implementation:** `shift_reg[0] <= MISO;`

### Chip Select Controller

**Purpose:** Gate the SPI bus and select the target slave  
**Assert:** `CS_n <= 1'b0` on IDLE → TRANSFER transition  
**Deassert:** `CS_n <= 1'b1` in DONE state

### Control FSM

**Purpose:** Sequence the complete SPI transaction
start=1
IDLE ──────────► TRANSFER ──────────► DONE

▲ bit_cnt==WIDTH-1 │

└─────────────────────────────────────┘

**IDLE State**

- Waits for `start` assertion
- Loads `data_in` into `shift_reg`
- Resets `bit_cnt` and `sclk_cnt`
- Asserts `CS_n` LOW
- Clears `done` flag

**TRANSFER State**

- Increments `sclk_cnt` every clock
- Toggles SCLK when `sclk_cnt == 4'b0100`
- On SCLK falling edge: drives MOSI, shifts left, increments `bit_cnt`
- On SCLK rising edge: samples MISO into `shift_reg[0]`
- Transitions to DONE when `bit_cnt == WIDTH-1`

**DONE State**

- Asserts `done` HIGH for one cycle
- Latches `shift_reg` into `data_out`
- Deasserts `CS_n` HIGH
- Drives SCLK LOW
- Returns to IDLE

---

## Project Files

### spi_master.v

SPI Master RTL implementation containing:

- Parametric WIDTH support
- 3-state synchronous FSM
- SCLK clock divider
- Full duplex shift register engine
- Active low synchronous reset
- done flag and data_out latch

### spi_master_tb.v

Self-checking testbench that verifies:

- Power-on reset behavior
- CS_n assertion on start
- MOSI pattern correctness for 0xA5
- SCLK toggle timing
- done flag assertion
- data_out latch correctness

### spi_master.sch

Xschem block diagram schematic — first Xschem schematic drawn in this series.
Contains all ports labeled with correct directions:

- Inputs: `clk` `rst_n` `start` `data_in[7:0]` `MISO`
- Outputs: `SCLK` `MOSI` `CS_n` `data_out[7:0]` `done`
- Power: `VDD` `GND`

### tb_spi_master.vcd

Waveform database used for GTKWave analysis.

---

## Verified Conditions

- ✔ SCLK generation at correct frequency
- ✔ CS_n assertion on transfer start
- ✔ MSB-first MOSI transmission verified for 0xA5
- ✔ MISO sampling on rising edge
- ✔ bit_cnt boundary at WIDTH-1
- ✔ done flag single-cycle assertion
- ✔ data_out latch in DONE state
- ✔ Active low reset initializes all outputs
- ✔ Unknown x state resolved after reset

---

## Simulation Results

**Terminal Result**
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/Day23%20_terminal.png?raw=true)

**waveform result**

![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/Day23%20gtk.png?raw=true)

**first Xschem result**

![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/Xschem.png?raw=true)

### Test Vector

data_in = 8'hA5 = 10100101

MISO = 8'h00 (tied low)

### Verified Waveform Timestamps

| Event               | Timestamp |
| ------------------- | --------- |
| Reset released      | 40 ns     |
| CS_n asserted LOW   | 70 ns     |
| SCLK first toggle   | 170 ns    |
| MOSI pattern start  | 270 ns    |
| done asserted HIGH  | 1590 ns   |
| Total transfer time | 1520 ns   |

### MOSI Pattern Verified

Expected : 1 0 1 0 0 1 0 1

Observed : 1 0 1 0 0 1 0 1 ✓

### Transfer Time Calculation

8 SCLK cycles × 8 system clocks × 20 ns = 1280 ns active transfer

FSM overhead = 1520 ns total

---

## How to Simulate

```bash
# Compile
iverilog -o spi_master.out spi_master.v spi_master_tb.v

# Run simulation
vvp spi_master.out

# View waveform
gtkwave tb_spi_master.vcd
```

Add signals in GTKWave in this order:
clk → rst_n → start → CS_n → SCLK → MOSI → MISO → done → data_out

---

## Key Learnings

### Synchronous Output Delay

All FSM outputs update one clock cycle after the input condition is met
because the always block is triggered by posedge clk. This is called a
registered output — outputs can only change on a clock edge, never
between edges.

### x State at Power-On

Output registers show x at simulation time 0 because flip-flops have no
defined power-on state in real silicon. The synchronous reset resolves
all x states within one clock cycle of rst_n assertion.

### Metastability in SPI

Driving and sampling on opposite clock edges provides a half-period
settling window. This satisfies setup and hold time constraints and
prevents the race condition that would occur if both actions happened
on the same edge.

### Xschem Block Diagram

Xschem is a schematic capture frontend used in open-source IC design flows.
It generates netlists for analog simulation via ngspice. For digital RTL
blocks, it serves as architecture documentation showing port directions,
power rails, and block hierarchy.

---

## Capstone Connections

### ShieldHer — Women Safety Alert SoC

- NEO-6M GPS module communicates over SPI Mode 0
- SPI Master reads GPS coordinates on distress trigger
- Coordinates forwarded to GSM module for SOS alert
- Timing critical — every microsecond matters in an emergency

### NeuralEdge — Edge AI Inference Accelerator

- SPI Master handles external sensor data input
- data_in feeds directly into MAC unit pipeline
- done flag triggers inference cycle start

---

## Interview Question Practiced

**Company: Qualcomm — Design Verification Engineer**

> SPI Master waveform shows correct SCLK and CS_n but slave latches
> wrong data. What are the first 3 things you check?

1. **CPOL/CPHA Mode Mismatch** — Verify master and slave datasheet mode
   configuration match exactly. Wrong mode causes sampling on wrong edge.

2. **Setup and Hold Time Violations** — Measure MOSI to SCLK edge timing.
   If MOSI changes too close to the sampling edge, the slave flip-flop
   enters metastability and latches garbage data.

3. **Bit Order Mismatch** — Confirm MSB vs LSB first configuration matches
   slave expectation. Reversed bit order produces mirror-image data errors.

---

## Verification Environment

Simulator: Icarus Verilog (iverilog)  
Waveform Viewer: GTKWave  
Schematic Tool: Xschem

## Status

✔ RTL Implemented  
✔ Testbench Verified  
✔ Waveforms Analyzed  
✔ Xschem Schematic Drawn  
✔ Capstone Connections Mapped

---

_Part of the 100 Days of VLSI Series_  
_Prashik Wankhede — github.com/prashik-vlsi/100_Days_of_VLSI_
