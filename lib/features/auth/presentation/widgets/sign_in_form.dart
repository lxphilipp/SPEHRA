import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sdg/features/auth/presentation/screens/registration_screen.dart';
import 'package:flutter_sdg/features/auth/presentation/screens/forget_password_screen.dart';
import '../../../../core/layouts/responsive_main_navigation.dart';
import '../../../introduction/presentation/screens/introduction_main_screen.dart';
import '../providers/auth_provider.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // OPTIMIZED: Themed snackbar logic
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

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    final String email = emailController.text.trim();
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Please enter email and password.', isError: true);
      return;
    }

    setState(() { _isLoading = true; });
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    bool loginSuccess = await authProvider.performSignIn(email, password);

    if (mounted) {
      setState(() { _isLoading = false; });
    } else {
      return;
    }

    if (loginSuccess) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final isNewUser = user.metadata.creationTime == user.metadata.lastSignInTime;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => isNewUser ? const IntroductionMainScreen() : const ResponsiveMainNavigation()),
        );
      }
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Login failed. Please check your credentials.';
      _showSnackbar(errorMsg, isError: true);
    }
  }

  // --- Your original methods, now themed ---

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

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: Image.asset('assets/logo/Logo-Bild.png', width: 100, height: 100),
      ),
    );
  }

  Widget _buildEmailTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        controller: emailController,
        // OPTIMIZED: The decoration now uses the global theme
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.email),
          hintText: 'Email',
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
      ),
    );
  }

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
          // OPTIMIZED: The style comes from the TextButtonTheme
          child: const Text('Forgot Password?'),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          // OPTIMIZED: The style has been removed and is inherited from the global theme.
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