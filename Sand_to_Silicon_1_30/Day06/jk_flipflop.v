module jk_flipflop(

    input j,
    input k,
    input clk,
    output reg Q,
    output reg Qbar
);
initial begin 

Q=0;
Qbar=1;
end 

always @(posedge clk) begin

if (j==0 && k ==0 )begin
end
else if (j==0 && k == 1) begin
    Q<=0;
    Qbar<=1;
end

else if( j==1 && k == 0 ) begin 
    Q<=1;
    Qbar<=0;
end
else begin 
Q<=~Q;
Qbar<=~Qbar;
end 
end
endmodule
