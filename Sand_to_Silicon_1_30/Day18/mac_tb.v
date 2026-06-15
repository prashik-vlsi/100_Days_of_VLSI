`timescale 1ns / 1ps

module tb_mac;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] A;
    reg [31:0] B;

    // Outputs
    wire [63:0] accum;

    // Instance Under Test (UUT)
    mac uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .accum(accum)
    );

    // Clock Generation (50 MHz -> 20ns period)
    always #10 clk = ~clk;

    initial begin
        // GTKWave VCD Dump Configuration
        $dumpfile("tb_mac.vcd");
        $dumpvars(0, tb_mac);

        // Terminal Output Monitor
        $monitor("Time=%0dt | rst=%b | A=%d, B=%d | Accum=%d", $time, rst, A, B, accum);
        
        // Initialize Inputs
        clk = 0;
        rst = 1;
        A = 0;
        B = 0;
        #20; // Hold reset for 1 clock cycle
        
        rst = 0; // Release reset
        #5;      // Small offset from clock edge
        
        // Test Case 1: 5 * 4 = 20 (Accum should be 20)
        A = 32'd5; B = 32'd4;
        #20;
        
        // Test Case 2: 2 * 3 = 6 (Accum should be 20 + 6 = 26)
        A = 32'd2; B = 32'd3;
        #20;
        
        // Test Case 3: 10 * 10 = 100 (Accum should be 26 + 100 = 126)
        A = 32'd10; B = 32'd10;
        #20;

        $display("--- MAC Testbench Simulation Completed ---");
        $finish;
    end

endmodule