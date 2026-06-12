module clk_gate(
    input clk,
    input enable,
   
    output wire GCLK
);

reg latch_en;


assign GCLK = latch_en & clk;


always @(clk or enable) begin
    if (!clk)
        latch_en <= enable;
end
endmodule