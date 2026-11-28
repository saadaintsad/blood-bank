import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../utils/emergency_rules.dart';
import '../../../widgets/app_button.dart';

/// Explains the Emergency Alert and holds its button (walkthrough
/// Scene 6). The button is disabled with "Available again in X days"
/// while the 15-day limit runs.
class EmergencyAlertCard extends StatelessWidget {
  const EmergencyAlertCard({
    super.key,
    required this.district,
    required this.daysLeft,
    required this.onSend,
    this.isSending = false,
  });

  /// The request's district, e.g. "Dhaka".
  final String district;

  /// 0 when the alert can be sent now.
  final int daysLeft;

  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canSend = daysLeft == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Text(
                    'Need more donors?',
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'An Emergency Alert reaches every donor in $district, whatever '
              'their blood group, so they can help or share your request. '
              'You can send one every $emergencyCooldownDays days.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: canSend
                  ? 'Emergency Alert'
                  : 'Available again in '
                        '${daysLeft == 1 ? '1 day' : '$daysLeft days'}',
              icon: canSend ? Icons.campaign_outlined : Icons.schedule,
              variant: AppButtonVariant.outlined,
              isLoading: isSending,
              onPressed: canSend ? onSend : null,
            ),
          ],
        ),
      ),
    );
  }
}
