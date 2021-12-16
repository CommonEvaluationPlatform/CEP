package chipyard.config

import chisel3._

import freechips.rocketchip.config.{Field, Parameters, Config}
import freechips.rocketchip.devices.tilelink.{BootROMLocated}
import freechips.rocketchip.stage.phases.TargetDirKey
import freechips.rocketchip.tile._

import mitllBlocks.cep_addresses._
import mitllBlocks.aes._
import mitllBlocks.des3._
import mitllBlocks.iir._
import mitllBlocks.idft._
import mitllBlocks.gps._
import mitllBlocks.md5._
import mitllBlocks.dft._
import mitllBlocks.fir._
import mitllBlocks.sha256._
import mitllBlocks.rsa._
import mitllBlocks.cep_registers._
import mitllBlocks.cep_scratchpad._
import mitllBlocks.srot._

//
// CEP Specific Configuration Fragments
//
class WithAES extends Config((site, here, up) => {
  case PeripheryAESKey => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.aes_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.aes_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.aes_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.aes_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.aes_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.aes_llki_sendrecv_addr),
      dev_name            = s"aes"
    ))
})

class WithDES3 extends Config((site, here, up) => {
  case PeripheryDES3Key => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.des3_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.des3_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.des3_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.des3_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.des3_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.des3_llki_sendrecv_addr),
      dev_name            = s"des3"
    ))
})

class WithIIR extends Config((site, here, up) => {
  case PeripheryIIRKey => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.iir_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.iir_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.iir_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.iir_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.iir_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.iir_llki_sendrecv_addr),
      dev_name            = s"iir"
    ))
})

class WithIDFT extends Config((site, here, up) => {
  case PeripheryIDFTKey => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.idft_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.idft_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.idft_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.idft_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.idft_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.idft_llki_sendrecv_addr),
      dev_name            = s"idft"
    ))
})

class WithGPS extends Config((site, here, up) => {
  case PeripheryGPSKey => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_0_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_0_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_0_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_0_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_0_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_0_llki_sendrecv_addr),
      dev_name            = s"gps_0",
      verilog_module_name = Some(s"gps_mock_tss")
    ),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_1_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_1_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_1_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_1_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_1_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_1_llki_sendrecv_addr),
      dev_name            = s"gps_1",
      verilog_module_name = Some(s"gps_mock_tss")
    ),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_2_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_2_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_2_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_2_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_2_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_2_llki_sendrecv_addr),
      dev_name            = s"gps_2",
      verilog_module_name = Some(s"gps_mock_tss")
    ),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_3_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_3_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_3_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_3_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_3_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_3_llki_sendrecv_addr),
      dev_name            = s"gps_3",
      verilog_module_name = Some(s"gps_mock_tss")
    ))
})

class WithMD5 extends Config((site, here, up) => {
  case PeripheryMD5Key => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.md5_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.md5_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.md5_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.md5_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.md5_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.md5_llki_sendrecv_addr),
      dev_name            = s"md5"
    ))
})

class WithDFT extends Config((site, here, up) => {
  case PeripheryDFTKey => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.dft_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.dft_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.dft_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.dft_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.dft_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.dft_llki_sendrecv_addr),
      dev_name            = s"dft"
    ))
})

class WithFIR extends Config((site, here, up) => {
  case PeripheryFIRKey => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.fir_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.fir_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.fir_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.fir_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.fir_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.fir_llki_sendrecv_addr),
      dev_name            = s"fir"
    ))
})

class WithSHA256 extends Config((site, here, up) => {
  case PeripherySHA256Key => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_0_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_0_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_0_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_0_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_0_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_0_llki_sendrecv_addr),
      dev_name            = s"sha256_0",
      verilog_module_name = Some(s"sha256_mock_tss")
    ),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_1_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_1_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_1_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_1_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_1_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_1_llki_sendrecv_addr),
      dev_name            = s"sha256_1",
      verilog_module_name = Some(s"sha256_mock_tss")
    ),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_2_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_2_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_2_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_2_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_2_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_2_llki_sendrecv_addr),
      dev_name            = s"sha256_2",
      verilog_module_name = Some(s"sha256_mock_tss")
    ),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_3_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_3_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_3_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_3_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_3_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_3_llki_sendrecv_addr),
      dev_name            = s"sha256_3",
      verilog_module_name = Some(s"sha256_mock_tss")
    ))
})

class WithRSA extends Config((site, here, up) => {
  case PeripheryRSAKey => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.rsa_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.rsa_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.rsa_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.rsa_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.rsa_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.rsa_llki_sendrecv_addr),
      dev_name            = s"rsa"
    ))
})

class WithCEPRegisters extends Config((site, here, up) => {
  case PeripheryCEPRegistersKey => List(
    CEPREGSParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.cepregs_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.cepregs_base_depth),
      dev_name            = s"cepregs"
    ))
})

// Address and size defaults can be overriden
class WithCEPScratchpad (address:   BigInt = CEPBaseAddresses.scratchpad_base_addr,
                         size:      BigInt = CEPBaseAddresses.scratchpad_depth) extends Config((site, here, up) => {
  case CEPScratchpadKey => List(
    CEPScratchpadParams(
      slave_address       = address,
      slave_depth         = size,
      dev_name            = s"scratchpad"
    ))
})

// CEPBootROM allows override of default parameters
class WithCEPBootROM    (address  : BigInt  = 0x10000, 
                         size     : Int     = 0x10000,
                         hang     : BigInt  = 0x10040) extends Config((site, here, up) => {
  case BootROMLocated(x) => up(BootROMLocated(x), site).map(_.copy(
                         address = address,
                         size    = size,
                         hang    = hang,
                         contentFileName = s"${site(TargetDirKey)}/bootrom.rv${site(XLen)}.img"))
})

class WithSROT extends Config((site, here, up) => {
  case SROTKey => List(
    SROTParams(
      slave_address       = BigInt(CEPBaseAddresses.srot_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.srot_base_depth),
      cep_cores_base_addr = BigInt(CEPBaseAddresses.cep_cores_base_addr),
      cep_cores_depth     = BigInt(CEPBaseAddresses.cep_cores_depth),
      // The following array results in the creation of LLKI_CORE_INDEX_ARRAY in srot_wrapper.sv
      // The SRoT uses these indicies for routing keys to the appropriate core
      llki_cores_array    = Array(
        CEPBaseAddresses.aes_llki_base_addr,      // Core Index 0 
        CEPBaseAddresses.md5_llki_base_addr,      // Core Index 1 
        CEPBaseAddresses.sha256_0_llki_base_addr, // Core Index 2 
        CEPBaseAddresses.sha256_1_llki_base_addr, // Core Index 3 
        CEPBaseAddresses.sha256_2_llki_base_addr, // Core Index 4 
        CEPBaseAddresses.sha256_3_llki_base_addr, // Core Index 5 
        CEPBaseAddresses.rsa_llki_base_addr,      // Core Index 6 
        CEPBaseAddresses.des3_llki_base_addr,     // Core Index 7 
        CEPBaseAddresses.dft_llki_base_addr,      // Core Index 8 
        CEPBaseAddresses.idft_llki_base_addr,     // Core Index 9 
        CEPBaseAddresses.fir_llki_base_addr,      // Core Index 10
        CEPBaseAddresses.iir_llki_base_addr,      // Core Index 11
        CEPBaseAddresses.gps_0_llki_base_addr,    // Core Index 12
        CEPBaseAddresses.gps_1_llki_base_addr,    // Core Index 13
        CEPBaseAddresses.gps_2_llki_base_addr,    // Core Index 14
        CEPBaseAddresses.gps_3_llki_base_addr     // Core Index 15
      )
    ))
})
