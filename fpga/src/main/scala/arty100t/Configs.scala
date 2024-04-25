// See LICENSE for license details.
package chipyard.fpga.arty100t

import chisel3._ 

import sys.process._
import math.min

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.devices.tilelink._
import org.chipsalliance.diplomacy._
import org.chipsalliance.diplomacy.lazymodule._
import freechips.rocketchip.diplomacy.{ResourceBinding, Resource, ResourceAddress}
import freechips.rocketchip.system._
import freechips.rocketchip.tile._

import sifive.blocks.devices.uart._
import sifive.blocks.devices.spi._
import sifive.blocks.devices.gpio._

import sifive.fpgashells.shell.{DesignKey}

import testchipip.serdes.{SerialTLKey}

import chipyard.{BuildSystem}
import chipyard.iobinders._
import chipyard.config.{WithSPI, WithUART}

// don't use FPGAShell's DesignKey
class WithNoDesignKey extends Config((site, here, up) => {
  case DesignKey => (p: Parameters) => new SimpleLazyRawModule()(p)
})

// Instantiate the CEP Bootroom
class WithCEPBootrom extends Config((site, here, up) => {
  case BootROMLocated(x) => up(BootROMLocated(x)).map { p =>
    val freqMHz = (up(PeripheryBusKey).dtsFrequency.get).toLong
    // Forcing rebuild every time (-B) is critical as the clean process does NOT touch the bootrom
    val make = s"make -B -C fpga/src/main/resources/arty100t/cep_sdboot PBUS_CLK=${freqMHz} bin"
    require (make.! == 0, "Failed to build bootrom")
    p.copy(hang = 0x10000, contentFileName = s"./fpga/src/main/resources/arty100t/cep_sdboot/build/sdboot.bin")
  }
})

class WithArty100TGPIO extends Config((site, here, up) => {
  case PeripheryGPIOKey => {
    if (Arty100TGPIOs.width > 0) {
      require(Arty100TGPIOs.width <= 64) // currently only support 64 GPIOs (change addrs to get more)
      val gpioAddrs = Seq(BigInt(0x64002000), BigInt(0x64007000))
      val maxGPIOSupport = 32 // max gpios supported by SiFive driver (split by 32)
      List.tabulate(((Arty100TGPIOs.width - 1)/maxGPIOSupport) + 1)(n => {
        GPIOParams(address = gpioAddrs(n), width = min(Arty100TGPIOs.width - maxGPIOSupport*n, maxGPIOSupport))
      })
    }
    else {
      List.empty[GPIOParams]
    }
  }
})

// By default, this uses the on-board USB-UART for the TSI-over-UART link
// The PMODUART HarnessBinder maps the actual UART device to JD pin
class WithArty100TTweaks(freqMHz: Double = 50) extends Config(
  new WithArty100TPMODUART ++
  new WithArty100TUARTTSI ++
  new WithArty100TDDRTL ++
  new WithArty100TJTAG ++
  new WithNoDesignKey ++
  new testchipip.tsi.WithUARTTSIClient ++
  new chipyard.harness.WithSerialTLTiedOff ++
  new chipyard.harness.WithHarnessBinderClockFreqMHz(freqMHz) ++
  new chipyard.config.WithMemoryBusFrequency(freqMHz) ++
  new chipyard.config.WithFrontBusFrequency(freqMHz) ++
  new chipyard.config.WithSystemBusFrequency(freqMHz) ++
  new chipyard.config.WithPeripheryBusFrequency(freqMHz) ++
  new chipyard.config.WithControlBusFrequency(freqMHz) ++
  new chipyard.config.WithOffchipBusFrequency(freqMHz) ++
  new chipyard.harness.WithAllClocksFromHarnessClockInstantiator ++
  new chipyard.clocking.WithPassthroughClockGenerator ++
  new chipyard.config.WithTLBackingMemory ++ // FPGA-shells converts the AXI to TL for us
  new freechips.rocketchip.subsystem.WithExtMemSize(BigInt(256) << 20) ++ // 256mb on ARTY
  new freechips.rocketchip.subsystem.WithoutTLMonitors)

// By default, CEP does not use the TSI interface
class WithArty100TCEPTweaks(freqMHz: Double = 50) extends Config(
  new WithArty100TPMODUART ++
  new WithArty100TUARTTSI ++
  new WithArty100TDDRTL ++
  new WithArty100TJTAG ++
  new WithNoDesignKey ++
  new chipyard.harness.WithSerialTLTiedOff ++
  new chipyard.harness.WithHarnessBinderClockFreqMHz(freqMHz) ++
  new chipyard.config.WithMemoryBusFrequency(freqMHz) ++
  new chipyard.config.WithFrontBusFrequency(freqMHz) ++
  new chipyard.config.WithSystemBusFrequency(freqMHz) ++
  new chipyard.config.WithPeripheryBusFrequency(freqMHz) ++
  new chipyard.config.WithControlBusFrequency(freqMHz) ++
  new chipyard.config.WithOffchipBusFrequency(freqMHz) ++
  new chipyard.harness.WithAllClocksFromHarnessClockInstantiator ++
  new chipyard.clocking.WithPassthroughClockGenerator ++
  new chipyard.config.WithTLBackingMemory ++ // FPGA-shells converts the AXI to TL for us
  new freechips.rocketchip.subsystem.WithExtMemSize(BigInt(256) << 20) ++ // 256mb on ARTY
  new freechips.rocketchip.subsystem.WithoutTLMonitors)

class RocketArty100TConfig extends Config(
  new WithArty100TTweaks ++
  new chipyard.config.WithBroadcastManager ++ // no l2
  new chipyard.RocketConfig)

class RocketArty100TCEPConfig extends Config(
  // Add the CEP registers (required)
  new chipyard.config.WithCEPRegisters ++

  // Resources in the Arty100T are limited, so we add one of the smaller cores (MD5)
  // and a variant of the Surrogate Root of Trust
  new chipyard.config.WithMD5 ++
  new chipyard.config.WithSROTFPGAMD5Only ++

  // Instantiate the UART
  new WithArty100TUART ++
  new chipyard.config.WithUART(address = 0x64000000L) ++
  new chipyard.config.WithNoUART ++   // Disable the default UART

  // Instantiate the SPI/MMIO int
  new WithSPIIOPunchthrough ++
  new WithSPISDCardHarnessBinder ++
  new chipyard.config.WithSPI (address = 0x64001000L) ++

  // Instantiate the GPIO
  new WithGPIOPunchthrough ++
//  new WithArty100TGPIOBinder ++
  new WithArty100TGPIO ++

  // Insert with CEP bootrom
  new WithCEPBootrom ++

  // No L2 cache
  new chipyard.config.WithBroadcastManager ++ // no l2

  // Overide the chip info 
  new WithDTS("mit-ll,cep-arty100t", Nil) ++

  // Add the Arty100TCEPTweaks
  new WithArty100TCEPTweaks ++

  // Standard RocketConfig
  new chipyard.RocketConfig
)

class NoCoresArty100TConfig extends Config(
  new WithArty100TTweaks ++
  new chipyard.config.WithBroadcastManager ++ // no l2
  new chipyard.NoCoresConfig)

// This will fail to close timing above 50 MHz
class BringupArty100TConfig extends Config(
  new WithArty100TSerialTLToGPIO ++
  new WithArty100TTweaks(freqMHz = 50) ++
  new testchipip.serdes.WithSerialTLPHYParams(testchipip.serdes.InternalSyncSerialPhyParams(freqMHz=50)) ++
  new chipyard.ChipBringupHostConfig)
