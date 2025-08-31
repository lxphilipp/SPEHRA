import 'package:flutter/foundation.dart' show immutable;

/// Represents a Sustainable Development Goal (SDG) navigation item.
///
/// This model is used to display SDG items in a navigation context,
/// typically showing an image, title, and linking to a specific goal.
@immutable
class SdgNavigationItemModel {
  /// The unique identifier for the SDG.
  final String goalId;

  /// The title of the SDG.
  final String title;

  /// The local asset path for the image representing the SDG.
  final String imageAssetPath;

  /// Creates an instance of [SdgNavigationItemModel].
  ///
  /// All parameters are required.
  const SdgNavigationItemModel({
    required this.goalId,
    required this.title,
    required this.imageAssetPath,
  });

  /// Creates an instance of [SdgNavigationItemModel] from a JSON map.
  ///
  /// This factory constructor is typically used to parse data received from an API.
  ///
  /// Throws a [TypeError] if the `json` map does not contain the expected
  /// keys or if the values are not of the expected types.
  factory SdgNavigationItemModel.fromJson(Map<String, dynamic> json) {
    return SdgNavigationItemModel(
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      imageAssetPath: json['imageAssetPath'] as String,
    );
  }
}