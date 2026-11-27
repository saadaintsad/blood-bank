/// Spacing, corner radius and fixed sizes for the whole app.
///
/// Keeping these in one file means a number like "16" has a name
/// (AppSpacing.md) and can be changed everywhere at once.
library;

/// Spacing scale. Use these for padding and gaps instead of random numbers.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner radius values for rounded shapes.
class AppRadius {
  AppRadius._();

  static const double badge = 10;
  static const double field = 16;
  static const double card = 20;
}

/// Fixed sizes used across the app.
class AppSizes {
  AppSizes._();

  /// Smallest comfortable size for anything tappable (Material guideline).
  static const double minTouchTarget = 48;

  /// Height of AppButton. A little taller than 48 so it is easy to hit.
  static const double buttonHeight = 52;

  /// The app is designed for phones. On wider screens (like Chrome on a
  /// laptop) it is shown inside a frame this wide.
  static const double maxPhoneWidth = 430;
}
