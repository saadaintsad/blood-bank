/// Small fixed sets of values used by the models.
library;

/// A donor's availability, from docs/requirements.md.
///
/// This is an "enhanced enum": each value carries its own label, so the
/// text shown to users is defined in one place.
enum DonorStatus {
  /// Green. Can donate now and appears in search.
  available('Available'),

  /// Yellow. Donated recently and is waiting out the gap between
  /// donations. Screens usually show "Available in X days" instead.
  recentlyDonated('Recently donated'),

  /// Red. Set by the donor (for example during exams). Hidden from search.
  notAvailable('Not available');

  const DonorStatus(this.label);

  /// Default text shown next to the status colour.
  final String label;
}

/// Where a blood request is in its life: Open → Fulfilled, or
/// Open → Cancelled (see "Blood requests" in docs/requirements.md).
enum RequestStatus {
  open('Open'),
  fulfilled('Fulfilled'),
  cancelled('Cancelled'),

  /// Shown, never saved by the app: an Open request 48 hours past the end
  /// of its required date counts as closed (utils/request_rules.dart).
  /// The Supabase version can set it on a schedule later.
  expired('Expired');

  const RequestStatus(this.label);

  final String label;
}

/// A donor's gender. It decides the waiting period between donations
/// (see utils/eligibility.dart), so registration asks for it.
enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.label);

  /// Text shown on the gender buttons.
  final String label;
}
