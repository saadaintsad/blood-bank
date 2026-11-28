import 'package:flutter/material.dart';

import '../theme/spacing.dart';
import '../utils/contact_launcher.dart';
import 'app_button.dart';

/// Call (filled) and SMS (outlined) side by side for one phone number.
///
/// Only shown to users with an open blood request (see DonorCard).
class ContactButtons extends StatelessWidget {
  const ContactButtons({super.key, required this.phone});

  /// The number to call or text, as 01XXXXXXXXX.
  final String phone;

  /// Opens the dialer or SMS app. If nothing could open the link (for
  /// example Chrome on a laptop), a snackbar says so instead.
  Future<void> _open(
    BuildContext context,
    Future<bool> Function(String) launch,
    String appName,
  ) async {
    // Read the messenger before the `await`: after waiting, this widget
    // might be gone, and its context should not be used any more.
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launch(phone);
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open the $appName on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded gives each button half of the row.
        Expanded(
          child: AppButton(
            label: 'Call',
            icon: Icons.call,
            onPressed: () => _open(context, callNumber, 'dialer'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppButton(
            label: 'SMS',
            icon: Icons.sms_outlined,
            variant: AppButtonVariant.outlined,
            onPressed: () => _open(context, sendSms, 'messages app'),
          ),
        ),
      ],
    );
  }
}
