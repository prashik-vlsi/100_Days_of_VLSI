`timescale 1ns/1ps

module tb_register_bank;

reg         clk;
reg         rst_n;
reg         write_en;
reg  [31:0] data_in;

wire [31:0] data_out;

wire gclk ;

register_bank dut (
    .clk(clk),
    .rst_n(rst_n),
    .write_en(write_en),
    .data_in(data_in),
    .data_out(data_out),
    .gclk(gclk)
);

// Clock generation
always #5 clk = ~clk;

initial begin

    $dumpfile("clock_gating.vcd");
    $dumpvars(0, tb_register_bank);

    
    $monitor("T=%0t clk=%b gclk=%b en=%b din=%h dout=%h",
              $time, clk, dut.gclk, write_en, data_in, data_out);

    clk      = 0;
    rst_n    = 0;
    write_en = 0;
    data_in  = 0;

    // Reset
    #15;
    rst_n = 1;

    // -------------------------
    // Clock Gating OFF
    // -------------------------
    data_in = 32'h11;
    #20;

    // -------------------------
    // Enable Clock
    // -------------------------
    write_en = 1;

    data_in = 32'h55;
    #20;

    data_in = 32'hAA;
    

   @(negedge clk);
write_en = 0;

@(negedge clk);
data_in = 32'hFF;
#19;

$finish;


end



endmodule
