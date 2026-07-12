module register_bank #(
    parameter data_width = 32 

)(
    input wire clk,
    input  wire rst_n,
    input wire write_en,
    input wire  [data_width-1:0] data_in,
    output reg [data_width-1:0] data_out,
    output wire gclk
);
    

icg u_icg(

    .clk(clk),
    .en(write_en),
    .gclk(gclk)
);

always @(posedge gclk or negedge rst_n)begin
if(!rst_n)begin
data_out <= 32'h00;
end
else begin
data_out <= data_in;
end
end
endmodule
