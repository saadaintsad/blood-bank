import 'package:flutter/material.dart';

import '../models/donor_search_result.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'blood_group_badge.dart';
import 'compatible_label.dart';
import 'contact_buttons.dart';
import 'status_chip.dart';

/// One donor in the Find Blood results.
///
/// Shows the blood group stamp at the start of the row, then name, area,
/// gender and status. Pass [phone] only when the viewer may see it; then
/// the number and Call / SMS buttons appear too.
class DonorCard extends StatelessWidget {
  const DonorCard({
    super.key,
    required this.donor,
    this.phone,
    this.onTap,
  });

  final DonorSearchResult donor;

  /// The donor's number, or null to keep it hidden.
  final String? phone;

  /// Opens the donor's details.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final phone = this.phone;

    // Card draws the surface and warm border from the theme. InkWell adds
    // the tap ripple; clipBehavior keeps the ripple inside the corners.
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BloodGroupBadge(bloodGroup: donor.bloodGroup),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(donor.name, style: textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${donor.area}, ${donor.district} · '
                          '${donor.gender.label}',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.inkMuted),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Wrap moves the chips to a new line on narrow
                        // screens instead of overflowing.
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            StatusChip(
                              status: donor.status,
                              label: donor.statusLabel,
                            ),
                            if (!donor.isExactMatch) const CompatibleLabel(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.inkMuted),
                ],
              ),
              if (phone != null) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm + 4),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 18, color: AppColors.inkMuted),
                    const SizedBox(width: AppSpacing.sm),
                    Text(phone, style: textTheme.titleSmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm + 4),
                ContactButtons(phone: phone),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
