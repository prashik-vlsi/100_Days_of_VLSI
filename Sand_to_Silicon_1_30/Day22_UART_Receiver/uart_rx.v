module uart_rx(
    input wire         clk,
    input wire         rst,
    input wire         rx,
    input wire  [15:0] baud_div,
    output reg  [7:0]  rx_data,
    output reg         rx_done,
    output reg         parity_err,
    output reg         frame_err
);

    // --- Internal Registers ---
    reg [2:0]  state;        // Current FSM state
    reg [15:0] baud_cnt;     // Baud clock divider counter
    reg [3:0]  tick;         // 16x oversample tick counter (0...15)
    reg [2:0]  bit_cnt;      // Count data bits (0...7)
    reg [7:0]  rx_shift;     // Shift register holding received bits 
    reg        rx_sync;      // Synchronized rx input
    reg        parity_calc;  // Running XOR of received bits 
    reg        tick_en;

    // --- State Parameters ---
    parameter IDLE   = 0;
    parameter START  = 1;
    parameter DATA   = 2;
    parameter PARITY = 3;
    parameter STOP   = 4;

    // --- Baud Rate Generator (16x Oversampling Pulse) ---
    always @(posedge clk) begin 
        if (rst) begin
            baud_cnt <= 1'b0; 
            tick_en  <= 1'b0;
        end
        else if (baud_cnt == baud_div - 1) begin 
            baud_cnt <= 1'b0;
            tick_en  <= 1'b1;
        end
        else begin 
            tick_en  <= 1'b0;
            baud_cnt <= baud_cnt + 1;
        end
    end

    // --- FSM Sequential Logic ---
    always @(posedge clk) begin 
        if (rst) begin 
            state       <= IDLE;
            rx_done     <= 0;
            parity_calc <= 0;
            parity_err  <= 0;
            tick        <= 0;
            frame_err   <= 0;
            bit_cnt     <= 0;
            rx_shift    <= 0;
            rx_data     <= 0;
            rx_sync     <= 1'b1;
        end 
        else begin 
            // Continuously sample the raw RX input to prevent metastability
            rx_sync <= rx;

            case (state)
                
                IDLE: begin 
                    rx_done <= 1'b0; // Clear the done flag for the new transaction
                    tick    <= 4'b0;
                    if (rx_sync == 0) begin 
                        state       <= START;
                        parity_calc <= 1'b0; // Reset parity accumulator
                    end
                    else begin 
                        state <= IDLE;
                    end
                end

                START: begin 
                    if (tick_en) begin
                        if (tick == 4'd7) begin // Center of start bit check
                            if (rx_sync == 0) begin
                                tick  <= 4'b0; // Clear counter for the next bit
                                state <= DATA; // Valid start bit confirmed!
                            end 
                            else begin
                                state <= IDLE; // Noise glitch detected, abort to IDLE
                            end
                        end 
                        else begin
                            tick <= tick + 1'b1;
                        end
                    end
                end

                DATA: begin
                    if (tick_en) begin
                        if (tick == 4'd15) begin // Center of data bit check
                            tick <= 4'b0;
                            
                            // Shift right: places the newest bit at MSB, pushing older ones down (LSB First)
                            rx_shift    <= {rx_sync, rx_shift[7:1]}; 
                            parity_calc <= parity_calc ^ rx_sync; // Keep a running XOR of all data bits
                            
                            if (bit_cnt == 3'd7) begin
                                bit_cnt <= 3'b0;
                                state   <= PARITY; // All 8 data bits captured, move to parity check
                            end 
                            else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            end
                        end 
                        else begin
                            tick <= tick + 1'b1;
                        end
                    end
                end

                PARITY: begin
                    if (tick_en) begin
                        if (tick == 4'd15) begin // Center of parity bit check
                            tick <= 4'b0;
                            
                            // Even Parity verification: 
                            // XORing the running data parity with the received parity bit should result in 0
                            parity_err <= (parity_calc ^ rx_sync); 
                            
                            state <= STOP;
                        end
                        else begin
                            tick <= tick + 1'b1;
                        end
                    end
                end

                STOP: begin
                    if (tick_en) begin
                        if (tick == 4'd15) begin // Center of stop bit check
                            tick    <= 4'b0;
                            rx_done <= 1'b1; // Signal to external system that rx_data is ready
                            rx_data <= rx_shift; // Present the final valid byte to the output
                            
                            // Framing Error check: the stop bit must be a logic 1
                            if (rx_sync == 0) begin
                                frame_err <= 1'b1;
                            end
                            else begin
                                frame_err <= 1'b0;
                            end
                            
                            state <= IDLE; // Packet complete, return to monitor the line
                        end
                        else begin
                            tick <= tick + 1'b1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule