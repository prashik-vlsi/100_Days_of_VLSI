module tb_decoder_2x4;

reg A;
reg B;

wire [3:0] Y;

decoder_2x4 uut(

    .A(A),
    .B(B),
    .Y(Y)

);

initial begin

    $dumpfile("deco_dump.vcd");
    $dumpvars(0, tb_decoder_2x4);

    A = 0; B = 0; #10;
    A = 0; B = 1; #10;
    A = 1; B = 0; #10;
    A = 1; B = 1; #10;

    $finish;

end

initial begin

    $monitor(
    "Time=%0t A=%b B=%b Y=%b",
    $time, A, B, Y
    );

end

endmodule