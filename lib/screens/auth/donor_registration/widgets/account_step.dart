import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/donor_registration_provider.dart';
import '../../../../theme/spacing.dart';
import '../../../../utils/app_routes.dart';
import '../../../../utils/validators.dart';
import '../../../../widgets/app_text_field.dart';
import '../../widgets/auth_switch_prompt.dart';

/// Step 1 for new users only: name, mobile number and password.
///
/// The fields have no controllers. Each one starts from the provider's
/// saved answer (initialValue) and writes back on every key press
/// (onChanged), so the text is still there after going Back to this step.
class AccountStep extends StatelessWidget {
  const AccountStep({super.key});

  @override
  Widget build(BuildContext context) {
    // context.read: this step only writes to the provider, so it doesn't
    // need to rebuild when the provider changes.
    final registration = context.read<DonorRegistrationProvider>();
    final textTheme = Theme.of(context).textTheme;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'You will log in with this number and password, both to donate '
            'and to find blood.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Full name',
            hint: 'Your name',
            icon: Icons.person_outline,
            initialValue: registration.name,
            onChanged: (value) => registration.name = value,
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
            initialValue: registration.phone,
            onChanged: (value) => registration.phone = value,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: Validators.phone,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            hint: 'At least 8 letters and numbers',
            icon: Icons.lock_outline,
            initialValue: registration.password,
            onChanged: (value) => registration.password = value,
            isPassword: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            validator: Validators.password,
          ),
          const SizedBox(height: AppSpacing.md),
          AuthSwitchPrompt(
            question: 'Already have an account?',
            actionLabel: 'Log in',
            // Log in first; Home then offers Register as Donor with the
            // name and number already filled in.
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.login),
          ),
        ],
      ),
    );
  }
}
