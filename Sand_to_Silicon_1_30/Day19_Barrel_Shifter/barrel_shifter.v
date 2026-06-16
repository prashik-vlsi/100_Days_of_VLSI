module barrel_shifter #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] in,
    input  [2:0]       shamt,
    input  [2:0]       mode,
    output reg [WIDTH-1:0] out
);
wire [2*WIDTH-1:0] rol_temp;
wire [2*WIDTH-1:0] ror_temp;

assign rol_temp = {in, in} << shamt;
assign ror_temp = {in, in} >> shamt;

    always @(*) begin 
        case(mode)
            // Mode 0: Logical Shift Left (LSL)
            3'b000: begin
                out = in << shamt;
            end
            
            // Mode 1: Logical Shift Right (LSR)
            3'b001: begin
                out = in >> shamt;
            end
            
            // Mode 2: Arithmetic Shift Right (ASR)
            3'b010: begin
                out = $signed(in) >>> shamt;
            end
            
            // Mode 3: Rotate Left (ROL)
            3'b011: begin 
                out = rol_temp[2*WIDTH-1:WIDTH];
            end
            
            // Mode 4: Rotate Right (ROR)
            3'b100: begin 
                 out = ror_temp[WIDTH-1:0];
            end

            
            default: begin
                out = in;
            end
        endcase
    end

endmodule