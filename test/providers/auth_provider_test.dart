import 'package:bloodbank/data/mock/mock_auth_repository.dart';
import 'package:bloodbank/data/mock/sample_users.dart';
import 'package:bloodbank/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Duration.zero makes the mock answer instantly, so tests stay fast.
  AuthProvider createProvider() =>
      AuthProvider(const MockAuthRepository(delay: Duration.zero));

  test('logs in with a sample account', () async {
    final auth = createProvider();

    final success =
        await auth.logIn(phone: '01700000001', password: samplePassword);

    expect(success, isTrue);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentUser!.name, 'Sample Seeker');
    expect(auth.errorMessage, isNull);
  });

  test('rejects a wrong password', () async {
    final auth = createProvider();

    final success =
        await auth.logIn(phone: '01700000001', password: 'wrong-pass');

    expect(success, isFalse);
    expect(auth.isLoggedIn, isFalse);
    expect(auth.errorMessage, 'Wrong mobile number or password.');
  });

  test('rejects an unknown number', () async {
    final auth = createProvider();

    final success =
        await auth.logIn(phone: '01999999999', password: samplePassword);

    expect(success, isFalse);
    expect(auth.errorMessage, isNotNull);
  });

  test('isLoading is true while logging in and false afterwards', () async {
    final auth = createProvider();
    final loadingValues = <bool>[];
    // Record isLoading every time the provider notifies its listeners.
    auth.addListener(() => loadingValues.add(auth.isLoading));

    await auth.logIn(phone: '01700000002', password: samplePassword);

    expect(loadingValues, [true, false]);
  });
}
