import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/providers/open_requests_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 28);

  Future<OpenRequestsProvider> loadFor(String viewerId) async {
    final store = MockStore(today: today);
    final provider = OpenRequestsProvider(
      MockRequestRepository(store, delay: Duration.zero),
      MockDonorRepository(store, delay: Duration.zero),
      viewerId: viewerId,
    );
    await provider.load();
    return provider;
  }

  test('Sample Donor (O+) sees the B+ request before the A− one', () async {
    final provider = await loadFor('user-2');

    expect(provider.district, 'Dhaka');
    expect(provider.requests.map((r) => r.id), ['request-1', 'request-2']);
    expect(provider.isCompatible(provider.requests[0]), isTrue);
    expect(provider.isCompatible(provider.requests[1]), isFalse);
  });

  test('an O− donor can give to both, so the sooner one is first', () async {
    // Sample donor donor-7 is O−, the universal donor group.
    final provider = await loadFor('donor-7');

    expect(provider.requests.map((r) => r.id), ['request-1', 'request-2']);
    expect(provider.requests.every(provider.isCompatible), isTrue);
  });

  test("a donor's own request is left out", () async {
    // Farhana (donor-6) posted request-2.
    final provider = await loadFor('donor-6');

    expect(provider.requests.map((r) => r.id), ['request-1']);
  });

  test('non-donors get a message instead of a list', () async {
    final provider = await loadFor('user-1');

    expect(provider.requests, isEmpty);
    expect(provider.errorMessage, contains('for donors'));
  });
}
