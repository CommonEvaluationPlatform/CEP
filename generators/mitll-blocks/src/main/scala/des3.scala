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

  // Define blackbox and its associated IO (with LLKI)
  class des3_mock_tss() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())

      // Inputs
      val start               = Input(Bool())
      val decrypt             = Input(Bool())
      val key1                = Input(UInt(56.W))
      val key2                = Input(UInt(56.W))
      val key3                = Input(UInt(56.W))
      val desIn               = Input(UInt(64.W))

      // Outputs
      val desOut              = Output(UInt(64.W))
      val out_valid           = Output(Bool())

      // LLKI discrete interface
      val llkid_key_data      = Input(UInt(64.W))
      val llkid_key_valid     = Input(Bool())
      val llkid_key_ready     = Output(Bool())
      val llkid_key_complete  = Output(Bool())
      val llkid_clear_key     = Input(Bool())
      val llkid_clear_key_ack = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/des3/des3_mock_tss.sv")
    addResource("/vsrc/des3/des3.v")
    addResource("/vsrc/des3/key_sel3.v")
    addResource("/vsrc/des3/crp.v")
    addResource("/vsrc/des3/sbox1.v")
    addResource("/vsrc/des3/sbox2.v")
    addResource("/vsrc/des3/sbox3.v")
    addResource("/vsrc/des3/sbox4.v")
    addResource("/vsrc/des3/sbox5.v")
    addResource("/vsrc/des3/sbox6.v")
    addResource("/vsrc/des3/sbox7.v")
    addResource("/vsrc/des3/sbox8.v")

  }

  // Define blackbox and its associated IO (without LLKI)
  class des3() extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())

      // Inputs
      val start               = Input(Bool())
      val decrypt             = Input(Bool())
      val key1                = Input(UInt(56.W))
      val key2                = Input(UInt(56.W))
      val key3                = Input(UInt(56.W))
      val desIn               = Input(UInt(64.W))

      // Outputs
      val desOut              = Output(UInt(64.W))
      val out_valid           = Output(Bool())

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/des3/des3.v")
    addResource("/vsrc/des3/key_sel3.v")
    addResource("/vsrc/des3/crp.v")
    addResource("/vsrc/des3/sbox1.v")
    addResource("/vsrc/des3/sbox2.v")
    addResource("/vsrc/des3/sbox3.v")
    addResource("/vsrc/des3/sbox4.v")
    addResource("/vsrc/des3/sbox5.v")
    addResource("/vsrc/des3/sbox6.v")
    addResource("/vsrc/des3/sbox7.v")
    addResource("/vsrc/des3/sbox8.v")

  }

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

    // Define the LLKI Protocol Processing blackbox and its associated IO
    class llki_pp_wrapper(  llki_ctrlsts_addr     : BigInt, 
                            llki_sendrecv_addr    : BigInt,
                            slave_tl_szw          : Int,
                            slave_tl_aiw          : Int,
                            slave_tl_aw           : Int,
                            slave_tl_dbw          : Int,
                            slave_tl_dw           : Int,
                            slave_tl_diw          : Int) extends BlackBox (

        Map(
          "CTRLSTS_ADDR"    -> IntParam(llki_ctrlsts_addr),   // Address of the LLKI PP Control/Status Register
          "SENDRECV_ADDR"   -> IntParam(llki_sendrecv_addr),  // Address of the LLKI PP Message Send/Receive interface
          "SLAVE_TL_SZW"    -> IntParam(slave_tl_szw),
          "SLAVE_TL_AIW"    -> IntParam(slave_tl_aiw),
          "SLAVE_TL_AW"     -> IntParam(slave_tl_aw),
          "SLAVE_TL_DBW"    -> IntParam(slave_tl_dbw),
          "SLAVE_TL_DW"     -> IntParam(slave_tl_dw),
          "SLAVE_TL_DIW"    -> IntParam(slave_tl_diw)
        )
    ) {

      val io = IO(new Bundle {

        // Clock and Reset
        val clk                 = Input(Clock())
        val rst                 = Input(Reset())

        // Slave - Tilelink A Channel (Signal order/names from Tilelink Specification v1.8.0)
        val slave_a_opcode      = Input(UInt(3.W))
        val slave_a_param       = Input(UInt(3.W))
        val slave_a_size        = Input(UInt(slave_tl_szw.W))
        val slave_a_source      = Input(UInt(slave_tl_aiw.W))
        val slave_a_address     = Input(UInt(slave_tl_aw.W))
        val slave_a_mask        = Input(UInt(slave_tl_dbw.W))
        val slave_a_data        = Input(UInt(slave_tl_dw.W))
        val slave_a_corrupt     = Input(Bool())
        val slave_a_valid       = Input(Bool())
        val slave_a_ready       = Output(Bool())

        // Slave - Tilelink D Channel (Signal order/names from Tilelink Specification v1.8.0)
        val slave_d_opcode      = Output(UInt(3.W))
        val slave_d_param       = Output(UInt(3.W))
        val slave_d_size        = Output(UInt(slave_tl_szw.W))
        val slave_d_source      = Output(UInt(slave_tl_aiw.W))
        val slave_d_sink        = Output(UInt(slave_tl_diw.W))
        val slave_d_denied      = Output(Bool())
        val slave_d_data        = Output(UInt(slave_tl_dw.W))
        val slave_d_corrupt     = Output(Bool())
        val slave_d_valid       = Output(Bool())
        val slave_d_ready       = Input(Bool())

        // LLKI discrete interface
        val llkid_key_data      = Output(UInt(64.W))
        val llkid_key_valid     = Output(Bool())
        val llkid_key_ready     = Input(Bool())
        val llkid_key_complete  = Input(Bool())
        val llkid_clear_key     = Output(Bool())
        val llkid_clear_key_ack = Input(Bool())

      })
    } // end class llki_pp_wrapper

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
    val impl = Module(new des3_mock_tss())
    impl.suggestName(impl.desiredName+"_inst")

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


