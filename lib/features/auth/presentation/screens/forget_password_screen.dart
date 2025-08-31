import 'package:flutter/material.dart';
import 'auth_page_layout.dart';
import '../widgets/forgot_password_form.dart';

/// A screen that allows users to reset their password.
///
/// This screen provides a form for users to enter their email address
/// and request a password reset link.
class ForgotPasswordScreen extends StatelessWidget {
  /// Creates a [ForgotPasswordScreen].
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
