/// Phone number validation utilities using CountryCodes for digit counts.
library;

import 'country_codes.dart';

class PhoneValidator {
  /// Get expected digit count for a country code.
  static int getExpectedDigits(String countryCode) {
    return CountryCodes.getExpectedDigits(countryCode);
  }

  /// Clean phone number — keep only digits.
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Validate phone number for a given country code.
  /// Returns null if valid, or an error message if invalid.
  static String? validate(String phone, String countryCode) {
    final cleaned = cleanPhone(phone);
    final expected = getExpectedDigits(countryCode);

    if (cleaned.isEmpty) {
      return 'Please enter a phone number';
    }

    if (cleaned.length < expected) {
      return 'Phone number must be $expected digits for $countryCode (entered ${cleaned.length})';
    }

    if (cleaned.length > expected) {
      return 'Phone number must be $expected digits for $countryCode (entered ${cleaned.length})';
    }

    // Reject all-same-digit numbers (e.g., 1111111111)
    if (cleaned.split('').toSet().length == 1) {
      return 'Please enter a valid phone number';
    }

    // Reject sequential patterns (e.g., 1234567890, 9876543210)
    const ascending = '0123456789012345';
    const descending = '9876543210987654';
    if (ascending.contains(cleaned) || descending.contains(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null; // Valid
  }

  /// Check if phone is valid (boolean version).
  static bool isValid(String phone, String countryCode) {
    return validate(phone, countryCode) == null;
  }
}
