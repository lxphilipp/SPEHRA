import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/Chat/screen/group/group_member.dart';
import 'package:flutter_sdg/Chat/screen/group/widgets/group_massage_card.dart';
import 'package:flutter_sdg/models/group_model.dart';
import 'package:flutter_sdg/models/message.dart';
import 'package:iconsax/iconsax.dart';

class GroupScreens extends StatefulWidget {
  final GroupChat groupChat;
  const GroupScreens({super.key, required this.groupChat});

  @override
  State<GroupScreens> createState() => _GroupScreensState();
}

class _GroupScreensState extends State<GroupScreens> {
  TextEditingController groupcon = TextEditingController();

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
              widget.groupChat.name!,
              style: TextStyle(color: Colors.white),
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('id', whereIn: widget.groupChat.members)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List membersName = [];
                    for (var element in snapshot.data!.docs) {
                      membersName.add(element.data()['name']);
                    }
                    return Text(
                      membersName.join(' , '),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }
                  return Container();
                }),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GroupMember(chatGroup: widget.groupChat),
                ),
              );
            },
            icon: const Icon(Iconsax.user),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.groupChat.id!)
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<Message> msgs = snapshot.data!.docs
                        .map((e) => Message.fromJson(e.data()))
                        .toList()
                      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
                    if (msgs.isEmpty) {
                      return Center(
                        child: GestureDetector(
                          onTap: () => FireData().sendGMessage(
                              'Sag Hello 👋', widget.groupChat.id!),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '👋',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    'Sag Hello',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        reverse: true,
                        itemCount: msgs.length,
                        itemBuilder: (context, index) {
                          return GroupMassageCard(
                            index: index,
                            message: msgs[index],
                          );
                        },
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: TextField(
                      controller: groupcon,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        suffixIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Iconsax.camera),
                            ),
                            IconButton.filled(
                              onPressed: () {
                                if (groupcon.text.isNotEmpty) {
                                  FireData()
                                      .sendGMessage(
                                          groupcon.text, widget.groupChat.id!)
                                      .then((value) {
                                    setState(() {
                                      groupcon.text = "";
                                    });
                                  });
                                }
                              },
                              icon: const Icon(Iconsax.send_1),
                            ),
                          ],
                        ),
                        border: InputBorder.none,
                        hintText: "message",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
