module tb_sr_latch;

reg s;
reg r;

wire Q;
wire Qbar;

sr_latch DUT(
    .s(s),
    .r(r),
    .Q(Q),
    .Qbar(Qbar)
);

initial begin

    $dumpfile("sr_latch_dump.vcd");
    $dumpvars(0, tb_sr_latch);

 s=1; r=0; #10;   // SET first — give Q a known value
s=0; r=0; #10;   // HOLD — now it has something to hold
s=0; r=1; #10;   // RESET
s=0; r=0; #10;   // HOLD again
s=1; r=1; #10;   // FORBIDDEN
    $finish;

end

initial begin

    $monitor("Time=%0t, s=%b, r=%b, Q=%b, Qbar=%b",
              $time, s, r, Q, Qbar);

end

endmodule

