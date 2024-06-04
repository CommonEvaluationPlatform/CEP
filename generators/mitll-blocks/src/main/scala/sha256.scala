//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : sha256.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : TileLink interface to the verilog SHA256 core
//
//--------------------------------------------------------------------------------------
package mitllBlocks.sha256

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
case object PeripherySHA256Key extends Field[Seq[COREParams]](Nil)

// This trait "connects" the core to the Rocket Chip and passes the parameters down
// to the instantiation
trait CanHavePeripherySHA256 { this: BaseSubsystem =>
  val sha256node = p(PeripherySHA256Key).map { params =>

    // Pull in the rocket-chip bus references
    val pbus = locateTLBusWrapper(PBUS)
    val mbus = locateTLBusWrapper(MBUS)
    val fbus = locateTLBusWrapper(FBUS)

    // Map the core parameters
    val coreparams : COREParams = params

    // Initialize the attachment parameters
    val coreattachparams = COREAttachParams(
      slave_bus   = pbus,
      llki_bus    = Some(pbus)
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

      // Perform the slave "attachments" to the llki bus
      coreattachparams.llki_bus.get.coupleTo(coreparams.dev_name + "_llki_slave") {
        module.llki_node :*= 
        TLSourceShrinker(16) :*=
        TLFragmenter(coreattachparams.llki_bus.get) :*=_
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
  // The OpenTitan-based Tilelink interfaces support 4 beatbytes only
  val llki_node = TLManagerNode(Seq(TLSlavePortParameters.v1(
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
  lazy val module = new coreTLModuleImp(coreparams, this)

}
//--------------------------------------------------------------------------------------
// END: TileLink Module
//--------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
// BEGIN: TileLink Module Implementation
//--------------------------------------------------------------------------------------
class coreTLModuleImp(coreparams: COREParams, outer: coreTLModule) extends LazyModuleImp(outer) {

  // "Connect" to llki node's signals and parameters
  val (llki, llkiEdge)    = outer.llki_node.in(0)
  
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

  // Instantiate the blackbox
  val sha256_inst   = Module(new sha256_mock_tss())
  sha256_inst.suggestName(sha256_inst.desiredName+"_inst")

  // Map the LLKI discrete blackbox IO between the core_inst and llki_pp_inst
  sha256_inst.io.llkid_key_data       := llki_pp_inst.io.llkid_key_data
  sha256_inst.io.llkid_key_valid      := llki_pp_inst.io.llkid_key_valid
  llki_pp_inst.io.llkid_key_ready     := sha256_inst.io.llkid_key_ready
  llki_pp_inst.io.llkid_key_complete  := sha256_inst.io.llkid_key_complete
  sha256_inst.io.llkid_clear_key      := llki_pp_inst.io.llkid_clear_key
  llki_pp_inst.io.llkid_clear_key_ack := sha256_inst.io.llkid_clear_key_ack

  // Macro definition for creating rising edge detectors
  def rising_edge(x: Bool)    = x && !RegNext(x)

  // Define registers and wires associated with the Core I/O
  val next                   = RegInit(false.B)
  val init                   = RegInit(false.B)
  val block0                 = RegInit(0.U(64.W))
  val block1                 = RegInit(0.U(64.W))
  val block2                 = RegInit(0.U(64.W))
  val block3                 = RegInit(0.U(64.W))
  val block4                 = RegInit(0.U(64.W))
  val block5                 = RegInit(0.U(64.W))
  val block6                 = RegInit(0.U(64.W))
  val block7                 = RegInit(0.U(64.W))
  val digest_valid           = Wire(Bool())
  val digest                 = Wire(UInt(256.W))
  val ready                  = Wire(Bool())

  // Connect the Core I/O
  sha256_inst.io.clk             := clock
  sha256_inst.io.rst             := reset
  sha256_inst.io.init            := rising_edge(init)
  sha256_inst.io.next            := rising_edge(next)
  sha256_inst.io.block           := Cat(block0, block1, 
                                        block2, block3, 
                                        block4, block5, 
                                        block6, block7)
  digest                         := sha256_inst.io.digest
  digest_valid                   := sha256_inst.io.digest_valid
  ready                          := sha256_inst.io.ready

  // Define the register map
  // Registers with .r suffix to RegField are Read Only (otherwise, Chisel will assume they are R/W)
  outer.slave_node.regmap (
      SHA256Addresses.sha256_ctrlstatus_addr ->RegFieldGroup("sha256_ready", Some("sha256_ready_Register"),Seq(RegField.r(1,  ready),
                                                                                                               RegField  (1,  init),
                                                                                                               RegField  (1,  next))),
      SHA256Addresses.sha256_block_w0 -> RegFieldGroup("sha256_0", Some("sha256_msg_input_word_0"),        Seq(RegField  (64, block0))),
      SHA256Addresses.sha256_block_w1 -> RegFieldGroup("sha256_1", Some("sha256_msg_input_word_1"),        Seq(RegField  (64, block1))),
      SHA256Addresses.sha256_block_w2 -> RegFieldGroup("sha256_2", Some("sha256_msg_input_word_2"),        Seq(RegField  (64, block2))),
      SHA256Addresses.sha256_block_w3 -> RegFieldGroup("sha256_3", Some("sha256_msg_input_word_3"),        Seq(RegField  (64, block3))),
      SHA256Addresses.sha256_block_w4 -> RegFieldGroup("sha256_4", Some("sha256_msg_input_word_4"),        Seq(RegField  (64, block4))),
      SHA256Addresses.sha256_block_w5 -> RegFieldGroup("sha256_5", Some("sha256_msg_input_word_5"),        Seq(RegField  (64, block5))),
      SHA256Addresses.sha256_block_w6 -> RegFieldGroup("sha256_6", Some("sha256_msg_input_word_6"),        Seq(RegField  (64, block6))),
      SHA256Addresses.sha256_block_w7 -> RegFieldGroup("sha256_7", Some("sha256_msg_input_word_7"),        Seq(RegField  (64, block7))),
      SHA256Addresses.sha256_done     -> RegFieldGroup("sha256_done", Some("sha256_done"),                 Seq(RegField.r(1,  digest_valid))),
      SHA256Addresses.sha256_digest_w0 -> RegFieldGroup("sha256_msg_output0", Some("sha256_msg_output0"),  Seq(RegField.r(64, digest(255,192)))),
      SHA256Addresses.sha256_digest_w1 -> RegFieldGroup("sha256_msg_output1", Some("sha256_msg_output1"),  Seq(RegField.r(64, digest(191,128)))),
      SHA256Addresses.sha256_digest_w2 -> RegFieldGroup("sha256_msg_output2", Some("sha256_msg_output2"),  Seq(RegField.r(64, digest(127, 64)))),
      SHA256Addresses.sha256_digest_w3 -> RegFieldGroup("sha256_msg_output3", Some("sha256_msg_output3"),  Seq(RegField.r(64, digest( 63,  0))))               
  )  // regmap

}
//--------------------------------------------------------------------------------------
// END: TileLink Module Implementation
//--------------------------------------------------------------------------------------
