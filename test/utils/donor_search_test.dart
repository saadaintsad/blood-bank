import 'package:bloodbank/models/donor_search_result.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/utils/donor_search.dart';
import 'package:flutter_test/flutter_test.dart';

/// A result with sensible defaults, so each test only sets what matters.
DonorSearchResult result(
  String name, {
  bool exact = true,
  String area = 'Mirpur',
  DonorStatus status = DonorStatus.available,
}) {
  return DonorSearchResult(
    donorId: name,
    name: name,
    bloodGroup: exact ? 'B+' : 'O-',
    district: 'Dhaka',
    area: area,
    gender: Gender.male,
    status: status,
    daysUntilAvailable: status == DonorStatus.available ? 0 : 10,
    isExactMatch: exact,
  );
}

List<String> names(List<DonorSearchResult> results) =>
    [for (final r in results) r.name];

void main() {
  const yellow = DonorStatus.recentlyDonated;

  test('exact blood group comes before compatible', () {
    final sorted = sortSearchResults([
      result('Compatible', exact: false),
      result('Exact'),
    ]);
    expect(names(sorted), ['Exact', 'Compatible']);
  });

  test('exact match wins even over same area and Green', () {
    final sorted = sortSearchResults(
      [
        result('Compatible here', exact: false, area: 'Badda'),
        result('Exact elsewhere', area: 'Uttara', status: yellow),
      ],
      preferredArea: 'Badda',
    );
    expect(names(sorted), ['Exact elsewhere', 'Compatible here']);
  });

  test('same area comes before the rest of the district', () {
    final sorted = sortSearchResults(
      [result('Away', area: 'Uttara'), result('Near', area: 'Badda')],
      preferredArea: 'Badda',
    );
    expect(names(sorted), ['Near', 'Away']);
  });

  test('same area wins over Green', () {
    final sorted = sortSearchResults(
      [
        result('Green away', area: 'Uttara'),
        result('Yellow near', area: 'Badda', status: yellow),
      ],
      preferredArea: 'Badda',
    );
    expect(names(sorted), ['Yellow near', 'Green away']);
  });

  test('Green comes before Yellow', () {
    final sorted = sortSearchResults([
      result('Yellow', status: yellow),
      result('Green'),
    ]);
    expect(names(sorted), ['Green', 'Yellow']);
  });

  test('area is ignored when none is chosen', () {
    final sorted = sortSearchResults([
      result('Badda yellow', area: 'Badda', status: yellow),
      result('Uttara green', area: 'Uttara'),
    ]);
    expect(names(sorted), ['Uttara green', 'Badda yellow']);
  });

  test('ties are broken by name, ignoring case', () {
    final sorted = sortSearchResults([
      result('karim'),
      result('Arif'),
      result('Mitu'),
    ]);
    expect(names(sorted), ['Arif', 'karim', 'Mitu']);
  });

  test('walkthrough Scene 4 order', () {
    final sorted = sortSearchResults([
      result('Nusrat', exact: false, area: 'Badda'),
      result('Tanvir', area: 'Bashundhara', status: yellow),
      result('Mitu', exact: false, area: 'Rampura'),
      result('Karim', area: 'Uttara'),
    ]);
    expect(names(sorted), ['Karim', 'Tanvir', 'Mitu', 'Nusrat']);
  });

  test('does not change the original list', () {
    final original = [result('B'), result('A')];
    sortSearchResults(original);
    expect(names(original), ['B', 'A']);
  });
}
