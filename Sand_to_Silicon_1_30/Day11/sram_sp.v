module sram_sp(
    input clk,
    input cs,
    input we,
    input  [2:0] addr,
    input  [7:0] din,
    output reg [7:0] dout
);
    reg[7:0] mem [ 7:0];

always @(posedge clk)begin
    if (cs == 0)
        dout <= 8'bzzzzzzzz;
    else if (cs == 1 && we == 1)
        mem[addr] <= din;

    else 
        dout <= mem[addr];
        end


endmodule
