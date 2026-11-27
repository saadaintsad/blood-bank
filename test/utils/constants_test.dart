import 'package:bloodbank/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('there are 8 blood groups', () {
    expect(bloodGroups.length, 8);
  });

  test('there are 64 different districts', () {
    expect(bangladeshDistricts.length, 64);
    expect(bangladeshDistricts.toSet().length, 64); // no duplicates
  });
}
