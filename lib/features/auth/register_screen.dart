import 'package:flutter/material.dart';
import 'login_screen.dart';

/// Legacy alias: Typed registration is replaced with Google Sign-In.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
