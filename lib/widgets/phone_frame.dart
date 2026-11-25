import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';

/// Shows the app inside a phone-sized frame on wide screens.
///
/// On a real phone this does nothing. In Chrome on a laptop it centres the
/// app at [AppSizes.maxPhoneWidth] wide on a neutral backdrop, so every
/// screen looks and screenshots like a mobile app.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  /// The app content (in our case, the Navigator with all the screens).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Narrow screen: it already is a phone, show the app as-is.
        if (constraints.maxWidth <= AppSizes.maxPhoneWidth) {
          return child;
        }

        // Tell the screens inside that the "screen" is only phone-wide.
        // Without this, MediaQuery.sizeOf(context) would report the full
        // browser width and layouts based on it would come out too wide.
        final mediaQuery = MediaQuery.of(context);
        final phoneSize = Size(AppSizes.maxPhoneWidth, constraints.maxHeight);

        return ColoredBox(
          color: AppColors.desktopBackdrop,
          child: Center(
            child: Container(
              width: AppSizes.maxPhoneWidth,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 40,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              // ClipRect keeps dialogs and sheets from drawing outside.
              child: ClipRect(
                child: MediaQuery(
                  data: mediaQuery.copyWith(size: phoneSize),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
