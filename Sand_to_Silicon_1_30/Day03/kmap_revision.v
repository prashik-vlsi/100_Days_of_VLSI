module kmap_revision(

    input a,
    input b,
    input c,
    output y
);

assign y = (a&~c)|(a&b)|(b&~c);
endmodule