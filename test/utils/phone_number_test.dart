import 'package:bloodbank/utils/phone_number.dart';
import 'package:bloodbank/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeBangladeshiPhone', () {
    test('keeps a number that is already 01XXXXXXXXX', () {
      expect(normalizeBangladeshiPhone('01712345678'), '01712345678');
    });

    test('removes the +88 country code', () {
      expect(normalizeBangladeshiPhone('+8801712345678'), '01712345678');
    });

    test('removes the 88 country code without a plus', () {
      expect(normalizeBangladeshiPhone('8801712345678'), '01712345678');
    });

    test('ignores spaces and dashes', () {
      expect(normalizeBangladeshiPhone('017-1234 5678'), '01712345678');
      expect(normalizeBangladeshiPhone('+880 1712-345678'), '01712345678');
      expect(normalizeBangladeshiPhone(' 01712345678 '), '01712345678');
    });

    test('accepts every operator code from 3 to 9', () {
      for (var code = 3; code <= 9; code++) {
        expect(normalizeBangladeshiPhone('01${code}12345678'), isNotNull);
      }
    });

    test('rejects operator codes 0, 1 and 2', () {
      expect(normalizeBangladeshiPhone('01012345678'), isNull);
      expect(normalizeBangladeshiPhone('01112345678'), isNull);
      expect(normalizeBangladeshiPhone('01212345678'), isNull);
    });

    test('rejects numbers that are too short or too long', () {
      expect(normalizeBangladeshiPhone('0171234567'), isNull); // 10 digits
      expect(normalizeBangladeshiPhone('017123456789'), isNull); // 12 digits
      expect(normalizeBangladeshiPhone('+88017123456789'), isNull);
    });

    test('rejects a wrong country code', () {
      expect(normalizeBangladeshiPhone('+8811712345678'), isNull);
      expect(normalizeBangladeshiPhone('+9101712345678'), isNull);
    });

    test('rejects numbers without the leading 0', () {
      expect(normalizeBangladeshiPhone('1712345678'), isNull);
      expect(normalizeBangladeshiPhone('+881712345678'), isNull);
    });

    test('rejects letters, other symbols and empty input', () {
      expect(normalizeBangladeshiPhone('0171234567a'), isNull);
      expect(normalizeBangladeshiPhone('(017)12345678'), isNull);
      expect(normalizeBangladeshiPhone(''), isNull);
      expect(normalizeBangladeshiPhone('   '), isNull);
    });
  });

  group('Validators.phone', () {
    test('returns null (valid) for every accepted format', () {
      expect(Validators.phone('01712345678'), isNull);
      expect(Validators.phone('+8801712345678'), isNull);
      expect(Validators.phone('8801712345678'), isNull);
      expect(Validators.phone('017-1234 5678'), isNull);
    });

    test('asks for the number when it is empty', () {
      expect(Validators.phone(null), 'Mobile number is required');
      expect(Validators.phone(''), 'Mobile number is required');
      expect(Validators.phone('  '), 'Mobile number is required');
    });

    test('shows the 01XXXXXXXXX example when the number is invalid', () {
      expect(
        Validators.phone('01212345678'),
        'Enter a valid Bangladeshi mobile number, e.g. 01712345678',
      );
      expect(Validators.phone('12345'), isNotNull);
    });
  });
}
