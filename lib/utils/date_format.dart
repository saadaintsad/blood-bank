/// Short month names for [formatDate].
const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date as "27 Nov 2026".
///
/// Day-month-year is the order people in Bangladesh use. Writing the month
/// as a word avoids mixing up 03/04 (3 April or 4 March?). The `intl`
/// package can do this too, but we don't need a whole package for one format.
String formatDate(DateTime date) {
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}
