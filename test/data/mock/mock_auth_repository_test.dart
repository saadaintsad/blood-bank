import 'package:bloodbank/data/mock/mock_auth_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/data/mock/sample_users.dart';
import 'package:bloodbank/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAuthRepository repository;

  // setUp runs before every test, so each test starts with a clean store.
  setUp(() {
    repository = MockAuthRepository(MockStore(), delay: Duration.zero);
  });

  test('sample accounts can still log in', () async {
    final user =
        await repository.logIn(phone: '01700000002', password: samplePassword);

    expect(user.name, 'Sample Donor');
    expect(user.isDonor, isTrue);
  });

  test('a signed-up account can log in with its password', () async {
    final created = await repository.signUp(
      name: '  Test Seeker  ',
      phone: '01800000009',
      password: 'secret123',
    );
    final loggedIn =
        await repository.logIn(phone: '01800000009', password: 'secret123');

    expect(created.name, 'Test Seeker'); // spaces trimmed
    expect(loggedIn.id, created.id);
    expect(loggedIn.isDonor, isFalse);
  });

  test('each new account gets its own id', () async {
    final first = await repository.signUp(
      name: 'A',
      phone: '01800000001',
      password: 'secret123',
    );
    final second = await repository.signUp(
      name: 'B',
      phone: '01800000002',
      password: 'secret123',
    );

    expect(first.id, isNot(second.id));
  });

  test('signing up with a used number throws AuthException', () async {
    // expectLater + throwsA checks that the Future fails with that error.
    // `await` makes the test wait until that check has finished.
    await expectLater(
      repository.signUp(
        name: 'Copy',
        phone: '01700000001',
        password: 'secret123',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('a new account with the wrong password cannot log in', () async {
    await repository.signUp(
      name: 'Test Seeker',
      phone: '01800000009',
      password: 'secret123',
    );

    await expectLater(
      repository.logIn(phone: '01800000009', password: 'wrong-pass'),
      throwsA(isA<AuthException>()),
    );
  });
}
