# Day 14 — Clock Domain Crossing (CDC): Advanced Techniques

> **Project:** VitalGuard Medical Monitoring System
> **Topic:** Advanced CDC — Pulse Synchronization, Handshake Protocol, Multi-Bit Transfer

---

## Table of Contents

- [Overview](#overview)
- [Techniques Covered](#techniques-covered)
  - [Pulse Synchronizer](#1-pulse-synchronizer)
  - [Handshake Synchronizer](#2-handshake-synchronizer)
  - [Multi-Bit CDC](#3-multi-bit-cdc)
- [Implemented Modules](#implemented-modules)
- [Simulation Results](#simulation-results)
- [Capstone Integration — VitalGuard](#capstone-integration--vitalguard)
- [Key Learnings](#key-learnings)
- [Skills Acquired](#skills-acquired)

---

## Overview

This module covers advanced Clock Domain Crossing (CDC) techniques for safely transferring pulses, control signals, and multi-bit data between asynchronous clock domains in ASIC and FPGA designs.

The primary goals are:

- Prevent **metastability** and **data corruption**
- Ensure **zero event loss** across clock boundaries
- Apply industry-standard CDC patterns to the VitalGuard ADC-to-DSP interface

> Builds on foundational CDC concepts from previous days. Essential for reliable real-world FPGA and ASIC design.

---

## Techniques Covered

### 1. Pulse Synchronizer

#### Problem

A conventional 2-Flip-Flop synchronizer cannot reliably capture pulses narrower than the destination clock period, leading to missed events.

#### Solution

A **Toggle Flip-Flop (TFF)** converts each pulse into a level transition in the source domain. The toggled signal is then synchronized and edge-detected in the destination domain.

#### Architecture

```
Source Domain                  Destination Domain
─────────────────────────────────────────────────
Pulse ──► Toggle FF ──► 2FF Synchronizer ──► XOR Edge Detector ──► Pulse Out
```

#### Benefits

- Captures narrow pulses reliably
- Prevents pulse loss across unrelated clock domains
- Resistant to metastability
- Suitable for interrupt and event signaling

---

### 2. Handshake Synchronizer

#### Problem

Transferring multi-bit data directly across clock domains risks:

- Partial sampling
- Data corruption
- Inconsistent values at the destination

#### Solution

A **4-phase handshake protocol** ensures guaranteed, ordered delivery.

#### Handshake Sequence

```
Step    Source Domain        Destination Domain
────────────────────────────────────────────────
 1      Place data on bus
 2      Assert req ──────────────────────────────►
 3                           Capture data
 4      ◄──────────────────── Assert ack
 5      Deassert req
 6                           Deassert ack
```

#### Benefits

- Guaranteed data delivery with no corruption
- Compatible with fully asynchronous clocks
- Industry-standard CDC interface pattern

---

### 3. Multi-Bit CDC

#### Challenge

Synchronizing each bit independently is unsafe — different bits may be captured at different clock edges, producing transient invalid values.

#### Safe Techniques

**Gray Code Synchronization**

- Only one bit changes between adjacent values
- Eliminates multi-bit transition ambiguity
- Widely used in asynchronous FIFOs

**Asynchronous FIFO**

- Independent write and read clocks
- Gray-coded read/write pointers
- Pointer synchronization through 2FF synchronizers
- Full/Empty detection logic

---

## Implemented Modules

| File                  | Description                                                            |
| --------------------- | ---------------------------------------------------------------------- |
| `pulse_sync.v`        | Pulse synchronizer — Toggle FF + 2FF Synchronizer + XOR Edge Detection |
| `tb_pulse_sync.v`     | Testbench: ADC (5 MHz) → DSP (50 MHz) pulse transfer                   |
| `handshake_sync.v`    | 4-phase handshake synchronizer for 8-bit CDC transfer                  |
| `handshake_sync_tb.v` | Testbench: ECG sample transfer across clock domains                    |

---

## Simulation Results

### Pulse Synchronizer

| Parameter               | Value   |
| ----------------------- | ------- |
| Source Clock (ADC)      | 5 MHz   |
| Destination Clock (DSP) | 50 MHz  |
| Transfer Latency        | ~130 ns |

**Results:**

| Test                                  | Status  |
| ------------------------------------- | ------- |
| Source pulse captured                 | ✅ Pass |
| No pulse loss                         | ✅ Pass |
| Destination pulse generated correctly | ✅ Pass |
| Metastability mitigated               | ✅ Pass |
| Back-to-back pulses — all detected    | ✅ Pass |
| Toggle synchronization under load     | ✅ Pass |

---

### Handshake Synchronizer

**Test Data:** `8'hA5`

| Measurement         | Value      |
| ------------------- | ---------- |
| Source Data         | `8'hA5`    |
| Destination Data    | `8'hA5`    |
| Data Integrity      | ✅ Match   |
| req/ack Sequence    | ✅ Correct |
| Corruption Observed | ✅ None    |

---

## Capstone Integration — VitalGuard

The VitalGuard Medical Monitoring System requires reliable CDC across three interfaces:

### ADC → DSP Interrupt Transfer

```
ADC Pulse ──► Pulse Synchronizer ──► DSP Interrupt
```

- ADC clock domain differs from DSP clock domain
- Pulse synchronizer ensures no interrupt loss

---

### ECG Sample Transfer

```
ADC Domain (8-bit ECG Sample) ──► Handshake Synchronizer ──► DSP Domain
```

- 8-bit sample transferred without corruption
- Verified result: `8'hA5` transferred successfully

---

### Continuous Sample Buffering (Multi-Bit CDC)

```
ADC ──► Async FIFO ──► DSP
```

- Gray-coded read/write pointers
- 2FF pointer synchronization
- Full/Empty detection

---

## Key Learnings

- A 2FF synchronizer alone is **insufficient** for narrow pulse transfers
- Toggle-based synchronization converts transient pulses into detectable level changes
- Handshake protocols provide **guaranteed** multi-bit CDC delivery
- Gray code reduces synchronization errors by changing only **one bit per transition**
- Asynchronous FIFOs are the **industry-standard** solution for high-speed multi-bit CDC
- CDC verification is critical for safe, reliable FPGA and ASIC operation

---

## Skills Acquired

- Pulse Synchronizer Design
- Toggle Flip-Flop CDC Techniques
- XOR-based Edge Detection Logic
- 4-Phase Handshake Protocol Implementation
- Multi-Bit CDC Design Patterns
- Gray Code Conversion
- Asynchronous FIFO Architecture
- CDC Verification and Waveform Debugging
- FPGA/ASIC CDC Best Practices

---

## Summary

| Deliverable                            | Status                    |
| -------------------------------------- | ------------------------- |
| Pulse Synchronizer                     | ✅ Implemented & Verified |
| Toggle FF CDC Technique                | ✅ Implemented & Verified |
| Handshake Synchronizer                 | ✅ Implemented & Verified |
| Multi-Bit CDC Concepts                 | ✅ Studied & Applied      |
| VitalGuard ADC-to-DSP CDC Architecture | ✅ Integrated             |

> Day 14 completes the advanced CDC foundation required for reliable asynchronous clock domain communication in production-grade FPGA and ASIC systems.
