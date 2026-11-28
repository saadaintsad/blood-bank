import '../../models/blood_request.dart';
import '../repositories/request_repository.dart';
import 'mock_store.dart';

/// Reads blood requests from a [MockStore]. No network calls.
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
    final requests = _store.requestsById.values
        .where((request) => request.ownerId == userId && request.isOpen)
        .toList();
    // Newest required date first.
    requests.sort((a, b) => b.requiredDate.compareTo(a.requiredDate));
    return requests;
  }
}
