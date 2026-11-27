import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock/mock_auth_repository.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/phone_frame.dart';

/// The root widget of Reddify.
///
/// It creates the app-wide providers, sets the theme and the first screen.
/// Navigation routes will be added here in a later task.
class ReddifyApp extends StatelessWidget {
  const ReddifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider creates AuthProvider once and makes it
    // available to every screen below it. To switch to Supabase later,
    // only the repository passed in here changes.
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(const MockAuthRepository()),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // `builder` wraps whatever page is showing (the Navigator), so every
        // screen, dialog and snackbar appears inside the phone frame.
        builder: (context, child) => PhoneFrame(child: child!),
        // Shows one screen at a time for now. Swap in HomeScreen()
        // (screens/home/home_screen.dart) to see the Home screen again.
        home: const LoginScreen(),
      ),
    );
  }
}
