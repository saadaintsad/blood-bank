/// The order of the Open Requests list for donors ("Blood requests" in
/// docs/requirements.md): requests the donor's blood group can give to
/// come first, then the rest. Within each group, the soonest required
/// date first, so the most urgent request is on top.
library;

import '../models/blood_request.dart';
import 'blood_compatibility.dart';

/// A new list with [requests] in Open Requests order for a donor with
/// [donorGroup]. The original list is not changed.
List<BloodRequest> sortOpenRequests(
  List<BloodRequest> requests,
  String donorGroup,
) {
  int rank(BloodRequest request) =>
      canDonateTo(donorGroup, request.bloodGroup) ? 0 : 1;

  return [...requests]..sort((a, b) {
    final byMatch = rank(a) - rank(b);
    if (byMatch != 0) return byMatch;
    final byDate = a.requiredDate.compareTo(b.requiredDate);
    if (byDate != 0) return byDate;
    // Same day: the one posted first has waited longest.
    return a.createdAt.compareTo(b.createdAt);
  });
}
