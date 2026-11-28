import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/donor_registration_provider.dart';
import '../../../../theme/spacing.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/validators.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/labelled_field.dart';
import '../../../../widgets/privacy_note.dart';
import '../../../../widgets/searchable_dropdown.dart';

/// District, area and optional extra details.
///
/// Dhaka donors pick their area from a list; everyone else types it.
class LocationStep extends StatelessWidget {
  const LocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final registration = context.watch<DonorRegistrationProvider>();
    final showErrors = registration.showErrors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Seekers search for donors by district and area. Your area is '
          'shown, never your exact address.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        LabelledField(
          label: 'District',
          child: SearchableDropdown(
            options: bangladeshDistricts,
            selected: registration.district,
            hint: 'Type or choose a district',
            icon: Icons.location_city_outlined,
            errorText: showErrors ? registration.districtError : null,
            onSelected: registration.setDistrict,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildAreaField(registration, showErrors),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Extra details (optional)',
          hint: 'Road, block or a landmark',
          icon: Icons.signpost_outlined,
          initialValue: registration.extraLocationDetails,
          onChanged: (value) => registration.extraLocationDetails = value,
          textInputAction: TextInputAction.done,
        ),
        const PrivacyNote('Private. Never shown to other users.'),
      ],
    );
  }

  Widget _buildAreaField(
    DonorRegistrationProvider registration,
    bool showErrors,
  ) {
    final district = registration.district;
    final areaError = showErrors ? registration.areaError : null;

    if (district == 'Dhaka') {
      return LabelledField(
        label: 'Area',
        child: SearchableDropdown(
          // A new key when the district changes makes Flutter build a
          // fresh dropdown, so the old district's area doesn't linger.
          key: const ValueKey('dhaka-area'),
          options: dhakaAreas,
          selected: registration.area.isEmpty ? null : registration.area,
          hint: 'Type or choose an area',
          icon: Icons.place_outlined,
          errorText: areaError,
          onSelected: registration.setArea,
        ),
      );
    }

    if (district == null) {
      return const LabelledField(
        label: 'Area',
        child: SearchableDropdown(
          options: [],
          selected: null,
          hint: 'Choose a district first',
          icon: Icons.place_outlined,
          enabled: false,
        ),
      );
    }

    return AppTextField(
      key: ValueKey('area-$district'),
      label: 'Area',
      hint: 'Area or neighbourhood',
      icon: Icons.place_outlined,
      initialValue: registration.area,
      onChanged: registration.setArea,
      validator: (value) => Validators.requiredField(value, fieldName: 'Area'),
    );
  }
}
