import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/request_details_provider.dart';
import '../../theme/spacing.dart';
import '../../utils/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/message_panel.dart';
import 'widgets/emergency_alert_card.dart';
import 'widgets/interest_action.dart';
import 'widgets/interested_donors_section.dart';
import 'widgets/request_info_card.dart';
import 'widgets/seeker_actions.dart';
import 'widgets/seeker_contact_card.dart';

/// One blood request ("Blood requests" and the "I'm Interested flow" in
/// docs/requirements.md, walkthrough Scenes 5 and 6).
///
/// The seeker who posted it sees interested donors, Mark Fulfilled /
/// Cancel and Emergency Alert. Donors see the seeker's number and
/// "I'm Interested". Layout only: the state is in RequestDetailsProvider.
///
/// Open it with:
///   Navigator.pushNamed(context, AppRoutes.requestDetails,
///       arguments: request.id);
class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: _buildBody(context),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    final provider = context.watch<RequestDetailsProvider>();

    if (provider.isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    final request = provider.request;
    if (request == null) {
      return [
        MessagePanel(
          icon: Icons.cloud_off_outlined,
          title: provider.errorMessage ?? 'This request could not be found.',
          action: AppButton(
            label: 'Try again',
            icon: Icons.refresh,
            variant: AppButtonVariant.outlined,
            onPressed: provider.load,
          ),
        ),
      ];
    }

    final info = RequestInfoCard(request: request, status: provider.status);
    const gap = SizedBox(height: AppSpacing.md);

    return switch (provider.role) {
      RequestViewerRole.owner => [
        info,
        InterestedDonorsSection(
          donors: provider.interestedDonors,
          today: provider.now,
        ),
        if (provider.isOpen) ...[
          gap,
          EmergencyAlertCard(
            district: request.district,
            daysLeft: provider.emergencyDaysLeft,
            isSending: provider.isSendingAlert,
            onSend: () => _sendEmergencyAlert(context),
          ),
          const SizedBox(height: AppSpacing.lg),
          SeekerActions(
            isBusy: provider.isClosing,
            onMarkFulfilled: () => _markFulfilled(context),
            onCancel: () => _cancel(context),
          ),
        ],
      ],
      RequestViewerRole.donor => [
        info,
        gap,
        InterestAction(
          response: provider.myResponse,
          isOpen: provider.isOpen,
          blockReason: provider.interestBlockReason,
          now: provider.now,
          isLoading: provider.isResponding,
          onPressed: () => _expressInterest(context),
        ),
        if (provider.seekerPhone != null) ...[
          gap,
          SeekerContactCard(phone: provider.seekerPhone!),
        ],
      ],
      RequestViewerRole.other => [
        info,
        gap,
        MessagePanel(
          icon: Icons.volunteer_activism_outlined,
          title: 'Want to help?',
          message:
              'Register as a donor to respond to requests and see the '
              "seeker's number.",
          action: AppButton(
            label: 'Register as Donor',
            variant: AppButtonVariant.outlined,
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.donorRegistration),
          ),
        ),
      ],
    };
  }

  Future<void> _expressInterest(BuildContext context) async {
    final provider = context.read<RequestDetailsProvider>();
    // Read the messenger before `await`: the context may be gone after.
    final messenger = ScaffoldMessenger.of(context);
    final error = await provider.expressInterest();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Thanks! The seeker can now see your name and number.',
        ),
      ),
    );
  }

  Future<void> _sendEmergencyAlert(BuildContext context) async {
    final provider = context.read<RequestDetailsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final district = provider.request!.district;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Send an Emergency Alert?',
      message:
          'Every donor in $district with alerts on will be told about this '
          'request, whatever their blood group. You can only do this once '
          'every 15 days.',
      confirmLabel: 'Send alert',
      dismissLabel: 'Not now',
    );
    if (!confirmed) return;

    final error = await provider.sendEmergencyAlert();
    // Notifications are mocked for now (no Firebase yet).
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'Alert sent to donors in $district.')),
    );
  }

  Future<void> _markFulfilled(BuildContext context) {
    final patient = context.read<RequestDetailsProvider>().request!.patientName;
    return _confirmAndClose(
      context,
      title: 'Mark as fulfilled?',
      message:
          'Glad you found blood for $patient. The request will close and '
          "can't be reopened.",
      confirmLabel: 'Mark Fulfilled',
      successMessage: 'Request marked Fulfilled.',
      close: (provider) => provider.markFulfilled(),
    );
  }

  Future<void> _cancel(BuildContext context) {
    return _confirmAndClose(
      context,
      title: 'Cancel this request?',
      message:
          "It will close and can't be reopened. Without an open request, "
          "donors' phone numbers are hidden again.",
      confirmLabel: 'Cancel request',
      successMessage: 'Request cancelled.',
      close: (provider) => provider.cancel(),
    );
  }

  /// Asks first, then closes the request and reports the result.
  Future<void> _confirmAndClose(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String successMessage,
    required Future<String?> Function(RequestDetailsProvider) close,
  }) async {
    final provider = context.read<RequestDetailsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
    );
    if (!confirmed) return;

    final error = await close(provider);
    // The "closed by the seeker" notification is mocked: we just say so.
    final told = provider.interestedDonors.isEmpty
        ? ''
        : " Interested donors were told it's closed.";
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? '$successMessage$told')),
    );
  }
}
