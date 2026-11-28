import '../../models/donor_response.dart';
import '../../models/interested_donor.dart';
import '../../utils/interest_rules.dart';
import '../../utils/request_rules.dart';
import '../repositories/interest_repository.dart';
import 'mock_store.dart';

/// Records "I'm Interested" responses in a [MockStore]. No network calls.
class MockInterestRepository implements InterestRepository {
  MockInterestRepository(
    this._store, {
    this.delay = const Duration(milliseconds: 400),
  });

  final MockStore _store;

  /// Pretend server delay. Tests pass Duration.zero.
  final Duration delay;

  @override
  Future<DonorResponse> expressInterest(
    String requestId, {
    required String donorId,
  }) async {
    await Future.delayed(delay);
    final now = _store.now;

    // The same checks the server will make, in order.
    final request = _store.requestsById[requestId];
    if (request == null || !isLive(request, now)) {
      throw const InterestException('This request is no longer open.');
    }
    if (request.ownerId == donorId) {
      throw const InterestException("You can't respond to your own request.");
    }
    final profile = _store.donorProfilesByUserId[donorId];
    if (profile == null) {
      throw const InterestException('Only donors can respond to requests.');
    }
    if (_findResponse(requestId, donorId) != null) {
      throw const InterestException(
        'You have already responded to this request.',
      );
    }
    final reason = interestBlockReason(
      profile: profile,
      patientGroup: request.bloodGroup,
      activeResponse: activeResponseOf(
        _store.responsesById.values,
        donorId,
        now,
      ),
      now: now,
    );
    if (reason != null) throw InterestException(reason);

    final response = DonorResponse(
      id: _store.createResponseId(),
      requestId: requestId,
      donorId: donorId,
      tappedAt: now,
      askDonatedAt: donateQuestionAt(request.requiredDate, now),
    );
    _store.responsesById[response.id] = response;
    return response;
  }

  @override
  Future<DonorResponse?> getActiveResponse(String donorId) async {
    await Future.delayed(delay);
    return activeResponseOf(_store.responsesById.values, donorId, _store.now);
  }

  @override
  Future<DonorResponse?> getResponse(
    String requestId, {
    required String donorId,
  }) async {
    await Future.delayed(delay);
    return _findResponse(requestId, donorId);
  }

  @override
  Future<List<InterestedDonor>> getInterestedDonors(
    String requestId, {
    required String viewerId,
  }) async {
    await Future.delayed(delay);

    // Only the seeker who posted the request sees who responded.
    final request = _store.requestsById[requestId];
    if (request == null || request.ownerId != viewerId) return const [];

    final responses =
        _store.responsesById.values
            .where((response) => response.requestId == requestId)
            .toList()
          ..sort((a, b) => a.tappedAt.compareTo(b.tappedAt));

    final donors = <InterestedDonor>[];
    for (final response in responses) {
      final user = _store.userById(response.donorId);
      final profile = _store.donorProfilesByUserId[response.donorId];
      if (user == null || profile == null) continue;
      donors.add(
        InterestedDonor(
          donorId: user.id,
          name: user.name,
          bloodGroup: profile.bloodGroup,
          area: profile.area,
          phone: user.phone,
          tappedAt: response.tappedAt,
        ),
      );
    }
    return donors;
  }

  /// [donorId]'s response to [requestId], or null.
  DonorResponse? _findResponse(String requestId, String donorId) {
    for (final response in _store.responsesById.values) {
      if (response.requestId == requestId && response.donorId == donorId) {
        return response;
      }
    }
    return null;
  }
}
