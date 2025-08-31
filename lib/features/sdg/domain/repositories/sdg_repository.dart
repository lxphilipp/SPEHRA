import '../entities/sdg_detail_entity.dart';
import '../entities/sdg_list_item_entity.dart';

/// Abstract interface for a repository that handles Sustainable Development Goal (SDG) data.
///
/// This repository provides methods to fetch lists of SDGs for overview purposes
/// and detailed information for specific SDGs.
abstract class SdgRepository {
  /// Loads a list of all SDGs for an overview or list view.
  ///
  /// Returns a list of [SdgListItemEntity] on success, or `null` if an error occurs.
  Future<List<SdgListItemEntity>?> getAllSdgListItems();

  /// Loads detailed information for a specific SDG based on its ID.
  ///
  /// Returns an [SdgDetailEntity] on success, or `null` if the SDG is not found
  /// or an error occurs.
  ///
  /// [sdgId]: The unique identifier of the SDG to retrieve.
  Future<SdgDetailEntity?> getSdgDetailById(String sdgId);
}