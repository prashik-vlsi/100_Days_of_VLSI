module reset_controller (
    input  wire ext_rst_n,      // External push-button reset
    input  wire por_rst_n,      // Power-On Reset
    input  wire sw_rst_n,       // Software reset
    input  wire wdog_rst_n,     // Watchdog reset
    input  wire pll_lock,       // PLL lock indicator

    output wire raw_rst_n
);

assign raw_rst_n =
       ext_rst_n  &
       por_rst_n  &
       sw_rst_n   &
       wdog_rst_n &
       pll_lock;

endmodule