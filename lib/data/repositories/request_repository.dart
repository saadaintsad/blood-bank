import '../../models/blood_request.dart';
import '../../models/enums.dart';
import '../../models/new_blood_request.dart';

/// What the app needs to post, read and close blood requests.
///
/// MockRequestRepository implements it for now; a Supabase version comes
/// later.
abstract class RequestRepository {
  /// [userId]'s requests that are Open right now (not expired), newest
  /// posted first.
  Future<List<BloodRequest>> getOpenRequests(String userId);

  /// All of [userId]'s requests, whatever their status, newest posted
  /// first. Used by My Requests.
  Future<List<BloodRequest>> getMyRequests(String userId);

  /// The request with [requestId], or null if there is none.
  Future<BloodRequest?> getRequest(String requestId);

  /// Requests that are Open right now in [district], for the Open Requests
  /// list. Leaves out [viewerId]'s own requests. Soonest required date
  /// first.
  Future<List<BloodRequest>> getDistrictOpenRequests(
    String district, {
    required String viewerId,
  });

  /// The seeker's contact number on request [requestId], or null when
  /// [viewerId] may not see it. Only donors may ("Seeker's contact phone"
  /// in docs/requirements.md); Supabase will check this with RLS.
  Future<String?> getSeekerPhone(String requestId, {required String viewerId});

  /// When [userId] last sent an Emergency Alert, or null if never.
  Future<DateTime?> getLastEmergencyAlert(String userId);

  /// Sends an Emergency Alert for request [requestId] to every donor in
  /// its district, and returns the time it was sent. Notifications are
  /// mocked for now, so nothing is really sent yet.
  ///
  /// Throws [RequestException] unless [userId] owns the request, it is
  /// still Open, and they have not sent one in the last 15 days. The
  /// server will enforce the 15-day limit too.
  Future<DateTime> sendEmergencyAlert(
    String requestId, {
    required String userId,
  });

  /// Posts a new request. It goes live as Open straight away.
  ///
  /// Throws [RequestException] if the owner already has the maximum number
  /// of open requests, or the required date is in the past. Supabase will
  /// check both in the database too, so the rules hold even if the app is
  /// bypassed.
  Future<BloodRequest> createRequest(NewBloodRequest draft);

  /// Marks request [requestId] Fulfilled or Cancelled and returns it.
  ///
  /// Throws [RequestException] unless [userId] owns it and it is still
  /// Open. [status] must be fulfilled or cancelled.
  ///
  /// Donors who tapped "I'm Interested" are affected too: Cancelled ends
  /// their 3-hour window at once, and Fulfilled makes "Did you donate?"
  /// due straight away.
  Future<BloodRequest> closeRequest(
    String requestId, {
    required String userId,
    required RequestStatus status,
  });
}

/// Thrown when posting or closing a request fails. [message] is safe to
/// show to the user.
class RequestException implements Exception {
  const RequestException(this.message);

  final String message;

  @override
  String toString() => 'RequestException: $message';
}
