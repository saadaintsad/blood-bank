/// App-wide constant values: names, sizes, spacing and fixed lists.
///
/// Keeping these in one file means a number like "16" has a name
/// (AppSpacing.md) and can be changed everywhere at once.
library;

/// Text that appears in many places.
class AppStrings {
  AppStrings._();

  static const String appName = 'Reddify';
  static const String tagline = 'Every drop finds its way.';
}

/// Contact details shown in the footer.
///
/// PLACEHOLDERS: these are not real yet. Replace them before release.
class AppContact {
  AppContact._();

  static const String phone = '+880 1700-000000';
  static const String email = 'hello@reddify.app';
  static const String location = 'Dhaka, Bangladesh';
}

/// Spacing scale. Use these for padding and gaps instead of random numbers.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner radius values for rounded shapes.
class AppRadius {
  AppRadius._();

  static const double badge = 10;
  static const double field = 16;
  static const double card = 20;
}

/// Fixed sizes used across the app.
class AppSizes {
  AppSizes._();

  /// Smallest comfortable size for anything tappable (Material guideline).
  static const double minTouchTarget = 48;

  /// Height of AppButton. A little taller than 48 so it is easy to hit.
  static const double buttonHeight = 52;

  /// The app is designed for phones. On wider screens (like Chrome on a
  /// laptop) it is shown inside a frame this wide.
  static const double maxPhoneWidth = 430;
}

/// The eight ABO/Rh blood groups.
///
/// We store a plain hyphen ("A-") because it is easy to type and to save in
/// a database later. BloodGroupBadge shows it with a proper minus sign.
const List<String> bloodGroups = [
  'A+',
  'A-',
  'B+',
  'B-',
  'O+',
  'O-',
  'AB+',
  'AB-',
];

/// All 64 districts of Bangladesh, in alphabetical order, using the
/// current official English spellings.
const List<String> bangladeshDistricts = [
  'Bagerhat',
  'Bandarban',
  'Barguna',
  'Barishal',
  'Bhola',
  'Bogura',
  'Brahmanbaria',
  'Chandpur',
  'Chapainawabganj',
  'Chattogram',
  'Chuadanga',
  "Cox's Bazar",
  'Cumilla',
  'Dhaka',
  'Dinajpur',
  'Faridpur',
  'Feni',
  'Gaibandha',
  'Gazipur',
  'Gopalganj',
  'Habiganj',
  'Jamalpur',
  'Jashore',
  'Jhalokathi',
  'Jhenaidah',
  'Joypurhat',
  'Khagrachhari',
  'Khulna',
  'Kishoreganj',
  'Kurigram',
  'Kushtia',
  'Lakshmipur',
  'Lalmonirhat',
  'Madaripur',
  'Magura',
  'Manikganj',
  'Meherpur',
  'Moulvibazar',
  'Munshiganj',
  'Mymensingh',
  'Naogaon',
  'Narail',
  'Narayanganj',
  'Narsingdi',
  'Natore',
  'Netrokona',
  'Nilphamari',
  'Noakhali',
  'Pabna',
  'Panchagarh',
  'Patuakhali',
  'Pirojpur',
  'Rajbari',
  'Rajshahi',
  'Rangamati',
  'Rangpur',
  'Satkhira',
  'Shariatpur',
  'Sherpur',
  'Sirajganj',
  'Sunamganj',
  'Sylhet',
  'Tangail',
  'Thakurgaon',
];
