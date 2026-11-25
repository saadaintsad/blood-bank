import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text styles for Reddify, built on the Archivo typeface.
///
/// Material 3 names text by role (display, headline, title, body, label).
/// Screens should pick a role from `Theme.of(context).textTheme` instead of
/// choosing font sizes by hand, so text stays consistent everywhere.
class AppTextStyles {
  AppTextStyles._();

  /// The full Material 3 type scale used by the theme.
  static TextTheme get textTheme {
    return TextTheme(
      // Large, rare text such as a hero number.
      displaySmall: _archivo(32, FontWeight.w800, height: 1.15),

      // Screen titles inside the page body ("Find a donor").
      headlineMedium: _archivo(26, FontWeight.w700, height: 1.2),
      headlineSmall: _archivo(22, FontWeight.w700, height: 1.25),

      // App bar titles, card titles, section headers.
      titleLarge: _archivo(20, FontWeight.w700, height: 1.3),
      titleMedium: _archivo(16, FontWeight.w600, height: 1.35),
      titleSmall: _archivo(14, FontWeight.w600, height: 1.4),

      // Normal reading text.
      bodyLarge: _archivo(16, FontWeight.w400, height: 1.5),
      bodyMedium: _archivo(14, FontWeight.w400, height: 1.5),
      bodySmall: _archivo(12, FontWeight.w400,
          height: 1.4, color: AppColors.inkMuted),

      // Buttons, chips, field labels and small captions.
      labelLarge: _archivo(15, FontWeight.w600, height: 1.2),
      labelMedium: _archivo(13, FontWeight.w600, height: 1.2),
      labelSmall: _archivo(11, FontWeight.w600,
          height: 1.2, letterSpacing: 0.6, color: AppColors.inkMuted),
    );
  }

  /// Heavy style for the letters inside a blood-group stamp ("AB+").
  /// The size is set by the badge itself, so only weight and spacing here.
  static TextStyle get bloodGroup {
    return GoogleFonts.archivo(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1,
      color: AppColors.primary,
    );
  }

  /// Small helper so each style above is one short line.
  static TextStyle _archivo(
    double size,
    FontWeight weight, {
    double? height,
    double letterSpacing = 0,
    Color color = AppColors.ink,
  }) {
    return GoogleFonts.archivo(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }
}
