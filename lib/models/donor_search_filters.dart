/// What the seeker chose on the Find Blood screen.
///
/// Only [bloodGroup] is required. Empty or null values mean "any".
class DonorSearchFilters {
  const DonorSearchFilters({
    required this.bloodGroup,
    this.district,
    this.area,
    this.name = '',
    this.onlyAvailable = false,
  });

  /// The patient's blood group. Compatible donor groups are found too.
  final String bloodGroup;

  /// Only donors in this district, when set.
  final String? district;

  /// Donors in this area are listed first. It changes the order only and
  /// never hides anyone (decided with the project owner).
  final String? area;

  /// Part of the donor's name, any case. Empty means any name.
  final String name;

  /// True keeps Green (available now) donors only.
  final bool onlyAvailable;
}
