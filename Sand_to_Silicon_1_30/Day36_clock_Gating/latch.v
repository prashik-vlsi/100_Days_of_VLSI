// latch.v - D-Latch Implementation
module LATCH (
    input D,
    input G,
    output Q,
    output QN
);
    reg Q_internal;
    
    always @(*) begin
        if (G)
            Q_internal <= D;
    end
    
    assign Q = Q_internal;
    assign QN = ~Q_internal;
endmodule