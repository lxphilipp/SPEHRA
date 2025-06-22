// KEIN import 'package:equatable/equatable.dart';

class MessageEntity {
  final String id;
  final String toId;
  final String fromId;
  final String msg;
  final String type;
  final DateTime? createdAt;
  final DateTime? readAt;

  const MessageEntity({
    required this.id,
    required this.toId,
    required this.fromId,
    required this.msg,
    required this.type,
    this.createdAt,
    this.readAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageEntity &&
        other.id == id &&
        other.toId == toId &&
        other.fromId == fromId &&
        other.msg == msg &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.readAt == readAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      toId,
      fromId,
      msg,
      type,
      createdAt,
      readAt,
    );
  }

  MessageEntity copyWith({
    String? id,
    String? toId,
    String? fromId,
    String? msg,
    String? type,
    DateTime? createdAt,
    bool? allowNullCreatedAt,
    DateTime? readAt,
    bool? allowNullReadAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      toId: toId ?? this.toId,
      fromId: fromId ?? this.fromId,
      msg: msg ?? this.msg,
      type: type ?? this.type,
      createdAt: (allowNullCreatedAt == true) ? null : (createdAt ?? this.createdAt),
      readAt: (allowNullReadAt == true) ? null : (readAt ?? this.readAt),
    );
  }
}