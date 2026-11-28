import 'package:flutter/foundation.dart';

import '../data/repositories/request_repository.dart';
import '../models/blood_request.dart';
import '../models/enums.dart';
import '../utils/request_rules.dart' as rules;

/// The state of the My Requests screen: the user's requests and the
/// Mark Fulfilled / Cancel actions.
class MyRequestsProvider extends ChangeNotifier {
  MyRequestsProvider(
    this._repository, {
    required this.userId,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RequestRepository _repository;

  /// The logged-in user whose requests these are.
  final String userId;

  final DateTime Function() _clock;

  List<BloodRequest> _requests = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _closingId;

  /// Newest posted first.
  List<BloodRequest> get requests => _requests;
  bool get isLoading => _isLoading;

  /// Set when loading the list failed.
  String? get errorMessage => _errorMessage;

  /// The id of the request being closed right now, so only its card
  /// shows a spinner.
  String? get closingId => _closingId;

  /// What to show for [request] now, including Expired.
  RequestStatus statusOf(BloodRequest request) =>
      rules.effectiveStatus(request, _clock());

  /// True when [request] can still be marked Fulfilled or Cancelled.
  bool canClose(BloodRequest request) => rules.isLive(request, _clock());

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _requests = await _repository.getMyRequests(userId);
    } catch (_) {
      _requests = const [];
      _errorMessage = 'Could not load your requests. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns null on success, or a message to show in a snackbar.
  Future<String?> markFulfilled(String requestId) =>
      _close(requestId, RequestStatus.fulfilled);

  /// Returns null on success, or a message to show in a snackbar.
  Future<String?> cancel(String requestId) =>
      _close(requestId, RequestStatus.cancelled);

  Future<String?> _close(String requestId, RequestStatus status) async {
    _closingId = requestId;
    notifyListeners();
    try {
      final closed = await _repository.closeRequest(
        requestId,
        userId: userId,
        status: status,
      );
      // Swap the old copy for the closed one, keeping the order.
      _requests = [
        for (final request in _requests)
          request.id == requestId ? closed : request,
      ];
      return null;
    } on RequestException catch (error) {
      return error.message;
    } catch (_) {
      return 'Could not update the request. Please try again.';
    } finally {
      _closingId = null;
      notifyListeners();
    }
  }
}
