import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/spacing.dart';
import '../../utils/constants.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/home_footer.dart';
import '../../widgets/home_hero.dart';
import '../../widgets/section_header.dart';
import '../../widgets/step_card.dart';
import '../../widgets/trust_point.dart';
import 'home_content.dart';
import 'widgets/home_actions.dart';

/// The Home screen. Anyone can see it, logged in or not.
///
/// It explains what Reddify does and shows the main actions. Which
/// actions appear depends on login state (see HomeActions).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(onDark: true),
        actions: [
          // Temporary: log out lives here until the Profile screen exists.
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
              onPressed: () => context.read<AuthProvider>().logOut(),
            ),
        ],
      ),
      // SingleChildScrollView + Column, because this page is a short,
      // fixed set of sections (not a long list that needs ListView.builder).
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HomeHero(actions: HomeActions()),
            _buildHowItWorks(),
            const SizedBox(height: AppSpacing.lg),
            _buildWhyReddify(),
            const SizedBox(height: AppSpacing.xxl),
            const HomeFooter(),
          ],
        ),
      ),
    );
  }

  /// "How it works": three connected steps.
  Widget _buildHowItWorks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'How it works'),
          const SizedBox(height: AppSpacing.md),
          // A for-loop with an index, so we know which step is the last.
          for (var i = 0; i < howItWorksSteps.length; i++)
            StepCard(
              step: howItWorksSteps[i],
              isLast: i == howItWorksSteps.length - 1,
            ),
        ],
      ),
    );
  }

  /// "Why Reddify": three trust points inside one card.
  Widget _buildWhyReddify() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: SectionHeader(title: 'Why ${AppStrings.appName}'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < trustPoints.length; i++) ...[
                  // A divider between points, but not before the first one.
                  if (i > 0) const Divider(indent: 72),
                  TrustPoint(point: trustPoints[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
