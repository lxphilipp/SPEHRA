// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_sdg/auth_wrapper.dart'; // <-- Importiere die neue Datei
import 'core/theme/app_theme.dart';
// Deine anderen Imports bleiben unverändert

class MyApp extends StatelessWidget {
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