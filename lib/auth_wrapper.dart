// lib/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/layouts/responsive_main_navigation.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();

    // Show a loading screen while checking the initial auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If logged in, show the main app. Otherwise, show the sign-in screen.
    if (authProvider.isLoggedIn) {
      return const ResponsiveMainNavigation();
    } else {
      return const SignInScreen();
    }
  }
}