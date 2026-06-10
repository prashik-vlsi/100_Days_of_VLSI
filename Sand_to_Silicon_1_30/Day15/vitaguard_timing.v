module vitaguard_timing(
    input clk,
    input rst,
    input [7:0]adc_val,
    input [7:0]treshold,
    output reg alert
);
wire stage1;
wire stage2;
wire stage3;

assign stage1=(adc_val>treshold)? 1'b1:1'b0;

assign stage2=stage1&&(adc_val!=0);

assign stage3=stage2&&(treshold!=255);

always @(posedge clk)begin
    if(rst)begin
        alert<=1'b0;
    end
    else begin 
        alert <= stage3;
end

end
endmodule
