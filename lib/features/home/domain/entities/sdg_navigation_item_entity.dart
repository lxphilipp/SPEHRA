import 'package:flutter/foundation.dart' show immutable;

@immutable
class SdgNavigationItemEntity {
  final String goalId; // z.B. "goal1", "goal2"
  final String title;  // z.B. "No Poverty"
  final String imageAssetPath;

  const SdgNavigationItemEntity({
    required this.goalId,
    required this.title,
    required this.imageAssetPath,
    // this.routeName,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SdgNavigationItemEntity &&
        other.goalId == goalId &&
        other.title == title &&
        other.imageAssetPath == imageAssetPath;
    // && other.routeName == routeName;
  }

  @override
  int get hashCode =>
      goalId.hashCode ^
      title.hashCode ^
      imageAssetPath.hashCode;
// ^ routeName.hashCode;
}