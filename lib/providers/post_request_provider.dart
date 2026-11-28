import 'package:flutter/foundation.dart';

import '../data/repositories/request_repository.dart';
import '../models/blood_request.dart';
import '../models/new_blood_request.dart';
import '../models/user.dart';
import '../utils/eligibility.dart' show dateOnly;
import '../utils/phone_number.dart';
import '../utils/request_rules.dart';

/// The state of the Post Request form.
///
/// app.dart creates one each time the screen opens and calls [load], which
/// checks the 3-open-requests limit before the user types anything.
class PostRequestProvider extends ChangeNotifier {
  PostRequestProvider(
    this._repository, {
    required this.owner,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       // The user's own number is the usual contact, so start with it.
       contactPhone = owner.phone;

  final RequestRepository _repository;

  /// The logged-in user posting the request.
  final AppUser owner;

  final DateTime Function() _clock;

  DateTime get today => dateOnly(_clock());

  // ---- Answers --------------------------------------------------------
  // Text fields: plain fields, because the text box already shows what
  // was typed (same pattern as DonorRegistrationProvider).

  String patientName = '';
  String hospital = '';
  String contactPhone;
  String notes = '';

  // Pickers: private with setters that redraw the screen.

  String? _bloodGroup;
  int _units = minUnits;
  String? _district;
  DateTime? _requiredDate;

  String? get bloodGroup => _bloodGroup;
  int get units => _units;
  String? get district => _district;
  DateTime? get requiredDate => _requiredDate;

  void setBloodGroup(String group) {
    _bloodGroup = group;
    notifyListeners();
  }

  /// Changes the units by [change] (+1 or -1), kept between [minUnits]
  /// and [maxUnits].
  void changeUnits(int change) {
    _units = (_units + change).clamp(minUnits, maxUnits);
    notifyListeners();
  }

  void setDistrict(String district) {
    _district = district;
    notifyListeners();
  }

  void setRequiredDate(DateTime date) {
    _requiredDate = date;
    notifyListeners();
  }

  // ---- Errors for the pickers ----------------------------------------
  // Text fields check themselves with `validator:`; pickers can't, so
  // their messages come from here, shown after the first submit.

  bool _showErrors = false;
  bool get showErrors => _showErrors;

  String? get bloodGroupError =>
      _bloodGroup == null ? "Choose the patient's blood group" : null;

  String? get districtError =>
      _district == null ? "Choose the hospital's district" : null;

  String? get requiredDateErrorText => requiredDateError(_requiredDate, today);

  bool get _pickersValid =>
      bloodGroupError == null &&
      districtError == null &&
      requiredDateErrorText == null;

  // ---- Loading and submitting ------------------------------------------

  bool _isChecking = false;
  bool _limitReached = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  /// True while [load] checks how many requests are open.
  bool get isChecking => _isChecking;

  /// True when the user already has [maxOpenRequests] open requests. The
  /// screen then explains the limit instead of showing the form.
  bool get limitReached => _limitReached;

  bool get isSubmitting => _isSubmitting;

  /// Message from the last failed submit, or null.
  String? get errorMessage => _errorMessage;

  /// Call once when the screen opens.
  Future<void> load() async {
    _isChecking = true;
    notifyListeners();
    try {
      final open = await _repository.getOpenRequests(owner.id);
      _limitReached = open.length >= maxOpenRequests;
    } catch (_) {
      // Not fatal: show the form. The repository checks the limit again
      // when the request is posted.
      _limitReached = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Posts the request. Returns it on success, or null if something is
  /// missing or the repository refused it (see [errorMessage]).
  ///
  /// [textFieldsValid] is the result of the Form's validate(), which
  /// checks the name, hospital and phone boxes.
  Future<BloodRequest?> submit({required bool textFieldsValid}) async {
    _showErrors = true;
    _errorMessage = null;
    if (!textFieldsValid || !_pickersValid) {
      notifyListeners(); // Show the picker errors.
      return null;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final trimmedNotes = notes.trim();
      return await _repository.createRequest(
        NewBloodRequest(
          ownerId: owner.id,
          patientName: patientName.trim(),
          bloodGroup: _bloodGroup!,
          unitsNeeded: _units,
          hospital: hospital.trim(),
          district: _district!,
          requiredDate: _requiredDate!,
          // Always save 01XXXXXXXXX, even if +880… was typed. The form's
          // phone validator has already made sure this isn't null.
          contactPhone: normalizeBangladeshiPhone(contactPhone)!,
          notes: trimmedNotes.isEmpty ? null : trimmedNotes,
        ),
      );
    } on RequestException catch (error) {
      _errorMessage = error.message;
      // Another tab or device may have posted in the meantime.
      if (error.message == openRequestLimitMessage) _limitReached = true;
      return null;
    } catch (_) {
      _errorMessage = 'Could not post the request. Please try again.';
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
