module mealy(
    input rst, 
    input clk,
    input in,
    output wire out
);

reg [1:0]s;

parameter s0=2'b00;
parameter s1=2'b01;
parameter s2=2'b10;
parameter s3=2'b11;

reg [1:0]next_state=s0;

always @(posedge clk or posedge rst)begin
    if(rst)
        s<=s0;
    else
        s<=next_state;
    end
always @(*)begin 

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
            if(in) next_state = s1;
            else   next_state = s2;
        end
        default: next_state = s0;
          
        endcase
    end
    
   assign out = (s == s3 && in == 1) ? 1 : 0;
endmodule



