setenv CEP_INSTALL <CEP Chipyard INSTALLATION DIRECTORY>/sims/cep_cosim

setenv MY_REGRESSION_AREA ${CEP_INSTALL}/testSuites/tracking/regression
setenv MY_REGRESSION ${CEP_INSTALL}/testSuites/tracking

setenv VM_DASHBOARD ${CEP_INSTALL}/vmanager/scripts
setenv VPLAN_TOP ${CEP_INSTALL}/vmanager/cep_vPlan

#Set environment variables to use the cosim/cadence.make setup
setenv VMGR_VERSION    VMANAGERAGILE20.06.001
setenv VMGR_DIR        /brewhouse/cad4/x86_64/Cadence/VMANAGERAGILE20.06.001/tools/bin
setenv VMGR_PATH       /brewhouse/cad4/x86_64/Cadence/${VMGR_VERSION}/tools/bin
setenv PATH            ${PATH}:${VMGR_PATH}

setenv XCELIUM_VERSION XCELIUMAGILE20.09.001
setenv XCELIUM_DIR     /brewhouse/cad4/x86_64/Cadence/XCELIUMAGILE20.09.001/tools/bin
setenv XCELIUM_INSTALL /brewhouse/cad4/x86_64/Cadence/${XCELIUM_VERSION}
setenv XCELLIUM_PATH   ${XCELIUM_INSTALL}/tools/bin
setenv PATH            ${PATH}:${XCELLIUM_PATH}

# Tool configuration and licenses
setenv CADENCE_ENABLE_AVSREQ_44905_PHASE_1 1
setenv CADENCE_ENABLE_AVSREQ_63188_PHASE_1 1

# RISCV Toolchain
setenv RISCV /data/riscv7
setenv RISCV_DIR ${RISCV}
setenv PATH ${PATH}:${RISCV}/bin


