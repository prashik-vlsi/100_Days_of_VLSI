module tb_d_latch;

reg d;
reg en;
wire Q;
wire Qbar;

d_latch DUT(

    .d(d),
    .en(en),
    .Q(Q),
    .Qbar(Qbar)
);

initial begin
$dumpfile("d_dump.vcd");
$dumpvars(0, tb_d_latch);

en=0; d=0; #10;
en=0; d=1; #10;
en=1; d=0; #10;
en=1; d=1; #10;

$finish;

end

initial begin

$monitor("Time=%0t, d=%b, en=%b, Q=%b, Qbar=%b", 
$time, en, d, Q, Qbar);

end
endmodule