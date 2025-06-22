// Dieses Modell wird verwendet, wenn du die SDG-Items aus einer JSON-Datei lädst.
// Wenn sie statisch sind, kannst du sie direkt im RepositoryImpl erzeugen
// und dieses Modell ist dann nicht zwingend nötig.
import 'package:flutter/foundation.dart' show immutable;

@immutable
class SdgNavigationItemModel {
  final String goalId;
  final String title;
  final String imageAssetPath;
  // final String routeName;

  const SdgNavigationItemModel({
    required this.goalId,
    required this.title,
    required this.imageAssetPath,
    // this.routeName,
  });

  factory SdgNavigationItemModel.fromJson(Map<String, dynamic> json) {
    return SdgNavigationItemModel(
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      imageAssetPath: json['imageAssetPath'] as String,
      // routeName: json['routeName'] as String?,
    );
  }

// Kein toMap, wenn nur gelesen wird
}