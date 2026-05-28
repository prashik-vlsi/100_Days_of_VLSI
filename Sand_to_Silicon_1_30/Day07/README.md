# Day 7- Shift Registers and Counters

## Modules Completed
| Module | File | Status |
|--------|------|--------|
| SIPO Shift Register | sipo.v | ✅ Verified |
| PISO Shift Register | piso.v | ✅ Verified |
| 4-bit Ripple Counter | ripple_counter.v | ✅ Verified |
| 4-bit Synchronous Counter | sync_counter.v | ✅ Verified |

## Key Concepts
- **Ripple Counter**: T FF with T=1 cascaded. Each stage divides clock by 2. Weakness: cascaded tCQ delay, not scalable.
- **Synchronous Counter**: All FFs clocked by same CLK. Toggle controlled by carry logic.
  - T0 = 1
  - T1 = Q0
  - T2 = Q1 & Q0
  - T3 = Q2 & Q1 & Q0

## Tools
- Simulator: iverilog
- Waveform: gtkwave
- OS: Ubuntu

## Waveforms
- rc.vcd — Ripple Counter
- sync.vcd — Synchronous Counter
- sipo.vcd
- pipo.vcd