import '../../models/blood_request.dart';

// SAMPLE DATA: one open blood request, owned by Sample Requester
// (01700000003 / demo1234). Log in as them to see donors' phone numbers
// and the Call / SMS buttons in Find Blood. Patient, hospital and number
// are placeholders.

/// The sample requests. The required date is tomorrow, counted from
/// [today], so the request never looks out of date.
List<BloodRequest> sampleRequests(DateTime today) {
  return [
    BloodRequest(
      id: 'request-1',
      ownerId: 'user-3',
      patientName: 'Sample Patient',
      bloodGroup: 'B+',
      unitsNeeded: 2,
      hospital: 'Sample Hospital',
      district: 'Dhaka',
      requiredDate: DateTime(today.year, today.month, today.day + 1),
      contactPhone: '01700000003',
      notes: 'Sample request for testing.',
    ),
  ];
}
