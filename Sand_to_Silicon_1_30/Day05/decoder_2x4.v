module decoder_2x4 (

    input A,
    input B,

    output [3:0] Y

);

assign Y[0] = ~A & ~B;
assign Y[1] = ~A &  B;
assign Y[2] =  A & ~B;
assign Y[3] =  A &  B;

endmodule



