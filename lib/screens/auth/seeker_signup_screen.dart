import 'package:flutter/material.dart';

import '../../utils/app_routes.dart';
import '../../widgets/auth_band_layout.dart';
import 'widgets/auth_switch_prompt.dart';
import 'widgets/seeker_signup_form.dart';

/// Seeker sign-up: name, mobile number and password only (see "Accounts
/// and login" in docs/requirements.md). Layout only; the form logic lives
/// in SeekerSignupForm.
///
/// Open it with `arguments: true` to continue to Find Blood afterwards.
class SeekerSignupScreen extends StatelessWidget {
  const SeekerSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Values passed to pushNamed(..., arguments: x) arrive in the route's
    // settings.
    final continueToFindBlood =
        ModalRoute.of(context)?.settings.arguments == true;

    return AuthBandLayout(
      card: SeekerSignupForm(continueToFindBlood: continueToFindBlood),
      footer: AuthSwitchPrompt(
        question: 'Already have an account?',
        actionLabel: 'Log in',
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.login),
      ),
    );
  }
}
