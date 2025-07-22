import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/utils/app_logger.dart';
import '../models/sdg_navigation_item_model.dart';

abstract class HomeLocalDataSource {
  Future<List<SdgNavigationItemModel>> getSdgNavigationItems();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final String _sdgAssetPath = 'assets/data/sdg_navigation_items.json';

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