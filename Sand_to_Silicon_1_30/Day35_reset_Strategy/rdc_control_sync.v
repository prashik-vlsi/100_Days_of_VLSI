module rdc_control_sync(

    input  wire cpu_clk,
    input  wire uart_clk,

    input  wire cpu_rst_n,
    input  wire uart_rst_n,

    input  wire cpu_valid,

    output wire uart_valid

);

reg sync_ff1;
reg sync_ff2;

always @(posedge uart_clk or negedge uart_rst_n)
begin
    if(!uart_rst_n)
    begin
        sync_ff1 <= 1'b0;
        sync_ff2 <= 1'b0;
    end
    else
    begin
        sync_ff1 <= cpu_valid;
        sync_ff2 <= sync_ff1;
    end
end

assign uart_valid = sync_ff2;

endmodule