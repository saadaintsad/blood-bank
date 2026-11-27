import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/spacing.dart';
import 'blood_group_badge.dart';
import 'raised_card.dart';
import 'status_chip.dart';

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
                const StatusChip(
                  status: DonorStatus.available,
                  label: 'Available to donate',
                ),
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
