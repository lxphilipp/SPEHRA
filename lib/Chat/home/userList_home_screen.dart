import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/Chat/contact/contact_card.dart';
import 'package:flutter_sdg/Chat/firebase/fire_database.dart';
import 'package:flutter_sdg/Chat/widgets/text_feld.dart';
import 'package:flutter_sdg/models/user_data.dart';
import 'package:iconsax/iconsax.dart';

class UserlistHomeScreen extends StatefulWidget {
  const UserlistHomeScreen({super.key});

  @override
  State<UserlistHomeScreen> createState() => _UserlistHomeScreenState();
}

class _UserlistHomeScreenState extends State<UserlistHomeScreen> {
  bool searched = false;
  List myContacts = [];
  TextEditingController emailcon = TextEditingController();
  TextEditingController searchcon = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        onPressed: () {
                          FireData().addContact(emailcon.text).then((value) {
                            setState(() {
                              emailcon.text = "";
                            });
                            Navigator.pop(context);
                          });
                        },
                        child: Center(
                          child: Text("Add Contact"),
                        ),
                      )
                    ],
                  ),
                );
              });
        },
        child: Icon(Iconsax.user_add),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xff040324),
        actions: [
          searched
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searched = false;
                      searchcon.text = "";
                    });
                  },
                  icon: Icon(Iconsax.close_circle),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      searched = true;
                    });
                  },
                  icon: Icon(Iconsax.search_normal),
                ),
        ],
        title: searched
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchcon.text = value;
                        });
                      },
                      autofocus: true,
                      controller: searchcon,
                      decoration: InputDecoration(
                        hintText: "Search by name",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                'My Favorite Contacts',
                style: TextStyle(color: Colors.white),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users') // ← تم التعديل هنا
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data?.data() == null) {
                    return Center(child: Text('No data found.'));
                  }

                  myContacts = snapshot.data?.data()?['my_users'] ??
                      []; // ← تم التعديل هنا

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users') // ← تم التعديل هنا
                        .where('id',
                            whereIn: myContacts.isEmpty ? [''] : myContacts)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData) {
                        return Center(child: Text('No contacts.'));
                      }

                      final List<UserData> items = snapshot.data!.docs
                          .map((e) => UserData.fromMap(e.data()))
                          .where((element) => element.name!
                              .toLowerCase()
                              .startsWith(searchcon.text.toLowerCase()))
                          .toList()
                        ..sort((a, b) => a.name!.compareTo(b.name!));

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return contact2Card(
                            user: items[index],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
