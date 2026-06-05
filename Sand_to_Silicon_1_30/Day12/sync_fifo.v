    module sync_fifo(
        input clk,
        input rst,
        input wr_en,
        input rd_en,
        input [7:0]wr_data,
        output [7:0]rd_data,
        output full,
        output empty
        
        
    );
    parameter data_width =8;
    parameter depth =16;
    reg [4:0]wr_ptr;
    reg [4:0]rd_ptr;


    reg[7:0] mem [15:0];

    assign  empty=(wr_ptr==rd_ptr);
    assign full =(wr_ptr[4]!=rd_ptr[4] && wr_ptr[3:0]==rd_ptr[3:0]);

    wire wr_valid;
    wire rd_valid;

    assign wr_valid = wr_en && !full;
    assign rd_valid = rd_en && !empty;


    always @(posedge clk) begin
        if (rst)
            wr_ptr <= 5'b00000;
        else if (wr_en && !full)
            wr_ptr <= wr_ptr + 5'b00001;
    end

    always @(posedge clk) begin
        if (rst)
            rd_ptr <= 5'b00000;
        else if (rd_en && !empty)
            rd_ptr <= rd_ptr + 5'b00001;
    end

    assign rd_data= mem[rd_ptr[3:0]];
    always @(posedge clk) begin
        if (wr_en && !full)
            mem[wr_ptr[3:0]] <= wr_data;
        end

    endmodule