import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/spacing.dart';
import '../../../utils/phone_number.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

/// The login form: title, mobile number, password and the Log in button.
///
/// It is Stateful because it owns the text controllers and the Form's key.
/// The login itself is done by AuthProvider. The screen around this form
/// only handles layout.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // The key gives us access to the Form, so we can validate every field
  // at once when the button is pressed.
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controllers hold resources, so we release them when the widget is
  // removed from the screen.
  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // validate() runs every field's validator and shows the error
    // messages. It returns true only if all fields are valid.
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    // The validator already passed, so this is never null here. We send
    // the stored 01XXXXXXXXX format, even if the user typed +880...
    final phone = normalizeBangladeshiPhone(_phoneController.text)!;

    // context.read gets the provider once, without rebuilding on changes.
    final auth = context.read<AuthProvider>();
    final success = await auth.logIn(
      phone: phone,
      password: _passwordController.text,
    );

    // After an `await`, the widget may have left the screen. `mounted`
    // tells us whether it is still safe to use `context`.
    if (!mounted) return;

    final message = success
        ? 'Logged in as ${auth.currentUser!.name} (demo account)'
        : auth.errorMessage!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    // Go back to the screen that opened Login (usually Home), which now
    // shows the logged-in version. The snackbar stays visible because it
    // belongs to the app-wide ScaffoldMessenger, not to this screen.
    final navigator = Navigator.of(context);
    if (success && navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // context.watch rebuilds this widget whenever AuthProvider calls
    // notifyListeners(), so the button spinner follows isLoading.
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      // AutofillGroup lets password managers fill number + password together.
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
              label: 'Mobile number',
              hint: '01XXXXXXXXX',
              icon: Icons.phone_outlined,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: Validators.phone,
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
              // strength rules (Validators.password) belong on sign-up,
              // so older passwords are never rejected here.
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Password'),
              // Pressing Enter in the password field logs in.
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Log in',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
