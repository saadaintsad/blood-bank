import 'package:flutter/material.dart';

/// A full-width DropdownMenu you can type into to filter the list.
/// Used for the 64 districts and the Dhaka areas (registration and Find
/// Blood).
///
/// Example:
///   SearchableDropdown(
///     options: bangladeshDistricts,
///     selected: provider.district,
///     hint: 'Type or choose a district',
///     icon: Icons.location_city_outlined,
///     onSelected: provider.setDistrict,
///   )
class SearchableDropdown extends StatelessWidget {
  const SearchableDropdown({
    super.key,
    required this.options,
    required this.selected,
    required this.hint,
    required this.icon,
    this.errorText,
    this.onSelected,
    this.enabled = true,
  });

  final List<String> options;
  final String? selected;
  final String hint;
  final IconData icon;
  final String? errorText;
  final ValueChanged<String>? onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: selected,
      enabled: enabled,
      // Stretch to the full width of the form.
      expandedInsets: EdgeInsets.zero,
      // Typing narrows the list, e.g. "dh" shows Dhaka and Dhanmondi.
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 320,
      hintText: hint,
      leadingIcon: Icon(icon),
      errorText: errorText,
      dropdownMenuEntries: [
        for (final option in options)
          DropdownMenuEntry(value: option, label: option),
      ],
      onSelected: (value) {
        if (value != null) onSelected?.call(value);
      },
    );
  }
}
