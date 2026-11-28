import '../../models/donor.dart';
import '../../models/enums.dart';
import '../../models/user.dart';
import '../../utils/eligibility.dart';

// SAMPLE DATA: 15 fictional donors in Dhaka for testing Find Blood.
// The first five are the people from docs/walkthrough.md, so Scene 4 can
// be replayed: search B+ in Dhaka and you should see Karim and Mahin,
// then Tanvir (Yellow), then the Compatible donors.
//
// Numbers 01700000101 to 01700000115 are made up. Every sample donor can
// also log in with the sample password (demo1234).

/// The donors' accounts.
const List<AppUser> sampleDonorUsers = [
  AppUser(id: 'donor-1', name: 'Karim', phone: '01700000101', isDonor: true),
  AppUser(id: 'donor-2', name: 'Tanvir', phone: '01700000102', isDonor: true),
  AppUser(id: 'donor-3', name: 'Nusrat', phone: '01700000103', isDonor: true),
  AppUser(id: 'donor-4', name: 'Mitu', phone: '01700000104', isDonor: true),
  AppUser(id: 'donor-5', name: 'Arif', phone: '01700000105', isDonor: true),
  AppUser(id: 'donor-6', name: 'Farhana', phone: '01700000106', isDonor: true),
  AppUser(id: 'donor-7', name: 'Rakib', phone: '01700000107', isDonor: true),
  AppUser(id: 'donor-8', name: 'Sadia', phone: '01700000108', isDonor: true),
  AppUser(id: 'donor-9', name: 'Imran', phone: '01700000109', isDonor: true),
  AppUser(id: 'donor-10', name: 'Joya', phone: '01700000110', isDonor: true),
  AppUser(id: 'donor-11', name: 'Mahin', phone: '01700000111', isDonor: true),
  AppUser(id: 'donor-12', name: 'Tania', phone: '01700000112', isDonor: true),
  AppUser(id: 'donor-13', name: 'Shuvo', phone: '01700000113', isDonor: true),
  AppUser(id: 'donor-14', name: 'Riya', phone: '01700000114', isDonor: true),
  AppUser(id: 'donor-15', name: 'Nayeem', phone: '01700000115', isDonor: true),
];

/// The donors' profiles.
///
/// Donation dates count back from [today], so a donor who "gave 40 days
/// ago" always shows the same "Available in X days", whatever day the app
/// is opened.
List<DonorProfile> sampleDonorProfiles(DateTime today) {
  DateTime daysAgo(int days) =>
      DateTime(today.year, today.month, today.day - days);

  // A small helper so each donor below fits on a few lines. The status is
  // worked out from the last donation, like registration does, unless the
  // donor chose Red ([isOnBreak]).
  DonorProfile donor(
    String userId,
    String bloodGroup,
    Gender gender,
    String area, {
    int? donatedDaysAgo,
    bool isOnBreak = false,
  }) {
    final lastDonation = donatedDaysAgo == null ? null : daysAgo(donatedDaysAgo);
    return DonorProfile(
      userId: userId,
      bloodGroup: bloodGroup,
      gender: gender,
      dateOfBirth: DateTime(1998, 3, 10),
      district: 'Dhaka',
      area: area,
      lastDonationDate: lastDonation,
      status: isOnBreak
          ? DonorStatus.notAvailable
          : startingStatus(lastDonation, gender, today),
    );
  }

  return [
    // From the walkthrough.
    donor('donor-1', 'B+', Gender.male, 'Uttara', donatedDaysAgo: 200),
    donor('donor-2', 'B+', Gender.male, 'Bashundhara', donatedDaysAgo: 40),
    donor('donor-3', 'O+', Gender.female, 'Badda', donatedDaysAgo: 240),
    donor('donor-4', 'B-', Gender.female, 'Rampura'),
    donor('donor-5', 'A+', Gender.male, 'Mirpur', donatedDaysAgo: 150),
    // Others, to cover every group, gender and status.
    donor('donor-6', 'A-', Gender.female, 'Dhanmondi', donatedDaysAgo: 60),
    donor('donor-7', 'O-', Gender.male, 'Mohammadpur'),
    donor('donor-8', 'AB+', Gender.female, 'Gulshan', donatedDaysAgo: 300),
    donor('donor-9', 'AB-', Gender.male, 'Bashundhara', donatedDaysAgo: 20),
    donor('donor-10', 'O+', Gender.other, 'Khilgaon', donatedDaysAgo: 100),
    donor('donor-11', 'B+', Gender.male, 'Bashundhara', donatedDaysAgo: 100),
    // Red (on a break): never shown in search.
    donor('donor-12', 'A+', Gender.female, 'Uttara', isOnBreak: true),
    donor('donor-13', 'O+', Gender.male, 'Badda', isOnBreak: true),
    donor('donor-14', 'B-', Gender.female, 'Mirpur', donatedDaysAgo: 90),
    donor('donor-15', 'O-', Gender.male, 'Dhanmondi', donatedDaysAgo: 50),
  ];
}
