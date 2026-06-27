`timescale 1ns/1ps

module apb_tb;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;

    reg clk, rst_n, start, wr_en;
    reg  [ADDR_WIDTH-1:0] addr_in;
    reg  [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire done_out;
    wire psel, penable, pwrite;
    wire [ADDR_WIDTH-1:0] paddr;
    wire [DATA_WIDTH-1:0] pwdata, prdata;
    wire pready;

    apb_master #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH)) u_master (
        .clk(clk),.rst_n(rst_n),.start(start),.wr_en(wr_en),
        .addr_in(addr_in),.data_in(data_in),.data_out(data_out),
        .done_out(done_out),.psel(psel),.penable(penable),
        .pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),
        .prdata(prdata),.pready(pready)
    );

    apb_slave #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH)) u_slave (
        .clk(clk),.rst_n(rst_n),.psel(psel),.penable(penable),
        .pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),
        .prdata(prdata),.pready(pready)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("apb.vcd");
        $dumpvars(0, apb_tb);
        $monitor($time, " rst=%b start=%b psel=%b penable=%b pwrite=%b paddr=%h pwdata=%h prdata=%h pready=%b done=%b",
        rst_n, start, psel, penable, pwrite, paddr, pwdata, prdata, pready, done_out);

        // Initialize
        clk=0; rst_n=0; start=0;
        wr_en=0; addr_in=0; data_in=0;

        // Reset
        #20; rst_n=1;

        // Transaction 1 — Write 500 to load_value (ECG timer interval)
        #10;
        wr_en=1; addr_in=32'h00; data_in=500;
        start=1; #10; start=0;
        #75;

        // Transaction 2 — Write 1 to control (start ECG timer)
        wr_en=1; addr_in=32'h04; data_in=1;
        start=1; #10; start=0;
        #50;

        // Transaction 3 — Read status (check done flag)
        wr_en=0; addr_in=32'h08; data_in=0;
        start=1; #10; start=0;
        #200;

        $finish;
    end

endmodule