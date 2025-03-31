import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ContactHomeScreen extends StatefulWidget {
  const ContactHomeScreen({super.key});

  @override
  State<ContactHomeScreen> createState() => _ContactHomeScreenState();
}

class _ContactHomeScreenState extends State<ContactHomeScreen> {
  bool searched = false;
  TextEditingController searchcon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          searched
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      searched = false;
                    });
                  },
                  icon: Icon(Iconsax.close_circle))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      searched = true;
                    });
                  },
                  icon: Icon(Iconsax.search_normal))
        ],
        title: searched
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: searchcon,
                      decoration: InputDecoration(
                          hintText: "search by name", border: InputBorder.none),
                    ),
                  ),
                ],
              )
            : Text('My contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text("name"),
                      trailing: IconButton(
                          onPressed: () {}, icon: Icon(Iconsax.message)),
                    ),
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
