#!/usr/bin/env bash

export CEP_INSTALL=$(cd ../..; pwd)

export MY_REGRESSION_AREA=${CEP_INSTALL}/testSuites/tracking/regression
export MY_REGRESSION=${CEP_INSTALL}/testSuites/tracking

export VM_DASHBOARD=${CEP_INSTALL}/vmanager/scripts
export VPLAN_TOP=${CEP_INSTALL}/vmanager/cep_vPlan

#Set environment variables to use the cosim/cadence.make setup
export VMGR_VERSION=VMANAGERAGILE20.06.001
export VMGR_DIR=/brewhouse/cad4/x86_64/Cadence/VMANAGERAGILE20.06.001/tools/bin
export VMGR_PATH=/brewhouse/cad4/x86_64/Cadence/${VMGR_VERSION}/tools/bin
export PATH=${PATH}:${VMGR_PATH}

export XCELIUM_VERSION=XCELIUMAGILE20.09.001
export XCELIUM_DIR=/brewhouse/cad4/x86_64/Cadence/XCELIUMAGILE20.09.001/tools/bin
export XCELIUM_INSTALL=/brewhouse/cad4/x86_64/Cadence/${XCELIUM_VERSION}
export XCELLIUM_PATH=${XCELIUM_INSTALL}/tools/bin
export PATH=${PATH}:${XCELLIUM_PATH}

# # Tool configuration and licenses
export CADENCE_ENABLE_AVSREQ_44905_PHASE_1=1
export CADENCE_ENABLE_AVSREQ_63188_PHASE_1=1
