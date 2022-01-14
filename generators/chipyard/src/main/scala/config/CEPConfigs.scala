package chipyard

import freechips.rocketchip.config.{Config}
import freechips.rocketchip.diplomacy.{AsynchronousCrossing}
import freechips.rocketchip.subsystem._

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
// Define the default configuration for the CEP
// Addresses and other parameter overrides are definied in ConfigFragments.scala
// AbstractCEPConfig is definied in AbstractConfig.scala
//
// Note: Configurations are applied in order, from bottom to top
//
class CEPRocketConfig extends Config(
  // Add the CEP Accelerator Cores
  new chipyard.config.WithAES ++
  new chipyard.config.WithDES3 ++
  new chipyard.config.WithFIR ++
  new chipyard.config.WithIIR ++
  new chipyard.config.WithDFT ++
  new chipyard.config.WithIDFT ++
  new chipyard.config.WithMD5 ++
  new chipyard.config.WithRSA ++
  new chipyard.config.WithGPS(params = Seq(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_0_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_0_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_0_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_0_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_0_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_0_llki_sendrecv_addr),
      dev_name            = s"gps_0"),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_1_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_1_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_1_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_1_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_1_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_1_llki_sendrecv_addr),
      dev_name            = s"gps_1"),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_2_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_2_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_2_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_2_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_2_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_2_llki_sendrecv_addr),
      dev_name            = s"gps_2"),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_3_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_3_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_3_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_3_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_3_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_3_llki_sendrecv_addr),
      dev_name            = s"gps_3")
    )) ++
  new chipyard.config.WithSHA256(params = Seq(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_0_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_0_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_0_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_0_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_0_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_0_llki_sendrecv_addr),
      dev_name            = s"sha256_0"),
    COREParams( 
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_1_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_1_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_1_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_1_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_1_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_1_llki_sendrecv_addr),
      dev_name            = s"sha256_1"),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_2_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_2_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_2_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_2_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_2_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_2_llki_sendrecv_addr),
      dev_name            = s"sha256_2"),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_3_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_3_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_3_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_3_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_3_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_3_llki_sendrecv_addr),
      dev_name            = s"sha256_3")
    )) ++
  new chipyard.config.WithCEPRegisters ++
  new chipyard.config.WithSROT ++

  // Instantiantion of the CEP BootROM with default parameter overrides
  // The hang parameter sets the system-wide reset vector for ALL RocketTiles
  new chipyard.config.WithCEPBootROM(address = 0x10000L, size = 0x10000, hang = 0x10000L) ++

  // CEP Scratchpad memory @ the typical external memory base address
  // Address & Size are in terms of *bytes* even though the memory is
  // 64-bits wide.  Thus, size of 0x7FFFF results in 64K x 64-bit (or 512kB)
  new chipyard.config.WithCEPScratchpad(address = 0x80000000L, size = 0x7FFFFL) ++

  // Moved IO declerations from AbstractCEPConfig to here for readability
  new chipyard.config.WithUART  (address = 0x64000000L) ++
  new chipyard.config.WithGPIO  (address = 0x64002000L, width = 8) ++
  
  // These configuration items have been inherited from the default configuration of the Freedom U500
  new freechips.rocketchip.subsystem.WithNBigCores(4) ++
  new WithNMemoryChannels(1) ++
  new WithDTS("mit-ll,rocketchip-cep", Nil) ++
  new WithoutTLMonitors ++ 

  // The CEP ASIC Configuration has no external memory
  new freechips.rocketchip.subsystem.WithNoMemPort ++

  // Set the remainder of the configuration items
  new chipyard.config.AbstractCEPConfig
)

class CEPASICRocketConfig extends Config(
  // Add the CEP Accelerator Cores
  new chipyard.config.WithAES ++
  new chipyard.config.WithDES3 ++
  new chipyard.config.WithFIR ++
  new chipyard.config.WithIIR ++
  new chipyard.config.WithDFT ++
  new chipyard.config.WithIDFT ++
  new chipyard.config.WithMD5 ++
  new chipyard.config.WithRSA ++
  new chipyard.config.WithGPS(params = Seq(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_2_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_2_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_2_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_2_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_2_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_2_llki_sendrecv_addr),
      dev_name            = s"gps_2"),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_3_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_3_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_3_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_3_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_3_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_3_llki_sendrecv_addr),
      dev_name            = s"gps_3")
    )) ++
  new chipyard.config.WithSHA256(params = Seq(
    COREParams( 
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_1_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_1_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_1_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_1_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_1_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_1_llki_sendrecv_addr),
      dev_name            = s"sha256_1"),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_2_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_2_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_2_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_2_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_2_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_2_llki_sendrecv_addr),
      dev_name            = s"sha256_2"),
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_3_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_3_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_3_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_3_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_3_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_3_llki_sendrecv_addr),
      dev_name            = s"sha256_3")
    )) ++
  new chipyard.config.WithSHA256Redaction(params = Seq(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.sha256_0_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.sha256_0_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.sha256_0_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.sha256_0_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.sha256_0_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.sha256_0_llki_sendrecv_addr),
      dev_name            = s"sha256_redaction")
  )) ++
  new chipyard.config.WithGPSLBLL(params = Seq(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_0_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_0_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_0_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_0_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_0_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_0_llki_sendrecv_addr),
      dev_name            = s"gps_lbll"),
  ))++
  new chipyard.config.WithGPSRedaction(params = Seq(
    COREParams(
      slave_base_addr     = BigInt(CEPBaseAddresses.gps_1_base_addr),
      slave_depth         = BigInt(CEPBaseAddresses.gps_1_depth),
      llki_base_addr      = BigInt(CEPBaseAddresses.gps_1_llki_base_addr),
      llki_depth          = BigInt(CEPBaseAddresses.gps_1_llki_depth),
      llki_ctrlsts_addr   = BigInt(CEPBaseAddresses.gps_1_llki_ctrlsts_addr),
      llki_sendrecv_addr  = BigInt(CEPBaseAddresses.gps_1_llki_sendrecv_addr),
      dev_name            = s"gps_redaction"),
  ))++

  new chipyard.config.WithCEPRegisters ++
  new chipyard.config.WithSROT ++

  // Instantiantion of the CEP BootROM with default parameter overrides
  // The hang parameter sets the system-wide reset vector for ALL RocketTiles
  new chipyard.config.WithCEPBootROM(address = 0x10000L, size = 0x10000, hang = 0x10000L) ++

  // CEP Scratchpad memory @ the typical external memory base address
  // Address & Size are in terms of *bytes* even though the memory is
  // 64-bits wide.  Thus, size of 0x7FFFF results in 64K x 64-bit (or 512kB)
  new chipyard.config.WithCEPScratchpad(address = 0x80000000L, size = 0x7FFFFL) ++

  // Moved IO declerations from AbstractCEPConfig to here for readability
  new chipyard.config.WithUART(address = 0x64000000L) ++
  new chipyard.config.WithGPIO(address = 0x64002000L, width = 8) ++
  new chipyard.config.WithSPI (address = 0x64001000L) ++

  // These configuration items have been inherited from the default configuration of the Freedom U500
  new freechips.rocketchip.subsystem.WithNBigCores(4) ++
  new WithNMemoryChannels(1) ++
  new WithDTS("mit-ll,rocketchip-cep", Nil) ++
  new WithoutTLMonitors ++ 

  // The CEP ASIC Configuration has no external memory
  new freechips.rocketchip.subsystem.WithNoMemPort ++

  // Set the remainder of the configuration items
  new chipyard.config.AbstractCEPConfig
)
