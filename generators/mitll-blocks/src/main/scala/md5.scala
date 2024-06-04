//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : md5.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : TileLink interface to the verilog MD5 core
//
//--------------------------------------------------------------------------------------
package mitllBlocks.md5

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
case object PeripheryMD5Key extends Field[Seq[COREParams]](Nil)

// This trait "connects" the core to the Rocket Chip and passes the parameters down
// to the instantiation
trait CanHavePeripheryMD5 { this: BaseSubsystem =>
  val md5node = p(PeripheryMD5Key).map { params =>

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

    // Generate the clock domain for this module
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
  val md5_inst   = Module(new md5_mock_tss())
  md5_inst.suggestName(md5_inst.desiredName+"_inst")

  // Map the LLKI discrete blackbox IO between the core_inst and llki_pp_inst
  md5_inst.io.llkid_key_data          := llki_pp_inst.io.llkid_key_data
  md5_inst.io.llkid_key_valid         := llki_pp_inst.io.llkid_key_valid
  llki_pp_inst.io.llkid_key_ready     := md5_inst.io.llkid_key_ready
  llki_pp_inst.io.llkid_key_complete  := md5_inst.io.llkid_key_complete
  md5_inst.io.llkid_clear_key         := llki_pp_inst.io.llkid_clear_key
  llki_pp_inst.io.llkid_clear_key_ack := md5_inst.io.llkid_clear_key_ack

  val init                   = RegInit(false.B)
  val rst                    = RegInit(false.B)
  val msg_in_valid           = RegInit(false.B)
  val msg_padded_w0          = RegInit(0.U(64.W))
  val msg_padded_w1          = RegInit(0.U(64.W))
  val msg_padded_w2          = RegInit(0.U(64.W))
  val msg_padded_w3          = RegInit(0.U(64.W))
  val msg_padded_w4          = RegInit(0.U(64.W))
  val msg_padded_w5          = RegInit(0.U(64.W))
  val msg_padded_w6          = RegInit(0.U(64.W))
  val msg_padded_w7          = RegInit(0.U(64.W))
  val msg_output             = Wire(UInt(256.W))
  val msg_out_valid          = Wire(Bool())
  val ready                  = Wire(Bool())

  md5_inst.io.clk            := clock
  md5_inst.io.rst            := (reset.asBool || rst).asAsyncReset
  md5_inst.io.init           := init
  md5_inst.io.msg_in_valid   := msg_in_valid
  md5_inst.io.msg_padded     := Cat(msg_padded_w0, msg_padded_w1,
                                    msg_padded_w2, msg_padded_w3,
                                    msg_padded_w4, msg_padded_w5, 
                                    msg_padded_w6, msg_padded_w7)
  msg_output                 := md5_inst.io.msg_output
  msg_out_valid              := md5_inst.io.msg_out_valid
  ready                      := md5_inst.io.ready

  // Define the register map
  // Registers with .r suffix to RegField are Read Only (otherwise, Chisel will assume they are R/W)
  outer.slave_node.regmap (
      MD5Addresses.md5_ready         -> RegFieldGroup("md5_ready", Some("md5_ready_register"),    Seq(RegField.r(1,  ready           ))),
      MD5Addresses.md5_msg_padded_w0 -> RegFieldGroup("md5_in0", Some("md5_msg_input_word_0"),    Seq(RegField  (64, msg_padded_w0))),
      MD5Addresses.md5_msg_padded_w1 -> RegFieldGroup("md5_in1", Some("md5_msg_input_word_1"),    Seq(RegField  (64, msg_padded_w1))),
      MD5Addresses.md5_msg_padded_w2 -> RegFieldGroup("md5_in2", Some("md5_msg_input_word_2"),    Seq(RegField  (64, msg_padded_w2))),
      MD5Addresses.md5_msg_padded_w3 -> RegFieldGroup("md5_in3", Some("md5_msg_input_word_3"),    Seq(RegField  (64, msg_padded_w3))),
      MD5Addresses.md5_msg_padded_w4 -> RegFieldGroup("md5_in4", Some("md5_msg_input_word_4"),    Seq(RegField  (64, msg_padded_w4))),
      MD5Addresses.md5_msg_padded_w5 -> RegFieldGroup("md5_in5", Some("md5_msg_input_word_5"),    Seq(RegField  (64, msg_padded_w5))),
      MD5Addresses.md5_msg_padded_w6 -> RegFieldGroup("md5_in6", Some("md5_msg_input_word_6"),    Seq(RegField  (64, msg_padded_w6))),
      MD5Addresses.md5_msg_padded_w7 -> RegFieldGroup("md5_in7", Some("md5_msg_input_word_7"),    Seq(RegField  (64, msg_padded_w7))),
      MD5Addresses.md5_msg_output_w0 -> RegFieldGroup("md5_msg_output0", Some("md5_msg_output1"), Seq(RegField.r(64, msg_output(127,64)))),
      MD5Addresses.md5_msg_output_w1 -> RegFieldGroup("md5_msg_output1", Some("md5_msg_output1"), Seq(RegField.r(64, msg_output(63,0)))),
      MD5Addresses.md5_in_valid      -> RegFieldGroup("md5_msg_in_valid", Some("md5_in_valid"),   Seq(RegField  (1,  msg_in_valid))),
      MD5Addresses.md5_out_valid     -> RegFieldGroup("md5_msg_out_valid", Some("md5_out_valid"), Seq(RegField.r(1,  msg_out_valid))),
      MD5Addresses.md5_rst           -> RegFieldGroup("message_rst", Some("message_rst"),         Seq(RegField  (1, rst),
                                                                                                      RegField  (1, init)))
  )  // regmap

}
//--------------------------------------------------------------------------------------
// END: TileLink Module Implementation
//--------------------------------------------------------------------------------------
