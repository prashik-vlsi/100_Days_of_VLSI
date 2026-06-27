// =============================================================================
// Module Name: i2c_slave
// Description: Silicon-level, fully synthesizable I2C Peripheral Slave core.
//              Designed with metastability synchronizers, deglitching hook-points,
//              and clean tristate execution bounds. Suitable for ASIC/FPGA flow.
// Compatible Protocols: I2C Standard Mode (100 kbps), Fast Mode (400 kbps)
// Timing Assumptions: System 'clk' frequency >> 'scl' frequency (Minimum 10x)
// =============================================================================

module i2c_slave (
    // --- System Control ---
    input  wire       clk,      // System Clock (High-frequency mastering clock)
    input  wire       rst_n,    // Asynchronous Active-Low Reset (Silicon standard)

    // --- Physical I2C Bus Interface ---
    input  wire       scl,      // Raw SCL Input line from package pin
    input  wire       sda_in,   // Raw SDA Input line from package pin
    output reg        sda_out,  // Driven data payload back to package pin buffer
    output reg        sda_oen,  // Tristate Output Enable: 1 = Drive 'sda_out', 0 = High-Z (Pull-up)

    // --- Core Application Logic Register Interface ---
    input  wire [6:0] addr,     // Hardwired or OTP-configured 7-bit peripheral address
    input  wire [7:0] data_in   // Parallel input register data ready to be read by Master
);

    // -------------------------------------------------------------------------
    // FSM State Encoding (Explicit Binary Definition for Synthesis Opts)
    // -------------------------------------------------------------------------
    localparam STATE_IDLE  = 3'b000;
    localparam STATE_ADDR  = 3'b001;
    localparam STATE_ACK   = 3'b010;
    localparam STATE_DATA  = 3'b011;

    // -------------------------------------------------------------------------
    // Synchronizer Chain Registers (Metastability Mitigation)
    // -------------------------------------------------------------------------
    // (* ASYNC_REG = "TRUE" *) // Synthesis attribute for physical placement close together
    reg [2:0] scl_sync;
    reg [2:0] sda_sync;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scl_sync <= 3'b111;
            sda_sync <= 3'b111;
        end else begin
            scl_sync <= {scl_sync[1:0], scl};
            sda_sync <= {sda_sync[1:0], sda_in};
        end
    end

    // Assign stable, synchronized signals for current and delayed lookback states
    wire scl_curr = scl_sync[1]; // Double-flopped signal
    wire scl_prev = scl_sync[2]; // Triple-flopped signal for edge profiling
    wire sda_curr = sda_sync[1]; 
    wire sda_prev = sda_sync[2];

    // -------------------------------------------------------------------------
    // Combinatorial Edge & Bus Condition Monitors
    // -------------------------------------------------------------------------
    wire scl_rise  = (!scl_prev) && scl_curr; // SCL rising edge detection pulse
    wire scl_fall  = (scl_prev) && (!scl_curr); // SCL falling edge detection pulse
    
    // START Condition: SDA falls while SCL remains statically High
    wire start_det = (scl_curr && sda_prev && !sda_curr);
    
    // STOP Condition: SDA rises while SCL remains statically High
    wire stop_det  = (scl_curr && !sda_prev && sda_curr);

    // -------------------------------------------------------------------------
    // Peripheral Internal Control Storage
    // -------------------------------------------------------------------------
    reg [2:0] state;          // Current state tracking structural pointer
    reg [7:0] shift_reg;      // Serial-to-Parallel / Parallel-to-Serial Data engine
    reg [3:0] bit_cnt;        // I2C transaction framing counter (0 to 8 operations)
    reg       rw_bit;         // Latched Direction Flag: 1 = Master Read, 0 = Master Write
    reg       addr_matched;   // Statically latched validity bit for active transmission sequence

    // -------------------------------------------------------------------------
    // Main Finite State Machine (Single-Clock Synchronous Architecture)
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Synchronous Initialization Vector (Silicon Safe Mode)
            state        <= STATE_IDLE;
            sda_out      <= 1'b1;
            sda_oen      <= 1'b0; // Default to Input mode (High-Z)
            shift_reg    <= 8'h00;
            bit_cnt      <= 4'd0;
            rw_bit       <= 1'b0;
            addr_matched <= 1'b0;
        end else begin
            
            // Asynchronous Bus Condition Interception Rules
            if (start_det) begin
                state        <= STATE_ADDR;
                bit_cnt      <= 4'd0;
                addr_matched <= 1'b0;
                sda_oen      <= 1'b0; // Instantly yield control of the bus line
            end else if (stop_det) begin
                state        <= STATE_IDLE;
                sda_oen      <= 1'b0; // Structural return to line release standard
            end else begin

                case (state)

                    // ---------------------------------------------------------
                    // STATE_IDLE: Wait Loop Configuration
                    // ---------------------------------------------------------
                    STATE_IDLE: begin
                        sda_oen <= 1'b0; // Passive bus monitoring mode
                        sda_out <= 1'b1;
                        bit_cnt <= 4'd0;
                    end

                    // ---------------------------------------------------------
                    // STATE_ADDR: Frame collection & Identity validation
                    // ---------------------------------------------------------
                    STATE_ADDR: begin
                        if (scl_rise) begin
                            if (bit_cnt < 4'd7) begin
                                // Shift incoming bits directly into low tracking array
                                shift_reg <= {shift_reg[6:0], sda_curr};
                                bit_cnt   <= bit_cnt + 4'd1;
                            end else if (bit_cnt == 4'd7) begin
                                // 8th Bit: Capture the R/W bit direction parameter
                                rw_bit    <= sda_curr;
                                bit_cnt   <= bit_cnt + 4'd1;
                            end
                        end
                        
                        // Critical Transition Target: Evaluate address matching on 8th falling edge
                        if (scl_fall && (bit_cnt == 4'd8)) begin
                            bit_cnt <= 4'd0;
                            state   <= STATE_ACK;
                            
                            if (shift_reg[6:0] == addr) begin
                                addr_matched <= 1'b1;
                                sda_oen      <= 1'b1; // Grab ownership of the line
                                sda_out      <= 1'b0; // Clamp line low to acknowledge (ACK)
                            end else begin
                                addr_matched <= 1'b0;
                                sda_oen      <= 1'b0; // Let line float high (NACK)
                            end
                        end
                    end

                    // ---------------------------------------------------------
                    // STATE_ACK: Hold Acknowledge window steady over 9th clock duration
                    // ---------------------------------------------------------
                    STATE_ACK: begin
                        // Slave holds ACK setup valid until the 9th SCL clock cycle terminates
                        if (scl_fall) begin
                            if (addr_matched) begin
                                if (rw_bit) begin
                                    // Process Path: Master Read command confirmed
                                    state   <= STATE_DATA;
                                    sda_oen <= 1'b1;
                                    sda_out <= data_in[7]; // Setup MSB onto data bus pre-emptively
                                    bit_cnt <= 4'd1; 
                                end else begin
                                    // Process Path: Master Write command placeholder 
                                    // Default back to IDLE unless handling payload arrays
                                    state   <= STATE_IDLE;
                                    sda_oen <= 1'b0;
                                end
                            end else begin
                                state   <= STATE_IDLE;
                                sda_oen <= 1'b0;
                            end
                        end
                    end

                    // ---------------------------------------------------------
                    // STATE_DATA: Transmit internal byte array back to Master
                    // ---------------------------------------------------------
                    STATE_DATA: begin
                        if (scl_fall) begin
                            if (bit_cnt < 4'd8) begin
                                sda_oen <= 1'b1;
                                sda_out <= data_in[7 - bit_cnt]; // Unroll parallel array out to serial line
                                bit_cnt <= bit_cnt + 4'd1;
                            end else begin
                                // 8-Bits completely shifted out. Relinquish bus control immediately
                                // on the 8th falling edge to let Master frame its incoming ACK/NACK
                                sda_oen <= 1'b0; 
                                bit_cnt <= 4'd0;
                                state   <= STATE_IDLE; 
                            end
                        end
                    end

                    default: state <= STATE_IDLE;
                endcase
            end
        end
    end

endmodule