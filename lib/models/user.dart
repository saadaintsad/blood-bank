/// A Reddify account. Everyone has one; donors also get a DonorProfile
/// (models/donor.dart) linked by [id].
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
  /// "Register as Donor" for donors.
  final bool isDonor;

  /// Returns a copy with some fields changed.
  ///
  /// The fields are `final`, so we never change a user in place. Instead we
  /// make a new one, e.g. `user.copyWith(isDonor: true)` after registering.
  AppUser copyWith({String? name, bool? isDonor}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      phone: phone,
      isDonor: isDonor ?? this.isDonor,
    );
  }
}
