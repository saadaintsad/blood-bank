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
