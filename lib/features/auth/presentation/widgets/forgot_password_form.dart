import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// A form that allows users to request a password reset email.
///
/// This widget provides a text field for the user to enter their email address
/// and a button to submit the request. It interacts with the
/// [AuthenticationProvider] to handle the password reset logic.
class ForgotPasswordForm extends StatefulWidget {
  /// Creates a [ForgotPasswordForm].
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

  /// Displays a snackbar with the given [message].
  ///
  /// If [isError] is true, the snackbar will have an error background color.
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

  /// Submits the password reset request.
  ///
  /// Validates the email input, then calls the [AuthenticationProvider]
  /// to send the password reset email. Shows appropriate feedback to the user
  /// via snackbars.
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
            decoration: const InputDecoration(
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
                color: theme.colorScheme.onPrimary,
              ),
            )
                : const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }
}
