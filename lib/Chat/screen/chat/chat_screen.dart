import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/Chat/firebase/fire_storge.dart';
import 'package:flutter_sdg/Chat/screen/chat/widgets/chat_message_card.dart';
import 'package:flutter_sdg/models/message.dart';
import 'package:flutter_sdg/models/user_data.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

// صفحة المحادثة بعد انشائها
class Chat2Screen extends StatefulWidget {
  final String roomId;
  final UserData chatUser;
  const Chat2Screen({super.key, required this.roomId, required this.chatUser});

  @override
  State<Chat2Screen> createState() => _Chat2ScreenState();
}

class _Chat2ScreenState extends State<Chat2Screen> {
  TextEditingController msgcon = TextEditingController();
  List<String> selectedMsg2 = [];
  List<String> copyMsg = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff040324),
      appBar: AppBar(
        backgroundColor: Color(0xff040324),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatUser.name!,
              style: TextStyle(color: Colors.white),
            ),
            Text(
              //widget.chatUser.lastActived!,
              widget.chatUser.lastActived != null
                  ? '${DateTime.fromMillisecondsSinceEpoch(int.tryParse(widget.chatUser.lastActived!) ?? 0).day}.${DateTime.fromMillisecondsSinceEpoch(int.tryParse(widget.chatUser.lastActived!) ?? 0).month}.${DateTime.fromMillisecondsSinceEpoch(int.tryParse(widget.chatUser.lastActived!) ?? 0).year} • ${DateTime.fromMillisecondsSinceEpoch(int.tryParse(widget.chatUser.lastActived!) ?? 0).hour}:${DateTime.fromMillisecondsSinceEpoch(int.tryParse(widget.chatUser.lastActived!) ?? 0).minute.toString().padLeft(2, '0')}'
                  : '',
              style: Theme.of(context).textTheme.labelMedium,
            )
          ],
        ),
        actions: [
          copyMsg.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: copyMsg.join(' \n'),
                      ),
                    );
                    setState(() {
                      copyMsg.clear();
                      selectedMsg2.clear();
                    });
                  },
                  icon: const Icon(Iconsax.copy))
              : Container(),
          selectedMsg2.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    FireData().deleteMsg(widget.roomId, selectedMsg2);
                    selectedMsg2.clear();
                    copyMsg.clear();
                  },
                  icon: Icon(Iconsax.trash),
                )
              : Container(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(widget.roomId)
                      .collection('messages')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Message> messageItem = snapshot.data!.docs
                          .map((e) => Message.fromJson(e.data()))
                          .toList()
                        ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

                      return messageItem.isNotEmpty
                          ? ListView.builder(
                              reverse: true,
                              itemCount: messageItem.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedMsg2.length > 0
                                          ? selectedMsg2.contains(
                                                  messageItem[index].id)
                                              ? selectedMsg2
                                                  .remove(messageItem[index].id)
                                              : selectedMsg2
                                                  .add(messageItem[index].id!)
                                          : null;
                                      copyMsg.isNotEmpty
                                          ? messageItem[index].type == 'text'
                                              ? copyMsg.contains(
                                                      messageItem[index].msg)
                                                  ? copyMsg.remove(
                                                      messageItem[index].msg!)
                                                  : copyMsg.add(
                                                      messageItem[index].msg!)
                                              : null
                                          : null;
                                      print(copyMsg);
                                    });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      selectedMsg2
                                              .contains(messageItem[index].id)
                                          ? selectedMsg2
                                              .remove(messageItem[index].id)
                                          : selectedMsg2
                                              .add(messageItem[index].id!);
                                      messageItem[index].type == 'text'
                                          ? copyMsg.contains(
                                                  messageItem[index].msg)
                                              ? copyMsg.remove(
                                                  messageItem[index].msg!)
                                              : copyMsg
                                                  .add(messageItem[index].msg!)
                                          : null;
                                      print(copyMsg);
                                    });
                                  },
                                  child: Chat2messageCard(
                                    selected: selectedMsg2
                                        .contains(messageItem[index].id),
                                    index: index,
                                    messageItem: messageItem[index],
                                    roomId: widget.roomId,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: GestureDetector(
                                onTap: () => FireData().sendMessage(
                                    widget.chatUser.id!,
                                    'Hello 👋',
                                    widget.roomId),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "👋",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium,
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                          "Hello",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                    } else {
                      return Container();
                    }
                  }),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: TextField(
                      controller: msgcon,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                          suffixIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // IconButton(
                              //     onPressed: () {},
                              //     icon: Icon(Iconsax.emoji_happy)),
                              IconButton(
                                  onPressed: () async {
                                    ImagePicker picker = ImagePicker();
                                    XFile? image = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    if (image != null) {
                                      FireStorage().sendImage(
                                          file: File(image.path),
                                          roomId: widget.roomId,
                                          uid: widget.chatUser.id!);
                                    }
                                  },
                                  icon: Icon(Iconsax.camera)),
                            ],
                          ),
                          border: InputBorder.none,
                          hintText: "message",
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8)),
                    )
                    //CustumFeld()
                    ,
                  ),
                ),
                IconButton.filled(
                    onPressed: () {
                      if (msgcon.text.isNotEmpty) {
                        FireData()
                            .sendMessage(
                                widget.chatUser.id!, msgcon.text, widget.roomId)
                            .then((value) {
                          setState(() {
                            msgcon.text = "";
                          });
                        });
                      }
                    },
                    icon: Icon(Iconsax.send_1))
              ],
            )
          ],
        ),
      ),
    );
  }
}
