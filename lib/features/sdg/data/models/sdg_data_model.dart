import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Represents the data model for a Sustainable Development Goal (SDG).
///
/// This class is immutable and holds all the necessary information
/// to display an SDG, including its identifiers, textual descriptions,
/// asset paths for images, and relevant external links.
@immutable
class SdgDataModel {
  /// The unique identifier for the SDG (e.g., "goal1").
  final String id;

  /// The title of the SDG (e.g., "No Poverty").
  final String title;

  /// The asset path for the SDG icon used in lists (e.g., 'assets/icons/17_SDG_Icons/1.png').
  final String listImageAssetPath;

  /// The asset path for the large image used on the SDG detail page (e.g., 'assets/icons/sdg_named/1.jpg').
  final String detailImageAssetPath;

  /// A list of key points describing the SDG.
  final List<String> descriptionPoints;

  /// A list of URLs to external resources for more information about the SDG.
  final List<String> externalLinks;

  /// The asset path to the text file containing detailed information about the SDG (e.g., 'assets/texts/SDG_1.txt').
  final String textAssetPath;

  /// Creates an instance of [SdgDataModel].
  ///
  /// All parameters are required.
  const SdgDataModel({
    required this.id,
    required this.title,
    required this.listImageAssetPath,
    required this.detailImageAssetPath,
    required this.descriptionPoints,
    required this.externalLinks,
    required this.textAssetPath,
  });

  /// Creates an [SdgDataModel] instance from a JSON map.
  ///
  /// Provides default values for fields if they are missing in the JSON map
  /// to prevent runtime errors.
  factory SdgDataModel.fromJson(Map<String, dynamic> json) {
    return SdgDataModel(
      id: json['id'] as String? ?? '', // Fallback if 'id' is missing
      title: json['title'] as String? ?? 'Unknown SDG',
      listImageAssetPath: json['listImageAssetPath'] as String? ?? '',
      detailImageAssetPath: json['detailImageAssetPath'] as String? ?? '',
      descriptionPoints: List<String>.from(json['descriptionPoints'] ?? []),
      externalLinks: List<String>.from(json['externalLinks'] ?? []),
      textAssetPath: json['textAssetPath'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SdgDataModel &&
        other.id == id &&
        other.title == title &&
        other.listImageAssetPath == listImageAssetPath &&
        other.detailImageAssetPath == detailImageAssetPath &&
        listEquals(other.descriptionPoints, descriptionPoints) &&
        listEquals(other.externalLinks, externalLinks) &&
        other.textAssetPath == textAssetPath;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    listImageAssetPath,
    detailImageAssetPath,
    Object.hashAll(descriptionPoints),
    Object.hashAll(externalLinks),
    textAssetPath,
  );
}
