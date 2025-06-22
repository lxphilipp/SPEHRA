import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/auth/presentation/screens/sign_in_screen.dart';



class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    await authProvider.performSignOut();

    // WICHTIG: mounted-Check bevor UI-Operationen nach einem await stattfinden
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()), // Dein Login-Screen
          (Route<dynamic> route) => false, // Diese Bedingung entfernt alle Routen aus dem Stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _handleLogout(context), // Ruft die neue _handleLogout-Methode auf
      child: const Text(
        "Logout",
        style: TextStyle( // Behalte dein ursprüngliches Styling oder passe es an
          color: Colors.white,
          fontSize: 18, // Beispiel: Etwas kleiner für einen Standard-Button
          fontFamily: "OswaldRegular", // Wenn du diese Schriftart noch verwendest
        ),
      ),
    );

  }
}