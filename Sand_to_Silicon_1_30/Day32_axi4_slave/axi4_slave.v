//=============================================================================
// AXI4-Lite Slave Memory Module
// Refactored for Production Quality, Synthesis, and Readability
//=============================================================================
module axi4_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4,
    parameter MEM_DEPTH  = 15   // Valid indices 0..14, addr 0xF is out-of-range
)(
    input  wire                     clk,
    input  wire                     rst_n,
 
    // Write Address Channel
    input  wire [ADDR_WIDTH-1:0]    awaddr,
    input  wire                     awvalid,
    output reg                      awready,
 
    // Write Data Channel
    input  wire [DATA_WIDTH-1:0]    wdata,
    input  wire [(DATA_WIDTH/8)-1:0] wstrb, // Note: Unused in core memory array write
    input  wire                     wvalid,
    output reg                      wready,
 
    // Write Response Channel
    output reg  [1:0]               bresp,
    output reg                      bvalid,
    input  wire                     bready,
 
    // Read Address Channel
    input  wire [ADDR_WIDTH-1:0]    araddr,
    input  wire                     arvalid,
    output reg                      arready,
 
    // Read Data Channel
    output reg  [DATA_WIDTH-1:0]    rdata,
    output reg  [1:0]               rresp,
    output reg                      rvalid,
    input  wire                     rready
);
 
    //-------------------------------------------------------------------------
    // Internal Signals & Storage
    //-------------------------------------------------------------------------
    reg [31:0] mem_array [MEM_DEPTH-1:0];
 
    // FSM States
    localparam IDLE    = 2'b00;
    localparam ADR_RCV = 2'b01;
 
    reg [1:0] ar_state;
    reg [1:0] aw_state;
    reg [ADDR_WIDTH-1:0] araddr_reg;
    reg [ADDR_WIDTH-1:0] awaddr_reg;

    //-------------------------------------------------------------------------
    // Read Address (AR) Channel FSM
    //-------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ar_state   <= IDLE;
            araddr_reg <= {ADDR_WIDTH{1'b0}};
            arready    <= 1'b0;
        end else begin
            case (ar_state)
                IDLE: begin
                    arready <= 1'b0;
                    if (arvalid) begin
                        araddr_reg <= araddr;
                        ar_state   <= ADR_RCV;
                    end
                end

                ADR_RCV: begin
                    arready  <= 1'b1;
                    ar_state <= IDLE;
                end

                default: begin
                    ar_state <= IDLE;
                end
            endcase
        end
    end
 
    //-------------------------------------------------------------------------
    // Read Data (R) Channel Logic
    //-------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata  <= {DATA_WIDTH{1'b0}};
            rresp  <= 2'b00;
            rvalid <= 1'b0;
        end else begin
            if (ar_state == ADR_RCV) begin
                rvalid <= 1'b1;
                if (araddr_reg < MEM_DEPTH) begin
                    rdata <= mem_array[araddr_reg];
                    rresp <= 2'b00; // OKAY
                end else begin
                    rdata <= {DATA_WIDTH{1'b0}};
                    rresp <= 2'b10; // SLVERR
                end
            end else if (rvalid && rready) begin
                rvalid <= 1'b0;
            end
        end
    end
 
    //-------------------------------------------------------------------------
    // Write Address (AW) Channel FSM
    //-------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            aw_state   <= IDLE;
            awaddr_reg <= {ADDR_WIDTH{1'b0}};
            awready    <= 1'b1;
        end else begin
            case (aw_state)
                IDLE: begin
                    awready <= 1'b1;
                    if (awvalid) begin
                        awaddr_reg <= awaddr;
                        awready    <= 1'b0;
                        aw_state   <= ADR_RCV;
                    end
                end

                ADR_RCV: begin
                    awready <= 1'b0;
                    if (wvalid && wready) begin
                        aw_state <= IDLE;
                    end
                end

                default: begin
                    aw_state <= IDLE;
                end
            endcase
        end
    end

    //-------------------------------------------------------------------------
    // Write Data (W) Channel Control
    //-------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wready  <= 1'b0;
        end else begin
            if (wvalid && wready) begin
                wready  <= 1'b0;
            end else if (aw_state == ADR_RCV) begin
                wready  <= 1'b1;
            end
        end
    end
    
    //-------------------------------------------------------------------------
    // Write Response (B) Channel & Memory Array Update
    //-------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bvalid <= 1'b0;
            bresp  <= 2'b00;
        end else begin
            if (wvalid && wready) begin
                bvalid <= 1'b1;
                bresp  <= (awaddr_reg < MEM_DEPTH) ? 2'b00 : 2'b10;
                
                if (awaddr_reg < MEM_DEPTH) begin
                    mem_array[awaddr_reg] <= wdata;
                end
            end else if (bvalid && bready) begin
                bvalid <= 1'b0;
            end
        end
    end

endmodule