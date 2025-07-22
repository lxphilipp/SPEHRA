import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
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

  Future<void> _submitResetPasswordRequest() async {
    if (_isLoading) return;
    final String email = emailController.text.trim();

    if (email.isEmpty) {
      _showSnackbar('Please enter your email address.', isError: true);
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

    if (wasSuccessful) {
      _showSnackbar('Password reset email sent. Please check your inbox (and spam folder).');
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Could not send password reset email.';
      _showSnackbar(errorMsg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            'Enter your email address below and we will send you a link to reset your password.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextField(
            controller: emailController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Email',
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitResetPasswordRequest(),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitResetPasswordRequest,
            child: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                // The color of the loading circle is inherited from the button
                color: theme.colorScheme.onPrimary,
              ),
            )
            // The text color is also inherited from the button theme
                : const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }
}