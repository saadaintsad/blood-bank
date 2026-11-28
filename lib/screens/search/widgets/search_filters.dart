import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/donor_search_provider.dart';
import '../../../theme/spacing.dart';
import '../../../utils/constants.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/blood_group_picker.dart';
import '../../../widgets/labelled_field.dart';
import '../../../widgets/searchable_dropdown.dart';

/// First entry of the district list; choosing it clears the district.
const String _anyDistrict = 'Any district';

/// First entry of the Dhaka area list; choosing it clears the area.
const String _anyArea = 'Any area';

/// The Find Blood filters: blood group (required), district, area, name
/// and "only available". Everything is stored in DonorSearchProvider.
class SearchFilters extends StatelessWidget {
  const SearchFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final search = context.watch<DonorSearchProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelledField(
          label: "Patient's blood group",
          errorText: search.bloodGroupError,
          child: BloodGroupPicker(
            selected: search.bloodGroup,
            onSelected: search.setBloodGroup,
            hasError: search.bloodGroupError != null,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LabelledField(
          label: 'District',
          note: 'Optional',
          child: SearchableDropdown(
            // DropdownMenu only reads its starting value once. The key
            // makes Flutter build a new one when the district changes,
            // e.g. when it is filled in from the user's open request.
            key: ValueKey('district-${search.district}'),
            options: const [_anyDistrict, ...bangladeshDistricts],
            selected: search.district,
            hint: 'Any district',
            icon: Icons.location_city_outlined,
            onSelected: (value) =>
                search.setDistrict(value == _anyDistrict ? null : value),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildAreaField(search),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Donor name (optional)',
          hint: 'Part of a name',
          icon: Icons.person_search_outlined,
          initialValue: search.name,
          onChanged: search.setName,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => search.search(),
        ),
        const SizedBox(height: AppSpacing.sm),
        // SwitchListTile is a whole row (title + switch) that toggles
        // when tapped anywhere, so the tap target is large.
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Only available donors'),
          subtitle: const Text('Hide donors who gave blood recently'),
          value: search.onlyAvailable,
          onChanged: search.setOnlyAvailable,
        ),
      ],
    );
  }

  /// Dhaka has a list of areas; other districts get a text field. Before a
  /// district is chosen, the area field is disabled.
  Widget _buildAreaField(DonorSearchProvider search) {
    const label = 'Area';
    const note = 'Listed first';
    final district = search.district;

    if (district == 'Dhaka') {
      return LabelledField(
        label: label,
        note: note,
        child: SearchableDropdown(
          key: ValueKey('dhaka-area-${search.area}'),
          options: const [_anyArea, ...dhakaAreas],
          selected: search.area.isEmpty ? null : search.area,
          hint: 'Any area',
          icon: Icons.place_outlined,
          onSelected: (value) => search.setArea(value == _anyArea ? '' : value),
        ),
      );
    }

    if (district == null) {
      return const LabelledField(
        label: label,
        note: note,
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
      label: '$label (optional)',
      hint: 'Area or neighbourhood',
      icon: Icons.place_outlined,
      initialValue: search.area,
      onChanged: search.setArea,
    );
  }
}
