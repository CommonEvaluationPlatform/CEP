//#************************************************************************
//# Copyright 2024 Massachusetts Institute of Technology
//# SPDX short identifier: BSD-3-Clause
//#
//# File Name:      HarnessBinders.scala
//# Program:        Common Evaluation Platform (CEP)
//# Description:    Harness Binders file for VC707
//# Notes:          
//#************************************************************************

package chipyard.fpga.vc707

import chisel3._
import chisel3.experimental.{BaseModule}

import org.chipsalliance.diplomacy.nodes.{HeterogeneousBag}
import freechips.rocketchip.tilelink.{TLBundle}

import sifive.blocks.devices.uart.{UARTPortIO}
import sifive.blocks.devices.spi.{HasPeripherySPI, SPIPortIO}
import sifive.blocks.devices.gpio.{HasPeripheryGPIOModuleImp, GPIOPortIO}

import chipyard._
import chipyard.harness._
import chipyard.iobinders._

/*** UART ***/
class WithVC707UARTHarnessBinder extends HarnessBinder({
  case (th: VC707FPGATestHarnessImp, port: UARTPort, chipId: Int) => {
    th.vc707Outer.io_uart_bb.bundle <> port.io
  }
})

/*** SPI ***/
class WithVC707SPISDCardHarnessBinder extends HarnessBinder({
  case (th: VC707FPGATestHarnessImp, port: SPIPort, chipId: Int) => {
    th.vc707Outer.io_spi_bb.bundle <> port.io
  }
})

/*** GPIO ***/
class WithVC707GPIOHarnessBinder extends OverrideHarnessBinder({
  (system: HasPeripheryGPIOModuleImp, th: BaseModule, ports: Seq[GPIOPortIO]) => {
    th match { case vc707th: VC707FPGATestHarnessImp => {
      (vc707th.vc707Outer.io_gpio_bb zip ports).map { case (bb_io, dut_io) =>
        bb_io.bundle <> dut_io
      }
    } }
  }
})

/*** Experimental DDR ***/
class WithVC707DDRMemHarnessBinder extends HarnessBinder({
  case (th: VC707FPGATestHarnessImp, port: TLMemPort, chipId: Int) => {
    val bundles = th.vc707Outer.ddrClient.out.map(_._1)
    val ddrClientBundle = Wire(new HeterogeneousBag(bundles.map(_.cloneType)))
    bundles.zip(ddrClientBundle).foreach { case (bundle, io) => bundle <> io }
    ddrClientBundle <> port.io
  }
})
