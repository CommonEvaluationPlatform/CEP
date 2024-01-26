// See LICENSE for license details.
package chipyard.fpga.arty100t

import chisel3._

import sys.process._
import math.min

import org.chipsalliance.cde.config._
import freechips.rocketchip.subsystem._
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.devices.tilelink._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.system._
import freechips.rocketchip.tile._

import sifive.blocks.devices.uart._
import sifive.blocks.devices.gpio._
import sifive.blocks.devices.spi._
import sifive.fpgashells.shell.{DesignKey}

import testchipip.serdes.{SerialTLKey}

import chipyard.{BuildSystem}
import chipyard.iobinders.{OverrideIOBinder, OverrideLazyIOBinder}
import chipyard.config.{WithSPI, WithUART}

import mitllBlocks.cep_addresses._

// don't use FPGAShell's DesignKey
class WithNoDesignKey extends Config((site, here, up) => {
  case DesignKey => (p: Parameters) => new SimpleLazyRawModule()(p)
})

class WithUARTIOPassthrough extends OverrideIOBinder({
  (system: HasPeripheryUARTModuleImp) => {
    val io_uart_pins_temp = system.uart.zipWithIndex.map { case (dio, i) => IO(dio.cloneType).suggestName(s"uart_$i") }
    (io_uart_pins_temp zip system.uart).map { case (io, sysio) =>
      io <> sysio
    }
    (io_uart_pins_temp, Nil)
  }
})

class WithGPIOIOPassthrough extends OverrideIOBinder({
  (system: HasPeripheryGPIOModuleImp) => {
    val io_gpio_pins_temp = system.gpio.zipWithIndex.map { case (dio, i) => IO(dio.cloneType).suggestName(s"gpio_$i") }
    (io_gpio_pins_temp zip system.gpio).map { case (io, sysio) =>
      io <> sysio
    }
    (io_gpio_pins_temp, Nil)
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

class WithSPIIOPassthrough  extends OverrideLazyIOBinder({
  (system: HasPeripherySPI) => {
    // attach resource to 1st SPI
    ResourceBinding {
      Resource(new MMCDevice(system.tlSpiNodes.head.device, 1), "reg").bind(ResourceAddress(0))
    }

    InModuleBody {
      system.asInstanceOf[BaseSubsystem].module match { case system: HasPeripherySPIModuleImp => {
        val io_spi_pins_temp = system.spi.zipWithIndex.map { case (dio, i) => IO(dio.cloneType).suggestName(s"spi_$i") }
        (io_spi_pins_temp zip system.spi).map { case (io, sysio) =>
          io <> sysio
        }
        (io_spi_pins_temp, Nil)
      } }
    }
  }
})

class WithCEPBootrom extends Config((site, here, up) => {
  case BootROMLocated(x) => up(BootROMLocated(x)).map { p =>
    val freqMHz = (up(PeripheryBusKey).dtsFrequency.get).toLong
    // Forcing rebuild every time (-B) is critical as the clean process does NOT touch the bootrom
    val make = s"make -B -C fpga/src/main/resources/arty100t/cep_sdboot PBUS_CLK=${freqMHz} bin"
    require (make.! == 0, "Failed to build bootrom")
    p.copy(hang = 0x10000, contentFileName = s"./fpga/src/main/resources/arty100t/cep_sdboot/build/sdboot.bin")
  }
})

class WithArty100TTweaks extends Config(
  new chipyard.harness.WithAllClocksFromHarnessClockInstantiator ++
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

class RocketArty100TCEPConfig extends Config(
  // Add the CEP registers (required)
  new chipyard.config.WithCEPRegisters ++

  // Resources in the Arty100T are limited, so we add one of the smaller cores (MD5)
  // and a variant of the Surrogate Root of Trust
  new chipyard.config.WithMD5 ++
  new chipyard.config.WithSROTFPGAMD5Only ++

  // Insert with CEP bootrom
  new WithCEPBootrom ++

  // Overide the chip info 
  new WithDTS("mit-ll,cep-arty100t", Nil) ++

  // Add GPIO (LEDs have been explicitly removed from the Arty100T test harness)
  new WithArty100TGPIOBinder ++
  new WithGPIOIOPassthrough ++
  new WithArty100TGPIO ++

  // Add SD interface (MMC Device added by WithSPIIOPassthrough)
  new WithSPISDCardBinder ++
  new WithSPIIOPassthrough ++
  new WithSPI ++

  // Restore default UART
  new WithUARTBinder ++
  new WithUARTIOPassthrough ++
  new WithUART(address = 0x64000000L) ++
  
  // Include the Arty100T Tweaks
  new WithArty100TTweaks ++

  // Remove the L2 cache
  new chipyard.config.WithBroadcastManager ++ // no l2

  // Include the standard Rocket Config
  new chipyard.RocketConfig)

class RocketArty100TConfig extends Config(
  new WithArty100TTweaks ++
  new chipyard.config.WithBroadcastManager ++ // no l2
  new chipyard.RocketConfig)

class NoCoresArty100TConfig extends Config(
  new WithArty100TTweaks ++
  new chipyard.config.WithBroadcastManager ++ // no l2
  new chipyard.NoCoresConfig)

// This will fail to close timing above 50 MHz
class BringupArty100TConfig extends Config(
  new WithArty100TSerialTLToGPIO ++
  new WithArty100TTweaks(freqMHz = 50) ++
  new testchipip.serdes.WithSerialTLPHYParams(testchipip.serdes.InternalSyncSerialParams(freqMHz=50)) ++
  new chipyard.ChipBringupHostConfig)
