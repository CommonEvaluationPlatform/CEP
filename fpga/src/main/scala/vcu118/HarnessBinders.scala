//#************************************************************************
//# Copyright 2024 Massachusetts Institute of Technology
//# SPDX short identifier: BSD-3-Clause
//#
//# File Name:      HarnessBinders.scala
//# Program:        Common Evaluation Platform (CEP)
//# Description:    Harness Binders file for VCU118
//# Notes:          
//#************************************************************************

package chipyard.fpga.vcu118

import chisel3._
import chisel3.experimental.{BaseModule}

import freechips.rocketchip.util.{HeterogeneousBag}
import freechips.rocketchip.tilelink.{TLBundle}

import sifive.blocks.devices.uart.{HasPeripheryUARTModuleImp, UARTPortIO}
import sifive.blocks.devices.spi.{HasPeripherySPI, SPIPortIO}
import sifive.blocks.devices.gpio.{HasPeripheryGPIOModuleImp, GPIOPortIO}

import chipyard._
import chipyard.harness._

/*** UART ***/
class WithVCU118UARTHarnessBinder extends OverrideHarnessBinder({
  (system: HasPeripheryUARTModuleImp, th: BaseModule, ports: Seq[UARTPortIO]) => {
    th match { case vcu118th: VCU118FPGATestHarnessImp => {
      vcu118th.vcu118Outer.io_uart_bb.bundle <> ports.head
    }}
  }
})

/*** SPI ***/
class WithVCU118SPISDCardHarnessBinder extends OverrideHarnessBinder({
  (system: HasPeripherySPI, th: BaseModule, ports: Seq[SPIPortIO]) => {
    th match { case vcu118th: VCU118FPGATestHarnessImp => {
      vcu118th.vcu118Outer.io_spi_bb.bundle <> ports.head
    }}
  }
})

/*** GPIO ***/
class WithVCU118GPIOHarnessBinder extends OverrideHarnessBinder({
  (system: HasPeripheryGPIOModuleImp, th: BaseModule, ports: Seq[GPIOPortIO]) => {
    th match { case vcu118th: VCU118FPGATestHarnessImp => {
      (vcu118th.vcu118Outer.io_gpio_bb zip ports).map { case (bb_io, dut_io) =>
        bb_io.bundle <> dut_io
      }
    } }
  }
})

/*** Experimental DDR ***/
class WithVCU118DDRMemHarnessBinder extends OverrideHarnessBinder({
  (system: CanHaveMasterTLMemPort, th: BaseModule, ports: Seq[HeterogeneousBag[TLBundle]]) => {
    th match { case vcu118th: VCU118FPGATestHarnessImp => {
      require(ports.size == 1)

      val bundles = vcu118th.vcu118Outer.ddrClient.out.map(_._1)
      val ddrClientBundle = Wire(new HeterogeneousBag(bundles.map(_.cloneType)))
      bundles.zip(ddrClientBundle).foreach { case (bundle, io) => bundle <> io }
      ddrClientBundle <> ports.head
    }}
  }
})
