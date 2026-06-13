module axi4_lite_slave(
    input wire aclk,
    input wire rst_n,
    input wire awvalid,
    input wire wvalid,
    input wire [31:0] wdata,
    input wire [31:0] awaddr,
    input wire [3:0] wstrb,
    input wire bready,
    input wire rready,
    input wire arvalid,
    input wire [31:0] araddr,

    output reg awready,
    output reg wready,
    output reg rvalid,
    output reg [1:0] bresp,
    output reg bvalid,
    output reg [31:0] rdata,
    output reg arready,
    output reg [1:0] rresp
);

reg [31:0] sample_rate_reg;
reg [31:0] gain_reg;
reg [31:0] filter_reg;
reg [31:0] alarm_reg;

always @(posedge aclk or negedge rst_n) begin
    if (!rst_n) begin
        sample_rate_reg <= 32'h00;
        gain_reg        <= 32'h00;
        filter_reg      <= 32'h00;
        alarm_reg       <= 32'h00;
        awready         <= 1'b0;
        wready          <= 1'b0;
        bvalid          <= 1'b0;
        bresp           <= 2'b00;
        arready         <= 1'b0;
        rdata           <= 32'h00;
        rvalid          <= 1'b0;
        rresp           <= 2'b00;
    end else begin
        awready <= 1'b1;
        wready  <= 1'b1;

        // Write Logic
        if (awvalid && awready && wvalid && wready) begin
            case (awaddr)
                32'h00: sample_rate_reg <= wdata;
                32'h04: gain_reg        <= wdata;
                32'h08: filter_reg      <= wdata;
                32'h0C: alarm_reg       <= wdata;
            endcase
            bvalid <= 1'b1;
            bresp  <= 2'b00;
        end

        if (bvalid && bready) begin
            bvalid <= 1'b0;
        end

        // Read Logic
        if (arvalid && !rvalid) begin
            case (araddr)
                32'h00: rdata <= sample_rate_reg;
                32'h04: rdata <= gain_reg;
                32'h08: rdata <= filter_reg;
                32'h0C: rdata <= alarm_reg;
                default: begin
                    rdata <= 32'h0;
                    rresp <= 2'b10;
                end
            endcase
            rresp   <= 2'b00;
            rvalid  <= 1'b1;
            arready <= 1'b1;
        end else begin
            arready <= 1'b0;
        end

        if (rvalid && rready) begin
            rvalid <= 1'b0;
        end
    end
end

endmodule