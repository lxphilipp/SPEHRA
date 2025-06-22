// lib/features/chat/domain/entities/chat_user_entity.dart
import 'package:flutter/foundation.dart'; // Für @immutable

@immutable
class ChatUserEntity {
  final String id;
  final String name;
  final String? imageUrl;
  final bool? isOnline;
  final DateTime? lastActiveAt;

  const ChatUserEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isOnline,
    this.lastActiveAt,
  });


  ChatUserEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    bool? allowNullImageUrl,
    bool? isOnline,
    bool? allowNullIsOnline,
    DateTime? lastActiveAt,
    bool? allowNullLastActiveAt
  }) {
    return ChatUserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: (allowNullImageUrl == true) ? null : (imageUrl ?? this.imageUrl),
      isOnline: (allowNullIsOnline == true) ? null : (isOnline ?? this.isOnline),
      lastActiveAt: (allowNullLastActiveAt == true) ? null : (lastActiveAt ?? this.lastActiveAt),
    );
  }

  // Überschreiben von operator== und hashCode für korrekte Vergleiche und Verwendung in Sets/Maps.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatUserEntity &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        other.isOnline == isOnline &&
        other.lastActiveAt == lastActiveAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      imageUrl,
      isOnline,
      lastActiveAt,
    );
  }

  @override
  String toString() {
    return 'ChatUserEntity(id: $id, name: $name, imageUrl: $imageUrl, isOnline: $isOnline, lastActiveAt: $lastActiveAt)';
  }
}