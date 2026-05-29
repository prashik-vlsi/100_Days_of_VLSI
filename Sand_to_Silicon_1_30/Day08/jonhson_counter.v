module jonhson_counter(
    input clk,
    input rst,
    output reg [3:0] Q
);

always @(posedge clk) begin

    if(rst)
        Q <= 4'b0000;

    else begin
        Q[0] <= ~Q[3];
        Q[1] <= Q[0];
        Q[2] <= Q[1];
        Q[3] <= Q[2];
    end

end

endmodule
