//==============================================================================
// Module      : ahb_master
// Project     : NeuralEdge SoC
// Description :
//   Simple AHB-Lite Master capable of generating a sequential read/write burst
//   or single transfers based on burst_mode configuration, featuring fully
//   compliant pipelined read data capture.
//==============================================================================

module ahb_master (

    //----------------------------------------------------------------------
    // Global Signals
    //----------------------------------------------------------------------
    input  wire        HCLK,
    input  wire        HRESETn,

    //----------------------------------------------------------------------
    // AHB Master Outputs
    //----------------------------------------------------------------------
    output reg [31:0]  HADDR,
    output reg         HWRITE,
    output reg [2:0]   HSIZE,
    output reg [2:0]   HBURST,
    output reg [1:0]   HTRANS,
    output reg [3:0]   HPROT,
    output reg [31:0]  HWDATA,

    //----------------------------------------------------------------------
    // AHB Master Inputs
    //----------------------------------------------------------------------
    input  wire [31:0] HRDATA,
    input  wire        burst_mode,  // 0 = single transfer, 1 = INCR4 burst
    input  wire [31:0] data_in,     // Input data from testbench for writes
    input  wire        HREADY,
    input  wire        HRESP,
    input  wire        start,       // begin transfer
    input  wire [31:0] addr_in,     // address to fetch from/write to
    input  wire        wr,          // read (0) or write (1)

    //----------------------------------------------------------------------
    // Captured Read Data Output
    //----------------------------------------------------------------------
    output reg [31:0]  rdata_out    // Captured read data sent to testbench

);

    //----------------------------------------------------------------------
    // AHB Transfer Type Encoding
    //----------------------------------------------------------------------
    localparam IDLE   = 2'b00;
    localparam BUSY   = 2'b01;
    localparam NONSEQ = 2'b10;
    localparam SEQ    = 2'b11;

    //----------------------------------------------------------------------
    // Internal Registers
    //----------------------------------------------------------------------
    reg [2:0] burst_cnt;
    reg       valid_rphase; // Pipeline flag: High during a read data phase

    //----------------------------------------------------------------------
    // Master State Machine & Bus Logic
    //----------------------------------------------------------------------
    always @(posedge HCLK or negedge HRESETn) begin

        //------------------------------------------------------------------
        // Asynchronous Reset
        //------------------------------------------------------------------
        if (!HRESETn) begin
            HADDR        <= 32'h00000000;
            HWRITE       <= 1'b0;
            HSIZE        <= 3'b000;
            HBURST       <= 3'b000;
            HTRANS       <= IDLE;
            HPROT        <= 4'b0011;
            HWDATA       <= 32'h00000000;
            burst_cnt    <= 3'd0;
            valid_rphase <= 1'b0;
            rdata_out    <= 32'h00000000;
        end

        //------------------------------------------------------------------
        // Execute logic only when slave is ready
        //------------------------------------------------------------------
        else if (HREADY) begin

            // Pipelined Read Capture: If previous cycle was a valid read 
            // address phase, capture the incoming HRDATA now.
            if (valid_rphase) begin
                rdata_out <= HRDATA;
            end

            // Determine if the *next* cycle will be a valid read data phase
            valid_rphase <= (HTRANS != IDLE && HTRANS != BUSY) && !HWRITE;

            case (HTRANS)

                //----------------------------------------------------------
                // Idle State
                //----------------------------------------------------------
                IDLE: begin
                    if (start) begin
                        HADDR  <= addr_in; 
                        HWRITE <= wr;      
                        HTRANS <= NONSEQ;  // Kick off address phase
                    end
                end

                //----------------------------------------------------------
                // First Transfer of Burst / Single Transfer Phase
                //----------------------------------------------------------
                NONSEQ: begin
                    HSIZE <= 3'b010; // Word size (32-bit)
                    
                    if (burst_mode == 1'b0) begin
                        // Single Transfer Logic
                        HBURST <= 3'b000; // SINGLE
                        HTRANS <= IDLE;   // Back to IDLE next cycle
                        
                        if (HWRITE) begin
                            HWDATA <= data_in; // Drive single write data phase
                        end
                    end
                    else begin
                        // Burst Transfer Logic (INCR4)
                        HBURST    <= 3'b011; // INCR4 burst
                        HTRANS    <= SEQ;    // Move to sequential cycles
                        burst_cnt <= 3'd0;
                    end
                end
                
                //----------------------------------------------------------
                // Sequential Transfers (INCR4)
                //----------------------------------------------------------
                SEQ: begin
                    if (burst_cnt < 3'd3) begin // 3 SEQ phases required for 4 beats
                        HADDR     <= HADDR + 32'h4;
                        HTRANS    <= SEQ;
                        burst_cnt <= burst_cnt + 1'b1;
                        
                        if (HWRITE) begin
                            if (burst_cnt == 3'd0)
                                HWDATA <= data_in; // First beat uses testbench data
                            else
                                HWDATA <= HWDATA + 32'h1; // Subsequent beats increment
                        end
                    end
                    else begin
                        // Final data phase handling for the 4th beat
                        if (HWRITE) begin
                            HWDATA <= HWDATA + 32'h1;
                        end
                        HTRANS     <= IDLE;
                        burst_cnt  <= 3'd0;
                    end
                end

                //----------------------------------------------------------
                // Default
                //----------------------------------------------------------
                default: begin
                    HTRANS <= IDLE;
                end

            endcase
        end
    end

endmodule