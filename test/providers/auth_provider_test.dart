import 'package:bloodbank/data/mock/mock_auth_repository.dart';
import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/data/mock/sample_users.dart';
import 'package:bloodbank/models/donor.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A fresh store per test, so accounts made in one test don't leak into
  // the next. Duration.zero makes the mocks answer instantly.
  AuthProvider createProvider() {
    final store = MockStore();
    return AuthProvider(
      MockAuthRepository(store, delay: Duration.zero),
      MockDonorRepository(store, delay: Duration.zero),
    );
  }

  DonorProfile profileFor(String userId) => DonorProfile(
    userId: userId,
    bloodGroup: 'A-',
    gender: Gender.male,
    dateOfBirth: DateTime(1995, 6, 1),
    district: 'Dhaka',
    area: 'Rampura',
    status: DonorStatus.available,
  );

  test('logs in with a sample account', () async {
    final auth = createProvider();

    final success = await auth.logIn(
      phone: '01700000001',
      password: samplePassword,
    );

    expect(success, isTrue);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentUser!.name, 'Sample Seeker');
    expect(auth.errorMessage, isNull);
  });

  test('rejects a wrong password', () async {
    final auth = createProvider();

    final success = await auth.logIn(
      phone: '01700000001',
      password: 'wrong-pass',
    );

    expect(success, isFalse);
    expect(auth.isLoggedIn, isFalse);
    expect(auth.errorMessage, 'Wrong mobile number or password.');
  });

  test('rejects an unknown number', () async {
    final auth = createProvider();

    final success = await auth.logIn(
      phone: '01999999999',
      password: samplePassword,
    );

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

  test('the sample donor is a donor and the sample seeker is not', () async {
    final auth = createProvider();

    await auth.logIn(phone: '01700000001', password: samplePassword);
    expect(auth.currentUser!.isDonor, isFalse);

    await auth.logIn(phone: '01700000002', password: samplePassword);
    expect(auth.currentUser!.isDonor, isTrue);
  });

  test('logOut clears the user and notifies listeners', () async {
    final auth = createProvider();
    await auth.logIn(phone: '01700000001', password: samplePassword);

    var notified = false;
    auth.addListener(() => notified = true);
    auth.logOut();

    expect(auth.isLoggedIn, isFalse);
    expect(auth.currentUser, isNull);
    expect(notified, isTrue);
  });

  test('signUp creates an account and logs straight into it', () async {
    final auth = createProvider();

    final success = await auth.signUp(
      name: 'Test Seeker',
      phone: '01800000009',
      password: 'secret123',
    );

    expect(success, isTrue);
    expect(auth.currentUser!.name, 'Test Seeker');
    expect(auth.currentUser!.isDonor, isFalse);
  });

  test('a new account can log in again after logging out', () async {
    final auth = createProvider();
    await auth.signUp(
      name: 'Test Seeker',
      phone: '01800000009',
      password: 'secret123',
    );
    auth.logOut();

    final success = await auth.logIn(
      phone: '01800000009',
      password: 'secret123',
    );

    expect(success, isTrue);
    expect(auth.currentUser!.name, 'Test Seeker');
  });

  test('signUp rejects a number that already has an account', () async {
    final auth = createProvider();

    final success = await auth.signUp(
      name: 'Someone Else',
      phone: '01700000001', // Sample Seeker's number
      password: 'secret123',
    );

    expect(success, isFalse);
    expect(auth.isLoggedIn, isFalse);
    expect(auth.errorMessage, contains('already exists'));
  });

  test(
    'registerDonor turns a seeker into a donor, even after re-login',
    () async {
      final auth = createProvider();
      await auth.logIn(phone: '01700000001', password: samplePassword);

      final success = await auth.registerDonor(profileFor('user-1'));
      expect(success, isTrue);
      expect(auth.currentUser!.isDonor, isTrue);

      // The store remembers the profile, so logging in again keeps it.
      auth.logOut();
      await auth.logIn(phone: '01700000001', password: samplePassword);
      expect(auth.currentUser!.isDonor, isTrue);
    },
  );

  test('registerDonor refuses a user who is already a donor', () async {
    final auth = createProvider();
    await auth.logIn(phone: '01700000002', password: samplePassword);

    final success = await auth.registerDonor(profileFor('user-2'));

    expect(success, isFalse);
    expect(auth.errorMessage, 'You are already registered as a donor.');
  });
}
