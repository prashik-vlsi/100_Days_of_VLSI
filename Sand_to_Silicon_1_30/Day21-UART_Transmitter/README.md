# Day 21 — UART Transmitter (8N1 Protocol)

## Topic

UART Transmitter — Baud Rate Generation, Serial Data Transmission, FSM Control, 8N1 Frame Formatting, Asynchronous Communication

## Theory

The Universal Asynchronous Receiver-Transmitter (UART) is one of the most widely deployed serial communication interfaces in digital systems. Unlike synchronous protocols, UART does not transmit a clock signal alongside data. Instead, both communicating devices agree beforehand on a fixed baud rate, allowing data to be exchanged over a single serial line.

UART transmission converts parallel data stored inside registers into a serialized bit stream. The transmitter frames the data according to a predefined protocol, ensuring that the receiver can correctly identify the beginning, payload, and end of each transmitted word.

A standard UART transmitter consists of two primary components:

1. **Baud Rate Generator (BRG)** — Generates timing ticks corresponding to the selected baud rate.
2. **Transmit Finite State Machine (FSM)** — Controls frame sequencing and serial data output.

---

## Key Distinctions

### Asynchronous Communication

No clock signal is exchanged between transmitter and receiver. Synchronization is achieved using the Start Bit and a mutually agreed baud rate.

### UART Idle State

The transmission line remains at logic HIGH (1) when idle. A falling edge from HIGH to LOW indicates the beginning of a new frame.

### Frame Structure (8N1)

A standard UART frame contains:

| Field      | Bits | Description           |
| ---------- | ---- | --------------------- |
| Start Bit  | 1    | Logic LOW (0)         |
| Data Bits  | 8    | LSB transmitted first |
| Parity Bit | 0    | Not used              |
| Stop Bit   | 1    | Logic HIGH (1)        |

Frame Format:

IDLE → START → D0 → D1 → D2 → D3 → D4 → D5 → D6 → D7 → STOP → IDLE

### Baud Rate Generation

Given:

System Clock = 50 MHz

Target Baud Rate = 9600 bps

Required clock cycles per bit:

50,000,000 ÷ 9600 = 5208.33

Integer divider selected:

MAX_COUNT = 5207

Counter Width:

2¹² = 4096 < 5208

2¹³ = 8192 > 5208

Therefore:

WIDTH = 13 bits

This guarantees generation of a single-cycle baud_tick every UART bit period.

---

## Operations Implemented

| Block            | Function                       | Core Logic                      |
| ---------------- | ------------------------------ | ------------------------------- |
| Baud Generator   | Generates baud_tick pulse      | Counter-based frequency divider |
| Start Bit Logic  | Initiates frame transmission   | TX = 0                          |
| Data Shift Logic | Serializes payload             | LSB-first transmission          |
| Stop Bit Logic   | Terminates frame               | TX = 1                          |
| FSM Controller   | Controls transmission sequence | IDLE → START → DATA → STOP      |

---

## Files

| File         | Description                         |
| ------------ | ----------------------------------- |
| uart_tx.v    | UART transmitter RTL implementation |
| baud_gen.v   | Baud rate generator module          |
| uart_tx_tb.v | Self-checking testbench             |
| uart_tx.vcd  | Simulation waveform dump            |
| README.md    | Project documentation               |

---

## Simulation Results

### Terminal Output

## ![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/Terminal_day_21.png?raw=true)

### GTKWave Verification

## ![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/gtk_day_21.png?raw=true)

### Verified Conditions

- Correct baud_tick generation
- Proper start bit insertion
- LSB-first data transmission
- Correct stop bit generation
- FSM state transitions
- Return to idle state after frame completion

All test cases passed successfully.

---

---

## Key Learnings

### Baud Rate Generation

A baud generator converts a high-frequency system clock into accurately timed bit intervals. Divider accuracy directly impacts communication reliability.

### FSM-Based Protocol Design

Communication protocols are naturally modeled using finite state machines. State sequencing ensures deterministic frame generation and timing control.

### Serial Communication Fundamentals

UART demonstrates how parallel processor data is transformed into serialized streams suitable for low-pin-count communication channels.

### Timing-Critical Digital Design

Although conceptually simple, UART transmission requires strict timing adherence. Any baud mismatch or frame violation can cause data corruption at the receiver.

---

Verified with **iverilog** and **GTKWave**.

Part of the **100 Days of VLSI** series.
