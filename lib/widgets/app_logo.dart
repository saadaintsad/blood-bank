import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../utils/constants.dart';

/// The Reddify logo: a small stamp-shaped square with a blood drop,
/// followed by the app name.
///
/// Set [onDark] to true when the logo sits on crimson or slate, so the
/// colours flip and stay readable.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final textColor = onDark ? Colors.white : AppColors.ink;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The mark: same square-with-border shape as our blood-group stamps.
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: onDark ? Colors.white : AppColors.surface,
            border: Border.all(color: AppColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: const Icon(
            Icons.water_drop,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: textColor, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
