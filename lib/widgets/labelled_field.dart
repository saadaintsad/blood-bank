import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Puts a label above any input (a picker, dropdown or button group), in
/// the same style AppTextField uses, with an optional error line below.
///
/// Example:
///   LabelledField(
///     label: 'Gender',
///     errorText: provider.showErrors ? provider.genderError : null,
///     child: SegmentedButton(...),
///   )
class LabelledField extends StatelessWidget {
  const LabelledField({
    super.key,
    required this.label,
    required this.child,
    this.note,
    this.errorText,
  });

  final String label;
  final Widget child;

  /// Small grey text after the label, e.g. "Optional".
  final String? note;

  /// Shown in red below [child] when not null.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: textTheme.titleSmall,
            children: [
              if (note != null)
                TextSpan(
                  text: '  $note',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.inkMuted),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs + 2),
          Text(
            errorText!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
