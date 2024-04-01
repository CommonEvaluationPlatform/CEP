//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : cep_scratchpad.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : Provides a discrete blackbox scratchpad instantiation to facilitate
//                replacement during ASIC builds
//
//--------------------------------------------------------------------------------------
package mitllBlocks.cep_scratchpad

import chisel3._
import chisel3.util._
import chisel3.experimental.{IntParam, BaseModule}
import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.subsystem.{BaseSubsystem, PeripheryBusKey}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.regmapper._
import freechips.rocketchip.tilelink._

import mitllBlocks.cep_addresses._

//--------------------------------------------------------------------------------------
// BEGIN: Scratchpad "Periphery" connections
//--------------------------------------------------------------------------------------

// Parameters associated with the Scratchpad
case object CEPScratchpadKey extends Field[Seq[COREParams]](Nil)

// This trait "connects" the Scratchpad to the Rocket Chip and passes the parameters down
// to the instantiation
trait CanHaveCEPScratchpad { this: BaseSubsystem =>
  val ScratchpadNodes = p(CEPScratchpadKey).map { params =>

    // Initialize the attachment parameters
    val coreattachparams = COREAttachParams(
      coreparams      = params,
      slave_bus       = mbus,    // The scratchpad is connected to the Memory Bus
      llki_bus        = pbus
    )

    // Generate the clock domain for this module
    val scratchpadDomain = coreattachparams.slave_bus.generateSynchronousDomain

    // Define the Tilelink module
    scratchpadDomain {
      val module = LazyModule(new scratchpadTLModule(coreattachparams)(p)).suggestName(coreattachparams.coreparams.dev_name+"module")

      // Perform the slave "attachments" to the specified bus... fragment as required
      coreattachparams.slave_bus.coupleTo(coreattachparams.coreparams.dev_name) {
        module.slave_node :*=
        TLSourceShrinker(16) :*=
        TLFragmenter(coreattachparams.slave_bus) :*=_
      }

    } // scratchpadDomain

}}

//--------------------------------------------------------------------------------------
// END: Scratchpad "Periphery" connections
//--------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
// BEGIN: Tilelink Scratchpad Module and Module Implementation Declerations
//
// Note: If one does not explicitly put "supportsPutFull" and/or "supportsPutPartial"
//   in the slave parameters, the manager will be instantiated as Read Only (and will
//   show up as such in the device tree.  Also, the chisel optimization that gets
//   "kicked off" because of the inclusion of diplomacy widgets will result in the A
//   channel data bus being tied to ZERO.
//--------------------------------------------------------------------------------------
class scratchpadTLModule(coreattachparams: COREAttachParams)(implicit p: Parameters) extends LazyModule {

  // Create a Manager / Slave / Sink node
  // These parameters have been copied from SRAM.scala
  val slave_node = TLManagerNode(Seq(TLSlavePortParameters.v1(
    Seq(TLSlaveParameters.v1(
      address             = Seq(AddressSet(
                              coreattachparams.coreparams.slave_base_addr, 
                              coreattachparams.coreparams.slave_depth)),
      resources           = new SimpleDevice(coreattachparams.coreparams.dev_name, 
                              Seq("mitll," + coreattachparams.coreparams.dev_name)).reg("mem"),
      regionType          = RegionType.UNCACHED,
      executable          = true,
      supportsGet         = TransferSizes(1, 8),
      supportsPutFull     = TransferSizes(1, 8),
      supportsPutPartial  = TransferSizes(1, 8),
      supportsArithmetic  = TransferSizes.none,
      supportsLogical     = TransferSizes.none,
      fifoId              = Some(0))),  // requests are handled in order
    beatBytes   = 8,                    // Scratchpad width is fixed at 8 bytes
    minLatency  = 1)))
    
    // Instantiate the implementation
    lazy val module = new scratchpadTLModuleImp(coreattachparams.coreparams, this)

} // end scratchpadTLModule

class scratchpadTLModuleImp(coreparams: COREParams, outer: scratchpadTLModule) extends LazyModuleImp(outer) {

  // "Connect" to Slave Node's signals and parameters
  val (slave, slaveEdge)    = outer.slave_node.in(0)

  // Ensure unused channels are tied off
  slave.b.valid   := false.B
  slave.c.ready   := true.B
  slave.e.ready   := true.B

  // Define scratchpad_wrapper blackbox and its associated IO
  class scratchpad_wrapper(   address           : BigInt, 
                              depth             : BigInt,
                              slave_tl_szw      : Int,
                              slave_tl_aiw      : Int,
                              slave_tl_aw       : Int,
                              slave_tl_dbw      : Int,
                              slave_tl_dw       : Int,
                              slave_tl_diw      : Int) extends BlackBox (
      Map(
        "ADDRESS"                       -> IntParam(address),       // Base address of the TL slave
        "DEPTH"                         -> IntParam(depth),         // Address depth of the TL slave
        "SLAVE_TL_SZW"                  -> IntParam(slave_tl_szw),
        "SLAVE_TL_AIW"                  -> IntParam(slave_tl_aiw),
        "SLAVE_TL_AW"                   -> IntParam(slave_tl_aw),
        "SLAVE_TL_DBW"                  -> IntParam(slave_tl_dbw),
        "SLAVE_TL_DW"                   -> IntParam(slave_tl_dw),
        "SLAVE_TL_DIW"                  -> IntParam(slave_tl_diw)
      )
  ) with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk               = Input(Clock())
      val rst               = Input(Reset())

      // Slave - Tilelink A Channel (Signal order/names from Tilelink Specification v1.8.0)
      val slave_a_opcode    = Input(UInt(3.W))
      val slave_a_param     = Input(UInt(3.W))
      val slave_a_size      = Input(UInt(slave_tl_szw.W))
      val slave_a_source    = Input(UInt(slave_tl_aiw.W))
      val slave_a_address   = Input(UInt(slave_tl_aw.W))
      val slave_a_mask      = Input(UInt(slave_tl_dbw.W))
      val slave_a_data      = Input(UInt(slave_tl_dw.W))
      val slave_a_corrupt   = Input(Bool())
      val slave_a_valid     = Input(Bool())
      val slave_a_ready     = Output(Bool())

      // Slave - Tilelink D Channel (Signal order/names from Tilelink Specification v1.8.0)
      val slave_d_opcode    = Output(UInt(3.W))
      val slave_d_param     = Output(UInt(3.W))
      val slave_d_size      = Output(UInt(slave_tl_szw.W))
      val slave_d_source    = Output(UInt(slave_tl_aiw.W))
      val slave_d_sink      = Output(UInt(slave_tl_diw.W))
      val slave_d_denied    = Output(Bool())
      val slave_d_data      = Output(UInt(slave_tl_dw.W))
      val slave_d_corrupt   = Output(Bool())
      val slave_d_valid     = Output(Bool())
      val slave_d_ready     = Input(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/llki/scratchpad_wrapper.sv")

  } // end class scratchpad_wrapper

  // Instantiate the scratchpad_wrapper
  // As the depth parameter is being used to define the size of the instantiated memory, it must be incremented by +1 before
  // passing it down to the scratchpad_wrapper
  val scratchpad_wrapper_inst = Module(new scratchpad_wrapper(
    coreparams.slave_base_addr, 
    coreparams.slave_depth + 1,
    slaveEdge.bundle.sizeBits,
    slaveEdge.bundle.sourceBits,
    slaveEdge.bundle.addressBits,
    slaveEdge.bundle.dataBits / 8,
    slaveEdge.bundle.dataBits,
    slaveEdge.bundle.sinkBits
  ))

  // Connect the Clock and Reset
  scratchpad_wrapper_inst.io.clk                := clock
  scratchpad_wrapper_inst.io.rst                := reset

  // Connect the Slave A Channel to the Black box IO
  scratchpad_wrapper_inst.io.slave_a_opcode     := slave.a.bits.opcode    
  scratchpad_wrapper_inst.io.slave_a_param      := slave.a.bits.param     
  scratchpad_wrapper_inst.io.slave_a_size       := slave.a.bits.size
  scratchpad_wrapper_inst.io.slave_a_source     := slave.a.bits.source    
  scratchpad_wrapper_inst.io.slave_a_address    := slave.a.bits.address
  scratchpad_wrapper_inst.io.slave_a_mask       := slave.a.bits.mask      
  scratchpad_wrapper_inst.io.slave_a_data       := slave.a.bits.data      
  scratchpad_wrapper_inst.io.slave_a_corrupt    := slave.a.bits.corrupt   
  scratchpad_wrapper_inst.io.slave_a_valid      := slave.a.valid          
  slave.a.ready                                 := scratchpad_wrapper_inst.io.slave_a_ready  

  // Connect the Slave D Channel to the Black Box IO    
  slave.d.bits.opcode                           := scratchpad_wrapper_inst.io.slave_d_opcode
  slave.d.bits.param                            := scratchpad_wrapper_inst.io.slave_d_param
  slave.d.bits.size                             := scratchpad_wrapper_inst.io.slave_d_size
  slave.d.bits.source                           := scratchpad_wrapper_inst.io.slave_d_source
  slave.d.bits.sink                             := scratchpad_wrapper_inst.io.slave_d_sink
  slave.d.bits.denied                           := scratchpad_wrapper_inst.io.slave_d_denied
  slave.d.bits.data                             := scratchpad_wrapper_inst.io.slave_d_data
  slave.d.bits.corrupt                          := scratchpad_wrapper_inst.io.slave_d_corrupt
  slave.d.valid                                 := scratchpad_wrapper_inst.io.slave_d_valid
  scratchpad_wrapper_inst.io.slave_d_ready      := slave.d.ready
  
} // end scratchpadTLModuleImp
//--------------------------------------------------------------------------------------
// END: Tilelink Scratchpad Module and Module Implementation Declerations
//--------------------------------------------------------------------------------------

