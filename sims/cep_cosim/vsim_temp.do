#
# Temporary TCL script to support elaboration of the Chipyard-based CEP
#
vlog -sv -f firrtl_black_box_resource_files.top.f
vlog -sv EICG_wrapper.v
vlog -sv chipyard.TestHarness.CEPASICRocketConfig.top.mems.v
vlog -sv chipyard.TestHarness.CEPASICRocketConfig.top.v
vopt +acc work.ChipTop -o debugver
vsim debugver -cpppath "/usr/bin/g++"
run 1ns