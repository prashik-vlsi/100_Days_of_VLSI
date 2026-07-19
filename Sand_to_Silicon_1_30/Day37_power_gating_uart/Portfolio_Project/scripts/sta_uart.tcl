#==================================================
# Sky130 UART Power Gating STA
#==================================================

# Liberty timing library
read_liberty /home/prashik-wankhede/.ciel/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Synthesized netlist
read_verilog uart_synth.v


# Top module
link_design uart_power_gating_with_idle_timer


# Clock definition
create_clock -name clk -period 3 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.1 [get_clocks clk]


# Input delays
set_input_delay 1 -clock clk [get_ports rst_n]
set_input_delay 1 -clock clk [get_ports sleep]
set_input_delay 1 -clock clk [get_ports tx_start]
set_input_delay 1 -clock clk [get_ports tx_data]


# Output delays
set_output_delay 1 -clock clk [get_ports tx]
set_output_delay 1 -clock clk [get_ports tx_busy]
set_output_delay 1 -clock clk [get_ports sleep_ack]


# Reports
report_clock_properties

report_checks -path_delay max -digits 4

report_wns

report_tns
report_checks -path_delay max > reports/setup_report.txt
report_checks -path_delay min > reports/hold_report.txt
