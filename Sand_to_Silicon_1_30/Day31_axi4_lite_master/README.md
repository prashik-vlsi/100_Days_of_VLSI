# Day 31 — AXI4-Lite Write Channel
## 100 Days of VLSI — NeuralEdge SoC Project

**Engineer:** Prashik Wankhede
**GitHub:** github.com/prashik-vlsi/100_Days_of_VLSI
**Tools:** iverilog · GTKWave · GVim · Yosys · Xschem · Ubuntu 22.04
**Date:** July 2025

---

## NeuralEdge SoC Context

NeuralEdge is an edge AI inference accelerator SoC
designed to run neural network classification
entirely on chip — no cloud, no internet required.

The AXI4-Lite Write Channel built today is the
control plane interface of NeuralEdge. The host
processor writes neural network weights and
inference commands to NeuralEdge through this
exact channel. An incorrect write transaction
means wrong weights loaded — wrong inference
result — wrong classification output.

This module is mission-critical.

---

## Module Overview

| Parameter | Value |
|-----------|-------|
| Module | axi4_lite_master_write + axi4_lite_slave_write |
| Protocol | ARM AMBA AXI4-Lite |
| Data Width | 32-bit |
| Addr Width | 32-bit |
| Channels | 3 — AW + W + B |
| Handshake | VALID + READY on each channel |
| Error Handle | BRESP — OKAY SLVERR DECERR |
| Byte Enable | WSTRB — 4-bit byte lane select |
| Synthesis | Yosys — [fill cell count] cells |
| Simulation | iverilog + GTKWave |

---

## AXI4-Lite Write Channels

```
┌─────────────────────────────────────────────────┐
│           AXI4-LITE WRITE TRANSACTION           │
│                                                 │
│  MASTER                          SLAVE          │
│                                                 │
│  ──── Write Address Channel (AW) ────           │
│  AWVALID ────────────────────────►              │
│           ◄──────────────────── AWREADY         │
│  AWADDR  ────────────────────────►              │
│                                                 │
│  ──── Write Data Channel (W) ────               │
│  WVALID  ────────────────────────►              │
│           ◄──────────────────── WREADY          │
│  WDATA   ────────────────────────►              │
│  WSTRB   ────────────────────────►              │
│                                                 │
│  ──── Write Response Channel (B) ────           │
│           ◄──────────────────── BVALID          │
│  BREADY  ────────────────────────►              │
│           ◄──────────────────── BRESP           │
│                                                 │
│  Transfer completes when VALID + READY = 1      │
│  on each channel independently                  │
└─────────────────────────────────────────────────┘
```

---

## VALID READY Handshake — All 4 Cases

```
VALID  READY  Result
─────  ─────  ──────────────────────────────
  0      0    No transfer — both waiting
  1      0    Master ready — slave not ready
              Master holds signals stable
  0      1    Slave ready — master not ready
              Slave waits
  1      1    TRANSFER HAPPENS this cycle
              Both ready — data moves
```

---

## Port List

### AXI4-Lite Master Write

```verilog
module axi4_lite_master_write (
    // Clock and Reset
    input  wire        aclk,
    input  wire        aresetn,

    // Write Address Channel — AW
    output reg  [31:0] awaddr,
    output reg         awvalid,
    input  wire        awready,

    // Write Data Channel — W
    output reg  [31:0] wdata,
    output reg  [ 3:0] wstrb,
    output reg         wvalid,
    input  wire        wready,

    // Write Response Channel — B
    input  wire [ 1:0] bresp,
    input  wire        bvalid,
    output reg         bready
);
```

### AXI4-Lite Slave Write

```verilog
module axi4_lite_slave_write (
    // Clock and Reset
    input  wire        aclk,
    input  wire        aresetn,

    // Write Address Channel — AW
    input  wire [31:0] awaddr,
    input  wire        awvalid,
    output reg         awready,

    // Write Data Channel — W
    input  wire [31:0] wdata,
    input  wire [ 3:0] wstrb,
    input  wire        wvalid,
    output reg         wready,

    // Write Response Channel — B
    output reg  [ 1:0] bresp,
    output reg         bvalid,
    input  wire        bready
);
```

---

## BRESP Response Codes

| Code | Name | Description |
|------|------|-------------|
| 2'b00 | OKAY | Transaction successful |
| 2'b01 | EXOKAY | Exclusive access okay |
| 2'b10 | SLVERR | Slave error — bad address |
| 2'b11 | DECERR | Decode error — no slave |

---

## WSTRB Byte Enable Encoding

| WSTRB | Bytes Written | Use Case |
|-------|--------------|----------|
| 4'b1111 | All 4 bytes | Full word write |
| 4'b0001 | Byte 0 only | Byte write LSB |
| 4'b0011 | Bytes 0-1 | Halfword write |
| 4'b1100 | Bytes 2-3 | Upper halfword |
| 4'b0000 | Nothing | No write |

---

## Architecture

```
┌──────────────────────────────────────────────────┐
│          AXI4-LITE WRITE SYSTEM                  │
│                                                  │
│  ┌─────────────────┐    ┌────────────────────┐   │
│  │   AXI4 Master   │    │   AXI4 Slave       │   │
│  │                 │    │                    │   │
│  │  ┌───────────┐  │    │  ┌──────────────┐  │   │
│  │  │ AW Channel│──┼────┼─►│ Addr Capture │  │   │
│  │  │ AWVALID   │  │    │  │ AWREADY gen  │  │   │
│  │  │ AWREADY   │  │    │  └──────────────┘  │   │
│  │  │ AWADDR    │  │    │                    │   │
│  │  └───────────┘  │    │  ┌──────────────┐  │   │
│  │                 │    │  │ Data Capture │  │   │
│  │  ┌───────────┐  │    │  │ WREADY gen   │  │   │
│  │  │ W Channel │──┼────┼─►│ WSTRB decode │  │   │
│  │  │ WVALID    │  │    │  │ Memory write │  │   │
│  │  │ WREADY    │  │    │  └──────────────┘  │   │
│  │  │ WDATA     │  │    │                    │   │
│  │  │ WSTRB     │  │    │  ┌──────────────┐  │   │
│  │  └───────────┘  │    │  │ BRESP gen    │  │   │
│  │                 │    │  │ BVALID assert│  │   │
│  │  ┌───────────┐  │    │  │ OKAY/SLVERR  │  │   │
│  │  │ B Channel │◄─┼────┼──│              │  │   │
│  │  │ BVALID    │  │    │  └──────────────┘  │   │
│  │  │ BREADY    │  │    │                    │   │
│  │  │ BRESP     │  │    └────────────────────┘   │
│  │  └───────────┘  │                             │
│  └─────────────────┘                             │
└──────────────────────────────────────────────────┘
```

---

## AXI4-Lite vs AHB-Lite vs APB

| Feature | APB | AHB-Lite | AXI4-Lite |
|---------|-----|----------|-----------|
| Channels | 1 | 1 | 5 independent |
| Pipeline | No | Yes | Yes |
| Burst | No | Yes | No (Lite) |
| Handshake | PSEL+PENABLE | HTRANS+HREADY | VALID+READY |
| Bandwidth | Low | Medium | High |
| Complexity | Simple | Moderate | Complex |
| Use case | Timers GPIO | Memory DMA | SoC fabric |
| Error | PSLVERR | HRESP | BRESP |
| VitalGuard | Timer config | — | — |
| NeuralEdge | — | Weight fetch | Control plane |

---

## Simulation Results

### Test Cases

| Test | Description | Result |
|------|-------------|--------|
| 1 | Normal write — slave ready immediately | ✅ PASS |
| 2 | Slave not ready — AWREADY low — master waits | ✅ PASS |
| 3 | Write with WSTRB byte enable 4'b0001 | ✅ PASS |
| 4 | SLVERR response on invalid address | ✅ PASS |
| 5 | Back to back writes — no gaps | ✅ PASS |


![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/DAy31_terminal.png?raw=true)

### Key Waveform Observations

| Signal | Behavior |
|--------|----------|
| AWVALID + AWREADY | Transfer on cycle both high |
| WVALID + WREADY | Independent of AW channel |
| WSTRB | 4'b1111 full word — 4'b0001 byte |
| BVALID | Asserted after write complete |
| BRESP | 2'b00 OKAY success — 2'b10 SLVERR error |



![Image  Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/Day31_waveform.png?raw=true)

---

## Yosys Synthesis Report


### Synthesis Statistics

```
=== axi4_lite_slave_write ===

   Total cells          : [fill from output]
   DFF count            : [fill from output]
   Combinational        : [fill from output]

   Compared to APB Day 28:
   APB  — 356 cells  98 DFF
   AXI  — [X] cells  [X] DFF
   More cells because:
   3 independent state machines
   One per channel AW W B
   Each needs own VALID READY tracking
```

---

##  synthesis  image
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/axi4_master_schematics.png?raw=true)

## Key Concepts Learned

### 1. Independent Channel Operation
AW and W channels are completely independent.
Master can send address before data is ready.
Slave can accept data before it has the address.
This independence allows higher throughput
compared to APB and AHB.

### 2. VALID READY Handshake Rule
Transfer happens only when VALID AND READY
are both high on the same clock edge.
VALID must never be deasserted once asserted
unless a transfer has completed.
READY can be asserted or deasserted any time.

### 3. WSTRB Byte Enable
WSTRB controls which bytes of WDATA are
actually written to memory.
bit[0] controls byte[0] — bits 7:0.
bit[3] controls byte[3] — bits 31:24.
Critical for partial word writes in
register mapped peripherals.

### 4. BRESP Error Handling
Slave must always send a response.
Master must always wait for response
before issuing next write transaction.
SLVERR tells master the write failed —
master must decide whether to retry.

### 5. AXI Ordering Rule
In AXI4-Lite, all transactions are
in order. No out-of-order support.
This simplifies the design significantly
compared to full AXI4.

---

## Interview Questions

**Q: Explain AXI4-Lite write transaction
from start to finish.**
*Asked at: Qualcomm, Nvidia*

Master asserts AWVALID with AWADDR on
write address channel. Slave responds
with AWREADY when it can accept the address.
Simultaneously or after, master asserts
WVALID with WDATA and WSTRB on write
data channel. Slave responds with WREADY.
After both address and data are received,
slave sends response on B channel with
BVALID and BRESP. Master asserts BREADY
to accept the response. Transaction complete.

---

**Q: What is WSTRB and why is it needed?**
*Asked at: Intel, AMD*

WSTRB is a 4-bit byte strobe signal where
each bit controls whether the corresponding
byte lane of WDATA is written to memory.
It is needed because processors often need
to update individual bytes within a 32-bit
word without disturbing other bytes —
for example updating a single register field
or writing a byte to a char array.

---

**Q: Why does AXI4-Lite have 5 channels
instead of APB's single bus?**
*Asked at: Qualcomm, Tessolve*

AXI4-Lite separates read and write paths
into independent channels so both can
operate simultaneously. Write uses AW W B
channels and read uses AR R channels.
This decoupling allows much higher
throughput than APB where read and write
share the same bus and cannot overlap.
The independence also allows the address
to be transferred before data is ready,
removing unnecessary stalls.

---

## Key Learning — From My Mistakes

```
Mistake 1:
  Deasserted AWVALID before
  transfer completed.
  Master violated AXI protocol.

  Fix:
  Once AWVALID is asserted it must
  stay high until AWREADY is seen.
  Master cannot take back a request.

  Lesson:
  VALID is a commitment.
  Once you say you have data —
  you must hold it until accepted.

Mistake 2:
  Sent BRESP before both AW and W
  channels completed.
  Slave responded too early.

  Fix:
  Slave must track both channels
  independently and only generate
  BRESP after both address AND
  data have been received.

  Lesson:
  Three separate state machines.
  One per channel.
  Never combine them.
```

---

## File Structure

```
Day31_AXI4_Lite_Write/
├── axi4_lite_master_write.v    — Master RTL
├── axi4_lite_slave_write.v     — Slave RTL
├── axi4_lite_write_tb.v        — Testbench
├── axi4_lite_write.ys          — Yosys script
├── axi4_lite_write_netlist.v   — Gate netlist
├── axi4_lite_write.sch         — Xschem schematic
├── waveform.vcd                — GTKWave dump
└── README.md                   — This file
```

---

## Capstone Connection

| Project | Module Used | Purpose |
|---------|-------------|---------|
| NeuralEdge | AXI4-Lite Write | Host writes weights and commands |
| VitalGuard | AXI4-Lite Write | Future — data plane expansion |

```
┌─────────────────────────────────────────┐
│  NeuralEdge — Write Path                │
│                                         │
│  Host Processor                         │
│       │                                 │
│       │ AXI4-Lite Write                 │
│       ▼                                 │
│  ┌────────────┐                         │
│  │ AXI Slave  │                         │
│  │ Write Chan │                         │
│  └─────┬──────┘                         │
│        │                                │
│        ▼                                │
│  ┌────────────┐                         │
│  │   Weight   │                         │
│  │   Memory   │                         │
│  │  (SPRAM)   │                         │
│  └─────┬──────┘                         │
│        │                                │
│        ▼                                │
│  ┌────────────┐                         │
│  │  MAC Unit  │                         │
│  │ Inference  │                         │
│  └────────────┘                         │
└─────────────────────────────────────────┘
```

---

## Progress

```
Day 31 / 100 complete
NeuralEdge SoC — 62% blocks complete
Tapeout — 52 days remaining

Protocol stack complete so far:
  UART  ✅ Day 21-22
  SPI   ✅ Day 23-24
  I2C   ✅ Day 25-26
  APB   ✅ Day 27-28
  AHB   ✅ Day 29-30
  AXI Write ✅ Day 31
  AXI Read  🔄 Day 32
```

---

## GitHub Commit

```bash
git add .
git commit -m "Day 31: AXI4-Lite Write Channel —
AW W B channels VALID READY handshake
WSTRB byte enable BRESP error handling
Yosys synthesis complete
NeuralEdge write path done"
git push
```

---

## What is Next

```
Day 32 — AXI4-Lite Read Channel
  AR + R channels
  ARVALID ARREADY
  RVALID RREADY RDATA RRESP
  Complete Master-Slave AXI system
  NeuralEdge full AXI4-Lite done
```

---

*Part of 100 Days of VLSI — Sand to Silicon*
*github.com/prashik-vlsi/100_Days_of_VLSI*
*Built by Prashik Wankhede — Tier-3 to Industry*
