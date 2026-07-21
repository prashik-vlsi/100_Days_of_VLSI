# Read SKY130 timing library
read_liberty /media/prashik-wankhede/SKY130_PDK/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Read synthesized netlist
read_verilog design_synth.v

# Set top module
link_design my_design

# Read timing constraints
read_sdc constraints.sdc

# Report clocks
report_clock_skew

# Setup timing
report_checks -path_delay max -format full_clock_expanded

# Hold timing
report_checks -path_delay min -format full_clock_expanded

# Report worst setup paths
report_checks -path_delay max -group_count 10

# Report worst hold paths
report_checks -path_delay min -group_count 10
