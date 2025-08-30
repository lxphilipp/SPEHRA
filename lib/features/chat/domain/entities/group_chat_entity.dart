import 'package:flutter/foundation.dart';

class GroupChatEntity {
  final String id;
  final String name;
  final String? imageUrl;
  final List<String> adminIds;
  final List<String> memberIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;

  const GroupChatEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.adminIds,
    required this.memberIds,
    this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupChatEntity &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        listEquals(other.adminIds, adminIds) &&   // Wichtig für Listen!
        listEquals(other.memberIds, memberIds) && // Wichtig für Listen!
        other.lastMessage == lastMessage &&
        other.lastMessageTime == lastMessageTime &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      imageUrl,
      Object.hashAll(adminIds),  // Hashcode für Listeninhalt
      Object.hashAll(memberIds), // Hashcode für Listeninhalt
      lastMessage,
      lastMessageTime,
      createdAt,
    );
  }

  GroupChatEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    bool? allowNullImageUrl,
    List<String>? adminIds,
    List<String>? memberIds,
    String? lastMessage,
    bool? allowNullLastMessage,
    DateTime? lastMessageTime,
    bool? allowNullLastMessageTime,
    DateTime? createdAt,
    bool? allowNullCreatedAt,
  }) {
    return GroupChatEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: (allowNullImageUrl == true) ? null : (imageUrl ?? this.imageUrl),
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      lastMessage: (allowNullLastMessage == true) ? null : (lastMessage ?? this.lastMessage),
      lastMessageTime: (allowNullLastMessageTime == true) ? null : (lastMessageTime ?? this.lastMessageTime),
      createdAt: (allowNullCreatedAt == true) ? null : (createdAt ?? this.createdAt),
    );
  }
}