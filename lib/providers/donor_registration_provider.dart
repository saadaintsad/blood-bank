import 'package:flutter/foundation.dart';

import '../models/donor.dart';
import '../models/enums.dart';
import '../models/user.dart';
import '../utils/eligibility.dart' as eligibility;
import '../utils/phone_number.dart';
import '../utils/validators.dart';
import 'auth_provider.dart';

/// The steps of donor registration, in order.
enum RegistrationStep {
  account('Your account'),
  aboutYou('About you'),
  location('Location'),
  donation('Donation and alerts'),
  consent('Consent');

  const RegistrationStep(this.title);

  /// Shown in the step header, e.g. "Step 2 of 5 · About you".
  final String title;
}

/// Remembers what the user has entered in the donor registration form and
/// which step they are on.
///
/// The screen creates one of these when it opens, and it is thrown away
/// when the screen closes. Keeping the answers here (not inside each step's
/// widget) means they survive moving back and forth between steps.
class DonorRegistrationProvider extends ChangeNotifier {
  DonorRegistrationProvider({this.existingUser, DateTime Function()? clock})
      // DateTime.now is passed as a function, not called, so `today` is
      // always fresh. Tests pass their own clock to fix the date.
      : _clock = clock ?? DateTime.now;

  /// The logged-in seeker becoming a donor, or null for a brand-new user.
  final AppUser? existingUser;

  final DateTime Function() _clock;

  DateTime get today => eligibility.dateOnly(_clock());

  /// New users must create an account first; existing users skip that.
  bool get isNewAccount => existingUser == null;

  // ---- Answers --------------------------------------------------------
  // Text typed into text fields is stored in plain public fields. The
  // field itself already shows the text, so nothing else needs to redraw
  // on every key press.

  String name = '';
  String phone = '';
  String password = '';
  String extraLocationDetails = '';

  // Answers that change what is drawn (pickers, switches) are private,
  // and each has a setter method that calls notifyListeners() so the
  // screen redraws.

  String? _bloodGroup;
  Gender? _gender;
  DateTime? _dateOfBirth;
  String? _district;
  String _area = '';
  DateTime? _lastDonationDate;
  bool _neverDonated = false;
  bool _receiveAlerts = true;
  bool _consentGiven = false;

  String? get bloodGroup => _bloodGroup;
  Gender? get gender => _gender;
  DateTime? get dateOfBirth => _dateOfBirth;
  String? get district => _district;
  String get area => _area;
  DateTime? get lastDonationDate => _lastDonationDate;
  bool get neverDonated => _neverDonated;
  bool get receiveAlerts => _receiveAlerts;
  bool get consentGiven => _consentGiven;

  void setBloodGroup(String value) => _update(() => _bloodGroup = value);
  void setGender(Gender value) => _update(() => _gender = value);
  void setDateOfBirth(DateTime value) => _update(() => _dateOfBirth = value);

  /// Changing the district clears the area, because areas belong to one
  /// district.
  void setDistrict(String value) {
    if (value == _district) return;
    _update(() {
      _district = value;
      _area = '';
    });
  }

  void setArea(String value) => _update(() => _area = value);

  void setLastDonationDate(DateTime value) => _update(() {
        _lastDonationDate = value;
        _neverDonated = false;
      });

  /// Ticking "never donated" clears any date picked before.
  void setNeverDonated(bool value) => _update(() {
        _neverDonated = value;
        if (value) _lastDonationDate = null;
      });

  void setReceiveAlerts(bool value) => _update(() => _receiveAlerts = value);
  void setConsentGiven(bool value) => _update(() => _consentGiven = value);

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }

  // ---- Steps -----------------------------------------------------------

  List<RegistrationStep> get steps => isNewAccount
      ? RegistrationStep.values
      : RegistrationStep.values
          .where((step) => step != RegistrationStep.account)
          .toList();

  int _stepIndex = 0;

  RegistrationStep get currentStep => steps[_stepIndex];
  int get stepNumber => _stepIndex + 1;
  int get stepCount => steps.length;
  bool get isFirstStep => _stepIndex == 0;
  bool get isLastStep => _stepIndex == steps.length - 1;

  /// Becomes true after the user presses Next on a step with missing
  /// answers. Pickers only show their error text after that, so a fresh
  /// step doesn't greet the user with red messages.
  bool _showErrors = false;
  bool get showErrors => _showErrors;

  bool _isAgeBlocked = false;

  /// True when the date of birth is outside 18–60. The screen then shows
  /// the "you can still find blood" panel instead of the form.
  bool get isAgeBlocked => _isAgeBlocked;

  /// Goes to the next step if the current one is complete. Returns true if
  /// it moved.
  bool next() {
    if (!isCurrentStepValid) {
      _update(() => _showErrors = true);
      return false;
    }
    if (currentStep == RegistrationStep.aboutYou && !isAgeAllowed) {
      _update(() => _isAgeBlocked = true);
      return false;
    }
    if (isLastStep) return false;
    _update(() {
      _stepIndex++;
      _showErrors = false;
    });
    return true;
  }

  /// Goes back one step. Returns false on the first step (nothing to do).
  bool back() {
    if (isFirstStep) return false;
    _update(() {
      _stepIndex--;
      _showErrors = false;
    });
    return true;
  }

  /// Closes the age panel so the user can fix a mistyped date of birth.
  void dismissAgeBlock() => _update(() => _isAgeBlocked = false);

  // ---- Checks ----------------------------------------------------------

  /// Age in whole years, or null before a date of birth is picked.
  int? get age =>
      _dateOfBirth == null ? null : eligibility.ageOn(_dateOfBirth!, today);

  bool get isAgeAllowed => age != null && eligibility.isEligibleDonorAge(age!);

  // Error messages for the pickers. Text fields use Validators directly.
  String? get bloodGroupError =>
      _bloodGroup == null ? 'Choose your blood group' : null;
  String? get genderError => _gender == null ? 'Choose your gender' : null;
  String? get dateOfBirthError =>
      _dateOfBirth == null ? 'Pick your date of birth' : null;
  String? get districtError =>
      _district == null ? 'Choose your district' : null;
  String? get areaError => _area.trim().isEmpty ? 'Enter your area' : null;
  String? get lastDonationError => _lastDonationDate == null && !_neverDonated
      ? 'Pick a date, or tick "I have never donated"'
      : null;

  bool get isCurrentStepValid {
    return switch (currentStep) {
      RegistrationStep.account => Validators.requiredField(name) == null &&
          Validators.phone(phone) == null &&
          Validators.password(password) == null,
      RegistrationStep.aboutYou => bloodGroupError == null &&
          genderError == null &&
          dateOfBirthError == null,
      RegistrationStep.location => districtError == null && areaError == null,
      RegistrationStep.donation => lastDonationError == null,
      RegistrationStep.consent => _consentGiven,
    };
  }

  /// Green or Yellow, from the last donation date. Shown as a preview on
  /// the donation step. Before a gender is chosen we assume the longer gap.
  DonorStatus get startingStatus => eligibility.startingStatus(
        _lastDonationDate,
        _gender ?? Gender.other,
        today,
      );

  /// Days until a Yellow donor turns Green (0 when already Green).
  int get daysUntilAvailable => eligibility.daysUntilEligible(
        _lastDonationDate,
        _gender ?? Gender.other,
        today,
      );

  /// Text for the status chip: "Available", or "Available in 44 days".
  String get startingStatusLabel {
    if (startingStatus == DonorStatus.available) {
      return DonorStatus.available.label;
    }
    final days = daysUntilAvailable;
    return 'Available in $days ${days == 1 ? 'day' : 'days'}';
  }

  /// Turns the answers into a profile. Call only after every step passed.
  DonorProfile buildProfile(String userId) {
    final extra = extraLocationDetails.trim();
    return DonorProfile(
      userId: userId,
      bloodGroup: _bloodGroup!,
      gender: _gender!,
      dateOfBirth: _dateOfBirth!,
      district: _district!,
      area: _area.trim(),
      extraLocationDetails: extra.isEmpty ? null : extra,
      lastDonationDate: _lastDonationDate,
      receiveAlerts: _receiveAlerts,
      status: startingStatus,
    );
  }

  // ---- Saving ----------------------------------------------------------

  /// Creates the account (new users only) and saves the donor profile.
  /// Returns true on success; on failure the message is in
  /// [AuthProvider.errorMessage].
  Future<bool> submit(AuthProvider auth) async {
    if (isNewAccount && !auth.isLoggedIn) {
      final signedUp = await _signUp(auth);
      if (!signedUp) {
        // Most likely the number is already registered, which is fixed on
        // the account step, so take the user back there.
        _update(() => _stepIndex = 0);
        return false;
      }
    }
    return auth.registerDonor(buildProfile(auth.currentUser!.id));
  }

  /// For a new user outside the age range: make a seeker account from the
  /// account step's details, so they can still find blood.
  Future<bool> signUpAsSeeker(AuthProvider auth) => _signUp(auth);

  Future<bool> _signUp(AuthProvider auth) {
    return auth.signUp(
      name: name.trim(),
      // The account step already checked the number, so this is never null.
      phone: normalizeBangladeshiPhone(phone)!,
      password: password,
    );
  }
}
