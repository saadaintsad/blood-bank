import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

/// A card that sits on top of the crimson band, with a soft shadow that
/// lifts it off the colour behind it.
///
/// Use the plain `Card` for cards on the off-white background, and this
/// one for the single card that overlaps a crimson band (hero, login).
class RaisedCard extends StatelessWidget {
  const RaisedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md + 4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F5A0A16), // Crimson-tinted, about 12% opacity.
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
