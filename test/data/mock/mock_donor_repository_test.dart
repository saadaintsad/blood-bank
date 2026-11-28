import 'package:bloodbank/data/mock/mock_donor_repository.dart';
import 'package:bloodbank/data/mock/mock_store.dart';
import 'package:bloodbank/models/donor_search_filters.dart';
import 'package:bloodbank/models/donor_search_result.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Sample Seeker has no request; Sample Requester has an open B+ one.
  const seekerId = 'user-1';
  const sampleDonorId = 'user-2';
  const requesterId = 'user-3';

  late MockDonorRepository repository;

  setUp(() {
    // A fixed "today" keeps the sample donors' Yellow days predictable.
    final store = MockStore(today: DateTime(2026, 11, 28));
    repository = MockDonorRepository(store, delay: Duration.zero);
  });

  Future<List<DonorSearchResult>> search(
    DonorSearchFilters filters, {
    String viewerId = seekerId,
  }) {
    return repository.searchDonors(filters, viewerId: viewerId);
  }

  List<String> names(List<DonorSearchResult> results) => [
    for (final r in results) r.name,
  ];

  group('searchDonors', () {
    test(
      'B+ in Dhaka lists exact, then compatible, Green before Yellow',
      () async {
        final results = await search(
          const DonorSearchFilters(bloodGroup: 'B+', district: 'Dhaka'),
        );

        expect(names(results), [
          // Exact B+: Green A–Z, then Yellow.
          'Karim', 'Mahin', 'Tanvir',
          // Compatible (B−, O+, O−): Green A–Z, then Yellow A–Z.
          'Mitu', 'Nusrat', 'Rakib', 'Sample Donor',
          'Joya', 'Nayeem', 'Riya',
        ]);
      },
    );

    test('labels compatible donors and counts Yellow days', () async {
      final results = await search(const DonorSearchFilters(bloodGroup: 'B+'));
      final tanvir = results.firstWhere((r) => r.name == 'Tanvir');
      final mitu = results.firstWhere((r) => r.name == 'Mitu');

      expect(tanvir.isExactMatch, isTrue);
      expect(tanvir.status, DonorStatus.recentlyDonated);
      // Walkthrough Scene 4: donated 40 days ago, men wait 84 days.
      expect(tanvir.statusLabel, 'Available in 44 days');
      expect(mitu.isExactMatch, isFalse);
    });

    test('hides Red donors', () async {
      // Shuvo (O+) and Tania (A+) are Red; AB+ can receive from both.
      final results = await search(const DonorSearchFilters(bloodGroup: 'AB+'));
      expect(names(results), isNot(contains('Shuvo')));
      expect(names(results), isNot(contains('Tania')));
      expect(
        results.every((r) => r.status != DonorStatus.notAvailable),
        isTrue,
      );
    });

    test('hides groups that cannot give to the patient', () async {
      final results = await search(const DonorSearchFilters(bloodGroup: 'B+'));
      expect(names(results), isNot(contains('Arif'))); // A+
      expect(names(results), isNot(contains('Imran'))); // AB−
    });

    test("hides the viewer's own donor profile", () async {
      final results = await search(
        const DonorSearchFilters(bloodGroup: 'O+'),
        viewerId: sampleDonorId,
      );
      expect(names(results), isNot(contains('Sample Donor')));
    });

    test('selected area comes first but hides nobody', () async {
      final all = await search(const DonorSearchFilters(bloodGroup: 'B+'));
      final withArea = await search(
        const DonorSearchFilters(bloodGroup: 'B+', area: 'Bashundhara'),
      );

      expect(withArea.length, all.length);
      expect(names(withArea).take(3), ['Mahin', 'Tanvir', 'Karim']);
    });

    test('filters by district', () async {
      final results = await search(
        const DonorSearchFilters(bloodGroup: 'B+', district: 'Sylhet'),
      );
      expect(results, isEmpty);
    });

    test('filters by part of the name, ignoring case', () async {
      final results = await search(
        const DonorSearchFilters(bloodGroup: 'B+', name: 'KAR'),
      );
      expect(names(results), ['Karim']);
    });

    test('"only available" keeps Green donors only', () async {
      final results = await search(
        const DonorSearchFilters(bloodGroup: 'B+', onlyAvailable: true),
      );
      expect(names(results), isNot(contains('Tanvir')));
      expect(results.every((r) => r.status == DonorStatus.available), isTrue);
    });
  });

  group('getDonorPhone', () {
    test('is hidden from a viewer without an open request', () async {
      final phone = await repository.getDonorPhone(
        'donor-1',
        viewerId: seekerId,
      );
      expect(phone, isNull);
    });

    test('is shown to a viewer with an open request', () async {
      final phone = await repository.getDonorPhone(
        'donor-1',
        viewerId: requesterId,
      );
      expect(phone, '01700000101');
    });

    test('stays hidden for a Red donor, even with a request', () async {
      final phone = await repository.getDonorPhone(
        'donor-13',
        viewerId: requesterId,
      );
      expect(phone, isNull);
    });
  });
}
