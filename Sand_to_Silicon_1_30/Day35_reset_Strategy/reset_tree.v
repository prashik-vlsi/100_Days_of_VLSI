module reset_tree (

    input  wire cpu_clk,
    input  wire adc_clk,
    input  wire uart_clk,

    input  wire raw_rst_n,

    output wire cpu_rst_n,
    output wire adc_rst_n,
    output wire uart_rst_n

);

    // CPU Reset Synchronizer
    reset_sync cpu_sync (
        .dst_clk    (cpu_clk),
        .rst_n      (raw_rst_n),
        .sync_rst_n (cpu_rst_n)
    );

    // ADC Reset Synchronizer
    reset_sync adc_sync (
        .dst_clk    (adc_clk),
        .rst_n      (raw_rst_n),
        .sync_rst_n (adc_rst_n)
    );

    // UART Reset Synchronizer
    reset_sync uart_sync (
        .dst_clk    (uart_clk),
        .rst_n      (raw_rst_n),
        .sync_rst_n (uart_rst_n)
    );

endmodule