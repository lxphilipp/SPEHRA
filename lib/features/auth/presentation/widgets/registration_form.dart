import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Stelle sicher, dass der Pfad zu deinem MYAuthProvider korrekt ist
import '../providers/auth_provider.dart'; // Beispielpfad, passe ihn ggf. an

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  // Controller für jedes Textfeld
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // Optional: Weitere Controller, falls du mehr Felder hast (z.B. studyFieldController)

  bool _isLoading = false; // Für den Ladezustand des Buttons

  // Wichtig: Controller im dispose()-Callback aufräumen, um Speicherlecks zu vermeiden
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Methode, die aufgerufen wird, wenn der Registrierungs-Button gedrückt wird
  Future<void> _handleRegistration() async {
    if (_isLoading) return; // Verhindere mehrfache Ausführung während des Ladens

    // Hole die Werte aus den Textfeldern und trimme sie (Leerzeichen entfernen)
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim(); // Passwörter sollten i.d.R. nicht getrimmt werden, außer es ist explizit gewünscht
    // Optional: Werte aus weiteren Controllern holen

    // Einfache Client-seitige Validierung
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      if (!mounted) return; // Sicherheitscheck
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return; // Beende die Funktion hier
    }

    // --- Hier könntest du weitere Validierungen einfügen ---
    // z.B. E-Mail-Format prüfen, Passwortlänge/-komplexität (obwohl Firebase das auch serverseitig macht)
    // if (!email.contains('@')) { /* Snackbar: Invalid email */ return; }
    // if (password.length < 6) { /* Snackbar: Password too short */ return; }

    // Ladezustand aktivieren
    setState(() {
      _isLoading = true;
    });

    // Hole den MYAuthProvider
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    // Rufe die performRegistration-Methode im Provider auf
    bool registrationSuccess = await authProvider.performRegistration(
      email: email,
      password: password,
      name: name,
      // Optional: Weitere Parameter übergeben, falls deine performRegistration-Methode sie erwartet
      // studyField: studyFieldController.text.trim(),
      // school: schoolController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    } else {
      return;
    }

    // Erneuter mounted-Check vor UI-Operationen wie SnackBar oder Navigation
    if (!mounted) return;

    // Reaktion basierend auf dem Ergebnis vom Provider
    if (registrationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration successful! You can now log in.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Geht davon aus, dass dieser Screen über den Login-Screen geöffnet wurde
      }
      // Alternativ, wenn du direkt zum Login navigieren willst:
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignInScreen()));
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Registration failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    // Beispielhafter Aufbau (passe ihn an dein aktuelles UI an!):
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Macht Buttons breiter
        children: [
          const SizedBox(height: 20),
          const Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 30),

          // Namensfeld
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'User Name',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.person, color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreenAccent, width: 2),
              ),
            ),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),

          // E-Mail-Feld
          TextField(
            controller: emailController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.email, color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreenAccent, width: 2),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),

          // Passwort-Feld
          TextField(
            controller: passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.lock, color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreenAccent, width: 2),
              ),
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleRegistration(), // Absenden auch per Tastatur-Enter
          ),
          const SizedBox(height: 40),

          // Registrierungs-Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontFamily: 'OswaldRegular')
            ),
            onPressed: _isLoading ? null : _handleRegistration,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text('Register', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}