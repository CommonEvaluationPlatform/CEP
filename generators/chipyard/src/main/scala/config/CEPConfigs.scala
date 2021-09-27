package chipyard

import freechips.rocketchip.config.{Config}
import freechips.rocketchip.diplomacy.{AsynchronousCrossing}

class CEPRocketConfig extends Config(
  new freechips.rocketchip.subsystem.WithNBigCores(4) ++
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
  new chipyard.config.AbstractCEPConfig
)
