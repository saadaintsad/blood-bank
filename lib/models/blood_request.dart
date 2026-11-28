import 'enums.dart';

/// A request for blood posted by a user.
///
/// Fields from "Blood requests" in docs/requirements.md. Post Request
/// creates these (see NewBloodRequest); one sample request lives in
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
    required this.createdAt,
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

  /// The day the blood is needed (no time of day).
  final DateTime requiredDate;

  /// The seeker's number, as 01XXXXXXXXX.
  final String contactPhone;

  /// When it was posted. Lists show the newest first.
  final DateTime createdAt;

  final String? notes;

  /// The saved status. Screens should show `effectiveStatus()` from
  /// utils/request_rules.dart instead, which also knows about expiry.
  final RequestStatus status;

  /// A copy with a new status, e.g. after Mark Fulfilled. The fields are
  /// final, so we make a new object instead of changing this one.
  BloodRequest copyWith({RequestStatus? status}) {
    return BloodRequest(
      id: id,
      ownerId: ownerId,
      patientName: patientName,
      bloodGroup: bloodGroup,
      unitsNeeded: unitsNeeded,
      hospital: hospital,
      district: district,
      requiredDate: requiredDate,
      contactPhone: contactPhone,
      createdAt: createdAt,
      notes: notes,
      status: status ?? this.status,
    );
  }
}
