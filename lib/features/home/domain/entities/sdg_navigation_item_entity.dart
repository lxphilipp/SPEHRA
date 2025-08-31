import 'package:flutter/foundation.dart' show immutable;

/// Represents a Sustainable Development Goal (SDG) navigation item.
///
/// This entity is used to display SDG items in a navigation context,
/// providing essential information like the goal ID, title, and image asset path.
@immutable
class SdgNavigationItemEntity {
  /// The unique identifier for the SDG goal.
  final String goalId;

  /// The title of the SDG goal.
  final String title;

  /// The path to the image asset representing the SDG goal.
  final String imageAssetPath;

  /// Creates an instance of [SdgNavigationItemEntity].
  ///
  /// All parameters are required.
  const SdgNavigationItemEntity({
    required this.goalId,
    required this.title,
    required this.imageAssetPath,
  });

  /// Compares this [SdgNavigationItemEntity] to another object for equality.
  ///
  /// Returns `true` if the other object is an [SdgNavigationItemEntity]
  /// and all corresponding fields are equal.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SdgNavigationItemEntity &&
        other.goalId == goalId &&
        other.title == title &&
        other.imageAssetPath == imageAssetPath;
  }

  /// Returns the hash code for this [SdgNavigationItemEntity].
  ///
  /// The hash code is based on the [goalId], [title], and [imageAssetPath].
  @override
  int get hashCode =>
      goalId.hashCode ^
      title.hashCode ^
      imageAssetPath.hashCode;
}
