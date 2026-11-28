import '../../models/donor_response.dart';
import '../../models/interested_donor.dart';

/// What the app needs for the "I'm Interested" flow.
///
/// MockInterestRepository implements it for now; a Supabase version comes
/// later.
abstract class InterestRepository {
  /// Records that donor [donorId] is interested in request [requestId].
  ///
  /// Throws [InterestException] unless the request is open, the donor is
  /// not its owner, is Green with a compatible blood group, has not
  /// already responded to it, and is not inside the 3-hour window of
  /// another response. The server will check the same rules.
  Future<DonorResponse> expressInterest(
    String requestId, {
    required String donorId,
  });

  /// [donorId]'s response whose 3-hour window is running now, or null.
  Future<DonorResponse?> getActiveResponse(String donorId);

  /// [donorId]'s response to request [requestId], or null if they have
  /// not responded to it.
  Future<DonorResponse?> getResponse(
    String requestId, {
    required String donorId,
  });

  /// The donors interested in request [requestId], first to respond
  /// first. Only the request's owner ([viewerId]) may see them; anyone
  /// else gets an empty list.
  Future<List<InterestedDonor>> getInterestedDonors(
    String requestId, {
    required String viewerId,
  });
}

/// Thrown when "I'm Interested" fails. [message] is safe to show.
class InterestException implements Exception {
  const InterestException(this.message);

  final String message;

  @override
  String toString() => 'InterestException: $message';
}
