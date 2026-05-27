module priority_encoder(

    input [3:0]y,
    output a,
    output b
);
assign a=y[2]|y[3];

assign b=y[3]|(y[1]&~y[2]);

endmodule