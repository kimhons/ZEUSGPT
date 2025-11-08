import 'package:flutter_test/flutter_test.dart';
import 'package:zeusgpt/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('currency', () {
      test('formats basic currency correctly', () {
        expect(Formatters.currency(1234.56), equals('\$1234.56'));
        expect(Formatters.currency(0), equals('\$0.00'));
        expect(Formatters.currency(1000000), equals('\$1000000.00'));
      });

      test('handles negative amounts', () {
        expect(Formatters.currency(-1234.56), equals('\$-1234.56'));
      });

      test('formats different currencies', () {
        expect(Formatters.currency(1234.56, symbol: '€'), equals('€1234.56'));
        expect(Formatters.currency(1234.56, symbol: '£'), equals('£1234.56'));
      });
    });

    group('currencyWithSeparator', () {
      test('formats currency with thousands separator', () {
        expect(Formatters.currencyWithSeparator(1234.56), equals('\$1,234.56'));
        expect(Formatters.currencyWithSeparator(0), equals('\$0.00'));
        expect(Formatters.currencyWithSeparator(1000000), equals('\$1,000,000.00'));
      });

      test('handles negative amounts', () {
        expect(Formatters.currencyWithSeparator(-1234.56), equals('-\$1,234.56'));
      });

      test('formats different currencies', () {
        expect(Formatters.currencyWithSeparator(1234.56, symbol: '€'), equals('€1,234.56'));
        expect(Formatters.currencyWithSeparator(1234.56, symbol: '£'), equals('£1,234.56'));
      });
    });

    group('date', () {
      test('formats date with default format', () {
        final date = DateTime(2024, 3, 15);
        expect(Formatters.date(date), equals('Mar 15, 2024'));
      });

      test('handles leap year dates', () {
        final leapDay = DateTime(2024, 2, 29);
        expect(Formatters.date(leapDay), equals('Feb 29, 2024'));
      });
    });

    group('dateTime', () {
      test('formats datetime with default format', () {
        final dateTime = DateTime(2024, 3, 15, 14, 30, 45);
        final result = Formatters.dateTime(dateTime);
        expect(result, contains('Mar 15, 2024'));
        expect(result, contains('2:30'));
        expect(result, contains('PM'));
      });
    });

    group('time', () {
      test('formats time correctly', () {
        final time1 = DateTime(2024, 3, 15, 14, 30);
        final result1 = Formatters.time(time1);
        expect(result1, contains('2:30'));
        expect(result1, contains('PM'));

        final time2 = DateTime(2024, 3, 15, 9, 5);
        final result2 = Formatters.time(time2);
        expect(result2, contains('9:05'));
        expect(result2, contains('AM'));

        final time3 = DateTime(2024, 3, 15, 0, 0);
        final result3 = Formatters.time(time3);
        expect(result3, contains('12:00'));
        expect(result3, contains('AM'));
      });
    });

    group('dateISO', () {
      test('formats to ISO 8601 string', () {
        final date = DateTime.utc(2024, 3, 15, 14, 30, 45);
        expect(Formatters.dateISO(date), equals('2024-03-15T14:30:45.000Z'));
      });
    });

    group('relativeTime', () {
      test('formats recent times correctly', () {
        final now = DateTime.now();
        
        // Just now
        expect(Formatters.relativeTime(now), equals('Just now'));
        
        // Minutes ago
        final fiveMinAgo = now.subtract(const Duration(minutes: 5));
        expect(Formatters.relativeTime(fiveMinAgo), equals('5m ago'));
        
        // Hours ago
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        expect(Formatters.relativeTime(twoHoursAgo), equals('2h ago'));
      });

      test('formats days correctly', () {
        final now = DateTime.now();
        
        // Yesterday
        final yesterday = now.subtract(const Duration(days: 1));
        expect(Formatters.relativeTime(yesterday), equals('Yesterday'));
        
        // Days ago
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        expect(Formatters.relativeTime(threeDaysAgo), equals('3d ago'));
      });

      test('formats weeks correctly', () {
        final now = DateTime.now();
        final twoWeeksAgo = now.subtract(const Duration(days: 14));
        expect(Formatters.relativeTime(twoWeeksAgo), equals('2w ago'));
      });
    });

    group('tokenCount', () {
      test('formats small token counts', () {
        expect(Formatters.tokenCount(0), equals('0 tokens'));
        expect(Formatters.tokenCount(500), equals('500 tokens'));
        expect(Formatters.tokenCount(999), equals('999 tokens'));
      });

      test('formats thousands with K suffix', () {
        expect(Formatters.tokenCount(1000), equals('1.0K tokens'));
        expect(Formatters.tokenCount(1500), equals('1.5K tokens'));
        expect(Formatters.tokenCount(12345), equals('12.3K tokens'));
      });

      test('formats millions with M suffix', () {
        expect(Formatters.tokenCount(1000000), equals('1.0M tokens'));
        expect(Formatters.tokenCount(2500000), equals('2.5M tokens'));
      });
    });

    group('tokenCountShort', () {
      test('formats small token counts', () {
        expect(Formatters.tokenCountShort(0), equals('0'));
        expect(Formatters.tokenCountShort(500), equals('500'));
        expect(Formatters.tokenCountShort(999), equals('999'));
      });

      test('formats thousands with K suffix', () {
        expect(Formatters.tokenCountShort(1000), equals('1.0K'));
        expect(Formatters.tokenCountShort(1500), equals('1.5K'));
      });

      test('formats millions with M suffix', () {
        expect(Formatters.tokenCountShort(1000000), equals('1.0M'));
        expect(Formatters.tokenCountShort(2500000), equals('2.5M'));
      });
    });

    group('fileSize', () {
      test('formats bytes correctly', () {
        expect(Formatters.fileSize(0), equals('0 bytes'));
        expect(Formatters.fileSize(512), equals('512 bytes'));
        expect(Formatters.fileSize(1023), equals('1023 bytes'));
      });

      test('formats kilobytes correctly', () {
        expect(Formatters.fileSize(1024), equals('1.00 KB'));
        expect(Formatters.fileSize(1536), equals('1.50 KB'));
        expect(Formatters.fileSize(10240), equals('10.00 KB'));
      });

      test('formats megabytes correctly', () {
        expect(Formatters.fileSize(1048576), equals('1.00 MB'));
        expect(Formatters.fileSize(5242880), equals('5.00 MB'));
      });

      test('formats gigabytes correctly', () {
        expect(Formatters.fileSize(1073741824), equals('1.00 GB'));
        expect(Formatters.fileSize(2147483648), equals('2.00 GB'));
      });
    });

    group('percentage', () {
      test('formats percentages correctly', () {
        expect(Formatters.percentage(50.0), equals('50%'));
        expect(Formatters.percentage(75.5), equals('76%'));
        expect(Formatters.percentage(100.0), equals('100%'));
      });

      test('respects decimal places', () {
        expect(Formatters.percentage(12.345, decimals: 2), equals('12.35%'));
        expect(Formatters.percentage(12.345, decimals: 0), equals('12%'));
        expect(Formatters.percentage(12.345, decimals: 1), equals('12.3%'));
      });

      test('handles zero and negative values', () {
        expect(Formatters.percentage(0), equals('0%'));
        expect(Formatters.percentage(-50.0), equals('-50%'));
      });
    });

    group('duration', () {
      test('formats seconds correctly', () {
        expect(Formatters.duration(const Duration(seconds: 30)), equals('30s'));
        expect(Formatters.duration(const Duration(seconds: 5)), equals('5s'));
      });

      test('formats minutes and seconds correctly', () {
        expect(Formatters.duration(const Duration(minutes: 2, seconds: 30)),
            equals('2m 30s'));
        expect(Formatters.duration(const Duration(minutes: 1, seconds: 5)),
            equals('1m 5s'));
      });

      test('formats hours and minutes correctly', () {
        expect(
            Formatters.duration(const Duration(hours: 1, minutes: 30, seconds: 45)),
            equals('1h 30m'));
        expect(Formatters.duration(const Duration(hours: 2, minutes: 5)),
            equals('2h 5m'));
      });

      test('handles zero duration', () {
        expect(Formatters.duration(Duration.zero), equals('0s'));
      });
    });

    group('millisToSeconds', () {
      test('converts milliseconds to seconds', () {
        expect(Formatters.millisToSeconds(1000), equals('1.00s'));
        expect(Formatters.millisToSeconds(2500), equals('2.50s'));
        expect(Formatters.millisToSeconds(100), equals('0.10s'));
      });
    });

    group('phoneNumber', () {
      test('formats 10-digit US phone numbers', () {
        expect(Formatters.phoneNumber('1234567890'),
            equals('(123) 456-7890'));
        expect(Formatters.phoneNumber('5551234567'),
            equals('(555) 123-4567'));
      });

      test('formats 11-digit numbers with country code', () {
        expect(Formatters.phoneNumber('11234567890'),
            equals('+1 (123) 456-7890'));
      });

      test('handles already formatted numbers', () {
        expect(Formatters.phoneNumber('(123) 456-7890'),
            equals('(123) 456-7890'));
      });

      test('handles numbers with hyphens', () {
        expect(Formatters.phoneNumber('123-456-7890'),
            equals('(123) 456-7890'));
      });

      test('handles numbers with spaces', () {
        expect(Formatters.phoneNumber('123 456 7890'),
            equals('(123) 456-7890'));
      });

      test('returns original for invalid formats', () {
        expect(Formatters.phoneNumber('12345'), equals('12345'));
        expect(Formatters.phoneNumber('abc'), equals('abc'));
      });
    });

    group('numberWithSeparator', () {
      test('formats numbers with thousands separator', () {
        expect(Formatters.numberWithSeparator(1234), equals('1,234'));
        expect(Formatters.numberWithSeparator(1234567), equals('1,234,567'));
        expect(Formatters.numberWithSeparator(1000000), equals('1,000,000'));
      });

      test('handles small numbers', () {
        expect(Formatters.numberWithSeparator(123), equals('123'));
        expect(Formatters.numberWithSeparator(0), equals('0'));
      });
    });

    group('decimal', () {
      test('formats decimal numbers', () {
        expect(Formatters.decimal(12.3456), equals('12.35'));
        expect(Formatters.decimal(100.1), equals('100.10'));
      });

      test('respects decimal places', () {
        expect(Formatters.decimal(12.3456, decimals: 0), equals('12'));
        expect(Formatters.decimal(12.3456, decimals: 3), equals('12.346'));
      });
    });

    group('modelName', () {
      test('converts model IDs to readable names', () {
        expect(Formatters.modelName('gpt-4'), equals('GPT 4'));
        expect(Formatters.modelName('gpt-3.5-turbo'), contains('GPT'));
        expect(Formatters.modelName('claude-3-opus'), equals('Claude 3 Opus'));
      });

      test('capitalizes properly', () {
        expect(Formatters.modelName('gpt-4o'), equals('GPT 4o'));
      });
    });

    group('creditCardMasked', () {
      test('masks credit card number', () {
        expect(Formatters.creditCardMasked('4532015112830366'),
            equals('**** **** **** 0366'));
        expect(Formatters.creditCardMasked('5425233430109903'),
            equals('**** **** **** 9903'));
      });

      test('handles already formatted cards', () {
        expect(Formatters.creditCardMasked('4532 0151 1283 0366'),
            equals('**** **** **** 0366'));
      });

      test('handles short numbers', () {
        expect(Formatters.creditCardMasked('123'), equals('****'));
      });
    });

    group('apiKeyMasked', () {
      test('masks API key', () {
        expect(Formatters.apiKeyMasked('sk-1234567890abcdefghij'),
            equals('sk-1....ghij'));
        expect(Formatters.apiKeyMasked('api-key-12345678901234567890'),
            equals('api-....7890'));
      });

      test('handles short keys', () {
        expect(Formatters.apiKeyMasked('short'), equals('****'));
      });
    });

    group('capitalize', () {
      test('capitalizes first letter', () {
        expect(Formatters.capitalize('hello'), equals('Hello'));
        expect(Formatters.capitalize('world'), equals('World'));
      });

      test('handles already capitalized', () {
        expect(Formatters.capitalize('Hello'), equals('Hello'));
      });

      test('handles empty string', () {
        expect(Formatters.capitalize(''), equals(''));
      });

      test('handles single character', () {
        expect(Formatters.capitalize('a'), equals('A'));
      });
    });

    group('capitalizeWords', () {
      test('capitalizes each word', () {
        expect(Formatters.capitalizeWords('hello world'), equals('Hello World'));
        expect(Formatters.capitalizeWords('the quick brown fox'),
            equals('The Quick Brown Fox'));
      });

      test('handles already capitalized', () {
        expect(Formatters.capitalizeWords('Hello World'), equals('Hello World'));
      });

      test('handles single word', () {
        expect(Formatters.capitalizeWords('hello'), equals('Hello'));
      });
    });

    group('camelCaseToTitle', () {
      test('converts camelCase to Title Case', () {
        expect(Formatters.camelCaseToTitle('helloWorld'), equals('Hello World'));
        expect(Formatters.camelCaseToTitle('firstName'), equals('First Name'));
      });

      test('handles single word', () {
        expect(Formatters.camelCaseToTitle('hello'), equals('Hello'));
      });
    });

    group('snakeCaseToTitle', () {
      test('converts snake_case to Title Case', () {
        expect(Formatters.snakeCaseToTitle('hello_world'), equals('Hello World'));
        expect(Formatters.snakeCaseToTitle('first_name'), equals('First Name'));
      });
    });

    group('truncate', () {
      test('truncates long text', () {
        expect(Formatters.truncate('This is a long text', 10),
            equals('This is...'));
        expect(Formatters.truncate('Hello World', 5), equals('He...'));
      });

      test('does not truncate short text', () {
        expect(Formatters.truncate('Short', 10), equals('Short'));
        expect(Formatters.truncate('Test', 20), equals('Test'));
      });

      test('uses custom suffix', () {
        expect(Formatters.truncate('Long text here', 8, suffix: '…'),
            equals('Long te…'));
      });

      test('handles exact length', () {
        expect(Formatters.truncate('Exactly10!', 10), equals('Exactly10!'));
      });
    });

    group('initials', () {
      test('generates initials from full name', () {
        expect(Formatters.initials('John Doe'), equals('JD'));
        expect(Formatters.initials('Mary Jane Watson'), equals('MW'));
      });

      test('handles single name', () {
        expect(Formatters.initials('John'), equals('J'));
      });

      test('handles lowercase names', () {
        expect(Formatters.initials('john doe'), equals('JD'));
      });

      test('handles extra spaces', () {
        expect(Formatters.initials('  John   Doe  '), equals('JD'));
      });
    });

    group('listToString', () {
      test('formats list with proper grammar', () {
        expect(Formatters.listToString(['a']), equals('a'));
        expect(Formatters.listToString(['a', 'b']), equals('a and b'));
        expect(Formatters.listToString(['a', 'b', 'c']), equals('a, b, and c'));
        expect(Formatters.listToString(['a', 'b', 'c', 'd']),
            equals('a, b, c, and d'));
      });

      test('handles empty list', () {
        expect(Formatters.listToString([]), equals(''));
      });

      test('uses custom separator', () {
        expect(Formatters.listToString(['a', 'b', 'c'], separator: '; '),
            equals('a; b, and c'));
      });
    });

    group('version', () {
      test('formats version number', () {
        expect(Formatters.version('1.0.0+123'), equals('v1.0.0'));
        expect(Formatters.version('2.5.3+456'), equals('v2.5.3'));
      });

      test('handles version without build number', () {
        expect(Formatters.version('1.0.0'), equals('v1.0.0'));
      });
    });

    group('messageCount', () {
      test('formats message count correctly', () {
        expect(Formatters.messageCount(0), equals('No messages'));
        expect(Formatters.messageCount(1), equals('1 message'));
        expect(Formatters.messageCount(5), equals('5 messages'));
      });
    });

    group('conversationCount', () {
      test('formats conversation count correctly', () {
        expect(Formatters.conversationCount(0), equals('No conversations'));
        expect(Formatters.conversationCount(1), equals('1 conversation'));
        expect(Formatters.conversationCount(5), equals('5 conversations'));
      });
    });

    group('subscriptionTier', () {
      test('formats subscription tier names', () {
        expect(Formatters.subscriptionTier('free'), equals('Free'));
        expect(Formatters.subscriptionTier('pro'), equals('Pro'));
        expect(Formatters.subscriptionTier('team'), equals('Team'));
        expect(Formatters.subscriptionTier('enterprise'), equals('Enterprise'));
      });

      test('handles unknown tiers', () {
        expect(Formatters.subscriptionTier('custom'), equals('Custom'));
      });
    });

    group('messageRole', () {
      test('formats message roles', () {
        expect(Formatters.messageRole('user'), equals('You'));
        expect(Formatters.messageRole('assistant'), equals('AI'));
        expect(Formatters.messageRole('system'), equals('System'));
      });

      test('handles unknown roles', () {
        expect(Formatters.messageRole('custom'), equals('Custom'));
      });
    });
  });
}
