class ChatRoom {
  String? id;
  List? memeber;
  String? lastMassage;
  // ignore: non_constant_identifier_names
  String? LastMassageTime;
  String? createdAt;

  ChatRoom({
    required this.id,
    required this.createdAt,
    required this.memeber,
    required this.lastMassage,
    // ignore: non_constant_identifier_names
    required this.LastMassageTime,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? "",
      createdAt: json['created_At'] ?? "",
      memeber: json['member'] ?? [],
      lastMassage: json['last_Massage'],
      LastMassageTime: json['last_Massage_Time'] ?? "0",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_At': createdAt,
      'member': memeber,
      'last_Massage': lastMassage,
      'last_Massage_Time': LastMassageTime,
    };
  }
}
