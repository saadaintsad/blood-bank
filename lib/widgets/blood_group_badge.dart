import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';

/// Badge sizes. Each one is a fixed square, so a blood group always takes
/// the same space and lines up in lists.
enum BloodGroupBadgeSize {
  /// 40 x 40. Inside chips or dense rows.
  small,

  /// 56 x 56. At the start of a donor or request row.
  medium,

  /// 84 x 84 "stamp" with a double border and a slight tilt.
  /// Use once per screen, e.g. on the user's own donor card.
  large,
}

/// Shows a blood group ("B+", "AB-") as a square crimson stamp.
///
/// The blood group is the first thing a seeker looks for, so it gets its
/// own strong shape instead of a small coloured pill.
class BloodGroupBadge extends StatelessWidget {
  const BloodGroupBadge({
    super.key,
    required this.bloodGroup,
    this.size = BloodGroupBadgeSize.medium,
  });

  /// One of the values in [bloodGroups], for example "O-".
  final String bloodGroup;
  final BloodGroupBadgeSize size;

  @override
  Widget build(BuildContext context) {
    // Swap the typed hyphen for a real minus sign, which looks balanced
    // next to the plus sign.
    final displayText = bloodGroup.replaceAll('-', '−');

    final badge = switch (size) {
      BloodGroupBadgeSize.small => _StampBox(
          dimension: 40,
          fontSize: 15,
          borderWidth: 1.5,
          text: displayText,
        ),
      BloodGroupBadgeSize.medium => _StampBox(
          dimension: 56,
          fontSize: 20,
          borderWidth: 2,
          text: displayText,
        ),
      BloodGroupBadgeSize.large => _buildLargeStamp(displayText),
    };

    // Screen readers say "Blood group B positive" instead of "B plus".
    return Semantics(
      label: 'Blood group ${_spokenName(bloodGroup)}',
      excludeSemantics: true,
      child: badge,
    );
  }

  /// The large stamp: an outer border, a thin inner border, and a small
  /// tilt, like a rubber stamp pressed on a donor card.
  Widget _buildLargeStamp(String text) {
    return Transform.rotate(
      angle: -0.06, // About -3.5 degrees. Small enough to stay readable.
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.primary, width: 2.5),
          borderRadius: BorderRadius.circular(AppRadius.badge + 4),
        ),
        child: _StampBox(
          dimension: 72,
          fontSize: 30,
          borderWidth: 1,
          text: text,
        ),
      ),
    );
  }

  /// Turns "AB-" into "A B negative" for screen readers.
  static String _spokenName(String group) {
    final letters = group.replaceAll(RegExp(r'[+-]'), '').split('').join(' ');
    final sign = group.endsWith('+') ? 'positive' : 'negative';
    return '$letters $sign';
  }
}

/// A square with a crimson border and the blood group centred inside.
class _StampBox extends StatelessWidget {
  const _StampBox({
    required this.dimension,
    required this.fontSize,
    required this.borderWidth,
    required this.text,
  });

  final double dimension;
  final double fontSize;
  final double borderWidth;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary, width: borderWidth),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      // FittedBox shrinks "AB+" a little if it would not fit the square.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: AppTextStyles.bloodGroup.copyWith(fontSize: fontSize),
        ),
      ),
    );
  }
}
