import 'package:flutter/widgets.dart';

import 'app_routes.dart';

/// Closes every screen above Home after the user creates an account.
///
/// When [continueToFindBlood] is true, it then opens Find Blood, because
/// the user started there (Home > Find Blood > Sign up).
void returnHomeAfterSignUp(
  NavigatorState navigator, {
  bool continueToFindBlood = false,
}) {
  // popUntil keeps removing the top screen until the test is true.
  // route.isFirst is true for the bottom screen of the stack, Home.
  navigator.popUntil((route) => route.isFirst);
  if (continueToFindBlood) {
    navigator.pushNamed(AppRoutes.findBlood);
  }
}

/// Where Post Request was opened from. It decides where the user lands
/// after posting. Pass it as `arguments` to AppRoutes.postRequest.
enum PostRequestOrigin {
  /// Home's Post Request button. Goes on to My Requests.
  home,

  /// My Requests' "+" button. Goes back to My Requests, which reloads.
  myRequests,

  /// The "Post a blood request to see numbers" banner on Find Blood or
  /// Donor details. Goes back to a fresh Find Blood, which now fills in
  /// from the new request and shows phone numbers.
  contactBanner,
}

/// Moves on after a request is posted (see [PostRequestOrigin]).
void leavePostRequest(NavigatorState navigator, PostRequestOrigin origin) {
  switch (origin) {
    case PostRequestOrigin.home:
      // Replace, so Back from My Requests goes Home, not to the form.
      navigator.pushReplacementNamed(AppRoutes.myRequests);
    case PostRequestOrigin.myRequests:
      // `true` tells My Requests something changed.
      navigator.pop(true);
    case PostRequestOrigin.contactBanner:
      // The old Find Blood screen loaded before the request existed, so
      // replace it with a new one that checks again.
      navigator.popUntil((route) => route.isFirst);
      navigator.pushNamed(AppRoutes.findBlood);
  }
}
