import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/providers/my_requests_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 28);

  /// My Requests for Sample Requester (user-3), whose one sample request
  /// is needed tomorrow (29 Nov). [now] sets the provider's clock.
  Future<MyRequestsProvider> loadFor({DateTime? now}) async {
    final store = MockStore(today: today, now: now);
    final provider = MyRequestsProvider(
      MockRequestRepository(store, delay: Duration.zero),
      userId: 'user-3',
      clock: () => now ?? today,
    );
    await provider.load();
    return provider;
  }

  test('loads the user\'s requests', () async {
    final provider = await loadFor();

    expect(provider.requests, hasLength(1));
    expect(provider.statusOf(provider.requests.first), RequestStatus.open);
    expect(provider.canClose(provider.requests.first), isTrue);
  });

  test('a seeker with no requests gets an empty list', () async {
    final store = MockStore(today: today);
    final provider = MyRequestsProvider(
      MockRequestRepository(store, delay: Duration.zero),
      userId: 'user-1',
      clock: () => today,
    );
    await provider.load();

    expect(provider.requests, isEmpty);
    expect(provider.errorMessage, isNull);
  });

  test('Mark Fulfilled closes the request', () async {
    final provider = await loadFor();

    final error = await provider.markFulfilled('request-1');

    expect(error, isNull);
    final request = provider.requests.first;
    expect(provider.statusOf(request), RequestStatus.fulfilled);
    expect(provider.canClose(request), isFalse);
    expect(provider.closingId, isNull);
  });

  test('Cancel closes the request', () async {
    final provider = await loadFor();

    await provider.cancel('request-1');

    expect(provider.statusOf(provider.requests.first), RequestStatus.cancelled);
  });

  test('48 hours after the required day it shows as Expired', () async {
    // Needed 29 Nov, so it closes at 2 Dec 00:00.
    final provider = await loadFor(now: DateTime(2026, 12, 2));
    final request = provider.requests.first;

    expect(provider.statusOf(request), RequestStatus.expired);
    expect(provider.canClose(request), isFalse);
  });
}
