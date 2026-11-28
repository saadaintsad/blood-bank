import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/enums.dart';
import '../../../../providers/donor_registration_provider.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/spacing.dart';
import '../../../../utils/date_format.dart';
import '../../../../utils/eligibility.dart';
import '../../../../widgets/date_field.dart';
import '../../../../widgets/labelled_field.dart';
import '../../../../widgets/privacy_note.dart';
import '../../../../widgets/status_chip.dart';

/// Last donation date (or "never donated"), a preview of the starting
/// status, and the blood request alerts switch.
class DonationStep extends StatelessWidget {
  const DonationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final registration = context.watch<DonorRegistrationProvider>();
    final textTheme = Theme.of(context).textTheme;
    final today = registration.today;
    final error = registration.showErrors
        ? registration.lastDonationError
        : null;
    final hasAnswered =
        registration.lastDonationDate != null || registration.neverDonated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelledField(
          label: 'Last donation date',
          child: DateField(
            value: registration.lastDonationDate,
            onChanged: registration.setLastDonationDate,
            hint: 'When did you last give blood?',
            helpText: 'Last donation date',
            firstDate: DateTime(today.year - 60),
            // No future dates: you can't have donated tomorrow.
            lastDate: today,
            enabled: !registration.neverDonated,
            hasError: error != null,
          ),
        ),
        // CheckboxListTile makes the whole row tappable, not just the box,
        // which gives a comfortably large tap target.
        CheckboxListTile(
          value: registration.neverDonated,
          onChanged: (value) => registration.setNeverDonated(value ?? false),
          title: Text('I have never donated', style: textTheme.bodyLarge),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (error != null)
          Text(
            error,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        const PrivacyNote(
          'Private. Used only to work out when you can donate again.',
        ),
        if (hasAnswered) ...[
          const SizedBox(height: AppSpacing.lg),
          _StartingStatusCard(registration: registration),
        ],
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        SwitchListTile(
          value: registration.receiveAlerts,
          onChanged: registration.setReceiveAlerts,
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Receive blood request alerts',
            style: textTheme.titleSmall,
          ),
          subtitle: Text(
            'Get a notification when someone needs your blood group. You '
            'can turn this off at any time.',
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// "You'll start as [Available]" with a sentence explaining why.
class _StartingStatusCard extends StatelessWidget {
  const _StartingStatusCard({required this.registration});

  final DonorRegistrationProvider registration;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = registration.startingStatus;
    final gender = registration.gender ?? Gender.other;

    final explanation = status == DonorStatus.available
        ? 'You will appear in donor search straight away.'
        : 'Donors wait ${waitingPeriodDays(gender)} days between '
              'donations. You will still appear in search, and turn '
              'Available automatically on '
              '${formatDate(nextEligibleDate(registration.lastDonationDate!, gender))}.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You will start as', style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            StatusChip(status: status, label: registration.startingStatusLabel),
            const SizedBox(height: AppSpacing.sm),
            Text(explanation, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
