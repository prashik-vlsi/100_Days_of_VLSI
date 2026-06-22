# Day 22 — UART Receiver (8E1 Protocol with 16× Oversampling)

## Topic

**UART Receiver** — 16× Oversampling Time-Base, Glitch Rejection Logic, Metastability Synchronization, Even Parity Verification, Framing Error Detection, FSM Control, and Parallel Data Reconstruction.

---

## Theory

The Universal Asynchronous Receiver-Transmitter (UART) Receiver (`RX`) captures an asynchronous serial data stream and reconstructs it into parallel data bytes. Since the incoming serial signal is not synchronized with the system clock, the receiver must safely recover data timing using oversampling techniques.

A robust UART receiver typically consists of three major blocks:

### 1. Input Synchronizer

The `rx` input is asynchronous to the system clock and may cause metastability if sampled directly. A multi-stage synchronizer is used to safely transfer the signal into the receiver clock domain.

### 2. 16× Oversampling Tick Generator

A baud-rate generator produces a sampling enable pulse sixteen times faster than the target baud rate. This allows the receiver to locate the center of each bit period for reliable data recovery.

### 3. Receive Finite State Machine (FSM)

The FSM manages frame reception, validates the start bit, reconstructs serial data into parallel format, performs parity verification, checks the stop bit, and generates completion/error flags.

---

## Key Concepts

### Asynchronous Clock Recovery

The receiver derives an internal sampling time-base from the system clock.

**Given:**

- System Clock = `50 MHz`
- Baud Rate = `115200 bps`
- Oversampling Factor = `16×`

The oversampling tick frequency is:

```text
115200 × 16 = 1.8432 MHz
```

Required divider value:

```text
50,000,000 / 1,843,200 = 27.126
```

Selected implementation:

```verilog
MAX_COUNT = 26;
```

A counter running from `0` to `26` generates a tick every `27` clock cycles.

---

### Start-Bit Glitch Rejection

A falling edge on the RX line does not immediately indicate a valid start bit.

To reject noise pulses:

1. Detect the falling edge.
2. Wait 8 oversampling ticks.
3. Sample the center of the start bit.
4. Confirm that RX remains LOW.

If RX is HIGH at the midpoint sample, the event is classified as a glitch and the FSM returns to `IDLE`.

---

## UART Frame Format (8E1)

| Field      | Width | Value       |
| ---------- | ----- | ----------- |
| Start Bit  | 1     | 0           |
| Data Bits  | 8     | LSB First   |
| Parity Bit | 1     | Even Parity |
| Stop Bit   | 1     | 1           |

Frame sequence:

```text
IDLE
  ↓
START
  ↓
D0 → D1 → D2 → D3 → D4 → D5 → D6 → D7
  ↓
PARITY
  ↓
STOP
  ↓
IDLE
```

---

## Sampling Geometry

### Start Bit

The center of the start bit is verified at:

```text
tick_count = 7
```

which corresponds to the 8th oversampling tick.

### Data, Parity, and Stop Bits

Each subsequent bit is sampled at:

```text
tick_count = 15
```

which corresponds to 16 oversampling ticks from the previous sample point.

This ensures sampling occurs near the geometric center of every bit period.

---

## Functional Blocks

### Input Synchronizer

**Purpose**

- Metastability protection

**Implementation**

```verilog
rx_sync <= rx;
```

---

### Oversampling Tick Generator

**Purpose**

- Generate 16× baud-rate sampling ticks

**Implementation**

- Counter-based clock divider

---

### Start-Bit Validator

**Purpose**

- Noise and glitch rejection

**Condition**

```verilog
rx_sync == 0
```

at:

```text
tick_count == 7
```

---

### Shift Register

**Purpose**

- Reconstruct serial data into parallel format

**Implementation**

```verilog
rx_shift <= {rx_sync, rx_shift[7:1]};
```

---

### Even Parity Checker

**Purpose**

- Validate received parity bit

**Condition**

```text
D0 ⊕ D1 ⊕ D2 ⊕ D3 ⊕ D4 ⊕ D5 ⊕ D6 ⊕ D7 ⊕ P = 0
```

A non-zero result generates:

```verilog
parity_err <= 1'b1;
```

---

### Framing Error Detector

**Purpose**

- Verify stop-bit integrity

**Condition**

```verilog
rx_sync == 1'b1
```

during STOP state.

Otherwise:

```verilog
frame_err <= 1'b1;
```

---

### Receive FSM

State progression:

```text
IDLE
  ↓
START
  ↓
DATA
  ↓
PARITY
  ↓
STOP
  ↓
IDLE
```

The FSM controls:

- Start-bit validation
- Bit counting
- Data shifting
- Parity verification
- Stop-bit verification
- Completion signaling

---

## Project Files

### uart_rx.v

UART Receiver RTL implementation containing:

- Input synchronizer
- Tick generator
- Receive FSM
- Data reconstruction logic
- Error detection logic

### uart_rx_tb.v

Self-checking testbench that verifies:

- Valid frame reception
- Parity error handling
- Framing error detection
- Start-bit glitch rejection

### uart_rx_sim.vcd

Waveform database used for GTKWave analysis.

### README.md

Project documentation and integration notes.

---

## Verified Conditions

- [x] Accurate 16× oversampling tick generation
- [x] Mid-bit start-bit validation
- [x] Noise glitch rejection
- [x] LSB-first byte reconstruction
- [x] Even parity verification
- [x] Stop-bit framing validation
- [x] Single-cycle `rx_done` pulse generation
- [x] Error flag generation (`parity_err`, `frame_err`)

---

## Key Learnings

### Oversampling-Based Data Recovery

Sampling at the center of each bit period maximizes timing margin and improves tolerance to baud-rate mismatch between transmitter and receiver.

### Reliable SoC Integration

When either:

```verilog
parity_err
```

or

```verilog
frame_err
```

is asserted, the received byte should be considered invalid.

Recommended hardware response:

- Log protocol fault
- Block normal data processing
- Clear receive buffers
- Request retransmission

### FSM Recovery Design

Error recovery paths must be carefully implemented.

Improper state transitions or uncleared counters can permanently stall a receiver and create protocol deadlocks.

---

## Verification Environment

**Simulator:** Icarus Verilog (`iverilog`)

**Waveform Viewer:** GTKWave

---

## Status

✔ RTL Implemented
✔ Testbench Verified
✔ Waveforms Analyzed
✔ Error Conditions Validated

**Part of the 100 Days of VLSI Series**
