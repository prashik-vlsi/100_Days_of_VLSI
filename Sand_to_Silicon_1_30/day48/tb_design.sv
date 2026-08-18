`timescale 1ns/1ps

module tb_mux4_1();


    // ========== SIGNALS ==========
    logic [7:0] a, b, c, d;
    logic [1:0] sel;
    logic [7:0] out;
    
    // ========== INSTANTIATE DUT (EXPLICIT PORT MAPPING) ==========
    mux4_1 uut(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sel(sel),
        .out(out)
    );
    
    // ========== WAVEFORM DUMP ==========
    initial begin
        $dumpfile("mux.vcd");
        $dumpvars(0, tb_mux4_1);
    end
    
    // ========== TEST LOGIC ==========
    initial begin

    $display("======================== PERFORM BY PRASHIK WANKHEDE==================");
        $display("================= TESTBENCH 4:1 MUX =================");
        
        // Initialize inputs
        a = 8'hAA;
        b = 8'hBB;
        c = 8'hCC;
        d = 8'hDD;
        
        // TEST 1: SEL = 00 (select a)
        $display("\nTEST 1: SEL = 00 (select a)");
        sel = 2'b00;
        #10;
        if(out == a)
            $display("  ✓ Test 1 passed successfully\n");
        else
            $display("  ✗ Test 1 FAILED: expected %h, got %h\n", a, out);
        
        // TEST 2: SEL = 01 (select b)
        $display("TEST 2: SEL = 01 (select b)");
        sel = 2'b01;
        #10;
        if(out == b)
            $display("  ✓ Test 2 passed successfully\n");
        else
            $display("  ✗ Test 2 FAILED: expected %h, got %h\n", b, out);
        
        // TEST 3: SEL = 10 (select c)
        $display("TEST 3: SEL = 10 (select c)");
        sel = 2'b10;
        #10;
        if(out == c)
            $display("  ✓ Test 3 passed successfully\n");
        else
            $display("  ✗ Test 3 FAILED: expected %h, got %h\n", c, out);
        
        // TEST 4: SEL = 11 (select d)
        $display("TEST 4: SEL = 11 (select d)");
        sel = 2'b11;
        #10;
        if(out == d)
            $display("  ✓ Test 4 passed successfully\n");
        else
            $display("  ✗ Test 4 FAILED: expected %h, got %h\n", d, out);
        
        $display("================= ALL TESTS COMPLETED =================");
        $display("=================== NO ERRORS =======================\n");
        $finish;
    end

endmodule