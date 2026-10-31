/*### Problem Statement

Design a **32-bit RV32I ALU Operand-B Multiplexer** in SystemVerilog. Create `rv32i_alu_operand_mux.sv` with the top module 
`rv32i_alu_operand_mux`. The module must select between the 32-bit register operand `rs2_data` and the 32-bit immediate `imm` 
using the control signal `alu_src`. When `alu_src = 0`, output `rs2_data`; when `alu_src = 1`, output `imm`.
Implement the design using `always_comb` with `if/else` and blocking assignments, ensuring purely combinational, latch-free RTL.
*/
module rv32i_alu_operand_mux(
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm,
    input  logic        alu_src,
    output logic [31:0] alu_operand_b
);

always_comb begin
    if (alu_src)
        alu_operand_b = imm;
    else
        alu_operand_b = rs2_data;
end

endmodule
