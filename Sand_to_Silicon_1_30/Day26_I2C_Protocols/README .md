# Day 26 — I2C Slave Module

## VitalGuard SoC — ECG Signal Processor

**Engineer** : Prashik Wankhede
**Date** : Day 26 of 100 Days of VLSI
**Module** : I2C Slave
**Tools** : iverilog, GTKWave, GVim, Xschem
**Tapeout** : VitalGuard — 1 September 2025

---

## Mission

The AD8232 ECG sensor acts as an I2C slave at address 0x48.
Our I2C Master from Day 25 needed a slave to talk to.
This module simulates the AD8232 behavior on the I2C bus.

---

## Module — i2c_slave.v

### Port List

| Port    | Direction | Width | Description                 |
| ------- | --------- | ----- | --------------------------- |
| clk     | input     | 1     | System clock                |
| rst     | input     | 1     | Active low reset            |
| scl     | input     | 1     | I2C clock from master       |
| sda_in  | input     | 1     | SDA data into slave         |
| sda_out | output    | 1     | SDA data driven by slave    |
| sda_oen | output    | 1     | SDA output enable           |
| addr    | input     | 7     | Slave address (AD8232=0x48) |
| data_in | input     | 8     | ECG data to send to master  |

### Internal Signals

| Signal     | Type | Width | Description                    |
| ---------- | ---- | ----- | ------------------------------ |
| shift_reg  | reg  | 7     | Collects incoming address bits |
| bit_cnt    | reg  | 3     | Counts SCL pulses 0 to 7       |
| state      | reg  | 3     | Current FSM state              |
| scl_prev   | reg  | 1     | Previous SCL for edge detect   |
| sda_prev   | reg  | 1     | Previous SDA for edge detect   |
| rw_bit     | reg  | 1     | 0=write 1=read                 |
| addr_match | wire | 1     | shift_reg == addr              |
| scl_rise   | wire | 1     | SCL rising edge detected       |
| scl_fall   | wire | 1     | SCL falling edge detected      |
| start_det  | wire | 1     | START condition detected       |
| stop_det   | wire | 1     | STOP condition detected        |

---

## FSM — 6 States

```
         start_det
  IDLE ──────────► START ──► ADDR
   ▲                            │
   │                      bit_cnt==7
   │                            │
   │              ◄─────────── ACK
   │           NACK              │
   │                        addr_match
   │                        && rw_bit
   │                            │
   └──── STOP ◄──── DATA ◄──────┘
         stop_det
```

### State Actions

```
IDLE  — Watch for START condition
        sda_oen = 0, sda_out = 1

START — Reset bit_cnt and shift_reg
        Go to ADDR unconditionally

ADDR  — On scl_rise: shift sda_in into shift_reg
        On scl_rise: increment bit_cnt
        At bit_cnt==7: capture rw_bit, go to ACK

ACK   — Reset bit_cnt = 0
        addr_match=1: sda_out=0, sda_oen=1 (ACK)
        addr_match=0: sda_out=1, sda_oen=0 (NACK)
        rw_bit=1: go to DATA
        rw_bit=0: go to IDLE

DATA  — On scl_fall: drive data_in[7-bit_cnt] on SDA
        On scl_rise: increment bit_cnt
        stop_det: go to STOP

STOP  — Release SDA: sda_oen=0, sda_out=1
        Go to IDLE
```

---

## Key Concepts Learned

### 1. ACK vs NACK

- I2C bus has pull-up resistor — SDA HIGH by default
- ACK = slave actively pulls SDA LOW
- NACK = slave releases SDA — pull-up makes it HIGH
- sda_out=0 + sda_oen=1 = ACK
- sda_out=1 + sda_oen=0 = NACK

### 2. SCL Edge Detection

- System clock samples SCL every cycle
- scl_rise = (!scl_prev) && (scl)
- scl_fall = (scl_prev) && (!scl)
- Same technique used for START and STOP detection

### 3. START and STOP Conditions

- START: SDA falls while SCL is HIGH
- STOP: SDA rises while SCL is HIGH
- Normal data changes only when SCL is LOW

### 4. R/W Bit

- 8th bit after 7-bit address
- 0 = master wants to write
- 1 = master wants to read
- AD8232 always read — rw_bit = 1

### 5. MSB First

- I2C transmits MSB first
- data_in[7] sent first
- data_in[7 - bit_cnt] gives correct sequence

---

## Simulation

```bash
# Compile
iverilog -o i2c_sim i2c_slave.v i2c_slave_tb.v

# Simulate
vvp i2c_sim

# Waveform
gtkwave dump.vcd
```

### Expected Output

```
ACK = 0 (expect 0)
DATA bit = 1
DATA bit = 0
DATA bit = 1
DATA bit = 0
DATA bit = 0
DATA bit = 1
DATA bit = 0
DATA bit = 1
DONE
```

### Test Scenario

```
Master calls address : 0x48 (AD8232)
R/W bit              : 1 (READ)
ECG data returned    : 0xA5 = 10100101
```

---

## VitalGuard Connection

```
VitalGuard SoC
│
├── I2C Master (Day 25)
│       │
│       │ SCL, SDA
│       │
├── I2C Slave — this module
│       │
│       └── Simulates AD8232 ECG sensor
│           Address : 0x48
│           Data    : ECG samples
│
└── Tapeout : 1 September 2025
```

---

## Output

**TERMINAL OUTPUT**
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/terminal26.jpeg?raw=true)

**waveform output**
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/waveform_Day_26.png?raw=true)

## Interview Questions

**Q: How does I2C slave acknowledge the master?**
A: After master sends 7-bit address and R/W bit,
slave pulls SDA LOW for one SCL cycle.
This is ACK. Bus has pull-up resistor so
SDA is HIGH by default. Slave must actively
drive LOW to acknowledge.

**Q: How does slave know master is calling it?**
A: Every slave has unique 7-bit address.
Slave collects 7 bits from SDA using shift
register. Compares with own address using
combinational comparator. No chip select
needed — address IS the select.

**Q: What is START condition in I2C?**
A: SDA falls while SCL is HIGH.
Normal data changes only when SCL is LOW.
START is special — violates normal rule
intentionally to signal bus transaction start.

---

_Tier-3 college. 8.6 CGPA. Building real SoCs._
_Portfolio beats degree every time._
