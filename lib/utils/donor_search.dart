/// The order of Find Blood results, kept in one place so it is easy to
/// test. Source: "Finding donors" and "Blood group matching" in
/// docs/requirements.md.
library;

import '../models/donor_search_result.dart';
import '../models/enums.dart';

/// Compares two results for sorting. A negative number means [a] comes
/// first. The rules, in order:
///
/// 1. Exact blood group before compatible groups.
/// 2. Donors in [preferredArea] before the rest (only if it is set).
/// 3. Green (available) before Yellow (recently donated).
/// 4. Name A–Z, so equal donors always appear in the same order.
int compareSearchResults(
  DonorSearchResult a,
  DonorSearchResult b, {
  String? preferredArea,
}) {
  // Each rule turns "is it better?" into 0 (better) or 1 (worse). If two
  // donors tie on one rule, we fall through to the next.
  final byMatch = _rank(a.isExactMatch) - _rank(b.isExactMatch);
  if (byMatch != 0) return byMatch;

  if (preferredArea != null && preferredArea.isNotEmpty) {
    final byArea =
        _rank(a.area == preferredArea) - _rank(b.area == preferredArea);
    if (byArea != 0) return byArea;
  }

  final byStatus = _rank(a.status == DonorStatus.available) -
      _rank(b.status == DonorStatus.available);
  if (byStatus != 0) return byStatus;

  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
}

/// A new list with [results] in Find Blood order (see
/// [compareSearchResults]). The original list is not changed.
List<DonorSearchResult> sortSearchResults(
  List<DonorSearchResult> results, {
  String? preferredArea,
}) {
  // `..sort(...)` sorts the copy and returns it (the ".." is a cascade).
  return [...results]..sort(
      (a, b) => compareSearchResults(a, b, preferredArea: preferredArea),
    );
}

/// 0 when [isBetter] is true, 1 otherwise. Lower numbers sort first.
int _rank(bool isBetter) => isBetter ? 0 : 1;
