module barrel_shifter_tb;
    reg [7:0]in;
    reg [2:0]shamt;
    reg [2:0]mode;
    wire [7:0]out;
barrel_shifter DUT(
    .in(in),
    .shamt(shamt),
    .mode(mode),
    .out(out)
);

    initial begin
        $dumpfile("barrel.vcd");
        $dumpvars(0, barrel_shifter_tb);

        $monitor("Time=%0t, in=%b, out=%b, shamt=%b, mode=%b",
        $time, in , out , shamt, mode);

        // --- Test Case 1: Logical Shift Left (LSL) ---
            in = 8'b0000_0011; shamt = 2; mode = 3'b000;
            #10; // Wait 10 nanoseconds

            // --- Test Case 2: Logical Shift Right (LSR) ---
            in = 8'b1100_0000; shamt = 3; mode = 3'b001;
            #10;

            // --- Test Case 3: Arithmetic Shift Right (ASR) ---
            in = 8'b1000_1111; shamt = 2; mode = 3'b010; // Sign bit (1) should replicate
            #10;

            // --- Test Case 4: Rotate Left (ROL) ---
            in = 8'b1011_0010; shamt = 3; mode = 3'b011;
            #10;

            // --- Test Case 5: Rotate Right (ROR) ---
            in = 8'b1011_0010; shamt = 3; mode = 3'b100;
            #10;

            // End the simulation
            $finish;
        end
  
endmodule


