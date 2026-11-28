import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/colors.dart';

/// A small rounded label showing a donor's status: icon + word + colour.
///
/// Example:
///   StatusChip(status: DonorStatus.available)
///   StatusChip(
///     status: DonorStatus.recentlyDonated,
///     label: 'Available in 44 days',
///   )
///
/// The colour is never the only signal: each status has its own icon and
/// text, so the chip still makes sense for colour-blind users.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.label});

  final DonorStatus status;

  /// Optional text to show instead of the status's default label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    // Pick the icon and colours for this status.
    final (IconData icon, Color iconColor, Color textColor, Color background) =
        switch (status) {
      DonorStatus.available => (
          Icons.check_circle,
          AppColors.statusAvailable,
          AppColors.statusAvailable,
          AppColors.statusAvailableSoft,
        ),
      DonorStatus.recentlyDonated => (
          Icons.schedule,
          AppColors.statusRecentlyDonated,
          AppColors.statusRecentlyDonatedText,
          AppColors.statusRecentlyDonatedSoft,
        ),
      DonorStatus.notAvailable => (
          Icons.do_not_disturb_on,
          AppColors.statusNotAvailable,
          AppColors.ink,
          AppColors.statusNotAvailableSoft,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999), // Fully rounded ends.
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          // Flexible lets the text wrap on very narrow screens or with a
          // large system font size, instead of overflowing the chip.
          Flexible(
            child: Text(
              label ?? status.label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
