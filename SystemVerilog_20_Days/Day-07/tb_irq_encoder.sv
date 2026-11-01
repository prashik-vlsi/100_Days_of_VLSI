
module tb_irq_encoder;

    logic [7:0] irq;
    logic [2:0] irq_id;
    logic       valid;

    integer total_tests = 0;
    integer errors = 0;

    // DUT instantiation
    irq_encoder dut (
        .irq     (irq),
        .irq_id  (irq_id),
        .valid   (valid)
    );

    // Self-checking task
    task automatic check_irq(
        input logic [7:0] test_irq,
        input logic [2:0] expected_id,
        input logic       expected_valid
    );

        begin
            irq = test_irq;
            #1;

            total_tests++;

            if ((irq_id !== expected_id) ||
                (valid  !== expected_valid)) begin

                $display("FAIL: IRQ=%b | ID=%b | Valid=%b | Expected ID=%b | Expected Valid=%b",
                         irq, irq_id, valid, expected_id, expected_valid);

                errors++;

            end
            else begin

                $display("PASS: IRQ=%b | ID=%b | Valid=%b",
                         irq, irq_id, valid);

            end
        end

    endtask

    initial begin

        $dumpfile("out.vcd");
        $dumpvars(0, tb_irq_encoder);


        $display("======================================");
        $display(" RV32I INTERRUPT PRIORITY ENCODER TEST");
        $display("======================================");

        // Test 1: No interrupt
        check_irq(8'b00000000, 3'd0, 1'b0);

        // Tests 2-9: Individual interrupt requests
        check_irq(8'b00000001, 3'd0, 1'b1);
        check_irq(8'b00000010, 3'd1, 1'b1);
        check_irq(8'b00000100, 3'd2, 1'b1);
        check_irq(8'b00001000, 3'd3, 1'b1);
        check_irq(8'b00010000, 3'd4, 1'b1);
        check_irq(8'b00100000, 3'd5, 1'b1);
        check_irq(8'b01000000, 3'd6, 1'b1);
        check_irq(8'b10000000, 3'd7, 1'b1);

        // Tests 10-13: Multiple simultaneous requests
        check_irq(8'b00001010, 3'd3, 1'b1);
        check_irq(8'b00101000, 3'd5, 1'b1);
        check_irq(8'b11000010, 3'd7, 1'b1);
        check_irq(8'b10000001, 3'd7, 1'b1);

        // Test 14: Multiple requests, highest priority wins
        check_irq(8'b10100010, 3'd7, 1'b1);

        // Test summary
        $display("\n======================================");
        $display(" TEST SUMMARY");
        $display("======================================");

        $display("Total test cases : %0d", total_tests);
        $display("Total errors     : %0d", errors);

        if (errors == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILED");

        $finish;

    end

endmodule
