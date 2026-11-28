import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../utils/constants.dart';
import 'app_logo.dart';

/// Dark slate footer with the logo, contact details and social links.
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  // A light grey for secondary text on the dark footer (about 9 : 1).
  static const Color _mutedOnDark = Color(0xFFB9C0C4);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final year = DateTime.now().year;

    return Container(
      color: AppColors.ink,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + 4,
        AppSpacing.xl,
        AppSpacing.md + 4,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(onDark: true),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.tagline,
            style: textTheme.bodyMedium?.copyWith(color: _mutedOnDark),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _ContactRow(icon: Icons.call_outlined, text: AppContact.phone),
          const _ContactRow(icon: Icons.mail_outline, text: AppContact.email),
          const _ContactRow(
            icon: Icons.location_on_outlined,
            text: AppContact.location,
          ),
          const SizedBox(height: AppSpacing.md),
          // Material Icons has no Instagram or YouTube logos, so we use
          // close generic icons and name the network in the tooltip.
          const Row(
            children: [
              _SocialButton(icon: Icons.facebook, name: 'Facebook'),
              _SocialButton(icon: Icons.camera_alt_outlined, name: 'Instagram'),
              _SocialButton(
                icon: Icons.smart_display_outlined,
                name: 'YouTube',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: Color(0xFF3A4246)),
          const SizedBox(height: AppSpacing.md),
          Text(
            '© $year ${AppStrings.appName}. Made for voluntary donors in Bangladesh.',
            style: textTheme.bodySmall?.copyWith(color: _mutedOnDark),
          ),
        ],
      ),
    );
  }
}

/// One line of contact info: an icon and some text.
class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: HomeFooter._mutedOnDark),
          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// A round 48dp social media button. It does nothing yet.
class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.name});

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {}, // Links will be added in a later stage.
      tooltip: name,
      icon: Icon(icon),
      color: Colors.white,
    );
  }
}
