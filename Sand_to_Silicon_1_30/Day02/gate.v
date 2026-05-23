module gate(
    input wire a,
    input wire b,
    output wire and_gate,
    output wire or_gate,
    output wire nand_gate,
    output wire nor_gate,
    output wire xor_gate
);

assign and_gate  = a & b;
assign or_gate   = a | b;
assign nand_gate = ~(a & b);
assign nor_gate  = ~(a | b);
assign xor_gate  = a ^ b;

endmodule