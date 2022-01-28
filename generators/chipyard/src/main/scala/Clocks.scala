package chipyard

import chisel3._
import chisel3.util._
import chisel3.experimental.{Analog, IO}

import scala.collection.mutable.{ArrayBuffer}

import freechips.rocketchip.prci._
import freechips.rocketchip.subsystem.{BaseSubsystem, SubsystemDriveAsyncClockGroupsKey, InstantiatesTiles}
import freechips.rocketchip.config.{Parameters, Field, Config}
import freechips.rocketchip.diplomacy.{ModuleValue, OutwardNodeHandle, InModuleBody, LazyModule}
import freechips.rocketchip.util.{ResetCatchAndSync}

import barstools.iocell.chisel._
import testchipip.{TLTileResetCtrl}

import chipyard.clocking._
import chipyard.iobinders._

import asicBlocks.ceppll._

//
// A combined Clock and REset implementation to facilitate blackbox insertion of a PLL
//
// Original reset implementation comments:
//   A simple reset implementation that punches out reset ports
//   for standard Module classes. The ChipTop reset pin is Async.
//   Synchronization is performed in the ClockGroupResetSynchronizer
//
object GenerateClockAndReset {
  def apply(chiptop: ChipTop): (Clock, Reset) = {
    implicit val p = chiptop.p
    
    // this needs directionality so generateIOFromSignal works
    val async_reset_wire = Wire(Input(AsyncReset()))
    val (reset_io, resetIOCell) = IOCell.generateIOFromSignal(async_reset_wire, "reset", p(IOCellKey), abstractResetAsAsync = true)
    chiptop.iocells ++= resetIOCell

    chiptop.harnessFunctions += ((th: HasHarnessSignalReferences) => {
      reset_io := th.dutReset
      Nil
    })

    val clock_wire = Wire(Input(Clock()))
    val (clock_io, clockIOCell) = IOCell.generateIOFromSignal(clock_wire, "clock", p(IOCellKey))
    chiptop.iocells ++= clockIOCell
    chiptop.harnessFunctions += ((th: HasHarnessSignalReferences) => {
      clock_io := th.buildtopClock
      Nil
    })

    (clock_wire, async_reset_wire)
  }
}

// Using GenerateClockAndReset as a baseline, this object has been created to allow substitution of the CEP PLL
// Like all other top level IO in the ASIC, GenericDigitalGPIOCells will be used
object GenerateClockAndResetPLL {
  def apply(chiptop: ChipTop): (Clock, Reset) = {
    implicit val p = chiptop.p
    
    // this needs directionality so generateIOFromSignal works
    val reset_in      = Wire(Input(AsyncReset()))
    val reset_in_pad  = IO(Analog(1.W)).suggestName(s"reset")
    val resetIOCell   = {
          val iocell  = p(IOCellKey).gpio().suggestName(s"iocell_reset")
          iocell.io.o   := false.B
          iocell.io.oe  := false.B
          iocell.io.ie  := true.B
          reset_in      := (iocell.io.i).asAsyncReset
          iocell.io.pad <> reset_in_pad
          Seq(iocell)
        }
    chiptop.iocells ++= resetIOCell
    chiptop.harnessFunctions += ((th: HasHarnessSignalReferences) => {
      UIntToAnalog(th.dutReset.do_asUInt, reset_in_pad, true.B)
      Nil
    })

    val clk_in      = Wire(Input(Clock()))
    val clk_in_pad  = IO(Analog(1.W)).suggestName(s"refclk")
    val clkIOCell   = {
          val iocell  = p(IOCellKey).gpio().suggestName(s"iocell_clk")
          iocell.io.o   := false.B
          iocell.io.oe  := false.B
          iocell.io.ie  := true.B
          clk_in        := (iocell.io.i).asClock
          iocell.io.pad <> clk_in_pad
          Seq(iocell)
        }
    chiptop.iocells ++= clkIOCell
    chiptop.harnessFunctions += ((th: HasHarnessSignalReferences) => {
      UIntToAnalog(th.buildtopClock.do_asUInt, clk_in_pad, true.B)
      Nil
    })

    val pll_bypass        = Wire(Input(Bool()))
    val pll_bypass_pad    = IO(Analog(1.W)).suggestName(s"pll_bypass")
    val pll_bypassIOCell  = {
          val iocell  = p(IOCellKey).gpio().suggestName(s"iocell_pll_bypass")
          iocell.io.o   := false.B
          iocell.io.oe  := false.B
          iocell.io.ie  := true.B
          pll_bypass    := iocell.io.i
          iocell.io.pad <> pll_bypass_pad
          Seq(iocell)
        }
    chiptop.iocells ++= pll_bypassIOCell
    chiptop.harnessFunctions += ((th: HasHarnessSignalReferences) => {
      UIntToAnalog(th.logicLow.asUInt, pll_bypass_pad, true.B)
      Nil
    })

    val pll_observe       = Wire(Output(Clock()))
    val pll_observe_pad   = IO(Analog(1.W)).suggestName(s"pll_observe")
    val pll_observeIOCell  = {
          val iocell  = p(IOCellKey).gpio().suggestName(s"iocell_pll_observe")
          iocell.io.o   := pll_observe.asBool
          iocell.io.oe  := true.B
          iocell.io.ie  := false.B
          iocell.io.pad <> pll_observe_pad
          Seq(iocell)
        }
    chiptop.iocells ++= pll_observeIOCell

    // Output wire definitions (not routed to chip IO)
    val reset_out               = Wire(Output(AsyncReset()))
    val clk_out                 = Wire(Output(Clock()))

    // Instantiate the CEP PLL Chisel module
    val module                  = Module(new CEPPLLModule()).suggestName(s"pll")

    // Connect to the CEP PLL Chisel module I/O
    module.io.reset_in          := reset_in
    module.io.clk_in            := clk_in
    module.io.pll_bypass        := pll_bypass
    reset_out                   := module.io.reset_out
    clk_out                     := module.io.clk_out
    pll_observe                 := module.io.pll_observe

    // Return the clock and reset outputs to the "calling function"
    (clk_out, reset_out)
  }
}

case object ClockingSchemeKey extends Field[ChipTop => ModuleValue[Double]](ClockingSchemeGenerators.dividerOnlyClockGenerator)
case object EnableBlackBoxPLLKey extends Field[Boolean](false)
/*
  * This is a Seq of assignment functions, that accept a clock name and return an optional frequency.
  * Functions that appear later in this seq have higher precedence that earlier ones.
  * If no function returns a non-empty value, the value specified in
  * [[DefaultClockFrequencyKey]] will be used.
  */
case object ClockFrequencyAssignersKey extends Field[Seq[(String) => Option[Double]]](Seq.empty)
case object DefaultClockFrequencyKey extends Field[Double]()

class ClockNameMatchesAssignment(name: String, fMHz: Double) extends Config((site, here, up) => {
  case ClockFrequencyAssignersKey => up(ClockFrequencyAssignersKey, site) ++
    Seq((cName: String) => if (cName == name) Some(fMHz) else None)
})

class ClockNameContainsAssignment(name: String, fMHz: Double) extends Config((site, here, up) => {
  case ClockFrequencyAssignersKey => up(ClockFrequencyAssignersKey, site) ++
    Seq((cName: String) => if (cName.contains(name)) Some(fMHz) else None)
})

object ClockingSchemeGenerators {
  // Default clock and reset generation
  val dividerOnlyClockGenerator: ChipTop => ModuleValue[Double] = { chiptop =>
    implicit val p = chiptop.p

    // Requires existence of undriven asyncClockGroups in subsystem
    val systemAsyncClockGroup = chiptop.lazySystem match {
      case l: BaseSubsystem if (p(SubsystemDriveAsyncClockGroupsKey).isEmpty) =>
        l.asyncClockGroupsNode
    }

    // Add a control register for each tile's reset
    val resetSetter = chiptop.lazySystem match {
      case sys: BaseSubsystem with InstantiatesTiles => Some(TLTileResetCtrl(sys))
      case _ => None
    }
    val resetSetterResetProvider = resetSetter.map(_.tileResetProviderNode).getOrElse(ClockGroupEphemeralNode())

    val aggregator = LazyModule(new ClockGroupAggregator("allClocks")).node
    // provides the implicit clock to the system
    (chiptop.implicitClockSinkNode
      := ClockGroup()
      := aggregator)
    // provides the system clock (ex. the bus clocks)
    (systemAsyncClockGroup
      :*= ClockGroupNamePrefixer()
      :*= aggregator)

    val referenceClockSource =  ClockSourceNode(Seq(ClockSourceParameters()))
    val dividerOnlyClkGenerator = LazyModule(new DividerOnlyClockGenerator("buildTopClockGenerator"))
    // provides all the divided clocks (from the top-level clock)
    (aggregator
      := ClockGroupFrequencySpecifier(p(ClockFrequencyAssignersKey), p(DefaultClockFrequencyKey))
      := ClockGroupResetSynchronizer()
      := resetSetterResetProvider
      := dividerOnlyClkGenerator.node
      := referenceClockSource)

    val asyncResetBroadcast = FixedClockBroadcast(None)
    resetSetter.foreach(_.asyncResetSinkNode := asyncResetBroadcast)
    val asyncResetSource = ClockSourceNode(Seq(ClockSourceParameters()))
    asyncResetBroadcast := asyncResetSource

    InModuleBody {

      // Generate the I/O Cells and optional Blackbox PLL for system Clock and Reset
      val (clock_wire, reset_wire): (Clock, Reset) = if (p(EnableBlackBoxPLLKey) == true) {
        GenerateClockAndResetPLL(chiptop)
      } else {
        GenerateClockAndReset(chiptop)
      }
      
      referenceClockSource.out.unzip._1.map { o =>
        o.clock := clock_wire
        o.reset := reset_wire
      }

      asyncResetSource.out.unzip._1.map { o =>
        o.clock := false.B.asClock // async reset broadcast network does not provide a clock
        o.reset := reset_wire
      }

      // return the reference frequency
      dividerOnlyClkGenerator.module.referenceFreq

    } // InModuleBody
  } // dividerOnlyClockGenerator
} // ClockingSchemeGenerators
