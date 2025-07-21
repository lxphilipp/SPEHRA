// lib/features/chat/domain/entities/message_entity.dart

import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  image,
  progressUpdate,
  milestoneUnlocked,
}

class MessageEntity extends Equatable {
  final String id;
  final String toId;
  final String fromId;
  final String msg;
  final MessageType type;
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
  List<Object?> get props => [id, toId, fromId, msg, type, createdAt, readAt];

  MessageEntity copyWith({
    String? id,
    String? toId,
    String? fromId,
    String? msg,
    MessageType? type,
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