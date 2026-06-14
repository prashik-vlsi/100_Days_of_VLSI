`timescale 1ns/1ps
module metastability_tb;
reg clk;
reg async_in;
wire sampled;

metastability DUT(
    .clk(clk),
    .async_in(async_in),
    .sampled(sampled)
);
initial begin
    clk=0;
    async_in=0;
end
always #5 clk=~clk;

initial begin
    $dumpfile("meta.vcd");
    $dumpvars(0, metastability_tb);
    #12 async_in = 1; // Change async_in near clock edge
    #7 async_in = 0;
    #6 async_in = 1;
    #9 async_in = 0;
    #50 $finish;
    end

initial begin 
    $monitor("Time=%0t, clk=%b, async_in=%b, sampled=%b",
    $time, clk, async_in, sampled);
end
endmodule