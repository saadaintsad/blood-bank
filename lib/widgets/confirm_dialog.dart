import 'package:flutter/material.dart';

/// Asks the user to confirm an action. Resolves to true only when they
/// tap [confirmLabel]; tapping "Keep it" or outside the dialog gives false.
///
///   final ok = await showConfirmDialog(
///     context,
///     title: 'Cancel this request?',
///     message: '...',
///     confirmLabel: 'Cancel request',
///   );
///   if (ok) ...
///
/// showDialog returns a Future that completes with the value passed to
/// Navigator.pop when the dialog closes.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String dismissLabel = 'Keep it',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(dismissLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  // Closing the dialog by tapping outside gives null; treat it as "no".
  return confirmed ?? false;
}
