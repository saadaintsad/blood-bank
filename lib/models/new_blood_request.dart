/// What the Post Request form sends to the repository.
///
/// It is a BloodRequest without the parts the "server" decides: the id,
/// the status (always Open at first) and the time it was posted.
class NewBloodRequest {
  const NewBloodRequest({
    required this.ownerId,
    required this.patientName,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.hospital,
    required this.district,
    required this.requiredDate,
    required this.contactPhone,
    this.notes,
  });

  final String ownerId;
  final String patientName;
  final String bloodGroup;
  final int unitsNeeded;
  final String hospital;
  final String district;
  final DateTime requiredDate;

  /// Already normalized to 01XXXXXXXXX.
  final String contactPhone;

  /// Null when the user left notes empty.
  final String? notes;
}
