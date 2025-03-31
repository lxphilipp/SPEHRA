import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/Chat/screen/group/group_edit.dart';
import 'package:flutter_sdg/models/group_model.dart';
import 'package:flutter_sdg/models/user_data.dart';
import 'package:iconsax/iconsax.dart';

class GroupMember extends StatefulWidget {
  final GroupChat chatGroup;
  const GroupMember({super.key, required this.chatGroup});

  @override
  State<GroupMember> createState() => _GroupMemberState();
}

class _GroupMemberState extends State<GroupMember> {
  @override
  Widget build(BuildContext context) {
    bool isAdmin =
        widget.chatGroup.admin.contains(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Member'),
        actions: [
          isAdmin
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditGroupScren(
                                chatGroup: widget.chatGroup,
                              )),
                    );
                  },
                  icon: const Icon(Iconsax.user_edit))
              : Container()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('id', whereIn: widget.chatGroup.members)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<UserData> user = snapshot.data!.docs
                          .map((e) => UserData.fromMap(e.data()))
                          .toList();
                      return ListView.builder(
                          itemCount: user.length,
                          itemBuilder: (context, index) {
                            bool admin =
                                widget.chatGroup.admin.contains(user[index].id);
                            return ListTile(
                              title: Text(user[index].name!),
                              subtitle: admin
                                  ? Text(
                                      "admin",
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : Text('member'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isAdmin
                                      ? IconButton(
                                          onPressed: () {
                                            FireData()
                                                .removeMember(
                                                    widget.chatGroup.id!,
                                                    user[index].id!)
                                                .then((value) {
                                              setState(() {
                                                widget.chatGroup.members
                                                    .remove(user[index].id!);
                                              });
                                            });
                                          },
                                          icon: const Icon(Iconsax.trash),
                                        )
                                      : Container(),
                                  // isAdmin
                                  //     ? IconButton(
                                  //         onPressed: () {},
                                  //         icon: const Icon(Iconsax.user_tick),
                                  //       )
                                  //     : Container(),
                                ],
                              ),
                            );
                          });
                    } else {
                      return Container();
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
