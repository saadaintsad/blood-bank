import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';
import '../../../../theme/spacing.dart';
import '../../../../utils/eligibility.dart';
import '../../../../widgets/app_button.dart';

/// Shown instead of the form when the date of birth is outside the donor
/// age range. People outside it can still use Reddify as seekers.
class AgeBlockedPanel extends StatelessWidget {
  const AgeBlockedPanel({
    super.key,
    required this.age,
    required this.isNewAccount,
    required this.isLoading,
    required this.onCreateSeekerAccount,
    required this.onChangeDateOfBirth,
    required this.onBackToHome,
  });

  final int age;

  /// New users get "Create account to find blood"; logged-in users already
  /// have an account and get "Back to Home".
  final bool isNewAccount;
  final bool isLoading;
  final VoidCallback onCreateSeekerAccount;
  final VoidCallback onChangeDateOfBirth;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reason = age < minDonorAge
        ? 'You are $age, so you can register as a donor once you turn '
            '$minDonorAge.'
        : 'You are $age, which is above the donor age limit of $maxDonorAge.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Icon(Icons.favorite_border, size: AppSpacing.xxl, color: AppColors.primary),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Donors must be $minDonorAge to $maxDonorAge years old',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(reason, textAlign: TextAlign.center, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'You can still use Reddify to find blood and post requests for '
          'someone who needs it.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isNewAccount)
          AppButton(
            label: 'Create account to find blood',
            icon: Icons.search,
            isLoading: isLoading,
            onPressed: onCreateSeekerAccount,
          )
        else
          AppButton(label: 'Back to Home', onPressed: onBackToHome),
        const SizedBox(height: AppSpacing.sm + 4),
        AppButton(
          label: 'Change date of birth',
          variant: AppButtonVariant.outlined,
          onPressed: isLoading ? null : onChangeDateOfBirth,
        ),
      ],
    );
  }
}
