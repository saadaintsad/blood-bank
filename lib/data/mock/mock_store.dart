import '../../models/blood_request.dart';
import '../../models/donor.dart';
import '../../models/user.dart';
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
  MockStore({DateTime? today}) : today = today ?? DateTime.now() {
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
  }

  /// The day the mock data treats as "today". Used for working out who is
  /// Yellow and for how many more days.
  final DateTime today;

  /// Accounts, looked up by their 01XXXXXXXXX number.
  final Map<String, AppUser> usersByPhone = {};

  /// Passwords, looked up by number. A real backend stores only a hash of
  /// each password, never the password itself; this is sample data only.
  final Map<String, String> passwordsByPhone = {};

  /// Donor profiles, looked up by the AppUser id they belong to.
  final Map<String, DonorProfile> donorProfilesByUserId = {};

  /// Blood requests, looked up by their id.
  final Map<String, BloodRequest> requestsById = {};

  int _nextUserNumber = sampleUsers.length + 1;

  /// A new unique id, like 'user-4'.
  String createUserId() => 'user-${_nextUserNumber++}';

  /// The account with this [id], or null. Accounts are stored by phone,
  /// so this looks through them all; fine for a few dozen sample users.
  AppUser? userById(String id) {
    for (final user in usersByPhone.values) {
      if (user.id == id) return user;
    }
    return null;
  }

  /// True when [userId] has at least one open blood request.
  bool hasOpenRequest(String userId) {
    return requestsById.values
        .any((request) => request.ownerId == userId && request.isOpen);
  }
}
