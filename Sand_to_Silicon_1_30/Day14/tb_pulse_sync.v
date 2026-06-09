module tb_pulse_sync;
reg clk_src;
reg clk_dst;
reg pulse_in;
reg rst;
wire pulse_out;

pulse_sync DUT(
    .clk_src(clk_src),
    .clk_dst(clk_dst),
    .rst(rst),
    .pulse_in(pulse_in),
    .pulse_out(pulse_out)
);

initial begin
    clk_src=0;
    clk_dst=0;
    rst=0;
    pulse_in=0;
end

always #100 clk_src=~clk_src;
always #10 clk_dst=~clk_dst;

initial begin 
    $dumpfile("pulse.vcd");
    $dumpvars(0, tb_pulse_sync);

    rst=1;
    #400;
    rst=0;
    #400;
    pulse_in=1;
    #200;
    pulse_in=0;
    #1000;
    pulse_in=1;
    #200;
    pulse_in=0;
    #1000;

    $finish;


end
initial begin

$monitor("Time=%0t, clk_src=%b, clk_dst=%b, rst=%b, pulse_in=%b, pulse_out=%b",
$time, clk_src, clk_dst, rst, pulse_in, pulse_out);
end


endmodule

