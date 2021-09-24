package opentitan.resources

import chisel3._
import chisel3.util._

// Add all the LLKI SystemVerilog Modules (or customized OpenTitan modules)
addResource("/vsrc/prim_rtl/prim_assert.sv")
addResource("/vsrc/prim_rtl/prim_util_pkg.sv")
addResource("/vsrc/prim_rtl/prim_fifo_sync.sv")
addResource("/vsrc/tlul_rtl/tlul_pkg.sv")
addResource("/vsrc/tlul_rtl/tlul_adapter_host.sv")
