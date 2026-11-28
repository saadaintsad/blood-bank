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

/// Formats the time of day as "4:10 PM" (12-hour clock, as people in
/// Bangladesh usually say it). Midnight is 12:00 AM and noon 12:00 PM.
String formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
