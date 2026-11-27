import 'phone_number.dart';

/// Form validators for TextFormField.
///
/// Each method returns `null` when the value is valid, or an error message
/// to show under the field. That is exactly what TextFormField's
/// `validator:` parameter expects, so you can write:
///
///   validator: Validators.email,
class Validators {
  Validators._();

  /// The field must not be empty (spaces alone do not count).
  static String? requiredField(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// A simple email check: something@something.something
  /// Real verification happens later when we send a confirmation email.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email, e.g. name@example.com';
    }
    return null;
  }

  /// A Bangladeshi mobile number.
  ///
  /// Accepts 01XXXXXXXXX, +8801XXXXXXXXX or 8801XXXXXXXXX, with or without
  /// spaces and dashes. Before saving, turn the input into the stored
  /// 01XXXXXXXXX format with normalizeBangladeshiPhone().
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (normalizeBangladeshiPhone(value) == null) {
      return 'Enter a valid Bangladeshi mobile number, e.g. 01712345678';
    }
    return null;
  }

  /// At least 8 characters, with at least one letter and one number.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Use at least 8 characters';
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);
    if (!hasLetter || !hasNumber) {
      return 'Use both letters and numbers';
    }
    return null;
  }

  /// Must match the password typed in the first field.
  ///
  /// Because it needs the other password, use it with a small function:
  ///   validator: (value) =>
  ///       Validators.confirmPassword(value, _passwordController.text),
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
