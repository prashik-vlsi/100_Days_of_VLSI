// icg.v - Integrated Clock Gating Cell
module icg (
    input clk,
    input en,                  // ← Changed from 'enable' to 'en'
    output gclk                // ← Changed from 'gated_clk' to 'gclk'
);
    wire en_latched;
    
    // Latch on negative clock edge
    LATCH u_latch (
        .D(en),
        .G(~clk),
        .Q(en_latched),
        .QN()
    );
    
    // AND gate to gate the clock
    assign gclk = clk & en_latched;
    
endmodule