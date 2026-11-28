import 'package:flutter/foundation.dart';

import '../data/repositories/donor_repository.dart';
import '../data/repositories/request_repository.dart';
import '../models/blood_request.dart';
import '../models/donor_search_filters.dart';
import '../models/donor_search_result.dart';

/// The state of the Find Blood screen: the filters, the results and
/// whether the viewer may see phone numbers.
///
/// app.dart creates a new one each time Find Blood opens, so the filters
/// start fresh on every visit.
class DonorSearchProvider extends ChangeNotifier {
  DonorSearchProvider(
    this._donorRepository,
    this._requestRepository, {
    required this.viewerId,
  });

  final DonorRepository _donorRepository;
  final RequestRepository _requestRepository;

  /// The logged-in user doing the search.
  final String viewerId;

  // ---------------------------------------------------------------------------
  // Filters
  // ---------------------------------------------------------------------------

  String? _bloodGroup;
  String? _district;
  String _area = '';
  String _name = '';
  bool _onlyAvailable = false;

  String? get bloodGroup => _bloodGroup;
  String? get district => _district;
  String get area => _area;
  String get name => _name;
  bool get onlyAvailable => _onlyAvailable;

  void setBloodGroup(String group) {
    _bloodGroup = group;
    notifyListeners();
  }

  /// Null means any district. Changing the district clears the area,
  /// because the old area belongs to the old district.
  void setDistrict(String? district) {
    if (district != _district) _area = '';
    _district = district;
    notifyListeners();
  }

  void setArea(String area) {
    _area = area;
    notifyListeners();
  }

  // Typing a name doesn't change anything on screen until Search is
  // pressed, so there is no notifyListeners() here.
  void setName(String name) => _name = name;

  void setOnlyAvailable(bool value) {
    _onlyAvailable = value;
    notifyListeners();
  }

  /// Shown under the blood group picker after pressing Search without one.
  String? get bloodGroupError =>
      _showErrors && _bloodGroup == null ? 'Choose a blood group' : null;

  // ---------------------------------------------------------------------------
  // Results
  // ---------------------------------------------------------------------------

  BloodRequest? _openRequest;
  List<DonorSearchResult> _results = const [];
  Map<String, String> _phonesByDonorId = const {};
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _showErrors = false;
  String? _errorMessage;

  /// The viewer's open request, or null. Only with one may they see
  /// donors' numbers ("Finding donors" in docs/requirements.md).
  BloodRequest? get openRequest => _openRequest;
  bool get canSeeContacts => _openRequest != null;

  List<DonorSearchResult> get results => _results;
  bool get isLoading => _isLoading;

  /// False until the first search, so the screen can show a hint instead
  /// of "No donors found".
  bool get hasSearched => _hasSearched;

  String? get errorMessage => _errorMessage;

  /// The donor's number, or null when the viewer may not see it.
  String? phoneFor(String donorId) => _phonesByDonorId[donorId];

  /// Call once when the screen opens. Checks for an open request; if there
  /// is one, its blood group and district fill the filters and the search
  /// runs straight away (walkthrough Scene 4).
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final requests = await _requestRepository.getOpenRequests(viewerId);
      _openRequest = requests.isEmpty ? null : requests.first;
    } catch (_) {
      // Not fatal: the user can still search, just without numbers.
      _openRequest = null;
    }

    final request = _openRequest;
    if (request == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }
    _bloodGroup = request.bloodGroup;
    _district = request.district;
    await search();
  }

  /// Runs the search with the current filters. Does nothing but show an
  /// error if no blood group is chosen yet.
  Future<void> search() async {
    final group = _bloodGroup;
    if (group == null) {
      _showErrors = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Show the spinner.

    try {
      final results = await _donorRepository.searchDonors(
        DonorSearchFilters(
          bloodGroup: group,
          district: _district,
          area: _area.trim().isEmpty ? null : _area.trim(),
          name: _name,
          onlyAvailable: _onlyAvailable,
        ),
        viewerId: viewerId,
      );
      _results = results;
      _phonesByDonorId = canSeeContacts ? await _loadPhones(results) : const {};
    } catch (_) {
      _results = const [];
      _phonesByDonorId = const {};
      _errorMessage = 'Could not load donors. Please try again.';
    } finally {
      _hasSearched = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches every result's number at the same time. Future.wait starts
  /// all the requests together and waits until they have all finished.
  Future<Map<String, String>> _loadPhones(
    List<DonorSearchResult> results,
  ) async {
    final phones = await Future.wait([
      for (final donor in results)
        _donorRepository.getDonorPhone(donor.donorId, viewerId: viewerId),
    ]);
    return {
      for (var i = 0; i < results.length; i++)
        if (phones[i] != null) results[i].donorId: phones[i]!,
    };
  }
}
