module pulse_sync(
    input clk_src,
    input clk_dst,
    input rst,
    input pulse_in,
    output pulse_out
);
reg toggle_q;
reg sync_ff1;
reg sync_ff2;
reg sync_ff2_prev;


always @(posedge clk_src)begin

    if(rst)begin
    toggle_q<=1'b0;
    end

    else if(pulse_in==1)
    toggle_q<=~toggle_q;

    

end

always @(posedge clk_dst)begin

    if(rst)begin
         sync_ff1<=1'b0;
    sync_ff2<=1'b0;
        
    end
   

    else

    sync_ff1<=toggle_q;
    sync_ff2<=sync_ff1;
end

always @(posedge clk_dst)begin
    if(rst)begin
        sync_ff2_prev<=1'b0;
    end
    else
    sync_ff2_prev<=sync_ff2;
end

assign pulse_out= sync_ff2^sync_ff2_prev;
endmodule