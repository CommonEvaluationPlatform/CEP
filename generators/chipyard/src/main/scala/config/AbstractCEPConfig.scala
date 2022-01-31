package chipyard.config

import freechips.rocketchip.config.{Config}
import freechips.rocketchip.subsystem._

// The following AbstractCEPConfig removes the L2 cache (when compared to AbstractConfig)
class AbstractCEPASICConfig extends Config(
  // Currently, the CEP does not depends/leverage the Chipyard TestHarness
  // The HarnessBinders control generation of hardware in the TestHarness

  // The IOBinders instantiate ChipTop IOs to match desired digital IOs
  // IOCells are generated for "Chip-like" IOs, while simulation-only IOs are directly punched through
  new chipyard.iobinders.WithDebugIOCells(enableJtagGPIO = true) ++
  new chipyard.iobinders.WithUARTGPIOCells ++
  new chipyard.iobinders.WithGPIOCells ++
  new chipyard.iobinders.WithSPIGPIOCells ++
  new chipyard.iobinders.WithTestIOStubs ++
  
  // Additional chip configuration items
  new chipyard.config.WithBlackBoxPLL ++                          // The System Clock & Reset will be routed through a Black Box PLL component
  new chipyard.config.WithNoSubsystemDrivenClocks ++              // drive the subsystem diplomatic clocks from ChipTop instead of using implicit clocks
  new chipyard.config.WithInheritBusFrequencyAssignments ++       // Unspecified clocks within a bus will receive the bus frequency if set
  new chipyard.config.WithPeripheryBusFrequencyAsDefault ++       // Unspecified frequencies with match the pbus frequency (which is always set)
  new chipyard.config.WithMemoryBusFrequency(200.0) ++            // Default 200 MHz mbus
  new chipyard.config.WithPeripheryBusFrequency(200.0) ++         // Default 200 MHz pbus
  new freechips.rocketchip.subsystem.WithJtagDTM ++               // set the debug module to expose a JTAG port
  new freechips.rocketchip.subsystem.WithNoMMIOPort ++            // no top-level MMIO master port (overrides default set in rocketchip)
  new freechips.rocketchip.subsystem.WithNoSlavePort ++           // no top-level MMIO slave port (overrides default set in rocketchip)
  new freechips.rocketchip.subsystem.WithNExtTopInterrupts(0) ++  // no external interrupts
  new chipyard.WithMulticlockCoherentBusTopology ++               // hierarchical buses including mbus+l2
  new freechips.rocketchip.system.BaseConfig
)                     // "base" rocketchip system

