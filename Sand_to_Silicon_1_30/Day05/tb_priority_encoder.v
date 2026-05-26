module tb_priority_encoder;

reg [3:0] y;

wire a;
wire b;

priority_encoder uut (

    .y(y),
    .a(a),
    .b(b)

);

initial begin

    $dumpfile("prio_dump.vcd");
    $dumpvars(0, tb_priority_encoder);

end

initial begin

    y = 4'b0001; #10; // Only Y0 active
    y = 4'b0010; #10; // Only Y1 active
    y = 4'b0100; #10; // Only Y2 active
    y = 4'b1000; #10; // Only Y3 active

    y = 4'b0011; #10; // Y1 and Y0 active
    y = 4'b0110; #10; // Y2 and Y1 active
    y = 4'b1111; #10; // All active

    $finish;

end

initial begin

    $monitor(
    "Time=%0t y=%b a=%b b=%b",
    $time, y, a, b
    );

end

endmodule