import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/Chat/widgets/text_feld.dart';
import 'package:flutter_sdg/models/user_data.dart';
import 'package:iconsax/iconsax.dart';

class CreatGroupScreen extends StatefulWidget {
  const CreatGroupScreen({super.key});

  @override
  State<CreatGroupScreen> createState() => _CreatGroupScreenState();
}

class _CreatGroupScreenState extends State<CreatGroupScreen> {
  TextEditingController gNamecon = TextEditingController();
  List<String> members = [];
  List myContact = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: members.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                FireData().creatGroup(gNamecon.text, members).then((value) {
                  Navigator.pop(context);
                  setState(() {
                    members = [];
                  });
                });
              },
              label: const Text('done'),
              icon: const Icon(Iconsax.tick_circle),
            )
          : Container(),
      appBar: AppBar(
        title: const Text('creat Group'),
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
                Text('Member'),
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
                    myContact = snapshot.data?.data()?['my_users'] ?? [];
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
