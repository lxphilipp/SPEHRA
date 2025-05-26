import 'package:flutter/material.dart';
import 'package:flutter_sdg/login/signin.dart'; // Dieser Import wird sich später ändern!

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter layout demo', // Du könntest hier einen besseren App-Titel eintragen
      home: SignInScreen(), // Vorerst bleibt das so, wird später durch den Router ersetzt
    );
  }
}