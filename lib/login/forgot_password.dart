import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
          leading: BackButton(onPressed: () {
            Navigator.pop(context);
          }),
          elevation: 0,
          backgroundColor: const Color(0xff040324)),
      body: const ForgotPassword(),
    );
  }
}

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();

  void _resetPassword() {
    FirebaseAuth.instance
        .sendPasswordResetEmail(
      email: emailController.text,
    )
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Check your email.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send password reset email: $error',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Receive Email to reset your password',
            style: TextStyle(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: Icon(Icons.email),
                prefixIconColor: Colors.white,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                hintText: ' Email',
                hintStyle: TextStyle(color: Colors.white),
              ),
              controller: emailController,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _resetPassword,
            child: const Text('Reset Password',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
