100 Days of VLSI — Sand to Silicon

From logic gates to silicon — a structured, simulation-driven VLSI design and verification journey.


PRASHIK WANKHEDE · VLSI ENGINEER IN PROGRESS
B.E. Electronics and Telecommunication · Maharashtra, India
CGPA: 8.6 · Ubuntu · iverilog · gtkwave · VS Code
Targeting: Nvidia Qualcomm AMD Intel Tessolve eInfochips eChipHub NIELIT
🔗 github.com/prashik-vlsi/100_Days_of_VLSI

Objective
To build industry-grade competency in RTL design, digital verification, and VLSI fundamentals through 100 days of rigorous daily practice — one module designed, simulated, and verified every single day.

Overall Progress
█░░░░░░░░░░░░░░░░░░░  10 / 100 days complete

Progress Tracker
DayModuleConcepts CoveredStatus01CMOS InverterPMOS, NMOS, static characteristics✅02Logic GatesAND, OR, NOT, NAND, NOR, XOR, XNOR✅03AddersHalf adder, Full adder, Ripple carry adder✅04Comparator · MUX · DEMUXBehavioral and structural modeling✅05Subtractor · Encoder · Decoder · Priority EncoderCombined combinational design✅06SR Latch · D LatchLevel-sensitive sequential circuits✅07D FF · JK FF · SIPO · PISO · Ripple Counter · Sync CounterEdge-triggered FFs, shift registers, counters✅08Johnson Counter · Ring CounterFeedback counters, lockup states, 2N vs N states✅09Moore FSMSequence detector, state diagram, output on state only✅10Mealy FSM — 1011 Sequence DetectorState+input output, overlapping detection, suffix-prefix matching✅

Environment
ToolPurposeiverilogVerilog compilation and simulationgtkwaveWaveform analysis and verificationVS CodeRTL coding and editingUbuntu 22.04Development environmentGit · GitHubVersion control and documentation

Concepts Mastered

CMOS static and dynamic behavior — PMOS, NMOS, switching characteristics
Combinational circuit design — behavioral and structural modeling styles
Latch vs Flip-Flop — level-sensitive vs edge-triggered, setup and hold awareness
Shift register architectures — SIPO, PISO, serial and parallel data paths
Counter design — ripple vs synchronous, propagation delay analysis
Johnson Counter — 2N states, complement feedback, filling and draining phases
Ring Counter — N states, direct feedback, lockup state awareness
Moore FSM — output depends on state only, extra state required for detection
Mealy FSM — output depends on state + input, faster response, fewer states
Sequence detector — overlapping detection, suffix-prefix matching, full state derivation
Testbench writing — VCD dump, $monitor, clock generation, waveform verification in gtkwave
RTL vs gate-level simulation — zero delay vs SDF-annotated timing


Repository Structure
100_Days_of_VLSI/
└── Sand_to_Silicon_1_30/
    ├── Day01_CMOS_Inverter/
    ├── Day02_Logic_Gates/
    ├── Day03_Adders/
    ├── Day04_Comparator_MUX_DEMUX/
    ├── Day05_Subtractor_Encoder_Decoder/
    ├── Day06_SR_D_Latch/
    ├── Day07_FF_ShiftReg_Counters/
    ├── Day08_Johnson_Ring_Counter/
    ├── Day09_Moore_FSM/
    └── Day10_Mealy_FSM_1011_Sequence_Detector/
        ├── mealy_1011.v
        ├── tb_mealy.v
        └── mealy.vcd

Latest Commit
bashgit commit -m "Day10_Mealy_FSM_1011_Sequence_Detector:
  state derivation · Verilog · testbench · simulation verified"

Daily Commitment

Minimum one module designed, simulated, and verified per day
Every module pushed to GitHub with testbench and waveform
Interview-grade understanding — not just working code
Concepts explained, traced, and defended as in a real technical interview


What Real Chip Engineers Use This For

The Mealy FSM built on Day 10 lives inside every UART receiver, USB controller, I2C handshake engine, and PCIe transaction layer on the planet. Every protocol you have ever used has a Mealy machine at its core.

ModuleWhere it lives in siliconMealy FSMUART start bit detector · Qualcomm modem handshake · Nvidia command parserMoore FSMTraffic light controller · vending machine · protocol state machinesCountersClock dividers · PWM generators · address sequencers in SRAMShift RegistersSerial-to-parallel conversion · JTAG scan chains · SPI interfaces

This repository is a living document. Updated daily.
Simulation-driven. Interview-grade. Sand to Silicon.
