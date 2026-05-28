module sync_count(
    input clk,
    input rst,
    output reg [3:0] q
);

// FF0 : T0 = 1
always @(posedge clk or posedge rst) begin
    if (rst)
        q[0] <= 1'b0;
    else
        q[0] <= ~q[0];
end

// FF1 : T1 = Q0
always @(posedge clk or posedge rst) begin
    if (rst)
        q[1] <= 1'b0;
    else if (q[0])
        q[1] <= ~q[1];
    else
        q[1] <= q[1];
end

// FF2 : T2 = Q1 & Q0
always @(posedge clk or posedge rst) begin
    if (rst)
        q[2] <= 1'b0;
    else if (q[1]&q[0])
        q[2] <= ~q[2];
    else
        q[2] <= q[2];
end

// FF3 : T3 = Q2 & Q1 & Q0
always @(posedge clk or posedge rst) begin
    if (rst)
        q[3] <= 1'b0;
    else if (q[2]&q[1]&q[0])
        q[3] <= ~q[3];
    else
        q[3] <= q[3];
end

endmodule
