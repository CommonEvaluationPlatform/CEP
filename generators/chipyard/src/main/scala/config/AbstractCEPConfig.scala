package chipyard.config

import org.chipsalliance.cde.config.{Config}

// The following defines the abstract configuration for non-FPGA based CEP build targets
class AbstractCEPConfig extends Config(

  // While the test harness is not used for the CEP, the following is required to complete the chipyard build
  new chipyard.harness.WithClockAndResetFromHarness ++

  // The IOBinders instantiate ChipTop IOs to match desired digital IOs
  // IOCells are generated for "Chip-like" IOs, while simulation-only IOs are directly punched through
  new chipyard.iobinders.WithDebugIOCells(enableJtagGPIO = true) ++
  new chipyard.iobinders.WithUARTGPIOCells ++
  new chipyard.iobinders.WithGPIOCells ++
  new chipyard.iobinders.WithSPIGPIOCells ++
  
  // Default behavior is to use a divider-only clock-generator
  // This works in VCS, Verilator, and FireSim/
  // This should get replaced with a PLL-like config instead
  new chipyard.clocking.WithDividerOnlyClockGenerator ++
  
  // Additional chip configuration items
  new chipyard.config.WithNoSubsystemDrivenClocks ++                    // drive the subsystem diplomatic clocks from ChipTop instead of using implicit clocks
  new chipyard.config.WithInheritBusFrequencyAssignments ++             // Unspecified clocks within a bus will receive the bus frequency if set
  new chipyard.config.WithPeripheryBusFrequencyAsDefault ++             // Unspecified frequencies with match the pbus frequency (which is always set)
  new chipyard.config.WithMemoryBusFrequency(200.0) ++                  // Default 200 MHz mbus
  new chipyard.config.WithPeripheryBusFrequency(200.0) ++               // Default 200 MHz pbus
  new chipyard.config.WithCEPJTAG ++                                    // set the debug module to expose a JTAG port
  new freechips.rocketchip.subsystem.WithNoMMIOPort ++                  // no top-level MMIO master port (overrides default set in rocketchip)
  new freechips.rocketchip.subsystem.WithNoSlavePort ++                 // no top-level MMIO slave port (overrides default set in rocketchip)
  new freechips.rocketchip.subsystem.WithNExtTopInterrupts(0) ++        // no external interrupts
  new freechips.rocketchip.subsystem.WithDontDriveBusClocksFromSBus ++  // leave the bus clocks undriven by sbus
  new freechips.rocketchip.subsystem.WithCoherentBusTopology ++         // hierarchical buses including sbus/mbus/pbus/fbus/cbus/l2  
  new freechips.rocketchip.system.BaseConfig                            // "base" rocketchip system
)
