module tb_rv32i_alu_operand_mux;

    logic [31:0] rs2_data;
    logic [31:0] imm;
    logic        alu_src;
    logic [31:0] alu_operand_b;

    rv32i_alu_operand_mux DUT (
        .rs2_data      (rs2_data),
        .imm           (imm),
        .alu_src       (alu_src),
        .alu_operand_b (alu_operand_b)
    );

    initial begin
        $dumpfile("out.vcd");
        $dumpvars(0, tb_rv32i_alu_operand_mux);

        rs2_data = 32'd25;
        imm      = 32'd10;
        alu_src  = 1'b0;

        #1;

        if (alu_operand_b == 32'd25) begin
            $display("PASS: alu_operand_b = %0d", alu_operand_b);
        end
        else begin
            $display("FAIL: Expected 25, Got %0d", alu_operand_b);
        end

        $finish;
    end

endmodule