//--------------------------------------------------------------------------------------
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File         : gps.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : TileLink interface to the verilog GPS core
//
//--------------------------------------------------------------------------------------
package mitllBlocks.gps

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
case object PeripheryGPSKey extends Field[Seq[COREParams]](Nil)

// This trait "connects" the core to the Rocket Chip and passes the parameters down
// to the instantiation
trait CanHavePeripheryGPS { this: BaseSubsystem =>
  val gpsnode = p(PeripheryGPSKey).map { params =>

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
  val startRound                   = RegInit(0.U(1.W))
  val sv_num                       = RegInit(0.U(6.W))
  val aes_key0                     = RegInit(0.U(64.W))
  val aes_key1                     = RegInit(0.U(64.W))
  val aes_key2                     = RegInit(0.U(64.W))
  val pcode_xn_cnt_speed           = RegInit(0x001.U(12.W))
  val pcode_z_cnt_speed            = RegInit(0x001.U(19.W))
  val pcode_ini_x1a                = RegInit(0x248.U(12.W)) // 12'b001001001000
  val pcode_ini_x1b                = RegInit(0x554.U(12.W)) // 12'b010101010100
  val pcode_ini_x2a                = RegInit(0x925.U(12.W)) // 12'b100100100101
  val pcode_ini_x2b                = RegInit(0x554.U(12.W)) // 12'b010101010100
  
  val gps_reset                    = RegInit(false.B)

  // Instantiate wires for the blackbox outputs
  val ca_code                      = Wire(UInt(13.W))
  val p_code0_u                    = Wire(UInt(32.W))
  val p_code0_l                    = Wire(UInt(32.W))
  val p_code1_u                    = Wire(UInt(32.W))
  val p_code1_l                    = Wire(UInt(32.W))
  val l_code0_u                    = Wire(UInt(32.W))
  val l_code0_l                    = Wire(UInt(32.W))
  val l_code1_u                    = Wire(UInt(32.W))
  val l_code1_l                    = Wire(UInt(32.W))
  val l_code_valid                 = Wire(Bool())

  // "Connect" to llki node's signals and parameters (if the LLKI is defined)
  if (coreattachparams.llki_bus.isDefined) {
    val (llki, llkiEdge)    = outer.llki_node.get.in(0)

    // Instantiate the GPS mock TSS
    val impl = Module(new gps_mock_tss())
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
    impl.io.sys_clk                     := clock                                      // Implicit module clock
    impl.io.sync_rst_in                 := reset
    impl.io.sync_rst_in_dut             := (reset.asBool || gps_reset).asAsyncReset 
                                                                                      // Implicit module reset
    impl.io.startRound                  := startRound                                 // Start bit
    impl.io.sv_num                      := sv_num                                     // GPS space vehicle number written by cepregression.cpp
    impl.io.aes_key                     := Cat(aes_key0, aes_key1, aes_key2)          // L code encryption key
    impl.io.pcode_speeds                := Cat(pcode_z_cnt_speed, pcode_xn_cnt_speed) // PCode acceleration register
    impl.io.pcode_initializers          := Cat(pcode_ini_x2b, pcode_ini_x2a, pcode_ini_x1b, pcode_ini_x1a) // Initializers for pcode shift registers
    ca_code                             := impl.io.ca_code               // Output GPS CA code
    p_code0_u                           := impl.io.p_code(127,96)        // Output P Code bits 
    p_code0_l                           := impl.io.p_code(95,64)         // Output P Code bits      
    p_code1_u                           := impl.io.p_code(63,32)         // Output P Code bits          
    p_code1_l                           := impl.io.p_code(31,0)          // Output P Code bits
    l_code0_u                           := impl.io.l_code(127,96)        // Output L Code bits                        
    l_code0_l                           := impl.io.l_code(95,64)         // Output L Code bits
    l_code1_u                           := impl.io.l_code(63,32)         // Output L Code bits      
    l_code1_l                           := impl.io.l_code(31,0)          // Output L Code bits
    l_code_valid                        := impl.io.l_code_valid          // Out is valid until start is again asserted

  } else { // else if (coreattachparams.llki_bus.isDefined)

    // Instantiate the GPS module
    val impl = Module(new gps())
    impl.suggestName(impl.desiredName+"_inst")

    // Map the blackbox I/O 
    impl.io.sys_clk                     := clock                                      // Implicit module clock
    impl.io.sync_rst_in                 := reset
    impl.io.startRound                  := startRound                                 // Start bit
    impl.io.sv_num                      := sv_num                                     // GPS space vehicle number written by cepregression.cpp
    impl.io.aes_key                     := Cat(aes_key0, aes_key1, aes_key2)          // L code encryption key
    impl.io.pcode_speeds                := Cat(pcode_z_cnt_speed, pcode_xn_cnt_speed) // PCode acceleration register
    impl.io.pcode_initializers          := Cat(pcode_ini_x2b, pcode_ini_x2a, pcode_ini_x1b, pcode_ini_x1a) // Initializers for pcode shift registers
    ca_code                             := impl.io.ca_code               // Output GPS CA code
    p_code0_u                           := impl.io.p_code(127,96)        // Output P Code bits 
    p_code0_l                           := impl.io.p_code(95,64)         // Output P Code bits      
    p_code1_u                           := impl.io.p_code(63,32)         // Output P Code bits          
    p_code1_l                           := impl.io.p_code(31,0)          // Output P Code bits
    l_code0_u                           := impl.io.l_code(127,96)        // Output L Code bits                        
    l_code0_l                           := impl.io.l_code(95,64)         // Output L Code bits
    l_code1_u                           := impl.io.l_code(63,32)         // Output L Code bits      
    l_code1_l                           := impl.io.l_code(31,0)          // Output L Code bits
    l_code_valid                        := impl.io.l_code_valid          // Out is valid until start is again asserted

  } // if (coreattachparams.llki_bus.isDefined)

  // Define the register map
  // Registers with .r suffix to RegField are Read Only (otherwise, Chisel will assume they are R/W)
  // Likewise, .w means Write Only
  outer.slave_node.regmap (
    GPSAddresses.gps_ctrlstatus_addr -> RegFieldGroup("gps_ctrlstatus", Some("GPS_Control_Status_Register"),Seq(
                    RegField    (1, startRound,      RegFieldDesc("start", "")),
                    RegField.r  (1, l_code_valid,  RegFieldDesc ("l_code_valid", "", volatile=true)))),
    GPSAddresses.gps_sv_num_addr     -> RegFieldGroup("sv_num",     Some("GPS_Set_SV_sv_num"),          Seq(RegField  (6,  sv_num))),
    GPSAddresses.gps_aes_key_addr_w0 -> RegFieldGroup("aes_key",    Some("GPS_Set_AES_Key_upper_bits"), Seq(RegField.w(64, aes_key0))),
    GPSAddresses.gps_aes_key_addr_w1 -> RegFieldGroup("aes_key",    Some("GPS_Set_AES_Key_middle_bits"),Seq(RegField.w(64, aes_key1))),
    GPSAddresses.gps_aes_key_addr_w2 -> RegFieldGroup("aes_key",    Some("GPS_Set_AES_Key_low_bits"),   Seq(RegField.w(64, aes_key2))),
    GPSAddresses.gps_pcode_speed_addr-> RegFieldGroup("pcode_speed",Some("GPS_PCode_acceleration"),     Seq(
                    RegField.w(12, pcode_xn_cnt_speed, RegFieldDesc("PCode_Xn_Counter_Speed","")),
                    RegField.w(19, pcode_z_cnt_speed,  RegFieldDesc("PCode_Z_Counter_Speed","")) )),
    GPSAddresses.gps_pcode_xini_addr -> RegFieldGroup("pcode_ini",  Some("GPS_PCode_x_lfsr_initial_states"),Seq(
                    RegField.w(12, pcode_ini_x1a, RegFieldDesc("PCode_X1A_Initial_State","")),
                    RegField.w(12, pcode_ini_x1b, RegFieldDesc("PCode_X1B_Initial_State","")),
                    RegField.w(12, pcode_ini_x2a, RegFieldDesc("PCode_X2A_Initial_State","")),
                    RegField.w(12, pcode_ini_x2b, RegFieldDesc("PCode_X2B_Initial_State","")) )),
    GPSAddresses.gps_ca_code_addr    -> RegFieldGroup("gps_cacode", Some("GPS_CA_code"),                Seq(RegField.r(64, ca_code))),
    GPSAddresses.gps_reset_addr      -> RegFieldGroup("gps_reset",  Some("GPS_addressable_reset"),      Seq(RegField  (1,  gps_reset))),            
    GPSAddresses.gps_p_code_addr_w0  -> RegFieldGroup("gps_pcode1", Some("GPS_pcode_upper_bits"),       Seq(RegField.r(64, Cat(p_code0_u,p_code0_l)))),
    GPSAddresses.gps_p_code_addr_w1  -> RegFieldGroup("gps_pcode1", Some("GPS_pcode_lower_64 bits"),    Seq(RegField.r(64, Cat(p_code1_u,p_code1_l)))),
    GPSAddresses.gps_l_code_addr_w0  -> RegFieldGroup("gps_lcode1", Some("GPS_lcode_upper_64 bits"),    Seq(RegField.r(64, Cat(l_code0_u,l_code0_l)))),
    GPSAddresses.gps_l_code_addr_w1  -> RegFieldGroup("gps_lcode1", Some("GPS_lcode_lower_64 bits"),    Seq(RegField.r(64, Cat(l_code1_u,l_code1_l))))
  )  // regmap
}
//--------------------------------------------------------------------------------------
// END: TileLink Module Implementation
//--------------------------------------------------------------------------------------

