module uart_tx #(
    parameter CLK_FREQ   = 50000000,  // 50 MHz System Clock
    parameter BAUD_RATE  = 9600,      // Target Baud Rate
    
    // Derived internally to make the IP scalable and reusable
    parameter MAX_COUNT  = (CLK_FREQ / BAUD_RATE) - 1 // 5207
)(
    input  wire       clk,        // System Clock
    input  wire       rst_n,      // Active-low Synchronous Reset
    input  wire       tx_start,   // Pulse to initiate transmission
    input  wire [7:0] tx_data,    // 8-bit Parallel data payload
    output reg        tx_serial,  // 1-bit Serial Output line (reg because assigned in FSM)
    output reg        tx_busy     // Status flag: 1 = Active, 0 = Idle
);

// State encoding constants (not registers, just literal values)
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

wire baud_tick;
assign baud_tick = (baud_cnt == MAX_COUNT);

// The actual hardware registers that hold the state
reg [1:0] current_state;
reg [1:0] next_state;

reg [$clog2(MAX_COUNT)-1:0] baud_cnt;
reg [2:0] bit_idx; // to count the timer
reg [7:0] tx_shift_reg;


// 1. SEQUENTIAL STATE REGISTER
always @(posedge clk) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// 2. COMBINATIONAL NEXT STATE LOGIC (Fixed to Blocking Assignments)
always @(*) begin
    next_state = current_state; // Default prevents latches
    
    case (current_state)
        IDLE: begin
            if (tx_start)
                next_state = START;
        end
        
        START: begin
            if (baud_tick)
                next_state = DATA;
        end
        
        DATA: begin
            if (baud_tick && (bit_idx == 3'd7))
                next_state = STOP;
        end
        
        STOP: begin
            if (baud_tick)
                next_state = IDLE;
        end
        
        default: next_state = IDLE;
    endcase
end

always @(posedge clk) begin
    if (!rst_n) begin
        baud_cnt <= 0;
    end else if (current_state == IDLE) begin
        baud_cnt <= 0; // Keep counter clear while sitting idle
    end else begin
        if (baud_tick) begin
            baud_cnt <= 0; // Rollover when terminal count is hit
        end else begin
            baud_cnt <= baud_cnt + 1'b1; // Normal incrementing
        end
    end
end
always @(posedge clk) begin
    if (!rst_n) begin
        bit_idx <= 3'd0;
    end else if (current_state == IDLE) begin
        bit_idx <= 3'd0;
    end else if (current_state == DATA) begin
        if (baud_tick) begin
            bit_idx <= bit_idx + 1'b1;
        end
    end
end
always @(posedge clk) begin
    if (!rst_n) begin
        tx_shift_reg <= 8'b0;
    end else if (current_state == IDLE && tx_start) begin
        tx_shift_reg <= tx_data; // Capture the data payload
    end else if (current_state == DATA && baud_tick) begin
        tx_shift_reg <= tx_shift_reg >> 1; // Shift right for LSB-first transmission
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        tx_serial <= 1'b1; // Default state of a UART line is HIGH
        tx_busy   <= 1'b0;
    end else begin
        case (current_state)
            IDLE: begin
                tx_serial <= 1'b1;
                tx_busy   <= 1'b0;
            end
            START: begin
                tx_serial <= 1'b0; // Force line LOW for start bit
                tx_busy   <= 1'b1;
            end
            DATA: begin
                tx_serial <= tx_shift_reg[0]; // Drive current LSB out to the line
                tx_busy   <= 1'b1;
            end
            STOP: begin
                tx_serial <= 1'b1; // Return line HIGH for stop bit
                tx_busy   <= 1'b1;
            end
            default: begin
                tx_serial <= 1'b1;
                tx_busy   <= 1'b0;
            end
    endcase
    end
end

endmodule