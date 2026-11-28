/// Rules for who may register as a donor and when they can donate again.
///
/// Every function takes `today` as a parameter instead of reading the
/// clock itself. That makes the rules "pure": the same input always gives
/// the same answer, so tests can pick any date they like.
///
/// Source: "Donor registration and profile" and "Availability and
/// eligibility" in docs/requirements.md.
library;

import '../models/enums.dart';

// These numbers will become settings in Supabase, so they can change
// without an app update. Until then they live here, in one place.

/// Youngest age (in whole years) that may register as a donor.
const int minDonorAge = 18;

/// Oldest age that may register. 60 is allowed; 61 is not.
const int maxDonorAge = 60;

/// Days between donations for men (12 weeks).
const int maleWaitingDays = 84;

/// Days between donations for women and any other gender (16 weeks).
const int otherWaitingDays = 112;

/// Removes the time of day, so "today at 9:30" and "today at 18:00" count
/// as the same day.
DateTime dateOnly(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

/// Age in whole years on [today]. The age goes up on the birthday itself.
///
/// Someone born on 29 February has their birthday on 1 March in years
/// that are not leap years.
int ageOn(DateTime dateOfBirth, DateTime today) {
  var age = today.year - dateOfBirth.year;
  final hadBirthdayThisYear =
      today.month > dateOfBirth.month ||
      (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);
  if (!hadBirthdayThisYear) age--;
  return age;
}

/// True when [age] is inside the donor range ([minDonorAge]–[maxDonorAge]).
bool isEligibleDonorAge(int age) => age >= minDonorAge && age <= maxDonorAge;

/// How many days a donor of this [gender] must wait between donations.
int waitingPeriodDays(Gender gender) {
  return switch (gender) {
    Gender.male => maleWaitingDays,
    Gender.female || Gender.other => otherWaitingDays,
  };
}

/// The first day the donor can give blood again after [lastDonation].
DateTime nextEligibleDate(DateTime lastDonation, Gender gender) {
  final day = dateOnly(lastDonation);
  // We add to the day number instead of using Duration(days: ...).
  // DateTime fixes the overflow (e.g. 40 November becomes 10 December),
  // and this avoids daylight-saving surprises with 24-hour durations.
  return DateTime(day.year, day.month, day.day + waitingPeriodDays(gender));
}

/// Days left until the donor can give again, or 0 if they already can.
/// Never-donated donors ([lastDonation] is null) get 0.
int daysUntilEligible(DateTime? lastDonation, Gender gender, DateTime today) {
  if (lastDonation == null) return 0;
  final days = nextEligibleDate(
    lastDonation,
    gender,
  ).difference(dateOnly(today)).inDays;
  return days > 0 ? days : 0;
}

/// A donor's status today.
///
/// Red is set by the donor, so it stays Red. Otherwise the waiting period
/// decides: Yellow while it runs, Green once it ends. That is how Yellow
/// turns Green "automatically" even though the saved status is still
/// Yellow (the server will do this on a schedule later).
DonorStatus currentStatus(
  DonorStatus savedStatus,
  DateTime? lastDonation,
  Gender gender,
  DateTime today,
) {
  if (savedStatus == DonorStatus.notAvailable) return DonorStatus.notAvailable;
  return startingStatus(lastDonation, gender, today);
}

/// The status a new donor starts with: Yellow (recently donated) while the
/// waiting period after [lastDonation] is still running, otherwise Green.
DonorStatus startingStatus(
  DateTime? lastDonation,
  Gender gender,
  DateTime today,
) {
  return daysUntilEligible(lastDonation, gender, today) > 0
      ? DonorStatus.recentlyDonated
      : DonorStatus.available;
}
