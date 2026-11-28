import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/data/repositories/request_repository.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/models/new_blood_request.dart';
import 'package:bloodbank/utils/request_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockStore store;
  late MockRequestRepository repository;

  // The sample "today". Sample Seeker (user-1) starts with no requests.
  final today = DateTime(2026, 11, 28);

  setUp(() {
    store = MockStore(today: today);
    repository = MockRequestRepository(store, delay: Duration.zero);
  });

  NewBloodRequest draft({String ownerId = 'user-1', DateTime? requiredDate}) {
    return NewBloodRequest(
      ownerId: ownerId,
      patientName: 'Test Patient',
      bloodGroup: 'A+',
      unitsNeeded: 2,
      hospital: 'Test Hospital',
      district: 'Sylhet',
      requiredDate: requiredDate ?? DateTime(2026, 11, 29),
      contactPhone: '01700000001',
    );
  }

  test(
    'a new request is Open straight away and unlocks phone numbers',
    () async {
      expect(store.hasOpenRequest('user-1'), isFalse);

      final request = await repository.createRequest(draft());

      expect(request.status, RequestStatus.open);
      expect(store.hasOpenRequest('user-1'), isTrue);
      expect(await repository.getOpenRequests('user-1'), hasLength(1));
    },
  );

  test('a required date in the past is refused', () async {
    await expectLater(
      repository.createRequest(draft(requiredDate: DateTime(2026, 11, 27))),
      throwsA(isA<RequestException>()),
    );
    expect(store.hasOpenRequest('user-1'), isFalse);
  });

  group('3 open requests limit', () {
    test('the 4th open request is refused', () async {
      for (var i = 0; i < maxOpenRequests; i++) {
        await repository.createRequest(draft());
      }

      await expectLater(
        repository.createRequest(draft()),
        throwsA(
          isA<RequestException>().having(
            (error) => error.message,
            'message',
            openRequestLimitMessage,
          ),
        ),
      );
    });

    test('a cancelled request frees a place', () async {
      final first = await repository.createRequest(draft());
      await repository.createRequest(draft());
      await repository.createRequest(draft());

      await repository.closeRequest(
        first.id,
        userId: 'user-1',
        status: RequestStatus.cancelled,
      );

      expect(await repository.createRequest(draft()), isNotNull);
    });

    test('expired requests do not count', () async {
      // Needed on 28 Nov, so they expire at 1 Dec 00:00.
      for (var i = 0; i < maxOpenRequests; i++) {
        await repository.createRequest(draft(requiredDate: today));
      }

      // The same requests, seen from a store whose clock says 1 Dec.
      final later = MockStore(today: today, now: DateTime(2026, 12, 1));
      later.requestsById.addAll(store.requestsById);
      final laterRepository = MockRequestRepository(
        later,
        delay: Duration.zero,
      );

      expect(await laterRepository.getOpenRequests('user-1'), isEmpty);
      expect(later.hasOpenRequest('user-1'), isFalse);
      final request = await laterRepository.createRequest(
        draft(requiredDate: DateTime(2026, 12, 2)),
      );
      expect(request.status, RequestStatus.open);
    });
  });

  group('closeRequest', () {
    test('the owner can mark a request Fulfilled', () async {
      final request = await repository.createRequest(draft());

      final closed = await repository.closeRequest(
        request.id,
        userId: 'user-1',
        status: RequestStatus.fulfilled,
      );

      expect(closed.status, RequestStatus.fulfilled);
      expect(store.hasOpenRequest('user-1'), isFalse);
    });

    test('someone else cannot close it', () async {
      final request = await repository.createRequest(draft());

      await expectLater(
        repository.closeRequest(
          request.id,
          userId: 'user-2',
          status: RequestStatus.cancelled,
        ),
        throwsA(isA<RequestException>()),
      );
    });

    test('a closed request cannot be closed again', () async {
      final request = await repository.createRequest(draft());
      await repository.closeRequest(
        request.id,
        userId: 'user-1',
        status: RequestStatus.cancelled,
      );

      await expectLater(
        repository.closeRequest(
          request.id,
          userId: 'user-1',
          status: RequestStatus.fulfilled,
        ),
        throwsA(isA<RequestException>()),
      );
    });
  });

  test('lists put the newest posted request first', () async {
    // Sample Requester (user-3) has one request posted at 00:00. A store
    // clock of 10:00 makes the new one clearly newer.
    final store = MockStore(today: today, now: DateTime(2026, 11, 28, 10));
    final repository = MockRequestRepository(store, delay: Duration.zero);
    final newer = await repository.createRequest(draft(ownerId: 'user-3'));
    await repository.closeRequest(
      'request-1',
      userId: 'user-3',
      status: RequestStatus.cancelled,
    );

    final mine = await repository.getMyRequests('user-3');
    expect(mine.map((request) => request.id), [newer.id, 'request-1']);
    expect(mine.last.status, RequestStatus.cancelled);
  });

  group('Emergency Alert', () {
    test('the owner can send one, then not again for 15 days', () async {
      // Sample Requester (user-3) owns the open request-1.
      expect(await repository.getLastEmergencyAlert('user-3'), isNull);

      final sentAt = await repository.sendEmergencyAlert(
        'request-1',
        userId: 'user-3',
      );
      expect(await repository.getLastEmergencyAlert('user-3'), sentAt);

      // Three days later (request-1 is still open): refused by the
      // "server" too, not only by the disabled button.
      store.now = DateTime(2026, 12, 1);
      await expectLater(
        repository.sendEmergencyAlert('request-1', userId: 'user-3'),
        throwsA(
          isA<RequestException>().having(
            (error) => error.message,
            'message',
            contains('12 days'),
          ),
        ),
      );
    });

    test('allowed again 15 days later', () async {
      await repository.sendEmergencyAlert('request-1', userId: 'user-3');
      // A new open request, because request-1 has expired by then.
      store.now = DateTime(2026, 12, 13);
      final request = await repository.createRequest(
        draft(ownerId: 'user-3', requiredDate: DateTime(2026, 12, 14)),
      );

      await repository.sendEmergencyAlert(request.id, userId: 'user-3');
      expect(
        await repository.getLastEmergencyAlert('user-3'),
        DateTime(2026, 12, 13),
      );
    });

    test('only the owner, and only while the request is open', () async {
      await expectLater(
        repository.sendEmergencyAlert('request-1', userId: 'user-1'),
        throwsA(isA<RequestException>()),
      );
      await repository.closeRequest(
        'request-1',
        userId: 'user-3',
        status: RequestStatus.fulfilled,
      );
      await expectLater(
        repository.sendEmergencyAlert('request-1', userId: 'user-3'),
        throwsA(isA<RequestException>()),
      );
    });
  });

  group('requests for donors', () {
    test("district list has open requests, not the viewer's own", () async {
      final dhaka = await repository.getDistrictOpenRequests(
        'Dhaka',
        viewerId: 'user-2',
      );
      expect(dhaka.map((r) => r.id), ['request-1', 'request-2']);

      // Sample Requester doesn't see their own request-1.
      final forOwner = await repository.getDistrictOpenRequests(
        'Dhaka',
        viewerId: 'user-3',
      );
      expect(forOwner.map((r) => r.id), ['request-2']);
    });

    test('closed requests are left out', () async {
      await repository.closeRequest(
        'request-1',
        userId: 'user-3',
        status: RequestStatus.cancelled,
      );
      final dhaka = await repository.getDistrictOpenRequests(
        'Dhaka',
        viewerId: 'user-2',
      );
      expect(dhaka.map((r) => r.id), ['request-2']);
    });

    test("the seeker's phone is shown to donors only", () async {
      expect(
        await repository.getSeekerPhone('request-1', viewerId: 'user-2'),
        '01700000003',
      );
      expect(
        await repository.getSeekerPhone('request-1', viewerId: 'user-1'),
        isNull,
      );
    });

    test('getRequest finds a request by id', () async {
      expect((await repository.getRequest('request-1'))?.bloodGroup, 'B+');
      expect(await repository.getRequest('request-999'), isNull);
    });
  });
}
