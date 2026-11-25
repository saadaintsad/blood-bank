import 'package:flutter/material.dart';

import '../models/info_item.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

/// One reason to trust Reddify: an icon in a soft circle, a title and
/// a short sentence. Meant to be stacked inside a single card.
class TrustPoint extends StatelessWidget {
  const TrustPoint({super.key, required this.point});

  final InfoItem point;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            child: Icon(point.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.title, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(point.description, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
