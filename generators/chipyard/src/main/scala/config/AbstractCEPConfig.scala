package chipyard.config

import org.chipsalliance.cde.config.{Config}

// The following defines the abstract configuration for non-FPGA based CEP build targets
class AbstractCEPConfig extends Config(

  // While the test harness is not used for the CEP, the following is required to complete the chipyard build
  new chipyard.harness.WithClockAndResetFromHarness ++
  new chipyard.harness.WithAbsoluteFreqHarnessClockInstantiator ++ // generate clocks in harness with unsynthesizable ClockSourceAtFreqMHz

  // The IOBinders instantiate ChipTop IOs to match desired digital IOs
  // IOCells are generated for "Chip-like" IOs, while simulation-only IOs are directly punched through
  new chipyard.iobinders.WithDebugIOCells(enableJtagGPIO = true) ++
  new chipyard.iobinders.WithUARTGPIOCells ++
  new chipyard.iobinders.WithGPIOCells ++
  new chipyard.iobinders.WithSPIGPIOCells ++
  
  // By default, punch out IOs to the Harness
  new chipyard.clocking.WithPassthroughClockGenerator ++
  new chipyard.clocking.WithClockGroupsCombinedByName(("uncore", Seq("sbus", "mbus", "pbus", "fbus", "cbus", "implicit"), Seq("tile"))) ++
  new chipyard.config.WithPeripheryBusFrequency(200.0) ++
  new chipyard.config.WithMemoryBusFrequency(200.0) ++

  // Additional chip configuration items
  new chipyard.config.WithNoSubsystemDrivenClocks ++                    // drive the subsystem diplomatic clocks from ChipTop instead of using implicit clocks
  new chipyard.config.WithInheritBusFrequencyAssignments ++             // Unspecified clocks within a bus will receive the bus frequency if set
  new freechips.rocketchip.subsystem.WithNMemoryChannels(1) ++          // Default 1 memory channels
  new freechips.rocketchip.subsystem.WithClockGateModel ++              // add default EICG_wrapper clock gate model
  new chipyard.config.WithCEPJTAG ++                                    // set the debug module to expose a JTAG port
  new freechips.rocketchip.subsystem.WithNoMMIOPort ++                  // no top-level MMIO master port (overrides default set in rocketchip)
  new freechips.rocketchip.subsystem.WithNoSlavePort ++                 // no top-level MMIO slave port (overrides default set in rocketchip)
  new freechips.rocketchip.subsystem.WithInclusiveCache ++              // use Sifive L2 cache
  new freechips.rocketchip.subsystem.WithNExtTopInterrupts(0) ++        // no external interrupts
  new freechips.rocketchip.subsystem.WithDontDriveBusClocksFromSBus ++  // leave the bus clocks undriven by sbus
  new freechips.rocketchip.subsystem.WithCoherentBusTopology ++         // hierarchical buses including sbus/mbus/pbus/fbus/cbus/l2  
  new freechips.rocketchip.system.BaseConfig                            // "base" rocketchip system
)
