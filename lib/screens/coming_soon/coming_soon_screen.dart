import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_button.dart';

/// A stand-in for screens that are not built yet.
///
/// Open it with:
///   Navigator.pushNamed(context, AppRoutes.comingSoon, arguments: 'Find Blood');
/// The `arguments` value becomes the title.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ModalRoute.of(context) is the route that is showing this screen.
    // Its settings carry whatever was passed as `arguments` to pushNamed.
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final featureName = arguments is String ? arguments : 'This feature';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction_outlined,
                size: AppSpacing.xxl,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Coming soon', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$featureName is not ready yet. It will be added in a later '
                'version of the app.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Back',
                variant: AppButtonVariant.outlined,
                // pop() removes this screen and shows the one below it.
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
