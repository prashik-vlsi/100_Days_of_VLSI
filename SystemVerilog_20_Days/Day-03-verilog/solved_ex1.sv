module dyn;
	int dyn [];
	initial begin
		dyn=new[3];
		dyn[0]=10; dyn[1]=20; dyn[2]=30;
		$display("size=%0d", dyn.size());
		dyn = new[5](dyn);
		$display("size=%0d d3=%0d d4=%0d", dyn.size(), dyn[3], dyn[4]);

		dyn.delete();
		$display("after delete size=%0d", dyn.size());

	end
endmodule
