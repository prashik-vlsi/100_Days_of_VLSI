module multiplier#(
    parameter WIDTH=8

)(
    input  [WIDTH-1:0]A,
    input  [WIDTH-1:0]B,
    output wire [2*WIDTH-1:0]out
);

assign out = A*B;
endmodule 