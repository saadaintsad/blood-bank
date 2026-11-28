/// Opens the phone's dialer or SMS app for a donor's number.
library;

import 'package:url_launcher/url_launcher.dart';

/// Opens the dialer with [phone] filled in. The user still presses call,
/// so nothing happens by accident. Returns false if no app could open it
/// (for example in a desktop browser).
Future<bool> callNumber(String phone) {
  // A "tel:" link is the standard way to ask the phone to dial a number.
  return _open(Uri(scheme: 'tel', path: phone));
}

/// Opens the SMS app with a new message to [phone]. Returns false if no
/// app could open it.
Future<bool> sendSms(String phone) {
  return _open(Uri(scheme: 'sms', path: phone));
}

Future<bool> _open(Uri uri) async {
  try {
    return await launchUrl(uri);
  } catch (_) {
    // launchUrl throws when nothing can handle the link.
    return false;
  }
}
