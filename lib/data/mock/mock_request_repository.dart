import '../../models/blood_request.dart';
import '../../models/enums.dart';
import '../../models/new_blood_request.dart';
import '../../utils/emergency_rules.dart';
import '../../utils/request_rules.dart';
import '../repositories/request_repository.dart';
import 'mock_store.dart';

/// Posts, reads and closes blood requests in a [MockStore]. No network
/// calls.
class MockRequestRepository implements RequestRepository {
  MockRequestRepository(
    this._store, {
    this.delay = const Duration(milliseconds: 400),
  });

  final MockStore _store;

  /// Pretend server delay. Tests pass Duration.zero.
  final Duration delay;

  @override
  Future<List<BloodRequest>> getOpenRequests(String userId) async {
    await Future.delayed(delay);
    return _newestFirst(_store.liveRequestsOf(userId));
  }

  @override
  Future<List<BloodRequest>> getMyRequests(String userId) async {
    await Future.delayed(delay);
    final requests = _store.requestsById.values
        .where((request) => request.ownerId == userId)
        .toList();
    return _newestFirst(requests);
  }

  @override
  Future<BloodRequest?> getRequest(String requestId) async {
    await Future.delayed(delay);
    return _store.requestsById[requestId];
  }

  @override
  Future<List<BloodRequest>> getDistrictOpenRequests(
    String district, {
    required String viewerId,
  }) async {
    await Future.delayed(delay);
    final requests = _store.requestsById.values
        .where(
          (request) =>
              request.district == district &&
              request.ownerId != viewerId &&
              isLive(request, _store.now),
        )
        .toList();
    return requests..sort((a, b) => a.requiredDate.compareTo(b.requiredDate));
  }

  @override
  Future<String?> getSeekerPhone(
    String requestId, {
    required String viewerId,
  }) async {
    await Future.delayed(delay);
    // The same check the Supabase RLS rule will make: donors only.
    if (!_store.donorProfilesByUserId.containsKey(viewerId)) return null;
    return _store.requestsById[requestId]?.contactPhone;
  }

  @override
  Future<DateTime?> getLastEmergencyAlert(String userId) async {
    await Future.delayed(delay);
    return _store.lastEmergencyAlertByUserId[userId];
  }

  @override
  Future<DateTime> sendEmergencyAlert(
    String requestId, {
    required String userId,
  }) async {
    await Future.delayed(delay);

    final request = _store.requestsById[requestId];
    if (request == null || request.ownerId != userId) {
      throw const RequestException(
        'Only the person who posted a request can send an Emergency Alert.',
      );
    }
    if (!isLive(request, _store.now)) {
      throw const RequestException('This request is already closed.');
    }
    // The server-side 15-day limit, so it holds even if the button is
    // somehow pressed while disabled.
    final daysLeft = daysUntilEmergencyAllowed(
      _store.lastEmergencyAlertByUserId[userId],
      _store.now,
    );
    if (daysLeft > 0) {
      throw RequestException(
        'You can send another Emergency Alert in '
        '${daysLeft == 1 ? '1 day' : '$daysLeft days'}.',
      );
    }

    // A real version would notify every donor in request.district with
    // alerts ON here (a Supabase Edge Function + Firebase Cloud Messaging).
    final sentAt = _store.now;
    _store.lastEmergencyAlertByUserId[userId] = sentAt;
    return sentAt;
  }

  @override
  Future<BloodRequest> createRequest(NewBloodRequest draft) async {
    await Future.delayed(delay);

    // The same two checks the Supabase database will make, so the rules
    // hold even if a screen forgets to check first.
    if (_store.liveRequestsOf(draft.ownerId).length >= maxOpenRequests) {
      throw const RequestException(openRequestLimitMessage);
    }
    final dateError = requiredDateError(draft.requiredDate, _store.now);
    if (dateError != null) throw RequestException(dateError);

    final request = BloodRequest(
      id: _store.createRequestId(),
      ownerId: draft.ownerId,
      patientName: draft.patientName,
      bloodGroup: draft.bloodGroup,
      unitsNeeded: draft.unitsNeeded,
      hospital: draft.hospital,
      district: draft.district,
      requiredDate: draft.requiredDate,
      contactPhone: draft.contactPhone,
      notes: draft.notes,
      createdAt: _store.now,
      // Live straight away: no approval step.
      status: RequestStatus.open,
    );
    _store.requestsById[request.id] = request;
    return request;
  }

  @override
  Future<BloodRequest> closeRequest(
    String requestId, {
    required String userId,
    required RequestStatus status,
  }) async {
    await Future.delayed(delay);

    if (status != RequestStatus.fulfilled &&
        status != RequestStatus.cancelled) {
      throw ArgumentError(
        'A request can only be closed as Fulfilled or '
        'Cancelled, not ${status.label}.',
      );
    }
    final request = _store.requestsById[requestId];
    if (request == null || request.ownerId != userId) {
      throw const RequestException(
        'Only the person who posted a request '
        'can close it.',
      );
    }
    if (!isLive(request, _store.now)) {
      throw const RequestException('This request is already closed.');
    }

    final closed = request.copyWith(status: status);
    _store.requestsById[requestId] = closed;
    _updateResponsesAfterClosing(requestId, status);
    return closed;
  }

  /// What closing a request means for the donors who tapped "I'm
  /// Interested" ("Request closes early" in docs/requirements.md). The
  /// "This request was closed by the seeker" notification is mocked.
  void _updateResponsesAfterClosing(String requestId, RequestStatus status) {
    final now = _store.now;
    final responses = _store.responsesById.values
        .where((response) => response.requestId == requestId)
        .toList();
    for (final response in responses) {
      final updated = status == RequestStatus.cancelled
          // Cancelled: back to their previous status (visible) at once.
          ? response.copyWith(endedEarlyAt: now)
          // Fulfilled: ask "Did you donate?" now, unless already due.
          : response.copyWith(
              askDonatedAt: response.askDonatedAt.isAfter(now)
                  ? now
                  : response.askDonatedAt,
            );
      _store.responsesById[response.id] = updated;
    }
  }

  /// Sorts by the time each request was posted, newest first.
  List<BloodRequest> _newestFirst(List<BloodRequest> requests) {
    return requests..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
