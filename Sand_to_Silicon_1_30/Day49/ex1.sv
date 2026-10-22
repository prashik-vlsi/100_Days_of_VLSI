module ex1;
	logic [7:0] mem[4];
	initial begin
		mem[0]= 8'h10;
		mem[1]= 8'h20;
		mem[2]= 8'h30;
		mem[3]= 8'h40;
		mem[4] = 8'h50;
		
		foreach( mem[i])
			$display("mem[%0d]='%h", i, mem[i]);
		
		end
endmodule
