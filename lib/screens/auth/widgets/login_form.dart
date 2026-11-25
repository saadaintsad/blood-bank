import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

/// The login form: title, email, password, "Remember me", "Forgot
/// password?" and the Log in button.
///
/// It is Stateful because it owns the text controllers, the checkbox value
/// and the Form's key. The screen around it only handles layout.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // The key gives us access to the Form, so we can validate every field
  // at once when the button is pressed.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  // Controllers hold resources, so we release them when the widget is
  // removed from the screen.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // validate() runs every field's validator and shows the error
    // messages. It returns true only if all fields are valid.
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // No backend yet, so we just confirm that the form worked.
    final email = _emailController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged in as $email (demo, no account check yet)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      // AutofillGroup lets password managers fill email + password together.
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome back', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Log in to find donors and manage your blood requests.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Email',
              hint: 'name@example.com',
              icon: Icons.mail_outline,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Password',
              hint: 'Your password',
              icon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              // At login we only check that a password was typed. The
              // strength rules (Validators.password) belong on Register,
              // so older passwords are never rejected here.
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Password'),
              // Pressing Enter in the password field logs in.
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildOptionsRow(),
            const SizedBox(height: AppSpacing.md),
            AppButton(label: 'Log in', onPressed: _submit),
          ],
        ),
      ),
    );
  }

  /// "Remember me" on the left, "Forgot password?" on the right.
  Widget _buildOptionsRow() {
    return Row(
      children: [
        Expanded(
          // InkWell makes the label tappable too, not just the small box.
          child: InkWell(
            onTap: () => setState(() => _rememberMe = !_rememberMe),
            borderRadius: BorderRadius.circular(AppRadius.badge),
            child: Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? false),
                  visualDensity: VisualDensity.compact,
                ),
                const Flexible(child: Text('Remember me')),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {}, // Forgot password screen comes later.
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          child: const Text('Forgot password?'),
        ),
      ],
    );
  }
}
