import 'package:flutter/material.dart';

import '../models/info_item.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

/// One step in a "How it works" sequence.
///
/// The icon sits in a stamp-style square. A thin line runs down to the
/// next step, so the steps read as one path from top to bottom.
/// Pass [isLast] = true on the final step to hide that line.
class StepCard extends StatelessWidget {
  const StepCard({super.key, required this.step, this.isLast = false});

  final InfoItem step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // IntrinsicHeight makes the left column as tall as the text on the
    // right, so the connecting line can stretch to fill that height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              _IconStamp(icon: step.icon),
              if (!isLast)
                const Expanded(
                  child: VerticalDivider(
                    width: 2,
                    thickness: 2,
                    color: AppColors.primarySoft,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              // Bottom padding is the gap between steps.
              padding: EdgeInsets.only(
                top: 2,
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(step.description, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A 44 x 44 square with a crimson border and icon, matching the
/// blood-group stamps.
class _IconStamp extends StatelessWidget {
  const _IconStamp({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Icon(icon, color: AppColors.primary, size: 22),
    );
  }
}
