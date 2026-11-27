/// Turns any accepted way of typing a Bangladeshi mobile number into the
/// one format we store: 01XXXXXXXXX (11 digits).
///
/// Accepted input (spaces and dashes are ignored):
///   01712345678
///   +8801712345678
///   8801712345678
///
/// Returns `null` if the input is not a valid Bangladeshi mobile number.
/// The digit after "01" is the operator code and must be 3 to 9.
String? normalizeBangladeshiPhone(String input) {
  // Remove spaces and dashes so "017-1234 5678" works too.
  var digits = input.replaceAll(RegExp(r'[\s-]'), '');

  // Drop the country code. "+88" and "88" both come before the leading 0,
  // so "+8801712345678" becomes "01712345678".
  if (digits.startsWith('+88')) {
    digits = digits.substring(3);
  } else if (digits.startsWith('88') && digits.length == 13) {
    // Only strip a bare "88" when the full number is 13 digits long,
    // so a random 11-digit number starting with 88 is not cut short.
    digits = digits.substring(2);
  }

  final localPattern = RegExp(r'^01[3-9]\d{8}$');
  if (!localPattern.hasMatch(digits)) return null;
  return digits;
}
