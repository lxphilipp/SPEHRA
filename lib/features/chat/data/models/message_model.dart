import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MessageModel extends Equatable{
  final String id;
  final String toId;
  final String fromId;
  final String msg;
  final String type;
  final DateTime? createdAt;
  final DateTime? readAt;

  const MessageModel({
    required this.id,
    required this.toId,
    required this.fromId,
    required this.msg,
    required this.type,
    this.createdAt,
    this.readAt,
  });

  /// Erstellt ein MessageModel aus einem Firestore-Dokument.
  /// Erwartet, dass Zeitstempel als Firestore-Timestamp gespeichert sind.
  factory MessageModel.fromJson(Map<String, dynamic> json, String docId) {
    return MessageModel(
      id: docId,
      toId: json['to_id'] as String? ?? '',
      fromId: json['from_id'] as String? ?? '',
      msg: json['msg'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      createdAt: (json['created_at'] as Timestamp?)?.toDate(),
      readAt: (json['read_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Erstellt eine Map zum Speichern einer neuen Nachricht in Firestore.
  Map<String, dynamic> toJsonForCreate() {
    return {
      'to_id': toId,
      'from_id': fromId,
      'msg': msg,
      'type': type,
      'created_at': FieldValue.serverTimestamp(), // Zeit wird vom Server gesetzt
      'read_at': null, // Wird initial nicht gelesen
    };
  }

  /// Nützliche Helfer-Methode zum Kopieren und Ändern von Instanzen.
  MessageModel copyWith({
    String? id,
    String? toId,
    String? fromId,
    String? msg,
    String? type,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      toId: toId ?? this.toId,
      fromId: fromId ?? this.fromId,
      msg: msg ?? this.msg,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
  @override
  List<Object?> get props => [id, toId, fromId, msg, type, createdAt, readAt];
}