module tb_imm_gen;
    logic [31:0] instr;
    logic [31:0] imm;
    integer errors = 0;
    integer tests = 0;

    imm_gen dut (.*);

    task automatic check(
        input logic [31:0] test_instr,
        input logic [31:0] expected_imm
    );
        begin
            instr = test_instr; #1; tests++;
            if (imm !== expected_imm) begin
                $display("FAIL instr=%h imm=%h expected=%h", instr, imm, expected_imm);
                errors++;
            end else $display("PASS instr=%h imm=%h", instr, imm);
        end
    endtask

    initial begin
        $display("=== Q8 IMMEDIATE GENERATOR / LATCH PREVENTION ===");
        // ADDI x1,x0,5 -> I immediate = 5
        check(32'h00500093, 32'd5);
        // LW x2,0(x0) -> I immediate = 0
        check(32'h00002103, 32'd0);
        // SW x2,4(x1) -> S immediate = 4
        check(32'h0020A223, 32'd4);
        // BEQ x1,x2,0 -> B immediate = 0
        check(32'h00208063, 32'd0);
        // LUI x1,0x12345 -> U immediate = 0x12345000
        check(32'h123450B7, 32'h12345000);
        // JAL x1,0 -> J immediate = 0
        check(32'h000000EF, 32'd0);
        // Unsupported opcode -> default zero
        check(32'h0000007F, 32'd0);

        $display("Q8 SUMMARY: tests=%0d errors=%0d", tests, errors);
        if (errors == 0) $display("Q8 PASS");
        else $display("Q8 FAIL");
        $finish;
    end
endmodule
