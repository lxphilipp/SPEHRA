import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/intro_page_model.dart';

/// Defines the contract for accessing introduction page data locally.
///
/// This data source is responsible for fetching the models that represent
/// the pages displayed during the application's introduction sequence.
abstract class IntroLocalDataSource {
  /// Retrieves a list of [IntroPageModel] objects.
  ///
  /// These models contain the content for each page of the introduction
  /// sequence (e.g., images, titles, descriptions).
  ///
  /// Returns a [Future] that completes with a list of [IntroPageModel].
  /// Throws an exception if the data cannot be loaded.
  Future<List<IntroPageModel>> getIntroPageModels();
}

/// Concrete implementation of [IntroLocalDataSource].
///
/// This implementation fetches introduction page data from a local JSON asset file.
class IntroLocalDataSourceImpl implements IntroLocalDataSource {
  /// Retrieves a list of [IntroPageModel] objects from 'assets/data/introduction_pages.json'.
  ///
  /// The method loads the JSON string from the asset bundle, decodes it,
  /// and then maps each JSON object to an [IntroPageModel].
  ///
  /// Returns a [Future] that completes with a list of [IntroPageModel].
  /// Throws an exception if the asset is not found or if the JSON is malformed.
  @override
  Future<List<IntroPageModel>> getIntroPageModels() async {
    final jsonString = await rootBundle.loadString('assets/data/introduction_pages.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((jsonItem) => IntroPageModel.fromJson(jsonItem)).toList();
  }
}
