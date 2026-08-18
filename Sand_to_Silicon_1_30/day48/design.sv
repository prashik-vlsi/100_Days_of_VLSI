module mux4_1(
    input  logic [7:0] a, b, c, d,
    input  logic [1:0] sel,
    output logic [7:0] out
);

always_comb begin
    case(sel)
        2'b00: out = a;
        2'b01: out = b;
        2'b10: out = c;
        2'b11: out = d;
        default: out = 8'b0; 
    endcase
end

endmodule