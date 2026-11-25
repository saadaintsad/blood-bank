import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'blood_group_badge.dart';
import 'raised_card.dart';

/// The hero illustration: a donor card with a big blood-group stamp.
///
/// It is built only from widgets (no image). When the screen opens, the
/// stamp "presses" down onto the card once, like a real rubber stamp.
class HeroDonorCard extends StatelessWidget {
  const HeroDonorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RaisedCard(
      child: Row(
        children: [
          // O- is the universal donor group, a fitting example for the hero.
          const _StampPress(
            child: BloodGroupBadge(
              bloodGroup: 'O-',
              size: BloodGroupBadgeSize.large,
            ),
          ),
          const SizedBox(width: AppSpacing.md + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your donor card', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Blood group, district and availability, ready for '
                  'whoever needs you.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm + 2),
                const _AvailableChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Plays a one-time "stamp pressed down" animation on its child.
class _StampPress extends StatelessWidget {
  const _StampPress({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Respect the system "reduce/remove animations" setting.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    // TweenAnimationBuilder animates a value from begin to end once.
    // The stamp starts slightly larger and settles to its normal size.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.3, end: 1.0),
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 650),
      curve: Curves.easeOutExpo,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }
}

/// "Available to donate" label. Uses an icon and a word, not colour alone.
class _AvailableChip extends StatelessWidget {
  const _AvailableChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            'Available to donate',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
