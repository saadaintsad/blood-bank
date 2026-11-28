import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/donor_search_result.dart';
import '../../../providers/donor_search_provider.dart';
import '../../../theme/spacing.dart';
import '../../../utils/app_routes.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/donor_card.dart';
import '../../../widgets/message_panel.dart';

/// The lower half of Find Blood. It shows one of five states: a hint
/// before the first search, loading, an error, "no donors", or the list.
class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  void _openDetails(BuildContext context, DonorSearchResult donor) {
    final search = context.read<DonorSearchProvider>();
    Navigator.pushNamed(
      context,
      AppRoutes.donorDetails,
      arguments: DonorDetailsArgs(
        donor: donor,
        phone: search.phoneFor(donor.donorId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<DonorSearchProvider>();

    if (search.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final error = search.errorMessage;
    if (error != null) {
      return MessagePanel(
        icon: Icons.cloud_off_outlined,
        title: error,
        action: AppButton(
          label: 'Try again',
          icon: Icons.refresh,
          variant: AppButtonVariant.outlined,
          onPressed: search.search,
        ),
      );
    }

    if (!search.hasSearched) {
      return const MessagePanel(
        icon: Icons.bloodtype_outlined,
        title: "Choose the patient's blood group",
        message: 'Then press Search to see donors who can give.',
      );
    }

    final results = search.results;
    if (results.isEmpty) {
      return const MessagePanel(
        icon: Icons.person_off_outlined,
        title: 'No donors found',
        message:
            'Try another district, clear the name, or turn off '
            '"Only available donors".',
      );
    }

    final count = results.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          count == 1 ? '1 donor found' : '$count donors found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        for (final donor in results) ...[
          DonorCard(
            donor: donor,
            phone: search.phoneFor(donor.donorId),
            onTap: () => _openDetails(context, donor),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
        ],
      ],
    );
  }
}
