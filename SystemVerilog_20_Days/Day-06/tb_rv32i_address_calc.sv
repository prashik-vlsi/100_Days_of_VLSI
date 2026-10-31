module tb_rv32i_address_calc;

    logic [31:0] rs1_data;
    logic [31:0] imm;
    logic [31:0] address;

    rv32i_address_calc DUT (
        .rs1_data (rs1_data),
        .imm      (imm),
        .address  (address)
    );

    initial begin

        $dumpfile("out.vcd");
        $dumpvars(0, tb_rv32i_address_calc);

        // Test 1: Positive offset
        rs1_data = 32'h00001000;
        imm      = 32'h00000020;
        #1;

        if (address == 32'h00001020)
            $display("PASS: Positive offset -> address = 0x%08h", address);
        else
            $display("FAIL: Expected 0x00001020, Got 0x%08h", address);


        // Test 2: Zero offset
        rs1_data = 32'h00002000;
        imm      = 32'h00000000;
        #1;

        if (address == 32'h00002000)
            $display("PASS: Zero offset     -> address = 0x%08h", address);
        else
            $display("FAIL: Expected 0x00002000, Got 0x%08h", address);


        // Test 3: Negative offset (-16)
        rs1_data = 32'h00001000;
        imm      = 32'hFFFFFFF0;
        #1;

        if (address == 32'h00000FF0)
            $display("PASS: Negative offset -> address = 0x%08h", address);
        else
            $display("FAIL: Expected 0x00000FF0, Got 0x%08h", address);


        // Test 4: 32-bit wraparound
        rs1_data = 32'hFFFFFFF0;
        imm      = 32'h00000020;
        #1;

        if (address == 32'h00000010)
            $display("PASS: Wraparound      -> address = 0x%08h", address);
        else
            $display("FAIL: Expected 0x00000010, Got 0x%08h", address);


        $finish;

    end

endmodule