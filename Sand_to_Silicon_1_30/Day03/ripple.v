module ripple(
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);

    wire c1, c2, c3;  // internal carry wires between stages

    // Stage 0: LSB
    fulladder FA0(.a(a[0]), .b(b[0]), .c(cin),  .sum(sum[0]), .carry(c1));

    // Stage 1: fill this in yourself
    fulladder FA1(.a(a[1]), .b(b[1]), .c(c1), .sum(sum[1]), .carry(c2));

    // Stage 2: fill this in yourself
    fulladder FA2(.a(a[2]), .b(b[2]), .c(c2), .sum(sum[2]), .carry(c3));

    // Stage 3: MSB - fill this in yourself
    fulladder FA3(.a(a[3]), .b(b[3]), .c(c3), .sum(sum[3]), .carry(cout));

endmodule
