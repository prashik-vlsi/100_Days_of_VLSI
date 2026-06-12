module apb_uart (
    input wire clk,
    input wire rst_n,
    input wire [31:0] PADDR,
    input wire [31:0] PWDATA,
    input wire pwrite,
    input wire penable,
    input wire psel,
    output wire [31:0] PRDATA,
    output wire pready
);

reg [7:0]  tx_data;
reg        tx_write;
reg [31:0] prdata_reg;

wire [7:0] rx_data;
wire       rx_ready;
wire       tx_busy;

uart uart_inst (
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_data),
    .tx_write(tx_write),
    .rx_data(rx_data),
    .rx_ready(rx_ready),
    .tx_busy(tx_busy)
);

assign pready = psel; 
assign PRDATA = prdata_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_data    <= 8'h00;
        tx_write   <= 1'b0;
        prdata_reg <= 32'h00;
    end
    else begin
        tx_write <= 1'b0; 
        
        if (psel) begin
            if (pwrite) begin
                case (PADDR[7:0])
                    8'h00: begin
                        tx_data  <= PWDATA[7:0];
                        tx_write <= 1'b1;
                    end
                    default: ;
                endcase
            end 
            else begin
                case (PADDR[7:0])
                    8'h04:   prdata_reg <= {24'h0, rx_data};
                    8'h08:   prdata_reg <= {30'h0, tx_busy, rx_ready};
                    default: prdata_reg <= 32'h0;
                endcase
            end
        end
    end
end

endmodule