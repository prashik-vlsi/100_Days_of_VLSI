module metastability(
    input clk,
    input async_in,
    output reg sampled


);
always @(posedge clk) begin
 sampled <= async_in;
 end
endmodule