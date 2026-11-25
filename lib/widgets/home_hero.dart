import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'app_button.dart';
import 'hero_donor_card.dart';

/// The top section of the Home screen.
///
/// A crimson band (continuing the app bar) holds the headline. The donor
/// card illustration sits across the bottom edge of the band, and the two
/// main buttons sit below it.
class HomeHero extends StatelessWidget {
  const HomeHero({
    super.key,
    required this.onFindBlood,
    required this.onBecomeDonor,
  });

  final VoidCallback onFindBlood;
  final VoidCallback onBecomeDonor;

  /// How much of the card's height (0 to 1) has crimson behind it.
  static const double _bandShare = 0.4;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headlineStyle = textTheme.displaySmall?.copyWith(
      color: Colors.white,
      fontSize: 36,
      height: 1.1,
      letterSpacing: -0.8,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. The crimson band with the headline.
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md + 4,
            AppSpacing.md,
            AppSpacing.md + 4,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Donate Blood,', style: headlineStyle),
              // Second line in soft pink: emphasis by colour, same size.
              Text(
                'Save Lives.',
                style: headlineStyle?.copyWith(color: AppColors.primarySoft),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Find voluntary donors near you by blood group and '
                'district, and reach them in one call.',
                style: textTheme.bodyLarge
                    ?.copyWith(color: AppColors.primarySoft),
              ),
            ],
          ),
        ),

        // 2. The card row. Its background is crimson on top and off-white
        // below (a gradient with a hard edge, no blending), so the band
        // seems to continue behind the top part of the card.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary,
                AppColors.background,
                AppColors.background,
              ],
              // Both middle colours sit at the same point: a sharp line.
              stops: [0, _bandShare, _bandShare, 1],
            ),
          ),
          child: const HeroDonorCard(),
        ),

        // 3. The two main actions.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            0,
          ),
          child: Column(
            children: [
              AppButton(
                label: 'Find Blood',
                icon: Icons.search,
                onPressed: onFindBlood,
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              AppButton(
                label: 'Become a Donor',
                variant: AppButtonVariant.outlined,
                onPressed: onBecomeDonor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
