import 'package:flutter/material.dart';
import 'auth_page_layout.dart';
import '../widgets/sign_in_form.dart';

/// A screen that provides a user interface for signing in.
///
/// This screen displays a [SignInForm] within an [AuthPageLayout].
class SignInScreen extends StatelessWidget {
  /// Creates a [SignInScreen].
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageLayout(
      body: SignInForm(),
    );
  }
}