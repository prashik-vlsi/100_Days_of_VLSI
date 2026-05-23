module kmap(

    input a,
    input b,
    input c,
    input d,
    output f
);
assign f=d|(~b&~c);
endmodule
