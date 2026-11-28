import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../utils/constants.dart';
import 'app_logo.dart';
import 'raised_card.dart';

/// The page layout of the Login and Sign-up screens: a crimson band with
/// the logo and tagline, one raised card overlapping its bottom edge, and
/// an optional [footer] below the card (e.g. "Already have an account?").
class AuthBandLayout extends StatelessWidget {
  const AuthBandLayout({super.key, required this.card, this.footer});

  /// What goes inside the raised card, usually a form.
  final Widget card;

  final Widget? footer;

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
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primarySoft,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    RaisedCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: card,
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),
            // No app bar on these screens, so we add our own back arrow,
            // drawn last so it sits on top. Only shown when there is a
            // screen to go back to.
            if (Navigator.canPop(context))
              const SafeArea(child: BackButton(color: AppColors.onPrimary)),
          ],
        ),
      ),
    );
  }
}
