package chipyard.fpga.arty100t

import chisel3._
import chisel3.experimental.{BaseModule}

import freechips.rocketchip.jtag.{JTAGIO}
import freechips.rocketchip.subsystem.{PeripheryBusKey}
import freechips.rocketchip.tilelink.{TLBundle}
import freechips.rocketchip.util.{HeterogeneousBag}
import freechips.rocketchip.diplomacy.{LazyRawModuleImp}

import sifive.blocks.devices.uart.{UARTPortIO, HasPeripheryUARTModuleImp, UARTParams}
import sifive.blocks.devices.gpio.{HasPeripheryGPIOModuleImp, GPIOPortIO}
import sifive.blocks.devices.spi.{HasPeripherySPI, SPIPortIO}
import sifive.blocks.devices.jtag.{JTAGPins, JTAGPinsFromPort}
import sifive.blocks.devices.pinctrl.{BasePin}
import sifive.fpgashells.shell._
import sifive.fpgashells.ip.xilinx._
import sifive.fpgashells.shell.xilinx._
import sifive.fpgashells.clocks._
import chipyard._
import chipyard.harness._
import chipyard.iobinders._
import testchipip.serdes._

class WithArty100TUARTTSI extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: UARTTSIPort, chipId: Int) => {
    val ath = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
    val harnessIO = IO(new UARTPortIO(port.io.uartParams)).suggestName("uart_tsi")
    harnessIO <> port.io.uart
    val packagePinsWithPackageIOs = Seq(
      ("A9" , IOPin(harnessIO.rxd)),
      ("D10", IOPin(harnessIO.txd)))
    packagePinsWithPackageIOs foreach { case (pin, io) => {
      ath.xdc.addPackagePin(io, pin)
      ath.xdc.addIOStandard(io, "LVCMOS33")
      ath.xdc.addIOB(io)
    } }

// Tethered Serial Interface (for debugging - https://chipyard.readthedocs.io/en/stable/Advanced-Concepts/Chip-Communication.html)
class WithArty100TUARTTSI(address: BigInt = 0x64000000L, uartBaudRate: BigInt = 115200) extends OverrideHarnessBinder({
  (system: CanHavePeripheryTLSerial, th: HasHarnessInstantiators, ports: Seq[ClockedIO[SerialIO]]) => {
    implicit val p = chipyard.iobinders.GetSystemParameters(system)
    ports.map({ port =>
      val ath = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
      val freq = p(PeripheryBusKey).dtsFrequency.get
      val bits = port.bits
      port.clock := th.harnessBinderClock
      val ram = TSIHarness.connectRAM(system.serdesser.get, bits, th.harnessBinderReset)
      val uart_to_serial = Module(new UARTToSerial(
        freq, UARTParams(address=address, initBaudRate=uartBaudRate)))
      val serial_width_adapter = Module(new SerialWidthAdapter(
        narrowW = 8, wideW = TSI.WIDTH))
      serial_width_adapter.io.narrow.flipConnect(uart_to_serial.io.serial)

      ram.module.io.tsi.flipConnect(serial_width_adapter.io.wide)

      ath.io_uart_bb.bundle <> uart_to_serial.io.uart

    })
  }
})

/*** DDR ***/
class WithArty100TDDRTL extends OverrideHarnessBinder({
  (system: CanHaveMasterTLMemPort, th: HasHarnessInstantiators, ports: Seq[HeterogeneousBag[TLBundle]]) => {
    require(ports.size == 1)
    val artyTh = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
    val bundles = artyTh.ddrClient.out.map(_._1)
    val ddrClientBundle = Wire(new HeterogeneousBag(bundles.map(_.cloneType)))
    bundles.zip(ddrClientBundle).foreach { case (bundle, io) => bundle <> io }
    ddrClientBundle <> port.io
  }
})

// Uses PMOD JA/JB
class WithArty100TSerialTLToGPIO extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: SerialTLPort, chipId: Int) => {
    val artyTh = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
    val harnessIO = IO(chiselTypeOf(port.io)).suggestName("serial_tl")
    harnessIO <> port.io

    harnessIO match {
      case io: DecoupledSerialIO => {
        val clkIO = io match {
          case io: InternalSyncSerialIO => IOPin(io.clock_out)
          case io: ExternalSyncSerialIO => IOPin(io.clock_in)
        }
        val packagePinsWithPackageIOs = Seq(
          ("G13", clkIO),
          ("B11", IOPin(io.out.valid)),
          ("A11", IOPin(io.out.ready)),
          ("D12", IOPin(io.in.valid)),
          ("D13", IOPin(io.in.ready)),
          ("B18", IOPin(io.out.bits, 0)),
          ("A18", IOPin(io.out.bits, 1)),
          ("K16", IOPin(io.out.bits, 2)),
          ("E15", IOPin(io.out.bits, 3)),
          ("E16", IOPin(io.in.bits, 0)),
          ("D15", IOPin(io.in.bits, 1)),
          ("C15", IOPin(io.in.bits, 2)),
          ("J17", IOPin(io.in.bits, 3))
        )
        packagePinsWithPackageIOs foreach { case (pin, io) => {
          artyTh.xdc.addPackagePin(io, pin)
          artyTh.xdc.addIOStandard(io, "LVCMOS33")
        }}

        // Don't add IOB to the clock, if its an input
        io match {
          case io: InternalSyncSerialIO => packagePinsWithPackageIOs foreach { case (pin, io) => {
            artyTh.xdc.addIOB(io)
          }}
          case io: ExternalSyncSerialIO => packagePinsWithPackageIOs.drop(1).foreach { case (pin, io) => {
            artyTh.xdc.addIOB(io)
          }}
        }

        artyTh.sdc.addClock("ser_tl_clock", clkIO, 100)
        artyTh.sdc.addGroup(pins = Seq(clkIO))
        artyTh.xdc.clockDedicatedRouteFalse(clkIO)
      }
    }
  }
})

// Maps the UART device to the on-board USB-UART
class WithArty100TUART(rxdPin: String = "A9", txdPin: String = "D10") extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: UARTPort, chipId: Int) => {
    val ath = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
    val harnessIO = IO(chiselTypeOf(port.io)).suggestName("uart")
    harnessIO <> port.io
    val packagePinsWithPackageIOs = Seq(
      (rxdPin, IOPin(harnessIO.rxd)),
      (txdPin, IOPin(harnessIO.txd)))
    packagePinsWithPackageIOs foreach { case (pin, io) => {
      ath.xdc.addPackagePin(io, pin)
      ath.xdc.addIOStandard(io, "LVCMOS33")
      ath.xdc.addIOB(io)
    } }
  }
})

// Maps the UART device to PMOD JD pins 3/7
class WithArty100TPMODUART extends WithArty100TUART("G2", "F3")

class WithArty100TJTAG extends HarnessBinder({
  case (th: HasHarnessInstantiators, port: JTAGPort, chipId: Int) => {
    val ath = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
    val harnessIO = IO(chiselTypeOf(port.io)).suggestName("jtag")
    harnessIO <> port.io

    ath.sdc.addClock("JTCK", IOPin(harnessIO.TCK), 10)
    ath.sdc.addGroup(clocks = Seq("JTCK"))
    ath.xdc.clockDedicatedRouteFalse(IOPin(harnessIO.TCK))
    val packagePinsWithPackageIOs = Seq(
      ("F4", IOPin(harnessIO.TCK)),
      ("D2", IOPin(harnessIO.TMS)),
      ("E2", IOPin(harnessIO.TDI)),
      ("D4", IOPin(harnessIO.TDO))
    )
    packagePinsWithPackageIOs foreach { case (pin, io) => {
      ath.xdc.addPackagePin(io, pin)
      ath.xdc.addIOStandard(io, "LVCMOS33")
      ath.xdc.addPullup(io)
    } }
  }
})

/*** GPIO ***/
class WithArty100TGPIOBinder extends OverrideHarnessBinder({
  (system: HasPeripheryGPIOModuleImp, th: HasHarnessInstantiators, ports: Seq[GPIOPortIO]) => {
    val artyTh = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
    (artyTh.io_gpio_bb zip ports).map { case (bb_io, dut_io) => bb_io.bundle <> dut_io}
  }
})

/*** SPI ***/
class WithSPISDCardBinder extends OverrideHarnessBinder({
  (system: HasPeripherySPI, th: HasHarnessInstantiators, ports: Seq[SPIPortIO]) => {
    val artyTh = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
    artyTh.io_spi_bb.bundle <> ports.head
  }
})

/*** UART ***/
class WithUARTBinder extends OverrideHarnessBinder({
  (system: HasPeripheryUARTModuleImp, th: HasHarnessInstantiators, ports: Seq[UARTPortIO]) => {
    val artyTh = th.asInstanceOf[LazyRawModuleImp].wrapper.asInstanceOf[Arty100THarness]
      artyTh.io_uart_bb.bundle <> ports.head
  }
})
