/// Phone number validation utilities with country-specific digit counts.
library;

class PhoneValidator {
  /// Map of country dial codes to expected digit lengths.
  static const Map<String, int> _countryDigits = {
    '+91': 10,  // India
    '+1': 10,   // USA / Canada
    '+44': 10,  // UK
    '+61': 9,   // Australia
    '+86': 11,  // China
    '+81': 10,  // Japan
    '+49': 10,  // Germany (10-11, using 10)
    '+33': 9,   // France
    '+39': 10,  // Italy
    '+55': 11,  // Brazil
    '+7': 10,   // Russia
    '+82': 10,  // South Korea
    '+65': 8,   // Singapore
    '+971': 9,  // UAE
    '+966': 9,  // Saudi Arabia
    '+92': 10,  // Pakistan
    '+880': 10, // Bangladesh
    '+94': 9,   // Sri Lanka
    '+977': 10, // Nepal
    '+60': 9,   // Malaysia (9-10, using 9)
    '+62': 10,  // Indonesia (10-12, using 10)
    '+63': 10,  // Philippines
    '+66': 9,   // Thailand
    '+84': 9,   // Vietnam
    '+234': 10, // Nigeria
    '+254': 9,  // Kenya
    '+27': 9,   // South Africa
    '+20': 10,  // Egypt
  };

  /// Default digit length if country code is not in the map.
  static const int _defaultDigits = 10;

  /// Get expected digit count for a country code.
  static int getExpectedDigits(String countryCode) {
    return _countryDigits[countryCode] ?? _defaultDigits;
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
