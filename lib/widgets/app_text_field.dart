import 'package:flutter/material.dart';

import '../theme/spacing.dart';

/// A labelled text field used in every form.
///
/// The label sits above the box (not inside it) so it is always visible,
/// even after the user has typed something.
///
/// Example:
///   AppTextField(
///     label: 'Email',
///     hint: 'name@example.com',
///     icon: Icons.mail_outline,
///     keyboardType: TextInputType.emailAddress,
///     validator: Validators.email,
///   )
///
/// Set [isPassword] to true to hide the text and show an eye button.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.initialValue,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;

  /// Starting text when there is no [controller]. Use one or the other.
  final String? initialValue;

  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final ValueChanged<String>? onChanged;

  /// Called when the user presses Enter / Done on the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Lets the browser or password manager fill the field, for example
  /// `[AutofillHints.email]` or `[AutofillHints.password]`.
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

// This widget is Stateful only because a password field must remember
// whether its text is currently hidden or shown.
class _AppTextFieldState extends State<AppTextField> {
  bool _isTextHidden = true;

  void _toggleVisibility() {
    setState(() => _isTextHidden = !_isTextHidden);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          autofillHints: widget.autofillHints,
          // Only password fields hide their text.
          obscureText: widget.isPassword && _isTextHidden,
          // Show errors as soon as the user leaves a field they touched.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icon == null ? null : Icon(widget.icon),
            suffixIcon: widget.isPassword ? _buildEyeButton() : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEyeButton() {
    return IconButton(
      onPressed: _toggleVisibility,
      // Tooltip doubles as the label screen readers announce.
      tooltip: _isTextHidden ? 'Show password' : 'Hide password',
      icon: Icon(
        _isTextHidden
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
    );
  }
}
