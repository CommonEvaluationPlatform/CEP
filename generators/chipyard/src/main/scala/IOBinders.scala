package chipyard.iobinders

import chisel3._
import chisel3.experimental.{Analog, IO, DataMirror}

import freechips.rocketchip.config._
import freechips.rocketchip.diplomacy._
import freechips.rocketchip.diplomacy.{ResourceBinding, Resource, ResourceAddress, InModuleBody}
import freechips.rocketchip.devices.debug._
import freechips.rocketchip.jtag.{JTAGIO}
import freechips.rocketchip.subsystem._
import freechips.rocketchip.system.{SimAXIMem}
import freechips.rocketchip.amba.axi4.{AXI4Bundle, AXI4SlaveNode, AXI4MasterNode, AXI4EdgeParameters}
import freechips.rocketchip.util._
import freechips.rocketchip.prci.{ClockSinkNode, ClockSinkParameters}
import freechips.rocketchip.groundtest.{GroundTestSubsystemModuleImp, GroundTestSubsystem}

import sifive.blocks.devices.gpio._
import sifive.blocks.devices.uart._
import sifive.blocks.devices.spi._
import tracegen.{TraceGenSystemModuleImp}

import barstools.iocell.chisel._

import testchipip._
import icenet.{CanHavePeripheryIceNIC, SimNetwork, NicLoopback, NICKey, NICIOvonly}

import scala.reflect.{ClassTag}

object IOBinderTypes {
  type IOBinderTuple = (Seq[Data], Seq[IOCell])
  type IOBinderFunction = (Boolean, => Any) => ModuleValue[IOBinderTuple]
}
import IOBinderTypes._

// System for instantiating binders based
// on the scala type of the Target (_not_ its IO). This avoids needing to
// duplicate harnesses (essentially test harnesses) for each target.

// IOBinders is map between string representations of traits to the desired
// IO connection behavior for tops matching that trait. We use strings to enable
// composition and overriding of IOBinders, much like how normal Keys in the config
// system are used/ At elaboration, the testharness traverses this set of functions,
// and functions which match the type of the DigitalTop are evaluated.

// You can add your own binder by adding a new (key, fn) pair, typically by using
// the OverrideIOBinder or ComposeIOBinder macros
case object IOBinders extends Field[Map[String, Seq[IOBinderFunction]]](
  Map[String, Seq[IOBinderFunction]]().withDefaultValue(Nil)
)

abstract trait HasIOBinders { this: LazyModule =>
  val lazySystem: LazyModule
  private val iobinders = p(IOBinders)
  // Note: IOBinders cannot rely on the implicit clock/reset, as they may be called from the
  // context of a LazyRawModuleImp
  private val lzy = iobinders.map({ case (s,fns) => s -> fns.map(f => f(true, lazySystem)) })
  private val imp = iobinders.map({ case (s,fns) => s -> fns.map(f => f(false, lazySystem.module)) })

  private lazy val lzyFlattened: Map[String, IOBinderTuple] = lzy.map({
    case (s,ms) => s -> (ms.map(_._1).flatten, ms.map(_._2).flatten)
  })
  private lazy val impFlattened: Map[String, IOBinderTuple] = imp.map({
    case (s,ms) => s -> (ms.map(_._1).flatten, ms.map(_._2).flatten)
  })

  // A publicly accessible list of IO cells (useful for a floorplanning tool, for example)
  lazy val iocells = (lzyFlattened.values ++ impFlattened.values).unzip._2.flatten.toBuffer

  // A mapping between stringified DigitalSystem traits and their corresponding ChipTop ports
  lazy val portMap = iobinders.keys.map(k => k -> (lzyFlattened(k)._1 ++ impFlattened(k)._1)).toMap
}

// Note: The parameters instance is accessible only through LazyModule
// or LazyModuleImpLike. The self-type requirement in traits like
// CanHaveMasterAXI4MemPort is insufficient to make it accessible to the IOBinder
// As a result, IOBinders only work on Modules which inherit LazyModule or
// or LazyModuleImpLike
object GetSystemParameters {
  def apply(s: Any): Parameters = {
    s match {
      case s: LazyModule => s.p
      case s: LazyModuleImpLike => s.p
      case _ => throw new Exception(s"Trying to get Parameters from a system that is not LazyModule or LazyModuleImpLike")
    }
  }
}

class IOBinder[T](composer: Seq[IOBinderFunction] => Seq[IOBinderFunction])(implicit tag: ClassTag[T]) extends Config((site, here, up) => {
  case IOBinders => up(IOBinders, site) + (tag.runtimeClass.toString -> composer(up(IOBinders, site)(tag.runtimeClass.toString)))
})

class ConcreteIOBinder[T](composes: Boolean, fn: T => IOBinderTuple)(implicit tag: ClassTag[T]) extends IOBinder[T](
  up => (if (composes) up else Nil) ++ Seq(((_, t) => { InModuleBody {
    t match {
      case system: T => fn(system)
      case _ => (Nil, Nil)
    }
  }}): IOBinderFunction)
)

class LazyIOBinder[T](composes: Boolean, fn: T => ModuleValue[IOBinderTuple])(implicit tag: ClassTag[T]) extends IOBinder[T](
  up => (if (composes) up else Nil) ++ Seq(((isLazy, t) => {
    val empty = new ModuleValue[IOBinderTuple] {
      def getWrappedValue: IOBinderTuple = (Nil, Nil)
    }
    if (isLazy) {
      t match {
        case system: T => fn(system)
        case _ => empty
      }
    } else {
      empty
    }
  }): IOBinderFunction)
)

// The "Override" binders override any previous IOBinders (lazy or concrete) defined on the same trait.
// The "Compose" binders do not override previously defined IOBinders on the same trait
// The default IOBinders evaluate only in the concrete "ModuleImp" phase of elaboration
// The "Lazy" IOBinders evaluate in the LazyModule phase, but can also generate hardware through InModuleBody

class OverrideIOBinder[T](fn: T => IOBinderTuple)(implicit tag: ClassTag[T]) extends ConcreteIOBinder[T](false, fn)
class ComposeIOBinder[T](fn: T => IOBinderTuple)(implicit tag: ClassTag[T]) extends ConcreteIOBinder[T](true, fn)

class OverrideLazyIOBinder[T](fn: T => ModuleValue[IOBinderTuple])(implicit tag: ClassTag[T]) extends LazyIOBinder[T](false, fn)
class ComposeLazyIOBinder[T](fn: T => ModuleValue[IOBinderTuple])(implicit tag: ClassTag[T]) extends LazyIOBinder[T](true, fn)


case object IOCellKey extends Field[IOCellTypeParams](GenericIOCellParams())


class WithGPIOCells extends OverrideIOBinder({
  (system: HasPeripheryGPIOModuleImp) => {
    val (ports2d, cells2d) = system.gpio.zipWithIndex.map({ case (gpio, i) =>
      gpio.pins.zipWithIndex.map({ case (pin, j) =>
        val g = IO(Analog(1.W)).suggestName(s"gpio_${i}_${j}")
        val iocell = system.p(IOCellKey).gpio().suggestName(s"iocell_gpio_${i}_${j}")
        iocell.io.o := pin.o.oval
        iocell.io.oe := pin.o.oe
        iocell.io.ie := pin.o.ie
        pin.i.ival := iocell.io.i
        iocell.io.pad <> g
        (g, iocell)
      }).unzip
    }).unzip
    val ports: Seq[Analog] = ports2d.flatten
    (ports, cells2d.flatten)
  }
})

// DOC include start: WithUARTIOCells
class WithUARTIOCells extends OverrideIOBinder({
  (system: HasPeripheryUARTModuleImp) => {
    val (ports: Seq[UARTPortIO], cells2d) = system.uart.zipWithIndex.map({ case (u, i) =>
      val (port, ios) = IOCell.generateIOFromSignal(u, s"uart_${i}", system.p(IOCellKey), abstractResetAsAsync = true)
      (port, ios)
    }).unzip
    (ports, cells2d.flatten)
  }
})
// DOC include end: WithUARTIOCells

// Class to support GPIO Instantiation for the UART Interface
class UARTChipGPIO extends Bundle {
  val txd = Analog(1.W)
  val rxd = Analog(1.W)
}

// Variant of the UART Binder that forces the instantiation of GPIO cells for ALL pins
class WithUARTGPIOCells extends OverrideIOBinder({
  (system: HasPeripheryUARTModuleImp) => {
    val (ports: Seq[UARTPortIO], cells2d) = system.uart.zipWithIndex.map({ case (u, i) =>
      val name        = s"uart_${i}"
      val port        = IO(new UARTChipGPIO).suggestName(name)
      val iocellBase  = s"iocell_${name}"

      // txd is unidirectional, but is being mapped to a GPIO Cell
      val txdIOs = {
        val iocell = system.p(IOCellKey).gpio().suggestName(s"${iocellBase}_txd")
        iocell.io.o := u.txd
        iocell.io.oe := true.B
        iocell.io.ie := false.B
        iocell.io.pad <> port.txd
        Seq(iocell)
      }

      // txd is unidirectional, but is being mapped to a GPIO Cell
      val rxdIOs = {
        val iocell = system.p(IOCellKey).gpio().suggestName(s"${iocellBase}_rxd")
        iocell.io.o   := false.B
        iocell.io.oe  := false.B
        iocell.io.ie  := true.B
        u.rxd         := iocell.io.i
        iocell.io.pad <> port.rxd
        Seq(iocell)
      }
      (port, txdIOs ++ rxdIOs)
    }).unzip
    (ports, cells2d.flatten)
  }
})

// Class to insert internally unconnected pads
class WithTestIOStubs extends OverrideIOBinder({
  (system: DontTouch) => {
    val ports = IO(new Bundle {
      val io      = Vec(16, Analog(1.W))
      val mode    = Vec(4, Analog(1.W))
    }).suggestName(s"test")

    val iocells = ports.io.zipWithIndex.map { case (pin, i) =>
      val iocell = Module(new GenericDigitalGPIOCell).suggestName(s"iocell_testio_${i}")
      iocell.io.pad <> pin
      iocell.io.o  := false.B
      iocell.io.ie := false.B
      iocell.io.oe := true.B
      iocell
    }

    val modecells = ports.mode.zipWithIndex.map { case (pin, i) =>
      val modecell = Module(new GenericDigitalGPIOCell).suggestName(s"iocell_testmode_${i}")
      modecell.io.pad <> pin
      modecell.io.o  := false.B
      modecell.io.ie := false.B
      modecell.io.oe := true.B
      modecell
    }
    (Nil, iocells ++ modecells)
  }
})

class WithSPIFlashIOCells extends OverrideIOBinder({
  (system: HasPeripherySPIFlashModuleImp) => {
    val (ports: Seq[SPIChipIO], cells2d) = system.qspi.zipWithIndex.map({ case (s, i) =>
      val name = s"spi_${i}"
      val port = IO(new SPIChipIO(s.c.csWidth)).suggestName(name)
      val iocellBase = s"iocell_${name}"

      // SCK and CS are unidirectional outputs
      val sckIOs = IOCell.generateFromSignal(s.sck, port.sck, Some(s"${iocellBase}_sck"), system.p(IOCellKey), IOCell.toAsyncReset)
      val csIOs = IOCell.generateFromSignal(s.cs, port.cs, Some(s"${iocellBase}_cs"), system.p(IOCellKey), IOCell.toAsyncReset)

      // DQ are bidirectional, so then need special treatment
      val dqIOs = s.dq.zip(port.dq).zipWithIndex.map { case ((pin, ana), j) =>
        val iocell = system.p(IOCellKey).gpio().suggestName(s"${iocellBase}_dq_${j}")
        iocell.io.o := pin.o
        iocell.io.oe := pin.oe
        iocell.io.ie := true.B
        pin.i := iocell.io.i
        iocell.io.pad <> ana
        iocell
      }

      (port, dqIOs ++ csIOs ++ sckIOs)
    }).unzip
    (ports, cells2d.flatten)
  }
})

// Class to support the instantiation of a SDIO/MMC capable interface
// Generated based on WithSPIFlashIOCells and WithSPIIOPassThrough from VCU118 implementation
class WithSPIIOCells extends OverrideLazyIOBinder({
  (system: HasPeripherySPI) => {
    
    // attach resource to 1st SPI
    ResourceBinding {
      Resource(new MMCDevice(system.tlSpiNodes.head.device, 1), "reg").bind(ResourceAddress(0))
    }

    InModuleBody {system.asInstanceOf[BaseSubsystem].module match { case system: HasPeripherySPIModuleImp => {
      val (ports: Seq[SPIChipIO], cells2d) = system.spi.zipWithIndex.map({ case (s, i) =>
        val name = s"spi_${i}"
        val port = IO(new SPIChipIO(s.c.csWidth)).suggestName(name)
        val iocellBase = s"iocell_${name}"

        // SCK and CS are unidirectional outputs
        val sckIOs = IOCell.generateFromSignal(s.sck, port.sck, Some(s"${iocellBase}_sck"), system.p(IOCellKey), IOCell.toAsyncReset)
        val csIOs = IOCell.generateFromSignal(s.cs, port.cs, Some(s"${iocellBase}_cs"), system.p(IOCellKey), IOCell.toAsyncReset)

        // DQ are bidirectional, so then need special treatment
        val dqIOs = s.dq.zip(port.dq).zipWithIndex.map { case ((pin, ana), j) =>
          val iocell = system.p(IOCellKey).gpio().suggestName(s"${iocellBase}_dq_${j}")
          iocell.io.o := pin.o
          iocell.io.oe := pin.oe
          iocell.io.ie := true.B
          pin.i := iocell.io.i
          iocell.io.pad <> ana
          iocell
        } // val dqIOs
        
          (port, dqIOs ++ csIOs ++ sckIOs)
      }).unzip // system.spi.zipWithIndex.map
      
      (ports, cells2d.flatten)

    }}} // InModuleBody 
  }  // system: HasPeripherySPI
}) // WithSPIIOCells

// Class to support GPIO Instantiation for the SPI Interface
class SPIChipGPIO(val csWidth: Int = 1) extends Bundle {
  val sck   = Analog(1.W)
  val cs    = Vec(csWidth, Analog(1.W))
  val dq    = Vec(4, Analog(1.W)) // Not using Analog(4.W) because we can't connect these to IO cells
}

// Class to support the instantiation of a SDIO/MMC capable interface
// Generated based on WithSPIFlashIOCells and WithSPIIOPassThrough from VCU118 implementation
// This variant forces the instantiation of GPIO cells for ALL pins
class WithSPIGPIOCells extends OverrideLazyIOBinder({
  (system: HasPeripherySPI) => {
    
    // attach resource to 1st SPI
    ResourceBinding {
      Resource(new MMCDevice(system.tlSpiNodes.head.device, 1), "reg").bind(ResourceAddress(0))
    }

    InModuleBody {system.asInstanceOf[BaseSubsystem].module match { case system: HasPeripherySPIModuleImp => {
      val (ports: Seq[SPIChipIO], cells2d) = system.spi.zipWithIndex.map({ case (s, i) =>
        val name = s"spi_${i}"
        val port = IO(new SPIChipGPIO(s.c.csWidth)).suggestName(name)
        val iocellBase = s"iocell_${name}"

        // CS is unidirectional, but is being mapped to a GPIO Cell
        val sckIOs = {
          val iocell = system.p(IOCellKey).gpio().suggestName(s"${iocellBase}_sck")
          iocell.io.o := s.sck
          iocell.io.oe := true.B
          iocell.io.ie := false.B
          iocell.io.pad <> port.sck
          Seq(iocell)
        }

        // CS is unidirectional, but is being mapped to a GPIO Cell
        val csIOs = s.cs.zip(port.cs).zipWithIndex.map { case ((pin, ana), j) =>
          val iocell = system.p(IOCellKey).gpio().suggestName(s"${iocellBase}_cs_${j}")
          iocell.io.o := pin
          iocell.io.oe := true.B
          iocell.io.ie := false.B
          iocell.io.pad <> ana
          iocell
        }

        // DQ are bidirectional, so then need special treatment
        val dqIOs = s.dq.zip(port.dq).zipWithIndex.map { case ((pin, ana), j) =>
          val iocell = system.p(IOCellKey).gpio().suggestName(s"${iocellBase}_dq_${j}")
          iocell.io.o := pin.o
          iocell.io.oe := pin.oe
          iocell.io.ie := true.B
          pin.i := iocell.io.i
          iocell.io.pad <> ana
          iocell
        } // val dqIOs
        
          (port, dqIOs ++ csIOs ++ sckIOs)
      }).unzip // system.spi.zipWithIndex.map
      
      (ports, cells2d.flatten)

    }}} // InModuleBody 
  }  // system: HasPeripherySPI
}) // WithSPIIOCells

class WithExtInterruptIOCells extends OverrideIOBinder({
  (system: HasExtInterruptsModuleImp) => {
    if (system.outer.nExtInterrupts > 0) {
      val (port: UInt, cells) = IOCell.generateIOFromSignal(system.interrupts, "ext_interrupts", system.p(IOCellKey), abstractResetAsAsync = true)
      (Seq(port), cells)
    } else {
      (Nil, Nil)
    }
  }
})

// Rocketchip's JTAGIO exposes the oe signal, which doesn't go off-chip
class JTAGChipIO extends Bundle {
  val TCK = Input(Clock())
  val TMS = Input(Bool())
  val TDI = Input(Bool())
  val TDO = Output(Bool())
}

class WithDebugIOCells extends OverrideLazyIOBinder({
  (system: HasPeripheryDebug) => {
    implicit val p = GetSystemParameters(system)
    val tlbus = system.asInstanceOf[BaseSubsystem].locateTLBusWrapper(p(ExportDebug).slaveWhere)
    val clockSinkNode = system.debugOpt.map(_ => ClockSinkNode(Seq(ClockSinkParameters())))
    clockSinkNode.map(_ := tlbus.fixedClockNode)
    def clockBundle = clockSinkNode.get.in.head._1


    InModuleBody { system.asInstanceOf[BaseSubsystem].module match { case system: HasPeripheryDebugModuleImp => {
      system.debug.map({ debug =>
        // We never use the PSDIO, so tie it off on-chip
        system.psd.psd.foreach { _ <> 0.U.asTypeOf(new PSDTestMode) }
        system.resetctrl.map { rcio => rcio.hartIsInReset.map { _ := clockBundle.reset.asBool } }
        system.debug.map { d =>
          // Tie off extTrigger
          d.extTrigger.foreach { t =>
            t.in.req := false.B
            t.out.ack := t.out.req
          }
          // Tie off disableDebug
          d.disableDebug.foreach { d => d := false.B }
          // Drive JTAG on-chip IOs
          d.systemjtag.map { j =>
            j.reset := ResetCatchAndSync(j.jtag.TCK, clockBundle.reset.asBool)
            j.mfr_id := p(JtagDTMKey).idcodeManufId.U(11.W)
            j.part_number := p(JtagDTMKey).idcodePartNum.U(16.W)
            j.version := p(JtagDTMKey).idcodeVersion.U(4.W)
          }
        }
        Debug.connectDebugClockAndReset(Some(debug), clockBundle.clock)

        // Add IOCells for the DMI/JTAG/APB ports
        val dmiTuple = debug.clockeddmi.map { d =>
          IOCell.generateIOFromSignal(d, "dmi", p(IOCellKey), abstractResetAsAsync = true)
        }

        val jtagTuple = debug.systemjtag.map { j =>
          val jtag_wire = Wire(new JTAGChipIO)
          j.jtag.TCK := jtag_wire.TCK
          j.jtag.TMS := jtag_wire.TMS
          j.jtag.TDI := jtag_wire.TDI
          jtag_wire.TDO := j.jtag.TDO.data
          IOCell.generateIOFromSignal(jtag_wire, "jtag", p(IOCellKey), abstractResetAsAsync = true)
        }

        val apbTuple = debug.apb.map { a =>
          IOCell.generateIOFromSignal(a, "apb", p(IOCellKey), abstractResetAsAsync = true)
        }

        val allTuples = (dmiTuple ++ jtagTuple ++ apbTuple).toSeq
        (allTuples.map(_._1).toSeq, allTuples.flatMap(_._2).toSeq)
      }).getOrElse((Nil, Nil))
    }}}
  }
})

class WithSerialTLIOCells extends OverrideIOBinder({
  (system: CanHavePeripheryTLSerial) => system.serial_tl.map({ s =>
    val sys = system.asInstanceOf[BaseSubsystem]
    val (port, cells) = IOCell.generateIOFromSignal(s.getWrappedValue, "serial_tl", sys.p(IOCellKey), abstractResetAsAsync = true)
    (Seq(port), cells)
  }).getOrElse((Nil, Nil))
})

class WithAXI4MemPunchthrough extends OverrideLazyIOBinder({
  (system: CanHaveMasterAXI4MemPort) => {
    implicit val p: Parameters = GetSystemParameters(system)
    val clockSinkNode = p(ExtMem).map(_ => ClockSinkNode(Seq(ClockSinkParameters())))
    clockSinkNode.map(_ := system.asInstanceOf[HasTileLinkLocations].locateTLBusWrapper(MBUS).fixedClockNode)
    def clockBundle = clockSinkNode.get.in.head._1

    InModuleBody {
      val ports: Seq[ClockedAndResetIO[AXI4Bundle]] = system.mem_axi4.zipWithIndex.map({ case (m, i) =>
        val p = IO(new ClockedAndResetIO(DataMirror.internal.chiselTypeClone[AXI4Bundle](m))).suggestName(s"axi4_mem_${i}")
        p.bits <> m
        p.clock := clockBundle.clock
        p.reset := clockBundle.reset
        p
      })
      (ports, Nil)
    }
  }
})

class WithAXI4MMIOPunchthrough extends OverrideLazyIOBinder({
  (system: CanHaveMasterAXI4MMIOPort) => {
    implicit val p: Parameters = GetSystemParameters(system)
    val clockSinkNode = p(ExtBus).map(_ => ClockSinkNode(Seq(ClockSinkParameters())))
    clockSinkNode.map(_ := system.asInstanceOf[HasTileLinkLocations].locateTLBusWrapper(MBUS).fixedClockNode)
    def clockBundle = clockSinkNode.get.in.head._1

    InModuleBody {
      val ports: Seq[ClockedAndResetIO[AXI4Bundle]] = system.mmio_axi4.zipWithIndex.map({ case (m, i) =>
        val p = IO(new ClockedAndResetIO(DataMirror.internal.chiselTypeClone[AXI4Bundle](m))).suggestName(s"axi4_mmio_${i}")
        p.bits <> m
        p.clock := clockBundle.clock
        p.reset := clockBundle.reset
        p
      })
      (ports, Nil)
    }
  }
})

class WithL2FBusAXI4Punchthrough extends OverrideLazyIOBinder({
  (system: CanHaveSlaveAXI4Port) => {
    implicit val p: Parameters = GetSystemParameters(system)
    val clockSinkNode = p(ExtIn).map(_ => ClockSinkNode(Seq(ClockSinkParameters())))
    clockSinkNode.map(_ := system.asInstanceOf[BaseSubsystem].fbus.fixedClockNode)
    def clockBundle = clockSinkNode.get.in.head._1

    InModuleBody {
      val ports: Seq[ClockedIO[AXI4Bundle]] = system.l2_frontend_bus_axi4.zipWithIndex.map({ case (m, i) =>
        val p = IO(new ClockedIO(Flipped(DataMirror.internal.chiselTypeClone[AXI4Bundle](m)))).suggestName(s"axi4_fbus_${i}")
        m <> p.bits
        p.clock := clockBundle.clock
        p
      })
      (ports, Nil)
    }
  }
})

class WithBlockDeviceIOPunchthrough extends OverrideIOBinder({
  (system: CanHavePeripheryBlockDevice) => {
    val ports: Seq[ClockedIO[BlockDeviceIO]] = system.bdev.map({ bdev =>
      val p = IO(new ClockedIO(new BlockDeviceIO()(GetSystemParameters(system)))).suggestName("blockdev")
      p <> bdev
      p
    }).toSeq
    (ports, Nil)
  }
})

class WithNICIOPunchthrough extends OverrideIOBinder({
  (system: CanHavePeripheryIceNIC) => {
    val ports: Seq[ClockedIO[NICIOvonly]] = system.icenicOpt.map({ n =>
      val p = IO(new ClockedIO(new NICIOvonly)).suggestName("nic")
      p <> n
      p
    }).toSeq
    (ports, Nil)
  }
})

class WithTraceGenSuccessPunchthrough extends OverrideIOBinder({
  (system: TraceGenSystemModuleImp) => {
    val success: Bool = IO(Output(Bool())).suggestName("success")
    success := system.success
    (Seq(success), Nil)
  }
})

class WithTraceIOPunchthrough extends OverrideIOBinder({
  (system: CanHaveTraceIOModuleImp) => {
    val ports: Option[TraceOutputTop] = system.traceIO.map { t =>
      val trace = IO(DataMirror.internal.chiselTypeClone[TraceOutputTop](t)).suggestName("trace")
      trace <> t
      trace
    }
    (ports.toSeq, Nil)
  }
})

class WithCustomBootPin extends OverrideIOBinder({
  (system: CanHavePeripheryCustomBootPin) => system.custom_boot_pin.map({ p =>
    val sys = system.asInstanceOf[BaseSubsystem]
    val (port, cells) = IOCell.generateIOFromSignal(p.getWrappedValue, "custom_boot", sys.p(IOCellKey), abstractResetAsAsync = true)
    (Seq(port), cells)
  }).getOrElse((Nil, Nil))
})

class WithDontTouchPorts extends OverrideIOBinder({
  (system: DontTouch) => system.dontTouchPorts(); (Nil, Nil)
})



