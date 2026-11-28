import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock/mock_auth_repository.dart';
import 'data/mock/mock_donor_repository.dart';
import 'data/mock/mock_request_repository.dart';
import 'data/mock/mock_store.dart';
import 'data/repositories/donor_repository.dart';
import 'data/repositories/request_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/donor_search_provider.dart';
import 'providers/my_requests_provider.dart';
import 'providers/post_request_provider.dart';
import 'screens/auth/donor_registration/donor_registration_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/seeker_signup_screen.dart';
import 'screens/coming_soon/coming_soon_screen.dart';
import 'screens/donor/donor_details_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/requests/my_requests_screen.dart';
import 'screens/requests/post_request_screen.dart';
import 'screens/search/find_blood_screen.dart';
import 'theme/app_theme.dart';
import 'utils/app_routes.dart';
import 'utils/constants.dart';
import 'widgets/phone_frame.dart';

/// The root widget of Reddify.
///
/// It creates the repositories and app-wide providers, sets the theme and
/// lists every screen the app can navigate to (the routes).
class ReddifyApp extends StatefulWidget {
  const ReddifyApp({super.key});

  @override
  State<ReddifyApp> createState() => _ReddifyAppState();
}

// Stateful so the store is created once and kept, not rebuilt each time
// this widget rebuilds.
class _ReddifyAppState extends State<ReddifyApp> {
  // One shared in-memory "database" for every mock repository, so a donor
  // profile saved by one is seen by the others.
  final MockStore _store = MockStore();

  @override
  Widget build(BuildContext context) {
    // MultiProvider puts several providers above the whole app. Any screen
    // can then read them with context.read / context.watch. To switch to
    // Supabase later, only the repositories created here change.
    return MultiProvider(
      providers: [
        // Plain Provider: hands out an object that never changes.
        Provider<DonorRepository>(create: (_) => MockDonorRepository(_store)),
        Provider<RequestRepository>(
          create: (_) => MockRequestRepository(_store),
        ),
        // ChangeNotifierProvider: also rebuilds listeners when it changes.
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            MockAuthRepository(_store),
            context.read<DonorRepository>(),
          ),
        ),
      ],
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
          // Find Blood gets its own DonorSearchProvider. It is created when
          // the screen opens and thrown away when it closes, so the filters
          // start fresh each visit. `..load()` (a cascade) starts loading
          // straight after creating it.
          AppRoutes.findBlood: (context) => ChangeNotifierProvider(
            create: (context) => DonorSearchProvider(
              context.read<DonorRepository>(),
              context.read<RequestRepository>(),
              viewerId: context.read<AuthProvider>().currentUser?.id ?? '',
            )..load(),
            child: const FindBloodScreen(),
          ),
          AppRoutes.donorDetails: (_) => const DonorDetailsScreen(),
          // Post Request and My Requests also get fresh providers per visit.
          // They need a logged-in user; if there is none (e.g. someone
          // typed the address in Chrome), show Login instead.
          AppRoutes.postRequest: (context) {
            final user = context.read<AuthProvider>().currentUser;
            if (user == null) return const LoginScreen();
            return ChangeNotifierProvider(
              create: (context) => PostRequestProvider(
                context.read<RequestRepository>(),
                owner: user,
              )..load(),
              child: const PostRequestScreen(),
            );
          },
          AppRoutes.myRequests: (context) {
            final user = context.read<AuthProvider>().currentUser;
            if (user == null) return const LoginScreen();
            return ChangeNotifierProvider(
              create: (context) => MyRequestsProvider(
                context.read<RequestRepository>(),
                userId: user.id,
              )..load(),
              child: const MyRequestsScreen(),
            );
          },
          AppRoutes.comingSoon: (_) => const ComingSoonScreen(),
        },
      ),
    );
  }
}
