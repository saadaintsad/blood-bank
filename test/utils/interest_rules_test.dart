import 'package:bloodbank/models/donor.dart';
import 'package:bloodbank/models/donor_response.dart';
import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/utils/interest_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tap = DateTime(2026, 11, 28, 10, 0);

  DonorResponse response({
    String donorId = 'donor-1',
    DateTime? tappedAt,
    DateTime? endedEarlyAt,
  }) {
    final at = tappedAt ?? tap;
    return DonorResponse(
      id: 'response-1',
      requestId: 'request-1',
      donorId: donorId,
      tappedAt: at,
      askDonatedAt: at.add(const Duration(hours: 10)),
      endedEarlyAt: endedEarlyAt,
    );
  }

  group('3-hour hiding', () {
    test('hidden right after the tap and until just before 3 hours', () {
      final r = response();
      expect(isInHiddenWindow(r, tap), isTrue);
      expect(isInHiddenWindow(r, DateTime(2026, 11, 28, 12, 59)), isTrue);
    });

    test('visible again exactly 3 hours after the tap', () {
      final r = response();
      expect(hiddenUntil(r), DateTime(2026, 11, 28, 13, 0));
      expect(isInHiddenWindow(r, DateTime(2026, 11, 28, 13, 0)), isFalse);
    });

    test('a cancelled request ends the window early', () {
      final r = response(endedEarlyAt: DateTime(2026, 11, 28, 11, 0));
      expect(hiddenUntil(r), DateTime(2026, 11, 28, 11, 0));
      expect(isInHiddenWindow(r, DateTime(2026, 11, 28, 11, 0)), isFalse);
    });

    test('ending "early" after the window is over changes nothing', () {
      final r = response(endedEarlyAt: DateTime(2026, 11, 28, 20, 0));
      expect(hiddenUntil(r), DateTime(2026, 11, 28, 13, 0));
    });
  });

  group('one interest at a time', () {
    test('a donor in their window cannot respond again', () {
      final responses = [response()];
      final inWindow = DateTime(2026, 11, 28, 11, 30);
      expect(activeResponseOf(responses, 'donor-1', inWindow), isNotNull);
      expect(canRespondNow(responses, 'donor-1', inWindow), isFalse);
    });

    test('they can respond again once the 3 hours are over', () {
      final responses = [response()];
      final later = DateTime(2026, 11, 28, 13, 0);
      expect(canRespondNow(responses, 'donor-1', later), isTrue);
    });

    test('other donors are not affected', () {
      final responses = [response()];
      expect(canRespondNow(responses, 'donor-2', tap), isTrue);
    });
  });

  group('when to ask "Did you donate?"', () {
    test('8 PM on the required date when the tap is earlier that day', () {
      expect(
        donateQuestionAt(DateTime(2026, 11, 28), DateTime(2026, 11, 28, 10)),
        DateTime(2026, 11, 28, 20),
      );
    });

    test('3 hours after the tap when that is later than 8 PM', () {
      expect(
        donateQuestionAt(DateTime(2026, 11, 28), DateTime(2026, 11, 28, 18)),
        DateTime(2026, 11, 28, 21),
      );
    });

    test('exactly 5 PM: both rules give 8 PM', () {
      expect(
        donateQuestionAt(DateTime(2026, 11, 28), DateTime(2026, 11, 28, 17)),
        DateTime(2026, 11, 28, 20),
      );
    });

    test('a request for tomorrow is asked about tomorrow evening', () {
      // Walkthrough Scene 7: Nusrat isn't asked tonight.
      expect(
        donateQuestionAt(DateTime(2026, 11, 29), DateTime(2026, 11, 28, 21)),
        DateTime(2026, 11, 29, 20),
      );
    });
  });

  group('interestBlockReason', () {
    DonorProfile profile({
      String group = 'O+',
      DonorStatus status = DonorStatus.available,
      DateTime? lastDonation,
    }) {
      return DonorProfile(
        userId: 'donor-1',
        bloodGroup: group,
        gender: Gender.male,
        dateOfBirth: DateTime(2000, 1, 1),
        district: 'Dhaka',
        area: 'Badda',
        lastDonationDate: lastDonation,
        status: status,
      );
    }

    test('a Green compatible donor may respond', () {
      expect(
        interestBlockReason(
          profile: profile(),
          patientGroup: 'B+',
          activeResponse: null,
          now: tap,
        ),
        isNull,
      );
    });

    test('a Yellow donor is told how many days to wait', () {
      final reason = interestBlockReason(
        profile: profile(
          status: DonorStatus.recentlyDonated,
          lastDonation: DateTime(2026, 10, 19), // 40 days before 28 Nov
        ),
        patientGroup: 'B+',
        activeResponse: null,
        now: tap,
      );
      expect(reason, 'You can donate again in 44 days.');
    });

    test('a Red donor is told to change their status', () {
      final reason = interestBlockReason(
        profile: profile(status: DonorStatus.notAvailable),
        patientGroup: 'B+',
        activeResponse: null,
        now: tap,
      );
      expect(reason, contains('Not available'));
    });

    test('an incompatible blood group is refused', () {
      final reason = interestBlockReason(
        profile: profile(group: 'A+'),
        patientGroup: 'B+',
        activeResponse: null,
        now: tap,
      );
      expect(
        reason,
        "Your blood group (A+) can't be given to this patient (B+).",
      );
    });

    test('a running window elsewhere says when they can respond again', () {
      final reason = interestBlockReason(
        profile: profile(),
        patientGroup: 'B+',
        activeResponse: response(),
        now: DateTime(2026, 11, 28, 11),
      );
      expect(reason, contains('1:00 PM'));
    });
  });
}
