module sr_latch(

    input s,
    input r,
    output reg Q,
    output reg Qbar
);

always @(*)
begin 
    if(s==0 && r==0)begin
     
    end
    else if(s==0&&r==1)begin
        Q<=0;
        Qbar<=1;
    end

    else if(s==1 && r==0)begin
        Q<=1;
        Qbar<=0;
    end
    else begin
        Q<=1'bx;
        Qbar<=1'bx;

    end
    end 
endmodule
