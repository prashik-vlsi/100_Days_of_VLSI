# Day 13 — Asynchronous FIFO
### 100 Days of VLSI — Prashik Wankhede
**Phase 1 · Module 2 · Bootcamp**

---

## What Was Built

A complete **Asynchronous FIFO** with Clock Domain Crossing (CDC) support.
- 8-bit wide × 16-deep dual port SRAM
- Gray code pointers for safe CDC
- 2 Flip-Flop synchronizers on both pointer paths
- FULL logic in write domain
- EMPTY logic in read domain
- All 8 ECG samples verified in simulation

---

## Capstone Connection — VitalGuard SoC

```
┌──────────────────────────────────────────────────────────┐
│                    VitalGuard SoC                        │
│                                                          │
│  ┌──────────┐   wr_clk=3MHz    ┌──────────────────────┐ │
│  │   ADC    │─────────────────►│                      │ │
│  │          │   wr_en          │   ASYNCHRONOUS       │ │
│  │  Samples │─────────────────►│   FIFO               │ │
│  │  ECG at  │   wr_data[7:0]   │                      │ │
│  │  3MHz    │─────────────────►│   8-bit x 16-deep    │ │
│  │          │                  │                      │ │
│  │          │◄─────────────────│   full               │ │
│  └──────────┘   back-pressure  │                      │ │
│                                │                      │ │
│  ┌──────────┐   rd_clk=48MHz   │                      │ │
│  │ DSP CORE │─────────────────►│                      │ │
│  │          │   rd_en          │                      │ │
│  │  Filter  │◄─────────────────│   rd_data[7:0]       │ │
│  │  FFT     │                  │                      │ │
│  │  Analysis│◄─────────────────│   empty              │ │
│  └──────────┘                  └──────────────────────┘ │
│                                                          │
│  CDC handled safely. No metastability. No data loss.     │
└──────────────────────────────────────────────────────────┘
```

---

## Architecture

```
╔══════════════════════════════════════════════════════════════════╗
║                     ASYNCHRONOUS FIFO                           ║
║                                                                  ║
║  WRITE DOMAIN (wr_clk)              READ DOMAIN (rd_clk)        ║
║  ══════════════════════             ═════════════════════        ║
║                                                                  ║
║  wr_en, wr_data                     rd_en                       ║
║       │                                │                        ║
║       ▼                                ▼                        ║
║  ┌─────────────┐                  ┌─────────────┐              ║
║  │  wr_ptr     │                  │  rd_ptr     │              ║
║  │  (binary)   │                  │  (binary)   │              ║
║  │  5-bit      │                  │  5-bit      │              ║
║  └──────┬──────┘                  └──────┬──────┘              ║
║         │ wr_addr[3:0]                   │ rd_addr[3:0]        ║
║         ▼                                ▼                      ║
║  ╔════════════════════════════════════════════╗                 ║
║  ║           DUAL PORT SRAM                   ║                 ║
║  ║           8-bit wide × 16 deep             ║                 ║
║  ╚════════════════════════════════════════════╝                 ║
║         │                                │                      ║
║         ▼                                ▼                      ║
║  ┌─────────────┐                  ┌─────────────┐              ║
║  │ BIN→GRAY    │                  │ BIN→GRAY    │              ║
║  └──────┬──────┘                  └──────┬──────┘              ║
║         │ wr_ptr_gray                    │ rd_ptr_gray         ║
║         │                                │                      ║
║         │◄── 2FF SYNC (rd→wr domain) ────│                     ║
║         │    rd_ptr_gray_sync            │                      ║
║         │                                │                      ║
║         │─── 2FF SYNC (wr→rd domain) ───►│                     ║
║         │                  wr_ptr_gray_sync                     ║
║         │                                │                      ║
║         ▼                                ▼                      ║
║  ┌─────────────┐                  ┌─────────────┐              ║
║  │ FULL LOGIC  │                  │ EMPTY LOGIC │              ║
║  └──────┬──────┘                  └──────┬──────┘              ║
║         │                                │                      ║
║         ▼                                ▼                      ║
║       full                             empty                    ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## Why Gray Code

```
Binary 7 → 8 transition:
  Binary:  0111 → 1000   (4 bits change simultaneously — DANGEROUS)
  Gray:    0100 → 1100   (only 1 bit changes — SAFE)

If synchronizer samples mid-transition:
  Binary → could latch 1111, 0000, 1011 — CORRUPT value
  Gray   → sees either 0100 or 1100     — both VALID values
```

---

## 2-FF Synchronizer

```
SOURCE DOMAIN                    DESTINATION DOMAIN
(wr_clk)                         (rd_clk)
─────────────────                ──────────────────────────

                                  rd_clk      rd_clk
                                     │            │
                                     ▼            ▼
SIGNAL ─────────────────────────►[ FF1 ]──────►[ FF2 ]──► SAFE
                                     │
                              MAY BE METASTABLE
                              Resolves in 1 cycle
                                              │
                                         Clean output
```

---

## FULL and EMPTY Conditions

```
EMPTY — checked in READ domain:
  empty = (rd_ptr_gray == wr_ptr_gray_sync)
  All 5 bits equal → reader caught up to writer

FULL — checked in WRITE domain:
  full = top 2 bits DIFFER + bottom 3 bits EQUAL
  wr_ptr_gray[4] ≠ rd_ptr_gray_sync[4]
  wr_ptr_gray[3] ≠ rd_ptr_gray_sync[3]
  wr_ptr_gray[2] = rd_ptr_gray_sync[2]
  wr_ptr_gray[1] = rd_ptr_gray_sync[1]
  wr_ptr_gray[0] = rd_ptr_gray_sync[0]
```

---

## Files

| File | Description |
|------|-------------|
| `async_fifo_mem.v` | Dual port SRAM — 8-bit × 16-deep |
| `async_fifo_wr_ctrl.v` | Write controller — wr_ptr, Gray, FULL |
| `async_fifo_rd_ctrl.v` | Read controller — rd_ptr, Gray, EMPTY |
| `async_fifo.v` | Top level — connects all + 2FF synchronizers |
| `tb_async_fifo.v` | Testbench — 8 ECG samples verified |

---

## Simulation Results

```
Tools    : iverilog + GTKWave
Platform : Ubuntu 22.04

Write domain clock : 10ns period (100 MHz)
Read domain clock  : 3ns  period (333 MHz)

ECG Samples Written : A1 A2 A3 A4 A5 A6 A7 A8
ECG Samples Read    : A1 A2 A3 A4 A5 A6 A7 A8

Result : PASS — All 8 samples verified
CDC    : PASS — No metastability errors
```

---

## Key Concepts Learned

- **Clock Domain Crossing (CDC)** — why it is dangerous
- **Metastability** — what it is and how 2FF sync resolves it
- **Gray Code** — only 1 bit changes per increment — safe to sync
- **Dual Port SRAM** — independent read and write ports
- **FULL/EMPTY** — computed in correct clock domains
- **Multi-file RTL** — one file per clock domain — industry practice

---

## Commit Message

```
Day13: Async FIFO — CDC between ADC and DSP clock domains
for VitalGuard SoC. Gray code pointers, 2FF synchronizers,
FULL/EMPTY logic. All 8 ECG samples verified in simulation.
```

---

*100 Days of VLSI — github.com/prashik-vlsi/100_Days_of_VLSI*
