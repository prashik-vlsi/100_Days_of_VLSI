module tb_branch_comp;
    logic [31:0] rs1, rs2;
    logic [2:0] funct3;
    logic branch_taken;
    integer errors = 0;
    integer tests = 0;

    branch_comp dut (.*);

    task automatic check(
        input logic [31:0] a,
        input logic [31:0] b,
        input logic [2:0] f3,
        input logic expected
    );
        begin
            rs1 = a; rs2 = b; funct3 = f3;
            #1;
            tests++;
            if (branch_taken !== expected) begin
                $display("FAIL rs1=%h rs2=%h funct3=%b got=%b expected=%b",
                         rs1, rs2, funct3, branch_taken, expected);
                errors++;
            end else begin
                $display("PASS rs1=%h rs2=%h funct3=%b taken=%b",
                         rs1, rs2, funct3, branch_taken);
            end
        end
    endtask

    initial begin
        $display("=== Q5 RV32I BRANCH COMPARATOR ===");
        check(32'd10, 32'd10, 3'b000, 1'b1); // BEQ
        check(32'd10, 32'd20, 3'b000, 1'b0);
        check(32'd10, 32'd20, 3'b001, 1'b1); // BNE
        check(32'd10, 32'd10, 3'b001, 1'b0);
        check(32'hFFFF_FFFF, 32'd1, 3'b100, 1'b1); // BLT signed: -1 < 1
        check(32'hFFFF_FFFF, 32'd1, 3'b101, 1'b0); // BGE signed
        check(32'hFFFF_FFFF, 32'd1, 3'b110, 1'b0); // BLTU unsigned
        check(32'hFFFF_FFFF, 32'd1, 3'b111, 1'b1); // BGEU unsigned
        check(32'd20, 32'd10, 3'b100, 1'b0);
        check(32'd20, 32'd10, 3'b101, 1'b1);
        check(32'd10, 32'd20, 3'b010, 1'b0); // unsupported funct3

        $display("Q5 SUMMARY: tests=%0d errors=%0d", tests, errors);
        if (errors == 0) $display("Q5 PASS");
        else $display("Q5 FAIL");
        $finish;
    end
endmodule
