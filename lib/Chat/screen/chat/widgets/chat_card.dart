import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/screen/chat/chat_screen.dart';
import 'package:flutter_sdg/models/message.dart';
import 'package:flutter_sdg/models/room_model.dart';
import 'package:flutter_sdg/models/user_data.dart';
import 'package:intl/intl.dart';

//هون صفحة الدردشو
class chat2Card extends StatelessWidget {
  final ChatRoom item;
  const chat2Card({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    List member = item.memeber!
        .where((element) => element != FirebaseAuth.instance.currentUser!.uid)
        .toList();
    String userId =
        member.isEmpty ? FirebaseAuth.instance.currentUser!.uid : member.first;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData chatUser = UserData.fromMap(snapshot.data!.data()!);
            return Card(
              child: ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chat2Screen(
                        chatUser: chatUser,
                        roomId: item.id!,
                      ),
                    )),
                leading: CircleAvatar(),
                title: Text(chatUser.name!),
                subtitle: Text(
                  item.lastMassage! == "" ? chatUser.about! : item.lastMassage!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .doc(item.id)
                      .collection('messages')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final unreadList = snapshot.data?.docs
                            .map((e) => Message.fromJson(e.data()))
                            .where((element) => element.read == "")
                            .where((element) =>
                                element.fromId !=
                                FirebaseAuth.instance.currentUser!.uid) ??
                        [];
                    // return unreadList.length != 0
                    //     ? Badge(
                    //         backgroundColor: Colors.green,
                    //         padding: EdgeInsets.symmetric(horizontal: 12),
                    //         label: Text(unreadList.length.toString()),
                    //         largeSize: 30,
                    //       )
                    //     : Text(DateFormat.yMMMEd()
                    //         .format(DateTime.fromMillisecondsSinceEpoch(
                    //             int.parse(item.LastMassageTime.toString())))
                    //         .toString());
                    if (unreadList.isNotEmpty) {
                      return Badge(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        label: Text(unreadList.length.toString()),
                        largeSize: 30,
                      );
                    } else {
                      // التعامل مع LastMassageTime
                      final timestampString = item.LastMassageTime?.toString();
                      final timestamp = int.tryParse(timestampString ?? '');
                      final formattedDate = timestamp != null
                          ? DateFormat.yMMMEd().format(
                              DateTime.fromMillisecondsSinceEpoch(timestamp))
                          : '';

                      return Text(formattedDate);
                    }
                  },
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
