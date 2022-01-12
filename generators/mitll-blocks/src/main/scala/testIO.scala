//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
//
// File         : testIO.scala
// Project      : Common Evaluation Platform (CEP)
// Description  : Constructs to help add unconnected Test IO to the ASIC top level
// Notes        :
//
//--------------------------------------------------------------------------------------

package mitllBlocks.testIO

import chisel3._
import chisel3.util._
import chisel3.experimental.{Analog, IO}
import freechips.rocketchip.diplomacy._

class TestIO extends Bundle {
  val testio = Vec(4, Analog(1.W))
}

trait HasTestIOImp extends LazyModuleImp {
  val testio = IO(new TestIO)
  dontTouch(testio)
}
