module tb_rv32i_branch_decision;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic        branch_enable;
    logic        branch_taken;

    rv32i_branch_decision DUT (
        .rs1_data      (rs1_data),
        .rs2_data      (rs2_data),
        .branch_enable (branch_enable),
        .branch_taken  (branch_taken)
    );

    initial begin

        $dumpfile("out.vcd");
        $dumpvars(0, tb_rv32i_branch_decision);

        // Test 1: Branch enabled and operands equal
        rs1_data      = 32'd50;
        rs2_data      = 32'd50;
        branch_enable = 1'b1;
        #1;

        if (branch_taken == 1'b1)
            $display("PASS: Equal operands -> branch taken");
        else
            $display("FAIL: Expected branch_taken = 1");


        // Test 2: Branch enabled but operands different
        rs1_data      = 32'd50;
        rs2_data      = 32'd25;
        branch_enable = 1'b1;
        #1;

        if (branch_taken == 1'b0)
            $display("PASS: Different operands -> branch not taken");
        else
            $display("FAIL: Expected branch_taken = 0");


        // Test 3: Branch disabled
        rs1_data      = 32'd100;
        rs2_data      = 32'd100;
        branch_enable = 1'b0;
        #1;

        if (branch_taken == 1'b0)
            $display("PASS: Branch disabled -> branch not taken");
        else
            $display("FAIL: Expected branch_taken = 0");

        $finish;

    end

endmodule