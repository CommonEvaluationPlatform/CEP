package chipyard.example

import chisel3._
import chisel3.util._
import chisel3.experimental.{IntParam, BaseModule}
import freechips.rocketchip.amba.axi4._
import freechips.rocketchip.prci._
import freechips.rocketchip.subsystem.{BaseSubsystem, PBUS}
import org.chipsalliance.cde.config.{Parameters, Field, Config}
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.regmapper.{HasRegMap, RegField}
import freechips.rocketchip.tilelink._
import freechips.rocketchip.util.UIntIsOneOf

// DOC include start: GCD params
case class GCDParams(
  address: BigInt = 0x4000,
  width: Int = 32,
  useAXI4: Boolean = false,
  useBlackBox: Boolean = true)
// DOC include end: GCD params

// DOC include start: GCD key
case object GCDKey extends Field[Option[GCDParams]](None)
// DOC include end: GCD key

class GCDIO(val w: Int) extends Bundle {
  val clock = Input(Clock())
  val reset = Input(Bool())
  val input_ready = Output(Bool())
  val input_valid = Input(Bool())
  val x = Input(UInt(w.W))
  val y = Input(UInt(w.W))
  val output_ready = Input(Bool())
  val output_valid = Output(Bool())
  val gcd = Output(UInt(w.W))
  val busy = Output(Bool())
}

class GCDTopIO extends Bundle {
  val gcd_busy = Output(Bool())
}

trait HasGCDTopIO {
  def io: GCDTopIO
}

// DOC include start: GCD blackbox
class GCDMMIOBlackBox(val w: Int) extends BlackBox(Map("WIDTH" -> IntParam(w))) with HasBlackBoxResource {
  val io = IO(new GCDIO(w))
  addResource("/vsrc/GCDMMIOBlackBox.v")
}
// DOC include end: GCD blackbox

// DOC include start: GCD chisel
class GCDMMIOChiselModule(val w: Int) extends Module {
  val io = IO(new GCDIO(w))
  val s_idle :: s_run :: s_done :: Nil = Enum(3)

  val state = RegInit(s_idle)
  val tmp   = Reg(UInt(w.W))
  val gcd   = Reg(UInt(w.W))

  io.input_ready := state === s_idle
  io.output_valid := state === s_done
  io.gcd := gcd

  when (state === s_idle && io.input_valid) {
    state := s_run
  } .elsewhen (state === s_run && tmp === 0.U) {
    state := s_done
  } .elsewhen (state === s_done && io.output_ready) {
    state := s_idle
  }

  when (state === s_idle && io.input_valid) {
    gcd := io.x
    tmp := io.y
  } .elsewhen (state === s_run) {
    when (gcd > tmp) {
      gcd := gcd - tmp
    } .otherwise {
      tmp := tmp - gcd
    }
  }

  io.busy := state =/= s_idle
}
// DOC include end: GCD chisel

// DOC include start: GCD router
class GCDTL(params: GCDParams, beatBytes: Int)(implicit p: Parameters) extends ClockSinkDomain(ClockSinkParameters())(p) {
  val device = new SimpleDevice("gcd", Seq("ucbbar,gcd")) 
  val node = TLRegisterNode(Seq(AddressSet(params.address, 4096-1)), device, "reg/control", beatBytes=beatBytes)

  override lazy val module = new GCDImpl
  class GCDImpl extends Impl with HasGCDTopIO {
    val io = IO(new GCDTopIO)
    withClockAndReset(clock, reset) {
      // How many clock cycles in a PWM cycle?
      val x = Reg(UInt(params.width.W))
      val y = Wire(new DecoupledIO(UInt(params.width.W)))
      val gcd = Wire(new DecoupledIO(UInt(params.width.W)))
      val status = Wire(UInt(2.W))

      val impl_io = if (params.useBlackBox) {
        val impl = Module(new GCDMMIOBlackBox(params.width))
        impl.io
      } else {
        val impl = Module(new GCDMMIOChiselModule(params.width))
        impl.io
      }

      impl_io.clock := clock
      impl_io.reset := reset.asBool

      impl_io.x := x
      impl_io.y := y.bits
      impl_io.input_valid := y.valid
      y.ready := impl_io.input_ready

      gcd.bits := impl_io.gcd
      gcd.valid := impl_io.output_valid
      impl_io.output_ready := gcd.ready

      status := Cat(impl_io.input_ready, impl_io.output_valid)
      io.gcd_busy := impl_io.busy

// DOC include start: GCD instance regmap
      node.regmap(
        0x00 -> Seq(
          RegField.r(2, status)), // a read-only register capturing current status
        0x04 -> Seq(
          RegField.w(params.width, x)), // a plain, write-only register
        0x08 -> Seq(
          RegField.w(params.width, y)), // write-only, y.valid is set on write
        0x0C -> Seq(
          RegField.r(params.width, gcd))) // read-only, gcd.ready is set on read
// DOC include end: GCD instance regmap
    }
  }
}

class GCDAXI4(params: GCDParams, beatBytes: Int)(implicit p: Parameters) extends ClockSinkDomain(ClockSinkParameters())(p) {
  val node = AXI4RegisterNode(AddressSet(params.address, 4096-1), beatBytes=beatBytes)
  override lazy val module = new GCDImpl
  class GCDImpl extends Impl with HasGCDTopIO {
    val io = IO(new GCDTopIO)
    withClockAndReset(clock, reset) {
      // How many clock cycles in a PWM cycle?
      val x = Reg(UInt(params.width.W))
      val y = Wire(new DecoupledIO(UInt(params.width.W)))
      val gcd = Wire(new DecoupledIO(UInt(params.width.W)))
      val status = Wire(UInt(2.W))

      val impl_io = if (params.useBlackBox) {
        val impl = Module(new GCDMMIOBlackBox(params.width))
        impl.io
      } else {
        val impl = Module(new GCDMMIOChiselModule(params.width))
        impl.io
      }

      impl_io.clock := clock
      impl_io.reset := reset.asBool

      impl_io.x := x
      impl_io.y := y.bits
      impl_io.input_valid := y.valid
      y.ready := impl_io.input_ready

      gcd.bits := impl_io.gcd
      gcd.valid := impl_io.output_valid
      impl_io.output_ready := gcd.ready

      status := Cat(impl_io.input_ready, impl_io.output_valid)
      io.gcd_busy := impl_io.busy

      node.regmap(
        0x00 -> Seq(
          RegField.r(2, status)), // a read-only register capturing current status
        0x04 -> Seq(
          RegField.w(params.width, x)), // a plain, write-only register
        0x08 -> Seq(
          RegField.w(params.width, y)), // write-only, y.valid is set on write
        0x0C -> Seq(
          RegField.r(params.width, gcd))) // read-only, gcd.ready is set on read
    }
  }
}
// DOC include end: GCD router

// DOC include start: GCD lazy trait
trait CanHavePeripheryGCD { this: BaseSubsystem =>
  private val portName = "gcd"

  private val pbus = locateTLBusWrapper(PBUS)

  // Only build if we are using the TL (nonAXI4) version
  val gcd_busy = p(GCDKey) match {
    case Some(params) => {
      val gcd = if (params.useAXI4) {
        val gcd = LazyModule(new GCDAXI4(params, pbus.beatBytes)(p))
        gcd.clockNode := pbus.fixedClockNode
        pbus.coupleTo(portName) {
          gcd.node :=
          AXI4Buffer () :=
          TLToAXI4 () :=
          // toVariableWidthSlave doesn't use holdFirstDeny, which TLToAXI4() needsx
          TLFragmenter(pbus.beatBytes, pbus.blockBytes, holdFirstDeny = true) := _
        }
        gcd
      } else {
        val gcd = LazyModule(new GCDTL(params, pbus.beatBytes)(p))
        gcd.clockNode := pbus.fixedClockNode
        pbus.coupleTo(portName) { gcd.node := TLFragmenter(pbus.beatBytes, pbus.blockBytes) := _ }
        gcd
      }
      val gcd_busy = InModuleBody {
        val busy = IO(Output(Bool())).suggestName("gcd_busy")
        busy := gcd.module.io.gcd_busy
        busy
      }
      Some(gcd_busy)
    }
    case None => None
  }
}
// DOC include end: GCD lazy trait

// DOC include start: GCD config fragment
class WithGCD(useAXI4: Boolean = false, useBlackBox: Boolean = false) extends Config((site, here, up) => {
  case GCDKey => Some(GCDParams(useAXI4 = useAXI4, useBlackBox = useBlackBox))
})
// DOC include end: GCD config fragment
