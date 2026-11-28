import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/post_request_provider.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation.dart';
import '../../../utils/request_rules.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/blood_group_picker.dart';
import '../../../widgets/date_field.dart';
import '../../../widgets/labelled_field.dart';
import '../../../widgets/privacy_note.dart';
import '../../../widgets/searchable_dropdown.dart';
import 'units_stepper.dart';

/// The Post Request form, in three cards: patient, where and when, and
/// contact. The answers live in PostRequestProvider.
class PostRequestForm extends StatefulWidget {
  const PostRequestForm({super.key, required this.origin});

  /// Where to go after posting.
  final PostRequestOrigin origin;

  @override
  State<PostRequestForm> createState() => _PostRequestFormState();
}

// Stateful only to keep the Form's key. A GlobalKey lets us call
// validate() on the whole form from the button.
class _PostRequestFormState extends State<PostRequestForm> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus(); // Close the keyboard.
    final post = context.read<PostRequestProvider>();
    // Read these before the `await`: after it, this widget may be gone.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final request = await post.submit(
      textFieldsValid: _formKey.currentState!.validate(),
    );
    if (request == null) return; // Errors are now on screen.

    messenger.showSnackBar(
      const SnackBar(content: Text('Request posted. It is now Open.')),
    );
    leavePostRequest(navigator, widget.origin);
  }

  @override
  Widget build(BuildContext context) {
    final post = context.watch<PostRequestProvider>();
    final showErrors = post.showErrors;
    final error = post.errorMessage;
    const gap = SizedBox(height: AppSpacing.md);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Section(
            title: 'Patient',
            children: [
              AppTextField(
                label: 'Patient name',
                hint: 'Full name of the patient',
                icon: Icons.person_outline,
                initialValue: post.patientName,
                keyboardType: TextInputType.name,
                onChanged: (value) => post.patientName = value,
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Patient name'),
              ),
              gap,
              LabelledField(
                label: 'Blood group',
                errorText: showErrors ? post.bloodGroupError : null,
                child: BloodGroupPicker(
                  selected: post.bloodGroup,
                  onSelected: post.setBloodGroup,
                  hasError: showErrors && post.bloodGroupError != null,
                ),
              ),
              gap,
              LabelledField(
                label: 'Units needed',
                note: 'Bags of blood',
                child: UnitsStepper(
                  units: post.units,
                  onChanged: post.changeUnits,
                ),
              ),
            ],
          ),
          gap,
          _Section(
            title: 'Where and when',
            children: [
              AppTextField(
                label: 'Hospital',
                hint: 'Hospital name',
                icon: Icons.local_hospital_outlined,
                initialValue: post.hospital,
                onChanged: (value) => post.hospital = value,
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Hospital'),
              ),
              gap,
              LabelledField(
                label: 'District',
                child: SearchableDropdown(
                  options: bangladeshDistricts,
                  selected: post.district,
                  hint: 'Type or choose a district',
                  icon: Icons.location_city_outlined,
                  errorText: showErrors ? post.districtError : null,
                  onSelected: post.setDistrict,
                ),
              ),
              gap,
              LabelledField(
                label: 'Required date',
                errorText: showErrors ? post.requiredDateErrorText : null,
                child: DateField(
                  value: post.requiredDate,
                  onChanged: post.setRequiredDate,
                  // The picker can't go into the past at all.
                  firstDate: post.today,
                  lastDate: DateTime(
                    post.today.year,
                    post.today.month,
                    post.today.day + maxDaysAhead,
                  ),
                  initialDate: post.today,
                  helpText: 'When is the blood needed?',
                  hasError: showErrors && post.requiredDateErrorText != null,
                ),
              ),
            ],
          ),
          gap,
          _Section(
            title: 'Contact',
            children: [
              AppTextField(
                label: 'Contact phone',
                hint: '01XXXXXXXXX',
                icon: Icons.phone_outlined,
                initialValue: post.contactPhone,
                keyboardType: TextInputType.phone,
                onChanged: (value) => post.contactPhone = value,
                validator: Validators.phone,
              ),
              const PrivacyNote('Shown only to donors who open your request.'),
              gap,
              AppTextField(
                label: 'Notes (optional)',
                hint: 'e.g. Surgery at 2 PM, please come by noon',
                initialValue: post.notes,
                maxLines: 3,
                maxLength: maxNotesLength,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                onChanged: (value) => post.notes = value,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (error != null) ...[
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.error),
            ),
            gap,
          ],
          AppButton(
            label: 'Post Request',
            icon: Icons.send_outlined,
            isLoading: post.isSubmitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your request goes live as Open straight away.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

/// A card with a small title, grouping related fields.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}
