module d_latch(

    input d,
    input en,

    output reg Q,
    output reg Qbar

);

initial begin
    Q = 0;
    Qbar = 1;
end

always @(*) begin

    if(en == 1) begin
        Q    <= d;
        Qbar <= ~d;
    end

end

endmodule

  
