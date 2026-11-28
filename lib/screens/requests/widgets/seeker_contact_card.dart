import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';
import '../../../widgets/contact_buttons.dart';
import '../../../widgets/privacy_note.dart';

/// The seeker's contact number with Call / SMS, shown to donors on
/// Request details ("Seeker's contact phone" in docs/requirements.md).
class SeekerContactCard extends StatelessWidget {
  const SeekerContactCard({super.key, required this.phone});

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
            Text("Seeker's contact", style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(phone, style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            ContactButtons(phone: phone),
            const PrivacyNote(
              "You see this number because you're a registered donor.",
            ),
          ],
        ),
      ),
    );
  }
}
