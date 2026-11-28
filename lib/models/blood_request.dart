import 'enums.dart';

/// A request for blood posted by a user.
///
/// Fields from "Blood requests" in docs/requirements.md. Post Request will
/// create these; for now one sample request lives in
/// data/mock/sample_requests.dart.
class BloodRequest {
  const BloodRequest({
    required this.id,
    required this.ownerId,
    required this.patientName,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.hospital,
    required this.district,
    required this.requiredDate,
    required this.contactPhone,
    this.notes,
    this.status = RequestStatus.open,
  });

  final String id;

  /// The AppUser who posted it. Only they can close it.
  final String ownerId;

  final String patientName;

  /// The patient's group, e.g. "B+". Donor search uses it to pre-fill.
  final String bloodGroup;

  /// Bags of blood needed.
  final int unitsNeeded;

  /// Free text, e.g. the hospital's name.
  final String hospital;

  final String district;
  final DateTime requiredDate;

  /// The seeker's number, as 01XXXXXXXXX.
  final String contactPhone;

  final String? notes;
  final RequestStatus status;

  bool get isOpen => status == RequestStatus.open;
}
