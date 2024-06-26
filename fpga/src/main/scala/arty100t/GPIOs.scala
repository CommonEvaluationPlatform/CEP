//#************************************************************************
//# Copyright 2024 Massachusetts Institute of Technology
//# SPDX short identifier: BSD-3-Clause
//#
//# File Name:      GPIOs.scala
//# Program:        Common Evaluation Platform (CEP)
//# Description:    Pin mappings for GPIO on the arty100t
//# Notes:          Modified from the Chipyard VCU118 BringupGPIOs.scala
//#
//#                 Arty100t tri-color LEDs are not mapped at this time
//#************************************************************************

package chipyard.fpga.arty100t

import scala.collection.mutable.{LinkedHashMap}

object Arty100TGPIOs {
    // map of the pin name (akin to die pin name) to (fpga package pin, IOSTANDARD, add pullup resistor?)

    val pinMapping = LinkedHashMap(
        "gpio0" -> ("U12",  "LVCMOS33", false), // Bit0  - PmodC Pin1
        "gpio1" -> ("V12",  "LVCMOS33", false), // Bit1  - PmodC Pin2
        "gpio2" -> ("V10",  "LVCMOS33", false), // Bit2  - PmodC Pin3
        "gpio3" -> ("V11",  "LVCMOS33", false), // Bit3  - PmodC Pin4
        "gpio4" -> ("U14",  "LVCMOS33", false), // Bit4  - PmodC Pin7
        "gpio5" -> ("V14",  "LVCMOS33", false), // Bit5  - PmodC Pin8
        "gpio6" -> ("T13",  "LVCMOS33", false), // Bit6  - PmodC Pin9
        "gpio7" -> ("U13",  "LVCMOS33", false), // Bit7  - PmodC Pin10
        "sw0"   -> ("A8",  "LVCMOS33", false),  // Bit8  - SW0
        "sw1"   -> ("C11", "LVCMOS33", false),  // Bit9  - SW1
        "sw2"   -> ("C10", "LVCMOS33", false),  // Bit10 - SW2
        "sw3"   -> ("A10", "LVCMOS33", false),  // Bit11 - SW3
        "btn0"  -> ("D9",  "LVCMOS33", false),  // Bit12 - Button0
        "btn1"  -> ("C9",  "LVCMOS33", false),  // Bit13 - Button1
        "btn2"  -> ("B9",  "LVCMOS33", false),  // Bit14 - Button2
        "btn3"  -> ("B8",  "LVCMOS33", false),  // Bit15 - Button3
        "led0"  -> ("H5",  "LVCMOS33", false),  // Bit16 - LED4
        "led1"  -> ("J5",  "LVCMOS33", false),  // Bit17 - LED5
        "led2"  -> ("T9",  "LVCMOS33", false),  // Bit18 - LED6
        "led3"  -> ("T10", "LVCMOS33", false)   // Bit19 - LED7
    )

    // return list of names (ordered)
    def names: Seq[String] = pinMapping.keys.toSeq

    // return number of GPIOs
    def width: Int = pinMapping.size
}
