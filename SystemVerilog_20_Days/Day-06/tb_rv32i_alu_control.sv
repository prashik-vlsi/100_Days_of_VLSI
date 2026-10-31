module tb_rv32i_alu_control;

    logic [2:0] funct3;
    logic [3:0] alu_control;

    rv32i_alu_control DUT (
        .funct3      (funct3),
        .alu_control (alu_control)
    );

    initial begin

        $dumpfile("out.vcd");
        $dumpvars(0, tb_rv32i_alu_control);

        funct3 = 3'b000;
        #1;
        if (alu_control == 4'b0000)
            $display("PASS: funct3=000 -> ADD");
        else
            $display("FAIL: ADD decode");


        funct3 = 3'b010;
        #1;
        if (alu_control == 4'b0010)
            $display("PASS: funct3=010 -> SLT");
        else
            $display("FAIL: SLT decode");


        funct3 = 3'b100;
        #1;
        if (alu_control == 4'b0100)
            $display("PASS: funct3=100 -> XOR");
        else
            $display("FAIL: XOR decode");


        funct3 = 3'b110;
        #1;
        if (alu_control == 4'b0110)
            $display("PASS: funct3=110 -> OR");
        else
            $display("FAIL: OR decode");


        funct3 = 3'b111;
        #1;
        if (alu_control == 4'b0111)
            $display("PASS: funct3=111 -> AND");
        else
            $display("FAIL: AND decode");

        $finish;

    end

endmodule