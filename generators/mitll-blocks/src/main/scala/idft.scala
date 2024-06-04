//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : idft.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : TileLink interface to the verilog idft core
// Note         : The "control" logic described in the idft abstract class
//                is intended to mimic the verilog in the dft_top_wb.v
//                module.
//
//--------------------------------------------------------------------------------------

package mitllBlocks.idft

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
case object PeripheryIDFTKey extends Field[Seq[COREParams]](Nil)

// This trait "connects" the core to the Rocket Chip and passes the parameters down
// to the instantiation
trait CanHavePeripheryIDFT { this: BaseSubsystem =>
  val idftnode = p(PeripheryIDFTKey).map { params =>

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
  class idft_top_mock_tss () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
   
      // Inputs
      val next                = Input(Bool())            
      val X0                  = Input(UInt(16.W))
      val X1                  = Input(UInt(16.W))
      val X2                  = Input(UInt(16.W))
      val X3                  = Input(UInt(16.W))
    
      // Outputs
      val next_out            = Output(Bool())
      val Y0                  = Output(UInt(16.W))
      val Y1                  = Output(UInt(16.W))
      val Y2                  = Output(UInt(16.W))
      val Y3                  = Output(UInt(16.W))

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
    addResource("/vsrc/dsp/idft_top_mock_tss.sv")
    addResource("/vsrc/dsp/idft_top.v")

  }

  // Define blackbox and its associated IO (without LLKI)
  class idft_top () extends BlackBox with HasBlackBoxResource {

    val io = IO(new Bundle {
      // Clock and Reset
      val clk                 = Input(Clock())
      val rst                 = Input(Reset())
   
      // Inputs
      val next                = Input(Bool())            
      val X0                  = Input(UInt(16.W))
      val X1                  = Input(UInt(16.W))
      val X2                  = Input(UInt(16.W))
      val X3                  = Input(UInt(16.W))
    
      // Outputs
      val next_out            = Output(Bool())
      val Y0                  = Output(UInt(16.W))
      val Y1                  = Output(UInt(16.W))
      val Y2                  = Output(UInt(16.W))
      val Y3                  = Output(UInt(16.W))

    })

    // Add the SystemVerilog/Verilog associated with the module
    // Relative to /src/main/resources
    addResource("/vsrc/dsp/idft_top.v")

  }

  // Macro definition for creating rising edge detectors
  def rising_edge(x: Bool)    = x && !RegNext(x)

  // Instantiate the input and output data memories (32 words of input and output data)
  val datain_mem              = Mem(32, UInt(64.W))     // for holding the input data
  val dataout_mem             = Mem(32, UInt(64.W))     // for holding the output data

  // Define registers / wires for interfacing to the dft blackbox
  val start                   = RegInit(false.B)      // Start bit controlled via register mappings
  val datain_we               = RegInit(false.B)      // Controlled via register mappings
  val datain_write_idx        = RegInit(0.U(6.W))     // Controlled via register mappings
  val datain_write_data       = RegInit(0.U(64.W))    // Controlled via register mappings
  val datain_read_idx         = RegInit(0.U(6.W))     // Generated read address from start bit
  val datain_read_data        = Wire(UInt(64.W))      // Data read from intermediate buffer into dft_top.v 

  val dataout_write_idx       = RegInit(0.U(6.W))     // Data output address generated from next_out
  val dataout_write_data      = RegInit(0.U(64.W))    // Data output
  val dataout_read_idx        = RegInit(0.U(6.W))     // Controlled via register mappings
  val dataout_read_data       = Wire(UInt(64.W))      // Controlled via register mappings
  val dataout_valid           = RegInit(false.B)      // Data valid output bit drive by dft_top.v

  val next_out                = RegInit(false.B)

  // "Connect" to llki node's signals and parameters (if the LLKI is defined)
  if (coreattachparams.llki_bus.isDefined) {

    val (llki, llkiEdge)    = outer.llki_node.get.in(0)

    // Instantiate the DFT Mock TSS
    val impl = Module(new idft_top_mock_tss())
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

    // Write to the input data memory when a rising edge is detected on the write enable
    when (rising_edge(datain_we)) {
      datain_mem.write(datain_write_idx, datain_write_data)
    }

    // Implement the read logic for the datain and data out memories
    datain_read_data              := datain_mem(datain_read_idx)
    dataout_read_data             := dataout_mem(dataout_read_idx)

    // Generate the read index for the data in memory
    when (rising_edge(start)) {
      datain_read_idx             := 0.U
    } .elsewhen (datain_read_idx < 32.U) {
      datain_read_idx             := datain_read_idx + 1.U
    }

    // Generate the write index for the output data memory (and write)
    when (next_out){
      dataout_write_idx           := 0.U;
    } .elsewhen (dataout_write_idx < 32.U) {
      dataout_write_idx           := dataout_write_idx + 1.U
      dataout_mem.write(dataout_write_idx, dataout_write_data)
    }

    // Generate the data valid signal
    when (rising_edge(start)) {
      dataout_valid               := 0.U
    } .elsewhen (rising_edge(next_out)) {
      dataout_valid               := 1.U
    }

    // Map the blackbox inputs
    impl.io.clk      := clock                // Implicit module clock
    impl.io.rst      := reset                // dft top has an active high reset 
    impl.io.X0       := Mux(datain_read_idx < 32.U, datain_read_data(63,48), 0.U) // Concatenating data into 64 bit blackbox input
    impl.io.X1       := Mux(datain_read_idx < 32.U, datain_read_data(47,32), 0.U) // Concatenating data into 64 bit blackbox input
    impl.io.X2       := Mux(datain_read_idx < 32.U, datain_read_data(31,16), 0.U) // Concatenating data into 64 bit blackbox input       
    impl.io.X3       := Mux(datain_read_idx < 32.U, datain_read_data(15,0),  0.U) // Concatenating data into 64 bit blackbox input
    impl.io.next     := rising_edge(start) 
                                                            // Map the dft input data only when pointing to
                                                            // a valid memory location
    // Map the blackbox outputs
    dataout_write_data                := Cat(impl.io.Y0,
                                             impl.io.Y1,
                                             impl.io.Y2,
                                             impl.io.Y3)      // dft output data
    next_out                            := impl.io.next_out

  } else { // else if (coreattachparams.llki_bus.isDefined)

    // Instantiate the DFT Top
    val impl = Module(new idft_top())
    impl.suggestName(impl.desiredName+"_inst")

  // Write to the input data memory when a rising edge is detected on the write enable
    when (rising_edge(datain_we)) {
      datain_mem.write(datain_write_idx, datain_write_data)
    }

    // Implement the read logic for the datain and data out memories
    datain_read_data              := datain_mem(datain_read_idx)
    dataout_read_data             := dataout_mem(dataout_read_idx)

    // Generate the read index for the data in memory
    when (rising_edge(start)) {
      datain_read_idx             := 0.U
    } .elsewhen (datain_read_idx < 32.U) {
      datain_read_idx             := datain_read_idx + 1.U
    }

    // Generate the write index for the output data memory (and write)
    when (next_out){
      dataout_write_idx           := 0.U;
    } .elsewhen (dataout_write_idx < 32.U) {
      dataout_write_idx           := dataout_write_idx + 1.U
      dataout_mem.write(dataout_write_idx, dataout_write_data)
    }

    // Generate the data valid signal
    when (rising_edge(start)) {
      dataout_valid               := 0.U
    } .elsewhen (rising_edge(next_out)) {
      dataout_valid               := 1.U
    }

    // Map the blackbox inputs
    impl.io.clk      := clock                // Implicit module clock
    impl.io.rst      := reset                // dft top has an active high reset 
    impl.io.X0       := Mux(datain_read_idx < 32.U, datain_read_data(63,48), 0.U) // Concatenating data into 64 bit blackbox input
    impl.io.X1       := Mux(datain_read_idx < 32.U, datain_read_data(47,32), 0.U) // Concatenating data into 64 bit blackbox input
    impl.io.X2       := Mux(datain_read_idx < 32.U, datain_read_data(31,16), 0.U) // Concatenating data into 64 bit blackbox input       
    impl.io.X3       := Mux(datain_read_idx < 32.U, datain_read_data(15,0),  0.U) // Concatenating data into 64 bit blackbox input
    impl.io.next     := rising_edge(start) 
                                                            // Map the dft input data only when pointing to
                                                            // a valid memory location
    // Map the blackbox outputs
    dataout_write_data                := Cat(impl.io.Y0,
                                             impl.io.Y1,
                                             impl.io.Y2,
                                             impl.io.Y3)      // dft output data
    next_out                            := impl.io.next_out

  } // if (coreattachparams.llki_bus.isDefined)


  // Define the register map
  // Registers with .r suffix to RegField are Read Only (otherwise, Chisel will assume they are R/W)
  outer.slave_node.regmap (
    IDFTAddresses.idft_ctrlstatus_addr    -> RegFieldGroup("dft_ctrlstatus",Some(""), Seq(
      RegField    (1, start               ),      // Start passing data to the dft blackbox
      RegField    (1, datain_we           ),      // Write enable for the datain memory
      RegField.r  (1, dataout_valid       ))),    // Data Out Valid
    IDFTAddresses.idft_datain_addr_addr   -> Seq(RegField     (5,  datain_write_idx)), // Address for data write, written to datain_write_idx by cepregression.cpp
    IDFTAddresses.idft_datain_data_addr   -> Seq(RegField     (64, datain_write_data)),// Data for data write, written to datain_write_data by cepregression.cpp
    IDFTAddresses.idft_dataout_addr_addr  -> Seq(RegField     (5,  dataout_read_idx)), // Address for data read, written to dataout_read_idx by cepregression.cpp 
    IDFTAddresses.idft_dataout_data_addr  -> Seq(RegField.r   (64, dataout_read_data)) // Data for data write, written to dataout_read_data by cepregression.cpp
  )  // regmap

}
//--------------------------------------------------------------------------------------
// END: TileLink Module Implementation
//--------------------------------------------------------------------------------------
