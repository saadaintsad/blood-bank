import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../models/user.dart';

/// Holds the login state and tells listening widgets when it changes.
///
/// A ChangeNotifier is a class that can call notifyListeners(). Widgets
/// that "watch" it (with Provider's context.watch) rebuild when it does.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  // The provider talks to the interface, not to the mock directly, so the
  // Supabase version can be swapped in later from app.dart.
  final AuthRepository _repository;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// The logged-in user, or null when nobody is logged in.
  AppUser? get currentUser => _currentUser;

  /// True while a login request is running.
  bool get isLoading => _isLoading;

  /// Message from the last failed login, or null.
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _currentUser != null;

  /// Tries to log in. Returns true on success.
  ///
  /// [phone] must already be normalized to 01XXXXXXXXX.
  Future<bool> logIn({required String phone, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Show the spinner.

    try {
      _currentUser = await _repository.logIn(phone: phone, password: password);
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      // `finally` runs after success *and* failure, so the spinner always
      // stops.
      _isLoading = false;
      notifyListeners();
    }
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
}
