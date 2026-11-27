import '../../models/donor.dart';
import '../repositories/donor_repository.dart';
import 'mock_store.dart';

/// Saves donor profiles in a [MockStore]. No network calls.
class MockDonorRepository implements DonorRepository {
  MockDonorRepository(
    this._store, {
    this.delay = const Duration(milliseconds: 600),
  });

  final MockStore _store;

  /// Pretend server delay. Tests pass Duration.zero.
  final Duration delay;

  @override
  Future<DonorProfile> registerDonor(DonorProfile profile) async {
    await Future.delayed(delay);

    if (_store.donorProfilesByUserId.containsKey(profile.userId)) {
      throw const DonorException('You are already registered as a donor.');
    }
    _store.donorProfilesByUserId[profile.userId] = profile;
    return profile;
  }

  @override
  Future<DonorProfile?> getProfile(String userId) async {
    await Future.delayed(delay);
    return _store.donorProfilesByUserId[userId];
  }
}
