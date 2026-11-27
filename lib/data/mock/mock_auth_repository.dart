import '../../models/user.dart';
import '../repositories/auth_repository.dart';
import 'sample_users.dart';

/// A pretend login service that checks the sample accounts in
/// sample_users.dart. No network calls.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository({this.delay = const Duration(milliseconds: 600)});

  /// How long to "wait for the server", so loading states can be seen.
  /// Tests pass Duration.zero to run instantly.
  final Duration delay;

  @override
  Future<AppUser> logIn({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(delay);

    for (final user in sampleUsers) {
      if (user.phone == phone && password == samplePassword) {
        return user;
      }
    }
    // Same message for a wrong number or a wrong password, so the app does
    // not reveal which numbers have accounts.
    throw const AuthException('Wrong mobile number or password.');
  }
}
