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

  /// Placeholder for screens that are not built yet. Pass the feature
  /// name as `arguments`, e.g. pushNamed(comingSoon, arguments: 'Find Blood').
  static const String comingSoon = '/coming-soon';
}
