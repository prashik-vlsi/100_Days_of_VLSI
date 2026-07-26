`timescale 1ns/1ps

module uart_tx #(
    parameter CLK_FREQ  = 10_000_000,
    parameter BAUD_RATE = 1_000_000
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx,
    output reg        tx_busy
);

    localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_counter;
    reg [3:0]  bit_counter;
    reg [9:0]  tx_shift_reg;

    always @(posedge clk) begin

        if (!rst_n) begin

            baud_counter <= 16'd0;
            bit_counter  <= 4'd0;
            tx_shift_reg <= 10'b1111111111;

            tx           <= 1'b1;
            tx_busy      <= 1'b0;

        end else begin

            // Start transmission
            if (tx_start && !tx_busy) begin

                // UART frame:
                // Start bit = 0
                // 8 data bits = LSB first
                // Stop bit = 1

                tx_shift_reg <= {1'b1, tx_data, 1'b0};

                tx_busy      <= 1'b1;

                baud_counter <= 16'd0;
                bit_counter  <= 4'd0;

                tx           <= 1'b0;

            end

            // Transmission active
            else if (tx_busy) begin

                if (baud_counter == BAUD_DIV - 1) begin

                    baud_counter <= 16'd0;

                    if (bit_counter == 4'd9) begin

                        // Transmission complete
                        tx_busy <= 1'b0;
                        tx      <= 1'b1;

                        bit_counter <= 4'd0;

                    end else begin

                        bit_counter <= bit_counter + 1'b1;

                        tx_shift_reg <= {
                            1'b1,
                            tx_shift_reg[9:1]
                        };

                        tx <= tx_shift_reg[1];

                    end

                end else begin

                    baud_counter <= baud_counter + 1'b1;

                end

            end

        end

    end

endmodule
