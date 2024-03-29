package chipyard.config

import org.chipsalliance.cde.config.{Config}

// --------------
// Chipyard abstract ("base") configuration
// NOTE: This configuration is NOT INSTANTIABLE, as it defines a empty system with no tiles
//
// The default set of IOBinders instantiate IOcells and ChipTop IOs for digital IO bundles.
// The default set of HarnessBinders instantiate TestHarness hardware for interacting with ChipTop IOs
// --------------

class AbstractCEPConfig extends Config(
  // The HarnessBinders control generation of hardware in the TestHarness
  //new chipyard.harness.WithUARTAdapter ++                          // add UART adapter to display UART on stdout, if uart is present
  //new chipyard.harness.WithBlackBoxSimMem ++                       // add SimDRAM DRAM model for axi4 backing memory, if axi4 mem is enabled
  new chipyard.harness.WithTiedOffSPIGPIO ++
  new chipyard.harness.WithUARTTiedOff ++
  new chipyard.harness.WithGPIOTiedOff ++                          // tie-off chiptop GPIOs, if GPIOs are present
  new chipyard.harness.WithClockFromHarness ++                     // all Clock I/O in ChipTop should be driven by harnessClockInstantiator
  new chipyard.harness.WithResetFromHarness ++                     // reset controlled by harness
  new chipyard.harness.WithAbsoluteFreqHarnessClockInstantiator ++ // generate clocks in harness with unsynthesizable ClockSourceAtFreqMHz

  // The IOBinders instantiate ChipTop IOs to match desired digital IOs
  // IOCells are generated for "Chip-like" IOs
  new chipyard.iobinders.WithDebugIOCells(enableJtagGPIO = true) ++
  new chipyard.iobinders.WithUARTGPIOCells ++
  new chipyard.iobinders.WithGPIOCells ++
  new chipyard.iobinders.WithSDIOGPIOCells ++
  new chipyard.iobinders.WithTestIOStubs ++
  new chipyard.iobinders.WithTestJtagStubs ++
  // The "punchthrough" IOBInders below don't generate IOCells, as these interfaces shouldn't really be mapped to ASIC IO
  // Instead, they directly pass through the DigitalTop ports to ports in the ChipTop
  new chipyard.iobinders.WithAXI4MemPunchthrough ++
  new chipyard.iobinders.WithSPIIOPunchthrough ++
  
  new chipyard.clocking.WithClockTapIOCells ++                      // Default generate a clock tapio
  new chipyard.clocking.WithPassthroughClockGenerator ++            // Default punch out IOs to the Harness
  new chipyard.clocking.WithClockGroupsCombinedByName(("uncore",    // Default merge all the bus clocks
    Seq("sbus", "mbus", "pbus", "fbus", "cbus", "obus", "implicit", "clock_tap"), Seq("tile"))) ++
  new chipyard.config.WithPeripheryBusFrequency(200.0) ++           // Default 200 MHz pbus
  new chipyard.config.WithControlBusFrequency(200.0) ++             // Default 200 MHz cbus
  new chipyard.config.WithMemoryBusFrequency(200.0) ++              // Default 200 MHz mbus
  new chipyard.config.WithControlBusFrequency(200.0) ++             // Default 200 MHz cbus
  new chipyard.config.WithSystemBusFrequency(200.0) ++              // Default 200 MHz sbus
  new chipyard.config.WithFrontBusFrequency(200.0) ++               // Default 200 MHz fbus
  new chipyard.config.WithOffchipBusFrequency(200.0) ++             // Default 200 MHz obus

  new chipyard.config.WithDebugModuleAbstractDataWords(8) ++        // increase debug module data capacity
  new chipyard.config.WithBootROM ++                                // use default bootrom
  new chipyard.config.WithL2TLBs(1024) ++                           // use L2 TLBs
  new chipyard.config.WithNoSubsystemClockIO ++                     // drive the subsystem diplomatic clocks from ChipTop instead of using implicit clocks
  new chipyard.config.WithInheritBusFrequencyAssignments ++         // Unspecified clocks within a bus will receive the bus frequency if set
  new freechips.rocketchip.subsystem.WithNMemoryChannels(1) ++      // Default 1 memory channels
  new freechips.rocketchip.subsystem.WithClockGateModel ++          // add default EICG_wrapper clock gate model
  new freechips.rocketchip.subsystem.WithJtagDTM ++                 // set the debug module to expose a JTAG port
  new freechips.rocketchip.subsystem.WithNoMMIOPort ++              // no top-level MMIO master port (overrides default set in rocketchip)
  new freechips.rocketchip.subsystem.WithNoSlavePort ++             // no top-level MMIO slave port (overrides default set in rocketchip)
  new freechips.rocketchip.subsystem.WithInclusiveCache ++          // use Sifive L2 cache
  new freechips.rocketchip.subsystem.WithNExtTopInterrupts(0) ++    // no external interrupts
  new freechips.rocketchip.subsystem.WithDontDriveBusClocksFromSBus ++ // leave the bus clocks undriven by sbus
  new freechips.rocketchip.subsystem.WithCoherentBusTopology ++     // hierarchical buses including sbus/mbus/pbus/fbus/cbus/l2
  new freechips.rocketchip.subsystem.WithDTS("ucb-bar,chipyard", Nil) ++ // custom device name for DTS
  new freechips.rocketchip.system.BaseConfig)                       // "base" rocketchip system
