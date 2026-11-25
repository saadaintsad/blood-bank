import 'package:flutter/material.dart';

/// Every colour used in Reddify lives here.
///
/// Screens should not write hex codes directly. Use these names (or the
/// theme's ColorScheme) so the whole app can be re-coloured in one place.
class AppColors {
  // A private constructor stops anyone from creating an AppColors object.
  // We only want to read the static colours below.
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Deep warm crimson, like stamp ink. Used for primary actions and
  /// blood-group stamps. It is darker than pure red so white text on it
  /// stays easy to read (contrast about 7.5 : 1).
  static const Color primary = Color(0xFFA3122A);

  /// Slightly darker crimson for pressed states and strong emphasis.
  static const Color primaryDark = Color(0xFF7E0D20);

  /// Very light crimson tint for selected chips and soft highlights.
  static const Color primarySoft = Color(0xFFF7E4E7);

  /// Text and icons placed on top of [primary].
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------------

  /// App background: soft warm off-white, like donor-card stock.
  static const Color background = Color(0xFFF4F1EC);

  /// Cards, text fields and sheets sit on this slightly lighter surface.
  static const Color surface = Color(0xFFFFFDF9);

  /// Hairline borders and dividers.
  static const Color border = Color(0xFFE5DED5);

  // ---------------------------------------------------------------------------
  // Text ("ink")
  // ---------------------------------------------------------------------------

  /// Main text colour: a dark slate, softer than pure black.
  static const Color ink = Color(0xFF1E2326);

  /// Secondary text such as hints and captions (passes 4.5 : 1 contrast).
  static const Color inkMuted = Color(0xFF5B6469);

  // ---------------------------------------------------------------------------
  // States
  // ---------------------------------------------------------------------------
  // Red is our brand colour, so states must never rely on colour alone.
  // Always pair them with an icon or a word ("Available", "Pending").

  static const Color success = Color(0xFF1D6B3A);
  static const Color successSoft = Color(0xFFE3F1E7);

  static const Color warning = Color(0xFF8A5300);
  static const Color warningSoft = Color(0xFFFBEED3);

  static const Color error = Color(0xFFB3261E);
  static const Color errorSoft = Color(0xFFFBE4E2);

  // ---------------------------------------------------------------------------
  // Web preview
  // ---------------------------------------------------------------------------

  /// Neutral backdrop shown around the phone frame on wide screens (Chrome).
  static const Color desktopBackdrop = Color(0xFF2A2F33);
}
