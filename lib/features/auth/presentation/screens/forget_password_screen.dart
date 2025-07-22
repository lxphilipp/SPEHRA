import 'package:flutter/material.dart';
// Import the NEW layout and your form widget
import '../layouts/auth_page_layout.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageLayout(
      appBarTitleText: 'Reset Password',
      showBackButton: true,
      body: ForgotPasswordForm(),
    );
  }
}