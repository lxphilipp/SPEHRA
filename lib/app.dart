import 'package:flutter/material.dart';
import 'package:flutter_sdg/auth_wrapper.dart';
import 'core/theme/app_theme.dart';

/// The main application widget.
///
/// This widget is the root of the application. It sets up the [MaterialApp]
/// with the [AuthWrapper] as the home screen and applies the dark theme.
class MyApp extends StatelessWidget {
  /// Creates the main application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter layouts demo',
      home: const AuthWrapper(),
      theme: AppTheme.darkTheme,
    );
  }
}
