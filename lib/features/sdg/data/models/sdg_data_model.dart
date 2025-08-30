import 'package:flutter/foundation.dart' show immutable, listEquals;

@immutable
class SdgDataModel {
  final String id;                    // z.B. "goal1"
  final String title;                 // z.B. "No Poverty"
  final String listImageAssetPath;    // Pfad zum Icon für die Liste (z.B. 'assets/icons/17_SDG_Icons/1.png')
  final String detailImageAssetPath;  // Pfad zum großen Bild für die Detailseite (z.B. 'assets/icons/sdg_named/1.jpg')
  final List<String> descriptionPoints; // Kernpunkte der Beschreibung
  final List<String> externalLinks;     // URLs zu weiteren Infos
  final String textAssetPath;         // Pfad zur SDG_X.txt Datei (z.B. 'assets/texts/SDG_1.txt')

  const SdgDataModel({
    required this.id,
    required this.title,
    required this.listImageAssetPath,
    required this.detailImageAssetPath,
    required this.descriptionPoints,
    required this.externalLinks,
    required this.textAssetPath,
  });

  // Factory-Konstruktor, um ein SdgDataModel aus einer JSON-Map zu erstellen
  factory SdgDataModel.fromJson(Map<String, dynamic> json) {
    return SdgDataModel(
      id: json['id'] as String? ?? '', // Fallback, falls 'id' fehlt
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