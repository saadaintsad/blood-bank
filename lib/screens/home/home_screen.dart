import 'package:flutter/material.dart';

import '../../data/home_content.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/home_footer.dart';
import '../../widgets/home_hero.dart';
import '../../widgets/section_header.dart';
import '../../widgets/step_card.dart';
import '../../widgets/trust_point.dart';

/// The public Home screen. Anyone can see it without logging in.
///
/// It explains what Reddify does and offers the two main paths:
/// finding blood and becoming a donor. Buttons do nothing yet; they will
/// open other screens in later stages.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(onDark: true),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _LoginButton(onPressed: () {}),
          ),
        ],
      ),
      // SingleChildScrollView + Column, because this page is a short,
      // fixed set of sections (not a long list that needs ListView.builder).
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeHero(onFindBlood: () {}, onBecomeDonor: () {}),
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

/// White pill button for the crimson app bar.
class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      // Override the theme colours just for this button, because the
      // normal crimson button would disappear on the crimson bar.
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        minimumSize: const Size(88, 40),
      ),
      child: const Text('Log in'),
    );
  }
}
