module dual_port_sram(

    input clk,
    input cs_a,
    input we_a,
    input  [2:0] addr_a,
    input  [7:0] din_a,
    output reg [7:0] dout_a,

    input cs_b,
    input we_b,
    input  [2:0] addr_b,
    input  [7:0] din_b,
    output reg [7:0] dout_b
);

reg[7:0] mem [7:0];

always @(posedge clk) begin

    if (cs_a == 0)
        dout_a <= 8'bzzzzzzzz;
    else if (cs_a == 1 && we_a == 1)
        mem[addr_a] <= din_a;
    else if(cs_a==1 && we_a==0)
        dout_a <= mem[addr_a];

     if (cs_b == 0)
        dout_b<= 8'bzzzzzzzz;
    else if (cs_b == 1 && we_b == 1)
        mem[addr_b] <= din_b;

    else 
        dout_b <= mem[addr_b];
        end
    endmodule

