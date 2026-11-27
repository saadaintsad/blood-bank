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
  });

  final String id;
  final String name;

  /// Always stored as 01XXXXXXXXX (see utils/phone_number.dart).
  final String phone;
}
