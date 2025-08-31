import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/utils/app_logger.dart';
import '../models/sdg_navigation_item_model.dart';

/// Abstract class for local data source related to home features.
///
/// This class defines the contract for fetching SDG (Sustainable Development Goals)
/// navigation items from a local data source.
abstract class HomeLocalDataSource {
  /// Fetches a list of SDG navigation items.
  ///
  /// Returns a [Future] that completes with a list of [SdgNavigationItemModel].
  /// Throws an [Exception] if an error occurs during fetching.
  Future<List<SdgNavigationItemModel>> getSdgNavigationItems();
}

/// Implementation of [HomeLocalDataSource] that fetches data from a local JSON asset.
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  /// The path to the JSON asset file containing SDG navigation items.
  final String _sdgAssetPath = 'assets/data/sdg_navigation_items.json';

  /// Fetches a list of SDG navigation items from the local JSON asset.
  ///
  /// This method reads the JSON file specified by [_sdgAssetPath],
  /// decodes the JSON string, and maps the data to a list of
  /// [SdgNavigationItemModel] objects.
  ///
  /// Returns a [Future] that completes with a list of [SdgNavigationItemModel].
  /// Throws an [Exception] if the file cannot be read or the data cannot be parsed.
  @override
  Future<List<SdgNavigationItemModel>> getSdgNavigationItems() async {
    try {
      final String response = await rootBundle.loadString(_sdgAssetPath);
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      return data
          .map((jsonItem) => SdgNavigationItemModel.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('HomeLocalDataSourceImpl: Error loading SDG navigation items', e);
      throw Exception('Failed to load SDG navigation items from asset: $e');
    }
  }
}
