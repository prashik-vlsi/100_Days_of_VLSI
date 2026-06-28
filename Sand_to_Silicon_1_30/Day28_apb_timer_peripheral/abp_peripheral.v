module apb_timer_peripheral #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // Clock and Reset
    input  wire                  clk,
    input  wire                  rst_n,

    // APB Interface — Inputs from Master
    input  wire [ADDR_WIDTH-1:0] paddr,
    input  wire                  psel,
    input  wire                  penable,
    input  wire                  pwrite,
    input  wire [DATA_WIDTH-1:0] pwdata,

    // APB Interface — Outputs to Master
    output reg  [DATA_WIDTH-1:0] prdata,
    output reg                   pready,
    output reg                   pslverr,

    // Timer Output — To VitalGuard ECG Engine
    output reg                   done_out
);

// ─────────────────────────────────────────
// Register Map
// ─────────────────────────────────────────
parameter LOAD_REG   = 32'h00;  // Load  — count value
parameter CTRL_REG   = 32'h04;  // Control — start/stop
parameter STAT_REG   = 32'h08;  // Status — done flag

// ─────────────────────────────────────────
// Internal Registers
// ─────────────────────────────────────────
reg [DATA_WIDTH-1:0] load_reg;    // stores count value from processor
reg                  ctrl_reg;    // stores start/stop bit
reg                  stat_reg;    // stores done flag set by hardware
reg [DATA_WIDTH-1:0] timer_count; // actual countdown counter

// ─────────────────────────────────────────
// Block 1 — APB Write and Read Decoder
// ─────────────────────────────────────────
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_reg <= {DATA_WIDTH{1'b0}};
        ctrl_reg <= 1'b0;
        prdata   <= {DATA_WIDTH{1'b0}};
        pready   <= 1'b0;
        pslverr  <= 1'b0;
    end
    else begin
        // default — clear error and ready each cycle
        pslverr <= 1'b0;
        pready  <= 1'b1;

        if (psel && penable) begin

            // Write decoder
            if (pwrite) begin
                case (paddr)
                    LOAD_REG : load_reg <= pwdata;
                    CTRL_REG : ctrl_reg <= pwdata[0];
                    default  : pslverr  <= 1'b1;
                endcase
            end

            // Read decoder
            else begin
                case (paddr)
                    LOAD_REG : prdata <= load_reg;
                    CTRL_REG : prdata <= {{DATA_WIDTH-1{1'b0}}, ctrl_reg};
                    STAT_REG : prdata <= {{DATA_WIDTH-1{1'b0}}, stat_reg};
                    default  : pslverr <= 1'b1;
                endcase
            end

        end
    end
end

// ─────────────────────────────────────────
// Block 2 — Timer Countdown Logic
// ─────────────────────────────────────────
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timer_count <= {DATA_WIDTH{1'b0}};
        stat_reg    <= 1'b0;
        done_out    <= 1'b0;
    end
    else begin
        if (ctrl_reg) begin

            // Start condition — load value from load_reg
            if (timer_count == 0) begin
                timer_count <= load_reg;
            end

            // Counting — decrement every clock cycle
            else begin
                timer_count <= timer_count - 1'b1;

                // Done — one cycle before zero
                if (timer_count == 1) begin
                    stat_reg <= 1'b1;
                    done_out <= 1'b1;
                end
            end

        end
    end
end

endmodule