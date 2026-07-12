SOURCES = latch.v icg.v register_bank.v tb_register_bank.v
EXECUTABLE = sim_tb
VCD_FILE = clock_gating.vcd

all: simulate

simulate: $(SOURCES)
	iverilog -o $(EXECUTABLE) $(SOURCES)
	vvp $(EXECUTABLE) -vcd

view:
	gtkwave $(VCD_FILE) &

clean:
	rm -f $(EXECUTABLE) $(VCD_FILE) *.vvp

.PHONY: all simulate view clean