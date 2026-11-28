import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/models/donor_search_filters.dart';
import 'package:bloodbank/models/donor_search_result.dart';
import 'package:bloodbank/models/new_blood_request.dart';
import 'package:bloodbank/providers/donor_search_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// A donor repository whose search always fails, to test the error state.
/// `extends` reuses the mock and overrides just one method.
class _FailingDonorRepository extends MockDonorRepository {
  _FailingDonorRepository(super.store) : super(delay: Duration.zero);

  @override
  Future<List<DonorSearchResult>> searchDonors(
    DonorSearchFilters filters, {
    required String viewerId,
  }) {
    throw Exception('No connection');
  }
}

void main() {
  DonorSearchProvider createProvider(String viewerId, {bool failing = false}) {
    final store = MockStore(today: DateTime(2026, 11, 28));
    return DonorSearchProvider(
      failing
          ? _FailingDonorRepository(store)
          : MockDonorRepository(store, delay: Duration.zero),
      MockRequestRepository(store, delay: Duration.zero),
      viewerId: viewerId,
    );
  }

  test('does not search without a blood group', () async {
    final search = createProvider('user-1');

    await search.search();

    expect(search.hasSearched, isFalse);
    expect(search.bloodGroupError, 'Choose a blood group');
  });

  test('without an open request: no filters filled, no phones', () async {
    final search = createProvider('user-1');
    await search.load();

    expect(search.canSeeContacts, isFalse);
    expect(search.bloodGroup, isNull);
    expect(search.hasSearched, isFalse);

    search.setBloodGroup('B+');
    await search.search();

    expect(search.results, isNotEmpty);
    expect(search.phoneFor(search.results.first.donorId), isNull);
  });

  test(
    'an open request fills the filters, searches and shows phones',
    () async {
      final search = createProvider('user-3'); // Sample Requester
      await search.load();

      expect(search.canSeeContacts, isTrue);
      expect(search.bloodGroup, 'B+');
      expect(search.district, 'Dhaka');
      expect(search.hasSearched, isTrue);
      expect(search.results.first.name, 'Karim');
      expect(search.phoneFor('donor-1'), '01700000101');
    },
  );

  test(
    'with several open requests, the newest posted one fills the filters',
    () async {
      // 10:00, so the new request is newer than the sample one (00:00).
      final store = MockStore(
        today: DateTime(2026, 11, 28),
        now: DateTime(2026, 11, 28, 10),
      );
      final requests = MockRequestRepository(store, delay: Duration.zero);
      await requests.createRequest(
        NewBloodRequest(
          ownerId: 'user-3',
          patientName: 'Second Patient',
          bloodGroup: 'O+',
          unitsNeeded: 1,
          hospital: 'Test Hospital',
          district: 'Sylhet',
          requiredDate: DateTime(2026, 11, 30),
          contactPhone: '01700000003',
        ),
      );
      final search = DonorSearchProvider(
        MockDonorRepository(store, delay: Duration.zero),
        requests,
        viewerId: 'user-3',
      );

      await search.load();

      expect(search.bloodGroup, 'O+');
      expect(search.district, 'Sylhet');
    },
  );

  test('changing the district clears the area', () {
    final search = createProvider('user-1');
    search.setDistrict('Dhaka');
    search.setArea('Badda');

    search.setDistrict('Sylhet');

    expect(search.area, isEmpty);
  });

  test('a failed search shows an error and no results', () async {
    final search = createProvider('user-1', failing: true);
    search.setBloodGroup('B+');

    await search.search();

    expect(search.errorMessage, isNotNull);
    expect(search.results, isEmpty);
    expect(search.isLoading, isFalse);
  });
}
