import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// The "Compatible" tag on donors whose blood group differs from the
/// patient's but can still give to them (e.g. an O− donor for a B+
/// patient).
///
/// It is outlined in ink rather than filled, so it never looks like a
/// status colour. Open Requests reuses it as "You can give".
class CompatibleLabel extends StatelessWidget {
  const CompatibleLabel({super.key, this.text = 'Compatible'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inkMuted),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.compare_arrows, size: 16, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
