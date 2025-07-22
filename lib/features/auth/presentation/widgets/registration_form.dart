import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_isLoading) return;
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar('Please fill in all required fields.', isError: true);
      return;
    }

    setState(() { _isLoading = true; });
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    bool registrationSuccess = await authProvider.performRegistration(
      email: email,
      password: password,
      name: name,
    );

    if (mounted) {
      setState(() { _isLoading = false; });
    } else {
      return;
    }

    if (registrationSuccess) {
      _showSnackbar('Registration successful! You can now log in.');
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Registration failed. Please try again.';
      _showSnackbar(errorMsg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration buildInputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 30),

          TextField(
            controller: nameController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: buildInputDecoration('User Name', Icons.person),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),

          TextField(
            controller: emailController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: buildInputDecoration('Email', Icons.email),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),

          TextField(
            controller: passwordController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: buildInputDecoration('Password', Icons.lock),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleRegistration(),
          ),
          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleRegistration,
            child: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
                : const Text('Register'),
          ),
        ],
      ),
    );
  }
}