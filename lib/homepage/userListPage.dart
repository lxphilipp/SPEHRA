import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/layout/chatpage_layout.dart';

class UserListPage extends StatelessWidget {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        backgroundColor: const Color(0xff040324),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text('Users',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OswaldLight',
            )),
      ),
      body: _buildListOfUsers(),
    );
  }

  Widget _buildListOfUsers() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('loading...');
          }

          return ListView(
              children: snapshot.data!.docs
                  .map<Widget>((doc) => _buildUserListItem(context, doc))
                  .toList());
        });
  }

  Widget _buildUserListItem(BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    //display all Users except curren User

    if (_auth.currentUser!.email != data['Email'] &&
        data['Email'] != null &&
        data['User UID'] != null &&
        data['name'] != null) {
      return Container(
        color: const Color.fromARGB(255, 29, 29, 61),
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: const Icon(
            Icons.person,
            color: Colors.white,
          ),
          title: Text(
            data['name'],
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'OswaldLight',
            ),
          ), // error
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPageLayout(
                          receiverUserName: data['name'],
                          receiverUserID: data['User UID'],
                        )));
          },
        ),
      );
    } else {
      return Container();
    }
  }
}
