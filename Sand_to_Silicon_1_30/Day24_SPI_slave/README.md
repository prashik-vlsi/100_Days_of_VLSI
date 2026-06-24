# Day 24 — SPI Slave (Mode 0 — Full Duplex 8-bit Receive)

## Topic

SPI Slave — CS Falling Edge Detection, MOSI Shift-In, MISO Shift-Out,
Full Duplex Operation, SCLK Edge Sampling via System Clock,
rx_done Pulse Generation, and Master-Slave Loopback Verification.

---

## Theory

The SPI Slave is the receiving end of the SPI bus. Unlike the Master, the
Slave does not generate SCLK or CS — it only responds to them. The Slave
wakes up when CS goes LOW, loads its tx_data into a shift register, and
begins simultaneous receive and transmit on each SCLK rising edge.

In the ShieldHer Women Safety SoC, the NEO-6M GPS module operates as an
SPI Slave. The MCU (Master) pulls CS LOW and clocks out a read command
while the GPS module shifts back location coordinates on MISO.
In the NeuralEdge Edge AI Accelerator, external sensor peripherals act
as SPI Slaves feeding data into the MAC unit inference pipeline.

---

## Key Concepts

### SPI Signal Directions (Slave Perspective)

| Signal | Direction           | Purpose                   |
| ------ | ------------------- | ------------------------- |
| CS     | Input (from Master) | Active LOW — slave select |
| SCLK   | Input (from Master) | Master-generated clock    |
| MOSI   | Input (from Master) | Data arriving at slave    |
| MISO   | Output (to Master)  | Data leaving slave        |

### Why Slave Cannot Use SCLK as Clock

SCLK arrives on a GPIO pin — not on the dedicated global clock network.
Using SCLK directly as a flip-flop clock causes two problems:

1. **Clock Skew** — GPIO routing introduces large, unpredictable delays
2. **Metastability** — Logic clocked by sys_clk that interacts with SCLK
   domain violates setup/hold times

**Solution:** Sample SCLK using sys_clk and detect edges using a
two-register synchronizer pattern:

```
sclk_prev <= sclk;
sclk_rising = (~sclk_prev) & sclk;
```

### CS Falling Edge Detection

```
cs_prev <= cs;
cs_falling = cs_prev & (~cs);   // 1→0 transition
```

CS falling edge triggers:

- Load tx_data into tx_shift register
- Reset bit_cnt to 0

### Off-By-One Bug — Critical Learning

**Wrong:** `rx_data <= shift_reg` when `bit_cnt == 7`

When `bit_cnt == 7`, the last MOSI bit is being shifted in the same
clock cycle. Due to non-blocking assignment semantics, `shift_reg`
has not yet captured the last bit. This causes a right-shift-by-one
error in received data.

**Correct:** `rx_data <= {shift_reg[6:0], mosi}` when `bit_cnt == 7`

This manually includes the last MOSI bit in the latched result,
producing the correct 8-bit received byte.

---

## Functional Blocks

### CS Edge Detector

**Purpose:** Detect transaction start  
**Implementation:** `assign cs_falling = cs_prev & (~cs);`  
**Action:** Load tx_shift, reset bit_cnt

### SCLK Edge Detector

**Purpose:** Sample MOSI and drive MISO on correct edge  
**Implementation:** `assign sclk_rising = (~sclk_prev) & sclk;`  
**Action:** Shift in MOSI, shift out MISO on rising edge

### RX Shift Register

**Purpose:** Deserialize 8 MOSI bits into a byte  
**Implementation:** `shift_reg <= {shift_reg[6:0], mosi};`  
**Direction:** MSB first, bit arrives at LSB each cycle

### TX Shift Register

**Purpose:** Serialize tx_data out on MISO  
**Implementation:** `miso <= tx_shift[7]; tx_shift <= {tx_shift[6:0], 1'b0};`  
**Direction:** MSB first, zero-padded from LSB

### rx_done Flag

**Purpose:** Signal that a complete byte has been received  
**Assert:** HIGH for one cycle when bit_cnt == 7  
**Clear:** LOW every other cycle  
**Action:** rx_data latched simultaneously with rx_done assertion

---

## RTL Architecture

```
          ┌─────────────────────────────────────┐
clk  ────►│                                     │
rst  ────►│         SPI_SLAVE                   │
cs   ────►│  cs_falling detector                ├──► miso
sclk ────►│  sclk_rising detector               ├──► rx_data[7:0]
mosi ────►│  RX shift_reg                       ├──► rx_done
          │  TX tx_shift                        │
tx_data──►│  3-bit bit_cnt                      │
          └─────────────────────────────────────┘
```

---

## SPI Transaction Timing (Mode 0)

```
CS    ─────┐                               ┌─────
           └───────────────────────────────┘

SCLK       ┌──┐  ┌──┐  ┌──┐  ┌──┐  ┌──┐
      ──────┘  └──┘  └──┘  └──┘  └──┘  └──────
           B7   B6   B5   B4  ...  B0

MOSI  ─────[D7][D6][D5][D4][D3][D2][D1][D0]───

MISO  ─────[Q7][Q6][Q5][Q4][Q3][Q2][Q1][Q0]───

rx_done                                    ┌─┐
      ─────────────────────────────────────┘ └─
```

---

## Project Files

### spi_slave.v

SPI Slave RTL implementation containing:

- Parametric WIDTH support (default 8)
- CS falling edge detection
- SCLK rising edge detection via sys_clk sampling
- Full duplex RX shift register and TX shift register
- 3-bit bit counter (0 to 7)
- rx_done single-cycle pulse
- Off-by-one corrected rx_data latch

### spi_slave_tb.v

Testbench verifying:

- Power-on reset behavior
- CS assertion and tx_data load
- MOSI shift-in for 0x3C and 0xF0
- rx_done pulse assertion
- rx_data correctness verified against sent data

### spi_slave.sch

Xschem block diagram showing:

- Inputs: clk, rst, cs, sclk, mosi, tx_data[7:0]
- Outputs: miso, rx_data[7:0], rx_done

### spi_slave_tb.vcd

Waveform database for GTKWave analysis.

---

## Verified Conditions

- ✔ CS falling edge detection correct
- ✔ tx_data loaded into tx_shift on CS falling edge
- ✔ MOSI shift-in MSB first verified
- ✔ MISO shift-out MSB first verified
- ✔ bit_cnt increments 0→7 per transaction
- ✔ rx_done single-cycle pulse asserted
- ✔ rx_data correct — off-by-one bug found and fixed
- ✔ Transaction 1: sent 0x3C → received 0x3C ✓
- ✔ Transaction 2: sent 0xF0 → received 0xF0 ✓

---

## Simulation Results

### Test Vectors

| Transaction | data sent | tx_data (slave) | rx_data received |
| ----------- | --------- | --------------- | ---------------- |
| 1           | 0x3C      | 0xA5            | 0x3C ✓           |
| 2           | 0xF0      | 0x5A            | 0xF0 ✓           |

**Terminal output**
![Image Alt](https://raw.githubusercontent.com/prashik-vlsi/100_Days_of_VLSI/67a3be83094bf68945107e12eb2758d47974de9b/Wavefrom_images/24terminal.png)

**waveform output**
![Image Alt](https://raw.githubusercontent.com/prashik-vlsi/100_Days_of_VLSI/67a3be83094bf68945107e12eb2758d47974de9b/Wavefrom_images/24wvefrom.png)

## Key Learnings

### Non-Blocking Assignment Timing

In Verilog, all non-blocking assignments (`<=`) in one always block
update simultaneously at the end of the time step. When `bit_cnt == 7`,
writing `rx_data <= shift_reg` captures the old value of shift_reg
before the last MOSI bit is included. The fix is to manually construct
the final byte: `rx_data <= {shift_reg[6:0], mosi}`.

### CDC — Why SCLK Cannot Clock Flip-Flops

SCLK is an asynchronous external signal. Using it directly as a clock
violates synthesis constraints and causes clock domain crossing issues.
The correct approach is to synchronize SCLK into the sys_clk domain
using edge detection registers.

### Full Duplex Simultaneity

On every SCLK rising edge, the slave both shifts in a MOSI bit AND
shifts out a MISO bit. Both operations happen in the same always block
in the same clock cycle — true full duplex operation.

---

## Capstone Connections

### ShieldHer — Women Safety Alert SoC

- NEO-6M GPS module is an SPI Slave
- This SPI Slave RTL models the GPS receiver interface
- On distress detection, Master reads GPS coordinates from Slave
- rx_done triggers coordinate parsing for GSM SOS transmission

### NeuralEdge — Edge AI Inference Accelerator

- External sensor peripherals act as SPI Slaves
- rx_data feeds directly into MAC unit input pipeline
- rx_done triggers start of inference cycle

---

---

## Verification Environment

Simulator : Icarus Verilog (iverilog)  
Waveform : GTKWave  
Schematic : Xschem V3.4.4  
OS : Ubuntu 22.04

---

## Status

✔ RTL Implemented  
✔ Testbench Written  
✔ Simulation Verified  
✔ Waveform Analyzed  
✔ Off-By-One Bug Found and Fixed  
✔ Xschem Block Diagram Drawn  
✔ Capstone Connections Mapped

---

_Part of the 100 Days of VLSI Series_  
_Prashik Wankhede — github.com/prashik-vlsi/100_Days_of_VLSI_
