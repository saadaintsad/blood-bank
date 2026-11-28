import '../../models/blood_request.dart';

/// What the app needs to read blood requests.
///
/// MockRequestRepository implements it for now. Post Request will add a
/// method to create requests.
abstract class RequestRepository {
  /// [userId]'s requests that are still Open, newest first.
  Future<List<BloodRequest>> getOpenRequests(String userId);
}
