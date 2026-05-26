module encoder_4x2(

    input [3:0]y,

    output A,
    output B
);

assign A= y[2]|y[3];

assign B = y[1]|y[3];

endmodule