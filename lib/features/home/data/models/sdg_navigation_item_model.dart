import 'package:flutter/foundation.dart' show immutable;

@immutable
class SdgNavigationItemModel {
  final String goalId;
  final String title;
  final String imageAssetPath;

  const SdgNavigationItemModel({
    required this.goalId,
    required this.title,
    required this.imageAssetPath,
  });

  factory SdgNavigationItemModel.fromJson(Map<String, dynamic> json) {
    return SdgNavigationItemModel(
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      imageAssetPath: json['imageAssetPath'] as String,
    );
  }
}