import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../utils/constants.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/raised_card.dart';
import 'widgets/auth_switch_prompt.dart';
import 'widgets/login_form.dart';

/// The Login screen. Layout only: the form logic lives in LoginForm.
///
/// A crimson band at the top holds the logo and tagline, and the login
/// card overlaps its bottom edge, matching the Home screen hero.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  /// Height of the crimson band behind the top of the screen.
  static const double _bandHeight = 200;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        // A Stack lets the band sit *behind* the content. Because the
        // Stack is inside the scroll view, the band scrolls with the page.
        child: Stack(
          children: [
            Container(height: _bandHeight, color: AppColors.primary),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(onDark: true)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppStrings.tagline,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.primarySoft),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const RaisedCard(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: LoginForm(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthSwitchPrompt(
                      question: "Don't have an account?",
                      actionLabel: 'Register',
                      onPressed: () {}, // Register screen comes later.
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
