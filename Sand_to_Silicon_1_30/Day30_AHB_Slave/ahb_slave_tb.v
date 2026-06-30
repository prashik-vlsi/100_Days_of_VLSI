`timescale 1ns / 1ps
 
module tb_ahb_top;
 
    // -------------------------------------------------------------------------
    // 1. Parameter Declarations
    // -------------------------------------------------------------------------
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10; // 100 MHz Clock
 
    // -------------------------------------------------------------------------
    // 2. Global Control Signals
    // -------------------------------------------------------------------------
    reg HCLK;
    reg HRESETn;
 
    // -------------------------------------------------------------------------
    // 3. Interconnecting AHB Bus Wires
    // -------------------------------------------------------------------------
    wire [31:0] HADDR;
    wire        HWRITE;
    wire [2:0]  HSIZE;
    wire [2:0]  HBURST;
    wire [1:0]  HTRANS;
    wire [3:0]  HPROT;
    wire [31:0] HWDATA;
 
    wire [31:0] HRDATA;
    wire        HREADYOUT;
    wire        HRESP;
 
    wire        HREADY;
    assign HREADY = HREADYOUT;
 
    // -------------------------------------------------------------------------
    // 4. Testbench Stimulus Signals (Direct Inputs to Master)
    // -------------------------------------------------------------------------
    reg         tb_start;
    reg [31:0]  tb_addr_in;
    reg         tb_wr;
    reg         tb_burst_mode;
    reg [31:0]  tb_data_in;
    wire [31:0] tb_rdata_out;
 
    // -------------------------------------------------------------------------
    // 5. Clock & Reset Generation
    // -------------------------------------------------------------------------
    initial begin
        HCLK = 0;
        forever #(CLK_PERIOD/2) HCLK = ~HCLK;
    end
 
    initial begin
        HRESETn = 1'b0;
        #(CLK_PERIOD * 2);
        HRESETn = 1'b1;
    end
 
    // -------------------------------------------------------------------------
    // 6. Module Instantiations
    // -------------------------------------------------------------------------
    ahb_master u_ahb_master (
        .HCLK        (HCLK),
        .HRESETn     (HRESETn),
        .HADDR       (HADDR),
        .HWRITE      (HWRITE),
        .HSIZE       (HSIZE),
        .HBURST      (HBURST),
        .HTRANS      (HTRANS),
        .HPROT       (HPROT),
        .HWDATA      (HWDATA),
        .HRDATA      (HRDATA),
        .burst_mode  (tb_burst_mode),
        .data_in     (tb_data_in),
        .HREADY      (HREADY),
        .HRESP       (HRESP),
        .start       (tb_start),
        .addr_in     (tb_addr_in),
        .wr          (tb_wr),
        .rdata_out   (tb_rdata_out)
    );
 
    ahb_slave #(
        .ADDR_WIDTH  (ADDR_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH)
    ) u_ahb_slave (
        .HCLK        (HCLK),
        .HRESETn     (HRESETn),
        .HADDR       (HADDR),
        .HWRITE      (HWRITE),
        .HSIZE       (HSIZE),
        .HBURST      (HBURST),
        .HTRANS      (HTRANS),
        .HPROT       (HPROT),
        .HWDATA      (HWDATA),
        .HSELx       (1'b1),
        .HREADY      (HREADY),
        .HRDATA      (HRDATA),
        .HREADYOUT   (HREADYOUT),
        .HRESP       (HRESP)
    );
 
    // -------------------------------------------------------------------------
    // 7. Waveform Dump
    // -------------------------------------------------------------------------
   initial begin
        $dumpfile("ahb_protocols.vcd");
        $dumpvars(0, tb_ahb_top);
    end

    initial begin
        forever begin
            @(posedge HCLK);
            $display("T=%0t HADDR=%h HWDATA=%h HWRITE=%b HTRANS=%b write_reg=%b addr_reg=%h",
                      $time, HADDR, HWDATA, HWRITE, HTRANS,
                      u_ahb_slave.write_reg, u_ahb_slave.addr_reg);
        end
    end
    // -------------------------------------------------------------------------
    // 8. Helper task: start one transfer and wait for it to clear
    // -------------------------------------------------------------------------
    task do_transfer;
        input [31:0] addr;
        input        write_en;
        input [31:0] wdata;
        input        burst;
        begin
            @(negedge HCLK);
            tb_addr_in    = addr;
            tb_wr         = write_en;
            tb_data_in    = wdata;
            tb_burst_mode = burst;
            tb_start      = 1'b1;
            @(negedge HCLK);
            tb_start      = 1'b0;
 // Wait until master returns to IDLE (HTRANS == 2'b00)
            wait (HTRANS == 2'b00);
            @(negedge HCLK); // settle one extra cycle
            wait (HREADY == 1'b1);   // wait for slave to clear wait states
            @(negedge HCLK);
        end
    endtask
    
 
    // -------------------------------------------------------------------------
    // 9. Stimulus
    // -------------------------------------------------------------------------
    initial begin
        // Initial values
        tb_start      = 1'b0;
        tb_addr_in    = 32'd0;
        tb_wr         = 1'b0;
        tb_burst_mode = 1'b0;
        tb_data_in    = 32'd0;
 
        // Wait for reset to deassert
        wait (HRESETn == 1'b1);
        @(negedge HCLK);
 
        // -----------------------------------------------------------
        // Test 1: Single write 42 to address 0x1000
        // -----------------------------------------------------------
        $display("TEST 1: Write 42 to 0x1000");
        do_transfer(32'h0000_0ffc, 1'b1, 32'd42, 1'b0);
        if (u_ahb_slave.mem_array[32'h0000_0ffc>> 2] == 32'd42)
        $display("PASS: Memory write successful");
        else
        $display("FAIL: Memory = %0d, expected 42",
                u_ahb_slave.mem_array[32'h0000_0ffc >> 2]);
    
        // -----------------------------------------------------------
        // Test 2: Single read back from 0x1000, verify == 42
        // -----------------------------------------------------------
        $display("TEST 2: Read back 0x1000");
        do_transfer(32'h0000_0ffc, 1'b0, 32'd0, 1'b0);
        #(CLK_PERIOD);
        if (tb_rdata_out == 32'd42)
            $display("PASS: Read back %0d, expected 42", tb_rdata_out);
        else
            $display("FAIL: Read back %0d, expected 42", tb_rdata_out);
 
        // -----------------------------------------------------------
        // Test 3: INCR4 burst write to 0x2000-0x200C
        // -----------------------------------------------------------
        $display("TEST 3: Burst write starting 0x2000");
        do_transfer(32'h0000_2000, 1'b1, 32'hA5A5_1234, 1'b1);
 
        // -----------------------------------------------------------
        // Test 4: INCR4 burst read from 0x2000, verify last value
        // -----------------------------------------------------------
        $display("TEST 4: Burst read starting 0x2000");
        do_transfer(32'h0000_2000, 1'b0, 32'd0, 1'b1);
        #(CLK_PERIOD);
        $display("Burst read last captured value = %h", tb_rdata_out);
 
        // -----------------------------------------------------------
        // Test 5: Access invalid address (out of 1024-location range)
        // -----------------------------------------------------------
        $display("TEST 5: Invalid address access");
        do_transfer(32'hFFFF_0000, 1'b1, 32'd99, 1'b0);
        #(CLK_PERIOD);
        if (HRESP == 1'b1)
            $display("PASS: HRESP asserted for invalid address");
        else
            $display("FAIL: HRESP not asserted for invalid address");
 
        #(CLK_PERIOD * 10);
        $display("Day 30 simulation complete.");
        $finish;
    end
 
endmodule
 