/* 

Design a **32-bit RV32I Effective Address Generator** that computes the effective memory address used by load and store instructions.
 The module shall accept a 32-bit base address from register `rs1` and a 32-bit sign-extended immediate offset and produce the corresponding 32-bit effective address. 
 The design must correctly handle positive offsets, negative offsets, zero offsets, and 32-bit address wraparound. The implementation must be synthesizable 
 and compliant with RV32I address-generation behavior.

 */
module rv32i_address_calc (
    input  logic [31:0] rs1_data,
    input  logic [31:0] imm,
    output logic [31:0] address
);

always_comb begin
    address = rs1_data + imm;
end

endmodule