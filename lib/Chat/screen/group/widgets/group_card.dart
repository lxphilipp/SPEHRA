import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/screen/group/group_screen.dart';
import 'package:flutter_sdg/models/group_model.dart';

class Group2Card extends StatelessWidget {
  final GroupChat groupChat;
  const Group2Card({
    super.key,
    required this.groupChat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupScreens(
                  groupChat: groupChat,
                ),
              )),
          leading: CircleAvatar(
            child: Text(groupChat.name!.characters.first),
          ),
          title: Text(groupChat.name!),
          subtitle: Text(
            groupChat.lastMessage == ""
                ? " send message"
                : groupChat.lastMessage,
            maxLines: 1,
          ),
          trailing: Text(groupChat.lastMessageTime)),
    );
  }
}
