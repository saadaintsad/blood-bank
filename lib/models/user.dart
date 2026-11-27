/// A Reddify account. Everyone has one; donors also get a donor profile
/// (added in a later task).
///
/// Called AppUser instead of User so it never clashes with Supabase's own
/// `User` class later.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.isDonor = false,
  });

  final String id;
  final String name;

  /// Always stored as 01XXXXXXXXX (see utils/phone_number.dart).
  final String phone;

  /// True once the user has registered as a donor. Home hides
  /// "Register as Donor" for donors. The full donor profile comes later.
  final bool isDonor;
}
