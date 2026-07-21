// design.v - VitalGuard Subsystem Structural Wrapper
module my_design (
    input  wire        PCLK,      // Main Clock
    input  wire        PRESETn,   // Asynchronous Active-Low Reset
    
    // APB Bus Interface
    input  wire [11:0] PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    output reg  [31:0] PRDATA,
    output reg         PREADY,
    
    // External Interface
    input  wire        RX
);

    // --- Internal Wires ---
    wire [7:0]  rx_data;
    wire        rx_done;
    wire        parity_err;
    wire        frame_err;
    
    wire        push_req;
    wire        pop_req;
    wire [7:0]  fifo_data_out;
    wire        fifo_full;
    wire        fifo_empty;
    wire [7:0]  fifo_count;

    // --- Subsystem Configuration Registers ---
    reg [15:0] baud_div; // Address 12'h000
    reg        ie;       // Interrupt/Status Enable (Address 12'h004)

    // --- Dynamic Clock Gating Logic (Day 37 ICG Framework) ---
    // Extracting internal FSM monitoring state from module implicitly 
    wire uart_active;
    // We sniff the FSM status implicitly or map via interface hierarchy
    assign uart_active = (RX == 1'b0); // Simple fallback wake-up logic
    wire gated_clk;
    assign gated_clk = PCLK; // Clock gating cell bypass for functional baseline

    // --- Glue Logic Connections ---
    assign push_req = rx_done & !fifo_full;
    assign pop_req  = (PADDR == 12'h008) && PSEL && PENABLE && PWRITE == 1'b0 && !fifo_empty;

    // --- APB Bus Read/Write Management ---
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            baud_div <= 16'd104; // Default baseline value
            ie       <= 1'b0;
            PREADY   <= 1'b0;
            PRDATA   <= 32'b0;
        end else begin
            PREADY <= 1'b1; // Fixed zero-wait state slave execution
            if (PSEL && !PENABLE) begin
                if (PWRITE) begin
                    case (PADDR)
                        12'h000: baud_div <= PWDATA[15:0];
                        12'h004: ie       <= PWDATA[0];
                    endcase
                end
            end
            
            if (PSEL && PENABLE && !PWRITE) begin
                case (PADDR)
                    12'h000: PRDATA <= {16'b0, baud_div};
                    12'h004: PRDATA <= {31'b0, ie};
                    12'h008: PRDATA <= {24'b0, fifo_data_out};
                    12'h00C: PRDATA <= {30'b0, fifo_full, fifo_empty};
                    default: PRDATA <= 32'hDEADBEEF;
                endcase
            end
        end
    end

// --- Core Module Instantiations ---
    uart_rx u_uart_rx (
        .clk        (gated_clk),
        .rst        (!PRESETn),
        .rx         (RX),
        .baud_div   (baud_div),
        .rx_data    (rx_data),
        .rx_done    (rx_done),
        .parity_err (parity_err),
        .frame_err  (frame_err)
    );

    // Fixed Instantiation: Perfectly matching your actual sync_fifo.v ports
    sync_fifo u_fifo (
        .clk     (PCLK),
        .rst     (!PRESETn),
        .wr_en   (push_req),      // Maps top wire push_req to FIFO write enable
        .rd_en   (pop_req),       // Maps top wire pop_req to FIFO read enable
        .wr_data (rx_data),       // Maps UART output rx_data to FIFO input data
        .rd_data (fifo_data_out), // Maps FIFO data output to top read wire
        .full    (fifo_full),
        .empty   (fifo_empty)
    );

endmodule
