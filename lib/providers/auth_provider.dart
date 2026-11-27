import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/donor_repository.dart';
import '../models/donor.dart';
import '../models/user.dart';

/// Holds the login state and tells listening widgets when it changes.
///
/// A ChangeNotifier is a class that can call notifyListeners(). Widgets
/// that "watch" it (with Provider's context.watch) rebuild when it does.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository, this._donorRepository);

  // The provider talks to the interfaces, not to the mocks directly, so the
  // Supabase versions can be swapped in later from app.dart.
  final AuthRepository _authRepository;
  final DonorRepository _donorRepository;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// The logged-in user, or null when nobody is logged in.
  AppUser? get currentUser => _currentUser;

  /// True while a login, sign-up or donor registration is running.
  bool get isLoading => _isLoading;

  /// Message from the last failed action, or null.
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _currentUser != null;

  /// Tries to log in. Returns true on success.
  ///
  /// [phone] must already be normalized to 01XXXXXXXXX.
  Future<bool> logIn({required String phone, required String password}) {
    return _run(() async {
      _currentUser =
          await _authRepository.logIn(phone: phone, password: password);
    });
  }

  /// Creates a seeker account and logs straight into it. Returns true on
  /// success. [phone] must already be normalized.
  Future<bool> signUp({
    required String name,
    required String phone,
    required String password,
  }) {
    return _run(() async {
      _currentUser = await _authRepository.signUp(
        name: name,
        phone: phone,
        password: password,
      );
    });
  }

  /// Adds [profile] to the logged-in account, making the user a donor.
  /// Returns true on success.
  ///
  /// For a brand-new user, call [signUp] first so there is an account
  /// (and a user id) to attach the profile to.
  Future<bool> registerDonor(DonorProfile profile) {
    return _run(() async {
      await _donorRepository.registerDonor(profile);
      _currentUser = _currentUser!.copyWith(isDonor: true);
    });
  }

  /// Logs the current user out.
  ///
  /// With mock data there is nothing to tell a server, so we only clear
  /// the local state. The Supabase version will also sign out there.
  void logOut() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners(); // Screens watching us switch to the logged-out view.
  }

  /// Runs [action] with the spinner on, and turns a repository error into
  /// [errorMessage]. Returns true if [action] finished without an error.
  ///
  /// logIn, signUp and registerDonor all need the same steps, so they share
  /// this helper instead of repeating them.
  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Show the spinner.

    try {
      await action();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } on DonorException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      // `finally` runs after success *and* failure, so the spinner always
      // stops.
      _isLoading = false;
      notifyListeners();
    }
  }
}
