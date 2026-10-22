/*Problem statement:
Two systems store multi-byte data in opposite byte order (little-endian and big-endian).
 A 32-bit word arrives in one order and must be converted to the other by reversing its four bytes.*/

module ex2;

    logic [3:0][7:0] word;
    logic [3:0][7:0] swapped;
        initial begin
            word=32'h11223344;
            for(int i=0; i<4; i++)
                swapped[3-i]=word[i];
            
            $display("word = %h", word);
            $display("swapped=%h", swapped);

    end
endmodule
