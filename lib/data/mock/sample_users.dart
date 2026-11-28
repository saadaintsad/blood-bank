import '../../models/donor.dart';
import '../../models/enums.dart';
import '../../models/user.dart';

// SAMPLE DATA: fictional people and numbers for the UI-only phase.
// Use these to log in while testing:
//
//   01700000001  /  demo1234   (Sample Seeker)
//   01700000002  /  demo1234   (Sample Donor)
//   01700000003  /  demo1234   (Sample Requester, has an open request)
//
// Accounts you create in the app are added to MockStore while the app is
// running, and disappear when you reload the page.

/// The password every sample account uses.
const String samplePassword = 'demo1234';

/// Accounts the mock login accepts.
const List<AppUser> sampleUsers = [
  AppUser(id: 'user-1', name: 'Sample Seeker', phone: '01700000001'),
  AppUser(
    id: 'user-2',
    name: 'Sample Donor',
    phone: '01700000002',
    isDonor: true,
  ),
  // Owns the open request in sample_requests.dart, so Find Blood shows
  // donors' phone numbers to this account.
  AppUser(id: 'user-3', name: 'Sample Requester', phone: '01700000003'),
];

/// The donor profile of Sample Donor. Fictional details.
final List<DonorProfile> sampleAccountDonorProfiles = [
  DonorProfile(
    userId: 'user-2',
    bloodGroup: 'O+',
    gender: Gender.male,
    dateOfBirth: DateTime(2000, 1, 1),
    district: 'Dhaka',
    area: 'Badda',
    status: DonorStatus.available,
  ),
];
