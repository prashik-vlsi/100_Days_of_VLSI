module demux(
    input s,
    input i,
    output y0,
    output y1
);

assign y0= ~s&i;
assign y1= s&i;

endmodule