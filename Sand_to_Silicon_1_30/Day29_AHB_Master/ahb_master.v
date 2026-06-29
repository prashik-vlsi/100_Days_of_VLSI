//==============================================================================
// Module      : AHB Master
// Project     : NeuralEdge SoC
// Description :
//   Simple AHB-Lite Master capable of generating a sequential read burst.
//
//   Features:
//     - Supports SINGLE/INCR read transfers
//     - Word-aligned addressing
//     - Wait-state support using HREADY
//     - Active-low asynchronous reset
//
// Author      :
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
    input  wire        HREADY,
    input  wire        HRESP,
    input wire         start,      // begin transfer
    input wire [31:0]  addr_in,    // address to fetch from
    input wire         wr          // read or write

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

    //----------------------------------------------------------------------
    // Master State Machine
    //----------------------------------------------------------------------
    always @(posedge HCLK or negedge HRESETn) begin

        //------------------------------------------------------------------
        // Asynchronous Reset
        //------------------------------------------------------------------
        if (!HRESETn) begin

            HADDR      <= 32'h00000000;
            HWRITE     <= 1'b0;
            HSIZE      <= 3'b000;
            HBURST     <= 3'b000;
            HTRANS     <= IDLE;
            HPROT      <= 4'b0011;
            HWDATA     <= 32'h00000000;
            burst_cnt  <= 3'd0;

        end

        //------------------------------------------------------------------
        // Execute transfer only when slave is ready
        //------------------------------------------------------------------
        else if (HREADY) begin

            case (HTRANS)

                //----------------------------------------------------------
                // Idle State
                //----------------------------------------------------------
                IDLE: begin
    if(start) begin
        HADDR  <= addr_in;    // use addr_in
        HWRITE <= wr;    // use wr
        HTRANS <= NONSEQ;    // start transfer
    end
end

                //----------------------------------------------------------
                // First Transfer of Burst
                //----------------------------------------------------------
                NONSEQ: begin
    HSIZE      <= 3'b010;
    HBURST     <= 3'b011;    // INCR4 burst
    HTRANS     <= SEQ;
    burst_cnt  <= 3'd0;
end
                //----------------------------------------------------------
                // Sequential Transfers
                //----------------------------------------------------------
                SEQ: begin

                    if (burst_cnt < 3'd4) begin

                        HADDR      <= HADDR + 32'h4;
                        HTRANS     <= SEQ;
                        burst_cnt  <= burst_cnt + 1'b1;

                    end
                    else begin

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