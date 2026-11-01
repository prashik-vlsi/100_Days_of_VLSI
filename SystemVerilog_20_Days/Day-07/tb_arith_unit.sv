module tb_arith_unit;
    logic [31:0] a, b, result;
    logic sub;
    integer errors = 0;
    integer tests = 0;

    arith_unit dut (.*);

    task automatic check(
        input logic [31:0] ta,
        input logic [31:0] tb,
        input logic tsub,
        input logic [31:0] expected
    );
        begin
            a = ta; b = tb; sub = tsub;
            #1;
            tests++;
            if (result !== expected) begin
                $display("FAIL a=%h b=%h sub=%b got=%h expected=%h",
                         a, b, sub, result, expected);
                errors++;
            end else begin
                $display("PASS a=%h b=%h sub=%b result=%h",
                         a, b, sub, result);
            end
        end
    endtask

    initial begin
        $display("=== Q6 RV32I ADD/SUB UNIT ===");
        check(32'd10, 32'd20, 1'b0, 32'd30);
        check(32'd100, 32'd50, 1'b0, 32'd150);
        check(32'hFFFF_FFFF, 32'd1, 1'b0, 32'h0000_0000);
        check(32'h7FFF_FFFF, 32'd1, 1'b0, 32'h8000_0000);
        check(32'd50, 32'd20, 1'b1, 32'd30);
        check(32'd20, 32'd50, 1'b1, 32'hFFFF_FFE2);
        check(32'd100, 32'd100, 1'b1, 32'd0);
        check(32'h8000_0000, 32'd1, 1'b1, 32'h7FFF_FFFF);
        check(32'd0, 32'd0, 1'b0, 32'd0);
        check(32'd0, 32'd1, 1'b1, 32'hFFFF_FFFF);

        $display("Q6 SUMMARY: tests=%0d errors=%0d", tests, errors);
        if (errors == 0) $display("Q6 PASS");
        else $display("Q6 FAIL");
        $finish;
    end
endmodule
