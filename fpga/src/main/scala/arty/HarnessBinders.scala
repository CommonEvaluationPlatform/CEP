package chipyard.fpga.arty

import chisel3._

import freechips.rocketchip.devices.debug.{HasPeripheryDebug}
import freechips.rocketchip.jtag.{JTAGIO}

import sifive.blocks.devices.uart.{UARTPortIO, HasPeripheryUARTModuleImp}
import sifive.blocks.devices.jtag.{JTAGPins, JTAGPinsFromPort}
import sifive.blocks.devices.pinctrl.{BasePin}

import sifive.fpgashells.ip.xilinx.{IBUFG, IOBUF, PULLUP, PowerOnResetFPGAOnly}

import chipyard.harness.{ComposeHarnessBinder, OverrideHarnessBinder}
import chipyard.iobinders.JTAGChipIO

class WithArtyResetHarnessBinder extends ComposeHarnessBinder({
  (system: HasPeripheryDebug, th: ArtyFPGATestHarness, ports: Seq[Data]) => {
    val resetPorts = ports.collect { case b: Bool => b }
    require(resetPorts.size == 2)
    withClockAndReset(th.clock_32MHz, th.ck_rst) {
      // Debug module reset
      th.dut_ndreset := resetPorts(0)

      // JTAG reset
      resetPorts(1) := PowerOnResetFPGAOnly(th.clock_32MHz)
    }
  }
})

class WithArtyJTAGHarnessBinder extends OverrideHarnessBinder({
  (system: HasPeripheryDebug, th: ArtyFPGATestHarness, ports: Seq[Data]) => {
    ports.map {
      case j: JTAGChipIO => {
        val jtag_wire = Wire(new JTAGIO)
        jtag_wire.TDO.data := j.TDO
        jtag_wire.TDO.driven := true.B
        j.TCK := jtag_wire.TCK
        j.TMS := jtag_wire.TMS
        j.TDI := jtag_wire.TDI

        val io_jtag = Wire(new JTAGPins(() => new BasePin(), false)).suggestName("jtag")

        JTAGPinsFromPort(io_jtag, jtag_wire)

        io_jtag.TCK.i.ival := IBUFG(IOBUF(th.jd_2).asClock).asBool

        IOBUF(th.jd_5, io_jtag.TMS)
        PULLUP(th.jd_5)

        IOBUF(th.jd_4, io_jtag.TDI)
        PULLUP(th.jd_4)

        IOBUF(th.jd_0, io_jtag.TDO)

        // mimic putting a pullup on this line (part of reset vote)
        th.SRST_n := IOBUF(th.jd_6)
        PULLUP(th.jd_6)

        // ignore the po input
        io_jtag.TCK.i.po.map(_ := DontCare)
        io_jtag.TDI.i.po.map(_ := DontCare)
        io_jtag.TMS.i.po.map(_ := DontCare)
        io_jtag.TDO.i.po.map(_ := DontCare)
      }
      case b: Bool =>
    }
  }
})

class WithArtyUARTHarnessBinder extends OverrideHarnessBinder({
  (system: HasPeripheryUARTModuleImp, th: ArtyFPGATestHarness, ports: Seq[UARTPortIO]) => {
    withClockAndReset(th.clock_32MHz, th.ck_rst) {
      IOBUF(th.uart_rxd_out,  ports.head.txd)
      ports.head.rxd := IOBUF(th.uart_txd_in)
    }
  }
})
