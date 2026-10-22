module parameterized_adder #(
    parameter int WIDTH = 4
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH:0]   sum
);

    // Extend both operands by 1 bit so the carry is preserved
    assign sum = {1'b0, a} + {1'b0, b};

endmodule
