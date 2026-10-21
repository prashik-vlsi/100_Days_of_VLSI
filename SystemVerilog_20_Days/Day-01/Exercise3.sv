module exercise3;
  typedef struct packed {
    logic [7:0] r;
    logic [7:0] g;
    logic [7:0] b;
  } pixel_t;

  pixel_t pixel;

  initial begin
    pixel.r = 8'hFF;
    pixel.g = 8'h80;
    pixel.b = 8'h00;
    $display("%h", pixel);
  end
endmodule
