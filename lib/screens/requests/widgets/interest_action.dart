import 'package:flutter/material.dart';

import '../../../models/donor_response.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../utils/date_format.dart';
import '../../../utils/interest_rules.dart';
import '../../../widgets/app_button.dart';

/// The donor's "I'm Interested" area on Request details.
///
/// Shows one of four things:
/// - a confirmation, once the donor has responded ([response] is set);
/// - a note that the request is closed ([isOpen] is false);
/// - the disabled button with the reason ([blockReason] is set);
/// - the full-width red button, with what tapping it will do.
class InterestAction extends StatelessWidget {
  const InterestAction({
    super.key,
    required this.response,
    required this.isOpen,
    required this.blockReason,
    required this.now,
    required this.onPressed,
    this.isLoading = false,
  });

  final DonorResponse? response;
  final bool isOpen;
  final String? blockReason;

  /// The current time, to tell whether the 3-hour window is still running.
  final DateTime now;

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mutedStyle = textTheme.bodyMedium?.copyWith(
      color: AppColors.inkMuted,
    );
    final response = this.response;

    if (response != null) return _buildConfirmation(context, response);

    if (!isOpen) {
      return Text(
        'This request is closed, so it no longer takes responses.',
        style: mutedStyle,
      );
    }

    final reason = blockReason;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: "I'm Interested",
          icon: Icons.volunteer_activism_outlined,
          isLoading: isLoading,
          // null disables the button.
          onPressed: reason == null ? onPressed : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (reason == null)
          Text(
            'The seeker will see your name and number. You will be hidden '
            "from search for 3 hours and can't respond to another request "
            'during that time.',
            style: mutedStyle,
          )
        else
          // An info icon makes it clear why the button is greyed out.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.inkMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(reason, style: textTheme.bodyMedium)),
            ],
          ),
      ],
    );
  }

  /// "You're interested" with what happens next.
  Widget _buildConfirmation(BuildContext context, DonorResponse response) {
    final textTheme = Theme.of(context).textTheme;
    final hiddenEnd = hiddenUntil(response);
    final ask = response.askDonatedAt;
    final lines = [
      if (isInHiddenWindow(response, now))
        "You're hidden from search until ${formatTime(hiddenEnd)}.",
      'The seeker can now see your name and number.',
      if (ask.isAfter(now))
        "We'll ask if you donated on ${formatDate(ask)} at ${formatTime(ask)}.",
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.statusAvailableSoft,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.statusAvailable),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're interested in this request",
                  style: textTheme.titleSmall,
                ),
                for (final line in lines) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(line, style: textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
