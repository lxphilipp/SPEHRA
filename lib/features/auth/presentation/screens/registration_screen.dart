import 'package:flutter/material.dart';
import 'auth_page_layout.dart';
import '../widgets/registration_form.dart';

/// Screen for user registration.
///
/// Displays a form for new users to create an account.
class RegistrationScreen extends StatelessWidget {
  /// Creates a [RegistrationScreen].
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
