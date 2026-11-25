import 'package:bloodbank/utils/constants.dart';
import 'package:bloodbank/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

// Quick checks for the plain-Dart helpers. Widget tests come later, once
// fonts are bundled with the app instead of downloaded by google_fonts.
void main() {
  test('constants list 8 blood groups and 64 districts', () {
    expect(bloodGroups.length, 8);
    expect(bangladeshDistricts.length, 64);
    expect(bangladeshDistricts.toSet().length, 64); // no duplicates
  });

  test('phone validator accepts Bangladeshi mobile formats', () {
    expect(Validators.phone('+8801712345678'), isNull);
    expect(Validators.phone('01712345678'), isNull);
    expect(Validators.phone('017-1234 5678'), isNull);
    expect(Validators.phone('01212345678'), isNotNull); // 2 is not an operator
    expect(Validators.phone('12345'), isNotNull);
  });

  test('email, password and confirm password validators', () {
    expect(Validators.email('donor@example.com'), isNull);
    expect(Validators.email('donor@'), isNotNull);
    expect(Validators.password('abc12345'), isNull);
    expect(Validators.password('abcdefgh'), isNotNull);
    expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
    expect(Validators.confirmPassword('abc', 'abc12345'), isNotNull);
    expect(Validators.requiredField('  '), isNotNull);
  });
}
