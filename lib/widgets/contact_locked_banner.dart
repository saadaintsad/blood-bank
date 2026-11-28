import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../utils/app_routes.dart';
import '../utils/navigation.dart';
import 'app_button.dart';

/// Explains why phone numbers are hidden, with a way to fix it.
///
/// Shown on Find Blood and Donor details to users without an open blood
/// request ("Finding donors" in docs/requirements.md).
class ContactLockedBanner extends StatelessWidget {
  const ContactLockedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.primaryDark),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Text(
                  "Post a blood request to see donors' contact numbers.",
                  style: textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          AppButton(
            label: 'Post Request',
            icon: Icons.add,
            variant: AppButtonVariant.outlined,
            // After posting, the user comes back to a fresh Find Blood
            // that shows numbers (see leavePostRequest).
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.postRequest,
              arguments: PostRequestOrigin.contactBanner,
            ),
          ),
        ],
      ),
    );
  }
}
