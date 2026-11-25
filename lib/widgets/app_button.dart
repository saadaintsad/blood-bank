import 'package:flutter/material.dart';

/// The two looks an AppButton can have.
enum AppButtonVariant {
  /// Solid crimson. Use for the main action on a screen.
  filled,

  /// Crimson outline on a clear background. Use for a second, quieter action.
  outlined,
}

/// The app's standard button.
///
/// Example:
///   AppButton(label: 'Search donors', onPressed: _search)
///   AppButton(
///     label: 'Become a donor',
///     variant: AppButtonVariant.outlined,
///     onPressed: _register,
///   )
///
/// Colours, height and shape come from the theme (see app_theme.dart),
/// so this widget only decides *which* Material button to show.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  /// Text on the button. Name the action: "Search donors", not "Submit".
  final String label;

  /// Called on tap. Pass `null` to show the button as disabled.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;

  /// Optional icon shown before the label.
  final IconData? icon;

  /// Shows a small spinner and blocks taps while something is happening.
  final bool isLoading;

  /// When true the button stretches to the width of its parent.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    // While loading, a null callback makes Flutter disable the button.
    final VoidCallback? tapHandler = isLoading ? null : onPressed;

    final Widget button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: tapHandler,
          child: _ButtonContent(label: label, icon: icon, isLoading: isLoading),
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: tapHandler,
          child: _ButtonContent(label: label, icon: icon, isLoading: isLoading),
        ),
    };

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// What goes inside the button: a spinner, or an optional icon plus label.
class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    if (icon == null) return Text(label);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
