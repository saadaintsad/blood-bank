import 'enums.dart';

/// The donor details added to an account by donor registration.
///
/// Field list from "Donor registration and profile" in
/// docs/requirements.md. Name and phone stay on AppUser, so a seeker who
/// becomes a donor keeps the same account.
class DonorProfile {
  const DonorProfile({
    required this.userId,
    required this.bloodGroup,
    required this.gender,
    required this.dateOfBirth,
    required this.district,
    required this.area,
    this.extraLocationDetails,
    this.lastDonationDate,
    this.receiveAlerts = true,
    required this.status,
  });

  /// The AppUser this profile belongs to.
  final String userId;

  /// One of `bloodGroups` in utils/constants.dart, e.g. "O+".
  final String bloodGroup;

  final Gender gender;

  /// Private. Only used to check the 18–60 age range.
  final DateTime dateOfBirth;

  final String district;
  final String area;

  /// Optional and private: never shown to other users.
  final String? extraLocationDetails;

  /// Private. Null means "never donated".
  final DateTime? lastDonationDate;

  /// Whether the donor wants blood request alerts. On by default.
  final bool receiveAlerts;

  /// Green, Yellow or Red. Set from [lastDonationDate] at registration.
  final DonorStatus status;
}
