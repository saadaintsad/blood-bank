import '../../models/blood_request.dart';
import '../../models/donor.dart';
import '../../models/donor_response.dart';
import '../../models/user.dart';
import '../../utils/request_rules.dart';
import 'sample_donors.dart';
import 'sample_requests.dart';
import 'sample_users.dart';

/// A pretend database that lives in memory while the app runs.
///
/// Every mock repository reads and writes this one object, just as the
/// Supabase repositories will later share one real database. app.dart
/// creates a single MockStore, so an account made on the sign-up screen
/// can log in afterwards. Everything is lost when the app restarts.
class MockStore {
  /// Starts with the sample accounts, donors and requests.
  ///
  /// Sample dates count back from [today] (default: the real today).
  /// Tests pass a fixed date so their results never change.
  ///
  /// [now] is the clock time used for request expiry. It defaults to
  /// [today] when a test fixes [today], otherwise to the real time.
  MockStore({DateTime? today, DateTime? now})
    : today = today ?? DateTime.now(),
      _fixedNow = now ?? today {
    for (final user in [...sampleUsers, ...sampleDonorUsers]) {
      usersByPhone[user.phone] = user;
      passwordsByPhone[user.phone] = samplePassword;
    }
    final profiles = [
      ...sampleAccountDonorProfiles,
      ...sampleDonorProfiles(this.today),
    ];
    for (final profile in profiles) {
      donorProfilesByUserId[profile.userId] = profile;
    }
    for (final request in sampleRequests(this.today)) {
      requestsById[request.id] = request;
    }
    for (final response in sampleResponses(this.now, requestsById)) {
      responsesById[response.id] = response;
    }
  }

  /// The day the mock data treats as "today". Used for working out who is
  /// Yellow and for how many more days.
  final DateTime today;

  DateTime? _fixedNow;

  /// The current time. Read fresh each time in the app, so a request
  /// expires even while the app stays open.
  DateTime get now => _fixedNow ?? DateTime.now();

  /// Fixes the clock at [value]. Tests use it to move time forward, e.g.
  /// to check that a donor's 3-hour window has ended.
  set now(DateTime value) => _fixedNow = value;

  /// Accounts, looked up by their 01XXXXXXXXX number.
  final Map<String, AppUser> usersByPhone = {};

  /// Passwords, looked up by number. A real backend stores only a hash of
  /// each password, never the password itself; this is sample data only.
  final Map<String, String> passwordsByPhone = {};

  /// Donor profiles, looked up by the AppUser id they belong to.
  final Map<String, DonorProfile> donorProfilesByUserId = {};

  /// Blood requests, looked up by their id.
  final Map<String, BloodRequest> requestsById = {};

  /// "I'm Interested" responses, looked up by their id.
  final Map<String, DonorResponse> responsesById = {};

  /// When each user last sent an Emergency Alert, by user id. Users who
  /// never sent one are missing from the map.
  final Map<String, DateTime> lastEmergencyAlertByUserId = {};

  int _nextUserNumber = sampleUsers.length + 1;
  int _nextRequestNumber = 100;
  int _nextResponseNumber = 100;

  /// A new unique id, like 'user-4'.
  String createUserId() => 'user-${_nextUserNumber++}';

  /// A new unique request id, like 'request-100'.
  String createRequestId() => 'request-${_nextRequestNumber++}';

  /// A new unique response id, like 'response-100'.
  String createResponseId() => 'response-${_nextResponseNumber++}';

  /// The account with this [id], or null. Accounts are stored by phone,
  /// so this looks through them all; fine for a few dozen sample users.
  AppUser? userById(String id) {
    for (final user in usersByPhone.values) {
      if (user.id == id) return user;
    }
    return null;
  }

  /// [userId]'s requests that are Open right now. Expired ones don't
  /// count (see isLive in utils/request_rules.dart).
  List<BloodRequest> liveRequestsOf(String userId) {
    return requestsById.values
        .where((request) => request.ownerId == userId && isLive(request, now))
        .toList();
  }

  /// True when [userId] has at least one open blood request.
  bool hasOpenRequest(String userId) => liveRequestsOf(userId).isNotEmpty;
}
