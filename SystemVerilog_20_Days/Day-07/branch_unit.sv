module branch_unit (
    input  logic [31:0] pc,
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    input  logic [31:0] branch_imm,
    input  logic [2:0]  funct3,
    input  logic        is_branch,
    output logic        branch_taken,
    output logic [31:0] next_pc
);
    logic compare_result;

    branch_comp u_branch_comp (
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .branch_taken(compare_result)
    );

    always_comb begin
        branch_taken = is_branch && compare_result;
        if (branch_taken)
            next_pc = pc + branch_imm;
        else
            next_pc = pc + 32'd4;
    end
endmodule
