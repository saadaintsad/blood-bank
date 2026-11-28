/// Names of the app's screens, used with Navigator.pushNamed.
///
/// Keeping the names here (not as typed strings in each screen) means a
/// typo becomes a compile error instead of a "route not found" crash.
/// The table that maps each name to a screen is in app.dart.
class AppRoutes {
  AppRoutes._();

  /// The first screen. '/' is Flutter's name for the starting route.
  static const String home = '/';
  static const String login = '/login';

  /// Seeker sign-up (name, number, password). Pass `arguments: true` to
  /// continue to Find Blood after signing up.
  static const String seekerSignup = '/sign-up';

  /// The multi-step donor registration form.
  static const String donorRegistration = '/register-donor';

  /// Donor search. Needs a logged-in user.
  static const String findBlood = '/find-blood';

  /// One donor's details. Pass a DonorDetailsArgs as `arguments`.
  static const String donorDetails = '/donor-details';

  /// The Post Request form. Pass a PostRequestOrigin (utils/navigation.dart)
  /// as `arguments`; it decides where the user goes after posting.
  static const String postRequest = '/post-request';

  /// The logged-in user's own requests, with Mark Fulfilled and Cancel.
  static const String myRequests = '/my-requests';

  /// One request's details. Pass the request id (a String) as
  /// `arguments`. The seeker sees their own view, donors see theirs.
  static const String requestDetails = '/request-details';

  /// Open requests in the donor's district. Donors only.
  static const String openRequests = '/open-requests';

  /// Placeholder for screens that are not built yet. Pass the feature
  /// name as `arguments`, e.g. pushNamed(comingSoon, arguments: 'Find Blood').
  static const String comingSoon = '/coming-soon';
}
