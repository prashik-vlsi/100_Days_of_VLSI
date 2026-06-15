`timescale 1ns / 1ps

module tb_alu;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] opcode;

    // Outputs
    wire [31:0] Result;
    wire zero;
    wire cout;

    // Instance Under Test (UUT)
    alu uut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .Result(Result),
        .zero(zero),
        .cout(cout)
    );

    initial begin
        // GTKWave VCD Dump Configuration
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        // Terminal Output Monitor
        $monitor("Time=%0dt | Opcode=%b | A=%d, B=%d | Result=%d | Zero=%b, Cout=%b", 
                 $time, opcode, A, B, Result, zero, cout);

        // Test 1: ADD
        A = 32'd15; B = 32'd10; opcode = 4'b0000;
        #10;

        // Test 2: SUB
        A = 32'd20; B = 32'd5; opcode = 4'b0001;
        #10;

        // Test 3: Bitwise AND
        A = 32'hFFFF_0000; B = 32'h5555_5555; opcode = 4'b0010;
        #10;

        // Test 4: SLL (Shift Left Logical)
        A = 32'd1; B = 32'd4; opcode = 4'b0101;
        #10;

        // Test 5: SLTU (Unsigned Corner Case A == B)
        A = 32'd5; B = 32'd5; opcode = 4'b1001;
        #10;

        // Test 6: SLT (Signed Corner Case Negative vs Positive)
        A = 32'h8000_0000; B = 32'd1; opcode = 4'b1000;
        #10;

        $display("--- ALU Testbench Simulation Completed ---");
        $finish;
    end

endmodule
    