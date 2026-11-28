import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';
import '../../../../theme/spacing.dart';

/// "Step 2 of 5" with the step's title and a progress bar, shown at the
/// top of the donor registration form.
class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.stepNumber,
    required this.stepCount,
    required this.title,
  });

  final int stepNumber;
  final int stepCount;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STEP $stepNumber OF $stepCount', style: textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm + 4),
          // ClipRRect rounds the ends of the progress bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: LinearProgressIndicator(
              value: stepNumber / stepCount,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: AppColors.border,
              // Screen readers announce this instead of a bare percentage.
              semanticsLabel: 'Step $stepNumber of $stepCount',
            ),
          ),
        ],
      ),
    );
  }
}
