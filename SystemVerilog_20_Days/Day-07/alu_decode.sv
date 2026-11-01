module alu_decode (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_op,
    output logic       illegal
);
    localparam logic [3:0] ALU_ADD  = 4'd0;
    localparam logic [3:0] ALU_SUB  = 4'd1;
    localparam logic [3:0] ALU_SLL  = 4'd2;
    localparam logic [3:0] ALU_SLT  = 4'd3;
    localparam logic [3:0] ALU_SLTU = 4'd4;
    localparam logic [3:0] ALU_XOR  = 4'd5;
    localparam logic [3:0] ALU_SRL  = 4'd6;
    localparam logic [3:0] ALU_SRA  = 4'd7;
    localparam logic [3:0] ALU_OR   = 4'd8;
    localparam logic [3:0] ALU_AND  = 4'd9;

    always_comb begin
        alu_op = ALU_ADD;
        illegal = 1'b0;

        // Exact opcode decode: mutually exclusive instruction classes.
        unique case (opcode)
            7'b0110011,  // R-type
            7'b0010011: begin // I-type ALU
                // Pattern matching is useful for shift encodings.
                casez ({funct7, funct3})
                    10'b???????_000: begin
                        if ((opcode == 7'b0110011) && (funct7 == 7'b0100000))
                            alu_op = ALU_SUB;
                        else
                            alu_op = ALU_ADD;
                    end
                    10'b0000000_001: alu_op = ALU_SLL;
                    10'b???????_010: alu_op = ALU_SLT;
                    10'b???????_011: alu_op = ALU_SLTU;
                    10'b???????_100: alu_op = ALU_XOR;
                    10'b0000000_101: alu_op = ALU_SRL;
                    10'b0100000_101: alu_op = ALU_SRA;
                    10'b???????_110: alu_op = ALU_OR;
                    10'b???????_111: alu_op = ALU_AND;
                    default: begin
                        alu_op = ALU_ADD;
                        illegal = 1'b1;
                    end
                endcase
            end

            default: begin
                alu_op = ALU_ADD;
                illegal = 1'b1;
            end
        endcase
    end

    // Priority-case demonstration: select the first asserted request.
    // This independent module is provided below in irq_priority_case.sv.
endmodule
