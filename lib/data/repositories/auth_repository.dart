import '../../models/user.dart';

/// What the app needs from an authentication service.
///
/// This is an *abstract* class: it only lists the methods, without code.
/// Today MockAuthRepository fills them in with an in-memory store. Later a
/// SupabaseAuthRepository will fill them in for real, and no screen has to
/// change, because screens only know about this interface.
abstract class AuthRepository {
  /// Logs in with a mobile number (already normalized to 01XXXXXXXXX) and
  /// a password. Returns the user, or throws [AuthException] on failure.
  Future<AppUser> logIn({required String phone, required String password});

  /// Creates a new account and returns it. [phone] must already be
  /// normalized. Throws [AuthException] if the number is already in use.
  Future<AppUser> signUp({
    required String name,
    required String phone,
    required String password,
  });
}

/// Thrown when logging in or signing up fails. [message] is safe to show
/// to the user.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
