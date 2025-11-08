import 'package:intl/intl.dart';

/// Centralized formatting utilities
///
/// Usage:
/// ```dart
/// final formatted = Formatters.currency(19.99);
/// final date = Formatters.date(DateTime.now());
/// final tokens = Formatters.tokenCount(1500);
/// ```
class Formatters {
  /// Format currency (USD)
  static String currency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format currency with thousands separator
  static String currencyWithSeparator(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format date to readable string (e.g., "Jan 15, 2025")
  static String date(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format date with time (e.g., "Jan 15, 2025 3:30 PM")
  static String dateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  /// Format time only (e.g., "3:30 PM")
  static String time(DateTime date) {
    return DateFormat.jm().format(date);
  }

  /// Format date to ISO 8601 string
  static String dateISO(DateTime date) {
    return date.toIso8601String();
  }

  /// Format relative time (e.g., "5 min ago", "Yesterday", "Jan 15")
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 30) {
      return 'Just now';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return DateFormat.MMMd().format(date);
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  /// Format token count with K/M suffix
  static String tokenCount(int tokens) {
    if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(1)}M tokens';
    } else if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(1)}K tokens';
    } else {
      return '$tokens tokens';
    }
  }

  /// Format token count short (just number with suffix)
  static String tokenCountShort(int tokens) {
    if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(1)}M';
    } else if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(1)}K';
    } else {
      return '$tokens';
    }
  }

  /// Format file size
  static String fileSize(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$bytes bytes';
    }
  }

  /// Format percentage
  static String percentage(double value, {int decimals = 0}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format duration (e.g., "2m 30s", "1h 5m")
  static String duration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      return '${minutes}m ${seconds}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format milliseconds to seconds
  static String millisToSeconds(int millis) {
    return '${(millis / 1000).toStringAsFixed(2)}s';
  }

  /// Format phone number (US format)
  static String phoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length == 10) {
      // US format: (123) 456-7890
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      // US format with country code: +1 (123) 456-7890
      return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }

    // Return original if format is unknown
    return phone;
  }

  /// Format number with thousands separator
  static String numberWithSeparator(num value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value);
  }

  /// Format decimal number
  static String decimal(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  /// Format model name for display
  static String modelName(String modelId) {
    // Convert model IDs to readable names
    // e.g., "gpt-4o" -> "GPT-4o", "claude-3-opus" -> "Claude 3 Opus"
    return modelId
        .split('-')
        .map((word) {
          if (word.toLowerCase() == 'gpt') {
            return 'GPT';
          } else if (word.toLowerCase() == 'opus' ||
              word.toLowerCase() == 'sonnet' ||
              word.toLowerCase() == 'haiku') {
            return word[0].toUpperCase() + word.substring(1);
          } else if (RegExp(r'^\d').hasMatch(word)) {
            return word;
          } else {
            return word[0].toUpperCase() + word.substring(1);
          }
        })
        .join(' ')
        .replaceAll('  ', ' ');
  }

  /// Format credit card number (masked)
  static String creditCardMasked(String cardNumber) {
    // Remove spaces and dashes
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

    if (cleaned.length < 4) {
      return '****';
    }

    // Show last 4 digits
    final lastFour = cleaned.substring(cleaned.length - 4);
    return '**** **** **** $lastFour';
  }

  /// Format API key (masked)
  static String apiKeyMasked(String apiKey) {
    if (apiKey.length < 8) {
      return '****';
    }

    // Show first 4 and last 4 characters
    final first4 = apiKey.substring(0, 4);
    final last4 = apiKey.substring(apiKey.length - 4);
    return '$first4....$last4';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize each word
  static String capitalizeWords(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }

  /// Convert camelCase to Title Case
  static String camelCaseToTitle(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map(capitalize)
        .join(' ');
  }

  /// Convert snake_case to Title Case
  static String snakeCaseToTitle(String text) {
    return text
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Format initials from name
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Format list to comma-separated string
  static String listToString(List<String> items, {String separator = ', '}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items[0];
    if (items.length == 2) return '${items[0]} and ${items[1]}';

    final allButLast = items.sublist(0, items.length - 1).join(separator);
    return '$allButLast, and ${items.last}';
  }

  /// Format version number
  static String version(String version) {
    // e.g., "1.0.0+123" -> "v1.0.0"
    return 'v${version.split('+')[0]}';
  }

  /// Format message count
  static String messageCount(int count) {
    if (count == 0) return 'No messages';
    if (count == 1) return '1 message';
    return '$count messages';
  }

  /// Format conversation count
  static String conversationCount(int count) {
    if (count == 0) return 'No conversations';
    if (count == 1) return '1 conversation';
    return '$count conversations';
  }

  /// Format subscription tier
  static String subscriptionTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'free':
        return 'Free';
      case 'pro':
        return 'Pro';
      case 'team':
        return 'Team';
      case 'enterprise':
        return 'Enterprise';
      default:
        return capitalize(tier);
    }
  }

  /// Format message role
  static String messageRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return 'You';
      case 'assistant':
        return 'AI';
      case 'system':
        return 'System';
      default:
        return capitalize(role);
    }
  }
}
