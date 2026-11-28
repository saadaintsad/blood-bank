/// Rules for blood requests, from "Blood requests" in docs/requirements.md.
///
/// Like utils/eligibility.dart, every function takes the date or time as a
/// parameter instead of reading the clock, so tests can pick any moment.
library;

import '../models/blood_request.dart';
import '../models/enums.dart';
import 'eligibility.dart' show dateOnly;

/// Most requests one user may have Open at the same time.
const int maxOpenRequests = 3;

/// Fewest and most bags one request can ask for.
const int minUnits = 1;
const int maxUnits = 10;

/// How far ahead the required date may be.
const int maxDaysAhead = 30;

/// Longest note allowed on a request.
const int maxNotesLength = 200;

/// Shown when a user tries to post while they already have
/// [maxOpenRequests] open.
const String openRequestLimitMessage =
    'You already have $maxOpenRequests open requests. Mark one Fulfilled '
    'or Cancel it before posting another.';

/// An error message for the required date, or null when it is fine.
///
/// Today is allowed (blood is often needed the same day); yesterday is not.
String? requiredDateError(DateTime? date, DateTime today) {
  if (date == null) return 'Choose the date the blood is needed';
  if (dateOnly(date).isBefore(dateOnly(today))) {
    return "The required date can't be in the past";
  }
  return null;
}

/// The moment an Open request closes by itself: 48 hours after the end of
/// its required day. Required 28 Nov ends at midnight starting 29 Nov, so
/// the request closes at 1 Dec 00:00.
DateTime expiresAt(DateTime requiredDate) {
  final day = dateOnly(requiredDate);
  // End of the day (+1) and then 2 more days. Adding to the day number
  // avoids daylight-saving surprises, as in eligibility.dart.
  return DateTime(day.year, day.month, day.day + 3);
}

/// True when [request] is still marked Open but its time has run out.
/// Fulfilled and Cancelled requests are already closed, so never "expire".
bool isExpired(BloodRequest request, DateTime now) {
  return request.status == RequestStatus.open &&
      !now.isBefore(expiresAt(request.requiredDate));
}

/// The status to show for [request] at [now]: its saved status, or
/// Expired once an Open request is past [expiresAt].
RequestStatus effectiveStatus(BloodRequest request, DateTime now) {
  return isExpired(request, now) ? RequestStatus.expired : request.status;
}

/// True when [request] is Open right now. Use this, not
/// `status == RequestStatus.open`, wherever "open" matters: the 3-request
/// limit, phone-number access and the Mark Fulfilled / Cancel buttons.
bool isLive(BloodRequest request, DateTime now) {
  return effectiveStatus(request, now) == RequestStatus.open;
}
