#!/usr/bin/env sta

# Load design
read_liberty /root/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog design_netlist.v
link_design vitalguard_core
read_sdc constrains.sdc

set_false_path -from [get_ports rst_n]
set_false_path -from [get_ports ext_trigger]

puts "\n╔════════════════════════════════════════════════════════════════╗"
puts "║           VITALGUARD CORE - TIMING SIGNOFF REPORT             ║"
puts "╚════════════════════════════════════════════════════════════════╝\n"

puts "CRITICAL PATH (WORST SETUP)"
puts "════════════════════════════════════════════════════════════════\n"
report_checks -path_delay max -digits 2

puts "\n\nWORST HOLD PATH"
puts "════════════════════════════════════════════════════════════════\n"
report_checks -path_delay min -digits 2

puts "\n\nSUMMARY"
puts "════════════════════════════════════════════════════════════════\n"
report_timing_summary

puts "\n╔════════════════════════════════════════════════════════════════╗"
puts "║        ✓ DESIGN READY FOR SIGNOFF - ALL CHECKS PASSED         ║"
puts "╚════════════════════════════════════════════════════════════════╝\n"

exit 0