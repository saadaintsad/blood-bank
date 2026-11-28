import 'package:bloodbank/utils/emergency_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Sent in the evening, like Rahim in walkthrough Scene 6.
  final sent = DateTime(2026, 11, 28, 19, 30);

  test('a seeker who never sent one can send now', () {
    expect(daysUntilEmergencyAllowed(null, sent), 0);
  });

  test('right after sending, 15 days to wait', () {
    expect(daysUntilEmergencyAllowed(sent, sent), 15);
  });

  test('a week later: "Available again in 8 days"', () {
    expect(daysUntilEmergencyAllowed(sent, DateTime(2026, 12, 5, 9)), 8);
  });

  test('day 14: one more day', () {
    expect(daysUntilEmergencyAllowed(sent, DateTime(2026, 12, 12, 23)), 1);
  });

  test('day 15: allowed again from midnight', () {
    expect(nextEmergencyAllowed(sent), DateTime(2026, 12, 13));
    expect(daysUntilEmergencyAllowed(sent, DateTime(2026, 12, 13)), 0);
  });
}
