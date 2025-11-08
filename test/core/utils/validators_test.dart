import 'package:flutter_test/flutter_test.dart';
import 'package:zeusgpt/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name+tag@example.co.uk'), isNull);
        expect(Validators.email('test_123@domain.org'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.email(null), isNotNull);
        expect(Validators.email(''), isNotNull);
      });

      test('returns error for invalid format', () {
        expect(Validators.email('invalid'), isNotNull);
        expect(Validators.email('test@'), isNotNull);
        expect(Validators.email('@example.com'), isNotNull);
        expect(Validators.email('test @example.com'), isNotNull);
      });
    });

    group('password', () {
      test('returns null for valid strong password', () {
        expect(Validators.password('Abcdef12!'), isNull);
        expect(Validators.password('Test1234@'), isNull);
        expect(Validators.password('Passw0rd#'), isNull);
      });

      test('returns null for valid weak password when not requiring strong', () {
        expect(Validators.password('password123', requireStrong: false),
            isNull);
        expect(Validators.password('testpass', requireStrong: false), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.password(null), isNotNull);
        expect(Validators.password(''), isNotNull);
      });

      test('returns error for password too short', () {
        expect(Validators.password('Test1!'), isNotNull);
        expect(Validators.password('abc'), isNotNull);
      });

      test('returns error for missing uppercase', () {
        expect(Validators.password('password123!'), isNotNull);
      });

      test('returns error for missing lowercase', () {
        expect(Validators.password('PASSWORD123!'), isNotNull);
      });

      test('returns error for missing number', () {
        expect(Validators.password('Password!'), isNotNull);
      });

      test('returns error for missing special character', () {
        expect(Validators.password('Password123'), isNotNull);
      });
    });

    group('confirmPassword', () {
      test('returns null when passwords match', () {
        expect(Validators.confirmPassword('test123', 'test123'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.confirmPassword(null, 'test'), isNotNull);
        expect(Validators.confirmPassword('', 'test'), isNotNull);
      });

      test('returns error when passwords do not match', () {
        expect(Validators.confirmPassword('test123', 'test456'), isNotNull);
        expect(Validators.confirmPassword('Test', 'test'), isNotNull);
      });
    });

    group('phone', () {
      test('returns null for valid phone numbers', () {
        expect(Validators.phone('1234567890'), isNull);
        expect(Validators.phone('(123) 456-7890'), isNull);
        expect(Validators.phone('+1 123 456 7890'), isNull);
        expect(Validators.phone('123-456-7890'), isNull);
      });

      test('returns error for null or empty when required', () {
        expect(Validators.phone(null, required: true), isNotNull);
        expect(Validators.phone('', required: true), isNotNull);
      });

      test('returns null for null or empty when not required', () {
        expect(Validators.phone(null, required: false), isNull);
        expect(Validators.phone('', required: false), isNull);
      });

      test('returns error for too few digits', () {
        expect(Validators.phone('12345'), isNotNull);
        expect(Validators.phone('123'), isNotNull);
      });

      test('returns error for too many digits', () {
        expect(Validators.phone('12345678901234567890'), isNotNull);
      });
    });

    group('displayName', () {
      test('returns null for valid names', () {
        expect(Validators.displayName('John Doe'), isNull);
        expect(Validators.displayName("O'Brien"), isNull);
        expect(Validators.displayName('Mary-Jane'), isNull);
        expect(Validators.displayName('De la Cruz'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.displayName(null), isNotNull);
        expect(Validators.displayName(''), isNotNull);
      });

      test('returns error for too short', () {
        expect(Validators.displayName('A'), isNotNull);
      });

      test('returns error for too long', () {
        expect(Validators.displayName('A' * 51), isNotNull);
      });

      test('returns error for invalid characters', () {
        expect(Validators.displayName('John123'), isNotNull);
        expect(Validators.displayName('Test@User'), isNotNull);
        expect(Validators.displayName('User_Name'), isNotNull);
      });
    });

    group('url', () {
      test('returns null for valid URLs', () {
        expect(Validators.url('https://example.com'), isNull);
        expect(Validators.url('http://test.org/path'), isNull);
        expect(Validators.url('https://sub.domain.com:8080/path?q=1'), isNull);
      });

      test('returns error for null or empty when required', () {
        expect(Validators.url(null, required: true), isNotNull);
        expect(Validators.url('', required: true), isNotNull);
      });

      test('returns null for null or empty when not required', () {
        expect(Validators.url(null, required: false), isNull);
        expect(Validators.url('', required: false), isNull);
      });

      test('returns error for invalid URLs', () {
        expect(Validators.url('invalid'), isNotNull);
        expect(Validators.url('ftp://example.com'), isNotNull);
        expect(Validators.url('//example.com'), isNotNull);
        expect(Validators.url('example.com'), isNotNull);
      });
    });

    group('conversationTitle', () {
      test('returns null for valid titles', () {
        expect(Validators.conversationTitle('Test Chat'), isNull);
        expect(Validators.conversationTitle('My Conversation 123'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.conversationTitle(null), isNotNull);
        expect(Validators.conversationTitle(''), isNotNull);
      });

      test('returns error for too short', () {
        expect(Validators.conversationTitle('AB'), isNotNull);
      });

      test('returns error for too long', () {
        expect(Validators.conversationTitle('A' * 101), isNotNull);
      });
    });

    group('messageContent', () {
      test('returns null for valid messages', () {
        expect(Validators.messageContent('Hello world'), isNull);
        expect(Validators.messageContent('A' * 100), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.messageContent(null), isNotNull);
        expect(Validators.messageContent(''), isNotNull);
      });

      test('returns error for too long', () {
        expect(Validators.messageContent('A' * 32001), isNotNull);
      });
    });

    group('apiKey', () {
      test('returns null for valid API keys', () {
        expect(Validators.apiKey('A' * 30), isNull);
        expect(Validators.apiKey('sk-1234567890abcdefghij'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.apiKey(null), isNotNull);
        expect(Validators.apiKey(''), isNotNull);
      });

      test('returns error for too short', () {
        expect(Validators.apiKey('short'), isNotNull);
      });

      test('includes custom key name in error message', () {
        final error = Validators.apiKey('', keyName: 'OpenAI Key');
        expect(error, contains('OpenAI Key'));
      });
    });

    group('creditCard', () {
      test('returns null for valid credit card numbers', () {
        // Visa test number
        expect(Validators.creditCard('4532015112830366'), isNull);
        // Mastercard test number
        expect(Validators.creditCard('5425233430109903'), isNull);
        // With spaces
        expect(Validators.creditCard('4532 0151 1283 0366'), isNull);
        // With dashes
        expect(Validators.creditCard('4532-0151-1283-0366'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.creditCard(null), isNotNull);
        expect(Validators.creditCard(''), isNotNull);
      });

      test('returns error for non-digits', () {
        expect(Validators.creditCard('abcd1234'), isNotNull);
      });

      test('returns error for invalid length', () {
        expect(Validators.creditCard('123'), isNotNull);
        expect(Validators.creditCard('12345678901234567890'), isNotNull);
      });

      test('returns error for invalid Luhn checksum', () {
        expect(Validators.creditCard('4532015112830367'), isNotNull);
      });
    });

    group('cvv', () {
      test('returns null for valid CVV', () {
        expect(Validators.cvv('123'), isNull);
        expect(Validators.cvv('1234'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.cvv(null), isNotNull);
        expect(Validators.cvv(''), isNotNull);
      });

      test('returns error for invalid format', () {
        expect(Validators.cvv('12'), isNotNull);
        expect(Validators.cvv('12345'), isNotNull);
        expect(Validators.cvv('abc'), isNotNull);
      });
    });

    group('expiryDate', () {
      test('returns null for valid future dates', () {
        final futureYear = (DateTime.now().year + 1) % 100;
        expect(Validators.expiryDate('12/$futureYear'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.expiryDate(null), isNotNull);
        expect(Validators.expiryDate(''), isNotNull);
      });

      test('returns error for invalid format', () {
        expect(Validators.expiryDate('1/23'), isNotNull);
        expect(Validators.expiryDate('123/23'), isNotNull);
        expect(Validators.expiryDate('12-23'), isNotNull);
      });

      test('returns error for invalid month', () {
        expect(Validators.expiryDate('00/25'), isNotNull);
        expect(Validators.expiryDate('13/25'), isNotNull);
      });

      test('returns error for expired date', () {
        expect(Validators.expiryDate('01/20'), isNotNull);
      });
    });

    group('required', () {
      test('returns null for non-empty values', () {
        expect(Validators.required('test'), isNull);
        expect(Validators.required(123), isNull);
        expect(Validators.required(true), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.required(null), isNotNull);
        expect(Validators.required(''), isNotNull);
      });

      test('includes field name in error message', () {
        final error = Validators.required(null, fieldName: 'Name');
        expect(error, contains('Name'));
      });
    });

    group('minLength', () {
      test('returns null for valid length', () {
        expect(Validators.minLength('test', 4), isNull);
        expect(Validators.minLength('testing', 5), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.minLength(null, 5), isNotNull);
        expect(Validators.minLength('', 5), isNotNull);
      });

      test('returns error for too short', () {
        expect(Validators.minLength('test', 5), isNotNull);
      });
    });

    group('maxLength', () {
      test('returns null for valid length', () {
        expect(Validators.maxLength('test', 5), isNull);
        expect(Validators.maxLength(null, 5), isNull);
      });

      test('returns error for too long', () {
        expect(Validators.maxLength('testing', 5), isNotNull);
      });
    });

    group('numeric', () {
      test('returns null for valid numbers', () {
        expect(Validators.numeric('123'), isNull);
        expect(Validators.numeric('123.45'), isNull);
        expect(Validators.numeric('-123'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.numeric(null), isNotNull);
        expect(Validators.numeric(''), isNotNull);
      });

      test('returns error for non-numeric', () {
        expect(Validators.numeric('abc'), isNotNull);
        expect(Validators.numeric('12a3'), isNotNull);
      });
    });

    group('integer', () {
      test('returns null for valid integers', () {
        expect(Validators.integer('123'), isNull);
        expect(Validators.integer('-456'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.integer(null), isNotNull);
        expect(Validators.integer(''), isNotNull);
      });

      test('returns error for non-integer', () {
        expect(Validators.integer('123.45'), isNotNull);
        expect(Validators.integer('abc'), isNotNull);
      });
    });

    group('range', () {
      test('returns null for value in range', () {
        expect(Validators.range(5, 1, 10), isNull);
        expect(Validators.range(1.5, 1.0, 2.0), isNull);
      });

      test('returns error for null', () {
        expect(Validators.range(null, 1, 10), isNotNull);
      });

      test('returns error for value out of range', () {
        expect(Validators.range(0, 1, 10), isNotNull);
        expect(Validators.range(11, 1, 10), isNotNull);
      });
    });

    group('username', () {
      test('returns null for valid usernames', () {
        expect(Validators.username('user123'), isNull);
        expect(Validators.username('test_user'), isNull);
        expect(Validators.username('User_123'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.username(null), isNotNull);
        expect(Validators.username(''), isNotNull);
      });

      test('returns error for too short', () {
        expect(Validators.username('ab'), isNotNull);
      });

      test('returns error for too long', () {
        expect(Validators.username('A' * 31), isNotNull);
      });

      test('returns error for invalid characters', () {
        expect(Validators.username('user-name'), isNotNull);
        expect(Validators.username('user@name'), isNotNull);
        expect(Validators.username('user name'), isNotNull);
      });

      test('returns error for starting with number', () {
        expect(Validators.username('123user'), isNotNull);
      });
    });

    group('pattern', () {
      test('returns null for matching pattern', () {
        expect(Validators.pattern('test123', r'^[a-z0-9]+$'), isNull);
        expect(Validators.pattern('ABC-123', r'^[A-Z]+-\d+$'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.pattern(null, r'^test$'), isNotNull);
        expect(Validators.pattern('', r'^test$'), isNotNull);
      });

      test('returns error for non-matching pattern', () {
        expect(Validators.pattern('test', r'^[0-9]+$'), isNotNull);
      });

      test('uses custom error message', () {
        final error = Validators.pattern(
          'test',
          r'^[0-9]+$',
          errorMessage: 'Must be numbers only',
        );
        expect(error, equals('Must be numbers only'));
      });
    });
  });
}
