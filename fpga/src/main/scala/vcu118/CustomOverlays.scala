//#************************************************************************
//# Copyright 2024 Massachusetts Institute of Technology
//# SPDX short identifier: BSD-3-Clause
//#
//# File Name:      CustomOverlays.scala
//# Program:        Common Evaluation Platform (CEP)
//# Description:    Custom FPGA Shell overlays for VCU118
//# Notes:          Modified from the Chipyard VCU118 CustomOverlays.scala
//#************************************************************************

package chipyard.fpga.vcu118

import chisel3._
import chisel3.experimental.{attach}

import freechips.rocketchip.diplomacy._
import org.chipsalliance.cde.config.{Parameters, Field}
import freechips.rocketchip.tilelink.{TLInwardNode, TLAsyncCrossingSink}
import freechips.rocketchip.prci._
import sifive.fpgashells.shell._
import sifive.fpgashells.ip.xilinx._
import sifive.fpgashells.shell.xilinx._
import sifive.fpgashells.clocks._

/* Connect GPIOs to FPGA I/Os */
abstract class GPIOXilinxPlacedOverlay(name: String, di: GPIODesignInput, si: GPIOShellInput)
  extends GPIOPlacedOverlay(name, di, si)
{
  def shell: XilinxShell

  shell { InModuleBody {
    (io.gpio zip tlgpioSink.bundle.pins).map { case (ioPin, sinkPin) =>
      val iobuf = Module(new IOBUF)
      iobuf.suggestName(s"gpio_iobuf")
      attach(ioPin, iobuf.io.IO)
      sinkPin.i.ival := iobuf.io.O
      iobuf.io.T := !sinkPin.o.oe
      iobuf.io.I := sinkPin.o.oval
    }
  } }
}

class CustomGPIOVCU118PlacedOverlay(val shell: VCU118Shell, name: String, val designInput: GPIODesignInput, val shellInput: GPIOShellInput, gpioNames: Seq[String])
   extends GPIOXilinxPlacedOverlay(name, designInput, shellInput)
{
  shell { InModuleBody {
    require(gpioNames.length == io.gpio.length)

    val packagePinsWithIOStdWithPackageIOs = (gpioNames zip io.gpio).map { case (name, io) =>
      val (pin, iostd, pullupEnable) = VCU118GPIOs.pinMapping(name)
      (pin, iostd, pullupEnable, IOPin(io))
    }

    val port = topIONode.bundle.port
    io <> port
    ui.clock := port.c0_ddr4_ui_clk
    ui.reset := /*!port.mmcm_locked ||*/ port.c0_ddr4_ui_clk_sync_rst
    port.c0_sys_clk_i := sys.clock.asUInt
    port.sys_rst := sys.reset // pllReset
    port.c0_ddr4_aresetn := !(ar.reset.asBool)

    // This was just copied from the SiFive example, but it's hard to follow.
    // The pins are emitted in the following order:
    // adr[0->13], we_n, cas_n, ras_n, bg, ba[0->1], reset_n, act_n, ck_c, ck_t, cke, cs_n, odt, dq[0->63], dqs_c[0->7], dqs_t[0->7], dm_dbi_n[0->7]
    val allddrpins = Seq(
      "AM27", "AL27", "AP26", "AP25", "AN28", "AM28", "AP28", "AP27", "AN26", "AM26", "AR28", "AR27", "AV25", "AT25", // adr[0->13]
      "AV28", "AU26", "AV26", "AU27", // we_n, cas_n, ras_n, bg
      "AR25", "AU28", // ba[0->1]
      "BD35", "AN25", "AT27", "AT26", "AW28", "AY29", "BB29", // reset_n, act_n, ck_c, ck_t, cke, cs_n, odt
      "BD30", "BE30", "BD32", "BE33", "BC33", "BD33", "BC31", "BD31", "BA32", "BB33", "BA30", "BA31", "AW31", "AW32", "AY32", "AY33", // dq[0->15]
      "AV30", "AW30", "AU33", "AU34", "AT31", "AU32", "AU31", "AV31", "AR33", "AT34", "AT29", "AT30", "AP30", "AR30", "AN30", "AN31", // dq[16->31]
      "BE34", "BF34", "BC35", "BC36", "BD36", "BE37", "BF36", "BF37", "BD37", "BE38", "BC39", "BD40", "BB38", "BB39", "BC38", "BD38", // dq[32->47]
      "BB36", "BB37", "BA39", "BA40", "AW40", "AY40", "AY38", "AY39", "AW35", "AW36", "AU40", "AV40", "AU38", "AU39", "AV38", "AV39", // dq[48->63]
      "BF31", "BA34", "AV29", "AP32", "BF35", "BF39", "BA36", "AW38", // dqs_c[0->7]
      "BF30", "AY34", "AU29", "AP31", "BE35", "BE39", "BA35", "AW37", // dqs_t[0->7]
      "BE32", "BB31", "AV33", "AR32", "BC34", "BE40", "AY37", "AV35") // dm_dbi_n[0->7]

    (IOPin.of(io) zip allddrpins) foreach { case (io, pin) => shell.xdc.addPackagePin(io, pin) }
  } }
}

class CustomGPIOVCU118ShellPlacer(shell: VCU118Shell, val shellInput: GPIOShellInput, gpioNames: Seq[String])(implicit val valName: ValName)
  extends GPIOShellPlacer[VCU118Shell] {
  def place(designInput: GPIODesignInput) = new CustomGPIOVCU118PlacedOverlay(shell, valName.name, designInput, shellInput, gpioNames)
}
