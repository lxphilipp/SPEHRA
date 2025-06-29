import 'package:flutter/material.dart';
// Importiere das NEUE Layout und dein Formular-Widget
import '../layouts/auth_page_layout.dart';
import '../widgets/sign_in_form.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageLayout(
      body: SignInForm(),
    );
  }
}