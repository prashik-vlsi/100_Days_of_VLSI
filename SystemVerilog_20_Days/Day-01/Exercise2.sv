module exercise2;
  typedef enum logic [1:0] {RED, YELLOW, GREEN} light_t;
  light_t light;

  initial begin
    light = RED;
    $display("%s", light.name());

    light = YELLOW;
    $display("%s", light.name());

    light = GREEN;
    $display("%s", light.name());
  end
endmodule