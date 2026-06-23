module spi_master #(
    parameter WIDTH = 8
)(
    input wire                 clk,
    input wire                 rst_n,
    input wire                 MISO,
    input wire [WIDTH-1:0]     data_in,
    input wire                 start,
    output reg                 MOSI,
    output reg                 SCLK,
    output reg                 CS_n,
    output reg                 done,
    output reg [WIDTH-1:0]     data_out
);
reg [WIDTH-1:0] shift_reg;
reg [2:0]       bit_cnt;
reg [1:0]       state;
reg [3:0]       sclk_cnt;
localparam IDLE     = 2'b00;
localparam TRANSFER = 2'b01;
localparam DONE     = 2'b10;
always @(posedge clk) begin 
    if(!rst_n) begin 
        state    <= IDLE;
        CS_n     <= 1'b1;
        SCLK     <= 1'b0;
        MOSI     <= 1'b0;
        done     <= 1'b0;
        data_out <= {WIDTH{1'b0}};
    end
    else begin 
        case(state)
            IDLE: begin 
                if(start) begin
                    CS_n     <= 1'b0;
                    shift_reg<= data_in;
                    bit_cnt  <= 3'b000;
                    sclk_cnt <= 4'b0000;
                    done     <= 1'b0;
                    state    <= TRANSFER;
                end
                else begin 
                    state    <= IDLE;
                end
            end // Fixed missing end for IDLE case
            TRANSFER: begin 
                sclk_cnt <= sclk_cnt + 1'b1;
                if(sclk_cnt == 4'b0100) begin
                    SCLK     <= ~SCLK;
                    sclk_cnt <= 4'b0000;
                    
                    if(SCLK == 1'b1) begin 
                        MOSI      <= shift_reg[WIDTH-1];      
                        shift_reg <= shift_reg << 1; 
                        bit_cnt   <= bit_cnt + 1'b1;  
                    end
                    else begin 
                        shift_reg[0] <= MISO;  
                    end
                    
                    if(bit_cnt == WIDTH-1) begin
                        state <= DONE;
                    end
                    else begin 
                        state <= TRANSFER;
                    end
                end
            end // Fixed missing end for TRANSFER case
            DONE: begin 
                done     <= 1'b1;
                CS_n     <= 1'b1;
                data_out <= shift_reg;
                SCLK     <= 1'b0; // Fixed size mismatch and changed to non-blocking
                state    <= IDLE;
            end
            
            default: begin
                state    <= IDLE;
            end
        endcase
    end 
end
endmodule