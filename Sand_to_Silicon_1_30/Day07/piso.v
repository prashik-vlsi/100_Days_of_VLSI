module piso(

    input [3:0]D,
    output wire s0,
    input clk,
    input load
);

reg [3:0] Q;

assign s0 = Q[3];

always @(posedge clk) begin

    if(load)
    begin
    Q<=D;
    end
else 
begin
        Q[3] <= Q[2];
        Q[2] <= Q[1];
        Q[1] <= Q[0];
        Q[0] <= 1'b0;
    end
end

endmodule



