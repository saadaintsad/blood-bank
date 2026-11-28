import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// One labelled line on a details screen (Donor details, Request details): an icon, a small grey
/// label and the value (text or any widget, such as a StatusChip).
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                value,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
