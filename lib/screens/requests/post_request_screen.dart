import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/post_request_provider.dart';
import '../../theme/spacing.dart';
import '../../utils/app_routes.dart';
import '../../utils/navigation.dart';
import '../../utils/request_rules.dart';
import '../../widgets/app_button.dart';
import '../../widgets/message_panel.dart';
import 'widgets/post_request_form.dart';

/// Post Request: a seeker asks for blood ("Blood requests" in
/// docs/requirements.md, walkthrough Scene 3).
///
/// Layout only. app.dart creates the PostRequestProvider, which first
/// checks the 3-open-requests limit. Open it with:
///   Navigator.pushNamed(context, AppRoutes.postRequest,
///       arguments: PostRequestOrigin.home);
class PostRequestScreen extends StatelessWidget {
  const PostRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final origin = arguments is PostRequestOrigin
        ? arguments
        : PostRequestOrigin.home;
    final post = context.watch<PostRequestProvider>();

    final Widget body;
    if (post.isChecking) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (post.limitReached) {
      body = _LimitReachedPanel(origin: origin);
    } else {
      body = PostRequestForm(origin: origin);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Post Request')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [body],
      ),
    );
  }
}

/// Shown instead of the form when the user already has the maximum
/// number of open requests.
class _LimitReachedPanel extends StatelessWidget {
  const _LimitReachedPanel({required this.origin});

  final PostRequestOrigin origin;

  @override
  Widget build(BuildContext context) {
    return MessagePanel(
      icon: Icons.inventory_2_outlined,
      title: 'You have $maxOpenRequests open requests',
      message:
          'That is the most you can have at once. When one is done, '
          'mark it Fulfilled or Cancel it in My Requests, then post again.',
      action: AppButton(
        label: 'Go to My Requests',
        variant: AppButtonVariant.outlined,
        onPressed: () {
          if (origin == PostRequestOrigin.myRequests) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.myRequests);
          }
        },
      ),
    );
  }
}
