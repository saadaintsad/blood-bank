import 'package:flutter/foundation.dart';

import '../data/repositories/donor_repository.dart';
import '../data/repositories/interest_repository.dart';
import '../data/repositories/request_repository.dart';
import '../models/blood_request.dart';
import '../models/donor.dart';
import '../models/donor_response.dart';
import '../models/enums.dart';
import '../models/interested_donor.dart';
import '../models/user.dart';
import '../utils/emergency_rules.dart';
import '../utils/interest_rules.dart' as interest;
import '../utils/request_rules.dart' as rules;

/// Who is looking at a request. It decides which parts of the screen show.
enum RequestViewerRole {
  /// The seeker who posted it: interested donors, close, Emergency Alert.
  owner,

  /// A donor: the seeker's phone and "I'm Interested".
  donor,

  /// A logged-in user who is not a donor: the request info only.
  other,
}

/// The state of the Request details screen for one request.
///
/// app.dart creates a new one each time the screen opens.
class RequestDetailsProvider extends ChangeNotifier {
  RequestDetailsProvider(
    this._requestRepository,
    this._interestRepository,
    this._donorRepository, {
    required this.requestId,
    required this.viewer,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final RequestRepository _requestRepository;
  final InterestRepository _interestRepository;
  final DonorRepository _donorRepository;

  final String requestId;

  /// The logged-in user looking at the request.
  final AppUser viewer;

  final DateTime Function() _clock;

  BloodRequest? _request;
  bool _isLoading = false;
  String? _errorMessage;

  // Owner view.
  List<InterestedDonor> _interestedDonors = const [];
  DateTime? _lastEmergencyAlert;
  bool _isClosing = false;
  bool _isSendingAlert = false;

  // Donor view.
  String? _seekerPhone;
  DonorProfile? _profile;
  DonorResponse? _myResponse;
  DonorResponse? _activeResponse;
  bool _isResponding = false;

  /// Null while loading, or when the request was not found.
  BloodRequest? get request => _request;
  bool get isLoading => _isLoading;

  /// Set when loading failed or the request doesn't exist.
  String? get errorMessage => _errorMessage;

  RequestViewerRole get role {
    if (_request?.ownerId == viewer.id) return RequestViewerRole.owner;
    if (viewer.isDonor) return RequestViewerRole.donor;
    return RequestViewerRole.other;
  }

  /// The current time from the clock given to the constructor. Screens
  /// use it instead of DateTime.now(), so tests can fix the time.
  DateTime get now => _clock();

  /// The status to show now, including Expired.
  RequestStatus get status => rules.effectiveStatus(_request!, _clock());

  /// True while the request can still be responded to or closed.
  bool get isOpen => _request != null && rules.isLive(_request!, _clock());

  List<InterestedDonor> get interestedDonors => _interestedDonors;
  bool get isClosing => _isClosing;
  bool get isSendingAlert => _isSendingAlert;

  /// 0 when Emergency Alert can be used now, otherwise the days to wait.
  int get emergencyDaysLeft =>
      daysUntilEmergencyAllowed(_lastEmergencyAlert, _clock());

  /// The seeker's number, shown to donors only.
  String? get seekerPhone => _seekerPhone;

  /// The viewer's own response to this request, or null.
  DonorResponse? get myResponse => _myResponse;
  bool get isResponding => _isResponding;

  /// Why the donor can't tap "I'm Interested", or null when they can (or
  /// have already responded to this request).
  String? get interestBlockReason {
    final profile = _profile;
    final request = _request;
    if (profile == null || request == null || _myResponse != null) {
      return null;
    }
    return interest.interestBlockReason(
      profile: profile,
      patientGroup: request.bloodGroup,
      activeResponse: _activeResponse,
      now: _clock(),
    );
  }

  /// True when the "I'm Interested" button should be enabled.
  bool get canExpressInterest =>
      isOpen &&
      _profile != null &&
      _myResponse == null &&
      interestBlockReason == null;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _request = await _requestRepository.getRequest(requestId);
      if (_request == null) {
        _errorMessage = 'This request could not be found.';
        return; // `finally` still runs.
      }
      switch (role) {
        case RequestViewerRole.owner:
          await _loadOwnerDetails();
        case RequestViewerRole.donor:
          await _loadDonorDetails();
        case RequestViewerRole.other:
          break; // The request info is all they see.
      }
    } catch (_) {
      _request = null;
      _errorMessage = 'Could not load this request. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadOwnerDetails() async {
    _interestedDonors = await _interestRepository.getInterestedDonors(
      requestId,
      viewerId: viewer.id,
    );
    _lastEmergencyAlert = await _requestRepository.getLastEmergencyAlert(
      viewer.id,
    );
  }

  Future<void> _loadDonorDetails() async {
    _seekerPhone = await _requestRepository.getSeekerPhone(
      requestId,
      viewerId: viewer.id,
    );
    _profile = await _donorRepository.getProfile(viewer.id);
    _myResponse = await _interestRepository.getResponse(
      requestId,
      donorId: viewer.id,
    );
    _activeResponse = await _interestRepository.getActiveResponse(viewer.id);
  }

  /// Taps "I'm Interested". Returns null on success, or a message to show.
  Future<String?> expressInterest() async {
    _isResponding = true;
    notifyListeners();
    try {
      final response = await _interestRepository.expressInterest(
        requestId,
        donorId: viewer.id,
      );
      _myResponse = response;
      _activeResponse = response;
      return null;
    } on InterestException catch (error) {
      return error.message;
    } catch (_) {
      return 'Could not send your response. Please try again.';
    } finally {
      _isResponding = false;
      notifyListeners();
    }
  }

  /// Returns null on success, or a message to show in a snackbar.
  Future<String?> markFulfilled() => _close(RequestStatus.fulfilled);

  /// Returns null on success, or a message to show in a snackbar.
  Future<String?> cancel() => _close(RequestStatus.cancelled);

  Future<String?> _close(RequestStatus newStatus) async {
    _isClosing = true;
    notifyListeners();
    try {
      _request = await _requestRepository.closeRequest(
        requestId,
        userId: viewer.id,
        status: newStatus,
      );
      return null;
    } on RequestException catch (error) {
      return error.message;
    } catch (_) {
      return 'Could not update the request. Please try again.';
    } finally {
      _isClosing = false;
      notifyListeners();
    }
  }

  /// Sends the Emergency Alert. Returns null on success, or a message.
  Future<String?> sendEmergencyAlert() async {
    _isSendingAlert = true;
    notifyListeners();
    try {
      _lastEmergencyAlert = await _requestRepository.sendEmergencyAlert(
        requestId,
        userId: viewer.id,
      );
      return null;
    } on RequestException catch (error) {
      return error.message;
    } catch (_) {
      return 'Could not send the alert. Please try again.';
    } finally {
      _isSendingAlert = false;
      notifyListeners();
    }
  }
}
