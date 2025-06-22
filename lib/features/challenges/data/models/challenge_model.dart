import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable, listEquals;

import '../../../../core/utils/app_logger.dart'; // Für @immutable und listEquals

@immutable // Markiert die Klasse als unveränderlich
class ChallengeModel {
  final String? id; // Nullable, da es von Firestore beim Erstellen zugewiesen wird
  final String title;
  final String description;
  final String task;
  final int points;
  final List<String> categories; // Liste von SDG-Goal-Keys (z.B. ["goal1", "goal5"])
  final String difficulty;     // z.B. "Easy", "Normal", "Advanced" - könnte später ein Enum werden
  final Timestamp? createdAt;  // Firestore Timestamp, nullable falls noch nicht gesetzt
  // final String? createdByUserId; // Optional: Wer hat die Challenge erstellt?

  const ChallengeModel({
    this.id,
    required this.title,
    required this.description,
    required this.task,
    required this.points,
    required this.categories,
    required this.difficulty,
    this.createdAt,
    // this.createdByUserId,
  });

  // Factory-Konstruktor, um ein ChallengeModel aus einem Firestore DocumentSnapshot zu erstellen
  factory ChallengeModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?; // Sicherer Cast zu Map oder null
    
    AppLogger.debug("ChallengeModel.fromSnapshot: Processing ${snapshot.id}");
    AppLogger.debug("ChallengeModel.fromSnapshot: Raw data: $data");

    if (data == null) {
      AppLogger.warning("ChallengeModel.fromSnapshot: Document ${snapshot.id} has no data");
      throw Exception("Document ${snapshot.id} has no data");
    }

    // Validate required fields
    final title = data['title'] as String?;
    final description = data['description'] as String?;
    final task = data['task'] as String?;
    final points = data['points'];
    final categories = data['category']; // Note: using 'category' field name from Firestore
    final difficulty = data['difficulty'] as String?;

    AppLogger.debug("ChallengeModel.fromSnapshot: title=$title, points=$points, categories=$categories");

    // Fallback-Werte für den Fall, dass Felder fehlen oder null sind
    return ChallengeModel(
      id: snapshot.id,
      title: title ?? '', // Fallback auf leeren String
      description: description ?? '',
      task: task ?? '',
      points: (points is int) ? points : (points is double) ? points.toInt() : 0, // Handle both int and double
      categories: categories != null ? List<String>.from(categories) : [], // Fallback auf leere Liste
      difficulty: difficulty ?? 'Easy', // Fallback auf 'Easy'
      createdAt: data['createdAt'] as Timestamp?,
      // createdByUserId: data['createdByUserId'] as String?,
    );
  }

  // Methode, um das ChallengeModel in eine Map für Firestore zu konvertieren
  Map<String, dynamic> toMap() {
    return {
      // 'id' wird nicht in die Map geschrieben, da es die Dokumenten-ID ist und von Firestore verwaltet wird
      'title': title,
      'description': description,
      'task': task,
      'points': points,
      'category': categories, // Firestore kann Listen direkt speichern
      'difficulty': difficulty,
      // Wenn createdAt null ist (beim Erstellen eines neuen Dokuments),
      // wird FieldValue.serverTimestamp() verwendet, damit Firestore den Zeitstempel setzt.
      // Wenn es bereits einen Wert hat (beim Aktualisieren), wird dieser Wert verwendet.
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      // if (createdByUserId != null) 'createdByUserId': createdByUserId,
    };
  }

  // copyWith Methode für einfache Objektaktualisierung
  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? task,
    int? points,
    List<String>? categories,
    String? difficulty,
    Timestamp? createdAt,
    // String? createdByUserId,
    bool clearCreatedAt = false, // Flag um createdAt explizit auf null zu setzen (für serverTimestamp)
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      task: task ?? this.task,
      points: points ?? this.points,
      categories: categories ?? this.categories,
      difficulty: difficulty ?? this.difficulty,
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      // createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }

  // Gleichheitsoperator für Vergleiche
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.task == task &&
        other.points == points &&
        listEquals(other.categories, categories) && // Wichtig für Listenvergleich
        other.difficulty == difficulty &&
        other.createdAt == createdAt;
    // && other.createdByUserId == createdByUserId;
  }

  // hashCode für Nutzung in Sets und Maps
  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    task,
    points,
    Object.hashAll(categories), // Korrekter Hash für Listen
    difficulty,
    createdAt,
    // createdByUserId,
  );

  @override
  String toString() {
    return 'ChallengeModel(id: $id, title: $title, points: $points, difficulty: $difficulty, categories: $categories, createdAt: $createdAt)';
  }
}