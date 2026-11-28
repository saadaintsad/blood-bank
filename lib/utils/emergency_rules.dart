/// The Emergency Alert limit from "Notifications and emergency alerts" in
/// docs/requirements.md: each seeker may send one every 15 days.
///
/// Days are counted on dates, like eligibility.dart: an alert sent at any
/// time on 1 Dec allows the next one from 16 Dec. That matches walkthrough
/// Scene 6 ("next week ... Available again in 8 days").
library;

import 'eligibility.dart' show dateOnly;

/// Days between two emergency alerts from the same seeker.
const int emergencyCooldownDays = 15;

/// The first day the seeker may send another alert after [lastSentAt].
DateTime nextEmergencyAllowed(DateTime lastSentAt) {
  final day = dateOnly(lastSentAt);
  return DateTime(day.year, day.month, day.day + emergencyCooldownDays);
}

/// Days until the seeker may send an alert again, or 0 when they can now.
/// [lastSentAt] is null when they have never sent one.
int daysUntilEmergencyAllowed(DateTime? lastSentAt, DateTime now) {
  if (lastSentAt == null) return 0;
  final days = nextEmergencyAllowed(lastSentAt)
      .difference(dateOnly(now))
      .inDays;
  return days > 0 ? days : 0;
}
