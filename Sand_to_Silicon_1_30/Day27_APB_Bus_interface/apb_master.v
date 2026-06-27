// =============================================================================
// Module: apb_master
// Description: A simple APB master to start read or write bus cycles.
// =============================================================================

module apb_master #(
    parameter ADDR_WIDTH = 32,          // Width of the address bus
    parameter DATA_WIDTH = 32           // Width of the data bus
)(
    // --- System Signals ---
    input  wire                    clk,       // Clock signal
    input  wire                    rst_n,     // Reset signal (Active-Low)

    // --- Core/User Interface ---
    input  wire                    start,     // Pulse high to start a transaction
    input  wire                    wr_en,     // 1 = Write transaction, 0 = Read transaction
    input  wire [ADDR_WIDTH-1:0]   addr_in,   // Target address from core
    input  wire [DATA_WIDTH-1:0]   data_in,   // Data to write from core
    output reg  [DATA_WIDTH-1:0]   data_out,  // Data returned to core on read
    output reg                     done_out,  // Pulses high when transaction complete

    // --- APB Bus Interface ---
    output reg                     psel,      // Select signal to slave
    output reg                     penable,   // Enable signal to slave
    output reg                     pwrite,    // Direction: 1=Write, 0=Read
    output reg  [ADDR_WIDTH-1:0]   paddr,     // Address sent to slave
    output reg  [DATA_WIDTH-1:0]   pwdata,    // Data sent to slave
    input  wire [DATA_WIDTH-1:0]   prdata,    // Data received from slave
    input  wire                    pready     // Ready signal from slave
);

    // --- FSM States ---
    localparam IDLE   = 2'b00;
    localparam SETUP  = 2'b01;
    localparam ACCESS = 2'b10;
    
    reg [1:0] state;

    // --- Single-Clock Synchronous FSM Logic ---
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            state    <= IDLE;
            paddr    <= {ADDR_WIDTH{1'b0}};
            pwdata   <= {DATA_WIDTH{1'b0}};
            pwrite   <= 1'b0;
            data_out <= {DATA_WIDTH{1'b0}};
            psel     <= 1'b0;
            penable  <= 1'b0;
            done_out <= 1'b0;
        end
        else begin 
            case (state)
            
                IDLE: begin
                    psel     <= 1'b0;
                    penable  <= 1'b0;
                    pwrite   <= 1'b0;
                    paddr    <= {ADDR_WIDTH{1'b0}};
                    pwdata   <= {DATA_WIDTH{1'b0}};
                    done_out <= 1'b0;

                    if (start) begin
                        state  <= SETUP;
                        // Pre-emptively register user inputs
                        paddr  <= addr_in;      
                        pwdata <= data_in;      
                        pwrite <= wr_en;        
                    end
                end

                
                SETUP: begin
                    psel    <= 1'b1;  // Actively assert slave select
                    penable <= 1'b0;  // Strobe must remain low for 1 cycle
                    state   <= ACCESS;
                end

              
                ACCESS: begin
                    psel    <= 1'b1;
                    penable <= 1'b1;  // Assert enable strobe to complete setup

                    if (pready) begin
                        state    <= IDLE;
                        penable  <= 1'b0;
                        psel     <= 1'b0;
                        done_out <= 1'b1; // Pulse transaction completion back to core
                        
                        // Capturing read payload if the master was executing a read
                        if (!pwrite) begin
                            data_out <= prdata;
                        end
                    end
                    else begin
                        state    <= ACCESS; // Slave is holding down pready; stall master
                    end
                end

                default: state <= IDLE;
            endcase
        end 
    end

endmodule