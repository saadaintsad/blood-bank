import 'package:bloodbank/data/mock/mock_auth_repository.dart';
import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/data/mock/sample_users.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/providers/auth_provider.dart';
import 'package:bloodbank/providers/donor_registration_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Every test pretends today is 27 Nov 2026, so ages and gaps never
  // change when the tests run on a different day.
  final today = DateTime(2026, 11, 27);

  DonorRegistrationProvider newUserForm() =>
      DonorRegistrationProvider(clock: () => today);

  AuthProvider createAuth() {
    final store = MockStore();
    return AuthProvider(
      MockAuthRepository(store, delay: Duration.zero),
      MockDonorRepository(store, delay: Duration.zero),
    );
  }

  /// Fills every step with valid answers and moves to the consent step.
  void fillAllSteps(DonorRegistrationProvider form) {
    if (form.isNewAccount) {
      form.name = 'Test Donor';
      form.phone = '+880 1800-000009'; // typed with country code
      form.password = 'secret123';
      form.next();
    }
    form.setBloodGroup('O+');
    form.setGender(Gender.female);
    form.setDateOfBirth(DateTime(2002, 1, 10));
    form.next();
    form.setDistrict('Dhaka');
    form.setArea('Badda');
    form.next();
    form.setNeverDonated(true);
    form.next();
  }

  test('new users get 5 steps, starting with their account', () {
    final form = newUserForm();

    expect(form.stepCount, 5);
    expect(form.currentStep, RegistrationStep.account);
  });

  test('logged-in seekers skip the account step', () {
    final form = DonorRegistrationProvider(
      existingUser: sampleUsers.first,
      clock: () => today,
    );

    expect(form.stepCount, 4);
    expect(form.currentStep, RegistrationStep.aboutYou);
  });

  test('Next stays on a step with missing answers and shows errors', () {
    final form = newUserForm();

    expect(form.next(), isFalse);
    expect(form.currentStep, RegistrationStep.account);
    expect(form.showErrors, isTrue);
  });

  test('an invalid phone number blocks the account step', () {
    final form = newUserForm()
      ..name = 'Test'
      ..phone = '12345'
      ..password = 'secret123';

    expect(form.next(), isFalse);
  });

  test('Back returns to the previous step and keeps the answers', () {
    final form = newUserForm();
    fillAllSteps(form);
    expect(form.currentStep, RegistrationStep.consent);

    form.back();
    form.back();
    expect(form.currentStep, RegistrationStep.location);
    expect(form.area, 'Badda');
  });

  test('changing the district clears the area', () {
    final form = newUserForm();
    form.setDistrict('Dhaka');
    form.setArea('Badda');

    form.setDistrict('Khulna');

    expect(form.area, isEmpty);
  });

  test('a 17-year-old is blocked on the About you step', () {
    final form = DonorRegistrationProvider(
      existingUser: sampleUsers.first,
      clock: () => today,
    );
    form.setBloodGroup('B+');
    form.setGender(Gender.male);
    form.setDateOfBirth(DateTime(2008, 11, 28)); // turns 18 tomorrow

    expect(form.next(), isFalse);
    expect(form.age, 17);
    expect(form.isAgeBlocked, isTrue);

    form.dismissAgeBlock();
    form.setDateOfBirth(DateTime(2008, 11, 27)); // 18 today
    expect(form.next(), isTrue);
  });

  test('the starting status preview follows the last donation date', () {
    final form = newUserForm();
    form.setGender(Gender.male);

    form.setLastDonationDate(DateTime(2026, 10, 18)); // 40 days ago
    expect(form.startingStatus, DonorStatus.recentlyDonated);
    expect(form.startingStatusLabel, 'Available in 44 days');

    form.setNeverDonated(true);
    expect(form.lastDonationDate, isNull);
    expect(form.startingStatus, DonorStatus.available);
  });

  test('the donation step needs a date or "never donated"', () {
    final form = newUserForm();
    fillAllSteps(form);
    form.back(); // to the donation step
    form.setNeverDonated(false);

    expect(form.next(), isFalse);
  });

  test('Finish is not allowed until consent is given', () {
    final form = newUserForm();
    fillAllSteps(form);

    expect(form.isCurrentStepValid, isFalse);
    form.setConsentGiven(true);
    expect(form.isCurrentStepValid, isTrue);
  });

  test('alerts are on by default', () {
    expect(newUserForm().receiveAlerts, isTrue);
  });

  test('submit creates the account and donor profile, which can log in',
      () async {
    final auth = createAuth();
    final form = newUserForm();
    fillAllSteps(form);
    form.setConsentGiven(true);

    final success = await form.submit(auth);
    expect(success, isTrue);
    expect(auth.currentUser!.phone, '01800000009'); // normalized
    expect(auth.currentUser!.isDonor, isTrue);

    auth.logOut();
    await auth.logIn(phone: '01800000009', password: 'secret123');
    expect(auth.currentUser!.isDonor, isTrue);
  });

  test('submit with a used number goes back to the account step', () async {
    final auth = createAuth();
    final form = newUserForm();
    fillAllSteps(form);
    form.phone = '01700000001'; // Sample Seeker already has it
    form.setConsentGiven(true);

    final success = await form.submit(auth);

    expect(success, isFalse);
    expect(form.currentStep, RegistrationStep.account);
    expect(auth.errorMessage, contains('already exists'));
  });

  test('signUpAsSeeker makes a seeker account from the account step',
      () async {
    final auth = createAuth();
    final form = newUserForm()
      ..name = 'Young Seeker'
      ..phone = '01800000010'
      ..password = 'secret123';

    final success = await form.signUpAsSeeker(auth);

    expect(success, isTrue);
    expect(auth.currentUser!.name, 'Young Seeker');
    expect(auth.currentUser!.isDonor, isFalse);
  });
}
