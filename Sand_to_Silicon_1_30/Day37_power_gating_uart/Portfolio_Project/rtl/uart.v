//==================================================
// UART with Power Gating + Idle Timeout
//==================================================
// FUTURE VERSION: Do not use yet. This is a reference
// for how to properly add automatic idle-based sleep.
//
// Key improvement over immediate sleep:
//   - Allows brief idle periods without power loss
//   - Reduces sleep/wake latency for bursty traffic
//   - PMU stays awake during short silences
//
// When to use:
//   - After base version (uart_power_gating.v) is verified
//   - When idle timeout improves power more than latency costs
//   - In production IP with characterized sleep timing
//==================================================

module uart_power_gating_with_idle_timer #(
    parameter DATA_WIDTH = 8,
    parameter CLK_FREQ   = 50_000_000,
    parameter BAUD_RATE  = 115200,
    parameter IDLE_TIMEOUT_US = 10  // Microseconds before auto-sleep
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  sleep,
    input  wire                  tx_start,
    input  wire [DATA_WIDTH-1:0] tx_data,

    output reg                   tx,
    output reg                   tx_busy,
    output wire                  sleep_ack
);

//--------------------------------------------------
// Local Parameters
//--------------------------------------------------
localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
localparam BAUD_COUNTER_WIDTH = $clog2(BAUD_DIV) + 1;

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

// Idle timeout in clock cycles
localparam IDLE_TIMEOUT_CYCLES = (IDLE_TIMEOUT_US * CLK_FREQ) / 1_000_000;
localparam IDLE_COUNTER_WIDTH = $clog2(IDLE_TIMEOUT_CYCLES) + 1;

//--------------------------------------------------
// Internal Registers
//--------------------------------------------------
reg [DATA_WIDTH-1:0] shift_reg;

reg [3:0] bit_count;
reg sleep_pending;
reg sleep_active;
reg [BAUD_COUNTER_WIDTH-1:0] baud_counter;

reg baud_tick;

reg [1:0] state;
reg [1:0] next_state;

reg [IDLE_COUNTER_WIDTH-1:0] idle_counter;

//--------------------------------------------------
// Power Gating Control
//--------------------------------------------------
wire uart_enable;
assign uart_enable = ~sleep_active;

//--------------------------------------------------
// Baud Generator (Power Gated)
//--------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        baud_counter <= {BAUD_COUNTER_WIDTH{1'b0}};
        baud_tick    <= 1'b0;
    end
    else if (uart_enable) begin
        if (baud_counter == BAUD_DIV - 1) begin
            baud_counter <= {BAUD_COUNTER_WIDTH{1'b0}};
            baud_tick    <= 1'b1;
        end
        else begin
            baud_counter <= baud_counter + 1'b1;
            baud_tick    <= 1'b0;
        end
    end
    else begin
        // Power-gated: hold counter, suppress tick
        baud_counter <= baud_counter;
        baud_tick    <= 1'b0;
    end
end

//--------------------------------------------------
// State Register (Power Gated)
//--------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else if (uart_enable)
        state <= next_state;
end

//--------------------------------------------------
// Next State Logic (Combinational)
//--------------------------------------------------
always @(*) begin
    next_state = state;

    case (state)
        IDLE: begin
            if (tx_start && !sleep_pending)
                next_state = START;
            else
                next_state = IDLE;
        end

        START: begin
            if (baud_tick)
                next_state = DATA;
            else
                next_state = START;
        end

        DATA: begin
            if (baud_tick) begin
                if (bit_count == DATA_WIDTH - 1)
                    next_state = STOP;
                else
                    next_state = DATA;
            end
            else begin
                next_state = DATA;
            end
        end

        STOP: begin
            if (baud_tick)
                next_state = IDLE;
            else
                next_state = STOP;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

//--------------------------------------------------
// Shift Register
//--------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        shift_reg <= {DATA_WIDTH{1'b0}};
    else if (uart_enable) begin
        if (state == IDLE && next_state == START)
            shift_reg <= tx_data;
        else if (state == DATA && baud_tick)
            shift_reg <= {1'b0, shift_reg[DATA_WIDTH-1:1]};
    end
end

//--------------------------------------------------
// Bit Counter
//--------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        bit_count <= 4'd0;
    else if (uart_enable) begin
        if (state == IDLE && next_state == START)
            bit_count <= 4'd0;
        else if (state == DATA && baud_tick)
            bit_count <= bit_count + 1'b1;
        else if (state == STOP && baud_tick)
            bit_count <= 4'd0;
    end
end

//--------------------------------------------------
// TX Output Logic
//--------------------------------------------------
always @(*) begin
    if (!uart_enable)
        tx = 1'b1;
    else begin
        case (state)
            IDLE  : tx = 1'b1;
            START : tx = 1'b0;
            DATA  : tx = shift_reg[0];
            STOP  : tx = 1'b1;
            default: tx = 1'b1;
        endcase
    end
end

//--------------------------------------------------
// TX Busy Logic
//--------------------------------------------------
always @(*) begin
    if (!uart_enable)
        tx_busy = 1'b0;
    else
        tx_busy = (state != IDLE);
end

//--------------------------------------------------
// Idle Counter (counts when in IDLE and sleep requested)
//--------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        idle_counter <= {IDLE_COUNTER_WIDTH{1'b0}};
    end
    else if (uart_enable && sleep_pending) begin
        if (state != IDLE) begin
            // Transmitting: reset counter
            idle_counter <= {IDLE_COUNTER_WIDTH{1'b0}};
        end
        else if (idle_counter < IDLE_TIMEOUT_CYCLES) begin
            // In IDLE, counting toward timeout
            idle_counter <= idle_counter + 1'b1;
        end
        // else: hold at timeout value
    end
    else begin
        // No sleep request or power-gated: reset counter
        idle_counter <= {IDLE_COUNTER_WIDTH{1'b0}};
    end
end

//--------------------------------------------------
// Power Management
//--------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sleep_pending <= 1'b0;
        sleep_active  <= 1'b0;
    end
    else if (!sleep) begin
        // Wake up immediately
        sleep_pending <= 1'b0;
        sleep_active  <= 1'b0;
    end
    else if (sleep && !sleep_active) begin
        // Sleep requested and not already sleeping
        sleep_pending <= 1'b1;

        // Enter sleep when:
        // 1. In IDLE state (not transmitting)
        // 2. AND idle_counter has timed out
        if (uart_enable && state == IDLE && idle_counter >= IDLE_TIMEOUT_CYCLES) begin
            sleep_active  <= 1'b1;
            sleep_pending <= 1'b0;
        end
    end
end

//--------------------------------------------------
// PMU Handshake Output
//--------------------------------------------------
assign sleep_ack = sleep_active;

endmodule
