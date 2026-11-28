/// A donor's "I'm Interested" on one blood request.
///
/// From the "I'm Interested flow" in docs/requirements.md. The rules that
/// use it (3 hours hidden, one at a time, when to ask "Did you donate?")
/// live in utils/interest_rules.dart.
class DonorResponse {
  const DonorResponse({
    required this.id,
    required this.requestId,
    required this.donorId,
    required this.tappedAt,
    required this.askDonatedAt,
    this.endedEarlyAt,
  });

  final String id;
  final String requestId;

  /// The AppUser id of the donor who tapped.
  final String donorId;

  /// When the donor tapped "I'm Interested". Their 3 hours hidden from
  /// search start here.
  final DateTime tappedAt;

  /// When the app should ask "Did you successfully donate blood?". The
  /// question screen comes with the Dashboard task.
  final DateTime askDonatedAt;

  /// Set when the seeker cancelled the request: the donor's 3-hour window
  /// ends at that moment instead of after 3 hours. Null otherwise.
  final DateTime? endedEarlyAt;

  /// A copy with some fields changed. The fields are final, so a change
  /// means a new object.
  DonorResponse copyWith({DateTime? askDonatedAt, DateTime? endedEarlyAt}) {
    return DonorResponse(
      id: id,
      requestId: requestId,
      donorId: donorId,
      tappedAt: tappedAt,
      askDonatedAt: askDonatedAt ?? this.askDonatedAt,
      endedEarlyAt: endedEarlyAt ?? this.endedEarlyAt,
    );
  }
}
