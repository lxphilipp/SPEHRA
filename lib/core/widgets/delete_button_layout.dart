import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 29, 29, 61),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content:
                  const Text('Are you sure you want to delete your account?'),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _auth.currentUser!.delete();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      child: const Text(
        'Delete Account',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'OswaldLight',
          fontSize: 14.0,
        ),
      ),
    );
  }
}
