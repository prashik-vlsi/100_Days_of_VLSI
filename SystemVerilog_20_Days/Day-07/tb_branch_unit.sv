module tb_branch_unit;
    logic [31:0] pc, rs1, rs2, branch_imm;
    logic [2:0] funct3;
    logic is_branch;
    logic branch_taken;
    logic [31:0] next_pc;
    integer errors = 0;
    integer tests = 0;

    branch_unit dut (.*);

    task automatic check(
        input logic [31:0] tpc,
        input logic [31:0] a,
        input logic [31:0] b,
        input logic [31:0] imm,
        input logic [2:0] f3,
        input logic t_is_branch,
        input logic expected_taken,
        input logic [31:0] expected_pc
    );
        begin
            pc = tpc; rs1 = a; rs2 = b; branch_imm = imm;
            funct3 = f3; is_branch = t_is_branch;
            #1; tests++;
            if ((branch_taken !== expected_taken) || (next_pc !== expected_pc)) begin
                $display("FAIL pc=%h a=%h b=%h f3=%b is_branch=%b taken=%b next_pc=%h",
                         pc, rs1, rs2, funct3, is_branch, branch_taken, next_pc);
                $display("     expected taken=%b next_pc=%h", expected_taken, expected_pc);
                errors++;
            end else $display("PASS taken=%b next_pc=%h", branch_taken, next_pc);
        end
    endtask

    initial begin
        $display("=== Q10 INTEGRATED RV32I BRANCH UNIT ===");
        check(32'h1000, 32'd7, 32'd7, 32'd16, 3'b000, 1'b1, 1'b1, 32'h1010); // BEQ taken
        check(32'h1000, 32'd7, 32'd8, 32'd16, 3'b000, 1'b1, 1'b0, 32'h1004); // BEQ not taken
        check(32'h2000, 32'hFFFF_FFFF, 32'd1, 32'd12, 3'b100, 1'b1, 1'b1, 32'h200C); // BLT
        check(32'h3000, 32'hFFFF_FFFF, 32'd1, 32'd12, 3'b110, 1'b1, 1'b0, 32'h3004); // BLTU
        check(32'h4000, 32'd1, 32'd1, 32'd8, 3'b000, 1'b0, 1'b0, 32'h4004); // not branch instr

        $display("Q10 SUMMARY: tests=%0d errors=%0d", tests, errors);
        if (errors == 0) $display("Q10 PASS");
        else $display("Q10 FAIL");
        $finish;
    end
endmodule
