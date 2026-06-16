# Day 19 — Barrel Shifter

## Topic
Parameterized Barrel Shifter — Logical Shift Left, Logical Shift Right,
Arithmetic Shift Right, Rotate Left, Rotate Right

## Theory
A barrel shifter is a purely combinational circuit that shifts or rotates
an N-bit input by any number of positions in a single clock cycle using
cascaded MUX stages. No sequential logic. No clock required.

For an 8-bit shifter with 3-bit shift amount, log2(8) = 3 MUX stages are
required. Each stage doubles the shift amount: shift by 1, shift by 2,
shift by 4.

Key distinction:
- LSR: vacated MSBs filled with 0 (unsigned numbers)
- ASR: vacated MSBs filled with sign bit in[WIDTH-1] (signed numbers)
- ROL/ROR: no bits lost, wrap-around using concatenation trick

## Operations Implemented

| Mode | Operation | Expression                        |
|------|-----------|-----------------------------------|
| 000  | LSL       | in << shamt                       |
| 001  | LSR       | in >> shamt                       |
| 010  | ASR       | $signed(in) >>> shamt             |
| 011  | ROL       | {in,in} << shamt [2*WIDTH-1:WIDTH]|
| 100  | ROR       | {in,in} >> shamt [WIDTH-1:0]      |

## Files
- `barrel_shifter.v`    — Parameterized RTL module
- `barrel_shifter_tb.v` — Testbench with 5 test cases
- `barrel.vcd`          — Simulation waveform dump

## Simulation Results
**Terminal output as shown**
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/Barrel_shifter_terminal_output.png?raw=true)

**WAVEFORM OUTPUT as shown**

![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/Barrel_shifter_waveform.png?raw=true)

All 5 test cases passed. Verified with iverilog and GTKWave.

## Capstone Connection
- **NeuralEdge**: Barrel shifter used in data alignment unit to align
  fixed-point operands before MAC operations in one cycle.
- **VitalGuard**: ASR used in ECG signal preprocessor to scale signed
  ADC samples without corrupting the two's complement sign bit.

## Key Learnings
1. Barrel shifter is combinational — single cycle, no clock
2. ASR vs LSR: wrong operator on signed ECG data causes patient safety bug
3. $signed() is a type cast — zero gates added to netlist, changes MSB
   routing in synthesizer from ground to sign bit replication
4. ROL/ROR implemented using concatenation trick: {in,in} shift + bit select
5. iverilog does not support part-select on expression result directly —
   intermediate wire required
