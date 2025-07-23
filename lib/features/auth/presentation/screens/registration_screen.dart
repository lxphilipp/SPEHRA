import 'package:flutter/material.dart';
import '../layouts/auth_page_layout.dart';
import '../widgets/registration_form.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageLayout(
      appBarTitleText: 'Create Account',
      showBackButton: true,
      body: RegistrationForm(),
    );
  }
}