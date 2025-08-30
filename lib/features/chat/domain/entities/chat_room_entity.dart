import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final List<String> members;
  final DateTime createdAt;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  final List<String> hiddenFor;
  final Map<String, DateTime> clearedAt;

  const ChatRoomEntity({
    required this.id,
    required this.members,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.hiddenFor = const [],
    this.clearedAt = const {},
  });

  @override
  List<Object?> get props => [
    id,
    members,
    createdAt,
    lastMessage,
    lastMessageTime,
    hiddenFor,
    clearedAt,
  ];
}