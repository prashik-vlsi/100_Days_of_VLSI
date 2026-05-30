module moore_seq_detector(

    input rst,
    input clk,
    input in,
    output wire out
);
reg [2:0]s;
parameter s0=3'b000;
parameter s1=3'b001;
parameter s2=3'b010;
parameter s3=3'b011;
parameter s4 =3'b100;

reg [2:0]next_state;

always@(posedge clk or posedge rst)begin

if(rst)
    s<=s0;
else
    s<=next_state;
    end
always @(*) begin
    case(s)
        s0: begin
            if(in) next_state = s1;
            else   next_state = s0;
        end
          s1: begin
            if(in) next_state = s1;
            else   next_state = s2;
        end
          s2: begin
            if(in) next_state = s3;
            else   next_state = s0;
        end
          s3: begin
            if(in) next_state = s4;
            else   next_state = s2;
        end
          s4: begin
            if(in) next_state = s1;
            else   next_state = s3;
        end
        endcase
    end
    
   assign out = (s== s4) ? 1 : 0;
endmodule





