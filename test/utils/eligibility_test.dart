import 'package:bloodbank/models/enums.dart';
import 'package:bloodbank/utils/eligibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // `group` puts related tests under one heading in the test output.
  group('ageOn', () {
    final dateOfBirth = DateTime(2008, 5, 15);

    test('is one less the day before the birthday', () {
      expect(ageOn(dateOfBirth, DateTime(2026, 5, 14)), 17);
    });

    test('goes up on the birthday itself', () {
      expect(ageOn(dateOfBirth, DateTime(2026, 5, 15)), 18);
    });

    test('stays the same the day after the birthday', () {
      expect(ageOn(dateOfBirth, DateTime(2026, 5, 16)), 18);
    });

    test('counts an earlier month in the year as birthday not reached', () {
      expect(ageOn(dateOfBirth, DateTime(2026, 1, 31)), 17);
    });

    test('a 29 February birthday counts from 1 March in other years', () {
      final leapBirthday = DateTime(2008, 2, 29);
      expect(ageOn(leapBirthday, DateTime(2026, 2, 28)), 17);
      expect(ageOn(leapBirthday, DateTime(2026, 3, 1)), 18);
      expect(ageOn(leapBirthday, DateTime(2028, 2, 29)), 20);
    });
  });

  group('isEligibleDonorAge', () {
    test('allows 18 to 60, including both ends', () {
      expect(isEligibleDonorAge(18), isTrue);
      expect(isEligibleDonorAge(35), isTrue);
      expect(isEligibleDonorAge(60), isTrue);
    });

    test('refuses 17 and 61', () {
      expect(isEligibleDonorAge(17), isFalse);
      expect(isEligibleDonorAge(61), isFalse);
    });
  });

  group('waitingPeriodDays', () {
    test('is 84 days for men and 112 for women and other genders', () {
      expect(waitingPeriodDays(Gender.male), 84);
      expect(waitingPeriodDays(Gender.female), 112);
      expect(waitingPeriodDays(Gender.other), 112);
    });
  });

  group('nextEligibleDate', () {
    test('adds the waiting period across months and years', () {
      expect(
        nextEligibleDate(DateTime(2026, 11, 20), Gender.male),
        DateTime(2027, 2, 12),
      );
      expect(
        nextEligibleDate(DateTime(2026, 11, 20), Gender.female),
        DateTime(2027, 3, 12),
      );
    });

    test('ignores the time of day', () {
      expect(
        nextEligibleDate(DateTime(2026, 1, 1, 22, 30), Gender.male),
        DateTime(2026, 3, 26),
      );
    });
  });

  group('daysUntilEligible and startingStatus', () {
    final today = DateTime(2026, 11, 27);

    test('never donated: 0 days, starts Green', () {
      expect(daysUntilEligible(null, Gender.male, today), 0);
      expect(startingStatus(null, Gender.male, today), DonorStatus.available);
    });

    test('a man who donated 40 days ago waits 44 more days (Yellow)', () {
      final lastDonation = DateTime(2026, 10, 18); // 40 days before today
      expect(daysUntilEligible(lastDonation, Gender.male, today), 44);
      expect(
        startingStatus(lastDonation, Gender.male, today),
        DonorStatus.recentlyDonated,
      );
    });

    test('a man is Green exactly 84 days after donating', () {
      final lastDonation = DateTime(2026, 9, 4); // 84 days before today
      expect(daysUntilEligible(lastDonation, Gender.male, today), 0);
      expect(
        startingStatus(lastDonation, Gender.male, today),
        DonorStatus.available,
      );
    });

    test('a man is still Yellow 83 days after donating', () {
      final lastDonation = DateTime(2026, 9, 5); // 83 days before today
      expect(daysUntilEligible(lastDonation, Gender.male, today), 1);
      expect(
        startingStatus(lastDonation, Gender.male, today),
        DonorStatus.recentlyDonated,
      );
    });

    test('90 days ago is Green for a man but Yellow for a woman', () {
      final ninetyDaysAgo = DateTime(2026, 8, 29);
      expect(
        startingStatus(ninetyDaysAgo, Gender.male, today),
        DonorStatus.available,
      );
      expect(
        startingStatus(ninetyDaysAgo, Gender.female, today),
        DonorStatus.recentlyDonated,
      );
      // Other genders use the 112-day gap too: 112 - 90 = 22 days left.
      expect(daysUntilEligible(ninetyDaysAgo, Gender.other, today), 22);
    });

    test('a woman is Green exactly 112 days after donating', () {
      final lastDonation = DateTime(2026, 8, 7); // 112 days before today
      expect(
        startingStatus(lastDonation, Gender.female, today),
        DonorStatus.available,
      );
    });

    test('eight months ago is Green for a woman (walkthrough Scene 1)', () {
      expect(
        startingStatus(DateTime(2026, 3, 27), Gender.female, today),
        DonorStatus.available,
      );
    });
  });
}
