import '../../models/user.dart';

// SAMPLE DATA: fictional people and numbers for the UI-only phase.
// Use these to log in while testing:
//
//   01700000001  /  demo1234   (Sample Seeker)
//   01700000002  /  demo1234   (Sample Donor)

/// The password every sample account uses.
const String samplePassword = 'demo1234';

/// Accounts the mock login accepts.
const List<AppUser> sampleUsers = [
  AppUser(id: 'user-1', name: 'Sample Seeker', phone: '01700000001'),
  AppUser(id: 'user-2', name: 'Sample Donor', phone: '01700000002'),
];
