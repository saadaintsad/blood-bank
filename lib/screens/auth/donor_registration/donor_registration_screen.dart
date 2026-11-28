import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/donor_registration_provider.dart';
import '../../../theme/spacing.dart';
import '../../../utils/navigation.dart';
import 'widgets/about_you_step.dart';
import 'widgets/account_step.dart';
import 'widgets/age_blocked_panel.dart';
import 'widgets/consent_step.dart';
import 'widgets/donation_step.dart';
import 'widgets/location_step.dart';
import 'widgets/step_header.dart';
import 'widgets/step_nav_bar.dart';

/// Donor registration: a form split into steps (see "Donor registration
/// and profile" in docs/requirements.md).
///
/// New users get 5 steps, starting with their account. Logged-in seekers
/// get 4, because their name and number are already known.
class DonorRegistrationScreen extends StatelessWidget {
  const DonorRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This provider exists only while this screen is open, so a new
    // registration always starts empty.
    return ChangeNotifierProvider(
      create: (context) => DonorRegistrationProvider(
        existingUser: context.read<AuthProvider>().currentUser,
      ),
      child: const _RegistrationBody(),
    );
  }
}

/// The screen's layout. It is Stateful only to own the Form key, which
/// lets the Next button show the text fields' error messages.
class _RegistrationBody extends StatefulWidget {
  const _RegistrationBody();

  @override
  State<_RegistrationBody> createState() => _RegistrationBodyState();
}

class _RegistrationBodyState extends State<_RegistrationBody> {
  final _formKey = GlobalKey<FormState>();

  void _onNext(DonorRegistrationProvider registration) {
    // Shows the messages under any text field that is wrong. The provider
    // makes the actual decision, so the result isn't needed here.
    _formKey.currentState?.validate();
    if (registration.isLastStep) {
      _finish(registration);
    } else {
      registration.next();
    }
  }

  Future<void> _finish(DonorRegistrationProvider registration) async {
    final auth = context.read<AuthProvider>();
    final success = await registration.submit(auth);
    if (!mounted) return;

    final message = success
        ? 'You are registered as a donor · ${registration.startingStatusLabel}'
        : auth.errorMessage!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (success) returnHomeAfterSignUp(Navigator.of(context));
  }

  Future<void> _createSeekerAccount(
    DonorRegistrationProvider registration,
  ) async {
    final auth = context.read<AuthProvider>();
    final success = await registration.signUpAsSeeker(auth);
    if (!mounted) return;

    final message = success
        ? 'Welcome, ${auth.currentUser!.name}. Your account is ready.'
        : auth.errorMessage!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (success) {
      returnHomeAfterSignUp(Navigator.of(context), continueToFindBlood: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registration = context.watch<DonorRegistrationProvider>();
    final isSaving = context.watch<AuthProvider>().isLoading;
    final isBlocked = registration.isAgeBlocked;
    final step = registration.currentStep;

    // Finish stays disabled until the consent box is ticked.
    final canGoOn =
        step != RegistrationStep.consent || registration.consentGiven;

    // PopScope catches the back arrow and Android's back gesture. On
    // later steps they go back one step instead of leaving the form.
    return PopScope(
      canPop: registration.isFirstStep && !isBlocked && !isSaving,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || isSaving) return;
        if (isBlocked) {
          registration.dismissAgeBlock();
        } else {
          registration.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Register as Donor')),
        body: Column(
          children: [
            if (!isBlocked)
              StepHeader(
                stepNumber: registration.stepNumber,
                stepCount: registration.stepCount,
                title: step.title,
              ),
            // Expanded gives the scrolling area all the height left
            // between the header and the button bar.
            Expanded(
              child: SingleChildScrollView(
                // A new key per step starts each step scrolled to the top.
                key: ValueKey(isBlocked ? 'age-blocked' : step),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: isBlocked
                    ? AgeBlockedPanel(
                        age: registration.age!,
                        isNewAccount: registration.isNewAccount,
                        isLoading: isSaving,
                        onCreateSeekerAccount: () =>
                            _createSeekerAccount(registration),
                        onChangeDateOfBirth: registration.dismissAgeBlock,
                        onBackToHome: () => Navigator.of(context).pop(),
                      )
                    : Form(key: _formKey, child: _buildStep(step)),
              ),
            ),
            if (!isBlocked)
              StepNavBar(
                showBack: !registration.isFirstStep,
                isLastStep: registration.isLastStep,
                isLoading: isSaving,
                onBack: registration.back,
                onNext: canGoOn ? () => _onNext(registration) : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(RegistrationStep step) {
    return switch (step) {
      RegistrationStep.account => const AccountStep(),
      RegistrationStep.aboutYou => const AboutYouStep(),
      RegistrationStep.location => const LocationStep(),
      RegistrationStep.donation => const DonationStep(),
      RegistrationStep.consent => const ConsentStep(),
    };
  }
}
