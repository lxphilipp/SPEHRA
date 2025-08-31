import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Represents the detailed information for a Sustainable Development Goal (SDG).
@immutable
class SdgDetailEntity {
  /// Unique identifier, e.g., "goal1", "goal2", ...
  final String id;

  /// The official title of the SDG, e.g., "No Poverty".
  final String title;

  /// Path to the large image of the SDG (e.g., from 'assets/icons/sdg_named/').
  final String imageAssetPath;

  /// Key points of the description as individual strings.
  final List<String> descriptionPoints;

  /// List of URLs to further information.
  final List<String> externalLinks;

  /// The detailed text content (from the old SDG_X.txt files).
  final String? mainTextContent;

  /// Creates an instance of [SdgDetailEntity].
  const SdgDetailEntity({
    required this.id,
    required this.title,
    required this.imageAssetPath,
    required this.descriptionPoints,
    required this.externalLinks,
    this.mainTextContent,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SdgDetailEntity &&
        other.id == id &&
        other.title == title &&
        other.imageAssetPath == imageAssetPath &&
        listEquals(other.descriptionPoints, descriptionPoints) &&
        listEquals(other.externalLinks, externalLinks) &&
        other.mainTextContent == mainTextContent;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    imageAssetPath,
    Object.hashAll(descriptionPoints), // Correct hash code generation for lists
    Object.hashAll(externalLinks),   // Correct hash code generation for lists
    mainTextContent,
  );

  /// Creates a copy of this [SdgDetailEntity] but with the given fields
  /// replaced with the new values.
  SdgDetailEntity copyWith({
    String? id,
    String? title,
    String? imageAssetPath,
    List<String>? descriptionPoints,
    List<String>? externalLinks,
    String? mainTextContent,
    bool clearMainTextContent = false,
  }) {
    return SdgDetailEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      descriptionPoints: descriptionPoints ?? this.descriptionPoints,
      externalLinks: externalLinks ?? this.externalLinks,
      mainTextContent: clearMainTextContent ? null : (mainTextContent ?? this.mainTextContent),
    );
  }

  @override
  String toString() {
    return 'SdgDetailEntity(id: $id, title: $title)';
  }
}
