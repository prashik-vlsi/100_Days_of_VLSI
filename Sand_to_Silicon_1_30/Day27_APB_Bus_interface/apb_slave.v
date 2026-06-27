// =============================================================================
// Module: apb_slave
// Description: A simple APB slave module to read and write 3 internal registers.
// =============================================================================

module apb_slave #(
    parameter ADDR_WIDTH = 32,          // Width of the address bus
    parameter DATA_WIDTH = 32           // Width of the data bus
)(
    // --- System Signals ---
    input  wire                    clk,     // Clock signal
    input  wire                    rst_n,   // Reset signal (Active-Low)

    // --- APB Bus Signals ---
    input  wire                    psel,    // Slave select signal
    input  wire                    penable, // Enable strobe signal
    input  wire                    pwrite,  // Write = 1, Read = 0
    input  wire [ADDR_WIDTH-1:0]   paddr,   // Register address
    input  wire [DATA_WIDTH-1:0]   pwdata,  // Data written from master
    output reg  [DATA_WIDTH-1:0]   prdata,  // Data read back to master
    output reg                    pready   // Ready signal back to master
);

    // --- Internal Registers ---
    reg [DATA_WIDTH-1:0] load_value;    // Register at address 0
    reg [DATA_WIDTH-1:0] control;       // Register at address 4
    reg [DATA_WIDTH-1:0] status;        // Register at address 8

    // --- Main Logic Block ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            load_value <= {DATA_WIDTH{1'b0}};
            control    <= {DATA_WIDTH{1'b0}};
            status     <= {DATA_WIDTH{1'b0}};
            prdata     <= {DATA_WIDTH{1'b0}};
            pready     <= 1'b0;
        end
        
        // Phase 1: Setup State (Selected but not enabled yet)
        else if (psel && !penable) begin 
            pready     <= 1'b0;          // Not ready yet
        end
        
        // Phase 2: Access State (Selected and enabled)
        else if (psel && penable) begin
            pready     <= 1'b1;          // Tell master data transaction is done
            
            if (pwrite) begin 
                // Master is WRITING data to the slave
                case (paddr)
                     32'h00: load_value <= pwdata;
                     32'h04: control    <= pwdata;
                     32'h08: status     <= pwdata;
                    default: ; // Do nothing if address doesn't exist
                endcase
            end
            else begin
                // Master is READING data from the slave
                case (paddr) 
                     32'h00: prdata     <= load_value;
                     32'h04: prdata     <= control;
                     32'h08: prdata     <= status;
                    default: prdata     <= {DATA_WIDTH{1'b0}}; // Return 0 for bad address
                endcase
            end
        end
        
        // Phase 3: Idle State (Bus is not using this slave)
        else begin
            pready     <= 1'b0;          // Keep ready low
        end
    end

endmodule