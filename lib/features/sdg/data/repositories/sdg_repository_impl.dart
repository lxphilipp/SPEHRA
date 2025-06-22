import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/sdg_detail_entity.dart';
import '../../domain/entities/sdg_list_item_entity.dart';
import '../../domain/repositories/sdg_repository.dart';
import '../datasources/sdg_local_datasource.dart';
import '../models/sdg_data_model.dart';

class SdgRepositoryImpl implements SdgRepository {
  final SdgLocalDataSource localDataSource;

  // Optional: Ein einfacher Cache für die Basis-SDG-Daten, um die JSON nicht jedes Mal neu zu parsen.
  List<SdgDataModel>? _cachedSdgBaseData;

  SdgRepositoryImpl({required this.localDataSource});

  // Hilfsmethode, um sicherzustellen, dass die Basis-Daten geladen und gecached sind.
  Future<List<SdgDataModel>> _getOrFetchBaseData() async {
    _cachedSdgBaseData ??= await localDataSource.getAllSdgBaseData();
    return _cachedSdgBaseData!; // Non-null assertion, da es gerade gesetzt wurde
  }

  // Mappt ein SdgDataModel zu einer SdgListItemEntity
  SdgListItemEntity _mapModelToListItemEntity(SdgDataModel model) {
    return SdgListItemEntity(
      id: model.id,
      title: model.title,
      listImageAssetPath: model.listImageAssetPath,
    );
  }

  // Mappt ein SdgDataModel und den zusätzlichen Textinhalt zu einer SdgDetailEntity
  SdgDetailEntity _mapModelToDetailEntity(SdgDataModel model, String? textContent) {
    return SdgDetailEntity(
      id: model.id,
      title: model.title,
      imageAssetPath: model.detailImageAssetPath,
      descriptionPoints: model.descriptionPoints,
      externalLinks: model.externalLinks,
      mainTextContent: textContent,
    );
  }

  @override
  Future<List<SdgListItemEntity>?> getAllSdgListItems() async {
    try {
      final baseDataModels = await _getOrFetchBaseData();
      return baseDataModels.map(_mapModelToListItemEntity).toList();
    } catch (e) {
      AppLogger.error("SdgRepositoryImpl: Error in getAllSdgListItems", e);
      return null; // Fehler signalisieren
    }
  }

  @override
  Future<SdgDetailEntity?> getSdgDetailById(String sdgId) async {
    if (sdgId.isEmpty) {
      AppLogger.warning("SdgRepositoryImpl: sdgId is empty for getSdgDetailById");
      return null;
    }
    try {
      final baseDataModels = await _getOrFetchBaseData();
      // Finde das spezifische SdgDataModel anhand der ID
      final SdgDataModel targetModel = baseDataModels.firstWhere(
              (model) => model.id == sdgId,
          orElse: () {
            // explizit null zurückgeben, wenn nicht gefunden, anstatt Fehler zu werfen
            // der dann als generischer Fehler im catch landen würde.
            // Dies ermöglicht dem Provider, "nicht gefunden" spezifischer zu behandeln.
            AppLogger.warning("SdgRepositoryImpl: SDG with ID '$sdgId' not found in base data");
            return null as SdgDataModel; // Cast, um den Typ des orElse zu erfüllen
          }
      );

      // Lade den spezifischen Textinhalt für dieses SDG
      final textContent = await localDataSource.getSdgTextContent(targetModel.textAssetPath);

      return _mapModelToDetailEntity(targetModel, textContent);
    } catch (e) {
      AppLogger.error("SdgRepositoryImpl: Error in getSdgDetailById for '$sdgId'", e);
      return null; // Allgemeiner Fehler signalisieren
    }
  }
}