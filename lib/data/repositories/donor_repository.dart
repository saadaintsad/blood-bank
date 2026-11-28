import '../../models/donor.dart';
import '../../models/donor_search_filters.dart';
import '../../models/donor_search_result.dart';

/// What the app needs to save, load and search donor profiles.
///
/// MockDonorRepository implements it for now; a Supabase version comes
/// later (see auth_repository.dart for why we use interfaces).
abstract class DonorRepository {
  /// Saves a new donor profile for [DonorProfile.userId] and returns it.
  /// Throws [DonorException] if that user is already a donor.
  Future<DonorProfile> registerDonor(DonorProfile profile);

  /// The donor profile of [userId], or null if they are not a donor.
  Future<DonorProfile?> getProfile(String userId);

  /// Donors matching [filters], already in Find Blood order.
  ///
  /// Includes every compatible blood group. Leaves out Red donors and the
  /// viewer's own profile ([viewerId]).
  Future<List<DonorSearchResult>> searchDonors(
    DonorSearchFilters filters, {
    required String viewerId,
  });

  /// The phone number of donor [donorId], or null when [viewerId] may not
  /// see it. Only viewers with an open blood request may, and only for
  /// Green or Yellow donors (the future `donor_contacts` RLS rule).
  Future<String?> getDonorPhone(String donorId, {required String viewerId});
}

/// Thrown when saving a donor profile fails. [message] is safe to show.
class DonorException implements Exception {
  const DonorException(this.message);

  final String message;

  @override
  String toString() => 'DonorException: $message';
}
