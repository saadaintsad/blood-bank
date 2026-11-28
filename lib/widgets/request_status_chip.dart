import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/colors.dart';

/// A small rounded label showing a blood request's status.
///
/// Like StatusChip, it always pairs the colour with an icon and a word.
/// It deliberately does not reuse the donor Green / Yellow / Red colours,
/// so "Open" is never mistaken for a donor being "Available".
///
///   RequestStatusChip(status: provider.statusOf(request))
class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({super.key, required this.status});

  /// Pass the effective status (with Expired), not the saved one.
  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (
      IconData icon,
      Color foreground,
      Color background,
      String label,
    ) = switch (status) {
      RequestStatus.open => (
        Icons.radio_button_checked,
        AppColors.primaryDark,
        AppColors.primarySoft,
        'Open',
      ),
      RequestStatus.fulfilled => (
        Icons.check_circle,
        AppColors.statusAvailable,
        AppColors.statusAvailableSoft,
        'Fulfilled',
      ),
      RequestStatus.cancelled => (
        Icons.cancel_outlined,
        AppColors.inkMuted,
        AppColors.neutralSoft,
        'Cancelled',
      ),
      // "Closed" makes clear nobody has to do anything any more.
      RequestStatus.expired => (
        Icons.timer_off_outlined,
        AppColors.inkMuted,
        AppColors.neutralSoft,
        'Closed · Expired',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
