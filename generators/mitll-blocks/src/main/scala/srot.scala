//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : srot.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : TileLink interface to the Surrogate Root of Trust (SRoT)
//                The Surrogate Root of Trust serves as a slave on the periphery
//                bus AND a master on the Front Bus
//
//--------------------------------------------------------------------------------------
package mitllBlocks.srot

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
// BEGIN: SRoT "Periphery" connections
//--------------------------------------------------------------------------------------
// Parameters associated with the SROT
case object SROTKey extends Field[Seq[SROTParams]](Nil)

// This trait "connects" the SRoT to the Rocket Chip and passes the parameters down
// to the instantiation
trait CanHaveSROT { this: BaseSubsystem =>
  val SROTNodes = p(SROTKey).map { params =>

    // Pull in the rocket-chip bus references
    val pbus = locateTLBusWrapper(PBUS)
    val mbus = locateTLBusWrapper(MBUS)
    val fbus = locateTLBusWrapper(FBUS)

    // Map the core parameters
    val coreparams : SROTParams = params

    // Initialize the attachment parameters
    val coreattachparams = COREAttachParams(
      slave_bus   = pbus,
      master_bus  = Some(fbus)
    )

    // Generate (and name) the clock domain for this module
    val coreDomain = coreattachparams.slave_bus.generateSynchronousDomain(coreparams.dev_name + "_").suggestName(coreparams.dev_name+"_ClockSinkDomain_inst")

    // Instantiate the TL Module
    val module = coreDomain { LazyModule(new coreTLModule(coreparams, coreattachparams)(p)).suggestName(coreparams.dev_name+"_module_inst")}

    // Define the Tilelink module 
    coreDomain {

      // Perform the slave "attachments" to the periphery bus
      coreattachparams.slave_bus.coupleTo("srot_slave") {
        module.slave_node :*= 
        TLSourceShrinker(16) :*=
        TLFragmenter(coreattachparams.slave_bus) :*=_
      }

      // Perform the master "attachments" to the front bus
      // TLFilter explicitly added to limite the master node to 32-bits of addressing
      coreattachparams.master_bus.get.coupleFrom("srot_master") {
        _ := 
        TLFilter(TLFilter.mSelectIntersect(AddressSet(
          0x00000000L, 0xFFFFFFFFL))) :=
        module.master_node  
      }
    } // coreDomain

}}

//--------------------------------------------------------------------------------------
// END: SRoT "Periphery" connections
//--------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
// BEGIN: Tilelink SROT Module and Module Implementation Declerations
//
// Note: If one does not explicitly put "supportsPutFull" and/or "supportsPullPartial"
//   in the slave parameters, the manager will be instantiated as Read Only (and will
//   show up as such in the device tree.  Also, the chisel optimization that gets
//   "kicked off" because of the inclusion of diplomacy widgets will result in the A
//   channel data bus being tied to ZERO.
//--------------------------------------------------------------------------------------
class coreTLModule(coreparams: SROTParams, coreattachparams: COREAttachParams)(implicit p: Parameters) extends LazyModule {
  override lazy val desiredName = coreparams.dev_name + "_module"

  // Create a Manager / Slave / Sink node
  val slave_node = TLManagerNode(Seq(TLSlavePortParameters.v1(
    Seq(TLSlaveParameters.v1(
      address             = Seq(AddressSet(
                              coreparams.slave_base_addr, 
                              coreparams.slave_depth)),
      resources           = new SimpleDevice("srot-slave", Seq("mitll,srot-slave")).reg,
      regionType          = RegionType.IDEMPOTENT,
      supportsGet         = TransferSizes(1, 8),
      supportsPutFull     = TransferSizes(1, 8),
      supportsPutPartial  = TransferSizes.none,
      supportsArithmetic  = TransferSizes.none,
      supportsLogical     = TransferSizes.none,
      fifoId              = Some(0))), // requests are handled in order
    beatBytes = coreattachparams.slave_bus.beatBytes)))

    // Create a Client / Master / Source node
    // The sourceID paramater assumes there are two masters on the fbus (Debug Module, SRoT)
    // This client node is "constained" to only talk to the CEP cores (via the visibility
    // parameter)
    val master_node = TLClientNode(Seq(TLMasterPortParameters.v1(
      Seq(TLMasterParameters.v1(
        name              = "srot_master0",
        sourceId          = IdRange(0, 15), 
        requestFifo       = true,
        visibility        = Seq(AddressSet(
          coreparams.cep_cores_base_addr,
          coreparams.cep_cores_depth))
      ))
    )))
    
    // Instantiate the implementation
    lazy val module = new coreTLModuleImp(coreparams, this)

} // end TLSROTModule
 
class coreTLModuleImp(coreparams: SROTParams, outer: coreTLModule) extends LazyModuleImp(outer) {

  // "Connect" to Slave Node's signals and parameters
  val (slave, slaveEdge)    = outer.slave_node.in(0)

  // Ensure unused channels are tied off
  slave.b.valid   := false.B
  slave.c.ready   := true.B
  slave.e.ready   := true.B

  // "Connect" to Master Node's signals and parameters
  val (master, masterEdge)  = outer.master_node.out(0)

  // Pack core index array
  val core_index_array_packed = coreparams.llki_cores_array.foldLeft(BigInt(0)) { 
    (packed, addr) => ((packed << 32) | addr)  }
  val num_cores = coreparams.llki_cores_array.length

  // Instantiate the srot_wrapper
  val srot_wrapper_inst = Module(new srot_wrapper(
    slave_tl_szw                    = slaveEdge.bundle.sizeBits,
    slave_tl_aiw                    = slaveEdge.bundle.sourceBits,
    slave_tl_aw                     = slaveEdge.bundle.addressBits,
    slave_tl_dbw                    = slaveEdge.bundle.dataBits / 8,
    slave_tl_dw                     = slaveEdge.bundle.dataBits,
    slave_tl_diw                    = slaveEdge.bundle.sinkBits,
    master_tl_szw                   = masterEdge.bundle.sizeBits,
    master_tl_aiw                   = masterEdge.bundle.sourceBits,
    master_tl_aw                    = masterEdge.bundle.addressBits,
    master_tl_dbw                   = masterEdge.bundle.dataBits / 8,
    master_tl_dw                    = masterEdge.bundle.dataBits,
    master_tl_diw                   = masterEdge.bundle.sinkBits,
    num_cores                       = num_cores,
    core_index_array_packed         = core_index_array_packed
  ))
  srot_wrapper_inst.suggestName(srot_wrapper_inst.desiredName+"_inst")

  // Connect the Clock and Reset
  srot_wrapper_inst.io.clk                := clock
  srot_wrapper_inst.io.rst                := reset.asBool

  // Connect the Slave A Channel to the Black box IO
  srot_wrapper_inst.io.slave_a_opcode     := slave.a.bits.opcode    
  srot_wrapper_inst.io.slave_a_param      := slave.a.bits.param     
  srot_wrapper_inst.io.slave_a_size       := slave.a.bits.size
  srot_wrapper_inst.io.slave_a_source     := slave.a.bits.source    
  srot_wrapper_inst.io.slave_a_address    := slave.a.bits.address
  srot_wrapper_inst.io.slave_a_mask       := slave.a.bits.mask      
  srot_wrapper_inst.io.slave_a_data       := slave.a.bits.data      
  srot_wrapper_inst.io.slave_a_corrupt    := slave.a.bits.corrupt   
  srot_wrapper_inst.io.slave_a_valid      := slave.a.valid          
  slave.a.ready                           := srot_wrapper_inst.io.slave_a_ready  

  // Connect the Slave D Channel to the Black Box IO    
  slave.d.bits.opcode                     := srot_wrapper_inst.io.slave_d_opcode
  slave.d.bits.param                      := srot_wrapper_inst.io.slave_d_param
  slave.d.bits.size                       := srot_wrapper_inst.io.slave_d_size
  slave.d.bits.source                     := srot_wrapper_inst.io.slave_d_source
  slave.d.bits.sink                       := srot_wrapper_inst.io.slave_d_sink
  slave.d.bits.denied                     := srot_wrapper_inst.io.slave_d_denied
  slave.d.bits.data                       := srot_wrapper_inst.io.slave_d_data
  slave.d.bits.corrupt                    := srot_wrapper_inst.io.slave_d_corrupt
  slave.d.valid                           := srot_wrapper_inst.io.slave_d_valid
  srot_wrapper_inst.io.slave_d_ready      := slave.d.ready

  // Connect the Master A channel to the Black Box IO
  master.a.bits.opcode                    := srot_wrapper_inst.io.master_a_opcode
  master.a.bits.param                     := srot_wrapper_inst.io.master_a_param
  master.a.bits.size                      := srot_wrapper_inst.io.master_a_size
  master.a.bits.source                    := srot_wrapper_inst.io.master_a_source
  master.a.bits.address                   := srot_wrapper_inst.io.master_a_address
  master.a.bits.mask                      := srot_wrapper_inst.io.master_a_mask
  master.a.bits.data                      := srot_wrapper_inst.io.master_a_data
  master.a.bits.corrupt                   := srot_wrapper_inst.io.master_a_corrupt
  master.a.valid                          := srot_wrapper_inst.io.master_a_valid
  srot_wrapper_inst.io.master_a_ready     := master.a.ready  

  // Connect the Master D channel to the Black Box IO
  srot_wrapper_inst.io.master_d_opcode    := master.d.bits.opcode
  srot_wrapper_inst.io.master_d_param     := master.d.bits.param
  srot_wrapper_inst.io.master_d_size      := master.d.bits.size
  srot_wrapper_inst.io.master_d_source    := master.d.bits.source
  srot_wrapper_inst.io.master_d_sink      := master.d.bits.sink
  srot_wrapper_inst.io.master_d_denied    := master.d.bits.denied
  srot_wrapper_inst.io.master_d_data      := master.d.bits.data
  srot_wrapper_inst.io.master_d_corrupt   := master.d.bits.corrupt
  srot_wrapper_inst.io.master_d_valid     := master.d.valid
  master.d.ready                          := srot_wrapper_inst.io.master_d_ready

} // end TLSROTModuleImp
//--------------------------------------------------------------------------------------
// END: Tilelink SROT Module and Module Implementation Declerations
//--------------------------------------------------------------------------------------

