import 'package:flutter/material.dart';

import 'colors.dart';
import 'spacing.dart';
import 'text_styles.dart';

/// Builds the Material 3 theme for the whole app.
///
/// Styling buttons, fields and bars here means every screen gets the same
/// look for free, and screen files stay short.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    // Start from our crimson seed so Material fills in every colour role,
    // then pin the roles we care about to our exact brand colours.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.ink,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.inkMuted,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      error: AppColors.error,
    );

    final textTheme = AppTextStyles.textTheme;

    // One rounded shape reused by buttons, so they all match.
    const buttonShape = StadiumBorder();
    const buttonSize = Size(64, AppSizes.buttonHeight);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,

      // Crimson header band, like the top of a printed donor card.
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.onPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          // Keep even small text buttons at the 48dp touch-target size.
          minimumSize: const Size(48, AppSizes.minTouchTarget),
          textStyle: textTheme.labelLarge,
        ),
      ),

      inputDecorationTheme: _inputTheme(textTheme),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        side: const BorderSide(color: AppColors.border),
        labelStyle: textTheme.labelMedium,
        shape: const StadiumBorder(),
      ),

      // Button groups such as Male / Female / Other. The chosen one gets
      // the soft crimson fill, like a selected chip.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          selectedBackgroundColor: AppColors.primarySoft,
          selectedForegroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(0, AppSizes.minTouchTarget),
          textStyle: textTheme.labelLarge,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: AppColors.inkMuted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Crimson track when on. The thumb icon makes on/off readable
      // without relying on colour alone.
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => Icon(
            states.contains(WidgetState.selected) ? Icons.check : Icons.close,
          ),
        ),
      ),

      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.surface,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.onPrimary,
      ),

      // The open list of a DropdownMenu (district and area pickers).
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.surface),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Text cursor and selection highlight in brand colours (not browser blue).
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primarySoft,
        selectionHandleColor: AppColors.primary,
      ),
    );
  }

  /// Text fields: filled card-colour boxes with a hairline border that turns
  /// crimson when focused.
  static InputDecorationTheme _inputTheme(TextTheme textTheme) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.inkMuted),
      prefixIconColor: AppColors.inkMuted,
      suffixIconColor: AppColors.inkMuted,
      errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary, width: 2),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 2),
    );
  }
}
