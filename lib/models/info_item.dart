import 'package:flutter/widgets.dart';

/// A small piece of explanatory content: an icon, a title and one sentence.
///
/// Used for the "How it works" steps and the "Why Reddify" points on the
/// Home screen, and reusable later for health tips.
class InfoItem {
  const InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
