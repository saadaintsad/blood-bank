import '../../models/donor.dart';
import '../../models/donor_search_filters.dart';
import '../../models/donor_search_result.dart';
import '../../models/enums.dart';
import '../../utils/blood_compatibility.dart';
import '../../utils/donor_search.dart';
import '../../utils/eligibility.dart';
import '../repositories/donor_repository.dart';
import 'mock_store.dart';

/// Saves and searches donor profiles in a [MockStore]. No network calls.
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

  @override
  Future<List<DonorSearchResult>> searchDonors(
    DonorSearchFilters filters, {
    required String viewerId,
  }) async {
    await Future.delayed(delay);

    final nameQuery = filters.name.trim().toLowerCase();
    final results = <DonorSearchResult>[];

    for (final profile in _store.donorProfilesByUserId.values) {
      // Skip anyone who doesn't match. `continue` jumps to the next donor.
      if (profile.userId == viewerId) continue;
      if (!canDonateTo(profile.bloodGroup, filters.bloodGroup)) continue;
      if (filters.district != null && profile.district != filters.district) {
        continue;
      }

      final status = currentStatus(
        profile.status,
        profile.lastDonationDate,
        profile.gender,
        _store.today,
      );
      if (status == DonorStatus.notAvailable) continue; // Red is hidden.
      if (filters.onlyAvailable && status != DonorStatus.available) continue;

      final user = _store.userById(profile.userId);
      if (user == null) continue;
      if (!user.name.toLowerCase().contains(nameQuery)) continue;

      results.add(
        DonorSearchResult(
          donorId: profile.userId,
          name: user.name,
          bloodGroup: profile.bloodGroup,
          district: profile.district,
          area: profile.area,
          gender: profile.gender,
          status: status,
          daysUntilAvailable: daysUntilEligible(
            profile.lastDonationDate,
            profile.gender,
            _store.today,
          ),
          isExactMatch: profile.bloodGroup == filters.bloodGroup,
        ),
      );
    }

    return sortSearchResults(results, preferredArea: filters.area);
  }

  @override
  Future<String?> getDonorPhone(
    String donorId, {
    required String viewerId,
  }) async {
    await Future.delayed(delay);

    // The same checks the Supabase RLS rule will make.
    if (!_store.hasOpenRequest(viewerId)) return null;
    final profile = _store.donorProfilesByUserId[donorId];
    if (profile == null) return null;
    final status = currentStatus(
      profile.status,
      profile.lastDonationDate,
      profile.gender,
      _store.today,
    );
    if (status == DonorStatus.notAvailable) return null;
    return _store.userById(donorId)?.phone;
  }
}
