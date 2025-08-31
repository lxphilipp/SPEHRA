import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sdg/features/auth/presentation/screens/registration_screen.dart';
import 'package:flutter_sdg/features/auth/presentation/screens/forget_password_screen.dart';
import '../../../../auth_wrapper.dart';
import '../providers/auth_provider.dart';

/// A form widget for user sign-in.
///
/// This widget provides fields for email and password input, along with
/// buttons for signing in, navigating to the registration screen, and
/// navigating to the forgot password screen.
class SignInForm extends StatefulWidget {
  /// Creates a [SignInForm].
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

/// The state for the [SignInForm] widget.
class _SignInFormState extends State<SignInForm> {
  /// Controls the email input field.
  final TextEditingController emailController = TextEditingController();
  /// Controls the password input field.
  final TextEditingController passwordController = TextEditingController();
  /// Indicates whether a sign-in operation is in progress.
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Shows a snackbar with the given [message].
  ///
  /// The snackbar's background color is determined by the [isError] flag.
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

  /// Handles the login process when the user attempts to sign in.
  ///
  /// Validates the email and password fields, then calls the
  /// [AuthenticationProvider] to perform the sign-in operation.
  /// Navigates to the [AuthWrapper] on success, or shows an error
  /// message on failure.
  Future<void> _handleLogin() async {
    if (_isLoading) return;
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Please enter email and password.', isError: true);
      return;
    }
    final bool isEmailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if (!isEmailValid) {
      _showSnackbar('Please enter a valid email address.', isError: true);
      return;
    }

    setState(() { _isLoading = true; });
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    final String? errorMessage = await authProvider.performSignIn(email, password);

    if (!mounted) return;

    setState(() { _isLoading = false; });

    // Check the result
    if (errorMessage == null) {
      // Success! Navigate. The AuthWrapper will handle the rest.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    } else {
      // Failure! Show the returned message.
      _showSnackbar(errorMessage, isError: true);
    }
  }

  /// Builds the header text for the sign-in form.
  Widget _buildSignInHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'SIGN IN',
        // OPTIMIZED: Style from the theme
        style: theme.textTheme.headlineMedium?.copyWith(
          fontFamily: 'OswaldLight',
        ),
      ),
    );
  }

  /// Builds the logo image for the sign-in form.
  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: Image.asset('assets/logo/Logo-Bild.png', width: 100, height: 100),
      ),
    );
  }

  /// Builds the email input text field.
  Widget _buildEmailTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        controller: emailController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.email),
          hintText: 'Email',
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  /// Builds the password input text field.
  Widget _buildPasswordTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        controller: passwordController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.lock),
          hintText: 'Password',
        ),
        obscureText: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _handleLogin(),
      ),
    );
  }

  /// Builds the "Forgot Password?" button.
  Widget _buildForgotPasswordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ));
          },
          child: const Text('Forgot Password?'),
        ),
      ),
    );
  }

  /// Builds the login button.
  Widget _buildLoginButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.onPrimary,
            ),
          )
              : const Text('LOGIN'),
        ),
      ),
    );
  }

  /// Builds the "Create Account" button.
  Widget _buildCreateAccountButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const RegistrationScreen(),
          ));
        },
        child: const Text('Create Account'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSignInHeader(context),
          _buildLogo(),
          _buildEmailTextField(context),
          _buildPasswordTextField(context),
          _buildForgotPasswordButton(context),
          _buildLoginButton(context),
          _buildCreateAccountButton(context),
        ],
      ),
    );
  }
}
