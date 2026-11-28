/// Which donor blood groups can give to which patients.
///
/// Source: "Blood group matching" in docs/requirements.md (standard
/// red-cell compatibility). The hospital's crossmatch test still makes the
/// final decision. Later this table moves to a Supabase lookup table.
library;

/// For each patient group, the donor groups that can give to them.
/// The patient's own group comes first in each list.
const Map<String, List<String>> _donorGroupsForPatient = {
  'O-': ['O-'],
  'O+': ['O+', 'O-'],
  'A-': ['A-', 'O-'],
  'A+': ['A+', 'A-', 'O+', 'O-'],
  'B-': ['B-', 'O-'],
  'B+': ['B+', 'B-', 'O+', 'O-'],
  'AB-': ['AB-', 'A-', 'B-', 'O-'],
  'AB+': ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'],
};

/// The donor groups that can give blood to a patient with [patientGroup].
/// An unknown group gets an empty list.
List<String> compatibleDonorGroups(String patientGroup) {
  return _donorGroupsForPatient[patientGroup] ?? const [];
}

/// True when a donor with [donorGroup] can give to a patient with
/// [patientGroup].
bool canDonateTo(String donorGroup, String patientGroup) {
  return compatibleDonorGroups(patientGroup).contains(donorGroup);
}
