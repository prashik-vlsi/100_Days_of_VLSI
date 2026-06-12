`timescale 1ns/1ps
module clk_gate_tb;
    reg enable;
    reg clk;
    
    wire GCLK;

clk_gate DUT(
    .enable(enable),
    .clk(clk),
    .GCLK(GCLK)
    
);


always #5 clk=~clk;

initial begin 
$dumpfile("clk.vcd");
$dumpvars(0, clk_gate_tb);
$dumpvars(0, DUT);




clk =0;
enable =0;



enable=1;
#50;


enable=0;
#50;


@(posedge clk);    // wait until CLK goes high
#2;                // wait 2ns — now we are mid-HIGH
enable = 1;        // change enable while CLK is still high
#20;               // observe GCLK — does it glitch?

enable =0;
#20;
@(negedge clk);    // wait until CLK goes low
#2;                // wait 2ns — now we are mid-LOW
enable = 1;        // change enable while CLK is low
#20;               // observe GCLK — clean response?

$finish;
end
endmodule 