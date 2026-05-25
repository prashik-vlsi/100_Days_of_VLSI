module comparator (

    input a,
    input b,
    output eq,
    output gt,
    output ls
);

assign eq = a==b;
assign gt= a>b;
assign ls = a<b;
endmodule