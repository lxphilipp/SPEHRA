import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/app_logger.dart';

class GroupChatModel {
  final String id;
  final String name;
  final String? imageUrl;
  final List<String> adminIds;
  final List<String> memberIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;

  const GroupChatModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.adminIds,
    required this.memberIds,
    this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
  });

  factory GroupChatModel.fromJson(Map<String, dynamic> json, String docId) {

    DateTime? lastMessageTime;
    if (json['last_message_time'] == null && json.containsKey('last_message_time')) {
      lastMessageTime = null;
    } else if (json['last_message_time'] is Timestamp) {
      lastMessageTime = (json['last_message_time'] as Timestamp).toDate();
    } else if (json['last_message_time'] is String && (json['last_message_time'] as String).isNotEmpty) {
      lastMessageTime = DateTime.tryParse(json['last_message_time']) ?? DateTime.fromMillisecondsSinceEpoch(int.tryParse(json['last_message_time']) ?? 0);
    } else if (json['last_message_time'] is int) {
      lastMessageTime = DateTime.fromMillisecondsSinceEpoch(json['last_message_time']);
    }

    DateTime? createdAt;
    if (json['created_at'] == null && json.containsKey('created_at')) {
      createdAt = null;
    } else if (json['created_at'] is Timestamp) {
      createdAt = (json['created_at'] as Timestamp).toDate();
    } else if (json['created_at'] is String) {
      createdAt = DateTime.tryParse(json['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(int.tryParse(json['created_at']) ?? 0);
    } else if (json['created_at'] is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(json['created_at']);
    } else if (!json.containsKey('created_at')) {
      AppLogger.warning("WARNING: 'created_at' is missing in GroupChat $docId.");
      createdAt = null;
    }

    return GroupChatModel(
      id: docId,
      name: json['name'] as String? ?? 'Unnamed Group',
      imageUrl: json['image_url'] as String?,
      adminIds: List<String>.from(json['admins'] as List<dynamic>? ?? []),
      memberIds: List<String>.from(json['members'] as List<dynamic>? ?? []),
      lastMessage: json['last_message'] as String?,
      lastMessageTime: lastMessageTime,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    final Map<String, dynamic> data = {
      'name': name,
      'image_url': imageUrl, // Ensure the key is consistent
      'admins': adminIds,
      'members': memberIds,
      'created_at': FieldValue.serverTimestamp(),
    };

    if (lastMessage != null && lastMessage!.isNotEmpty) {
      data['last_message'] = lastMessage;
      data['last_message_time'] = (lastMessageTime != null)
          ? Timestamp.fromDate(lastMessageTime!) // Take the explicitly set time
          : FieldValue.serverTimestamp();       // Or let the server stamp it
    } else {
      data['last_message'] = null; // Explicitly set to null to maintain consistency
      data['last_message_time'] = null; // Explicitly set to null
    }
    return data;
  }

  Map<String, dynamic> toJsonForUpdate() {
    final data = <String, dynamic>{};
    data['name'] = name;
    if (imageUrl != null) {
      data['image_url'] = imageUrl;
    } else {
      data['image_url'] = null;
    }
    data['admins'] = adminIds;
    data['members'] = memberIds;

    // Specific logic for lastMessage and lastMessageTime on update
    if (lastMessage != null && lastMessage!.isNotEmpty) {
      // Is only updated when a new message is sent
      data['last_message'] = lastMessage;
      data['last_message_time'] = FieldValue.serverTimestamp();
    }

    return data;
  }

  GroupChatModel copyWith({
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
    return GroupChatModel(
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