import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
// WICHTIG: Importiere die Entity-Datei, um Zugriff auf das Enum zu haben
import '../../domain/entities/message_entity.dart';

class MessageModel extends Equatable {
  final String id;
  final String toId;
  final String fromId;
  final String msg;
  final MessageType type;
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
  factory MessageModel.fromJson(Map<String, dynamic> json, String docId) {
    return MessageModel(
      id: docId,
      toId: json['to_id'] as String? ?? '',
      fromId: json['from_id'] as String? ?? '',
      msg: json['msg'] as String? ?? '',
      type: MessageType.values.firstWhere(
            (e) => e.name == (json['type'] as String?),
        orElse: () => MessageType.text,
      ),
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
      'type': type.name,
      'created_at': FieldValue.serverTimestamp(),
      'read_at': null,
    };
  }

  MessageModel copyWith({
    String? id,
    String? toId,
    String? fromId,
    String? msg,
    MessageType? type,
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