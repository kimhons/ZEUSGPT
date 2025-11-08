import '../constants/app_constants.dart';

/// Centralized validation utilities
///
/// Usage:
/// ```dart
/// final emailError = Validators.email('test@example.com');
/// if (emailError != null) {
///   // Show error
/// }
/// ```
class Validators {
  /// Validate email address
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? password(String? value, {bool requireStrong = true}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (requireStrong) {
      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Password must contain at least one uppercase letter';
      }
      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'Password must contain at least one lowercase letter';
      }
      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Password must contain at least one number';
      }
      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Password must contain at least one special character';
      }
    }

    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate phone number
  static String? phone(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Check if it has enough digits (10-15 for international numbers)
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate display name
  static String? displayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Only allow letters, spaces, hyphens, and apostrophes
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate URL
  static String? url(String? value, {bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'URL is required' : null;
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Please enter a valid URL';
      }
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return 'URL must start with http:// or https://';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  /// Validate conversation title
  static String? conversationTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }

    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }

    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }

    return null;
  }

  /// Validate message content
  static String? messageContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }

    if (value.length > 32000) {
      return 'Message is too long (max 32,000 characters)';
    }

    return null;
  }

  /// Validate API key
  static String? apiKey(String? value, {String? keyName}) {
    if (value == null || value.isEmpty) {
      return '${keyName ?? "API key"} is required';
    }

    if (value.length < 20) {
      return '${keyName ?? "API key"} appears to be invalid';
    }

    return null;
  }

  /// Validate credit card number (Luhn algorithm)
  static String? creditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Card number must contain only digits';
    }

    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'Invalid card number length';
    }

    // Luhn algorithm
    var sum = 0;
    var alternate = false;
    for (var i = cleaned.length - 1; i >= 0; i--) {
      var digit = int.parse(cleaned[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      alternate = !alternate;
    }

    if (sum % 10 != 0) {
      return 'Invalid card number';
    }

    return null;
  }

  /// Validate CVV
  static String? cvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV must be 3 or 4 digits';
    }

    return null;
  }

  /// Validate expiry date (MM/YY format)
  static String? expiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Expiry date must be in MM/YY format';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) {
      return 'Invalid expiry date';
    }

    if (month < 1 || month > 12) {
      return 'Invalid month';
    }

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }

    return null;
  }

  /// Validate required field
  static String? required(dynamic value, {String? fieldName}) {
    if (value == null || (value is String && value.isEmpty)) {
      return '${fieldName ?? "This field"} is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }

    if (value.length < min) {
      return '${fieldName ?? "This field"} must be at least $min characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? "This field"} must be less than $max characters';
    }

    return null;
  }

  /// Validate numeric value
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? "This field"} must be a number';
    }

    return null;
  }

  /// Validate integer value
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }

    if (int.tryParse(value) == null) {
      return '${fieldName ?? "This field"} must be an integer';
    }

    return null;
  }

  /// Validate value is within range
  static String? range(
    num? value,
    num min,
    num max, {
    String? fieldName,
  }) {
    if (value == null) {
      return '${fieldName ?? "This field"} is required';
    }

    if (value < min || value > max) {
      return '${fieldName ?? "This field"} must be between $min and $max';
    }

    return null;
  }

  /// Validate username (alphanumeric + underscore)
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    if (RegExp(r'^[0-9]').hasMatch(value)) {
      return 'Username cannot start with a number';
    }

    return null;
  }

  /// Validate matches pattern
  static String? pattern(
    String? value,
    String pattern, {
    String? fieldName,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? "This field"} is required';
    }

    if (!RegExp(pattern).hasMatch(value)) {
      return errorMessage ??
          'Invalid ${fieldName?.toLowerCase() ?? "value"} format';
    }

    return null;
  }
}
