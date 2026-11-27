import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/enums.dart';
import '../../../../models/user.dart';
import '../../../../providers/donor_registration_provider.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/spacing.dart';
import '../../../../widgets/blood_group_picker.dart';
import '../../../../widgets/date_field.dart';
import '../../../../widgets/labelled_field.dart';
import '../../../../widgets/privacy_note.dart';

/// Blood group, gender and date of birth.
///
/// Logged-in seekers start here, so it also shows whose account the
/// donor profile is being added to.
class AboutYouStep extends StatelessWidget {
  const AboutYouStep({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch: the pickers must redraw when an answer changes.
    final registration = context.watch<DonorRegistrationProvider>();
    final showErrors = registration.showErrors;
    final today = registration.today;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (registration.existingUser != null) ...[
          _RegisteringAsCard(user: registration.existingUser!),
          const SizedBox(height: AppSpacing.lg),
        ],
        LabelledField(
          label: 'Blood group',
          errorText: showErrors ? registration.bloodGroupError : null,
          child: BloodGroupPicker(
            selected: registration.bloodGroup,
            onSelected: registration.setBloodGroup,
            hasError: showErrors && registration.bloodGroupError != null,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LabelledField(
          label: 'Gender',
          note: 'Sets the gap between donations',
          errorText: showErrors ? registration.genderError : null,
          child: SizedBox(
            width: double.infinity,
            // SegmentedButton is Material 3's row of joined toggle
            // buttons. `selected` is a Set because some segmented buttons
            // allow several choices; here it holds at most one.
            child: SegmentedButton<Gender>(
              segments: [
                for (final gender in Gender.values)
                  ButtonSegment(value: gender, label: Text(gender.label)),
              ],
              selected: registration.gender == null
                  ? <Gender>{}
                  : {registration.gender!},
              emptySelectionAllowed: true,
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  registration.setGender(selection.first);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LabelledField(
          label: 'Date of birth',
          errorText: showErrors ? registration.dateOfBirthError : null,
          child: DateField(
            value: registration.dateOfBirth,
            onChanged: registration.setDateOfBirth,
            hint: 'Tap to choose a date',
            helpText: 'Date of birth',
            startWithYear: true,
            firstDate: DateTime(today.year - 100),
            lastDate: today,
            // Opening on a typical donor age saves a lot of scrolling.
            initialDate: DateTime(today.year - 25, today.month, today.day),
            hasError: showErrors && registration.dateOfBirthError != null,
          ),
        ),
        const PrivacyNote(
          'Private. Only used to check that donors are 18 to 60 years old.',
        ),
      ],
    );
  }
}

/// "Registering as Sample Seeker · 01700000001" for logged-in users, so
/// they can see their name and number are taken from their account.
class _RegisteringAsCard extends StatelessWidget {
  const _RegisteringAsCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // An initial-letter avatar instead of a photo.
            CircleAvatar(
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.primaryDark,
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: textTheme.titleMedium
                    ?.copyWith(color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registering as', style: textTheme.bodySmall),
                  Text(user.name, style: textTheme.titleMedium),
                  Text(user.phone, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
