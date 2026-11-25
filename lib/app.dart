import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/phone_frame.dart';

/// The root widget of Reddify.
///
/// It sets the theme and the first screen. Navigation routes will be added
/// here in later stages.
class ReddifyApp extends StatelessWidget {
  const ReddifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // `builder` wraps whatever page is showing (the Navigator), so every
      // screen, dialog and snackbar appears inside the phone frame.
      builder: (context, child) => PhoneFrame(child: child!),
      // Shows one screen at a time during stage 1. Swap in HomeScreen()
      // (screens/home/home_screen.dart) to see the Home screen again.
      home: const LoginScreen(),
    );
  }
}
