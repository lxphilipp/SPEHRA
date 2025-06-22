import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle; // Für Asset-Zugriff
import '../../../../core/utils/app_logger.dart';
import '../models/sdg_data_model.dart';

abstract class SdgLocalDataSource {
  /// Lädt die Basis-SDG-Daten (ohne den ausführlichen Textinhalt) aus einer JSON-Asset-Datei.
  Future<List<SdgDataModel>> getAllSdgBaseData();

  /// Lädt den spezifischen Textinhalt für ein SDG aus einer .txt-Asset-Datei.
  Future<String> getSdgTextContent(String textAssetPath);
}

class SdgLocalDataSourceImpl implements SdgLocalDataSource {
  // Pfad zu deiner JSON-Datei, die alle SDG-Metadaten enthält
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
      // Wirf eine spezifischere Exception, die das Repository fangen kann
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