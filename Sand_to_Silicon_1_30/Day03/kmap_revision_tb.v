module kmap_revision_tb;

    reg a;
    reg b;
    reg c;
    wire y;


    kmap_revision uut(

        .a(a),
        .b(b),
        .c(c),
        .y(y)
    );

    initial begin

    $dumpfile("rev_kmap_dump.vcd");
    $dumpvars(0,  kmap_revision_tb);

    a=0; b=0; c=0; #10;
    a=0; b=0; c=1;  #10;
    a=0; b=1; c=0; #10;
    a=0; b=1; c=1; #10;
    a=1; b=0; c=0; #10;
    a=1; b=0; c=1; #10;
    a=1; b=1; c=0; #10;
    a=1; b=1; c=1; #10;
   
   $finish;
end 

   initial begin
    $monitor("Time=%0t a=%b b=%b  c=%b y=%b",
    $time, a, b, c, y);
end

endmodule
