import '../entities/intro_page_entity.dart';

/// Das Repository-Interface definiert den Vertrag für die Introduction-Daten.
///
/// Die Domain-Schicht (UseCases) wird nur dieses Interface verwenden,
/// ohne zu wissen, wie oder woher die Daten tatsächlich kommen (ob aus einer
/// lokalen JSON-Datei, einer API oder einer Datenbank).
abstract class IntroRepository {

  /// Ruft eine Liste von [IntroPageEntity] ab, die alle Seiten der
  /// Einführungssequenz repräsentieren.
  ///
  /// Gibt eine `Future<List<IntroPageEntity>>` zurück.
  /// Kann eine Exception werfen, wenn das Laden der Daten fehlschlägt.
  Future<List<IntroPageEntity>> getIntroPages();

}