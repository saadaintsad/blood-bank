import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../widgets/app_button.dart';

/// Mark Fulfilled (the main action, full-width red) and Cancel (outlined)
/// for the seeker's own open request.
class SeekerActions extends StatelessWidget {
  const SeekerActions({
    super.key,
    required this.onMarkFulfilled,
    required this.onCancel,
    this.isBusy = false,
  });

  final VoidCallback onMarkFulfilled;
  final VoidCallback onCancel;

  /// True while the request is being closed: spinner, no second tap.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: 'Mark Fulfilled',
          icon: Icons.check,
          isLoading: isBusy,
          onPressed: onMarkFulfilled,
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        AppButton(
          label: 'Cancel request',
          icon: Icons.close,
          variant: AppButtonVariant.outlined,
          onPressed: isBusy ? null : onCancel,
        ),
      ],
    );
  }
}
