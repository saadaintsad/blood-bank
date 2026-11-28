import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/blood_request.dart';
import '../../providers/my_requests_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../utils/app_routes.dart';
import '../../utils/navigation.dart';
import '../../utils/request_rules.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/message_panel.dart';
import '../../widgets/request_card.dart';

/// My Requests: the user's own blood requests with their status, and Mark
/// Fulfilled / Cancel for the open ones ("Blood requests" in
/// docs/requirements.md).
///
/// Layout only. The state lives in MyRequestsProvider (made in app.dart).
class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  /// Opens Post Request and reloads the list if a request was posted.
  Future<void> _postRequest(BuildContext context) async {
    final provider = context.read<MyRequestsProvider>();
    // pushNamed returns a Future that completes when that screen pops,
    // with whatever it passed to pop() (here: true after posting).
    final posted = await Navigator.pushNamed(
      context,
      AppRoutes.postRequest,
      arguments: PostRequestOrigin.myRequests,
    );
    if (posted == true) provider.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Post Request',
            onPressed: () => _postRequest(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [_buildBody(context)],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final provider = context.watch<MyRequestsProvider>();

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

    final requests = provider.requests;
    if (requests.isEmpty) {
      return MessagePanel(
        icon: Icons.bloodtype_outlined,
        title: 'No requests yet',
        message:
            'Post a request when you need blood. Donors can then see '
            'it, and you can see their phone numbers in Find Blood.',
        action: AppButton(
          label: 'Post Request',
          icon: Icons.add,
          onPressed: () => _postRequest(context),
        ),
      );
    }

    final openCount = requests.where(provider.canClose).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$openCount of $maxOpenRequests open requests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Open requests close by themselves 48 hours after the required '
          'date.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final request in requests) ...[
          _buildCard(context, provider, request),
          const SizedBox(height: AppSpacing.sm + 4),
        ],
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    MyRequestsProvider provider,
    BloodRequest request,
  ) {
    final canClose = provider.canClose(request);
    return RequestCard(
      request: request,
      status: provider.statusOf(request),
      isBusy: provider.closingId == request.id,
      onMarkFulfilled: canClose ? () => _markFulfilled(context, request) : null,
      onCancel: canClose ? () => _cancel(context, request) : null,
      onTap: () => _openDetails(context, request),
    );
  }

  /// Opens the request's details (the seeker view) and reloads the list
  /// afterwards, because it may have been closed there.
  Future<void> _openDetails(BuildContext context, BloodRequest request) async {
    final provider = context.read<MyRequestsProvider>();
    await Navigator.pushNamed(
      context,
      AppRoutes.requestDetails,
      arguments: request.id,
    );
    provider.load();
  }

  Future<void> _markFulfilled(BuildContext context, BloodRequest request) {
    return _confirmAndClose(
      context,
      title: 'Mark as fulfilled?',
      message:
          'Glad you found blood for ${request.patientName}. The request '
          "will close and can't be reopened.",
      confirmLabel: 'Mark Fulfilled',
      successMessage: 'Request marked Fulfilled.',
      close: (provider) => provider.markFulfilled(request.id),
    );
  }

  Future<void> _cancel(BuildContext context, BloodRequest request) {
    return _confirmAndClose(
      context,
      title: 'Cancel this request?',
      message:
          "It will close and can't be reopened. Without an open "
          "request, donors' phone numbers are hidden again.",
      confirmLabel: 'Cancel request',
      successMessage: 'Request cancelled.',
      close: (provider) => provider.cancel(request.id),
    );
  }

  /// Asks first, then closes the request and reports the result.
  Future<void> _confirmAndClose(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String successMessage,
    required Future<String?> Function(MyRequestsProvider) close,
  }) async {
    final provider = context.read<MyRequestsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    );
    if (!confirmed) return;

    final error = await close(provider);
    messenger.showSnackBar(SnackBar(content: Text(error ?? successMessage)));
  }
}
