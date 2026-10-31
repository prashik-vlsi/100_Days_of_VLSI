module rv32i_pc_mux (
    input  logic [31:0] pc_plus_4,
    input  logic [31:0] branch_target,
    input  logic        pc_src,
    output logic [31:0] next_pc
);

always_comb begin
    if (pc_src) begin
        next_pc = branch_target;
    end
    else begin
        next_pc = pc_plus_4;
    end
end

endmodule
