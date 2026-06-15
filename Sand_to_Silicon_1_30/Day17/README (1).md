# Day 17 — AXI4 Lite Protocol

## 100 Days of VLSI — Prashik Wankhede

---

## Topic

AXI4 Lite Slave Implementation — VitalGuard ECG Register Map

---

## What Was Built

A complete AXI4 Lite slave with:

- Write path — AW + W + B channels
- Read path — AR + R channels
- 4 ECG configuration registers
- VALID/READY handshake on all channels
- SLVERR response for invalid addresses

---

## VitalGuard Register Map

| Address | Register        | Purpose                    |
| ------- | --------------- | -------------------------- |
| 0x00    | SAMPLE_RATE_REG | ECG sampling frequency     |
| 0x04    | GAIN_REG        | ECG amplifier gain         |
| 0x08    | FILTER_REG      | Low pass filter cutoff     |
| 0x0C    | ALARM_REG       | Heart rate alarm threshold |

---

## AXI4 Lite Channel Summary

| Channel | Direction    | Signals                      |
| ------- | ------------ | ---------------------------- |
| AW      | Master→Slave | AWADDR, AWVALID, AWREADY     |
| W       | Master→Slave | WDATA, WSTRB, WVALID, WREADY |
| B       | Slave→Master | BRESP, BVALID, BREADY        |
| AR      | Master→Slave | ARADDR, ARVALID, ARREADY     |
| R       | Slave→Master | RDATA, RRESP, RVALID, RREADY |

---

## Golden Rule

Transfer completes ONLY when VALID=1 AND READY=1 simultaneously on rising clock edge.
Once VALID is asserted it CANNOT be deasserted until handshake completes.

---

## Files

| File                 | Description         |
| -------------------- | ------------------- |
| axi4_lite_slave.v    | AXI4 Lite Slave RTL |
| axi4_lite_slave_tb.v | Testbench           |
| dump.vcd             | GTKWave waveform    |

---

## Simulation Results

| Test   | Operation | Address | Data | Result                          |
| ------ | --------- | ------- | ---- | ------------------------------- |
| TEST 1 | Write     | 0x00    | 0xA5 | OKAY — bvalid=1, bresp=00       |
| TEST 2 | Read      | 0x00    | 0xA5 | OKAY — rvalid=1, rdata=000000A5 |

Write value = Read value = 0xA5 ✅

Waveform as followed:
![Image Alt]([https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Day17.png?raw=true](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/Day17.png?raw=true)



---

## Tool Flow

```
iverilog -o axi4.sim axi4_lite_slave.v axi4_lite_slave_tb.v
vvp axi4.sim
gtkwave dump.vcd
```

---

## Capstone Connection — VitalGuard

This AXI4 Lite slave is the configuration interface for the VitalGuard ECG SoC.
The ARM Cortex-M processor writes ECG parameters via AXI4 Lite.
The DSP core reads these registers to configure sampling rate, gain, and alarm thresholds.

---

## Key Learnings

1. AXI4 Lite has 5 independent channels — each with its own handshake
2. VALID cannot be deasserted before handshake completes — ARM protocol rule
3. Write needs 3 channels. Read needs 2 channels.
4. BRESP and RRESP — 2'b00=OKAY, 2'b10=SLVERR
5. Non-blocking assignments require careful timing in testbench

---

## Interview Question — Qualcomm

**Q: Can master deassert AWVALID before handshake completes?**

No. This violates ARM AXI4 protocol. Once AWVALID is asserted it must remain high until AWREADY goes high. Deasserting early causes data corruption — slave may have partially latched the address. Production slaves use protocol checkers and AXI VIP to catch this violation immediately with fatal assertion errors.

---

_Day 17/100 Complete — Phase 1 — Module 2_
