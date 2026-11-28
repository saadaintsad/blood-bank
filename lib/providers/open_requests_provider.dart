import 'package:flutter/foundation.dart';

import '../data/repositories/donor_repository.dart';
import '../data/repositories/request_repository.dart';
import '../models/blood_request.dart';
import '../models/donor.dart';
import '../utils/blood_compatibility.dart';
import '../utils/open_requests_sort.dart';

/// The state of the Open Requests screen: open requests in the donor's
/// district, the ones they can give to first.
class OpenRequestsProvider extends ChangeNotifier {
  OpenRequestsProvider(
    this._requestRepository,
    this._donorRepository, {
    required this.viewerId,
  });

  final RequestRepository _requestRepository;
  final DonorRepository _donorRepository;

  /// The logged-in donor.
  final String viewerId;

  DonorProfile? _profile;
  List<BloodRequest> _requests = const [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Null until loaded, or when the viewer is not a donor.
  DonorProfile? get profile => _profile;

  /// Already in Open Requests order (see utils/open_requests_sort.dart).
  List<BloodRequest> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// The donor's district, e.g. "Dhaka", once loaded.
  String? get district => _profile?.district;

  /// True when the donor's blood group can give to [request]'s patient.
  bool isCompatible(BloodRequest request) {
    final group = _profile?.bloodGroup;
    return group != null && canDonateTo(group, request.bloodGroup);
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final profile = await _donorRepository.getProfile(viewerId);
      _profile = profile;
      if (profile == null) {
        _requests = const [];
        _errorMessage =
            'Open Requests is for donors. Register as a donor '
            'to see requests near you.';
        return; // `finally` below still runs.
      }
      final requests = await _requestRepository.getDistrictOpenRequests(
        profile.district,
        viewerId: viewerId,
      );
      _requests = sortOpenRequests(requests, profile.bloodGroup);
    } catch (_) {
      _requests = const [];
      _errorMessage = 'Could not load open requests. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
