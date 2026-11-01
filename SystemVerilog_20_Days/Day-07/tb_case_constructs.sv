module tb_case_constructs;
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;
    logic [3:0] alu_op;
    logic illegal;

    logic [3:0] irq;
    logic [1:0] irq_id;
    logic irq_valid;

    integer errors = 0;
    integer tests = 0;

    alu_decode adut (.*);
    irq_priority_case idut (
        .irq(irq), .irq_id(irq_id), .valid(irq_valid)
    );

    task automatic check_alu(
        input logic [6:0] op,
        input logic [2:0] f3,
        input logic [6:0] f7,
        input logic [3:0] expected_alu,
        input logic expected_illegal
    );
        begin
            opcode = op; funct3 = f3; funct7 = f7;
            #1; tests++;
            if ((alu_op !== expected_alu) || (illegal !== expected_illegal)) begin
                $display("FAIL ALU decode opcode=%b funct3=%b funct7=%b got=%h illegal=%b",
                         opcode, funct3, funct7, alu_op, illegal);
                errors++;
            end else $display("PASS ALU decode alu_op=%h illegal=%b", alu_op, illegal);
        end
    endtask

    task automatic check_irq(
        input logic [3:0] req,
        input logic [1:0] expected_id,
        input logic expected_valid
    );
        begin
            irq = req; #1; tests++;
            if ((irq_id !== expected_id) || (irq_valid !== expected_valid)) begin
                $display("FAIL priority case irq=%b got id=%b valid=%b",
                         irq, irq_id, irq_valid);
                errors++;
            end else $display("PASS priority case irq=%b id=%b valid=%b",
                              irq, irq_id, irq_valid);
        end
    endtask

    initial begin
        $display("=== Q7 CASE CONSTRUCTS ===");
        // alu_op: ADD=0, SUB=1, SLL=2, SLT=3, SLTU=4,
        //         XOR=5, SRL=6, SRA=7, OR=8, AND=9
        check_alu(7'b0110011, 3'b000, 7'b0000000, 4'd0, 1'b0); // ADD
        check_alu(7'b0110011, 3'b000, 7'b0100000, 4'd1, 1'b0); // SUB
        check_alu(7'b0010011, 3'b111, 7'b0000000, 4'd9, 1'b0); // ANDI
        check_alu(7'b0110011, 3'b101, 7'b0100000, 4'd7, 1'b0); // SRA
        check_alu(7'b0000011, 3'b010, 7'b0000000, 4'd0, 1'b1); // unsupported opcode

        check_irq(4'b0000, 2'd0, 1'b0);
        check_irq(4'b0001, 2'd0, 1'b1);
        check_irq(4'b0110, 2'd2, 1'b1);
        check_irq(4'b1011, 2'd3, 1'b1);

        $display("Q7 SUMMARY: tests=%0d errors=%0d", tests, errors);
        if (errors == 0) $display("Q7 PASS");
        else $display("Q7 FAIL");
        $finish;
    end
endmodule
