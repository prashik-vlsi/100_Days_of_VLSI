module gate_tb;
reg a;
reg b;
wire and_gate;
wire or_gate;
wire nand_gate;
wire nor_gate;
wire xor_gate;

gate  uut(
    .a(a),
    .b(b),
    .and_gate(and_gate),
    .or_gate(or_gate),
    .nand_gate(nand_gate),
    .nor_gate(nor_gate),
    .xor_gate(xor_gate)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, gate_tb);

    a=0; b=0; #10;
    a=0;  b=1; #10;
    a=1; b=0; #10;
    a=1; b=1; #10;

    $finish;

end
initial begin
    $monitor("Time=%0t a=%b b=%b AND=%b OR=%b NAND=%b NOR=%b XOR=%b",
    $time, a, b, and_gate, or_gate, nand_gate, nor_gate, xor_gate);
end


endmodule

