package chipyard

import freechips.rocketchip.config.{Config}
import freechips.rocketchip.diplomacy.{AsynchronousCrossing}

class CEPRocketConfig extends Config(
  new freechips.rocketchip.subsystem.WithNBigCores(1) ++
  new chipyard.config.WithAES ++
  new chipyard.config.AbstractConfig)
