remove_design -all
set search_path {../lib}
set target_library {lsi_10k.db}
set link_library "* lsi_10k.db"

analyze -format verilog {../rtl/top_module.v}
analyze -format verilog {../rtl/baud_rate.v}
analyze -format verilog {../rtl/spi_slave_select.v}
analyze -format verilog {../rtl/apb_slave_interface.v}
analyze -format verilog {../rtl/spi_shifter.v}

elaborate top_module

link

check_design

current_design  top_module

compile_ultra

write_file -f verilog -hier -output top_module_netlist.v
