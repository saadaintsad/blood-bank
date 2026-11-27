import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../utils/constants.dart';
import 'blood_group_badge.dart';

/// A 4 x 2 grid of the eight blood groups, each shown as its stamp.
/// Tapping one selects it.
///
/// Example:
///   BloodGroupPicker(
///     selected: provider.bloodGroup,
///     onSelected: provider.setBloodGroup,
///   )
class BloodGroupPicker extends StatelessWidget {
  const BloodGroupPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.hasError = false,
  });

  /// The chosen group, e.g. "B+", or null if none yet.
  final String? selected;
  final ValueChanged<String> onSelected;

  /// Gives the tiles a red border while nothing is chosen.
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    // GridView.count makes a grid with a fixed number of columns.
    // shrinkWrap + no scrolling lets it sit inside the page's own scroll
    // view instead of scrolling on its own.
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.1,
      children: [
        for (final group in bloodGroups)
          _BloodGroupTile(
            bloodGroup: group,
            isSelected: group == selected,
            hasError: hasError,
            onTap: () => onSelected(group),
          ),
      ],
    );
  }
}

/// One tappable square in the picker.
class _BloodGroupTile extends StatelessWidget {
  const _BloodGroupTile({
    required this.bloodGroup,
    required this.isSelected,
    required this.hasError,
    required this.onTap,
  });

  final String bloodGroup;
  final bool isSelected;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.primary
        : (hasError ? AppColors.error : AppColors.border);
    final radius = BorderRadius.circular(AppRadius.field);

    // Semantics tells screen readers this is a selectable button and
    // whether it is currently selected.
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
        ),
        // Material + InkWell gives the ripple effect on tap.
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Center(
            child: BloodGroupBadge(
              bloodGroup: bloodGroup,
              size: BloodGroupBadgeSize.small,
            ),
          ),
        ),
      ),
    );
  }
}
