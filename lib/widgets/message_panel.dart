import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// A centred icon, title, optional message and optional button.
///
/// Used for the hint, empty, error and "limit reached" states of list and
/// form screens (Find Blood, My Requests, Post Request).
class MessagePanel extends StatelessWidget {
  const MessagePanel({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;

  /// Usually an AppButton, e.g. "Try again".
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(icon, size: AppSpacing.xl + 8, color: AppColors.inkMuted),
          const SizedBox(height: AppSpacing.sm + 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}
