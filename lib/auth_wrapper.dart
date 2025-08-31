import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/layouts/responsive_main_navigation.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/introduction/presentation/screens/introduction_main_screen.dart';
import 'features/profile/presentation/providers/user_profile_provider.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';

/// A widget that wraps the authentication flow.
///
/// This widget listens to the [AuthenticationProvider] and [UserProfileProvider]
/// to determine which screen to show to the user.
///
/// If the user is logged in and has completed the introduction, it shows the
/// [ResponsiveMainNavigation] screen.
///
/// If the user is logged in but has not completed the introduction, it shows
/// the [IntroductionMainScreen].
///
/// If the user is not logged in, it shows the [SignInScreen].
///
/// While the authentication or profile data is loading, it shows a
/// [CircularProgressIndicator].
class AuthWrapper extends StatelessWidget {
  /// Creates an [AuthWrapper].
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

    // If the user is logged in
    if (authProvider.isLoggedIn) {
      final userProfile = profileProvider.userProfile;

      // When the profile is loaded
      if (userProfile != null) {
        // Check our new, reliable status
        if (userProfile.hasCompletedIntro) {
          return const ResponsiveMainNavigation(); // Go to the main app
        } else {
          return const IntroductionMainScreen(); // Show the introduction
        }
      }

      // Fallback if the profile is still loading or an error has occurred
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );

    } else {
      // If not logged in, show the login screen
      return const SignInScreen();
    }
  }
}
