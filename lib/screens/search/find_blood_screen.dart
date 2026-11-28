import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/donor_search_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/contact_locked_banner.dart';
import 'widgets/search_filters.dart';
import 'widgets/search_results.dart';

/// Find Blood: search donors by blood group, district, area and name
/// ("Finding donors" in docs/requirements.md, walkthrough Scenes 2 and 4).
///
/// Layout only. The state lives in DonorSearchProvider, which app.dart
/// creates for this route.
class FindBloodScreen extends StatelessWidget {
  const FindBloodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final search = context.watch<DonorSearchProvider>();
    final request = search.openRequest;

    return Scaffold(
      appBar: AppBar(title: const Text('Find Blood')),
      // One scroll view for filters and results, so small screens can
      // reach everything.
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (request != null) ...[
            _RequestNote(
              text:
                  'Filled in from your request: ${request.bloodGroup} '
                  'in ${request.district}.',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: SearchFilters(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Search',
            icon: Icons.search,
            isLoading: search.isLoading,
            onPressed: () {
              // Close the keyboard so the results are visible.
              FocusScope.of(context).unfocus();
              search.search();
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!search.canSeeContacts && !search.isLoading) ...[
            const ContactLockedBanner(),
            const SizedBox(height: AppSpacing.lg),
          ],
          const SearchResults(),
        ],
      ),
    );
  }
}

/// A one-line note above the filters, e.g. "Filled in from your request".
class _RequestNote extends StatelessWidget {
  const _RequestNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 18, color: AppColors.inkMuted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
