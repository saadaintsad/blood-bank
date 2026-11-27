import '../../models/donor.dart';
import '../../models/user.dart';
import 'sample_users.dart';

/// A pretend database that lives in memory while the app runs.
///
/// Both mock repositories read and write this one object, just as the
/// Supabase repositories will later share one real database. app.dart
/// creates a single MockStore, so an account made on the sign-up screen
/// can log in afterwards. Everything is lost when the app restarts.
class MockStore {
  /// Starts with the sample accounts from sample_users.dart.
  MockStore() {
    for (final user in sampleUsers) {
      usersByPhone[user.phone] = user;
      passwordsByPhone[user.phone] = samplePassword;
    }
    for (final profile in sampleDonorProfiles) {
      donorProfilesByUserId[profile.userId] = profile;
    }
  }

  /// Accounts, looked up by their 01XXXXXXXXX number.
  final Map<String, AppUser> usersByPhone = {};

  /// Passwords, looked up by number. A real backend stores only a hash of
  /// each password, never the password itself; this is sample data only.
  final Map<String, String> passwordsByPhone = {};

  /// Donor profiles, looked up by the AppUser id they belong to.
  final Map<String, DonorProfile> donorProfilesByUserId = {};

  int _nextUserNumber = sampleUsers.length + 1;

  /// A new unique id, like 'user-3'.
  String createUserId() => 'user-${_nextUserNumber++}';
}
