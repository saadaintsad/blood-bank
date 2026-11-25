import 'package:flutter/material.dart';

import '../models/info_item.dart';

// Static text for the Home screen. Kept here (not in the screen file) so
// the copy can be edited without touching layout code.
//
// Every point describes a feature Reddify is planned to have. We do not
// show made-up numbers like "10,000 donors" because we have no real data.

/// The three "How it works" steps, in order.
const List<InfoItem> howItWorksSteps = [
  InfoItem(
    icon: Icons.search,
    title: 'Find donors',
    description:
        'Search by blood group and district to see donors who are ready to give.',
  ),
  InfoItem(
    icon: Icons.call_outlined,
    title: 'Connect',
    description:
        'Call or text a donor directly, or post a request for others to see.',
  ),
  InfoItem(
    icon: Icons.favorite_outline,
    title: 'Save lives',
    description:
        'The donor gives blood at the hospital, and a patient gets what they need.',
  ),
];

/// The three "Why Reddify" trust points.
const List<InfoItem> trustPoints = [
  InfoItem(
    icon: Icons.map_outlined,
    title: 'All 64 districts',
    description: 'Look for donors anywhere in Bangladesh, close to the patient.',
  ),
  InfoItem(
    icon: Icons.phone_in_talk_outlined,
    title: 'Direct contact',
    description: 'Reach donors yourself in one tap. No middleman, no waiting.',
  ),
  InfoItem(
    icon: Icons.toggle_on_outlined,
    title: 'Honest availability',
    description:
        'Donors switch themselves on or off, so you only see who can give now.',
  ),
];
