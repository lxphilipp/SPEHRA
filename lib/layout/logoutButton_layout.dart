import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login/signin.dart';

class LogoutButton extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const SignInScreen()));
    //Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        logout(context);
      },
      child: const Text(
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: "OswaldRegular",
          ),
          "Logout"),
    );
  }
}
