module substractor(

    input a, 
    input b, 
    input bin, 
    output bout, 
    output diff
);

assign bout = (~a & b) | (~a & bin) | (b & bin);
assign diff = a^b^bin;


endmodule
