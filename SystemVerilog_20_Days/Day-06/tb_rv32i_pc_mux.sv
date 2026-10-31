module tb_rv32i_pc_mux;
    logic [31:0] pc_plus_4;
    logic [31:0] branch_target;
    logic        pc_src;
    logic [31:0] next_pc;

rv32i_pc_mux DUT(
    .pc_plus_4(pc_plus_4),
    .branch_target(branch_target),
    .pc_src(pc_src),
    .next_pc(next_pc)
);

initial begin

    pc_plus_4 = 32'h00001004;
    branch_target = 32'h00002000;

    $dumpfile("out.vcd");
    $dumpvars(0, tb_rv32i_pc_mux);

    pc_src = 1'b0;
    #1;

    if (next_pc == 32'h00001004)begin
        $display("PASS: The output is: %0d", next_pc);
    end
    else begin
        $display("The Test Failed");
    end
    pc_src=1'b1;
    #1;

    if (next_pc == 32'h00002000) begin
        $display("PASS: The output is: %0d", next_pc);
    end

    else begin
        $display("The test failed");
    end

end
endmodule