module handshake_sync(
       input clk_src,
    input clk_dst,
    input rst,
    input req_in,
    input [7:0]data_in,
    output reg ack_out,
    output reg [7:0]data_out
);
reg req_sync;
reg ack_sync;
reg req_ff1;
reg req_ff2;
reg ack_ff1;
reg ack_ff2;


always @(posedge clk_dst) begin
    if(rst)begin
        req_ff1<=1'b0;
        req_ff2<=1'b0;
    end
    else begin 
    req_ff1<=req_in;
    req_ff2<=req_ff1;
    end 

end

always @(posedge clk_src)begin
    if (rst) begin
        ack_ff1<=1'b0;
        ack_ff2<=1'b0;
    end
    else begin
        ack_ff1<=ack_sync;
        ack_ff2<=ack_ff1;
    end
end

always @(posedge clk_dst)begin
    if(rst)begin
        ack_sync<=1'b0;
        data_out<=1'b0;
    end
    else if(req_ff2==1)begin
        data_out<=data_in;
        ack_sync<=1;
    end
    else if(req_ff2==0)begin
        ack_sync<=0;
    end
end
always @(posedge clk_src)begin
   if(rst)begin
    ack_out<=1'b0;
   end
   else if(ack_ff2==1)begin
    ack_out<=1;
   end
   else if(ack_ff2==0)begin
    ack_out<=0;
   end
end


endmodule
