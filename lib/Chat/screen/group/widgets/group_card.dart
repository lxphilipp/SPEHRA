import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/screen/group/group_screen.dart';
import 'package:flutter_sdg/models/group_model.dart';
import 'package:intl/intl.dart';

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
            //child: Text(groupChat.name!.characters.first),
            child: Text(
              (groupChat.name != null && groupChat.name!.trim().isNotEmpty)
                  ? groupChat.name!.characters.first
                  : '?',
            ),
          ),
          //title: Text(groupChat.name!),
          title: Text(
            (groupChat.name != null && groupChat.name!.trim().isNotEmpty)
                ? groupChat.name!
                : 'No Name',
          ),
          subtitle: Text(
            groupChat.lastMessage == ""
                ? " send message"
                : groupChat.lastMessage,
            maxLines: 1,
          ),
          trailing: Text(
            DateFormat('dd.MM.yyyy HH:mm').format(
              DateTime.fromMillisecondsSinceEpoch(
                  int.parse(groupChat.lastMessageTime)),
            ),
            style: const TextStyle(fontSize: 12),
          )),
    );
  }
}
