
module irq_encoder (
    input  logic [7:0] irq,
    output logic [2:0] irq_id,
    output logic       valid
);

    always_comb begin

        irq_id = 3'b000;
        valid  = 1'b0;

        if (irq[7]) begin
            irq_id = 3'd7;
            valid  = 1'b1;
        end
        else if (irq[6]) begin
            irq_id = 3'd6;
            valid  = 1'b1;
        end
        else if (irq[5]) begin
            irq_id = 3'd5;
            valid  = 1'b1;
        end
        else if (irq[4]) begin
            irq_id = 3'd4;
            valid  = 1'b1;
        end
        else if (irq[3]) begin
            irq_id = 3'd3;
            valid  = 1'b1;
        end
        else if (irq[2]) begin
            irq_id = 3'd2;
            valid  = 1'b1;
        end
        else if (irq[1]) begin
            irq_id = 3'd1;
            valid  = 1'b1;
        end
        else if (irq[0]) begin
            irq_id = 3'd0;
            valid  = 1'b1;
        end

    end

endmodule
