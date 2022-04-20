# This script should be sourced in a csh/tcsh.

# NOTE: Vivado is not available in this environment and will not be run here.
#       To run Vivado use the Richmond (ri) setup in the Richmond datacenter.

# Set before calling this script
#setenv CEP_INSTALL `pwd`

# Check that the environment variable for the work area is set
if ( !($CEP_INSTALL) ) then
    echo Error: \$CEP_INSTALL must be defined.  Exiting.
    exit
endif

# Xilinx Components Necessary for Simulation
# cd /dvplats/rh7_2_tools/3rdParty/Xilinx_Installation/Xilinx/Vivado/2018.3
# tar cvzf ~/projects/cep/xilinx_extras.tgz data/rsb/non_default_iprepos/micron_ddr3_v2_0 data/verilog/src
#setenv VIVADO_PATH /grid/tfo/fast_fe_na_scratch/users/dmurray/dev/darpa_cep/VIVADO_PATH

if ( !($VIVADO_PATH) ) then
    echo Error: \$VIVADO_PATH must be defined.  Exiting.
    exit
endif


# Set environment variables to use the cosim/cadence.make setup
setenv VMGR_VERSION    20.06.001
setenv VMGR_DIR        /grid/avs/install/vmanager/AGILE
setenv XCELIUM_VERSION 20.09.001
setenv XCELIUM_DIR     /grid/avs/install/xcelium/AGILE

setenv PATH /grid/common/pkgs/dtc/v1.4.2/bin:${PATH}
setenv PATH /grid/common/pkgs/jdk/v1.8.0_191/bin:${PATH}
setenv PATH /grid/common/pkgs/gcc/v4.8.3/bin:${PATH}

# Tool configuration and licenses
setenv CADENCE_ENABLE_AVSREQ_44905_PHASE_1 1
setenv CADENCE_ENABLE_AVSREQ_63188_PHASE_1 1
setenv LM_LICENSE_FILE 5280@sjflex:5281@sjflex:5280@sjflex1:5280@sjflex2:5280@sjflex3

# RISCV Toolchain
setenv RISCV $CEP_INSTALL/software/riscv-gnu-toolchain/riscv
setenv PATH $RISCV/bin:${PATH}

# Aliases
alias cdcep 'cd $CEP_INSTALL'
