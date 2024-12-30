import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdg/homepage/homepage.dart';
import 'package:flutter_sdg/layout/login_layout.dart';
import 'package:flutter_sdg/login/create_user_account.dart';
import 'package:flutter_sdg/login/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sdg/question/introduction1.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginLayout(body: SignIn());
  }
}

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSignInHeader(),
          _buildLogo(),
          _buildEmailTextField(emailController),
          _buildPasswordTextField(passwordController),
          _buildForgotPasswordButton(context),
          _buildLoginButton(context),
          _buildCreateAccountButton(context),
        ],
      ),
    );
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
        child:
            Image.asset('assets/logo/Logo-Bild.png', width: 100, height: 100),
      ),
    );
  }

  Widget _buildEmailTextField(TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
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
        controller: controller,
      ),
    );
  }

  Widget _buildPasswordTextField(TextEditingController passwordController) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextField(
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
        controller: passwordController,
        obscureText: true,
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ForgotPasswordScreen(),
          ));
        },
        child: const Text('Forgot Password?',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final authProvider = Provider.of<MYAuthProvider>(context, listen: false);

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
            onPressed: () async {
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              )
                  .then((value) async {
                authProvider.login(emailController.text);
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get()
                      .then((userSnapshot) async {
                    // Get the shared preferences instance
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    // Check if it's the user's first login
                    bool isFirstLogin = prefs.getBool('isFirstLogin') ?? true;

                    // If it's the first login, show the introduction page
                    if (isFirstLogin) {
                      // Set 'isFirstLogin' to false
                      await prefs.setBool('isFirstLogin', false);

                      // Navigate to the introduction page
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const IntroductionPage()));
                    } else {
                      // If it's not the first login, navigate to the home page
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomePageScreen()));
                    }
                  });
                }
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Login was not successful',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            child: const Text('LOGIN', style: TextStyle(color: Colors.white)),
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
            builder: (context) => const RegistrationScreen(),
          ));
        },
        child:
            const Text('Create Account', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
