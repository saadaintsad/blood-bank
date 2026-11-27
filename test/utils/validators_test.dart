import 'package:bloodbank/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

// Phone validation has its own file: phone_number_test.dart.
void main() {
  test('requiredField rejects empty and blank values', () {
    expect(Validators.requiredField('Rahim'), isNull);
    expect(Validators.requiredField(''), isNotNull);
    expect(Validators.requiredField('  '), isNotNull);
    expect(
      Validators.requiredField(null, fieldName: 'Password'),
      'Password is required',
    );
  });

  test('email', () {
    expect(Validators.email('donor@example.com'), isNull);
    expect(Validators.email('donor@'), isNotNull);
    expect(Validators.email(''), isNotNull);
  });

  test('password needs 8+ characters with letters and numbers', () {
    expect(Validators.password('abc12345'), isNull);
    expect(Validators.password('abc123'), isNotNull); // too short
    expect(Validators.password('abcdefgh'), isNotNull); // no number
    expect(Validators.password('12345678'), isNotNull); // no letter
  });

  test('confirmPassword must match', () {
    expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
    expect(Validators.confirmPassword('abc', 'abc12345'), isNotNull);
    expect(Validators.confirmPassword('', 'abc12345'), isNotNull);
  });
}
