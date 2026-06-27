# Day 27 — APB Bus | VitalGuard SoC

**Engineer** : Prashik Wankhede  
**GitHub** : github.com/prashik-vlsi/100_Days_of_VLSI  
**Project** : VitalGuard — ECG Signal Processor SoC  
**Tapeout** : 1 September 2025

---

## What Was Built

A complete **AMBA APB (Advanced Peripheral Bus)** implementation from scratch — Master, Slave, and Testbench — verified in simulation with GTKWave waveform analysis.

This is the internal peripheral bus for **VitalGuard SoC**, connecting the processor to the ECG timer, UART controller, and sensor configuration registers.

---

## Module Specifications

### APB Slave — `apb_slave.v`

| Parameter  | Default | Description       |
| ---------- | ------- | ----------------- |
| ADDR_WIDTH | 32      | Address bus width |
| DATA_WIDTH | 32      | Data bus width    |

| Port    | Direction | Width      | Description                  |
| ------- | --------- | ---------- | ---------------------------- |
| clk     | input     | 1          | System clock                 |
| rst_n   | input     | 1          | Async active-low reset       |
| psel    | input     | 1          | Peripheral select            |
| penable | input     | 1          | Access phase enable strobe   |
| pwrite  | input     | 1          | 1=Write 0=Read               |
| paddr   | input     | ADDR_WIDTH | Register address             |
| pwdata  | input     | DATA_WIDTH | Write data from master       |
| prdata  | output    | DATA_WIDTH | Read data returned to master |
| pready  | output    | 1          | Transaction complete ACK     |

**Register Map — VitalGuard ECG Timer**

| Address | Register   | Description              |
| ------- | ---------- | ------------------------ |
| 0x00    | load_value | ECG sampling interval    |
| 0x04    | control    | Start/stop timer command |
| 0x08    | status     | Timer done flag          |

---

### APB Master — `apb_master.v`

| Parameter  | Default | Description       |
| ---------- | ------- | ----------------- |
| ADDR_WIDTH | 32      | Address bus width |
| DATA_WIDTH | 32      | Data bus width    |

| Port     | Direction | Width      | Description                     |
| -------- | --------- | ---------- | ------------------------------- |
| clk      | input     | 1          | System clock                    |
| rst_n    | input     | 1          | Async active-low reset          |
| start    | input     | 1          | Pulse high to begin transaction |
| wr_en    | input     | 1          | 1=Write 0=Read                  |
| addr_in  | input     | ADDR_WIDTH | Target register address         |
| data_in  | input     | DATA_WIDTH | Data to write                   |
| data_out | output    | DATA_WIDTH | Data received on read           |
| done_out | output    | 1          | Transaction complete flag       |
| psel     | output    | 1          | APB select to slave             |
| penable  | output    | 1          | APB enable to slave             |
| pwrite   | output    | 1          | APB direction to slave          |
| paddr    | output    | ADDR_WIDTH | APB address to slave            |
| pwdata   | output    | DATA_WIDTH | APB write data to slave         |
| prdata   | input     | DATA_WIDTH | APB read data from slave        |
| pready   | input     | 1          | APB ready from slave            |

**FSM State Machine**

```
IDLE ──(start)──► SETUP ──────────► ACCESS ──(pready)──► IDLE
 ▲                                     │
 └─────────────────(!pready)───────────┘
```

| State  | psel | penable | Action                     |
| ------ | ---- | ------- | -------------------------- |
| IDLE   | 0    | 0       | Wait for start pulse       |
| SETUP  | 1    | 0       | Drive addr and data on bus |
| ACCESS | 1    | 1       | Wait for pready from slave |

---

## APB Protocol — Two Phase Handshake

```
CLK     __|‾|_|‾|_|‾|_|‾|_|‾|_
PSEL    ______|‾‾‾‾‾‾‾‾‾‾‾‾‾|___
PENABLE ___________|‾‾‾‾‾‾‾|___
PREADY  _________________|‾|___
        |  IDLE | SETUP | ACCESS |
```

**Setup Phase** — PSEL=1, PENABLE=0  
Master puts address and data on bus. Slave waits.

**Access Phase** — PSEL=1, PENABLE=1  
Slave captures data. Asserts PREADY when done.

---

## Simulation Results — GTKWave Verified

Three complete APB transactions verified:

| Time  | Transaction | Address | Data      | Result                   |
| ----- | ----------- | ------- | --------- | ------------------------ |
| 45ns  | WRITE       | 0x00    | 0x1F4=500 | ECG timer interval set ✓ |
| 115ns | WRITE       | 0x04    | 0x1       | ECG timer started ✓      |
| 175ns | READ        | 0x08    | —         | Status register read ✓   |

**Waveform timing verified:**

- Setup phase identified at 45ns
- Access phase identified at 55ns
- PREADY asserted at 65ns
- done_out asserted at 75ns

---

## Key Concepts Learned

**1. APB Two Phase Protocol**  
Every transaction has Setup phase and Access phase.  
PENABLE distinguishes them.  
Slave never captures data in Setup phase.

**2. Active Low Async Reset**  
`always @(posedge clk or negedge rst_n)`  
Reset responds instantly without waiting for clock edge.  
Wire break or power drop defaults to reset — fail safe.

**3. Register Map Address Decode**  
Case statement on PADDR selects target register.  
PWRITE=1 writes. PWRITE=0 reads.  
Default case prevents undefined behavior.

**4. APB Wait States**  
Slave holds PREADY low when busy.  
Master stays in ACCESS state until PREADY goes high.  
Supports slow peripherals like Flash and EEPROM.

**5. FSM Based Master**  
Three state FSM — IDLE SETUP ACCESS.  
Registered outputs hold stable values across phases.  
done_out signals core when transaction is complete.

---

## VitalGuard SoC Context

APB Bus is the internal backbone of VitalGuard SoC.  
Processor uses APB to configure all peripherals.

```
Processor
    │
    ├── APB Bus ──────────────────────────┐
    │                                     │
    ├── 0x000 — ECG Timer (this module)  │
    ├── 0x100 — UART Controller          │
    ├── 0x200 — GPIO                     │
    └── 0x300 — ECG Sampler             │
```

Day 27 result — Processor can now configure ECG sampling interval via software register write.  
VitalGuard is now software configurable.

---

## Tools Used

| Tool     | Purpose           |
| -------- | ----------------- |
| GVim     | RTL coding        |
| iverilog | Compilation       |
| vvp      | Simulation        |
| GTKWave  | Waveform analysis |
| Xschem   | Schematic         |

---

## OUTPUT IMAGES

**TERMINAL OUTPUT**
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/terminalday27.png?raw=true)

**WAVEFORM OUTPUT**

![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/wavefromday27.png?raw=true)

## Interview Questions This Day Covers

**Q1 — Explain APB two phase protocol.**  
Setup phase — PSEL=1 PENABLE=0. Master drives address and data.  
Access phase — PSEL=1 PENABLE=1. Slave captures data and asserts PREADY.

**Q2 — What is PREADY used for?**  
PREADY is slave acknowledgement. Slave holds it low to insert wait states for slow peripherals. Master stays in ACCESS until PREADY goes high.

**Q3 — Why active low reset in SoC design?**  
When power drops or wire breaks signal defaults to 0. Active low treats 0 as reset making system fail safe.

**Q4 — What is a register map?**  
Each peripheral register gets a unique address. Processor writes to that address via APB to configure the peripheral. Slave decodes address using case statement.

**Q5 — Difference between APB and AXI?**  
APB — simple low power bus for slow peripherals. One transaction at a time. No burst. Used for timers UART GPIO.  
AXI — high bandwidth bus for memory and fast peripherals. Supports burst pipelining out of order transactions.

---

_Day 27 of 100 Days of VLSI — Prashik Wankhede_  
_VitalGuard SoC — Tapeout September 2025_
