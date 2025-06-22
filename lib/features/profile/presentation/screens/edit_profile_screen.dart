// lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import '../widgets/edit_profile_form.dart'; // Das neue Formular-Widget

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dein altes EditProfilPage war ein StatefulWidget, aber der Screen-Wrapper
    // kann oft ein StatelessWidget sein, wenn der State im Form-Widget liegt.
    return Scaffold(
      backgroundColor: const Color(0xff040324), // Aus AppColors.primaryBackground holen
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Aus AppColors.primaryText oder Theme holen
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white, // Aus AppColors.primaryText oder Theme holen
            fontFamily: 'OswaldLight',
          ),
        ),
        backgroundColor: const Color(0xff040324), // Aus AppColors.primaryBackground holen
      ),
      body: const EditProfileForm(), // Hier das Formular-Widget einbetten
    );
  }
}