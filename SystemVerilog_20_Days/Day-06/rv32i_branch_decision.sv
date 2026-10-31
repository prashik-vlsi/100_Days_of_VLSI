module rv32i_branch_decision (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic        branch_enable,
    output logic        branch_taken
);

always_comb begin
    if (branch_enable && (rs1_data == rs2_data))
        branch_taken = 1'b1;
    else
        branch_taken = 1'b0;
end

endmodule