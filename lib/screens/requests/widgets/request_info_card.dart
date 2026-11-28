import 'package:flutter/material.dart';

import '../../../models/blood_request.dart';
import '../../../models/enums.dart';
import '../../../theme/spacing.dart';
import '../../../utils/date_format.dart';
import '../../../widgets/blood_group_badge.dart';
import '../../../widgets/detail_row.dart';
import '../../../widgets/request_status_chip.dart';

/// The top card on Request details: the large blood group stamp, the
/// patient, the status and every detail of the request.
class RequestInfoCard extends StatelessWidget {
  const RequestInfoCard({
    super.key,
    required this.request,
    required this.status,
  });

  final BloodRequest request;

  /// The effective status (with Expired).
  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final units = request.unitsNeeded;
    final notes = request.notes;

    Text value(String text) => Text(text, style: textTheme.bodyLarge);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // The one large stamp on this screen.
                BloodGroupBadge(
                  bloodGroup: request.bloodGroup,
                  size: BloodGroupBadgeSize.large,
                ),
                const SizedBox(width: AppSpacing.md + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.patientName, style: textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.sm),
                      RequestStatusChip(status: status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            DetailRow(
              icon: Icons.bloodtype_outlined,
              label: 'Units needed',
              value: value(units == 1 ? '1 unit' : '$units units'),
            ),
            DetailRow(
              icon: Icons.local_hospital_outlined,
              label: 'Hospital',
              value: value('${request.hospital}, ${request.district}'),
            ),
            DetailRow(
              icon: Icons.event_outlined,
              label: 'Needed on',
              value: value(formatDate(request.requiredDate)),
            ),
            if (notes != null)
              DetailRow(
                icon: Icons.notes_outlined,
                label: 'Notes',
                value: value(notes),
              ),
          ],
        ),
      ),
    );
  }
}
