# Day 07 — Shift Registers
## Files
| File | Description |
|------|-------------|
| `sipo.v` | 4-bit Serial In Parallel Out shift register |
| `sipo_tb.v` | SIPO testbench — 1011 verified |
## Key Learning
- Register is a bank of DFFs sharing common clock
- N-bit SIPO needs exactly N clock cycles
- Non-blocking assignment mandatory in shift registers
- First bit in lands at Q[3] after full shift
