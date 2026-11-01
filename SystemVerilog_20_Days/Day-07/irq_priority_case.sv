module irq_priority_case (
    input  logic [3:0] irq,
    output logic [1:0] irq_id,
    output logic       valid
);
    always_comb begin
        irq_id = 2'd0;
        valid  = 1'b0;

        priority casez (irq)
            4'b1???: begin irq_id = 2'd3; valid = 1'b1; end
            4'b01??: begin irq_id = 2'd2; valid = 1'b1; end
            4'b001?: begin irq_id = 2'd1; valid = 1'b1; end
            4'b0001: begin irq_id = 2'd0; valid = 1'b1; end
            default: begin end
        endcase
    end
endmodule
