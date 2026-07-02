module axi4_master_write #(
    parameter addr_width = 4,
    parameter data_width = 32
)(
    // System Signals
    input wire                      clk,
    input wire                      rst_n,

    // User/Application Interface
    input wire                      write_req,
    input wire [addr_width-1:0]     addr_in,
    input wire [data_width-1:0]     data_in,
    input wire [(data_width/8)-1:0] strb_in,
    output reg                      write_done,

    // Write Address Channel (AW)
    output reg [addr_width-1:0]     awaddr,
    output reg                      awvalid,
    input  wire                     awready,

    // Write Data Channel (W)
    output reg [data_width-1:0]     wdata,
    output reg [(data_width/8)-1:0] wstrb,
    output reg                      wvalid,
    input  wire                     wready,

    // Write Response Channel (B)
    input  wire [1:0]               bresp,
    input  wire                     bvalid,
    output reg                      bready
);

    // State Machine States
    reg [1:0] state;
    localparam IDLE = 2'b00,
               WDAT = 2'b01,
               RESP = 2'b10,
               STOP = 2'b11;

    // Independent Tracking Handshake Registers
    reg aw_done;
    reg w_done;

    // Pure combinational completion flags - no live-signal race
    wire aw_hs = awvalid && awready;
    wire w_hs  = wvalid  && wready;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            awaddr     <= 0;
            awvalid    <= 1'b0;
            wdata      <= 0;
            wvalid     <= 1'b0;
            wstrb      <= 0;
            bready     <= 1'b0;
            write_done <= 1'b0;
            aw_done    <= 1'b0;
            w_done     <= 1'b0;
            state      <= IDLE;
        end else begin
            case (state)

                IDLE: begin
                    write_done <= 1'b0;
                    aw_done    <= 1'b0;
                    w_done     <= 1'b0;

                    if (write_req) begin
                        awaddr  <= addr_in;
                        wdata   <= data_in;
                        wstrb   <= strb_in;

                        awvalid <= 1'b1;
                        wvalid  <= 1'b1;
                        state   <= WDAT;
                    end
                end

                WDAT: begin
                    // Latch each handshake independently and immediately
                    // deassert the corresponding valid so it isn't
                    // re-sampled on a later cycle.
                    if (aw_hs) begin
                        awvalid <= 1'b0;
                        aw_done <= 1'b1;
                    end

                    if (w_hs) begin
                        wvalid <= 1'b0;
                        w_done <= 1'b1;
                    end

                    // Evaluate completion using ONLY latched state plus
                    // this cycle's fresh handshake pulses (aw_done/w_done
                    // are not yet updated by the NBAs above on this edge,
                    // so the live terms aw_hs/w_hs are required here).
                    if ((aw_done || aw_hs) && (w_done || w_hs)) begin
                        bready  <= 1'b1;
                        aw_done <= 1'b0;
                        w_done  <= 1'b0;
                        state   <= RESP;
                    end
                end

                RESP: begin
                    if (bvalid && bready) begin
                        bready     <= 1'b0;
                        write_done <= 1'b1;
                        state      <= STOP;
                    end
                end

                STOP: begin
                    write_done <= 1'b0;
                    state      <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule