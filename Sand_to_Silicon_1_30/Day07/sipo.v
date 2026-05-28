module sipo(
    input clk, 
    input si, 
    output reg [3:0]Q

);
always @(posedge clk) begin 

            Q[0]<=si;
            Q[1]<=Q[0];
            Q[2]<=Q[1];
            Q[3]<=Q[2];

    end
endmodule
