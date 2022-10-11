# for LED blinky test
TOP_MODULE = testram
VHDL_TOP_MODULE = sdram
VERILOG = testram.v ecp5pll.sv
VHDL = sdram.vhd

PIN_DEF = ulx3s_v20.lpf
DEVICE = 12k

include ulx3s.mk
