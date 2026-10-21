module exercise1;
  logic [7:0] data;

  initial begin
    data = 8'hA5;
    $display("bin=%b hex=%h dec=%0d", data, data, data);
  end
endmodule