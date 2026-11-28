/// Rules for the "I'm Interested" flow in docs/requirements.md.
///
/// Like eligibility.dart, every function takes the time as a parameter
/// instead of reading the clock, so tests can pick any moment.
library;

import '../models/donor.dart';
import '../models/donor_response.dart';
import '../models/enums.dart';
import 'blood_compatibility.dart';
import 'date_format.dart';
import 'eligibility.dart';

/// How long a donor stays hidden from search after tapping, and how long
/// they can't respond to another request.
const Duration interestHiddenPeriod = Duration(hours: 3);

/// The hour (24-hour clock) of the evening question on the required date.
const int donateQuestionHour = 20; // 8 PM

/// When the donor's hidden window ends: 3 hours after the tap, or earlier
/// if the seeker cancelled the request.
DateTime hiddenUntil(DonorResponse response) {
  final normalEnd = response.tappedAt.add(interestHiddenPeriod);
  final endedEarly = response.endedEarlyAt;
  if (endedEarly != null && endedEarly.isBefore(normalEnd)) return endedEarly;
  return normalEnd;
}

/// True while the donor is hidden from search because of [response].
bool isInHiddenWindow(DonorResponse response, DateTime now) {
  return !now.isBefore(response.tappedAt) &&
      now.isBefore(hiddenUntil(response));
}

/// The response of [donorId] whose hidden window is running at [now], or
/// null. There is at most one, because a donor can't respond to a second
/// request during the window.
DonorResponse? activeResponseOf(
  Iterable<DonorResponse> responses,
  String donorId,
  DateTime now,
) {
  for (final response in responses) {
    if (response.donorId == donorId && isInHiddenWindow(response, now)) {
      return response;
    }
  }
  return null;
}

/// True when [donorId] may tap "I'm Interested" on a new request now.
bool canRespondNow(
  Iterable<DonorResponse> responses,
  String donorId,
  DateTime now,
) {
  return activeResponseOf(responses, donorId, now) == null;
}

/// When to ask "Did you successfully donate blood?": 8 PM on the
/// request's required date, or 3 hours after the tap if that is later.
DateTime donateQuestionAt(DateTime requiredDate, DateTime tappedAt) {
  final evening = DateTime(
    requiredDate.year,
    requiredDate.month,
    requiredDate.day,
    donateQuestionHour,
  );
  final afterWindow = tappedAt.add(interestHiddenPeriod);
  return afterWindow.isAfter(evening) ? afterWindow : evening;
}

/// Why [profile] can't tap "I'm Interested" on a request for a
/// [patientGroup] patient, or null when they can.
///
/// Only Green donors whose group can give to the patient may respond
/// (agreed 28 Nov 2026). [activeResponse] is the donor's running window
/// on another request, if any. [now] is used for the Yellow countdown.
String? interestBlockReason({
  required DonorProfile profile,
  required String patientGroup,
  required DonorResponse? activeResponse,
  required DateTime now,
}) {
  final status = currentStatus(
    profile.status,
    profile.lastDonationDate,
    profile.gender,
    now,
  );
  if (status == DonorStatus.notAvailable) {
    return "You're set to Not available. Change your status to respond.";
  }
  if (status == DonorStatus.recentlyDonated) {
    final days = daysUntilEligible(
      profile.lastDonationDate,
      profile.gender,
      now,
    );
    return 'You can donate again in ${days == 1 ? '1 day' : '$days days'}.';
  }
  if (!canDonateTo(profile.bloodGroup, patientGroup)) {
    // A real minus sign (−) matches how the blood group stamps show it.
    String shown(String group) => group.replaceAll('-', '−');
    return "Your blood group (${shown(profile.bloodGroup)}) can't be given "
        'to this patient (${shown(patientGroup)}).';
  }
  if (activeResponse != null) {
    return 'You responded to another request. You can respond again at '
        '${formatTime(hiddenUntil(activeResponse))}.';
  }
  return null;
}
