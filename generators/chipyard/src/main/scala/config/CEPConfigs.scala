package chipyard

import freechips.rocketchip.config.{Config}
import freechips.rocketchip.diplomacy.{AsynchronousCrossing}
//
// Define the default configuration for the CEP
// Addresses and other parameter overrides are definied in ConfigFragments.scala
// AbstractCEPConfig is definied in AbstractConfig.scala
//

class CEPRocketConfig extends Config(
  // Instantiate four Rocket Cores 
  new freechips.rocketchip.subsystem.WithNBigCores(4) ++

  // Add the CEP Accelerator Cores
  new chipyard.config.WithAES ++
  new chipyard.config.WithDES3 ++
  new chipyard.config.WithIIR ++
  new chipyard.config.WithIDFT ++
  new chipyard.config.WithGPS ++
  new chipyard.config.WithMD5 ++
  new chipyard.config.WithIIR ++
  new chipyard.config.WithFIR ++
  new chipyard.config.WithSHA256 ++
  new chipyard.config.WithRSA ++
  new chipyard.config.WithCEPRegisters ++
  new chipyard.config.WithScratchpad ++
  new chipyard.config.WithSROT ++

  // Set the remainder of the configuration items
  new chipyard.config.AbstractCEPConfig
)

