import 'package:flutter/material.dart';

import '../models/blood_request.dart';
import '../models/enums.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../utils/date_format.dart';
import 'app_button.dart';
import 'blood_group_badge.dart';
import 'request_status_chip.dart';

/// One blood request in My Requests.
///
/// The blood group stamp starts the row, then the patient, units, hospital
/// and date. Pass [onMarkFulfilled] and [onCancel] only while the request
/// is still Open; closed requests show no buttons.
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.status,
    this.onMarkFulfilled,
    this.onCancel,
    this.isBusy = false,
  });

  final BloodRequest request;

  /// The effective status (with Expired), from MyRequestsProvider.statusOf.
  final RequestStatus status;

  final VoidCallback? onMarkFulfilled;
  final VoidCallback? onCancel;

  /// True while this request is being closed: shows a spinner and blocks
  /// a second tap.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mutedStyle = textTheme.bodyMedium?.copyWith(
      color: AppColors.inkMuted,
    );
    final units = request.unitsNeeded;
    final notes = request.notes;
    final hasActions = onMarkFulfilled != null || onCancel != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BloodGroupBadge(bloodGroup: request.bloodGroup),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.patientName, style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${units == 1 ? '1 unit' : '$units units'} · '
                        '${request.hospital}, ${request.district}',
                        style: mutedStyle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Needed on ${formatDate(request.requiredDate)}',
                        style: mutedStyle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RequestStatusChip(status: status),
                    ],
                  ),
                ),
              ],
            ),
            if (notes != null) ...[
              const SizedBox(height: AppSpacing.sm + 4),
              Text(notes, style: textTheme.bodyMedium),
            ],
            if (hasActions) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm + 4),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  /// Mark Fulfilled (outlined) gets most of the width; Cancel is a quieter
  /// text button so the two never crowd each other on a 360 dp screen.
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Mark Fulfilled',
            icon: Icons.check,
            variant: AppButtonVariant.outlined,
            isLoading: isBusy,
            onPressed: onMarkFulfilled,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: isBusy ? null : onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
