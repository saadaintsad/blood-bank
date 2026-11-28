import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_interest_repository.dart';
import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/data/repositories/interest_repository.dart';
import 'package:bloodbank/models/donor_search_filters.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/models/new_blood_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockStore store;
  late MockInterestRepository interests;
  late MockRequestRepository requests;
  late MockDonorRepository donors;

  // Sample data: request-1 is B+ in Dhaka (owner user-3), required 29 Nov.
  // Sample Donor (user-2) is O+ and Green, so they can respond to it.
  final today = DateTime(2026, 11, 28);
  final morning = DateTime(2026, 11, 28, 10);

  setUp(() {
    store = MockStore(today: today, now: morning);
    interests = MockInterestRepository(store, delay: Duration.zero);
    requests = MockRequestRepository(store, delay: Duration.zero);
    donors = MockDonorRepository(store, delay: Duration.zero);
  });

  /// True when [donorId] shows up in a B+ search in Dhaka.
  Future<bool> appearsInSearch(String donorId) async {
    final results = await donors.searchDonors(
      const DonorSearchFilters(bloodGroup: 'B+', district: 'Dhaka'),
      viewerId: 'user-1',
    );
    return results.any((donor) => donor.donorId == donorId);
  }

  /// A second open B+ request in Dhaka, owned by Sample Seeker.
  Future<String> secondRequest() async {
    final request = await requests.createRequest(
      NewBloodRequest(
        ownerId: 'user-1',
        patientName: 'Test Patient',
        bloodGroup: 'B+',
        unitsNeeded: 1,
        hospital: 'Test Hospital',
        district: 'Dhaka',
        requiredDate: DateTime(2026, 11, 30),
        contactPhone: '01700000001',
      ),
    );
    return request.id;
  }

  group('3-hour hiding from search', () {
    test('a donor disappears from search right after tapping', () async {
      expect(await appearsInSearch('user-2'), isTrue);

      await interests.expressInterest('request-1', donorId: 'user-2');

      expect(await appearsInSearch('user-2'), isFalse);
    });

    test('they are back in search once the 3 hours are over', () async {
      await interests.expressInterest('request-1', donorId: 'user-2');

      store.now = DateTime(2026, 11, 28, 12, 59);
      expect(await appearsInSearch('user-2'), isFalse);
      store.now = DateTime(2026, 11, 28, 13, 0);
      expect(await appearsInSearch('user-2'), isTrue);
    });

    test('the sample responses are past their window', () async {
      // Nusrat (donor-3) responded 5 hours ago, so she is visible.
      expect(await appearsInSearch('donor-3'), isTrue);
    });
  });

  group('one interest at a time', () {
    test('a second request inside the 3 hours is refused', () async {
      final otherId = await secondRequest();
      await interests.expressInterest('request-1', donorId: 'user-2');

      store.now = DateTime(2026, 11, 28, 11);
      await expectLater(
        interests.expressInterest(otherId, donorId: 'user-2'),
        throwsA(isA<InterestException>()),
      );
    });

    test('after 3 hours they can respond to another request', () async {
      final otherId = await secondRequest();
      await interests.expressInterest('request-1', donorId: 'user-2');

      store.now = DateTime(2026, 11, 28, 13);
      final response = await interests.expressInterest(
        otherId,
        donorId: 'user-2',
      );
      expect(response.requestId, otherId);
    });

    test('the same request cannot be answered twice', () async {
      await interests.expressInterest('request-1', donorId: 'user-2');
      store.now = DateTime(2026, 11, 28, 15);
      await expectLater(
        interests.expressInterest('request-1', donorId: 'user-2'),
        throwsA(isA<InterestException>()),
      );
    });
  });

  group('who may respond', () {
    test('Yellow donors are refused', () async {
      // Tanvir (donor-2) is B+ but donated 40 days ago.
      await expectLater(
        interests.expressInterest('request-1', donorId: 'donor-2'),
        throwsA(isA<InterestException>()),
      );
    });

    test('incompatible blood groups are refused', () async {
      // Arif (donor-5) is A+, which can't give to a B+ patient.
      await expectLater(
        interests.expressInterest('request-1', donorId: 'donor-5'),
        throwsA(isA<InterestException>()),
      );
    });

    test('non-donors and the owner are refused', () async {
      await expectLater(
        interests.expressInterest('request-1', donorId: 'user-1'),
        throwsA(isA<InterestException>()),
      );
      await expectLater(
        interests.expressInterest('request-1', donorId: 'user-3'),
        throwsA(isA<InterestException>()),
      );
    });
  });

  test('"Did you donate?" is set for 8 PM on the required date', () async {
    final response = await interests.expressInterest(
      'request-1',
      donorId: 'user-2',
    );
    expect(response.askDonatedAt, DateTime(2026, 11, 29, 20));
  });

  group('interested donors list', () {
    test('the owner sees every responder with their number', () async {
      await interests.expressInterest('request-1', donorId: 'user-2');
      final list = await interests.getInterestedDonors(
        'request-1',
        viewerId: 'user-3',
      );
      expect(list.map((d) => d.name), ['Nusrat', 'Mitu', 'Sample Donor']);
      expect(list.last.phone, '01700000002');
    });

    test('nobody else sees it', () async {
      final list = await interests.getInterestedDonors(
        'request-1',
        viewerId: 'user-2',
      );
      expect(list, isEmpty);
    });
  });

  group('when the seeker closes the request', () {
    test('Cancelled ends the 3-hour window straight away', () async {
      await interests.expressInterest('request-1', donorId: 'user-2');
      store.now = DateTime(2026, 11, 28, 11);

      await requests.closeRequest(
        'request-1',
        userId: 'user-3',
        status: RequestStatus.cancelled,
      );

      expect(await appearsInSearch('user-2'), isTrue);
      expect(await interests.getActiveResponse('user-2'), isNull);
    });

    test('Fulfilled makes "Did you donate?" due now', () async {
      await interests.expressInterest('request-1', donorId: 'user-2');
      final closedAt = DateTime(2026, 11, 28, 11);
      store.now = closedAt;

      await requests.closeRequest(
        'request-1',
        userId: 'user-3',
        status: RequestStatus.fulfilled,
      );

      final response = await interests.getResponse(
        'request-1',
        donorId: 'user-2',
      );
      expect(response!.askDonatedAt, closedAt);
      // Still hidden: only Cancelled ends the window early.
      expect(await appearsInSearch('user-2'), isFalse);
    });
  });
}
