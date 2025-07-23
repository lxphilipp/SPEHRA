import 'package:flutter/foundation.dart' show immutable;

@immutable
class SdgNavigationItemEntity {
  final String goalId;
  final String title;
  final String imageAssetPath;

  const SdgNavigationItemEntity({
    required this.goalId,
    required this.title,
    required this.imageAssetPath,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SdgNavigationItemEntity &&
        other.goalId == goalId &&
        other.title == title &&
        other.imageAssetPath == imageAssetPath;
  }

  @override
  int get hashCode =>
      goalId.hashCode ^
      title.hashCode ^
      imageAssetPath.hashCode;
}