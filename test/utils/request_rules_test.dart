import 'package:bloodbank/models/blood_request.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/utils/request_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// A request needed on [requiredDate]. Only the date and status matter to
/// these rules.
BloodRequest requestOn(
  DateTime requiredDate, {
  RequestStatus status = RequestStatus.open,
}) {
  return BloodRequest(
    id: 'r',
    ownerId: 'u',
    patientName: 'Test Patient',
    bloodGroup: 'B+',
    unitsNeeded: 1,
    hospital: 'Test Hospital',
    district: 'Dhaka',
    requiredDate: requiredDate,
    contactPhone: '01700000000',
    createdAt: DateTime(2026, 11, 20),
    status: status,
  );
}

void main() {
  final today = DateTime(2026, 11, 28);

  group('requiredDateError', () {
    test('no date is an error', () {
      expect(requiredDateError(null, today), isNotNull);
    });

    test('yesterday is in the past', () {
      expect(
        requiredDateError(DateTime(2026, 11, 27), today),
        "The required date can't be in the past",
      );
    });

    test('today is allowed, even late in the evening', () {
      expect(requiredDateError(DateTime(2026, 11, 28), today), isNull);
      expect(
        requiredDateError(DateTime(2026, 11, 28), DateTime(2026, 11, 28, 23)),
        isNull,
      );
    });

    test('a future date is allowed', () {
      expect(requiredDateError(DateTime(2026, 12, 5), today), isNull);
    });
  });

  group('expiry', () {
    final request = requestOn(DateTime(2026, 11, 28));

    test('closes 48 hours after the end of the required day', () {
      expect(expiresAt(DateTime(2026, 11, 28)), DateTime(2026, 12, 1));
    });

    test('still open one minute before', () {
      final now = DateTime(2026, 11, 30, 23, 59);
      expect(isExpired(request, now), isFalse);
      expect(effectiveStatus(request, now), RequestStatus.open);
      expect(isLive(request, now), isTrue);
    });

    test('expired from that moment on', () {
      final now = DateTime(2026, 12, 1);
      expect(isExpired(request, now), isTrue);
      expect(effectiveStatus(request, now), RequestStatus.expired);
      expect(isLive(request, now), isFalse);
    });

    test('Fulfilled and Cancelled requests keep their status', () {
      final later = DateTime(2027, 1, 1);
      final fulfilled = requestOn(
        DateTime(2026, 11, 28),
        status: RequestStatus.fulfilled,
      );
      final cancelled = requestOn(
        DateTime(2026, 11, 28),
        status: RequestStatus.cancelled,
      );

      expect(effectiveStatus(fulfilled, later), RequestStatus.fulfilled);
      expect(effectiveStatus(cancelled, later), RequestStatus.cancelled);
      expect(isLive(fulfilled, today), isFalse);
    });
  });
}
