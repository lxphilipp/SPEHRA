import 'package:flutter/material.dart';
// Importiere das NEUE Layout und dein Formular-Widget
import '../layouts/auth_page_layout.dart';
import '../widgets/registration_form.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageLayout(
      appBarTitleText: 'Create Account', // Wir wollen hier einen Text-Titel
      showBackButton: true,             // Und einen Zurück-Pfeil
      // appBarLeading: null, // Wenn du einen Custom Back-Button wolltest, hier übergeben
      body: RegistrationForm(),
    );
  }
}