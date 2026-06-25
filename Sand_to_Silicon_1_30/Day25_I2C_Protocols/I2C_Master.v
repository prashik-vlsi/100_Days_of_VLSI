`timescale 1ns/1ps

// =============================================================================
// I2C Master - Single-byte Write / Single-byte Read
//
// Clock:   50 MHz system clock  → clk period = 20 ns
// SCL:     each bit = 256 clk cycles = 5.12 µs  → ~195 kHz (Standard-mode)
//
// State Encoding: One-Hot (8-bit)
// Open-drain model: driving 0 pulls bus low; releasing (1'bz) lets pull-up win
// =============================================================================

module I2C_Master #(
    parameter [7:0] IDLE     = 8'b00000001,
    parameter [7:0] START    = 8'b00000010,
    parameter [7:0] ADDR_TX  = 8'b00000100,
    parameter [7:0] ADDR_ACK = 8'b00001000,
    parameter [7:0] DATA_TX  = 8'b00010000,
    parameter [7:0] DATA_ACK = 8'b00100000,
    parameter [7:0] STOP     = 8'b01000000,
    parameter [7:0] DATA_RX  = 8'b10000000
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire       rw,          // 0 = Write, 1 = Read
    input  wire [6:0] addr,
    input  wire [7:0] wdata,
    inout  wire       sda,
    inout  wire       scl,
    output reg  [7:0] rdata,
    output reg        done,
    output reg        ack_err
);

    // -------------------------------------------------------------------------
    // Internal registers
    // -------------------------------------------------------------------------
    reg [7:0] state;
    reg [7:0] next_state;
    reg [2:0] bit_cnt;
    reg [7:0] clk_cnt;

    reg sda_oe;     // 1 = master drives SDA
    reg sda_out;    // value master puts on SDA when sda_oe=1
    reg scl_oe;     // 1 = master pulls SCL low

    // -------------------------------------------------------------------------
    // Open-drain bus assignments
    // -------------------------------------------------------------------------
    assign sda = sda_oe ? sda_out : 1'bz;
    assign scl = scl_oe ? 1'b0    : 1'bz;

    // Clock-stretching: slave holds SCL low while master has released it
    wire scl_stretched = (!scl_oe) && (scl == 1'b0);


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= IDLE;
            clk_cnt <= 8'd0;
            bit_cnt <= 3'd0;
            rdata   <= 8'd0;
            done    <= 1'b0;
            ack_err <= 1'b0;
            scl_oe  <= 1'b0;
        end else begin

            // ------------------------------------------------------------------
            // Clock-stretching hold: freeze everything
            // ------------------------------------------------------------------
            if (scl_stretched) begin
                // hold all registers; do nothing
            end else begin

                // ---- Advance state machine ----
                state <= next_state;

                // ---- Clock counter ----
                // Reset when state changes OR on natural rollover
                if (state != next_state) begin
                    clk_cnt <= 8'd0;
                end else if (clk_cnt == 8'd255) begin
                    clk_cnt <= 8'd0;
                end else begin
                    clk_cnt <= clk_cnt + 1'b1;
                end

                // ---- Bit counter ----
                // Reset in IDLE or when entering a new bit-shifting state.
                // Increment at the end of each bit period (clk_cnt==255).
                if (state == IDLE) begin
                    bit_cnt <= 3'd0;
                end else if (state != next_state &&
                             (next_state == ADDR_TX ||
                              next_state == DATA_TX ||
                              next_state == DATA_RX)) begin
                    bit_cnt <= 3'd0;          // entering a new byte phase
                end else if (clk_cnt == 8'd255) begin
                    if (state == ADDR_TX ||
                        state == DATA_TX ||
                        state == DATA_RX) begin
                        bit_cnt <= bit_cnt + 1'b1; // wraps 7→0 naturally
                    end
                end

                // ---- Sample SDA for read data (mid SCL-high window) ----
                // SCL is high when clk_cnt >= 128; sample at mid-point = 192
                if (state == DATA_RX && clk_cnt == 8'd192) begin
                    rdata <= {rdata[6:0], sda}; // MSB first
                end

                // ---- Sample ACK (mid SCL-high window of ACK bit) ----
                if ((state == ADDR_ACK || state == DATA_ACK) &&
                     clk_cnt == 8'd192) begin
                    ack_err <= sda;  // slave drives 0=ACK, 1=NACK
                end else if (state == IDLE && start) begin
                    ack_err <= 1'b0; // clear at start of new transaction
                end

                // ---- Done pulse ----
                done <= (state == STOP && clk_cnt == 8'd255);

                // ---- SCL generation ----
                // SCL is released (high via pull-up) during IDLE / START / STOP
                // so that START/STOP conditions can be generated on SDA.
                // During all data/ack states: low for first half, high for second.
                if (next_state == IDLE ||
                    next_state == START ||
                    next_state == STOP) begin
                    scl_oe <= 1'b0;
                end else begin
                    // Use clk_cnt of the *current* cycle that will advance next
                    // clock — use next-cycle value to register cleanly.
                    // We want SCL low for clk_cnt 0..127 (after state entry)
                    // and high for 128..255.
                    if (state != next_state) begin
                        // First cycle of new state → start pulling low
                        scl_oe <= 1'b1;
                    end else if (clk_cnt == 8'd127) begin
                        scl_oe <= 1'b0; // release → SCL rises
                    end else if (clk_cnt == 8'd255) begin
                        scl_oe <= 1'b1; // pull low for next bit
                    end
                    // else hold current scl_oe
                end

            end // !scl_stretched
        end // rst_n
    end

    // =========================================================================
    // Combinational Block — next_state, sda_oe, sda_out
    // =========================================================================
    always @(*) begin
        // Safe defaults
        next_state = state;
        sda_oe     = 1'b0;
        sda_out    = 1'b1; // drive high when OE (safe default)

        case (state)

            // ------------------------------------------------------------------
            IDLE: begin
                sda_oe  = 1'b0;
                if (start) next_state = START;
            end

            // ------------------------------------------------------------------
            // START condition: SDA falls while SCL is high
            // Master holds SDA low for the entire START state period,
            // SCL is released (high) by the scl_oe logic above.
            // ------------------------------------------------------------------
            START: begin
                sda_oe  = 1'b1;
                sda_out = 1'b0;  // pull SDA low → START condition
                if (clk_cnt == 8'd255) next_state = ADDR_TX;
            end

            // ------------------------------------------------------------------
            // ADDR_TX: clock out 7-bit address then R/W bit, MSB first
            // ------------------------------------------------------------------
            ADDR_TX: begin
                sda_oe = 1'b1;
                if (bit_cnt < 3'd7)
                    sda_out = addr[6 - bit_cnt]; // addr[6] first
                else
                    sda_out = rw;                // 8th bit = R/W

                if (clk_cnt == 8'd255 && bit_cnt == 3'd7)
                    next_state = ADDR_ACK;
            end

            // ------------------------------------------------------------------
            // ADDR_ACK: release SDA, slave drives ACK (0) or NACK (1)
            // ------------------------------------------------------------------
            ADDR_ACK: begin
                sda_oe = 1'b0; // release
                if (clk_cnt == 8'd255) begin
                    if (ack_err)       next_state = STOP;
                    else if (rw == 0)  next_state = DATA_TX;
                    else               next_state = DATA_RX;
                end
            end

            // ------------------------------------------------------------------
            // DATA_TX: clock out 8-bit write data, MSB first
            // ------------------------------------------------------------------
            DATA_TX: begin
                sda_oe  = 1'b1;
                sda_out = wdata[7 - bit_cnt];

                if (clk_cnt == 8'd255 && bit_cnt == 3'd7)
                    next_state = DATA_ACK;
            end

            // ------------------------------------------------------------------
            // DATA_RX: release SDA, slave drives data bits
            // ------------------------------------------------------------------
            DATA_RX: begin
                sda_oe = 1'b0;

                if (clk_cnt == 8'd255 && bit_cnt == 3'd7)
                    next_state = DATA_ACK;
            end

            // ------------------------------------------------------------------
            // DATA_ACK:
            //   Write path: release SDA → slave drives ACK
            //   Read  path: master drives NACK (1) to signal end of read
            // ------------------------------------------------------------------
            DATA_ACK: begin
                if (rw == 1'b1) begin
                    sda_oe  = 1'b1;
                    sda_out = 1'b1; // NACK from master after read
                end else begin
                    sda_oe  = 1'b0; // wait for slave ACK
                end

                if (clk_cnt == 8'd255) next_state = STOP;
            end

            // ------------------------------------------------------------------
            // STOP condition: SDA rises while SCL is high
            // clk_cnt 0..127 : SDA low,  SCL high (released)
            // clk_cnt 128..255: SDA high → rising edge = STOP
            // ------------------------------------------------------------------
            STOP: begin
                sda_oe = 1'b1;
                if (clk_cnt < 8'd128)
                    sda_out = 1'b0;
                else
                    sda_out = 1'b1;

                if (clk_cnt == 8'd255) next_state = IDLE;
            end

            default: next_state = IDLE;

        endcase
    end

endmodule