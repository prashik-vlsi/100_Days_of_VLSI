`timescale 1ns/1ps

module multiplier_tb;

parameter WIDTH = 8;

reg  [WIDTH-1:0] A;
reg  [WIDTH-1:0] B;
wire [2*WIDTH-1:0] out;

// DUT Instantiation
multiplier #(
    .WIDTH(WIDTH)
) dut (
    .A(A),
    .B(B),
    .out(out)
);

initial begin
    $dumpfile("mul.vcd");
    $dumpvars(0, multiplier_tb);


    // Test Case 1
    A = 0;
    B = 0;
    #10;
    $display("A=%0d B=%0d OUT=%0d", A, B, out);

    // Test Case 2
    A = 5;
    B = 3;
    #10;
    $display("A=%0d B=%0d OUT=%0d", A, B, out);

    // Test Case 3
    A = 10;
    B = 20;
    #10;
    $display("A=%0d B=%0d OUT=%0d", A, B, out);

    // Boundary Condition
    A = {WIDTH{1'b1}};  // Maximum value
    B = {WIDTH{1'b1}};  // Maximum value
    #10;
    $display("A=%0d B=%0d OUT=%0d", A, B, out);

    $finish;

end

initial begin 
    $monitor("Time =0%t, A=%b, B=%b, out=%b", 
    $time , A, B, out);
end


endmodule