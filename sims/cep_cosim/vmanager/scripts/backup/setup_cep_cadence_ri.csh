# This script should be sourced in a csh/tcsh.

# NOTE: Only workarea setup steps requiring Vivado are run in Richmond.
#       This is not a full setup that will run simulations.

# Set before calling this script
#setenv CEP_INSTALL `pwd`

# Check that the environment variable for the work area is set
if ( !($CEP_INSTALL) ) then
    echo Error: \$CEP_INSTALL must be defined.  Exiting.
    exit
endif

setenv VIVADO_PATH /dvplats/rh7_2_tools/3rdParty/Xilinx_Installation/Xilinx/Vivado/2018.3/bin
setenv PATH ${VIVADO_PATH}:${PATH}

setenv XCELIUM_INSTALL /grid/avs/install/xcelium/AGILE/20.09.001
setenv PATH ${XCELIUM_INSTALL}/tools/bin:${PATH}
setenv PATH /grid/common/pkgs/dtc/v1.4.2/bin:${PATH}
setenv PATH /grid/common/pkgs/jdk/v1.8.0_191/bin:${PATH}
setenv PATH /grid/common/pkgs/gcc/v4.8.3/bin:${PATH}

setenv RISCV $CEP_INSTALL/software/riscv-gnu-toolchain/riscv

# Aliases
alias cdcep 'cd $CEP_INSTALL'
