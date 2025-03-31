import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/Chat/widgets/text_feld.dart';
import 'package:flutter_sdg/models/group_model.dart';
import 'package:flutter_sdg/models/user_data.dart';
import 'package:iconsax/iconsax.dart';

class EditGroupScren extends StatefulWidget {
  final GroupChat chatGroup;
  const EditGroupScren({super.key, required this.chatGroup});

  @override
  State<EditGroupScren> createState() => _EditGroupScrenState();
}

class _EditGroupScrenState extends State<EditGroupScren> {
  TextEditingController gNamecon = TextEditingController();
  List members = [];
  List myContact = [];
  @override
  void initState() {
    super.initState();
    gNamecon.text = widget.chatGroup.name!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          FireData()
              .editGroup(widget.chatGroup.id!, gNamecon.text, members)
              .then((value) => Navigator.pop(context));
        },
        label: const Text('Add'),
        icon: const Icon(Iconsax.tick_circle),
      ),
      appBar: AppBar(
        title: const Text('Edit Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                      ),
                      Positioned(
                          bottom: -10,
                          right: -10,
                          child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Iconsax.gallery)))
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: CustumFeld(
                    controller: gNamecon,
                    label: 'Group Name',
                    icon: Iconsax.user_octagon,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 16,
            ),
            const Row(
              children: [
                Text('Add Member'),
                Spacer(),
                Text('0'),
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    myContact = snapshot.data!.data()!['my_users'];
                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('id',
                                whereIn: myContact.isEmpty ? [''] : myContact)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final List<UserData> items = snapshot.data!.docs
                                .map((e) => UserData.fromMap(e.data()))
                                .where((element) =>
                                    element.id !=
                                    FirebaseAuth.instance.currentUser!.uid)
                                .where((element) => !widget.chatGroup.members
                                    .contains(element.id))
                                .toList()
                              ..sort((a, b) => a.name!.compareTo(b.name!));
                            return ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                    checkboxShape: const CircleBorder(),
                                    title: Text(items[index].name!),
                                    value: members.contains(items[index].id),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value!) {
                                          members.add(items[index].id!);
                                        } else {
                                          members.remove(items[index].id!);
                                        }
                                        print(members);
                                      });
                                    });
                              },
                            );
                          } else {
                            return Container();
                          }
                        });
                  } else {
                    return Container();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
