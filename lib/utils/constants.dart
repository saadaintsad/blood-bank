/// App-wide constant values: names, contact details and fixed lists.
///
/// Spacing, corner radius and sizes are design values, so they live in
/// theme/spacing.dart instead.
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
