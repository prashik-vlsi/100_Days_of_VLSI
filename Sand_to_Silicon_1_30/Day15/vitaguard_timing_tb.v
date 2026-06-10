module vitaguard_timing_tb;
reg clk;
reg rst;
reg [7:0]adc_val;
reg [7:0]treshold;
wire alert;

vitaguard_timing DUT(
    .clk(clk),
    .rst(rst),
    .adc_val(adc_val),
    .treshold(treshold),
    .alert(alert)

);

initial begin 
    clk=0;
    rst=0;
end
always #5 clk=~clk;


initial begin 
    $dumpfile("vita.vcd");
    $dumpvars(0, vitaguard_timing_tb);

rst=1;
#10;
rst=0;
#10;

    // Test 1 : Reset
    rst = 1;
    adc_val = 0;
    treshold = 100;
    #20;
$display("TEST1 Reset: alert=%b (expect 0)", alert);

    rst = 0;

    // Test 2 : adc_val below treshold
    adc_val = 50;
    treshold = 100;
    #20;
    $display("null: alert=%b (expect 0)", alert);
    // Test 3 : adc_val above treshold
    adc_val = 200;
    treshold = 100;
    #20;
    $display("emergency : alert=%b (expect 1)", alert);
    // Test 4 : adc_val = 200, treshold = 255
    adc_val = 200;
    treshold = 255;
    #20;
    $display("TEST4 adc_val below 255: alert=%b (expect 0)", alert);

    $finish;

end
endmodule