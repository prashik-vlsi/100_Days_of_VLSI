`timescale 1ns / 1ps

module tb_spi_master;

    // Parameters
    parameter WIDTH = 8;
    parameter CLK_PERIOD = 20; // 50 MHz clock

    // Testbench Signals (Inputs to UUT)
    reg                 clk;
    reg                 rst_n;
    reg                 MISO;
    reg [WIDTH-1:0]     data_in;
    reg                 start;

    // Testbench Signals (Outputs from UUT)
    wire                MOSI;
    wire                SCLK;
    wire                CS_n;
    wire                done;
    wire [WIDTH-1:0]    data_out;

    // Instantiate the Unit Under Test (UUT)
    spi_master #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .MISO(MISO),
        .data_in(data_in),
        .start(start),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .CS_n(CS_n),
        .done(done),
        .data_out(data_out)
    );

    // Clock Generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end

    // File Dumping Environment
    initial begin
        $dumpfile("tb_spi_master.vcd");
        $dumpvars(0, tb_spi_master);
    end

    // Monitor Block
    initial begin
        $monitor("Time=%0t | rst_n=%b | start=%b | CS_n=%b | SCLK=%b | MOSI=%b | MISO=%b | done=%b | data_out=%h", 
                 $time, rst_n, start, CS_n, SCLK, MOSI, MISO, done, data_out);
    end

    initial begin 
    rst_n   = 0;
    start   = 0;
    MISO    = 0;
    data_in = 0;
    
    #40;
    rst_n   = 1;
    #20;
    data_in = 8'hA5;
    start   = 1;
    #CLK_PERIOD;
    start   = 0;
    
    @(posedge done);
    #40;
    $finish; 
end
endmodule