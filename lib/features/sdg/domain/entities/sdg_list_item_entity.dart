import 'package:flutter/foundation.dart' show immutable;

@immutable
class SdgListItemEntity {
  final String id; // z.B. "goal1"
  final String title; // z.B. "No Poverty"
  final String listImageAssetPath; // Pfad zum Icon/kleinen Bild für die Liste (z.B. aus 'assets/icons/17_SDG_Icons/')

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