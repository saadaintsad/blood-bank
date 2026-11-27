import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';
import '../../../../theme/spacing.dart';
import '../../../../widgets/app_button.dart';

/// The bar at the bottom of the registration form: an outlined Back
/// button and a red Next (or Finish) button that takes the rest of the
/// width.
class StepNavBar extends StatelessWidget {
  const StepNavBar({
    super.key,
    required this.showBack,
    required this.isLastStep,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
  });

  /// Hidden on the first step, where the app bar's arrow already leaves.
  final bool showBack;
  final bool isLastStep;
  final bool isLoading;
  final VoidCallback onBack;

  /// Pass null to disable Next/Finish (e.g. until consent is given).
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      // SafeArea keeps the buttons above the phone's gesture bar.
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showBack) ...[
              AppButton(
                label: 'Back',
                variant: AppButtonVariant.outlined,
                fullWidth: false,
                // No going back while the account is being saved.
                onPressed: isLoading ? null : onBack,
              ),
              const SizedBox(width: AppSpacing.sm + 4),
            ],
            Expanded(
              child: AppButton(
                label: isLastStep ? 'Finish' : 'Next',
                icon: isLastStep ? Icons.check : null,
                isLoading: isLoading,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
