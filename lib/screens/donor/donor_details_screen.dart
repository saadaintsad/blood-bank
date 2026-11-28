import 'package:flutter/material.dart';

import '../../models/donor_search_result.dart';
import '../../theme/spacing.dart';
import '../../widgets/blood_group_badge.dart';
import '../../widgets/compatible_label.dart';
import '../../widgets/contact_buttons.dart';
import '../../widgets/contact_locked_banner.dart';
import '../../widgets/privacy_note.dart';
import '../../widgets/status_chip.dart';
import 'widgets/detail_row.dart';

/// Everything other users may see about one donor, plus Call / SMS for
/// viewers with an open blood request.
///
/// Open it with:
///   Navigator.pushNamed(context, AppRoutes.donorDetails,
///       arguments: DonorDetailsArgs(donor: donor, phone: phone));
class DonorDetailsScreen extends StatelessWidget {
  const DonorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The donor arrives as route arguments (see the comment above).
    final args = ModalRoute.of(context)!.settings.arguments as DonorDetailsArgs;
    final donor = args.donor;
    final phone = args.phone;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Donor details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md + 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // The one large stamp on this screen.
                      BloodGroupBadge(
                        bloodGroup: donor.bloodGroup,
                        size: BloodGroupBadgeSize.large,
                      ),
                      const SizedBox(width: AppSpacing.md + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(donor.name, style: textTheme.headlineSmall),
                            if (!donor.isExactMatch) ...[
                              const SizedBox(height: AppSpacing.sm),
                              const CompatibleLabel(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  DetailRow(
                    icon: Icons.event_available_outlined,
                    label: 'Availability',
                    value: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusChip(
                        status: donor.status,
                        label: donor.statusLabel,
                      ),
                    ),
                  ),
                  DetailRow(
                    icon: Icons.place_outlined,
                    label: 'Area',
                    value: Text(
                      '${donor.area}, ${donor.district}',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                  DetailRow(
                    icon: Icons.person_outline,
                    label: 'Gender',
                    value: Text(donor.gender.label, style: textTheme.bodyLarge),
                  ),
                  const PrivacyNote(
                    "Only the area is shown, never the donor's exact address.",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (phone != null)
            _ContactCard(phone: phone)
          else
            const ContactLockedBanner(),
        ],
      ),
    );
  }
}

/// The donor's number with Call and SMS buttons.
class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Contact', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(phone, style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            ContactButtons(phone: phone),
            const PrivacyNote(
              'You see this number because you have an open blood request.',
            ),
          ],
        ),
      ),
    );
  }
}
