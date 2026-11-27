import 'package:flutter/material.dart';

import '../../utils/app_routes.dart';
import '../../widgets/auth_band_layout.dart';
import 'widgets/auth_switch_prompt.dart';
import 'widgets/login_form.dart';

/// The Login screen. Layout only: the form logic lives in LoginForm, and
/// the crimson band + raised card come from AuthBandLayout.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBandLayout(
      card: const LoginForm(),
      footer: AuthSwitchPrompt(
        question: "Don't have an account?",
        actionLabel: 'Register',
        // pushReplacementNamed swaps this screen for Sign-up instead of
        // stacking it on top, so Back still returns to Home.
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.seekerSignup),
      ),
    );
  }
}
