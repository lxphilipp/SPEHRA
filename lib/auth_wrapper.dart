import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/layouts/responsive_main_navigation.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/introduction/presentation/screens/introduction_main_screen.dart';
import 'features/profile/presentation/providers/user_profile_provider.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    final profileProvider = context.watch<UserProfileProvider>();

    if (authProvider.isLoading || (authProvider.isLoggedIn && profileProvider.isLoadingProfile)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Wenn der Benutzer eingeloggt ist
    if (authProvider.isLoggedIn) {
      final userProfile = profileProvider.userProfile;

      // Wenn das Profil geladen ist
      if (userProfile != null) {
        // Prüfe unseren neuen, zuverlässigen Status
        if (userProfile.hasCompletedIntro) {
          return const ResponsiveMainNavigation(); // Gehe zur Haupt-App
        } else {
          return const IntroductionMainScreen(); // Zeige die Einführung
        }
      }

      // Fallback, falls das Profil noch lädt oder ein Fehler aufgetreten ist
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );

    } else {
      // Wenn nicht eingeloggt, zeige den Anmeldebildschirm
      return const SignInScreen();
    }
  }
}