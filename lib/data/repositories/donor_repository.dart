import '../../models/donor.dart';

/// What the app needs to save and load donor profiles.
///
/// MockDonorRepository implements it for now; a Supabase version comes
/// later (see auth_repository.dart for why we use interfaces).
abstract class DonorRepository {
  /// Saves a new donor profile for [DonorProfile.userId] and returns it.
  /// Throws [DonorException] if that user is already a donor.
  Future<DonorProfile> registerDonor(DonorProfile profile);

  /// The donor profile of [userId], or null if they are not a donor.
  Future<DonorProfile?> getProfile(String userId);
}

/// Thrown when saving a donor profile fails. [message] is safe to show.
class DonorException implements Exception {
  const DonorException(this.message);

  final String message;

  @override
  String toString() => 'DonorException: $message';
}
