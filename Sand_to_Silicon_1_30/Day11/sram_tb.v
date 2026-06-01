`timescale 1ns/1ps

module sram_tb;

reg clk;
reg cs;
reg we;
reg  [2:0] addr;
reg  [7:0] din;
wire [7:0] dout;

sram_sp DUT (
    .clk(clk),
    .cs(cs),
    .we(we),
    .addr(addr),
    .din(din),
    .dout(dout)
);

initial
    clk = 0;

always #5 clk = ~clk;

initial begin
    $dumpfile("sram.vcd");
    $dumpvars(0, sram_tb);

    cs   = 0;
    we   = 0;
    addr = 0;
    din  = 0;

    #10;

    cs   = 1;
    we   = 1;
    addr = 3;
    din  = 8'hAA;

    #10;

    we   = 0;
    addr = 3;

    #10;
        // write second location
    cs   = 1;
    we   = 1;
    addr = 5;
    din  = 8'hBB;
    #10;

    // read second location
    we   = 0;
    addr = 5;
    #10;

    // disable chip
    cs   = 0;
    #10;

    $finish;
end

endmodule
