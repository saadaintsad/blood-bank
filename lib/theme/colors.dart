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
  // Donor status: Green / Yellow / Red
  // ---------------------------------------------------------------------------
  // Red is also our brand colour, so a status must never rely on colour
  // alone. StatusChip always shows an icon and a word next to the colour.
  // Each status has an icon colour, a text colour and a soft background.

  /// Green: Available.
  static const Color statusAvailable = Color(0xFF1D6B3A);
  static const Color statusAvailableSoft = Color(0xFFE3F1E7);

  /// Yellow: Recently donated. Pure yellow is unreadable on white, so the
  /// icon is a deep amber and the text an even darker amber.
  static const Color statusRecentlyDonated = Color(0xFFB07800);
  static const Color statusRecentlyDonatedText = Color(0xFF7A4A00);
  static const Color statusRecentlyDonatedSoft = Color(0xFFFBEED3);

  /// Red: Not available. A bright scarlet, clearly different from the deep
  /// brand crimson. Its label uses [ink] so red text is never mistaken for
  /// a crimson button or link.
  static const Color statusNotAvailable = Color(0xFFE53935);
  static const Color statusNotAvailableSoft = Color(0xFFFDEBEA);

  // ---------------------------------------------------------------------------
  // Neutral (closed requests)
  // ---------------------------------------------------------------------------

  /// Soft grey background for things that are over, like a Cancelled or
  /// Expired request. Its text and icon use [inkMuted].
  static const Color neutralSoft = Color(0xFFECE8E2);

  // ---------------------------------------------------------------------------
  // Form errors
  // ---------------------------------------------------------------------------

  static const Color error = Color(0xFFB3261E);
  static const Color errorSoft = Color(0xFFFBE4E2);

  // ---------------------------------------------------------------------------
  // Web preview
  // ---------------------------------------------------------------------------

  /// Neutral backdrop shown around the phone frame on wide screens (Chrome).
  static const Color desktopBackdrop = Color(0xFF2A2F33);
}
