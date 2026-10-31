module rv32i_alu_control (
    input  logic [2:0] funct3,
    output logic [3:0] alu_control
);

always_comb begin

    case (funct3)

        3'b000: alu_control = 4'b0000; // ADD
        3'b001: alu_control = 4'b0001; // SLL
        3'b010: alu_control = 4'b0010; // SLT
        3'b011: alu_control = 4'b0011; // SLTU
        3'b100: alu_control = 4'b0100; // XOR
        3'b101: alu_control = 4'b0101; // SRL/SRA resolved later
        3'b110: alu_control = 4'b0110; // OR
        3'b111: alu_control = 4'b0111; // AND

        default: alu_control = 4'b1111;

    endcase

end

endmodule