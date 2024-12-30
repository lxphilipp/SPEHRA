import 'package:flutter/material.dart';
import 'package:flutter_sdg/login/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with default option
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the app with AuthProvider
  runApp(ChangeNotifierProvider(
      create: (context) => MYAuthProvider(), child: const MyApp())); // تغييير
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter layout demo',
      home: Scaffold(
        body: SignInScreen(),
      ),
    );
  }
}
