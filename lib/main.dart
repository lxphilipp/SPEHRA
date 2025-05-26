import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart'; // Dieser Import wird sich später ändern!
import 'app.dart'; // NEUER IMPORT für die MyApp-Klasse

void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the app with AuthProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => MYAuthProvider(), // Beachte: 'MYAuthProvider' ist ungewöhnlich. Üblich wäre 'AuthProvider'
      child: const MyApp(),
    ),
  );
}