import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/models/message.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class Chat2messageCard extends StatefulWidget {
  final int index;
  final Message messageItem;
  final String roomId;
  final bool selected;
  const Chat2messageCard({
    super.key,
    required this.index,
    required this.messageItem,
    required this.roomId,
    required this.selected,
  });

  @override
  State<Chat2messageCard> createState() => _Chat2messageCardState();
}

class _Chat2messageCardState extends State<Chat2messageCard> {
  @override
  void initState() {
    if (widget.messageItem.toId == FirebaseAuth.instance.currentUser!.uid) {
      FireData().readMessage(widget.roomId, widget.messageItem.id!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isMe =
        widget.messageItem.fromId == FirebaseAuth.instance.currentUser!.uid;
    return Container(
      decoration: BoxDecoration(
          color: widget.selected ? Colors.grey : Colors.transparent,
          borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          isMe
              ? IconButton(
                  onPressed: () {},
                  icon: Icon(Iconsax.message_edit),
                )
              : SizedBox(),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            color: isMe
                ? Theme.of(context).colorScheme.background
                : Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width / 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.messageItem.type == 'image'
                        ? Container(
                            child: Image.network(widget.messageItem.msg!),
                            // CachedNetworkImage(
                            //   imageUrl: messageItem.msg!,
                            //   placeholder: (context, url) {
                            //     return CircularProgressIndicator();
                            //   },
                            // ),
                          )
                        : Text(widget.messageItem.msg!),
                    SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isMe
                            ? Icon(
                                Iconsax.tick_circle,
                                color: widget.messageItem.read == ""
                                    ? Colors.grey
                                    : Colors.blueAccent,
                                size: 18,
                              )
                            : SizedBox(),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          DateFormat.yMMMEd()
                              .format(DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(widget.messageItem.createdAt!)))
                              .toString(),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
