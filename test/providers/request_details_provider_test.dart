import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_interest_repository.dart';
import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/models/new_blood_request.dart';
import 'package:bloodbank/models/user.dart';
import 'package:bloodbank/providers/request_details_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 28);
  final morning = DateTime(2026, 11, 28, 10);

  const seeker = AppUser(
    id: 'user-1',
    name: 'Sample Seeker',
    phone: '01700000001',
  );
  const donor = AppUser(
    id: 'user-2',
    name: 'Sample Donor',
    phone: '01700000002',
    isDonor: true,
  );
  const requester = AppUser(
    id: 'user-3',
    name: 'Sample Requester',
    phone: '01700000003',
  );

  late MockStore store;

  setUp(() => store = MockStore(today: today, now: morning));

  Future<RequestDetailsProvider> loadFor(
    AppUser viewer, {
    String requestId = 'request-1',
  }) async {
    final provider = RequestDetailsProvider(
      MockRequestRepository(store, delay: Duration.zero),
      MockInterestRepository(store, delay: Duration.zero),
      MockDonorRepository(store, delay: Duration.zero),
      requestId: requestId,
      viewer: viewer,
      clock: () => store.now,
    );
    await provider.load();
    return provider;
  }

  group('seeker view', () {
    test('the owner sees the interested donors', () async {
      final provider = await loadFor(requester);

      expect(provider.role, RequestViewerRole.owner);
      expect(provider.interestedDonors.map((d) => d.name), ['Nusrat', 'Mitu']);
      expect(provider.emergencyDaysLeft, 0);
    });

    test('after an Emergency Alert the button waits 15 days', () async {
      final provider = await loadFor(requester);

      expect(await provider.sendEmergencyAlert(), isNull);
      expect(provider.emergencyDaysLeft, 15);
      // A second try is refused with a message.
      expect(await provider.sendEmergencyAlert(), isNotNull);
    });

    test('Mark Fulfilled closes the request', () async {
      final provider = await loadFor(requester);

      expect(await provider.markFulfilled(), isNull);
      expect(provider.status, RequestStatus.fulfilled);
      expect(provider.isOpen, isFalse);
    });
  });

  group('donor view', () {
    test("a donor sees the seeker's phone and can respond", () async {
      final provider = await loadFor(donor);

      expect(provider.role, RequestViewerRole.donor);
      expect(provider.seekerPhone, '01700000003');
      expect(provider.canExpressInterest, isTrue);
    });

    test('after responding, the confirmation replaces the button', () async {
      final provider = await loadFor(donor);

      expect(await provider.expressInterest(), isNull);
      expect(provider.myResponse, isNotNull);
      expect(provider.canExpressInterest, isFalse);
      expect(provider.interestBlockReason, isNull);
    });

    test('another request is blocked during the 3 hours', () async {
      // A second B+ request in Dhaka, which O+ could give to.
      final other = await MockRequestRepository(store, delay: Duration.zero)
          .createRequest(
            NewBloodRequest(
              ownerId: seeker.id,
              patientName: 'Test Patient',
              bloodGroup: 'B+',
              unitsNeeded: 1,
              hospital: 'Test Hospital',
              district: 'Dhaka',
              requiredDate: DateTime(2026, 11, 30),
              contactPhone: seeker.phone,
            ),
          );
      final first = await loadFor(donor);
      await first.expressInterest();

      final second = await loadFor(donor, requestId: other.id);
      expect(second.canExpressInterest, isFalse);
      expect(second.interestBlockReason, contains('another request'));
    });

    test('an incompatible request explains why', () async {
      final provider = await loadFor(donor, requestId: 'request-2');
      expect(
        provider.interestBlockReason,
        "Your blood group (O+) can't be given to this patient (A−).",
      );
    });
  });

  test('a non-donor sees only the request, without the phone', () async {
    final provider = await loadFor(seeker);

    expect(provider.role, RequestViewerRole.other);
    expect(provider.seekerPhone, isNull);
    expect(provider.interestedDonors, isEmpty);
  });

  test('an unknown request shows an error', () async {
    final provider = await loadFor(seeker, requestId: 'request-999');

    expect(provider.request, isNull);
    expect(provider.errorMessage, isNotNull);
  });
}
