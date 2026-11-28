import 'package:flutter/material.dart';

import '../../../models/interested_donor.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../utils/date_format.dart';
import '../../../widgets/blood_group_badge.dart';
import '../../../widgets/contact_buttons.dart';
import '../../../widgets/privacy_note.dart';
import '../../../widgets/section_header.dart';

/// The seeker's list of donors who tapped "I'm Interested" on their
/// request, each with their number and Call / SMS (walkthrough Scene 5).
class InterestedDonorsSection extends StatelessWidget {
  const InterestedDonorsSection({
    super.key,
    required this.donors,
    required this.today,
  });

  /// First to respond first.
  final List<InterestedDonor> donors;

  /// Used to leave the date out of "Interested at 4:10 PM" for today.
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: donors.isEmpty
              ? 'Interested donors'
              : 'Interested donors (${donors.length})',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (donors.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md + 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.hourglass_empty, color: AppColors.inkMuted),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Text(
                      'No donors have responded yet. Donors who tap '
                      "I'm Interested will appear here with their number.",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          for (final donor in donors) ...[
            _InterestedDonorCard(donor: donor, today: today),
            const SizedBox(height: AppSpacing.sm + 4),
          ],
      ],
    );
  }
}

/// One interested donor: stamp, name, area, when they responded, and
/// their number with Call / SMS.
class _InterestedDonorCard extends StatelessWidget {
  const _InterestedDonorCard({required this.donor, required this.today});

  final InterestedDonor donor;
  final DateTime today;

  /// "Interested at 4:10 PM" today, "Interested 27 Nov 2026, 4:10 PM"
  /// on other days.
  String get _respondedText {
    final at = donor.tappedAt;
    final isToday =
        at.year == today.year && at.month == today.month && at.day == today.day;
    return isToday
        ? 'Interested at ${formatTime(at)}'
        : 'Interested ${formatDate(at)}, ${formatTime(at)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mutedStyle = textTheme.bodyMedium?.copyWith(
      color: AppColors.inkMuted,
    );

    return Card(
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
                      Text(donor.area, style: mutedStyle),
                      const SizedBox(height: 2),
                      Text(_respondedText, style: mutedStyle),
                      const SizedBox(height: AppSpacing.xs),
                      Text(donor.phone, style: textTheme.titleMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ContactButtons(phone: donor.phone),
            const PrivacyNote(
              "Shared with you because this donor tapped I'm Interested.",
            ),
          ],
        ),
      ),
    );
  }
}
