`timescale 1ns / 1ps

module uart_rx_tb();

    // --- Testbench Signals ---
    reg        clk;
    reg        rst;
    reg        rx;
    wire [15:0] baud_div;
    
    wire [7:0] rx_data;
    wire       rx_done;
    wire       parity_err;
    wire       frame_err;

    // --- Clock & Timing Parameters ---
    localparam CLK_PERIOD = 20;   // 50 MHz clock -> 20ns period
    localparam BIT_PERIOD = 8680; // 115200 Baud rate bit period ≈ 8680 ns
    
    assign baud_div = 16'd27;     // 50 MHz / (115200 * 16) ≈ 27

    // --- Unit Under Test (UUT) Instance ---
    uart_rx uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .baud_div(baud_div),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_err(parity_err),
        .frame_err(frame_err)
    );

    // --- System Clock Generator (50 MHz) ---
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end

    // --- VCD Wave Dumping & Continuous Monitoring ---
    initial begin
        // Setup waveform dump file for GTKWave/EDA tools
        $dumpfile("uart_rx_sim.vcd");
        $dumpvars(0, uart_rx_tb);
        
        // Track state transitions, inputs, and outputs every time they change
        $monitor("Time=%0t ns | rst=%b | rx=%b | state=%0d | tick=%0d | data=8'h%h | done=%b | PE=%b | FE=%b", 
                 $time, rst, rx, uut.state, uut.tick, rx_data, rx_done, parity_err, frame_err);
    end

    // --- Transmission Simulation Tasks ---
    task send_uart_byte(input [7:0] data_byte);
        integer i;
        reg parity_bit;
        begin
            parity_bit = ^data_byte; // Even parity calculation
            
            // 1. START Bit
            rx = 1'b0;
            #(BIT_PERIOD);
            
            // 2. DATA Bits (LSB First)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data_byte[i];
                #(BIT_PERIOD);
            end
            
            // 3. PARITY Bit
            rx = parity_bit;
            #(BIT_PERIOD);
            
            // 4. STOP Bit
            rx = 1'b1;
            #(BIT_PERIOD);
            
            // Idle gap
            #(BIT_PERIOD * 2);
        end
    endtask

    // --- Main Simulation Stimulus ---
    initial begin
        // Initial configuration
        rst = 1'b1;
        rx  = 1'b1;
        #(100);
        
        // Release reset
        @(posedge clk);
        rst = 1'b0;
        #(100);
        
        // TEST CASE 1: Send Valid Byte 0x55
        send_uart_byte(8'h55);
        
        // TEST CASE 2: Simulate Noise Glitch (Line drops low briefly, then returns high)
        rx = 1'b0;
        #(BIT_PERIOD / 4); 
        rx = 1'b1;         
        
        #(BIT_PERIOD * 3);
        
        // End simulation execution
        $finish;
    end

endmodule