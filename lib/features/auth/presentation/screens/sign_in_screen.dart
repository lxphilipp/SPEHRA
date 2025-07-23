import 'package:flutter/material.dart';
import '../layouts/auth_page_layout.dart';
import '../widgets/sign_in_form.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageLayout(
      body: SignInForm(),
    );
  }
}