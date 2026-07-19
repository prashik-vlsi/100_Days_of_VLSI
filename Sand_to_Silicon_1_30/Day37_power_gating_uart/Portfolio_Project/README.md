# UART with Power Gating — RTL-to-GDSII ASIC Implementation

A complete end-to-end ASIC design flow implementation using open-source tools and the SKY130 Process Design Kit.

## Project Overview

This project demonstrates a complete RTL-to-GDSII flow for a UART (Universal Asynchronous Receiver Transmitter) IP core with integrated power gating functionality. The design progresses through all major ASIC design stages: RTL design, functional verification, logic synthesis, physical design (floorplanning, placement, clock tree synthesis, routing), and signoff verification.

**Key Technologies:**
- Verilog RTL design
- Yosys logic synthesis
- OpenSTA static timing analysis
- OpenLane RTL-to-GDS automation
- SKY130 open process design kit
- Docker containerization
- Linux (Ubuntu) development environment
- KLayout layout visualization

## Objectives

1. Execute a complete RTL-to-GDSII design flow using open-source tools
2. Understand the purpose and function of each design stage
3. Learn how decisions in each domain propagate through subsequent stages
4. Gain practical proficiency with industry-standard open-source design tools
5. Create production-ready design outputs (GDSII, DEF, LEF, reports)
6. Document the complete journey from RTL through fabrication-ready layout

## What Was Implemented

### Design Components
- **UART Transmitter**: Serializes parallel data into asynchronous serial stream
- **UART Receiver**: Deserializes incoming serial data into parallel form
- **Baud Rate Generator**: Provides timing signals for serial communication
- **Power Gating Logic**: Enables power domain isolation for low-power operation

### Design Outputs
- Gate-level netlist (Verilog)
- Final DEF (Design Exchange Format) file
- Final LEF (Library Exchange Format) file
- Final GDSII (Graphic Data Stream) file
- Synthesis reports (gate count, timing estimates)
- Static timing analysis reports (slack, critical paths)
- Physical design reports (utilization, congestion, placement metrics)
- DRC and LVS verification reports
- Layout visualization (KLayout)

## Project Structure

```
uart-rtl-to-gdsii/
├── README.md                 # This file
├── designs/
│   └── uart/
│       ├── src/             # Verilog source files
│       │   ├── uart.v       # Top-level UART module
│       │   ├── tx.v         # Transmitter module
│       │   ├── rx.v         # Receiver module
│       │   ├── baud_gen.v   # Baud rate generator
│       │   └── power_gate.v # Power gating control
│       ├── sim/             # Simulation testbenches
│       │   └── tb_uart.v    # UART testbench
│       └── config.tcl       # OpenLane configuration file
├── outputs/
│   ├── synthesis/           # Yosys synthesis results
│   ├── floorplan/          # Floorplanning files
│   ├── placement/          # Placement results
│   ├── cts/                # Clock tree synthesis results
│   ├── routing/            # Routing results
│   ├── signoff/            # DRC, LVS, timing reports
│   ├── final_gdsii/        # Final GDSII file
│   └── reports/            # All analysis reports
└── tools/                   # Tool setup and scripts
    └── docker-compose.yml   # OpenLane Docker configuration
```

## Getting Started

### Prerequisites
- Docker installed and configured
- Linux/Ubuntu environment (or WSL2 on Windows)
- ~50GB free disk space (for OpenLane, tools, and PDK)
- Adequate RAM (16GB+ recommended)

### Setup Instructions

**1. Install Docker**
```bash
sudo apt-get update
sudo apt-get install docker.io
sudo usermod -aG docker $USER
newgrp docker
```

**2. Pull OpenLane Docker Image**
```bash
docker pull efabless/openlane:latest
```

**3. Clone or Download SKY130 PDK**
```bash
# OpenLane can download SKY130 PDK automatically, or:
git clone https://github.com/google/skywater-pdk.git
```

**4. Prepare Design Directory**
```bash
mkdir -p uart-rtl-to-gdsii/designs/uart/src
cd uart-rtl-to-gdsii
```

**5. Place Verilog Files**
Copy your UART RTL files (uart.v, tx.v, rx.v, baud_gen.v, power_gate.v) to `designs/uart/src/`

**6. Configure OpenLane**
Create `designs/uart/config.tcl` with synthesis constraints and physical design parameters:
```tcl
set ::env(DESIGN_NAME) "uart"
set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/src/*.v"
set ::env(CLOCK_PERIOD) "10"
set ::env(CLOCK_PORT) "clk"
set ::env(FP_SIZING) "relative"
set ::env(FP_CORE_UTIL) "40"
```

**7. Run OpenLane Flow**
```bash
# Interactive mode (for troubleshooting)
docker run -it -v $(pwd):/work efabless/openlane:latest bash
# Inside container:
cd /work/designs/uart
flow.tcl -design . -tag run_001

# Or non-interactive mode
docker run -v $(pwd):/work efabless/openlane:latest \
  flow.tcl -design /work/designs/uart -tag run_001
```

## Design Flow Stages

### 1. Functional Verification
```bash
# Using Icarus Verilog or similar simulator
iverilog -o tb_uart designs/uart/sim/tb_uart.v designs/uart/src/*.v
vvp tb_uart
```
Verifies that RTL correctly implements UART protocol behavior.

### 2. Logic Synthesis (Yosys)
Transforms RTL into gate-level netlist using SKY130 standard cells.
- Input: Verilog RTL
- Output: Gate-level netlist, preliminary timing estimates
- Key metrics: Gate count, register count, estimated slack

### 3. Floorplanning
Establishes die area, core region, and placement constraints.
- Balances area utilization against routing feasibility
- Affects downstream congestion and timing closure

### 4. Placement
Assigns cells to specific geometric locations on chip.
- Optimizes wirelength and congestion
- Impacts routing success and timing performance

### 5. Clock Tree Synthesis (CTS)
Creates clock distribution network with balanced delays and minimal skew.
- Ensures predictable clock arrival times
- Critical for timing closure

### 6. Routing
Establishes geometric wire connections between placed cells.
- Routes all signal nets while respecting design rules
- Determines actual interconnect delays

### 7. Signoff Verification
Performs final quality checks before fabrication.
- **DRC (Design Rule Check)**: Verifies manufacturability
- **LVS (Layout Versus Schematic)**: Verifies correctness
- **STA (Static Timing Analysis)**: Verifies timing requirements met

## Understanding the Outputs

### Key Output Files

**GDSII File** (`*.gds` or `*.gdsii`)
- Binary format containing complete geometric layout
- Ready for photomask generation and fabrication
- Can be viewed in KLayout

**DEF File** (`*.def`)
- Text format with cell placements and routing information
- Useful for design analysis and handoff

**LEF File** (`*.lef`)
- Standard cell library information
- Physical properties, pins, blockages

**Synthesis Report** (`*.rpt`)
- Gate-level implementation details
- Cell instantiation counts
- Estimated timing

**Timing Report** (`timing.rpt`)
- All timing paths and slack values
- Critical paths identified
- Setup/hold violations (if any)

**Physical Design Report** (`*.rpt`)
- Die area, core area, utilization
- Cell counts, wirelength statistics
- Routing congestion metrics

### Viewing Results
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/uart_power_gating_.png?raw=true)
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/uart_terminal_power_gating.png?raw=true)
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/uart_power_gating.png?raw=true)
![Image Alt](https://github.com/prashik-vlsi/100_Days_of_VLSI/blob/main/Wavefrom_images/k_layout_power.png?raw=true)

## Key Design Decisions

### Clock Constraint
- 10ns clock period (100 MHz) — chosen as reasonable target for SKY130
- Relaxed to allow sufficient margin without over-constraining

### Utilization Target
- 40% core utilization — balances area efficiency with routing feasibility
- Higher utilization (>70%) risks routing failures
- Lower utilization (<30%) wastes silicon area

### Floorplan Dimensions
- Determined by synthesized cell area and utilization target
- Includes margin for power delivery and routing tracks

### Power Gating Implementation
- Isolation cells used for domain crossing
- Level shifters for clock signals crossing power domains
- Minimal overhead for control logic

## Challenges and Solutions

| Challenge | Solution |
|-----------|----------|
| Docker permission issues | Configure volume mounts with proper ownership; use `docker exec` with user context |
| OpenLane directory confusion | Read documentation carefully; understand input/output locations before starting |
| SKY130 PDK not found | Ensure Docker volume mount includes PDK; verify `PDK_PATH` environment variable |
| Synthesis timing violations | Relax constraints; increase clock period; review RTL for unnecessary delays |
| Routing failures | Reduce utilization target; increase core margin; review floorplan locality |
| Clock skew issues | Adjust CTS parameters; review clock tree balance in reports |
| DRC violations | Review design rules in PDK; check minimum spacing/width for violated geometries |
| Long flow execution time | Use background execution; monitor progress through logs; consider overnight runs |

## Lessons Learned

### Understanding ASIC Design Flow
The complete flow reveals how each stage's decisions cascade:
- RTL implementation affects synthesis success
- Synthesis results affect placement feasibility  
- Placement affects routing difficulty
- Routing affects timing closure
- Each stage's quality affects downstream feasibility

### Physical Design Tradeoffs
Design optimization involves competing objectives:
- Area vs. routing difficulty (utilization)
- Power consumption vs. performance (clock frequency)
- Layout complexity vs. timing margins

### Tool Automation Value
OpenLane automates routine tasks but understanding underlying mechanics remains crucial:
- Know what each tool does
- Understand parameter relationships
- Interpret reports to identify problems

### Iterative Nature of Design
No design succeeds on first attempt:
- Flow execution identifies problems
- Reports guide targeted improvements
- Multiple iterations necessary for closure
- Patience and systematic debugging essential

### Open-Source Tools Maturity
Open-source design tools are production-capable:
- OpenLane achieves tape-out quality results
- Yosys produces efficient gate-level implementations
- OpenSTA provides accurate timing analysis
- Open PDKs enable complete design flows

## What Was NOT Done

This project intentionally focuses on core RTL-to-GDSII flow. Not included:

- Timing optimization or closure tuning
- Manual floorplan/placement optimization
- Multi-corner STA (worst-case, best-case corners)
- Power analysis or IR drop analysis
- Electromigration analysis
- Scan insertion for DFT
- ATPG (Automatic Test Pattern Generation)
- Clock gating optimization
- Physical verification debugging
- Silicon tape-out or fabrication
- Silicon validation testing

These represent advanced topics beyond learning objectives.

## References

- [OpenLane Documentation](https://openlane.readthedocs.io/)
- [Yosys Open SYnthesis Suite](http://www.clifford.at/yosys/)
- [OpenSTA - Open Source Static Timing Analyzer](https://github.com/The-OpenROAD-Project/OpenSTA)
- [KLayout - Layout Viewer and Editor](https://www.klayout.de/)
- [SkyWater SKY130 PDK](https://skywater.readthedocs.io/)
- [Docker Documentation](https://docs.docker.com/)
- [IEEE Std 1364-2005 - Verilog HDL](https://standards.ieee.org/)

## Useful Commands

```bash
# Docker - Run interactive OpenLane session
docker run -it -v $(pwd):/work efabless/openlane:latest bash

# Inside Docker container
cd /work/designs/uart
flow.tcl -design . -tag run_001          # Full flow
flow.tcl -design . -interactive          # Interactive mode

# View synthesis results
cat logs/synthesis/*.log

# Check timing
cat logs/synthesis/*/timing_summary.txt

# View final layout
klayout results/final/uart.gds

# Examine GDSII info
gds2oas results/final/uart.gds temp.oas  # Convert to OAS format
```

## Project Status

✅ **Completed**
- RTL design and verification
- Logic synthesis
- Static timing analysis
- Complete physical design
- Signoff verification
- Final GDSII generation

## Contributing

This is a learning project. Improvements welcome:
- Enhanced RTL design (e.g., FIFO buffers, interrupt support)
- Additional power gating domains
- Performance optimizations
- Documentation improvements

## Author Notes

This project represents a complete hands-on learning experience with modern ASIC design. Each stage in the flow presents unique challenges and learning opportunities. Understanding how tools and methodologies work together to transform RTL into silicon-ready layouts provides invaluable insight into digital design practice.

The open-source nature of the tools and PDK makes this flow accessible to anyone with a computer and internet connection—democratizing access to semiconductor design knowledge previously available only within large companies.

---

**Last Updated**: July 2026  
**Tools Version**: OpenLane (latest), Yosys, OpenSTA, SKY130 PDK  
**Status**: Production-ready flow, design successfully completed through signoff
