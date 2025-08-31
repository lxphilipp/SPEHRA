import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/utils/app_logger.dart';
import '../models/sdg_data_model.dart';

/// Abstract class for fetching SDG (Sustainable Development Goals) data from a local source.
///
/// This class defines the contract for local data sources that provide SDG information.
abstract class SdgLocalDataSource {
  /// Loads the base SDG data (without detailed text content) from a JSON asset file.
  ///
  /// Returns a [Future] that completes with a list of [SdgDataModel].
  /// Throws an [Exception] if loading or parsing fails.
  Future<List<SdgDataModel>> getAllSdgBaseData();

  /// Loads the specific text content for an SDG from a .txt asset file.
  ///
  /// [textAssetPath] is the path to the .txt asset file.
  /// Returns a [Future] that completes with the text content as a [String].
  /// Returns an empty string if [textAssetPath] is empty.
  /// Throws an [Exception] if loading fails.
  Future<String> getSdgTextContent(String textAssetPath);
}

/// Implementation of [SdgLocalDataSource] that fetches SDG data from local asset files.
class SdgLocalDataSourceImpl implements SdgLocalDataSource {
  /// The asset path for the JSON file containing all SDG base data.
  final String _sdgDataAssetPath = 'assets/data/all_sdg_data.json';

  @override
  Future<List<SdgDataModel>> getAllSdgBaseData() async {
    try {
      AppLogger.debug('SdgLocalDataSource: Loading SDG base data from $_sdgDataAssetPath');
      final String response = await rootBundle.loadString(_sdgDataAssetPath);
      final List<dynamic> jsonData = json.decode(response) as List<dynamic>;
      final models = jsonData
          .map((jsonItem) => SdgDataModel.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      AppLogger.info('SdgLocalDataSource: ${models.length} SDG base data loaded successfully');
      return models;
    } catch (e) {
      AppLogger.error('SdgLocalDataSource: Error loading SDG base data', e);
      throw Exception('Failed to load SDG base data from asset: ${e.toString()}');
    }
  }

  @override
  Future<String> getSdgTextContent(String textAssetPath) async {
    if (textAssetPath.isEmpty) {
      AppLogger.warning('SdgLocalDataSource: textAssetPath is empty');
      return '';
    }
    try {
      AppLogger.debug('SdgLocalDataSource: Loading text content from $textAssetPath');
      final content = await rootBundle.loadString(textAssetPath);
      AppLogger.debug('SdgLocalDataSource: Text content from $textAssetPath loaded successfully');
      return content;
    } catch (e) {
      AppLogger.error('SdgLocalDataSource: Error loading text content from $textAssetPath', e);
      throw Exception('Failed to load SDG text content for $textAssetPath: ${e.toString()}');
    }
  }
}