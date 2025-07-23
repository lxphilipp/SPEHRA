// lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/edit_profile_form.dart'; // Das neue Formular-Widget

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff040324),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OswaldLight',
          ),
        ),
        backgroundColor: const Color(0xff040324),
      ),
      body: const EditProfileForm(),
    );
  }
}