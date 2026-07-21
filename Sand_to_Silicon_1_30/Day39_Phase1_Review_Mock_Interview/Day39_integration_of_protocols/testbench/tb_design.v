`timescale 1ns/1ps

module tb_design;

    reg        PCLK;
    reg        PRESETn;
    reg [11:0] PADDR;
    reg        PSEL;
    reg        PENABLE;
    reg        PWRITE;
    reg [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire        PREADY;
    reg        RX;

    parameter CLK_PERIOD = 10;

    my_design dut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PADDR(PADDR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .RX(RX)
    );

    always #(CLK_PERIOD/2) PCLK = ~PCLK;

    initial begin
        // Setup waveform dumping
        $dumpfile("simulation.vcd");
        $dumpvars(0, tb_design);

        PCLK    = 0;
        PRESETn = 0;
        PADDR   = 0;
        PSEL    = 0;
        PENABLE = 0;
        PWRITE  = 0;
        PWDATA  = 0;
        RX      = 1;
        
        #(CLK_PERIOD * 5);
        PRESETn = 1;
        #(CLK_PERIOD * 2);

        apb_write(12'h000, 32'd16);
        #(CLK_PERIOD * 5);

        send_uart_byte(8'hA5);
        #(CLK_PERIOD * 400); 

        apb_read(12'h008);

        #(CLK_PERIOD * 20);
        $finish;
    end

    task apb_write(input [11:0] addr, input [31:0] data);
    begin
        @(posedge PCLK);
        PADDR   <= addr;
        PWDATA  <= data;
        PWRITE  <= 1'b1;
        PSEL    <= 1'b1;
        PENABLE <= 1'b0;

        @(posedge PCLK);
        PENABLE <= 1'b1;

        wait (PREADY);

        @(posedge PCLK);
        PSEL    <= 1'b0;
        PENABLE <= 1'b0;
        PWRITE  <= 1'b0;
        PADDR   <= 12'd0;
        PWDATA  <= 32'd0;
    end
    endtask

    task apb_read(input [11:0] addr);
    begin
        @(posedge PCLK);
        PADDR   <= addr;
        PWRITE  <= 1'b0;
        PSEL    <= 1'b1;
        PENABLE <= 1'b0;

        @(posedge PCLK);
        PENABLE <= 1'b1;

        wait (PREADY);
        $display("[%0t] APB READ : ADDR = %h DATA = %h", $time, addr, PRDATA);

        @(posedge PCLK);
        PSEL    <= 1'b0;
        PENABLE <= 1'b0;
        PADDR   <= 12'd0;
    end
    endtask

    task send_uart_byte(input [7:0] data);
        integer i;
        reg parity_bit;
        begin
            // Calculate even parity (XOR all bits together)
            parity_bit = ^data; 

            @(posedge PCLK);
            RX = 1'b0; // Start bit
            repeat (256) @(posedge PCLK);
            
            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                RX = data[i];
                repeat (256) @(posedge PCLK);
            end
            
            // --- FIX: Send the missing Parity Bit ---
            RX = parity_bit;
            repeat (256) @(posedge PCLK);
            
            // Stop bit
            RX = 1'b1;
            repeat (256) @(posedge PCLK);
            
            $display("[%0t] TB: Finished streaming UART Byte 8'h%h", $time, data);
        end
    endtask

endmodule