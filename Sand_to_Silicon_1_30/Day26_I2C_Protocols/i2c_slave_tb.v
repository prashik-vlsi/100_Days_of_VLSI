`timescale 1ns / 1ps

// =============================================================================
// Module Name: i2c_slave_tb
// Description: Golden Master Verification Simulation Environment for I2C Slave Core.
//              Emulates physical open-drain configurations with pull-ups.
// =============================================================================

module i2c_slave_tb;

    // --- Simulation System Drivers ---
    reg       clk;
    reg       rst_n;             // Updated to matching active-low standard
    reg       scl_master;
    reg       sda_master_dir;    // 1 = Master Asserting Line, 0 = Master High-Z
    reg       sda_master_out;
    reg [6:0] slave_addr_setting;
    reg [7:0] slave_data_to_send;

    // --- UUT Output Monitors ---
    wire      sda_out;
    wire      sda_oen;

    // --- Open-Drain Pull-Up Emulation Circuitry ---
    wire      scl = scl_master; 
    wire      sda = (sda_master_dir) ? sda_master_out : 
                    (sda_oen)        ? sda_out        : 1'b1; // Pulls to 1 if untouched

    // Device Under Test (DUT / UUT) Instantiation
    i2c_slave uut (
        .clk(clk),
        .rst_n(rst_n),
        .scl(scl),
        .sda_in(sda),
        .sda_out(sda_out),
        .sda_oen(sda_oen),
        .addr(slave_addr_setting),
        .data_in(slave_data_to_send)
    );

    // --- Clock Engine Configuration (50MHz Core Reference Frequency) ---
    always #10 clk = ~clk;

    // --- Standard Master Environment Framework Tasks ---
    localparam I2C_HALF_PERIOD = 2500; // 2.5 Microseconds defining standard 100KHz I2C tracking

    task i2c_init;
        begin
            scl_master     = 1'b1;
            sda_master_dir = 1'b1;
            sda_master_out = 1'b1; // Keep line steady in quiescent configuration
        end
    endtask

    task i2c_start;
        begin
            $display("[TIME: %0t ns] [MASTER] Transmitting START boundary pulse...", $time);
            sda_master_dir = 1'b1;
            sda_master_out = 1'b1;
            scl_master     = 1'b1;
            #I2C_HALF_PERIOD;
            sda_master_out = 1'b0; // SDA falls while SCL rests at '1'
            #I2C_HALF_PERIOD;
            scl_master     = 1'b0;
        end
    endtask

    task i2c_send_byte(input [7:0] byte_to_send);
        integer i;
        begin
            sda_master_dir = 1'b1;
            for (i = 7; i >= 0; i = i - 1) begin
                sda_master_out = byte_to_send[i];
                #I2C_HALF_PERIOD;
                scl_master     = 1'b1; 
                #I2C_HALF_PERIOD;
                scl_master     = 1'b0; 
            end
        end
    endtask

    task i2c_check_ack(output reg ack_received);
        begin
            sda_master_dir = 1'b0; // Release Master control line boundary to read ACK
            #I2C_HALF_PERIOD;
            scl_master     = 1'b1; // Assert 9th SCL sampling clock edge
            #100;                  
            ack_received   = !sda; // Capture low level status driven by slave core
            if (ack_received)
                $display("[TIME: %0t ns] [MASTER] STATUS_OK: Target device ACK received.", $time);
            else
                $display("[TIME: %0t ns] [MASTER] STATUS_ERR: Target device NACK read.", $time);
            #(I2C_HALF_PERIOD - 100);
            scl_master     = 1'b0;
        end
    endtask

    task i2c_read_byte(output [7:0] read_byte);
        integer i;
        begin
            sda_master_dir = 1'b0; 
            for (i = 7; i >= 0; i = i - 1) begin
                #I2C_HALF_PERIOD;
                scl_master   = 1'b1; 
                #100;
                read_byte[i] = sda;  
                #(I2C_HALF_PERIOD - 100);
                scl_master   = 1'b0;
            end
        end
    endtask

    task i2c_master_nack;
        begin
            $display("[TIME: %0t ns] [MASTER] Transmitting terminal NACK boundary...", $time);
            sda_master_dir = 1'b1;
            sda_master_out = 1'b1; 
            #I2C_HALF_PERIOD;
            scl_master     = 1'b1;
            #I2C_HALF_PERIOD;
            scl_master     = 1'b0;
        end
    endtask

    task i2c_stop;
        begin
            $display("[TIME: %0t ns] [MASTER] Transmitting STOP boundary pulse...", $time);
            sda_master_dir = 1'b1;
            sda_master_out = 1'b1;
            #I2C_HALF_PERIOD;
            sda_master_out = 1'b0; 
            #I2C_HALF_PERIOD;
            scl_master     = 1'b1;
            #I2C_HALF_PERIOD;
            sda_master_out = 1'b1; // SDA returns high during active SCL window
            #I2C_HALF_PERIOD;
        end
    endtask

    // --- Primary Verification Sequencer Pipeline ---
    reg        ack_status;
    reg [7:0]  received_data;
    reg [6:0]  target_address;
    reg        rnw_bit;

    initial begin
        // Hook up Icarus / GTKWave execution file assignments
        $dumpfile("i2c_simulation.vcd");
        $dumpvars(0, i2c_slave_tb);

        // Hardware Test Configuration Definitions
        clk                = 1'b0;
        rst_n              = 1'b0; // System enters reset state
        slave_addr_setting = 7'h5A;       
        slave_data_to_send = 8'hA5;       
        target_address     = 7'h5A;       
        rnw_bit            = 1'b1; // Read Mode
        
        i2c_init();
        #100;
        rst_n              = 1'b1; // Release physical reset structure
        #100;
        
        $display("==================================================================");
        $display("   Executing High-Reliability I2C Slave Validation Profile        ");
        $display("==================================================================");

        i2c_start();
        
        // Execute address distribution sequencing {7'h5A, 1'b1} -> 8'hB5
        i2c_send_byte({target_address, rnw_bit});
        i2c_check_ack(ack_status);

        if (ack_status) begin
            i2c_read_byte(received_data);
            i2c_master_nack();
        end

        i2c_stop();

        // Architectural Pass Criteria Evaluation Loop
        $display("==================================================================");
        if (received_data === slave_data_to_send) begin
            $display("   VERIFICATION RESULT: PASSED ");
            $display("   Received Payload: 8'h%h matched expected Array Output.", received_data);
        end else begin
            $display("   VERIFICATION RESULT: FAILED ");
            $display("   Critical Payload Mismatch Detected: Read 8'h%h", received_data);
        end
        $display("==================================================================");

        $finish;
    end
    // -------------------------------------------------------------------------
    // Terminal Result Monitor (Fixed Matrix Alignment)
    // -------------------------------------------------------------------------
    initial begin
        // Print the header line first
        $display("\nTerminal Result");
        $display("----------------------------------------------------------------------------------------------------------------");
        $display("Time    | rst_n | state | bit_cnt | scl | sda | sda_oen | sda_out | addr_matched | data_out");
        $display("----------------------------------------------------------------------------------------------------------------");
        
        // Using %-7d ensures time stays cleanly aligned without distorting the layout
        $monitor("Time=%-7d | rst_n=%b | state=%b | bit_cnt=%d   | scl=%b   | sda=%b   | sda_oen=%b     | sda_out=%b     | addr_matched=%b    | data_out=%h", 
                 $time, 
                 rst_n, 
                 uut.state,         
                 uut.bit_cnt,       
                 scl, 
                 sda, 
                 sda_oen, 
                 sda_out,
                 uut.addr_matched,
                 received_data);
    end

endmodule