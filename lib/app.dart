import 'package:flutter/material.dart';
import 'package:flutter_sdg/features/auth/presentation/screens/sign_in_screen.dart';

import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter layouts demo',
      home: const SignInScreen(),
      theme: AppTheme.darkTheme,
    );
  }
}