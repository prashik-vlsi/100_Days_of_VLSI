module tb_d_flipflop;

reg d;
reg clk;

wire Q;
wire Qbar;

d_flipflop DUT(

    .d(d),
    .clk(clk),
    .Q(Q),
    .Qbar(Qbar)
);

initial begin
$dumpfile("d_flop_dump.vcd");
$dumpvars(0, tb_d_flipflop);
 clk = 0;

    forever #5 clk = ~clk;

end

initial begin

    d = 0; #10;
    d = 1; #10;
    d = 0; #10;
    d = 1; #10;

    $finish;

end

initial begin

    $monitor("Time=%0t clk=%b d=%b Q=%b Qbar=%b",
              $time, clk, d, Q, Qbar);

end

endmodule