// See LICENSE

package chipyard.stage.phases

import chisel3.RawModule
import chisel3.stage.ChiselGeneratorAnnotation
import firrtl.AnnotationSeq
import firrtl.options.Viewer.view
import firrtl.options.{Dependency, Phase, PreservesAll, StageOptions}
import org.chipsalliance.cde.config.{Field, Parameters}
import freechips.rocketchip.diplomacy._
import chipyard.stage._

case object TargetDirKey extends Field[String](".")

/** Constructs a generator function that returns a top module with given config parameters */
class PreElaboration extends Phase with PreservesAll[Phase] with HasChipyardStageUtils {

  override val prerequisites = Seq(Dependency[Checks])
  override val dependents = Seq(Dependency[chisel3.stage.phases.Elaborate])

  override def transform(annotations: AnnotationSeq): AnnotationSeq = {

    val stageOpts = view[StageOptions](annotations)
    val rOpts = view[ChipyardOptions](annotations)
    val topMod = rOpts.topModule.get

    val config = getConfig(rOpts.configNames.get).alterPartial {
      case TargetDirKey => stageOpts.targetDir
    }

    val gen = () =>
      topMod
        .getConstructor(classOf[Parameters])
        .newInstance(config) match {
          case a: RawModule => a
          case a: LazyModule => LazyModule(a).module
        }

    ChiselGeneratorAnnotation(gen) +: annotations
  }

}
