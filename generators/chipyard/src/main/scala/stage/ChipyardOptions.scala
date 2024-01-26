// See LICENSE

package chipyard.stage

class ChipyardOptions private[stage] (
                                         val topModule:         Option[Class[_ <: Any]] = None,
                                         val configNames:       Option[Seq[String]] = None,
                                         val outputBaseName:    Option[String] = None) {

  private[stage] def copy(
                           topModule:         Option[Class[_ <: Any]] = topModule,
                           configNames:       Option[Seq[String]] = configNames,
                           outputBaseName:    Option[String] = outputBaseName,
                         ): ChipyardOptions = {

    new ChipyardOptions(
      topModule=topModule,
      configNames=configNames,
      outputBaseName=outputBaseName,
    )
  }

  lazy val topPackage: Option[String] = topModule match {
    case Some(a) => Some(a.getPackage.getName)
    case _ => None
  }

  lazy val configClass: Option[String] = configNames match {
    case Some(names) =>
      val classNames = names.map{ n => n.split('.').last }
      Some(classNames.mkString("_"))
    case _ => None
  }

  lazy val longName: Option[String] = outputBaseName match {
    case Some(name) => Some(name)
    case _ =>
      if (!topPackage.isEmpty && !configClass.isEmpty) Some(s"${topPackage.get}.${configClass.get}") else None
  }
}
