import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> members;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime createdAt;
  final List<String> hiddenFor;
  final Map<String, dynamic> clearedAt;

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
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hiddenFor: List<String>.from(json['hidden_for'] ?? []),
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

      'hidden_for': [],
      'cleared_at': {},
    };
  }


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