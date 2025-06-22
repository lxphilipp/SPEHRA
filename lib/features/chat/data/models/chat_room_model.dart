import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> members;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt; // Sollte beim Erstellen nie null sein

  // --- NEUE FELDER ---
  final List<String> hiddenFor;
  final Map<String, dynamic> clearedAt; // In Firestore speichern wir Timestamps (dynamic)

  const ChatRoomModel({
    required this.id,
    required this.members,
    this.lastMessage,
    this.lastMessageTime,
    required this.createdAt,
    this.hiddenFor = const [],
    this.clearedAt = const {},
  });

  /// Erstellt ein ChatRoomModel aus einem Firestore-Dokument.
  /// Erwartet, dass Zeitstempel als Firestore-Timestamp gespeichert sind.
  factory ChatRoomModel.fromJson(Map<String, dynamic> json, String docId) {
    return ChatRoomModel(
      id: docId,
      members: List<String>.from(json['members'] ?? []),
      lastMessage: json['last_message'] as String?,
      lastMessageTime: (json['last_message_time'] as Timestamp?)?.toDate(),
      // Wenn 'created_at' aus irgendeinem Grund fehlt, nehmen wir die aktuelle Zeit als Fallback,
      // aber eine Warnung wäre hier gut. In der Regel sollte es immer da sein.
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),

      // --- NEUE FELDER AUS JSON LESEN ---
      // 'hidden_for' ist der korrekte snake_case Name aus Firestore
      hiddenFor: List<String>.from(json['hidden_for'] ?? []),
      // 'cleared_at' ist der korrekte snake_case Name aus Firestore
      clearedAt: json['cleared_at'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Erstellt eine Map zum Speichern eines neuen Chatraums in Firestore.
  Map<String, dynamic> toJsonForCreate() {
    return {
      'members': members,
      'created_at': FieldValue.serverTimestamp(),
      'last_message': lastMessage, // Kann anfangs null sein
      'last_message_time': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : (lastMessage != null ? FieldValue.serverTimestamp() : null),

      // --- NEUE FELDER BEIM ERSTELLEN INITIALISIEREN ---
      'hidden_for': [], // Startet als leere Liste
      'cleared_at': {},   // Startet als leere Map
    };
  }

  // Diese Methode ist für Updates nützlich, aber wir verwenden sie gerade nicht direkt.
  // Es ist besser, Updates gezielt mit den richtigen Feldern durchzuführen.
  // Map<String, dynamic> toJsonForUpdate() {
  //   return {
  //     'last_message': lastMessage,
  //     'last_message_time': FieldValue.serverTimestamp(),
  //   };
  // }

  /// Nützliche Helfer-Methode zum Kopieren und Ändern von Instanzen.
  ChatRoomModel copyWith({
    String? id,
    List<String>? members,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    List<String>? hiddenFor,
    Map<String, dynamic>? clearedAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      hiddenFor: hiddenFor ?? this.hiddenFor,
      clearedAt: clearedAt ?? this.clearedAt,
    );
  }
}