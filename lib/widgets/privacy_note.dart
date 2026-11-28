import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// A small lock icon and text telling the user a detail stays private,
/// e.g. "Private. Never shown to other users."
class PrivacyNote extends StatelessWidget {
  const PrivacyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.lock_outline,
              size: 14,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          // Expanded lets long text wrap instead of overflowing.
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
