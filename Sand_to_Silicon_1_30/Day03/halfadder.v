module halfadder (

    input a,
    input b,
    output sum,
    output carr
);

assign  sum= a^b;
assign  carr = a&b;
endmodule