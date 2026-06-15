module mac (
    input clk,
    input rst,
    input [31:0] A,
    input [31:0] B,
    output reg [63:0] accum 
);

    always @(posedge clk) begin 
        if(rst) begin 
            accum <= 64'h0;
        end
        else begin 
            accum <= accum + (A * B);
        end
    end 
endmodule