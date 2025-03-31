import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Register',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OswaldLight',
          ),
        ),
        backgroundColor: const Color(0xff040324),
      ),
      body: const RegistrationForm(),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studyFieldController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();

  void _registerUser() {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
        .then((value) {
      String uid = value.user!.uid;
      String userEmail = value.user!.email!;
      String name = nameController.text;
      // Saves uid an E-Mail in Firestore
      FirebaseFirestore.instance.collection('users').doc(uid).set({
        //'User UID': uid,
        //'Email': userEmail,
        'id': uid,
        'email': userEmail,
        'name': name,
        'about': '',
        'imageURL': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'lastActived': '',
        'pushToken': '',
        'online': true,
        'my_users': [],
        'age': 0,
        'studyField': "",
        'school': "",
        'level': 1,
        'points': 0,
        'ongoingTasks': [],
        'completedTasks': [],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration successful. You can now log in.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to register: $error',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: Icon(Icons.person),
                prefixIconColor: Colors.white,
                hintText: ' Username',
                hintStyle: TextStyle(color: Colors.white),
              ),
              controller: nameController,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: Icon(Icons.email),
                prefixIconColor: Colors.white,
                hintText: ' Email',
                hintStyle: TextStyle(color: Colors.white),
              ),
              controller: emailController,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                prefixIcon: Icon(Icons.lock),
                prefixIconColor: Colors.white,
                hintText: ' Password',
                hintStyle: TextStyle(color: Colors.white),
              ),
              controller: passwordController,
              obscureText: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _registerUser,
            child:
                const Text('Register', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
