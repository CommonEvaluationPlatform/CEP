package chipyard.config

import scala.util.matching.Regex
import chisel3._
import chisel3.util.{log2Up}

import org.chipsalliance.cde.config.{Config}
import freechips.rocketchip.devices.tilelink.{BootROMLocated, PLICKey, CLINTKey}
import freechips.rocketchip.devices.debug.{Debug, ExportDebug, DebugModuleKey, DMI, JtagDTMKey, JtagDTMConfig}
import freechips.rocketchip.diplomacy.{AsynchronousCrossing}
import chipyard.stage.phases.TargetDirKey
import freechips.rocketchip.subsystem._
import freechips.rocketchip.tile.{XLen}

import sifive.blocks.devices.gpio._
import sifive.blocks.devices.uart._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.i2c._

import testchipip._

import chipyard.{ExtTLMem}

import mitllBlocks.cepPackage._
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
class WithAES ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.aes_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.aes_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.aes_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.aes_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.aes_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.aes_llki_sendrecv_addr),
    dev_name            = s"aes"))) extends Config((site, here, up) => {
  case PeripheryAESKey => params
})

class WithAESNoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.aes_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.aes_depth),
    dev_name            = s"aes"))) extends Config((site, here, up) => {
  case PeripheryAESKey => params
})

class WithDES3 ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.des3_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.des3_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.des3_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.des3_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.des3_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.des3_llki_sendrecv_addr),
    dev_name            = s"des3"))) extends Config((site, here, up) => {
  case PeripheryDES3Key => params
})

class WithDES3NoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.des3_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.des3_depth),
    dev_name            = s"des3"))) extends Config((site, here, up) => {
  case PeripheryDES3Key => params
})

class WithIIR ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.iir_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.iir_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.iir_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.iir_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.iir_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.iir_llki_sendrecv_addr),
    dev_name            = s"iir"))) extends Config((site, here, up) => {
  case PeripheryIIRKey => params
})

class WithIIRNoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.iir_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.iir_depth),
    dev_name            = s"iir"))) extends Config((site, here, up) => {
  case PeripheryIIRKey => params
})

class WithIDFT ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.idft_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.idft_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.idft_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.idft_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.idft_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.idft_llki_sendrecv_addr),
    dev_name            = s"idft"))) extends Config((site, here, up) => {
  case PeripheryIDFTKey => params
})

class WithIDFTNoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.idft_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.idft_depth),
    dev_name            = s"idft"))) extends Config((site, here, up) => {
  case PeripheryIDFTKey => params
})

class WithGPS ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.gps_0_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.gps_0_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.gps_0_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.gps_0_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_0_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_0_llki_sendrecv_addr),
    dev_name            = s"gps"))) extends Config((site, here, up) => {
  case PeripheryGPSKey => params
})

class WithGPSNoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.gps_0_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.gps_0_depth),
    dev_name            = s"gps"))) extends Config((site, here, up) => {
  case PeripheryGPSKey => params
})

class WithMD5 ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.md5_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.md5_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.md5_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.md5_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.md5_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.md5_llki_sendrecv_addr),
    dev_name            = s"md5"))) extends Config((site, here, up) => {
  case PeripheryMD5Key => params
})

class WithMD5NoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.md5_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.md5_depth),
    dev_name            = s"md5"))) extends Config((site, here, up) => {
  case PeripheryMD5Key => params
})

class WithDFT ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.dft_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.dft_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.dft_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.dft_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.dft_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.dft_llki_sendrecv_addr),
    dev_name            = s"dft"))) extends Config((site, here, up) => {
  case PeripheryDFTKey => params
})

class WithDFTNoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.dft_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.dft_depth),
    dev_name            = s"dft"))) extends Config((site, here, up) => {
  case PeripheryDFTKey => params
})

class WithFIR ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.fir_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.fir_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.fir_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.fir_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.fir_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.fir_llki_sendrecv_addr),
    dev_name            = s"fir"))) extends Config((site, here, up) => {
  case PeripheryFIRKey => params
})

class WithFIRNoLLKI( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.fir_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.fir_depth),
    dev_name            = s"fir"))) extends Config((site, here, up) => {
  case PeripheryFIRKey => params
})

class WithSHA256 ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.sha256_0_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.sha256_0_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.sha256_0_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.sha256_0_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_0_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_0_llki_sendrecv_addr),
    dev_name            = s"sha256"))) extends Config((site, here, up) => {
  case PeripherySHA256Key => params
})

class WithSHA256NoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.sha256_0_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.sha256_0_depth),
    dev_name            = s"sha256"))) extends Config((site, here, up) => {
  case PeripherySHA256Key => params
})

class WithRSA ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.rsa_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.rsa_depth),
    llki_base_addr      = BigInt(CEPBaseAddresses.rsa_llki_base_addr),
    llki_depth          = BigInt(CEPBaseAddresses.rsa_llki_depth),
    llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.rsa_llki_ctrlsts_addr),
    llki_sendrecv_addr  = BigInt(CEPBaseAddresses.rsa_llki_sendrecv_addr),
    dev_name            = s"rsa"))) extends Config((site, here, up) => {
  case PeripheryRSAKey => params
})

class WithRSANoLLKI ( params  : Seq[COREParams] = Seq(
  COREParams(
    slave_base_addr     = BigInt(CEPBaseAddresses.rsa_base_addr),
    slave_depth         = BigInt(CEPBaseAddresses.rsa_depth),
    dev_name            = s"rsa"))) extends Config((site, here, up) => {
  case PeripheryRSAKey => params
})

class WithCEPRegisters extends Config((site, here, up) => {
  case PeripheryCEPRegistersKey => List(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.cepregs_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.cepregs_base_depth),
      dev_name            = s"cepregs"
    ))
})

// Address and size defaults can be overriden
class WithCEPScratchpad (address:   BigInt = CEPBaseAddresses.scratchpad_base_addr,
                         size:      BigInt = CEPBaseAddresses.scratchpad_depth) extends Config((site, here, up) => {
  case CEPScratchpadKey => List(
    COREParams(
      slave_base_addr     = address,
      slave_depth         = size,
      dev_name            = s"scratchpad"
    ))
})

// Do not define BootROMLocated and ASICBootROMLocated at the same time
// WithCEPBootROM allows override of default parameters
class WithCEPBootROM    (address  : BigInt   = 0x10000, 
                         size     : Int      = 0x10000,
                         hang     : BigInt   = 0x10040) extends Config((site, here, up) => {
   case BootROMLocated(x) => up(BootROMLocated(x), site).map(_.copy(
                          address = address,
                          size    = size,
                          hang    = hang,
                          contentFileName = s"${site(TargetDirKey)}/bootrom.rv${site(XLen)}.img"))
})

class WithSROT extends Config((site, here, up) => {
  case SROTKey => List(
    SROTParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.srot_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.srot_base_depth),
      dev_name            = s"srot",
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

// The MD5 Only version of the SROT is allow targetting of the Arty100T, which was limited resources
class WithSROTFPGAMD5Only extends Config((site, here, up) => {
  case SROTKey => List(
    SROTParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.srot_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.srot_base_depth),
      dev_name            = s"srot",
      cep_cores_base_addr = BigInt(CEPBaseAddresses.cep_cores_base_addr),
      cep_cores_depth     = BigInt(CEPBaseAddresses.cep_cores_depth),
      // The following array results in the creation of LLKI_CORE_INDEX_ARRAY in srot_wrapper.sv
      // The SRoT uses these indicies for routing keys to the appropriate core
      llki_cores_array    = Array(
        CEPBaseAddresses.md5_llki_base_addr       // Core Index 0 
      )
    ))
})
