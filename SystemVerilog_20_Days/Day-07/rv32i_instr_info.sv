
module rv32i_instr_info (
    input  logic [31:0] instr,

    output logic [6:0] opcode,
    output logic [4:0] rd,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [2:0] funct3,
    output logic [6:0] funct7,

    output logic is_branch,
    output logic is_itype_alu,
    output logic is_jal,
    output logic is_load,
    output logic is_lui,
    output logic is_rtype,
    output logic is_store,

    output logic writes_rd,
    output logic uses_rs2
);

    // Instruction field extraction: pure combinational wiring
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // Opcode decoder
    always_comb begin

        // Default instruction class flags
        is_rtype     = 1'b0;
        is_itype_alu = 1'b0;
        is_load      = 1'b0;
        is_store     = 1'b0;
        is_branch    = 1'b0;
        is_lui       = 1'b0;
        is_jal       = 1'b0;

        // Default control signals
        writes_rd = 1'b0;
        uses_rs2  = 1'b0;

        unique case (instr[6:0])

            // R-type instructions
            7'b0110011: begin
                is_rtype = 1'b1;
                writes_rd = 1'b1;
                uses_rs2 = 1'b1;
            end

            // I-type ALU instructions
            7'b0010011: begin
                is_itype_alu = 1'b1;
                writes_rd = 1'b1;
            end

            // Load instructions
            7'b0000011: begin
                is_load = 1'b1;
                writes_rd = 1'b1;
            end

            // Store instructions
            7'b0100011: begin
                is_store = 1'b1;
                uses_rs2 = 1'b1;
            end

            // Branch instructions
            7'b1100011: begin
                is_branch = 1'b1;
                uses_rs2 = 1'b1;
            end

            // LUI instruction
            7'b0110111: begin
                is_lui = 1'b1;
                writes_rd = 1'b1;
            end

            // JAL instruction
            7'b1101111: begin
                is_jal = 1'b1;
                writes_rd = 1'b1;
            end

            // Unsupported opcode
            default: begin
                // All outputs retain their default values.
            end

        endcase

    end

endmodule
