import '../entities/sdg_detail_entity.dart';
import '../entities/sdg_list_item_entity.dart';

abstract class SdgRepository {
  /// Lädt eine Liste aller SDGs für die Übersichts-/Listenansicht.
  /// Gibt eine Liste von [SdgListItemEntity] bei Erfolg zurück, oder `null` bei einem Fehler.
  Future<List<SdgListItemEntity>?> getAllSdgListItems();

  /// Lädt die detaillierten Informationen für ein spezifisches SDG anhand seiner ID.
  /// Gibt [SdgDetailEntity] bei Erfolg zurück, oder `null` wenn nicht gefunden oder ein Fehler auftritt.
  Future<SdgDetailEntity?> getSdgDetailById(String sdgId);
}