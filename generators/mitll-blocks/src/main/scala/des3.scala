//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : des3.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : TileLink interface to the verilog des3 core
//
//--------------------------------------------------------------------------------------
package mitllBlocks.des3

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

// Parameters associated with the core
case object PeripheryDES3Key extends Field[Seq[COREParams]](Nil)

// This trait "connects" the core to the Rocket Chip and passes the parameters down
// to the instantiation IF the parameters have been initialized
trait CanHavePeripheryDES3 { this: BaseSubsystem =>
  val des3node = p(PeripheryDES3Key).map { params =>

    // Pull in the rocket-chip bus references
    val pbus = locateTLBusWrapper(PBUS)
    val mbus = locateTLBusWrapper(MBUS)
    val fbus = locateTLBusWrapper(FBUS)

    // Map the core parameters
    val coreparams : COREParams = params

    // Initialize the attachment parameters (depending if the LLKI base address is non-zero)
    val coreattachparams = if (coreparams.llki_base_addr > 0) {
      val params = COREAttachParams(
        slave_bus   = pbus,
        llki_bus    = Some(pbus)
      )
      params
    } else {
      val params = COREAttachParams(
        slave_bus   = pbus
      )
      params
    }

    // Generate (and name) the clock domain for this module
    val coreDomain = coreattachparams.slave_bus.generateSynchronousDomain(coreparams.dev_name + "_").suggestName(coreparams.dev_name+"_ClockSinkDomain_inst")

    // Instantiate the TL Module
    val module = coreDomain { LazyModule(new coreTLModule(coreparams, coreattachparams)(p)).suggestName(coreparams.dev_name+"_module_inst")}

    // Define the Tilelink Connections to the module
    coreDomain {

      // Perform the slave "attachments" to the slave bus
      coreattachparams.slave_bus.coupleTo(coreparams.dev_name + "_slave") {
        module.slave_node :*=
        TLFragmenter(coreattachparams.slave_bus) :*= _
      }

      // Attach the LLKI if it is defined
      if (coreattachparams.llki_bus.isDefined) {
        coreattachparams.llki_bus.get.coupleTo(coreparams.dev_name + "_llki_slave") {
          module.llki_node.get :*= 
          TLSourceShrinker(16) :*=
          TLFragmenter(coreattachparams.llki_bus.get) :*=_
        }
      } // if (coreattachparams.llki_bus.isDefined)
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
  // The OpenTitan-based Tilelink interfaces support 4 beatbytes only
  val llki_node = coreattachparams.llki_bus.map (_ =>  
    TLManagerNode(Seq(TLSlavePortParameters.v1(
      Seq(TLSlaveParameters.v1(
      address             = Seq(AddressSet(
                              coreparams.llki_base_addr, 
                              coreparams.llki_depth)),
      resources           = new SimpleDevice(coreparams.dev_name + "-llki-slave", 
                              Seq("mitll," + coreparams.dev_name + "-llki-slave")).reg,
      regionType          = RegionType.IDEMPOTENT,
      supportsGet         = TransferSizes(1, 8),
      supportsPutFull     = TransferSizes(1, 8),
      supportsPutPartial  = TransferSizes.none,
      supportsArithmetic  = TransferSizes.none,
      supportsLogical     = TransferSizes.none,
      fifoId              = Some(0))), // requests are handled in order
    beatBytes = coreattachparams.llki_bus.get.beatBytes)))
  )

  // Create the RegisterRouter node
  val slave_node = TLRegisterNode(
    address     = Seq(AddressSet(
                    coreparams.slave_base_addr, 
                    coreparams.slave_depth)),
    device      = new SimpleDevice(coreparams.dev_name + "-slave", 
                    Seq("mitll," + coreparams.dev_name + "-slave")),
    beatBytes   = coreattachparams.slave_bus.beatBytes
  )

  // Instantiate the implementation
  lazy val module = new coreTLModuleImp(coreparams, coreattachparams, this)

}
//--------------------------------------------------------------------------------------
// END: TileLink Module
//--------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
// BEGIN: TileLink Module Implementation
//--------------------------------------------------------------------------------------
class coreTLModuleImp(coreparams: COREParams, coreattachparams: COREAttachParams, outer: coreTLModule) extends LazyModuleImp(outer) {

  // Instantiate registers for the blackbox inputs
  val start                   = RegInit(0.U(1.W))
  val decrypt                 = RegInit(0.U(1.W))
  val key1                    = RegInit(0.U(56.W))
  val key2                    = RegInit(0.U(56.W))
  val key3                    = RegInit(0.U(56.W))  
  val desIn                   = RegInit(0.U(64.W))

  // Instantiate wires for the blackbox outputs
  val desOut                  = Wire(UInt(64.W))
  val out_valid               = Wire(Bool())


  // "Connect" to llki node's signals and parameters (if the LLKI is defined)
  if (coreattachparams.llki_bus.isDefined) {
    val (llki, llkiEdge)    = outer.llki_node.get.in(0)

    // Instantiate the DES3 Mock TSS
    val impl = Module(new des3_mock_tss())
    impl.suggestName(impl.desiredName+"_inst")

    // Instantiate the LLKI Protocol Processing Block with CORE SPECIFIC decode constants
    val llki_pp_inst = Module(new llki_pp_wrapper(
      coreparams.llki_ctrlsts_addr, 
      coreparams.llki_sendrecv_addr,
      llkiEdge.bundle.sizeBits,
      llkiEdge.bundle.sourceBits,
      llkiEdge.bundle.addressBits,
      llkiEdge.bundle.dataBits / 8,
      llkiEdge.bundle.dataBits,
      llkiEdge.bundle.sinkBits
    ))

    // Connect the Clock and Reset
    llki_pp_inst.io.clk                 := clock
    llki_pp_inst.io.rst                 := reset

    // Connect the Slave A Channel to the Black box IO
    llki_pp_inst.io.slave_a_opcode      := llki.a.bits.opcode
    llki_pp_inst.io.slave_a_param       := llki.a.bits.param
    llki_pp_inst.io.slave_a_size        := llki.a.bits.size
    llki_pp_inst.io.slave_a_source      := llki.a.bits.source
    llki_pp_inst.io.slave_a_address     := llki.a.bits.address
    llki_pp_inst.io.slave_a_mask        := llki.a.bits.mask
    llki_pp_inst.io.slave_a_data        := llki.a.bits.data
    llki_pp_inst.io.slave_a_corrupt     := llki.a.bits.corrupt
    llki_pp_inst.io.slave_a_valid       := llki.a.valid
    llki.a.ready                        := llki_pp_inst.io.slave_a_ready  

    // Connect the Slave D Channel to the Black Box IO    
    llki.d.bits.opcode                  := llki_pp_inst.io.slave_d_opcode
    llki.d.bits.param                   := llki_pp_inst.io.slave_d_param
    llki.d.bits.size                    := llki_pp_inst.io.slave_d_size
    llki.d.bits.source                  := llki_pp_inst.io.slave_d_source
    llki.d.bits.sink                    := llki_pp_inst.io.slave_d_sink
    llki.d.bits.denied                  := llki_pp_inst.io.slave_d_denied
    llki.d.bits.data                    := llki_pp_inst.io.slave_d_data
    llki.d.bits.corrupt                 := llki_pp_inst.io.slave_d_corrupt
    llki.d.valid                        := llki_pp_inst.io.slave_d_valid
    llki_pp_inst.io.slave_d_ready       := llki.d.ready

    impl.io.llkid_key_data              := llki_pp_inst.io.llkid_key_data
    impl.io.llkid_key_valid             := llki_pp_inst.io.llkid_key_valid
    llki_pp_inst.io.llkid_key_ready     := impl.io.llkid_key_ready
    llki_pp_inst.io.llkid_key_complete  := impl.io.llkid_key_complete
    impl.io.llkid_clear_key             := llki_pp_inst.io.llkid_clear_key
    llki_pp_inst.io.llkid_clear_key_ack := impl.io.llkid_clear_key_ack

    // Map the blackbox I/O 
    impl.io.clk                         := clock
    impl.io.rst                         := reset
    impl.io.start                       := start
    impl.io.decrypt                     := decrypt
    impl.io.desIn                       := desIn
    impl.io.key1                        := key1
    impl.io.key2                        := key2
    impl.io.key3                        := key3
    desOut                              := impl.io.desOut
    out_valid                           := impl.io.out_valid

  } else { // else if (coreattachparams.llki_bus.isDefined)
  
    // Instantiate the DES3 Mock TSS
    val impl = Module(new des3())
    impl.suggestName(impl.desiredName+"_inst")

    // Map the blackbox I/O 
    impl.io.clk                         := clock
    impl.io.reset                       := reset
    impl.io.start                       := start
    impl.io.decrypt                     := decrypt
    impl.io.desIn                       := desIn
    impl.io.key1                        := key1
    impl.io.key2                        := key2
    impl.io.key3                        := key3
    desOut                              := impl.io.desOut
    out_valid                           := impl.io.out_valid

  } // if (coreattachparams.llki_bus.isDefined)

  // Define the register map
  // Registers with .r suffix to RegField are Read Only (otherwise, Chisel will assume they are R/W)
  outer.slave_node.regmap (
    DES3Addresses.des3_ctrlstatus_addr -> RegFieldGroup("des3_ctrlstatus", Some(""), Seq(RegField  ( 1, start, RegFieldDesc("start", "")))),
    DES3Addresses.des3_decrypt_addr    -> RegFieldGroup("des3_decrypt",    Some(""), Seq(RegField  ( 1, decrypt))),
    DES3Addresses.des3_desIn_addr      -> RegFieldGroup("des3_desIn",      Some(""), Seq(RegField  (64, desIn))),
    DES3Addresses.des3_key1_addr       -> RegFieldGroup("des3_key0",       Some(""), Seq(RegField  (56, key1))),
    DES3Addresses.des3_key2_addr       -> RegFieldGroup("des3_key1",       Some(""), Seq(RegField  (56, key2))),
    DES3Addresses.des3_key3_addr       -> RegFieldGroup("des3_key2",       Some(""), Seq(RegField  (56, key3))),                
    DES3Addresses.des3_done            -> RegFieldGroup("des3_done",       Some(""), Seq(RegField.r( 1, out_valid))),
    DES3Addresses.des3_desOut_addr     -> RegFieldGroup("des3_desOut",     Some(""), Seq(RegField.r(64, desOut)))
  )  // regmap

}

//--------------------------------------------------------------------------------------
// END: TileLink Module Implementation
//--------------------------------------------------------------------------------------


