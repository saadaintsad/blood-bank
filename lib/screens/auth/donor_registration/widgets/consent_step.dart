import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/donor_registration_provider.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/spacing.dart';
import '../../../../widgets/blood_group_badge.dart';
import '../../../../widgets/status_chip.dart';
import '../registration_content.dart';

/// The last step: a preview of the donor card other users will see, the
/// consent message, and the "I agree" checkbox that unlocks Finish.
class ConsentStep extends StatelessWidget {
  const ConsentStep({super.key});

  @override
  Widget build(BuildContext context) {
    final registration = context.watch<DonorRegistrationProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('This is what other users will see:', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm + 4),
        _DonorCardPreview(registration: registration),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.visibility_outlined, color: AppColors.primaryDark),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Text(donorConsentText, style: textTheme.bodyMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CheckboxListTile(
          value: registration.consentGiven,
          onChanged: (value) => registration.setConsentGiven(value ?? false),
          title: Text(
            'I agree to share these details',
            style: textTheme.titleSmall,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

/// The donor card with the large tilted stamp (used once on this screen).
class _DonorCardPreview extends StatelessWidget {
  const _DonorCardPreview({required this.registration});

  final DonorRegistrationProvider registration;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = registration.existingUser?.name ?? registration.name.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 4),
        child: Row(
          children: [
            BloodGroupBadge(
              bloodGroup: registration.bloodGroup!,
              size: BloodGroupBadgeSize.large,
            ),
            const SizedBox(width: AppSpacing.md + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${registration.area.trim()}, ${registration.district}',
                    style: textTheme.bodyMedium,
                  ),
                  Text(registration.gender!.label, style: textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.sm + 2),
                  StatusChip(
                    status: registration.startingStatus,
                    label: registration.startingStatusLabel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
