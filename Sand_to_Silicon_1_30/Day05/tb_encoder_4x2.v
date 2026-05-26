module tb_encoder_4x2;

reg [3:0]y;

wire A;
wire B;

encoder_4x2 uut(
    .y(y),
    .A(A),
    .B(B)
);

initial begin 
$dumpfile("enco_dump.vcd");

$dumpvars(0, tb_encoder_4x2);
y = 4'b0001; #10;
y = 4'b0010; #10;
y = 4'b0100; #10;
y = 4'b1000; #10;
$finish;
end

initial begin
$monitor("Time=%0t y=%b A=%b B=%b", $time, y, A, B);

end
endmodule

