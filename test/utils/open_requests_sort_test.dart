import 'package:bloodbank/models/blood_request.dart';
import 'package:bloodbank/utils/open_requests_sort.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BloodRequest request(String id, String group, int day, {int postedDay = 1}) {
    return BloodRequest(
      id: id,
      ownerId: 'user-1',
      patientName: 'Test Patient',
      bloodGroup: group,
      unitsNeeded: 1,
      hospital: 'Test Hospital',
      district: 'Dhaka',
      requiredDate: DateTime(2026, 12, day),
      contactPhone: '01700000001',
      createdAt: DateTime(2026, 11, postedDay),
    );
  }

  test('compatible requests come first, then soonest date', () {
    final sorted = sortOpenRequests([
      request('a-minus-soon', 'A-', 1), // O+ can't give to A−
      request('b-plus-later', 'B+', 5),
      request('ab-plus-soon', 'AB+', 2),
    ], 'O+');

    expect(sorted.map((r) => r.id), [
      'ab-plus-soon',
      'b-plus-later',
      'a-minus-soon',
    ]);
  });

  test('on the same day, the one posted first comes first', () {
    final sorted = sortOpenRequests([
      request('newer', 'O+', 3, postedDay: 20),
      request('older', 'O+', 3, postedDay: 10),
    ], 'O+');
    expect(sorted.first.id, 'older');
  });

  test('the original list is not changed', () {
    final original = [request('x', 'A-', 1), request('y', 'O+', 2)];
    sortOpenRequests(original, 'O+');
    expect(original.first.id, 'x');
  });
}
