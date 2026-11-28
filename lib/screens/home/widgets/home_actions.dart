import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/spacing.dart';
import '../../../utils/app_routes.dart';
import '../../../widgets/app_button.dart';
import '../../auth/widgets/auth_switch_prompt.dart';

/// The main buttons on the Home screen. They change with login state
/// (see "Home screen" in docs/requirements.md):
///
/// - Logged out: Find Blood, Register as Donor, "Already have an account?
///   Log in".
/// - Logged in: Find Blood, Post Request, and Register as Donor only for
///   users who are not donors yet.
class HomeActions extends StatelessWidget {
  const HomeActions({super.key});

  /// Opens the placeholder screen with [featureName] as its title.
  /// Swap these for real routes as each screen gets built.
  void _openComingSoon(BuildContext context, String featureName) {
    Navigator.pushNamed(context, AppRoutes.comingSoon, arguments: featureName);
  }

  @override
  Widget build(BuildContext context) {
    // context.watch rebuilds this widget whenever AuthProvider changes,
    // so logging in or out swaps the buttons straight away.
    final user = context.watch<AuthProvider>().currentUser;
    final isLoggedIn = user != null;
    final showRegisterAsDonor = !isLoggedIn || !user.isDonor;

    // The gap between stacked buttons.
    const gap = SizedBox(height: AppSpacing.sm + 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: 'Find Blood',
          icon: Icons.search,
          // Logged-out users sign up first (just name, number, password),
          // then continue to Find Blood.
          onPressed: isLoggedIn
              ? () => Navigator.pushNamed(context, AppRoutes.findBlood)
              : () => Navigator.pushNamed(
                    context,
                    AppRoutes.seekerSignup,
                    arguments: true, // continue to Find Blood afterwards
                  ),
        ),
        if (isLoggedIn) ...[
          gap,
          AppButton(
            label: 'Post Request',
            icon: Icons.add,
            variant: AppButtonVariant.outlined,
            onPressed: () => _openComingSoon(context, 'Post Request'),
          ),
        ],
        if (showRegisterAsDonor) ...[
          gap,
          AppButton(
            label: 'Register as Donor',
            variant: AppButtonVariant.outlined,
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.donorRegistration),
          ),
        ],
        if (!isLoggedIn) ...[
          const SizedBox(height: AppSpacing.xs),
          AuthSwitchPrompt(
            question: 'Already have an account?',
            actionLabel: 'Log in',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          ),
        ],
      ],
    );
  }
}
