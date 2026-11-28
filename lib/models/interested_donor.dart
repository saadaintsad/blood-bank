/// One donor listed under a request as "interested", as the seeker who
/// posted it sees them (walkthrough Scene 5).
class InterestedDonor {
  const InterestedDonor({
    required this.donorId,
    required this.name,
    required this.bloodGroup,
    required this.area,
    required this.phone,
    required this.tappedAt,
  });

  final String donorId;
  final String name;
  final String bloodGroup;
  final String area;

  /// Shared with the seeker because the donor tapped "I'm Interested".
  final String phone;

  /// When they tapped, shown as "Interested at 4:10 PM".
  final DateTime tappedAt;
}
