#==============================================================
# Project      : UART Transmitter
# Top Module   : uart_tx
# Technology   : SKY130 HD
# Tool         : OpenSTA 3.1.0
#==============================================================


#--------------------------------------------------------------
# 1. Read SKY130 Liberty
#--------------------------------------------------------------

read_liberty /root/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib


#--------------------------------------------------------------
# 2. Read Gate-Level Netlist
#--------------------------------------------------------------

read_verilog design_netlist.v


#--------------------------------------------------------------
# 3. Link Top-Level Design
#--------------------------------------------------------------

link_design uart_tx


#--------------------------------------------------------------
# 4. Create Clock
#
# Clock Frequency = 50 MHz
# Clock Period    = 20 ns
#--------------------------------------------------------------

create_clock \
-name clk \
-period 3.146 \
[get_ports clk]


#--------------------------------------------------------------
# 5. Clock Uncertainty
#--------------------------------------------------------------

set_clock_uncertainty 0.2 [get_clocks clk]


#--------------------------------------------------------------
# 6. Input Delay Constraints
#
# Assume external input signals arrive 2 ns
# after the active clock edge.
#--------------------------------------------------------------

set_input_delay 2.0 \
-clock clk \
[get_ports tx_start]

set_input_delay 2.0 \
-clock clk \
[get_ports {tx_data[*]}]

set_input_delay 2.0 \
-clock clk \
[get_ports rst_n]


#--------------------------------------------------------------
# 7. Output Delay Constraints
#
# Assume external receiving logic requires
# output data to be available within 2 ns.
#--------------------------------------------------------------

set_output_delay 2.0 \
-clock clk \
[get_ports tx]

set_output_delay 2.0 \
-clock clk \
[get_ports tx_busy]




#--------------------------------------------------------------
# 10. Setup Timing Analysis
#--------------------------------------------------------------

puts ""
puts "=============================================="
puts "         SETUP TIMING ANALYSIS"
puts "=============================================="

report_checks \
-path_delay max \
-group_count 10 \
-format full_clock_expanded \
-fields {slew cap input_pin} \
-digits 3


#--------------------------------------------------------------
# 11. Hold Timing Analysis
#--------------------------------------------------------------

puts ""
puts "=============================================="
puts "          HOLD TIMING ANALYSIS"
puts "=============================================="

report_checks \
-path_delay min \
-group_count 10 \
-format full_clock_expanded \
-fields {slew cap input_pin} \
-digits 3


#--------------------------------------------------------------
# 12. Setup Report
#--------------------------------------------------------------

report_checks \
-path_delay max \
-format full_clock_expanded \
-fields {slew cap input_pin} \
-digits 3 \
> setup.rpt


#--------------------------------------------------------------
# 13. Hold Report
#--------------------------------------------------------------

report_checks \
-path_delay min \
-format full_clock_expanded \
-fields {slew cap input_pin} \
-digits 3 \
> hold.rpt


#--------------------------------------------------------------
# 14. Final Timing Summary
#--------------------------------------------------------------

puts ""
puts "=============================================="
puts "          STA ANALYSIS COMPLETED"
puts "=============================================="
puts "Design       : uart_tx"
puts "Clock        : clk"
puts "Clock Period : 20 ns"
puts "Frequency    : 50 MHz"
puts ""
puts "Generated Reports:"
puts "  setup.rpt"
puts "  hold.rpt"
puts "=============================================="