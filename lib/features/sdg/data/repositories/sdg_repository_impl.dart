/// Provides an implementation of the [SdgRepository] interface.
///
/// This repository is responsible for fetching and mapping SDG (Sustainable Development Goal)
/// data from a local data source. It includes caching for base SDG data to optimize performance.
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/sdg_detail_entity.dart';
import '../../domain/entities/sdg_list_item_entity.dart';
import '../../domain/repositories/sdg_repository.dart';
import '../datasources/sdg_local_datasource.dart';
import '../models/sdg_data_model.dart';

/// Implements the [SdgRepository] for fetching SDG data.
///
/// It uses a [SdgLocalDataSource] to retrieve data and maps it to
/// domain-specific entities. It also caches the base SDG data to avoid
/// redundant fetching.
class SdgRepositoryImpl implements SdgRepository {
  /// The local data source for SDG data.
  final SdgLocalDataSource localDataSource;

  /// Cache for the base SDG data to avoid repeated fetching from the data source.
  List<SdgDataModel>? _cachedSdgBaseData;

  /// Creates an instance of [SdgRepositoryImpl].
  ///
  /// Requires a [SdgLocalDataSource] to fetch data.
  SdgRepositoryImpl({required this.localDataSource});

  /// Helper method to ensure that the base data is loaded and cached.
  ///
  /// If the data is not already cached, it fetches it from the [localDataSource].
  Future<List<SdgDataModel>> _getOrFetchBaseData() async {
    _cachedSdgBaseData ??= await localDataSource.getAllSdgBaseData();
    return _cachedSdgBaseData!; // Non-null assertion, as it has just been set.
  }

  /// Maps an [SdgDataModel] to an [SdgListItemEntity].
  SdgListItemEntity _mapModelToListItemEntity(SdgDataModel model) {
    return SdgListItemEntity(
      id: model.id,
      title: model.title,
      listImageAssetPath: model.listImageAssetPath,
    );
  }

  /// Maps an [SdgDataModel] and additional text content to an [SdgDetailEntity].
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
      return null; // Signal an error.
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
      final SdgDataModel targetModel = baseDataModels.firstWhere(
              (model) => model.id == sdgId,
          orElse: () {
            // Explicitly return null if not found, instead of throwing an error
            // which would then land in the generic catch block.
            // This allows the provider to handle "not found" more specifically.
            AppLogger.warning("SdgRepositoryImpl: SDG with ID '$sdgId' not found in base data");
            return null as SdgDataModel; // Cast to satisfy the orElse type.
          }
      );

      // If targetModel is null (because it wasn't found), return null immediately.
      // This check is necessary because the orElse block now returns null SdgDataModel.
      // ignore: unnecessary_null_comparison
      if (targetModel == null) {
        return null;
      }

      // Load the specific text content for this SDG.
      final textContent = await localDataSource.getSdgTextContent(targetModel.textAssetPath);

      return _mapModelToDetailEntity(targetModel, textContent);
    } catch (e) {
      AppLogger.error("SdgRepositoryImpl: Error in getSdgDetailById for '$sdgId'", e);
      return null;
    }
  }
}
