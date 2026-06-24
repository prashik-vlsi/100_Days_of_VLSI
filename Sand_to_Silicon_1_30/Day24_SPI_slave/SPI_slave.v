module SPI_slave #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire cs,
    input wire sclk,
    input wire mosi,
    input wire [WIDTH-1:0] tx_data,
    output reg [WIDTH-1:0] rx_data,
    output reg rx_done,
    output reg miso
);

    reg sclk_prev;              // — 1 bit, to detect SCLK edge
    reg [WIDTH-1:0] shift_reg;  // — WIDTH bits, shift register for RX
    reg [WIDTH-1:0] tx_shift;   // — WIDTH bits, shift register for TX
    reg [2:0] bit_cnt;          // — 3 bits, counts 0 to 7
    reg cs_prev;  
    
    wire cs_falling;            // — 1 bit, to detect CS falling edge
    assign cs_falling = (cs_prev) && (~cs);

    wire sclk_rising;
    assign sclk_rising = (!sclk_prev) && (sclk);

    always @(posedge clk) begin 
        if (rst) begin
            shift_reg <= 8'b0;
            bit_cnt   <= 3'b0;
            sclk_prev <= 1'b0;
            tx_shift  <= 8'b0;
            cs_prev   <= 1'b0;
            rx_data   <= 8'b0;
            rx_done   <= 1'b0;
            miso      <= 1'b0;
        end 
        else begin 
            cs_prev   <= cs;
            sclk_prev <= sclk;
   
            if (cs_falling) begin
                tx_shift  <= tx_data;
                bit_cnt   <= 3'b0;
            end
            else if (sclk_rising & ~cs) begin
                shift_reg <= {shift_reg[6:0], mosi};
                miso      <= tx_shift[7]; // — which bit is MSB of an 8-bit register?
                tx_shift  <= {tx_shift[6:0], 1'b0}; // shift left, fill LSB with 0
                bit_cnt   <= bit_cnt + 1'b1;
                
                if (bit_cnt == 3'b111) begin 
                    rx_data <= {shift_reg[6:0], mosi};
                    rx_done <= 1'b1;
                end 
                else begin 
                    rx_done <= 1'b0;
                end
            end
        end
    end

endmodule