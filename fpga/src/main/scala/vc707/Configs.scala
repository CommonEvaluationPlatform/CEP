//#************************************************************************
//# Copyright 2024 Massachusetts Institute of Technology
//# SPDX short identifier: BSD-3-Clause
//#
//# File Name:      Configs.scala
//# Program:        Common Evaluation Platform (CEP)
//# Description:    Configuration file for VC707
//# Notes:          
//#************************************************************************

package chipyard.fpga.vc707

import sys.process._

import org.chipsalliance.cde.config.{Config, Parameters}
import freechips.rocketchip.subsystem.{SystemBusKey, PeripheryBusKey, ControlBusKey, ExtMem}
import freechips.rocketchip.devices.debug.{DebugModuleKey, ExportDebug, JTAG}
import freechips.rocketchip.devices.tilelink.{DevNullParams, BootROMLocated}
import freechips.rocketchip.diplomacy.{DTSModel, DTSTimebase, RegionType, AddressSet}
import freechips.rocketchip.tile.{XLen}

import sifive.blocks.devices.spi.{PeripherySPIKey, SPIParams}
import sifive.blocks.devices.uart.{PeripheryUARTKey, UARTParams}
import sifive.blocks.devices.gpio.{PeripheryGPIOKey, GPIOParams}

import sifive.fpgashells.shell.{DesignKey}
import sifive.fpgashells.shell.xilinx.{VC7074GDDRSize, VC7071GDDRSize}

import testchipip.serdes.{SerialTLKey}

import chipyard.{BuildSystem, ExtTLMem}
import chipyard.harness._

import math.min

import mitllBlocks.cepPackage._

class WithDefaultPeripherals extends Config((site, here, up) => {
  case PeripheryUARTKey => List(UARTParams(address = BigInt(0x64000000L)))
  case PeripherySPIKey => List(SPIParams(rAddress = BigInt(0x64001000L)))
})

class WithCEPDefaultPeripherals extends Config((site, here, up) => {
  case PeripheryUARTKey   => List(UARTParams(address  = BigInt(0x64000000L)))
  case PeripherySPIKey    => List(SPIParams(rAddress  = BigInt(0x64001000L)))
  case PeripheryGPIOKey   => {
     if (VC707GPIOs.width > 0) {
       require(VC707GPIOs.width <= 64) // currently only support 64 GPIOs (change addrs to get more)
       val gpioAddrs = Seq(BigInt(0x64002000), BigInt(0x64007000))
       val maxGPIOSupport = 32 // max gpios supported by SiFive driver (split by 32)
       List.tabulate(((VC707GPIOs.width - 1)/maxGPIOSupport) + 1)(n => {
         GPIOParams(address = gpioAddrs(n), width = min(VC707GPIOs.width - maxGPIOSupport*n, maxGPIOSupport))
       })
     }
     else {
       List.empty[GPIOParams]
     }
   }
})

// The VC707 build supports both 1GB and 4GB configurations
// In order to ensure the device builds properly, you'll need to go into the TestHarness and modify the following line:
//   val ddrNode = dp(DDROverlayKey).head.place(DDRDesignInput(dp(ExtTLMem).get.master.base, dutWrangler.node, harnessSysPLL, true)).overlayOutput.ddr
// and change the last parameter of DDRDesignInput:
// - DDRDesignInput(..... , false) - 1GB
// - DDRDesignInput(..... , true)  - 4GB
  
class WithSystemModifications extends Config((site, here, up) => {
  case DTSTimebase => BigInt{(1e6).toLong}
  case BootROMLocated(x) => up(BootROMLocated(x)).map { p =>
    // invoke makefile for sdboot
    val freqMHz = (site(SystemBusKey).dtsFrequency.get / (1000 * 1000)).toLong
    val make = s"make -B -C fpga/src/main/resources/vc707/sdboot PBUS_CLK=${freqMHz} bin"
    require (make.! == 0, "Failed to build bootrom")
    p.copy(hang = 0x10000, contentFileName = s"./fpga/src/main/resources/vc707/sdboot/build/sdboot.bin")
  }
  case ExtMem => up(ExtMem).map(x => x.copy(master = x.master.copy(size = site(VC7074GDDRSize)))) // set extmem to DDR size (note the size)
  case SerialTLKey => Nil // remove serialized tl port
})

class WithCEPSystemModifications extends Config((site, here, up) => {
  case DTSTimebase => BigInt{(1e6).toLong}
  case BootROMLocated(x) => up(BootROMLocated(x)).map { p =>
    // invoke makefile for sdboot
    val freqMHz = (site(SystemBusKey).dtsFrequency.get / (1000 * 1000)).toLong
    val make = s"make -B -C fpga/src/main/resources/vc707/cep_sdboot PBUS_CLK=${freqMHz} bin"
    require (make.! == 0, "Failed to build bootrom")
    p.copy(hang = 0x10000, contentFileName = s"./fpga/src/main/resources/vc707/cep_sdboot/build/sdboot.bin")
  }
  case ExtMem => up(ExtMem).map(x => x.copy(master = x.master.copy(size = site(VC7071GDDRSize)))) // set extmem to DDR size (note the size)
  case SerialTLKey => Nil // remove serialized tl port
})

class WithVC707Tweaks extends Config (
  // clocking
  new chipyard.harness.WithAllClocksFromHarnessClockInstantiator ++
  new chipyard.clocking.WithPassthroughClockGenerator ++
  new chipyard.config.WithMemoryBusFrequency(50.0) ++
  new chipyard.config.WithSystemBusFrequency(50.0) ++
  new chipyard.config.WithPeripheryBusFrequency(50.0) ++
  new chipyard.config.WithControlBusFrequency(50.0) ++
  new chipyard.config.WithFrontBusFrequency(50.0) ++

  new chipyard.harness.WithHarnessBinderClockFreqMHz(50) ++
  new WithFPGAFrequency(50) ++ // default 50MHz freq
  // harness binders
  new chipyard.harness.WithAllClocksFromHarnessClockInstantiator ++
  new WithVC707UARTHarnessBinder ++
  new WithVC707SPISDCardHarnessBinder ++
  new WithVC707DDRMemHarnessBinder ++
  // other configuration
  new WithDefaultPeripherals ++
  new chipyard.config.WithTLBackingMemory ++ // use TL backing memory
  new WithSystemModifications ++ // setup busses, use sdboot bootrom, setup ext. mem. size
  new chipyard.config.WithNoDebug ++ // remove debug module
  new freechips.rocketchip.subsystem.WithoutTLMonitors ++
  new freechips.rocketchip.subsystem.WithNMemoryChannels(1)
)

class WithVC707CEPTweaks extends Config (
  // clocking
  new chipyard.harness.WithAllClocksFromHarnessClockInstantiator ++
  new chipyard.clocking.WithPassthroughClockGenerator ++
  new chipyard.config.WithMemoryBusFrequency(75.0) ++
  new chipyard.config.WithSystemBusFrequency(75.0) ++
  new chipyard.config.WithPeripheryBusFrequency(75.0) ++
  new chipyard.config.WithControlBusFrequency(75.0) ++
  new chipyard.config.WithFrontBusFrequency(75.0) ++

  new chipyard.harness.WithHarnessBinderClockFreqMHz(75) ++
  new WithFPGAFrequency(75) ++
  // harness binders  
  new chipyard.harness.WithAllClocksFromHarnessClockInstantiator ++
  new WithVC707GPIOHarnessBinder ++
  new WithVC707UARTHarnessBinder ++
  new WithVC707SPISDCardHarnessBinder ++
  new WithVC707DDRMemHarnessBinder ++
  // other configuration
  new chipyard.iobinders.WithGPIOPunchthrough ++
  new WithCEPDefaultPeripherals ++
  new chipyard.config.WithTLBackingMemory ++ // use TL backing memory
  new WithCEPSystemModifications ++ // setup busses, use sdboot bootrom, setup ext. mem. size
  new chipyard.config.WithNoDebug ++ // remove debug module
  new freechips.rocketchip.subsystem.WithoutTLMonitors ++
  new freechips.rocketchip.subsystem.WithNMemoryChannels(1)
)

class RocketVC707CEPConfig extends Config(
  new chipyard.config.WithAES ++
  new chipyard.config.WithDES3 ++
  new chipyard.config.WithFIR ++
  new chipyard.config.WithIIR ++
  new chipyard.config.WithDFT ++
  new chipyard.config.WithIDFT ++
  new chipyard.config.WithMD5 ++
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
  new chipyard.config.WithRSA ++
  new chipyard.config.WithSROT ++
  new chipyard.config.WithCEPRegisters ++

  // Overide the chip info 
  new freechips.rocketchip.subsystem.WithDTS("mit-ll,cep-vc707", Nil) ++

  // Include the VC707 Tweaks
  new WithVC707CEPTweaks ++

  // Instantiate four big cores
  new freechips.rocketchip.subsystem.WithNBigCores(4) ++
  
  // Default Chipyard AbstractConfig
  new chipyard.config.AbstractConfig
)

class RocketVC707Config extends Config (
  new WithVC707Tweaks ++
  new chipyard.RocketConfig
)

class BoomVC707Config extends Config (
  new WithFPGAFrequency(50) ++
  new WithVC707Tweaks ++
  new chipyard.MegaBoomV3Config
)

class WithFPGAFrequency(fMHz: Double) extends Config (
  new chipyard.config.WithPeripheryBusFrequency(fMHz) ++
  new chipyard.config.WithMemoryBusFrequency(fMHz) ++
  new chipyard.config.WithSystemBusFrequency(fMHz) ++
  new chipyard.config.WithControlBusFrequency(fMHz) ++
  new chipyard.config.WithFrontBusFrequency(fMHz)
)

class WithFPGAFreq25MHz extends WithFPGAFrequency(25)
class WithFPGAFreq50MHz extends WithFPGAFrequency(50)
class WithFPGAFreq75MHz extends WithFPGAFrequency(75)
class WithFPGAFreq100MHz extends WithFPGAFrequency(100)
