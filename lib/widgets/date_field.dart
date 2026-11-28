import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../utils/date_format.dart';

/// A field that shows a date and opens Material's date picker on tap.
///
/// It looks like the text fields (the theme styles InputDecorator the same
/// way), but you can't type in it, which avoids date-format mistakes.
///
/// Wrap it in a LabelledField to give it a label above.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.hint = 'Pick a date',
    this.helpText,
    this.startWithYear = false,
    this.enabled = true,
    this.hasError = false,
  });

  /// The chosen date, or null if none yet.
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  /// The earliest and latest dates the picker allows.
  final DateTime firstDate;
  final DateTime lastDate;

  /// Where the picker opens when [value] is null.
  final DateTime? initialDate;

  final String hint;

  /// Title at the top of the picker, e.g. "Date of birth".
  final String? helpText;

  /// Opens on the year grid first. Handy for birthdays, which are years
  /// away from today.
  final bool startWithYear;

  final bool enabled;

  /// Draws the red error border. The message itself is shown by
  /// LabelledField.
  final bool hasError;

  Future<void> _pick(BuildContext context) async {
    // showDatePicker opens a dialog and waits (await) until the user picks
    // a date or cancels. Cancelling returns null.
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? initialDate ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      initialDatePickerMode: startWithYear
          ? DatePickerMode.year
          : DatePickerMode.day,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final text = value == null ? hint : formatDate(value!);

    return InkWell(
      onTap: enabled ? () => _pick(context) : null,
      borderRadius: BorderRadius.circular(AppRadius.field),
      // InputDecorator draws the same box, icon and borders as a
      // TextField, but around any child we like.
      child: InputDecorator(
        isEmpty: false,
        decoration: InputDecoration(
          enabled: enabled,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          // An empty error widget turns the border red without adding a
          // second message under LabelledField's one.
          error: hasError ? const SizedBox.shrink() : null,
        ),
        child: Text(
          text,
          style: textTheme.bodyLarge?.copyWith(
            color: value == null || !enabled
                ? AppColors.inkMuted
                : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
