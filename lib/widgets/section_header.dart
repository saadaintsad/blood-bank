import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// A title for a group of content, with an optional action on the right.
///
/// Example:
///   SectionHeader(
///     title: 'Urgent requests',
///     actionLabel: 'See all',
///     onAction: _openRequests,
///   )
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;

  /// Text for the small button on the right, e.g. "See all".
  final String? actionLabel;

  /// Called when the action is tapped. The button only shows if both
  /// [actionLabel] and [onAction] are given.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && onAction != null;

    return Padding(
      // More space above a heading than below it groups it with its content.
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            // Mark as a heading so screen readers can jump between sections.
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          if (hasAction)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
