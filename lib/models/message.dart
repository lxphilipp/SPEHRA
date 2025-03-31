// import 'package:cloud_firestore/cloud_firestore.dart';

// class Message{
//   final String senderID;
//   final String senderEmail;
//   final String receiverID;
//   final String message;
//   final Timestamp timestamp;

//   Message({
//     required this.senderID,
//     required this.senderEmail,
//     required this.message,
//     required this.receiverID,
//     required this.timestamp,
//   });

//   Map<String,dynamic> toMap()
//   {
//     return{
//       'senderID' : senderID,
//       'senderEmail' : senderEmail,
//       'receiverID' : receiverID,
//       'message' : message,
//       'timestamp' : timestamp,
//     };
//   }

//   // create a chatroomID

// }

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? id;
  String? toId;
  String? fromId;
  String? msg;
  String? type;
  String? createdAt;
  String? read;

  Message({
    required this.id,
    required this.toId,
    required this.fromId,
    required this.msg,
    required this.type,
    required this.createdAt,
    required this.read,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? "",
      toId: json['to_id'],
      fromId: json['from_id'],
      msg: json['msg'],
      type: json['type'],
      createdAt: json['created_At'] is Timestamp
          ? (json['created_At'] as Timestamp)
              .toDate()
              .toIso8601String() // Convert Timestamp to ISO 8601 String
          : json['created_At'], // Keep as String if already formatted
      read: json['read']?.toString() ?? "", // Convert read to String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'to_id': toId,
      'from_id': fromId,
      'msg': msg,
      'type': type,
      'created_At': createdAt,
      'read': read,
    };
  }
}
