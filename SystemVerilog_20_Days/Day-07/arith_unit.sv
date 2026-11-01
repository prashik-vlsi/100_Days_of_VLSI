module arith_unit (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        sub,
    output logic [31:0] result
);
    always_comb begin
        if (sub)
            result = a - b;
        else
            result = a + b;
    end
endmodule
