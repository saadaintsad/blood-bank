import 'package:flutter/widgets.dart';

import 'app_routes.dart';

/// Closes every screen above Home after the user creates an account.
///
/// When [continueToFindBlood] is true, it then opens Find Blood, because
/// the user started there (Home > Find Blood > Sign up). Find Blood is
/// still a placeholder screen, so it opens AppRoutes.comingSoon.
void returnHomeAfterSignUp(
  NavigatorState navigator, {
  bool continueToFindBlood = false,
}) {
  // popUntil keeps removing the top screen until the test is true.
  // route.isFirst is true for the bottom screen of the stack, Home.
  navigator.popUntil((route) => route.isFirst);
  if (continueToFindBlood) {
    navigator.pushNamed(AppRoutes.comingSoon, arguments: 'Find Blood');
  }
}
