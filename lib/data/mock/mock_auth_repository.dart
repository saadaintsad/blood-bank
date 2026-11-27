import '../../models/user.dart';
import '../repositories/auth_repository.dart';
import 'mock_store.dart';

/// A pretend login service that keeps accounts in a [MockStore].
/// No network calls.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(
    this._store, {
    this.delay = const Duration(milliseconds: 600),
  });

  final MockStore _store;

  /// How long to "wait for the server", so loading states can be seen.
  /// Tests pass Duration.zero to run instantly.
  final Duration delay;

  @override
  Future<AppUser> logIn({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(delay);

    final user = _store.usersByPhone[phone];
    if (user == null || _store.passwordsByPhone[phone] != password) {
      // Same message for a wrong number or a wrong password, so the app
      // does not reveal which numbers have accounts.
      throw const AuthException('Wrong mobile number or password.');
    }
    return _withDonorFlag(user);
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(delay);

    if (_store.usersByPhone.containsKey(phone)) {
      throw const AuthException(
        'An account with this number already exists. Log in instead.',
      );
    }

    final user = AppUser(
      id: _store.createUserId(),
      name: name.trim(),
      phone: phone,
    );
    _store.usersByPhone[phone] = user;
    _store.passwordsByPhone[phone] = password;
    return user;
  }

  /// A user is a donor when the store holds a donor profile for them.
  /// Deciding it here (not saving a flag) means it can never get out of
  /// step with the profiles that MockDonorRepository saves.
  AppUser _withDonorFlag(AppUser user) {
    final isDonor = _store.donorProfilesByUserId.containsKey(user.id);
    return user.copyWith(isDonor: isDonor);
  }
}
