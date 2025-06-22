import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Wird noch für user.metadata benötigt
import 'package:flutter_sdg/features/home/presentation/screens/home_screen.dart'; // Pfad anpassen
import 'package:flutter_sdg/question/introduction1.dart'; // Pfad anpassen
import 'package:flutter_sdg/features/auth/presentation/screens/registration_screen.dart'; // Pfad anpassen
import 'package:flutter_sdg/features/auth/presentation/screens/forget_password_screen.dart'; // Pfad anpassen
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

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    bool loginSuccess = await authProvider.performSignIn(email, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    } else {
      return;
    }

    if (!mounted) return;

    if (loginSuccess) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.metadata.creationTime == user.metadata.lastSignInTime) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const IntroductionPage()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful, but user data not found.')),
        );
      }
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Login failed. Please check your credentials.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSignInHeader() {
    return const Center(
      child: Text(
        'SIGN IN',
        style: TextStyle(
          fontFamily: 'OswaldLight',
          fontSize: 30,
          color: Colors.white,
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

  Widget _buildEmailTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        controller: emailController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          prefixIcon: Icon(Icons.email),
          prefixIconColor: Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintText: ' Email',
          hintStyle: TextStyle(color: Colors.white),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
        controller: passwordController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          prefixIcon: Icon(Icons.lock),
          prefixIconColor: Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintText: ' Password',
          hintStyle: TextStyle(color: Colors.white),
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
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ForgotPasswordScreen(), // Sicherstellen, dass dies importiert ist
          ));
        },
        child: const Text('Forgot Password?', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              elevation: 0,
              side: const BorderSide(color: Colors.green),
              minimumSize: const Size.fromHeight(55),
            ),
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text('LOGIN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const RegistrationScreen(), // Sicherstellen, dass dies importiert ist
          ));
        },
        child: const Text('Create Account', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSignInHeader(),
          _buildLogo(),
          _buildEmailTextField(),
          _buildPasswordTextField(),
          _buildForgotPasswordButton(context),
          _buildLoginButton(context),
          _buildCreateAccountButton(context),
        ],
      ),
    );
  }
}