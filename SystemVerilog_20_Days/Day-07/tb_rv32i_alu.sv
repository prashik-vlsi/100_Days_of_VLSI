module tb_rv32i_alu;
    logic [31:0] a, b, result;
    logic [3:0] alu_op;
    logic zero;
    integer errors = 0;
    integer tests = 0;

    rv32i_alu dut (.*);

    task automatic check(
        input logic [31:0] ta,
        input logic [31:0] tb,
        input logic [3:0] op,
        input logic [31:0] expected
    );
        begin
            a = ta; b = tb; alu_op = op; #1; tests++;
            if ((result !== expected) || (zero !== (expected == 32'b0))) begin
                $display("FAIL a=%h b=%h op=%h result=%h zero=%b expected=%h",
                         a, b, alu_op, result, zero, expected);
                errors++;
            end else $display("PASS op=%h result=%h zero=%b", alu_op, result, zero);
        end
    endtask

    initial begin
        $display("=== Q9 INTEGRATED RV32I ALU ===");
        check(32'd10, 32'd5, 4'd0, 32'd15);                 // ADD
        check(32'd10, 32'd5, 4'd1, 32'd5);                  // SUB
        check(32'd1, 32'd3, 4'd2, 32'd8);                   // SLL
        check(32'hFFFF_FFFF, 32'd1, 4'd3, 32'd1);          // SLT signed
        check(32'hFFFF_FFFF, 32'd1, 4'd4, 32'd0);          // SLTU
        check(32'hAA55_AA55, 32'h0F0F_0F0F, 4'd5, 32'hA55A_A55A); // XOR
        check(32'h8000_0000, 32'd1, 4'd6, 32'h4000_0000);  // SRL
        check(32'h8000_0000, 32'd1, 4'd7, 32'hC000_0000);  // SRA
        check(32'hAA00_0000, 32'h00BB_0000, 4'd8, 32'hAABB_0000); // OR
        check(32'hFFFF_00FF, 32'h0F0F_0F0F, 4'd9, 32'h0F0F_000F); // AND
        check(32'd5, 32'd5, 4'd1, 32'd0);                  // zero flag

        $display("Q9 SUMMARY: tests=%0d errors=%0d", tests, errors);
        if (errors == 0) $display("Q9 PASS");
        else $display("Q9 FAIL");
        $finish;
    end
endmodule
