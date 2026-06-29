`timescale 1ns/1ps

module ahb_master_tb;

    //----------------------------------------------------------------------
    // Signal Declarations
    //----------------------------------------------------------------------
    reg         HCLK;
    reg         HRESETn;
    reg  [31:0] HRDATA;
    reg         HREADY;
    reg         HRESP;
    reg  [31:0] addr_in;
    reg         wr;
    reg         start;

    wire [31:0] HADDR;
    wire        HWRITE;
    wire [2:0]  HSIZE;
    wire [2:0]  HBURST;
    wire [1:0]  HTRANS;
    wire [3:0]  HPROT;
    wire [31:0] HWDATA;

    //----------------------------------------------------------------------
    // DUT
    //----------------------------------------------------------------------
    ahb_master dut (
        .HCLK    (HCLK),
        .HRESETn (HRESETn),
        .HADDR   (HADDR),
        .HWRITE  (HWRITE),
        .HSIZE   (HSIZE),
        .HBURST  (HBURST),
        .HTRANS  (HTRANS),
        .HPROT   (HPROT),
        .HWDATA  (HWDATA),
        .HRDATA  (HRDATA),
        .HREADY  (HREADY),
        .HRESP   (HRESP),
        .addr_in (addr_in),
        .wr      (wr),
        .start   (start)
    );

    //----------------------------------------------------------------------
    // Clock
    //----------------------------------------------------------------------
    initial HCLK = 1'b0;
    always #5 HCLK = ~HCLK;

    //----------------------------------------------------------------------
    // Dump
    //----------------------------------------------------------------------
    initial begin
        $dumpfile("ahb_master.vcd");
        $dumpvars(0, ahb_master_tb);

        
    end
    //----------------------------------------------------------------------
// Monitor
//----------------------------------------------------------------------
always @(posedge HCLK) begin
    if(HTRANS != 2'b00) begin
        $display("T=%0t | HTRANS=%b | HADDR=%h | HREADY=%b | HWRITE=%b",
                  $time, HTRANS, HADDR, HREADY, HWRITE);
    end
end

    //----------------------------------------------------------------------
    // Stimulus
    //----------------------------------------------------------------------
    initial begin

        // 1. Initialize all inputs
        HRESETn = 0;
        HREADY  = 0;
        start   = 0;
        addr_in = 32'h0;
        wr      = 0;
        HRDATA  = 32'h0;
        HRESP   = 0;

        // 2. Release reset
        #20;
        HRESETn = 1;
        HREADY  = 1;

        // 3. Trigger INCR4 burst — NeuralEdge weight fetch
        #10;
        start   = 1'b1;      // trigger transfer
        addr_in = 32'h2000;      // NeuralEdge weight base address
        wr      = 1'b0;      // read or write?

        // 4. Let burst run 4 beats
        #40;               // how many cycles for 4 beats?
        start = 0;

        // 5. Insert wait state — slave busy
        HREADY = 1'b0;       // slave pulls low
        #20;
        HREADY = 1'b1;       // slave ready again

        // 6. End simulation
        #50;
        $finish;

    end

endmodule