import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/spacing.dart';
import '../../../utils/navigation.dart';
import '../../../utils/phone_number.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

/// The sign-up form: name, mobile number, password and Create account.
///
/// Built the same way as LoginForm: the widget owns the text controllers,
/// and AuthProvider does the actual sign-up.
class SeekerSignupForm extends StatefulWidget {
  const SeekerSignupForm({super.key, this.continueToFindBlood = false});

  /// Open Find Blood after signing up (the user came from there).
  final bool continueToFindBlood;

  @override
  State<SeekerSignupForm> createState() => _SeekerSignupFormState();
}

class _SeekerSignupFormState extends State<SeekerSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      name: _nameController.text.trim(),
      // Always save the 01XXXXXXXXX form, even if +880... was typed.
      phone: normalizeBangladeshiPhone(_phoneController.text)!,
      password: _passwordController.text,
    );
    if (!mounted) return;

    final message = success
        ? 'Welcome, ${auth.currentUser!.name}. Your account is ready.'
        : auth.errorMessage!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      returnHomeAfterSignUp(
        Navigator.of(context),
        continueToFindBlood: widget.continueToFindBlood,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create an account', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Just three details to start finding blood donors.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Full name',
              hint: 'Your name',
              icon: Icons.person_outline,
              controller: _nameController,
              keyboardType: TextInputType.name,
              autofillHints: const [AutofillHints.name],
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Name'),
            ),
            const SizedBox(height: AppSpacing.md),
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
              hint: 'At least 8 letters and numbers',
              icon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.password,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Create account',
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
