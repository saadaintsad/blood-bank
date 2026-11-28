import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_request_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/models/donor_search_filters.dart';
import 'package:bloodbank/models/donor_search_result.dart';
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

  test('an open request fills the filters, searches and shows phones',
      () async {
    final search = createProvider('user-3'); // Sample Requester
    await search.load();

    expect(search.canSeeContacts, isTrue);
    expect(search.bloodGroup, 'B+');
    expect(search.district, 'Dhaka');
    expect(search.hasSearched, isTrue);
    expect(search.results.first.name, 'Karim');
    expect(search.phoneFor('donor-1'), '01700000101');
  });

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
