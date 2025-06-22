import 'package:flutter/material.dart';
// Importiere das NEUE Layout und dein Formular-Widget
import '../layouts/auth_page_layout.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageLayout(
      appBarTitleText: 'Reset Password', // Wir wollen hier einen Text-Titel
      showBackButton: true,            // Und einen Zurück-Pfeil
      body: ForgotPasswordForm(),
    );
  }
}