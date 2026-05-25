module mux2_1(

    input s,
    input i0,
    input i1,

    output y
);

assign y=(~s&i0)|(s&i1);
endmodule
