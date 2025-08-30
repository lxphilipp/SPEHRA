import 'package:flutter/foundation.dart' show immutable, listEquals;

@immutable
class SdgDetailEntity {
  final String id; // Eindeutiger Bezeichner, z.B. "goal1", "goal2", ...
  final String title; // Der offizielle Titel des SDG, z.B. "No Poverty"
  final String imageAssetPath; // Pfad zum großen Bild des SDG (z.B. aus 'assets/icons/sdg_named/')
  final List<String> descriptionPoints; // Kernpunkte der Beschreibung als einzelne Strings
  final List<String> externalLinks; // Liste von URLs zu weiterführenden Informationen
  final String? mainTextContent; // Der ausführliche Textinhalt (aus den alten SDG_X.txt Dateien)

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
    Object.hashAll(descriptionPoints), // Korrekter Hash für Listen
    Object.hashAll(externalLinks),   // Korrekter Hash für Listen
    mainTextContent,
  );

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