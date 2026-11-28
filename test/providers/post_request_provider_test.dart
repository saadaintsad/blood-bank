import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/models/user.dart';
import 'package:bloodbank/providers/post_request_provider.dart';
import 'package:bloodbank/utils/request_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 28);
  const seeker = AppUser(
    id: 'user-1',
    name: 'Sample Seeker',
    phone: '01700000001',
  );

  late MockStore store;
  late MockRequestRepository repository;

  setUp(() {
    store = MockStore(today: today);
    repository = MockRequestRepository(store, delay: Duration.zero);
  });

  PostRequestProvider createProvider() {
    return PostRequestProvider(repository, owner: seeker, clock: () => today);
  }

  /// Fills every required answer with valid values.
  void fillIn(PostRequestProvider post) {
    post.patientName = '  Test Patient ';
    post.hospital = 'Test Hospital';
    post.setBloodGroup('O-');
    post.setDistrict('Dhaka');
    post.setRequiredDate(DateTime(2026, 11, 29));
  }

  test('starts with the user\'s own number and 1 unit', () {
    final post = createProvider();
    expect(post.contactPhone, '01700000001');
    expect(post.units, 1);
  });

  test('units stay between the limits', () {
    final post = createProvider();
    post.changeUnits(-1);
    expect(post.units, minUnits);
    for (var i = 0; i < 20; i++) {
      post.changeUnits(1);
    }
    expect(post.units, maxUnits);
  });

  test('missing pickers stop the submit and show errors', () async {
    final post = createProvider();

    final request = await post.submit(textFieldsValid: true);

    expect(request, isNull);
    expect(post.showErrors, isTrue);
    expect(post.bloodGroupError, isNotNull);
    expect(post.districtError, isNotNull);
    expect(post.requiredDateErrorText, isNotNull);
    expect(store.hasOpenRequest('user-1'), isFalse);
  });

  test('a past required date is an error', () {
    final post = createProvider();
    post.setRequiredDate(DateTime(2026, 11, 27));
    expect(
      post.requiredDateErrorText,
      "The required date can't be in the past",
    );
  });

  test('a valid form posts an Open request with a normalized number', () async {
    final post = createProvider();
    fillIn(post);
    post.contactPhone = '+880 1711-222333';
    post.notes = '   ';

    final request = await post.submit(textFieldsValid: true);

    expect(request, isNotNull);
    expect(request!.status, RequestStatus.open);
    expect(request.patientName, 'Test Patient');
    expect(request.contactPhone, '01711222333');
    expect(request.notes, isNull);
    expect(store.hasOpenRequest('user-1'), isTrue);
  });

  test('load() spots the 3-request limit before the form is filled', () async {
    for (var i = 0; i < maxOpenRequests; i++) {
      final post = createProvider();
      fillIn(post);
      await post.submit(textFieldsValid: true);
    }

    final post = createProvider();
    await post.load();

    expect(post.limitReached, isTrue);
  });

  test('a refused submit shows the limit message', () async {
    final first = createProvider();
    await first.load(); // Opened while there was still room.
    for (var i = 0; i < maxOpenRequests; i++) {
      final other = createProvider();
      fillIn(other);
      await other.submit(textFieldsValid: true);
    }

    fillIn(first);
    final request = await first.submit(textFieldsValid: true);

    expect(request, isNull);
    expect(first.errorMessage, openRequestLimitMessage);
    expect(first.limitReached, isTrue);
  });
}
