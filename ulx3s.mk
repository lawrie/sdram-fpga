DEVICE ?= 85k
PIN_DEF ?= ulx3s_v20.lpf
#IDCODE ?= 0x41113043 # 85f

BUILDDIR = bin

compile: $(BUILDDIR)/toplevel.bit

prog: $(BUILDDIR)/toplevel.bit
	fujprog $^

$(BUILDDIR)/toplevel.json: $(VERILOG) $(VHDL)
	mkdir -p $(BUILDDIR)
	yosys \
	-p "read_verilog -sv $(VERILOG)" \
	-p "ghdl --ieee=synopsys --std=08 -fexplicit -frelaxed-rules $(VHDL) -e $(VHDL_TOP_MODULE)" \
	-p "hierarchy -top ${TOP_MODULE}" \
	-p "synth_ecp5 ${YOSYS_OPTIONS} -json $(BUILDDIR)/toplevel.json"


$(BUILDDIR)/%.config: $(PIN_DEF) $(BUILDDIR)/toplevel.json
	nextpnr-ecp5 --${DEVICE} --package CABGA381 --freq 25 --timing-allow-fail --textcfg  $@ --json $(filter-out $<,$^) --lpf $<

$(BUILDDIR)/toplevel.bit: $(BUILDDIR)/toplevel.config
	ecppack --compress $^ $@

tb: test68.v $(VERILOG)
	iverilog -o tb tb.v $(VERILOG)

sim: tb
	./tb

clean:
	rm -rf ${BUILDDIR}

.SECONDARY:
.PHONY: compile clean prog
