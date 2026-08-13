`timescale 1ns/1ps

module tb_vitalguard_core;

    reg        clk_50mhz;
    reg        rst_n;
    reg        ext_trigger;
    reg [11:0] adc_data_in;
    reg        adc_valid;
    
    wire        adc_clk_out;
    wire [15:0] ecg_filtered_out;
    wire        alarm_flag;

    vitalguard_core uut (
        .clk_50mhz       (clk_50mhz),
        .rst_n           (rst_n),
        .ext_trigger     (ext_trigger),
        .adc_data_in     (adc_data_in),
        .adc_valid       (adc_valid),
        .adc_clk_out     (adc_clk_out),
        .ecg_filtered_out(ecg_filtered_out),
        .alarm_flag      (alarm_flag)
    );

    // 50 MHz Clock -> Period = 20ns
    always #10 clk_50mhz = ~clk_50mhz;

    initial begin
    $dumpfile("gtk.vcd");
    $dumpvars(0, tb_vitalguard_core);
        clk_50mhz   = 0;
        rst_n       = 0;
        ext_trigger = 0;
        adc_data_in = 12'd0;
        adc_valid   = 0;

        #40 rst_n = 1;
        #20 ext_trigger = 1;
        #20 adc_data_in = 12'h7FF;
        
        #500;
        $finish;
    end

endmodule