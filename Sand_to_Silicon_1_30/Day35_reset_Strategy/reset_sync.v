module reset_sync (
    input  wire dst_clk,
    input  wire rst_n,
    output wire sync_rst_n
);

reg sync_ff1;
reg sync_ff2;

// Output is taken directly from the second synchronizer stage
assign sync_rst_n = sync_ff2;

always @(posedge dst_clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_ff1 <= 1'b0;
        sync_ff2 <= 1'b0;
    end
    else begin
        sync_ff1 <= 1'b1;
        sync_ff2 <= sync_ff1;
    end
end

endmodule