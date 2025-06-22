import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Wichtig: Importiere deinen MYAuthProvider
import '../providers/auth_provider.dart'; // Stelle sicher, dass der Pfad stimmt!

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitResetPasswordRequest() async {
    if (_isLoading) return;
    final String email = emailController.text.trim();

    if (email.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    bool wasSuccessful = await authProvider.performSendPasswordResetEmail(email);

    if (mounted) {
      setState(() { _isLoading = false; });
    } else {
      return;
    }

    if (!mounted) return;
    if (wasSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Please check your inbox (and spam folder).',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // authProvider wurde schon geholt: final authProvider = Provider.of<MYAuthProvider>(context, listen: false);
      final errorMsg = authProvider.errorMessage ?? 'Could not send password reset email. Please check the address and try again.';
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
    // Dieses Widget gibt jetzt nur den Inhalt des Formulars zurück.
    // Das SingleChildScrollView und Padding sind hier, da der Screen kein generelles Layout anwendet.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Enter your email address below and we will send you a link to reset your password.',
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextField(
            controller: emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration( /* ... deine Dekoration ... */ ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitResetPasswordRequest(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom( /* ... dein Style ... */ ),
            onPressed: _isLoading ? null : _submitResetPasswordRequest,
            child: _isLoading
                ? const SizedBox( /* ... Ladekreis ... */ )
                : const Text('Send Reset Email', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}