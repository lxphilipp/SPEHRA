import 'package:flutter/foundation.dart' show immutable;

/// Represents a single item in the list of Sustainable Development Goals (SDGs).
///
/// This entity is typically used for displaying SDGs in a summary view,
/// such as a list or grid.
@immutable
class SdgListItemEntity {
  /// The unique identifier for the SDG (e.g., "goal1").
  final String id;

  /// The title of the SDG (e.g., "No Poverty").
  final String title;

  /// The asset path to the icon or small image for the SDG list item
  /// (e.g., from 'assets/icons/17_SDG_Icons/').
  final String listImageAssetPath;

  /// Creates an [SdgListItemEntity].
  ///
  /// All parameters are required.
  const SdgListItemEntity({
    required this.id,
    required this.title,
    required this.listImageAssetPath,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SdgListItemEntity &&
        other.id == id &&
        other.title == title &&
        other.listImageAssetPath == listImageAssetPath;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      listImageAssetPath.hashCode;
}