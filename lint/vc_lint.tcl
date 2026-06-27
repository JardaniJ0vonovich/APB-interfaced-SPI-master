#Liberty files are needed for logical and physical netlist designs
set search_path "./"
set link_library " "

set_app_var enable_lint true

#configure_lint_tag -enable -tag "W241" -goal lint_rtl
#configure_lint_tag -enable -tag "W240" -goal lint_rtl

configure_lint_setup -goal lint_rtl

analyze -verbose -format verilog "../rtl/top_module.v"
analyze -verbose -format verilog "../rtl/apb_slave_interface.v"
analyze -verbose -format verilog "../rtl/spi_shifter.v"
analyze -verbose -format verilog "../rtl/spi_slave_select.v"
analyze -verbose -format verilog "../rtl/baud_rate.v"

elaborate top_module

check_lint

report_lint -verbose -file report_lint_top_module.txt

