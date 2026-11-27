import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock/mock_auth_repository.dart';
import 'data/mock/mock_donor_repository.dart';
import 'data/mock/mock_store.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/donor_registration/donor_registration_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/seeker_signup_screen.dart';
import 'screens/coming_soon/coming_soon_screen.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'utils/app_routes.dart';
import 'utils/constants.dart';
import 'widgets/phone_frame.dart';

/// The root widget of Reddify.
///
/// It creates the app-wide providers, sets the theme and lists every
/// screen the app can navigate to (the routes).
class ReddifyApp extends StatelessWidget {
  const ReddifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider creates AuthProvider once and makes it
    // available to every screen below it. To switch to Supabase later,
    // only the repositories passed in here change.
    return ChangeNotifierProvider(
      create: (_) {
        // One shared in-memory "database" for both mock repositories, so
        // a donor profile saved by one is seen by the other.
        final store = MockStore();
        return AuthProvider(
          MockAuthRepository(store),
          MockDonorRepository(store),
        );
      },
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // `builder` wraps whatever page is showing (the Navigator), so every
        // screen, dialog and snackbar appears inside the phone frame.
        builder: (context, child) => PhoneFrame(child: child!),
        // Named routes: each name maps to a function that builds a screen.
        // Screens open each other with Navigator.pushNamed(context, name),
        // which puts the new screen on top of a stack; pop() goes back.
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.seekerSignup: (_) => const SeekerSignupScreen(),
          AppRoutes.donorRegistration: (_) => const DonorRegistrationScreen(),
          AppRoutes.comingSoon: (_) => const ComingSoonScreen(),
        },
      ),
    );
  }
}
