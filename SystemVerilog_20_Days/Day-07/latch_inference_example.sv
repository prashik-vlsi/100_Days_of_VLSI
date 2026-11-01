// EDUCATIONAL EXAMPLE ONLY: this code intentionally infers a level-sensitive latch.
// Do not use this coding pattern for a purely combinational RV32I immediate generator.
module latch_inference_example (
    input  logic       en,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);
    always_comb begin
        if (en)
            data_out = data_in;
        // Missing else assignment: data_out must retain its previous value.
        // That storage behaviour is a latch, and violates always_comb expectations.
    end
endmodule
