# Day 12 — Synchronous FIFO

### 100 Days of VLSI — Prashik Wankhede

---

## Overview

A **Synchronous FIFO (First In First Out)** buffer implemented in Verilog.  
Single clock domain. 8-bit data width. 16-location depth.  
Capstone connection: **VitalGuard ECG SoC** — ECG sample buffer between ADC and DSP filter block.

---

## Module: `sync_fifo.v`

### Parameters

| Parameter  | Value | Description              |
| ---------- | ----- | ------------------------ |
| data_width | 8     | Width of each data word  |
| depth      | 16    | Number of FIFO locations |

### Port List

| Signal  | Direction | Width | Description       |
| ------- | --------- | ----- | ----------------- |
| clk     | input     | 1-bit | Clock             |
| rst     | input     | 1-bit | Synchronous reset |
| wr_en   | input     | 1-bit | Write enable      |
| rd_en   | input     | 1-bit | Read enable       |
| wr_data | input     | 8-bit | Data input        |
| rd_data | output    | 8-bit | Data output       |
| full    | output    | 1-bit | FIFO full flag    |
| empty   | output    | 1-bit | FIFO empty flag   |

---

## Key Concepts Learned

### 1. Pointer Structure

- Both `wr_ptr` and `rd_ptr` are **5 bits wide** for a depth-16 FIFO
- Bottom 4 bits = memory address
- Top 1 bit = wrap/overflow bit

```
pointer = [ wrap_bit | addr_3 | addr_2 | addr_1 | addr_0 ]
              bit4      bit3    bit2     bit1     bit0
```

### 2. FULL and EMPTY Conditions

```verilog
assign empty = (wr_ptr == rd_ptr);
assign full  = (wr_ptr[4] != rd_ptr[4]) && (wr_ptr[3:0] == rd_ptr[3:0]);
```

| Condition | Meaning                                      |
| --------- | -------------------------------------------- |
| EMPTY     | All 5 bits equal — pointers never separated  |
| FULL      | Wrap bits differ — wr_ptr lapped rd_ptr once |

### 3. Valid Write and Read Conditions

```verilog
assign wr_valid = wr_en && !full;
assign rd_valid = rd_en && !empty;
```

### 4. Pointer Increment Logic

```verilog
// Write pointer
always @(posedge clk) begin
    if (rst)
        wr_ptr <= 5'b00000;
    else if (wr_en && !full)
        wr_ptr <= wr_ptr + 5'b00001;
end

// Read pointer
always @(posedge clk) begin
    if (rst)
        rd_ptr <= 5'b00000;
    else if (rd_en && !empty)
        rd_ptr <= rd_ptr + 5'b00001;
end
```

### 5. Memory Read and Write

```verilog
// Continuous read — rd_data always reflects current rd_ptr location
assign rd_data = mem[rd_ptr[3:0]];

// Clocked write — data latched on posedge when write is valid
always @(posedge clk) begin
    if (wr_en && !full)
        mem[wr_ptr[3:0]] <= wr_data;
end
```

---

## Simulation Results

**Tool:** iverilog + GTKWave  
**Testbench:** `sync_fifo_tb.v`

### Test Sequence

- Reset applied for 20ns
- 5 ECG samples written: `A1, A2, A3, A4, A5`
- 5 ECG samples read back in order

### Verified Behavior

| Check                            | Result  |
| -------------------------------- | ------- |
| EMPTY asserted at reset          | ✅ PASS |
| EMPTY deasserted after write     | ✅ PASS |
| All 5 samples written correctly  | ✅ PASS |
| All 5 samples read in order      | ✅ PASS |
| EMPTY reasserted after all reads | ✅ PASS |
| FULL flag logic verified         | ✅ PASS |

### Key Debug Lesson — Testbench Setup Time

- Driving `wr_data` and `@(posedge clk)` at the same time causes setup time violations
- Fix: drive data on `@(negedge clk)` so it is stable before the next posedge

---

## Capstone Connection — VitalGuard ECG SoC

```
ECG Analog Front End
        │
        ▼
   ADC (500 Hz sampling)
        │
        ▼
  ┌─────────────┐
  │  SYNC FIFO  │  ← This module
  │  8-bit x 16 │
  └─────────────┘
        │
        ▼
  DSP / Filter Block
```

The FIFO buffers ECG samples between the ADC and the DSP filter.  
Without this buffer, samples are lost when the DSP is busy — in a cardiac monitor, lost samples = missed arrhythmia.

---

**Compare the extra MSB pointer bit approach vs counter-based approach for FULL/EMPTY detection.**

| Aspect          | MSB Pointer Bit       | Counter Based                     |
| --------------- | --------------------- | --------------------------------- |
| Hardware cost   | Minimal — 1 extra bit | Extra counter register + logic    |
| Debuggability   | Less intuitive        | Direct occupancy visibility       |
| Timing path     | Simple comparison     | Counter on critical path          |
| Simultaneous RW | Handled naturally     | Count holds — needs careful logic |
| Best use case   | Area-critical designs | Status monitoring + flow control  |

---

## Files

| File             | Description        |
| ---------------- | ------------------ |
| `sync_fifo.v`    | RTL implementation |
| `sync_fifo_tb.v` | Testbench          |

---

## Commit Message

```
Day 12: Synchronous FIFO - RTL + Testbench + Simulation Complete
- Implemented 8-bit wide, 16-deep synchronous FIFO
- Extra MSB pointer bit for FULL/EMPTY detection
- Verified all 5 ECG samples A1-A5 written and read correctly
- Capstone: VitalGuard ECG sample buffer
```

---

_100 Days of VLSI — github.com/prashik-vlsi/100_Days_of_VLSI_
