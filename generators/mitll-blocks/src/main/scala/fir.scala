//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : fir.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : TileLink interface to the verilog FIR core
// Note         : The "control" logic described in the FIR abstract class
//                is intended to mimic the verilog in the fir_top_wb.v
//                module.
//
//--------------------------------------------------------------------------------------

package mitllBlocks.fir

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
// BEGIN: Module "Periphery" connections
//--------------------------------------------------------------------------------------

// Parameters associated with the core
case object PeripheryFIRKey extends Field[Seq[COREParams]](Nil)

// This trait "connects" the core to the Rocket Chip and passes the parameters down
// to the instantiation
trait CanHavePeripheryFIR { this: BaseSubsystem =>
  val firnode = p(PeripheryFIRKey).map { params =>

    // Map the core parameters
    val coreparams : COREParams = params

    // Initialize the attachment parameters
    val coreattachparams = COREAttachParams(
      slave_bus   = pbus,
      llki_bus    = Some(pbus)
    )

    // Generate the clock domain for this module
    val coreDomain = coreattachparams.slave_bus.generateSynchronousDomain

    // Define the Tilelink module 
    coreDomain {
      // Instantiate the TL module.  Note: This name shows up in the generated verilog hiearchy
      // and thus should be unique to this core and NOT a verilog reserved keyword
      val module = LazyModule(new coreTLModule(coreparams, coreattachparams)(p)).suggestName(coreparams.dev_name+"module")

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

  // Define blackbox and its associated IO
  class FIR_filter_mock_tss () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
      val rst_dut             = Input(Reset())
   
      // Inputs
      val inData              = Input(UInt(32.W))
    
      // Outputs
      val outData             = Output(UInt(32.W))

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
    addResource("/vsrc/dsp/FIR_filter_mock_tss.sv")
    addResource("/vsrc/dsp/FIR_filter.v")

    // Provide an optional override of the Blackbox module name
    override def desiredName(): String = {
      return coreparams.verilog_module_name.getOrElse(super.desiredName)
    }
  }

  // Instantiate the blackbox
  val FIR_filter_inst   = Module(new FIR_filter_mock_tss())

  // Provide an optional override of the Blackbox module instantiation name
  FIR_filter_inst.suggestName(FIR_filter_inst.desiredName()+"_inst")

  // Map the LLKI discrete blackbox IO between the core_inst and llki_pp_inst
  FIR_filter_inst.io.llkid_key_data    := llki_pp_inst.io.llkid_key_data
  FIR_filter_inst.io.llkid_key_valid   := llki_pp_inst.io.llkid_key_valid
  llki_pp_inst.io.llkid_key_ready      := FIR_filter_inst.io.llkid_key_ready
  llki_pp_inst.io.llkid_key_complete   := FIR_filter_inst.io.llkid_key_complete
  FIR_filter_inst.io.llkid_clear_key   := llki_pp_inst.io.llkid_clear_key
  llki_pp_inst.io.llkid_clear_key_ack  := FIR_filter_inst.io.llkid_clear_key_ack

  // Macro definition for creating rising edge detectors
  def rising_edge(x: Bool)    = x && !RegNext(x)

  // Instantiate the input and output data memories (32 words of input and output data)
  val datain_mem              = Mem(32, UInt(32.W))     // for holding the input data
  val dataout_mem             = Mem(32, UInt(32.W))     // for holding the output data

  // Define registers / wires for interfacing to the FIR blackbox
  val start                   = RegInit(false.B)      // Start bit
//  val fir_reset               = RegInit(false.B)      // Addressable reset
// tony duong 2/23/21: need the core in reset while LLKI is running
  val fir_reset               = RegInit(true.B)      // Addressable reset
  val fir_reset_re            = RegInit(false.B)      // Rising edge detection for addressable reset   
  val datain_we               = RegInit(false.B)      // Controlled via register mappings
  val datain_write_idx        = RegInit(0.U(6.W))     // Controlled via register mappings
  val datain_write_data       = RegInit(0.U(32.W))    // Controlled via register mappings
  val datain_read_idx         = RegInit(0.U(6.W))     // Generated write read address from start bit
  val datain_read_data        = Wire(UInt(32.W))      // Data read from intermediate buffer into FIR_filter.v    

  val dataout_write_idx       = RegInit(0.U(6.W))     // Data output address generated from next_out
  val dataout_write_data      = RegInit(0.U(32.W))    // Data output
  val dataout_read_idx        = RegInit(0.U(6.W))     // Controlled via register mappings
  val dataout_read_data       = Wire(UInt(32.W))      // Controlled via register mappings
  val dataout_valid           = RegInit(false.B)      // Data valid output bit

  val count                   = RegInit(0.U(6.W))     // Count syncs output buffers with filter propagation
  val next_out                = Wire(Bool())          // Bit driven high to designate start of the output sequence

  fir_reset_re                := rising_edge(fir_reset)

  // Write to the input data memory when a rising edge is detected on the write enable
  when (rising_edge(datain_we)) {
    datain_mem.write(datain_write_idx, datain_write_data)
  }

  // Implement the read logic for the datain and data out memories
  datain_read_data            := datain_mem(datain_read_idx)
  dataout_read_data           := dataout_mem(dataout_read_idx)

  // Generate the read index for the data in memory
  when (rising_edge(start)) {
    datain_read_idx         := 0.U
  } .elsewhen (datain_read_idx < 32.U) {
    datain_read_idx         := datain_read_idx + 1.U
  }

  // The following counter "counts" the propagation through the FIR filter
  when (rising_edge(start)) {
    count                   := 0.U
  } .elsewhen (datain_read_idx < 10.U) {
    count                   := count + 1.U
  }

  // Assert next out when the count reaches the appropriate value
  next_out                    := (count === 3.U)

  // Generate the write index for the output data memory (and write)
  when (rising_edge(next_out)) {
    dataout_write_idx       := 0.U;
  } .elsewhen (dataout_write_idx < 32.U) {
    dataout_write_idx       := dataout_write_idx + 1.U
    dataout_mem.write(dataout_write_idx, dataout_write_data)
  }

  // Generate the data valid signal
  when (rising_edge(start)) {
    dataout_valid           := 0.U
  } .elsewhen (rising_edge(next_out)) {
    dataout_valid           := 1.U
  }

  // Map the blackbox I/O
  // The FIR needs to be reset in between test vectors, thus a second reset
  // has been added in order to allow for the LLKI keys to persist
  FIR_filter_inst.io.clk       := clock
  FIR_filter_inst.io.rst       := reset
//  FIR_filter_inst.io.rst_dut   := (reset.asBool || fir_reset_re).asAsyncReset 
  FIR_filter_inst.io.rst_dut   := (reset.asBool || fir_reset).asAsyncReset 
                                                                     
  FIR_filter_inst.io.inData    := Mux(datain_read_idx < 32.U, datain_read_data, 0.U)
  dataout_write_data                    := FIR_filter_inst.io.outData

  // Define the register map
  // Registers with .r suffix to RegField are Read Only (otherwise, Chisel will assume they are R/W)
  outer.slave_node.regmap (
    FIRAddresses.fir_ctrlstatus_addr    -> RegFieldGroup("fir_ctrlstatus",Some(""), Seq(
      RegField    (1, start               ),      // Start passing data to the FIR blackbox
      RegField    (1, datain_we           ),      // Write enable for the datain memory
      RegField.r  (1, dataout_valid       ))),    // Data Out Valid
    FIRAddresses.fir_reset_addr                 -> Seq(RegField     (1,  fir_reset)),
    FIRAddresses.fir_datain_addr_addr   -> Seq(RegField     (5,  datain_write_idx)),
    FIRAddresses.fir_datain_data_addr   -> Seq(RegField     (32, datain_write_data)),
    FIRAddresses.fir_dataout_addr_addr  -> Seq(RegField     (5,  dataout_read_idx)),
    FIRAddresses.fir_dataout_data_addr  -> Seq(RegField.r   (32, dataout_read_data))
  )  // regmap

}
//--------------------------------------------------------------------------------------
// END: TileLink Module Implementation
//--------------------------------------------------------------------------------------

