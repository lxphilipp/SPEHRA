import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChat {
  String? id;
  String? name;
  String? image;
  List members;
  List admin;
  String lastMessage;
  String lastMessageTime;
  String createdAt;

  GroupChat({
    required this.id,
    required this.name,
    required this.image,
    required this.admin,
    required this.lastMessage,
    required this.createdAt,
    required this.lastMessageTime,
    required this.members,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      image: json['image'] ?? "",
      members: json['members'] ?? [],
      admin: json['admin_id'] ?? [],
      createdAt: json['created_At'] is Timestamp
          ? (json['created_At'] as Timestamp).toDate().toString()
          : json['created_At'] ?? "",
      lastMessage: json['last_Message'] ?? "",
      lastMessageTime: json['last_Message_Time'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'members': members,
      'admin_id': admin,
      'created_At': createdAt,
      'last_Message': lastMessage,
      'last_Message_Time': lastMessageTime,
    };
  }
}
