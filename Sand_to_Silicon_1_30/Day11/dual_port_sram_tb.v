`timescale 1ns/1ps;

module dual_port_sram_tb;
   reg clk;
    reg cs_a;
    reg we_a;
    reg  [2:0] addr_a;
    reg  [7:0] din_a;
    wire [7:0] dout_a;

    reg cs_b;
    reg we_b;
    reg  [2:0] addr_b;
    reg  [7:0] din_b;
    wire [7:0] dout_b;

dual_port_sram DUT(
     .clk(clk),
    .cs_a(cs_a),
    .we_a(we_a),
    .addr_a(addr_a),
    .din_a(din_a),
    .dout_a(dout_a),

    
    .cs_b(cs_b),
    .we_b(we_b),
    .addr_b(addr_b),
    .din_b(din_b),
    .dout_b(dout_b)

    
);

initial
    clk=0;

always #5 clk=~clk;

initial  begin
$dumpfile("dual.vcd");
$dumpvars(0, dual_port_sram_tb);

 // simultaneous write
cs_a = 1; we_a = 1; addr_a = 1; din_a = 8'hAA;
cs_b = 1; we_b = 1; addr_b = 5; din_b = 8'hBB;
#10;

// simultaneous read
we_a = 0; addr_a = 1;
we_b = 0; addr_b = 5;
#10;

// write on A while reading on B
we_a = 1; addr_a = 2; din_a = 8'hCC;
we_b = 0; addr_b = 1;
#10;

// disable both ports
cs_a = 0;
cs_b = 0;
#10;
    $finish;
end

endmodule




    


