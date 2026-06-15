module alu(
    input [31:0] A,
    input [31:0] B,
    input [3:0] opcode,
    output reg [31:0] Result,
    output zero,
    output cout
);

    wire sub_ctrl = opcode[0];
    wire [31:0] B_modified;
    wire [32:0] sum_full;
    wire negative;
    wire overflow;

    assign B_modified = B ^ {32{sub_ctrl}};
    assign sum_full   = A + B_modified + sub_ctrl;

    assign zero = !(|Result);
    assign cout = sum_full[32]; 
    assign negative = Result[31];
    assign overflow = (!A[31] && !B_modified[31] && Result[31]) || (A[31] && B_modified[31] && !Result[31]);

    always @(*) begin
        case(opcode)
            4'b0000: Result = sum_full[31:0];
            4'b0001: Result = sum_full[31:0];
            4'b0010: Result = A & B;
            4'b0011: Result = A | B;
            4'b0100: Result = A ^ B;
            4'b0101: Result = A << B[4:0];
            4'b0110: Result = A >> B[4:0];
            4'b0111: Result = $signed(A) >>> B[4:0];
            4'b1000: Result = (negative ^ overflow) ? 32'h1 : 32'h0;
            4'b1001: Result = (!cout) ? 32'h1 : 32'h0;
            default: Result = 32'h0;
        endcase
    end

endmodule