
module tb_rv32i_instr_info;

    logic [31:0] instr;

    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic is_branch;
    logic is_itype_alu;
    logic is_jal;
    logic is_load;
    logic is_lui;
    logic is_rtype;
    logic is_store;
    logic writes_rd;
    logic uses_rs2;

    integer errors = 0;
    integer test_count = 0;
    integer class_count;

    // DUT instantiation
    rv32i_instr_info dut (
        .instr        (instr),
        .opcode       (opcode),
        .rd           (rd),
        .rs1          (rs1),
        .rs2          (rs2),
        .funct3       (funct3),
        .funct7       (funct7),
        .is_branch    (is_branch),
        .is_itype_alu (is_itype_alu),
        .is_jal       (is_jal),
        .is_load      (is_load),
        .is_lui       (is_lui),
        .is_rtype     (is_rtype),
        .is_store     (is_store),
        .writes_rd    (writes_rd),
        .uses_rs2     (uses_rs2)
    );

    // Check instruction field extraction
    task automatic check_fields;
        begin
            if (opcode !== instr[6:0]) begin
                $error("Opcode extraction FAILED");
                errors++;
            end

            if (rd !== instr[11:7]) begin
                $error("rd extraction FAILED");
                errors++;
            end

            if (funct3 !== instr[14:12]) begin
                $error("funct3 extraction FAILED");
                errors++;
            end

            if (rs1 !== instr[19:15]) begin
                $error("rs1 extraction FAILED");
                errors++;
            end

            if (rs2 !== instr[24:20]) begin
                $error("rs2 extraction FAILED");
                errors++;
            end

            if (funct7 !== instr[31:25]) begin
                $error("funct7 extraction FAILED");
                errors++;
            end
        end
    endtask

    // Check instruction classification and control signals
    task automatic check_decode(
        input logic exp_branch,
        input logic exp_itype,
        input logic exp_jal,
        input logic exp_load,
        input logic exp_lui,
        input logic exp_rtype,
        input logic exp_store,
        input logic exp_writes_rd,
        input logic exp_uses_rs2
    );
        begin
            test_count++;

            #1;

            check_fields();

            // Instruction classification check
            if ({is_branch, is_itype_alu, is_jal, is_load,
                 is_lui, is_rtype, is_store} !==
                {exp_branch, exp_itype, exp_jal, exp_load,
                 exp_lui, exp_rtype, exp_store}) begin

                $error("Instruction classification FAILED: %h", instr);
                errors++;
            end

            // Control signal checks
            if (writes_rd !== exp_writes_rd) begin
                $error("writes_rd FAILED: %h", instr);
                errors++;
            end

            if (uses_rs2 !== exp_uses_rs2) begin
                $error("uses_rs2 FAILED: %h", instr);
                errors++;
            end

            // Mutual exclusivity check
            class_count = $countones({
                is_branch,
                is_itype_alu,
                is_jal,
                is_load,
                is_lui,
                is_rtype,
                is_store
            });

            if (class_count > 1) begin
                $error("Multiple instruction classes detected: %h", instr);
                errors++;
            end

            if (errors == 0)
                $display("PASS: Instruction %h", instr);
        end
    endtask

    initial begin

        $display("\n========== RV32I INSTRUCTION DECODER TEST ==========\n");

        // 1. R-type: ADD x3, x1, x2
        instr = 32'h002081B3;
        check_decode(0, 0, 0, 0, 0, 1, 0, 1, 1);

        // 2. I-type ALU: ADDI x1, x0, 5
        instr = 32'h00500093;
        check_decode(0, 1, 0, 0, 0, 0, 0, 1, 0);

        // 3. Load: LW x2, 0(x0)
        instr = 32'h00002103;
        check_decode(0, 0, 0, 1, 0, 0, 0, 1, 0);

        // 4. Store: SW x2, 4(x1)
        instr = 32'h0020A223;
        check_decode(0, 0, 0, 0, 0, 0, 1, 0, 1);

        // 5. Branch: BEQ x1, x2, 0
        instr = 32'h00208063;
        check_decode(1, 0, 0, 0, 0, 0, 0, 0, 1);

        // 6. LUI: LUI x1, 0x12345
        instr = 32'h123450B7;
        check_decode(0, 0, 0, 0, 1, 0, 0, 1, 0);

        // 7. JAL: JAL x1, 0
        instr = 32'h000000EF;
        check_decode(0, 0, 1, 0, 0, 0, 0, 1, 0);

        // 8. Unsupported opcode
        instr = 32'h0000007F;
        check_decode(0, 0, 0, 0, 0, 0, 0, 0, 0);

        // 9. R-type instruction writing to x0
        instr = 32'h00208033;
        check_decode(0, 0, 0, 0, 0, 1, 0, 1, 1);

        // Final test summary
        $display("\n========== TEST SUMMARY ==========");
        $display("Total test cases : %0d", test_count);
        $display("Total errors     : %0d", errors);

        if (errors == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILED");

        $display("==================================\n");

        $finish;
    end

endmodule
