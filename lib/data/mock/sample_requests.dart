import '../../models/blood_request.dart';
import '../../models/donor_response.dart';
import '../../utils/interest_rules.dart';

// SAMPLE DATA: two open blood requests in Dhaka. Patients, hospitals and
// numbers are placeholders.
//
// - request-1 belongs to Sample Requester (01700000003 / demo1234). Log in
//   as them to see donors' phone numbers in Find Blood, and the two
//   interested donors (Nusrat and Mitu) on the request's details.
// - request-2 belongs to the sample donor Farhana, so Sample Donor
//   (01700000002, O+) sees one request they can give to (B+) and one they
//   can't (A−) under Open Requests.

/// The sample requests. Required dates count from [today], so they never
/// look out of date.
List<BloodRequest> sampleRequests(DateTime today) {
  DateTime inDays(int days) =>
      DateTime(today.year, today.month, today.day + days);

  return [
    BloodRequest(
      id: 'request-1',
      ownerId: 'user-3',
      patientName: 'Sample Patient',
      bloodGroup: 'B+',
      unitsNeeded: 2,
      hospital: 'Sample Hospital',
      district: 'Dhaka',
      requiredDate: inDays(1),
      contactPhone: '01700000003',
      createdAt: inDays(0),
      notes: 'Sample request for testing.',
    ),
    BloodRequest(
      id: 'request-2',
      ownerId: 'donor-6',
      patientName: 'Sample Patient Two',
      bloodGroup: 'A-',
      unitsNeeded: 1,
      hospital: 'Sample Medical College',
      district: 'Dhaka',
      requiredDate: inDays(2),
      contactPhone: '01700000106',
      createdAt: inDays(0),
    ),
  ];
}

/// Nusrat (donor-3) and Mitu (donor-4) tapped "I'm Interested" on
/// request-1, 5 and 4 hours before [now]. Their 3-hour windows are already
/// over, so they still appear in Find Blood.
List<DonorResponse> sampleResponses(
  DateTime now,
  Map<String, BloodRequest> requestsById,
) {
  final request = requestsById['request-1']!;

  DonorResponse response(String id, String donorId, int hoursAgo) {
    final tappedAt = now.subtract(Duration(hours: hoursAgo));
    return DonorResponse(
      id: id,
      requestId: request.id,
      donorId: donorId,
      tappedAt: tappedAt,
      askDonatedAt: donateQuestionAt(request.requiredDate, tappedAt),
    );
  }

  return [
    response('response-1', 'donor-3', 5),
    response('response-2', 'donor-4', 4),
  ];
}
