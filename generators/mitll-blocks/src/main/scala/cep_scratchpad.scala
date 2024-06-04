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
import org.chipsalliance.cde.config.{Field, Parameters, Config}
import freechips.rocketchip.subsystem.{BaseSubsystem, PeripheryBusKey, PBUS, MBUS, FBUS}
import org.chipsalliance.diplomacy.lazymodule._
import freechips.rocketchip.diplomacy.{SimpleDevice, IdRange, TransferSizes, RegionType, AddressSet}
import freechips.rocketchip.regmapper.{HasRegMap, RegField, RegFieldGroup, RegFieldDesc}
import freechips.rocketchip.tilelink._

import mitllBlocks.cepPackage._

//--------------------------------------------------------------------------------------
// BEGIN: Module "Periphery" connections
//--------------------------------------------------------------------------------------

// Parameters associated with the Scratchpad
case object CEPScratchpadKey extends Field[Seq[COREParams]](Nil)

// This trait "connects" the Scratchpad to the Rocket Chip and passes the parameters down
// to the instantiation
trait CanHaveCEPScratchpad { this: BaseSubsystem =>
  val scratchpadNode = p(CEPScratchpadKey).map { params =>

    // Pull in the rocket-chip bus references
    val pbus = locateTLBusWrapper(PBUS)
    val mbus = locateTLBusWrapper(MBUS)
    val fbus = locateTLBusWrapper(FBUS)

    // Map the core parameters
    val coreparams : COREParams = params

    // Initialize the attachment parameters
    val coreattachparams = COREAttachParams(
      slave_bus   = mbus
    )

    // Generate (and name) the clock domain for this module
    val coreDomain = coreattachparams.slave_bus.generateSynchronousDomain(coreparams.dev_name + "_").suggestName(coreparams.dev_name+"_ClockSinkDomain_inst")

    // Instantiate the TL Module
    val module = coreDomain { LazyModule(new coreTLModule(coreparams, coreattachparams)(p)).suggestName(coreparams.dev_name+"_module_inst")}

    // Define the Tilelink module 
    coreDomain {

      // Perform the slave "attachments" to the slave bus
      coreattachparams.slave_bus.coupleTo(coreparams.dev_name + "_slave") {
        module.slave_node :*=
        TLFragmenter(coreattachparams.slave_bus) :*= _
      }

    } // coreDomain

}}
//--------------------------------------------------------------------------------------
// END: Module "Periphery" connections
//--------------------------------------------------------------------------------------
 


//--------------------------------------------------------------------------------------
// BEGIN: TileLink Module
//--------------------------------------------------------------------------------------
class coreTLModule(coreparams: COREParams, coreattachparams: COREAttachParams)(implicit p: Parameters) extends LazyModule {
  override lazy val desiredName = coreparams.dev_name + "_module"

  // Create a Manager / Slave / Sink node
  // These parameters have been copied from SRAM.scala
  val slave_node = TLManagerNode(Seq(TLSlavePortParameters.v1(
    Seq(TLSlaveParameters.v1(
      address             = Seq(AddressSet(
                              coreparams.slave_base_addr, 
                              coreparams.slave_depth)),
      resources           = new SimpleDevice(coreparams.dev_name, 
                              Seq("mitll," + coreparams.dev_name)).reg("mem"),
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
  lazy val module = new coreTLModuleImp(coreparams, this)    

}
//--------------------------------------------------------------------------------------
// END: TileLink Module
//--------------------------------------------------------------------------------------



//--------------------------------------------------------------------------------------
// BEGIN: TileLink Module Implementation
//--------------------------------------------------------------------------------------
class coreTLModuleImp(coreparams: COREParams, outer: coreTLModule) extends LazyModuleImp(outer) {

  // "Connect" to Slave Node's signals and parameters
  val (slave, slaveEdge)    = outer.slave_node.in(0)

  // Ensure unused channels are tied off
  slave.b.valid   := false.B
  slave.c.ready   := true.B
  slave.e.ready   := true.B

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
  scratchpad_wrapper_inst.suggestName(scratchpad_wrapper_inst.desiredName+"_inst")

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

