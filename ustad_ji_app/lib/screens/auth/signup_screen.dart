import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Signup reuses the login flow for the hackathon.
/// Replace with a dedicated signup form when backend auth is ready.
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
