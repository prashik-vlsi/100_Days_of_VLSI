#!/usr/bin/env sta

# Read Liberty timing library
read_liberty /root/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Read synthesized netlist
read_verilog design_netlist.v

# Replace with your actual top module name
link_design mux4_1

puts "\n========================================"
puts "      COMBINATIONAL STA REPORT"
puts "========================================\n"

# Report maximum-delay paths
puts "\n--- Maximum Delay Paths ---\n"
report_checks -path_delay max -digits 3

# Report minimum-delay paths
puts "\n--- Minimum Delay Paths ---\n"
report_checks -path_delay min -digits 3

puts "\n========================================"
puts "          END OF REPORT"
puts "========================================\n"

exit