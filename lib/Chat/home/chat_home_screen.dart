import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/Chat/screen/chat/widgets/chat_card.dart';
import 'package:flutter_sdg/Chat/widgets/text_feld.dart';
import 'package:flutter_sdg/homepage/homepage.dart';
import 'package:flutter_sdg/models/room_model.dart';
import 'package:iconsax/iconsax.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  TextEditingController emailcon = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double logoHeight = AppBar().preferredSize.height - 16.0;
    return Scaffold(
      backgroundColor: Color(0xff040324),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Enter Friend Email",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      CustumFeld(
                        controller: emailcon,
                        icon: Iconsax.direct,
                        label: 'Email',
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          onPressed: () {
                            if (emailcon.text.isNotEmpty) {
                              FireData()
                                  .createRoom(emailcon.text)
                                  .then((value) {
                                setState(() {
                                  emailcon.text = "";
                                });
                                Navigator.pop(context);
                              });
                            }
                          },
                          child: Center(
                            child: Text("creat chat"),
                          ))
                    ],
                  ),
                );
              });
        },
        child: Icon(Iconsax.message_add_1),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xff040324),
        title: const Text(
          'Chat',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const HomePageScreen()));
            },
            child: SizedBox(
              height: logoHeight,
              child: Image.asset(
                'assets/logo/Logo-Bild.png',
                height: logoHeight,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('rooms')
                      .where('member',
                          arrayContains: FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    //if (snapshot.hasData) {
                    //if (snapshot.hasData &&
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.docs.isNotEmpty) {
                      List<ChatRoom> items = snapshot.data!.docs
                          .map((e) => ChatRoom.fromJson(e.data()))
                          .toList()
                        // ..sort((a, b) =>
                        //     b.LastMassageTime!.compareTo(a.LastMassageTime!));
                        ..sort((a, b) =>
                            int.tryParse(b.LastMassageTime ?? '0')?.compareTo(
                              int.tryParse(a.LastMassageTime ?? '0') ?? 0,
                            ) ??
                            0);

                      return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, Index) {
                            return chat2Card(
                              item: items[Index],
                            );
                          });
                    } else {
                      return const Center(
                        child: Text(
                          "No chats found",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
