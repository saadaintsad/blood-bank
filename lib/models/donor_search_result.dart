import 'enums.dart';

/// One donor in the Find Blood results: only what other users may see.
///
/// There is no phone number here on purpose. Numbers are fetched
/// separately (DonorRepository.getDonorPhone) and only for users with an
/// open blood request, just like the future `donor_contacts` table.
class DonorSearchResult {
  const DonorSearchResult({
    required this.donorId,
    required this.name,
    required this.bloodGroup,
    required this.district,
    required this.area,
    required this.gender,
    required this.status,
    required this.daysUntilAvailable,
    required this.isExactMatch,
  });

  /// The donor's AppUser id.
  final String donorId;

  final String name;
  final String bloodGroup;
  final String district;
  final String area;
  final Gender gender;

  /// Today's status: Green or Yellow (Red donors never appear).
  final DonorStatus status;

  /// Days until a Yellow donor can give again. 0 for Green donors.
  final int daysUntilAvailable;

  /// True when the donor's group is the same as the patient's. False
  /// means a different but compatible group, labelled "Compatible".
  final bool isExactMatch;

  /// Text for the StatusChip: "Available in 44 days" for Yellow donors.
  String get statusLabel {
    if (status != DonorStatus.recentlyDonated) return status.label;
    return daysUntilAvailable == 1
        ? 'Available in 1 day'
        : 'Available in $daysUntilAvailable days';
  }
}

/// What the Donor details screen receives as route `arguments`.
///
/// [phone] is null when the viewer has no open blood request, so the
/// screen shows the "Post a blood request" banner instead.
class DonorDetailsArgs {
  const DonorDetailsArgs({required this.donor, this.phone});

  final DonorSearchResult donor;
  final String? phone;
}
