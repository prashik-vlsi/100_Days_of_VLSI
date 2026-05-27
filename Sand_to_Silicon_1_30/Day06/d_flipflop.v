module d_flipflop(
input d,
input clk, 
output reg Q,
output reg Qbar

);
initial begin
    Q = 0;
    Qbar = 1;
end

always @(posedge clk) begin

    Q    <= d;
    Qbar <= ~d;

end

endmodule
