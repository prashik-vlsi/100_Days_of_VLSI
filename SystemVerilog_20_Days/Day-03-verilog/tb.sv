module tb;
  logic [7:0]      grid [0:2][0:3];  // unpacked 2D
  logic [2:0][7:0] p;                // packed 2D
  logic [3:0][7:0] mem [0:1];        // mixed

  initial begin
    for (int r = 0; r < 3; r++)
      for (int c = 0; c < 4; c++)
        grid[r][c] = 8'(r*10 + c);       // box value = row*10 + col

    $display("grid[2][3] = %0d", grid[2][3]);
    $display("grid[1][0] = %0d", grid[1][0]);

    p = 24'hAABBCC;
    $display("p[2] = %h, p[0] = %h", p[2], p[0]);

    mem[1] = 32'h11223344;
    $display("mem[1][3] = %h", mem[1][3]);
    $display("mem[1][0] = %h", mem[1][0]);
    $display("mem[1][2][7:4] = %h", mem[1][2][7:4]);
  end
endmodule
