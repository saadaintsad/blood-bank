import 'package:bloodbank/utils/blood_compatibility.dart';
import 'package:bloodbank/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compatibleDonorGroups', () {
    // Every row of "Blood group matching" in docs/requirements.md.
    const table = {
      'O-': ['O-'],
      'O+': ['O+', 'O-'],
      'A-': ['A-', 'O-'],
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'AB-': ['AB-', 'A-', 'B-', 'O-'],
    };

    table.forEach((patient, donors) {
      test('$patient can receive from ${donors.join(', ')}', () {
        expect(compatibleDonorGroups(patient), unorderedEquals(donors));
      });
    });

    test('AB+ can receive from every group', () {
      expect(compatibleDonorGroups('AB+'), unorderedEquals(bloodGroups));
    });

    test("lists the patient's own group first", () {
      for (final group in bloodGroups) {
        expect(compatibleDonorGroups(group).first, group);
      }
    });

    test('an unknown group matches nobody', () {
      expect(compatibleDonorGroups('C+'), isEmpty);
    });
  });

  group('canDonateTo', () {
    test('O- can give to every group', () {
      for (final patient in bloodGroups) {
        expect(canDonateTo('O-', patient), isTrue, reason: patient);
      }
    });

    test('only O- can give to an O- patient', () {
      for (final donor in bloodGroups) {
        expect(canDonateTo(donor, 'O-'), donor == 'O-', reason: donor);
      }
    });

    test('A+ cannot give to B+ (walkthrough: Arif and Rahim)', () {
      expect(canDonateTo('A+', 'B+'), isFalse);
    });

    test('negative cannot receive positive', () {
      expect(canDonateTo('B+', 'B-'), isFalse);
      expect(canDonateTo('O+', 'A-'), isFalse);
    });
  });
}
