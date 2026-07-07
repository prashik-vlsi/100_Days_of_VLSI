# Day 32 — AXI4-Lite Complete (Read + Write)
## 100 Days of VLSI — NeuralEdge SoC Project



## NeuralEdge SoC Context

NeuralEdge is an edge AI inference accelerator SoC
designed to run neural network classification
entirely on chip — no cloud, no internet required.

The complete AXI4-Lite Master-Slave system built
across Days 31-32 is the full control plane of
NeuralEdge. The host processor writes neural
network weights via the write channels and reads
inference results via the read channels —
simultaneously, without blocking.

This is the most critical bus interface in the
NeuralEdge architecture.

---

## Module Overview

| Parameter | Value |
|-----------|-------|
| Module | axi4_lite_slave_complete |
| Protocol | ARM AMBA AXI4-Lite (IHI0022) |
| Data Width | 32-bit |
| Addr Width | 32-bit |
| Write Channels | AW + W + B |
| Read Channels | AR + R |
| Total Channels | 5 independent |
| Memory Depth | 16 locations (testbench) |
| Error Handling | BRESP SLVERR / RRESP SLVERR |
| Test Cases | 19 — all passed |
| Synthesis | Yosys — 1707 cells |
| DFF Count | 531 total |
| Simulation | iverilog + GTKWave |

---

## Complete AXI4-Lite Architecture

```
┌──────────────────────────────────────────────────────┐
│              AXI4-LITE COMPLETE SYSTEM               │
│                                                      │
│  ┌─────────────────┐       ┌──────────────────────┐  │
│  │   AXI4 MASTER   │       │    AXI4 SLAVE        │  │
│  │                 │       │                      │  │
│  │  ┌───────────┐  │──AW──►│  ┌────────────────┐  │  │
│  │  │ AW Channel│  │       │  │ Write Addr FSM │  │  │
│  │  │ AWVALID   │◄─┤──AW───┤  │ awaddr_reg     │  │  │
│  │  │ AWREADY   │  │       │  └────────────────┘  │  │
│  │  │ AWADDR    │  │       │                      │  │
│  │  └───────────┘  │       │  ┌────────────────┐  │  │
│  │                 │──W───►│  │ Write Data FSM │  │  │
│  │  ┌───────────┐  │       │  │ wdata + wstrb  │  │  │
│  │  │ W Channel │◄─┤──W────┤  │ Memory write   │  │  │
│  │  │ WVALID    │  │       │  └────────────────┘  │  │
│  │  │ WREADY    │  │       │                      │  │
│  │  │ WDATA     │  │       │  ┌────────────────┐  │  │
│  │  │ WSTRB     │  │◄─B────┤  │ Write Response │  │  │
│  │  └───────────┘  │       │  │ BRESP OKAY     │  │  │
│  │                 │       │  │ BRESP SLVERR   │  │  │
│  │  ┌───────────┐  │       │  └────────────────┘  │  │
│  │  │ B Channel │  │       │                      │  │
│  │  │ BVALID    │  │──AR──►│  ┌────────────────┐  │  │
│  │  │ BREADY    │  │       │  │ Read Addr FSM  │  │  │
│  │  │ BRESP     │◄─┤──AR───┤  │ araddr_reg     │  │  │
│  │  └───────────┘  │       │  └────────────────┘  │  │
│  │                 │       │                      │  │
│  │  ┌───────────┐  │◄─R────┤  ┌────────────────┐  │  │
│  │  │ AR Channel│  │       │  │ Read Data FSM  │  │  │
│  │  │ ARVALID   │  │       │  │ Memory read    │  │  │
│  │  │ ARREADY   │  │       │  │ RDATA + RRESP  │  │  │
│  │  └───────────┘  │       │  └────────────────┘  │  │
│  │                 │       │                      │  │
│  │  ┌───────────┐  │       │  ┌────────────────┐  │  │
│  │  │ R Channel │  │       │  │ Shared Memory  │  │  │
│  │  │ RVALID    │  │       │  │ Array          │  │  │
│  │  │ RREADY    │  │       │  │ 16 x 32-bit    │  │  │
│  │  │ RDATA     │  │       │  └────────────────┘  │  │
│  │  │ RRESP     │  │       │                      │  │
│  │  └───────────┘  │       └──────────────────────┘  │
│  └─────────────────┘                                  │
└──────────────────────────────────────────────────────┘
```

---


## VALID READY Handshake — Golden Rule

```
Transfer occurs ONLY when both
VALID and READY are high
on the same rising clock edge.

VALID  READY  Action
─────  ─────  ─────────────────────────────
  0      0    Both waiting — no transfer
  1      0    Master ready — slave not ready
              Master MUST hold signals stable
  0      1    Slave ready — master not ready
              Slave waits — no action
  1      1    ✅ TRANSFER — data moves

VALID rule: Once asserted — cannot
be deasserted until transfer completes.
READY rule: Can assert or deassert anytime.
```

---

## BRESP and RRESP Encoding

| Code | Name | Description |
|------|------|-------------|
| 2'b00 | OKAY | Transfer successful |
| 2'b01 | EXOKAY | Exclusive access okay |
| 2'b10 | SLVERR | Slave error — bad address |
| 2'b11 | DECERR | Decode error — no slave found |

---

## Write Channel State Machines

### AW Channel FSM

```
         ┌─────────────────────────────────┐
         │         AW FSM                  │
         │                                 │
         │  ┌──────┐  awvalid=1  ┌───────┐ │
         │  │ IDLE │────────────►│ADR_RCV│ │
         │  │      │◄────────────│       │ │
         │  └──────┘  handshake  └───────┘ │
         │             complete            │
         │  awready=1 in IDLE              │
         │  awready=0 in ADR_RCV           │
         └─────────────────────────────────┘
```

### W Channel FSM

```
         ┌─────────────────────────────────┐
         │         W FSM                   │
         │                                 │
         │  ┌──────┐  wvalid=1   ┌───────┐ │
         │  │ IDLE │────────────►│DAT_RCV│ │
         │  │      │◄────────────│       │ │
         │  └──────┘  write done └───────┘ │
         │                                 │
         │  wready=1 when addr received    │
         └─────────────────────────────────┘
```

### Read Channel FSM

```
         ┌─────────────────────────────────┐
         │         AR + R FSM              │
         │                                 │
         │  ┌──────┐  arvalid=1  ┌───────┐ │
         │  │ IDLE │────────────►│RD_PROC│ │
         │  │      │◄────────────│       │ │
         │  └──────┘  rready=1   └───────┘ │
         │                                 │
         │  arready=1 in IDLE              │
         │  rvalid=1 in RD_PROC            │
         └─────────────────────────────────┘
```

---



### Synthesis Statistics

```
=== axi4_lite_slave_complete ===

   Number of wires         :   281
   Number of wire bits     :  1910
   Number of public wires  :    38
   Number of public wire bits: 584
   Number of memories      :     0
   Number of memory bits   :     0
   Number of processes     :     0
   Number of cells         :  1707

   $_AND_       :   527   address decode + FSM logic
   $_DFFE_PN0N_ :    33   DFF enable active low reset
   $_DFFE_PN0P_ :    17   DFF enable active low reset
   $_DFFE_PN1P_ :     1   DFF enable active high reset
   $_DFFE_PP_   :   480   DFF enable positive reset
   $_MUX_       :    81   data selection logic
   $_NOT_       :    46   signal inversion
   $_OR_        :   522   condition combining

   Total DFF    :   531   (33+17+1+480)
   Combinational:  1176   (1707-531)
   Problems     :     0   ✅
```

### Synthesis Comparison

| Module | Cells | DFF | Purpose |
|--------|-------|-----|---------|
| APB Timer — Day 28 | 356 | 98 | Simple peripheral |
| AHB Master — Day 29 | 361 | 39 | Pipelined bus |
| AXI4 Complete — Day 32 | 1707 | 531 | Full 5-channel bus |

**Why AXI4 is 4.8x larger than APB:**
Five independent state machines — one per channel.
32-bit memory array with byte enable decode.
Concurrent read write path — both active simultaneously.
BRESP and RRESP generation logic.
Full handshake tracking for all 5 channels.

---

## Simulation Results — 19 Test Cases

### Test Summary

| # | Test Case | Expected | Result |
|---|-----------|----------|--------|
| 1 | Reset — all signals zero | All outputs 0 | ✅ PASS |
| 2 | Write addr 0x0 data 0xAB | mem[0]=0xAB | ✅ PASS |
| 3 | Write addr 0x4 data 0xCD | mem[1]=0xCD | ✅ PASS |
| 4 | Write addr 0x8 data 0xEF | mem[2]=0xEF | ✅ PASS |
| 5 | Read addr 0x0 | rdata=0xAB | ✅ PASS |
| 6 | Read addr 0x4 | rdata=0xCD | ✅ PASS |
| 7 | Read addr 0x8 | rdata=0xEF | ✅ PASS |
| 8 | WSTRB byte enable 4'b0001 | Only byte 0 written | ✅ PASS |
| 9 | WSTRB halfword 4'b0011 | Bytes 0-1 written | ✅ PASS |
| 10 | Write invalid addr 0xFF0 | BRESP=SLVERR | ✅ PASS |
| 11 | Read invalid addr 0xFF0 | RRESP=SLVERR | ✅ PASS |
| 12 | Slave busy — AWREADY low | Master waits | ✅ PASS |
| 13 | Slave busy — ARREADY low | Master waits | ✅ PASS |
| 14 | Back to back writes | All data correct | ✅ PASS |
| 15 | Back to back reads | All data correct | ✅ PASS |
| 16 | Write then read same addr | Read = written | ✅ PASS |
| 17 | Simultaneous read write | No corruption | ✅ PASS |
| 18 | BVALID BREADY handshake | Response complete | ✅ PASS |
| 19 | Full memory sequential write | All locations correct | ✅ PASS |

**Result: 19/19 PASS ✅**

---

## Waveform Observations — GTKWave
![Image Alt](https://raw.githubusercontent.com/prashik-vlsi/100_Days_of_VLSI/9cd9212a54134a9bac053ccffde2a16de550ee07/Wavefrom_images/day32.png)

### Key Signal Behaviors

| Signal | Observed Behavior |
|--------|------------------|
| AWVALID | Held high until AWREADY seen |
| AWREADY | Pulsed high to accept address |
| WVALID | Independent of AW channel |
| WSTRB | 4'b1111 full word — 4'b0001 byte |
| BVALID | One cycle after write completes |
| ARVALID | Held until ARREADY seen |
| RVALID | Asserted with RDATA valid |
| RRESP | 2'b00 OKAY — 2'b10 SLVERR |

---

## Debugging Log — Issues Found and Fixed

### Bug 1 — Incorrect Memory Write Address

**Symptom:** Writing to address 0x3 overwrote
data at address 0x5. Reading 0x3 returned X.

**Root Cause:** awaddr_reg was updated one
transaction late — used previous address
instead of current one.

**Fix:** Captured write address only after
valid AW handshake. Held stable until
write transaction completed.

**Lesson:** In pipelined buses address must
be latched at handshake — not speculatively.

---

### Bug 2 — One Cycle Address Shift

**Symptom:** Every write shifted by one
memory location. Final location unwritten.

**Root Cause:** Address register changed
before previous write completed.

**Fix:** Held awaddr_reg constant until
W-channel handshake (wvalid && wready)
completed.

**Lesson:** Address and data phases are
independent channels — coordinate carefully.

---

### Bug 3 — AW FSM Stuck in ADR_RCV

**Symptom:** Simulation hung during Test 5.
aw_state never returned to IDLE.

**Root Cause:** awready never reasserted
for next transaction.

**Fix:** Returned AW FSM to IDLE after
successful write handshake completion.

**Lesson:** Every FSM must have a clear
return path to IDLE. Stuck states cause
bus deadlock in real silicon.

---

### Bug 4 — AW/W Channel Desynchronization

**Symptom:** Address and data channels
became unsynchronized — wrong data written.

**Root Cause:** awready timing did not
follow AXI4-Lite protocol correctly.

**Fix:** Asserted awready in IDLE.
Deasserted after address acceptance.
Waited for write-data handshake before
accepting another address.

**Lesson:** Each AXI channel has strict
protocol ordering rules — violating
them causes silent data corruption.

---

### Bug 5 — Simulation Hung Full Memory Test

**Symptom:** Testbench stopped after few writes.

**Root Cause:** bvalid stayed asserted
because transaction never completed.

**Fix:** Correctly handled bvalid/bready
handshake. Ensured each write response
completed before starting next transaction.

**Lesson:** Response channel is not optional.
Master must always receive and accept BRESP
before issuing next transaction.

---

### Bug 6 — Yosys Output Directory Missing

**Symptom:**
```
ERROR: Can't open output file
synthesis/axi4_slave_netlist.v
```

**Fix:**
```bash
mkdir synthesis
yosys axi4_slave.ys
```

**Lesson:** Always create output directories
before running synthesis scripts.

---

### Bug 7 — Yosys Run Inside Shell

**Symptom:**
```
yosys> yosys axi4_slave.ys
ERROR: No such command: yosys
```

**Fix:** Exit Yosys shell first.
Run from Linux terminal:
```bash
yosys axi4_slave.ys
```

**Lesson:** Yosys interactive shell and
batch mode are different environments.

---

### Bug 8 — DOT to PNG Conversion

**Task:** Generate graphical netlist view.

**Command:**
```bash
dot -Tpng synthesis/axi4_slave.dot \
    -o synthesis/axi4_slave.png
```

**Result:** Visual schematic generated. ✅

![Image Alt](https://raw.githubusercontent.com/prashik-vlsi/100_Days_of_VLSI/9cd9212a54134a9bac053ccffde2a16de550ee07/Wavefrom_images/axi4_slave.png)

---

## Key Concepts Mastered

### 1. Five Independent Channels
AXI4-Lite separates read and write into
completely independent channel pairs.
AW W B handle writes. AR R handle reads.
All five can operate simultaneously —
no blocking between read and write paths.

### 2. VALID READY Handshake Protocol
Transfer occurs only when both VALID and
READY are high on the same clock edge.
VALID cannot be deasserted once asserted.
READY can toggle freely. This asymmetry
protects protocol ordering.

### 3. Address Latching in Pipelined Bus
Because AW and W channels are independent,
the write address must be latched after
the AW handshake and held stable until
the W handshake completes. Premature
update causes address corruption.

### 4. WSTRB Byte Enable
WSTRB[3:0] controls which byte lanes
of WDATA are written. Essential for
partial word updates — register fields,
byte arrays, packed structures.

### 5. Response Channel Mandatory
Every write transaction MUST receive a
BRESP response. Every read transaction
MUST receive RRESP with RDATA. Skipping
response causes bus deadlock in real SoC
because master waits forever.

---

## AXI4-Lite vs AXI4 Full vs CHI

| Feature | AXI4-Lite | AXI4 Full | AMBA 5 CHI |
|---------|-----------|-----------|------------|
| Channels | 5 | 5 | 3 layers |
| Burst | No | Yes | Packet |
| Out of order | No | Yes (ID tags) | Yes |
| Coherency | No | No | Yes (MESI) |
| Interface | Wire parallel | Wire parallel | SerDes NoC |
| Scale | 1-4 masters | 8-16 masters | 100s cores |
| Use case | Accelerator ctrl | Memory fabric | Multi-core CPU |
| NeuralEdge | Control plane | — | — |

---



## Capstone Connection — NeuralEdge

```
┌──────────────────────────────────────────────┐
│  NeuralEdge — AXI4-Lite Control Plane        │
│                                              │
│  Host Processor                              │
│       │                                      │
│       ├── AW+W+B ──► Write weights to memory │
│       │                                      │
│       └── AR+R ◄─── Read inference results   │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │  AXI4-Lite Slave Complete (Day 32)     │  │
│  │                                        │  │
│  │  ┌──────────┐      ┌────────────────┐  │  │
│  │  │  Weight  │      │   Inference    │  │  │
│  │  │  Memory  │─────►│   MAC Unit     │  │  │
│  │  │ (SPRAM)  │      │   (Day 18-20)  │  │  │
│  │  └──────────┘      └───────┬────────┘  │  │
│  │                            │           │  │
│  │                    ┌───────▼────────┐  │  │
│  │                    │   Result Reg   │  │  │
│  │                    │   Read via AR  │  │  │
│  │                    └────────────────┘  │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

---

## Protocol Stack — Complete Understanding

```
┌──────────────────────────────────────────────┐
│  AMBA PROTOCOL HIERARCHY                     │
│                                              │
│  APB  ── Simple ── Slow ── Peripherals       │
│          2 phases  low BW  timers GPIO       │
│          Day 27-28 ✅                        │
│                                              │
│  AHB  ── Pipelined ── Medium ── Memory       │
│          burst      mid BW    DMA ROM        │
│          Day 29-30 ✅                        │
│                                              │
│  AXI4 ── 5 channel ── High ── Accelerators  │
│          concurrent  high BW  GPU AI engine  │
│          Day 31-32 ✅                        │
│                                              │
│  CHI  ── Packet NoC ── Ultra ── Multi-core  │
│          coherent    max BW   CPU clusters   │
│          Conceptual ✅                       │
└──────────────────────────────────────────────┘
```

---

## Progress

```
Day 32 / 100 complete
NeuralEdge SoC — 68% blocks complete
Tapeout — 51 days remaining

Protocol stack COMPLETE:
  UART  ✅ Days 21-22
  SPI   ✅ Days 23-24
  I2C   ✅ Days 25-26
  APB   ✅ Days 27-28
  AHB   ✅ Days 29-30
  AXI4  ✅ Days 31-32

Next: Day 33 — CDC 2FF Synchronizer
```

---


*Part of 100 Days of VLSI — Sand to Silicon*
*github.com/prashik-vlsi/100_Days_of_VLSI*
*Built by Prashik Wankhede — Tier-3 to Industry*
