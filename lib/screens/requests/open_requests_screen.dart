import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../providers/open_requests_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../utils/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/compatible_label.dart';
import '../../widgets/message_panel.dart';
import '../../widgets/request_card.dart';

/// Open Requests: open blood requests in the donor's district, the ones
/// their blood group can give to first ("Blood requests" in
/// docs/requirements.md).
///
/// Layout only. The state lives in OpenRequestsProvider (made in app.dart).
class OpenRequestsScreen extends StatelessWidget {
  const OpenRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Open Requests')),
      // RefreshIndicator: pull the list down to load it again.
      body: RefreshIndicator(
        onRefresh: context.read<OpenRequestsProvider>().load,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [_buildBody(context)],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final provider = context.watch<OpenRequestsProvider>();

    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final error = provider.errorMessage;
    if (error != null) {
      return MessagePanel(
        icon: Icons.cloud_off_outlined,
        title: error,
        action: AppButton(
          label: 'Try again',
          icon: Icons.refresh,
          variant: AppButtonVariant.outlined,
          onPressed: provider.load,
        ),
      );
    }

    final district = provider.district ?? 'your district';
    final requests = provider.requests;
    if (requests.isEmpty) {
      return MessagePanel(
        icon: Icons.inbox_outlined,
        title: 'No open requests in $district right now',
        message:
            "When someone posts a request in $district, it will show here. "
            'Pull down to check again.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Requests in $district',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Requests your blood group can give to are shown first. Tap one '
          "to see the seeker's number and respond.",
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final request in requests) ...[
          RequestCard(
            request: request,
            // Every request here is Open, the list only has live ones.
            status: RequestStatus.open,
            label: provider.isCompatible(request)
                ? const CompatibleLabel(text: 'You can give')
                : null,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.requestDetails,
                arguments: request.id,
              );
              // Something may have changed (e.g. the donor responded).
              provider.load();
            },
          ),
          const SizedBox(height: AppSpacing.sm + 4),
        ],
      ],
    );
  }
}
