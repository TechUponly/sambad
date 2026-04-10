/// Comprehensive list of country dial codes with country names and expected digit lengths.
library;

class CountryCode {
  final String name;
  final String code;
  final String flag;
  final int digits;

  const CountryCode({required this.name, required this.code, required this.flag, required this.digits});

  @override
  String toString() => '$flag $code ($name)';
}

class CountryCodes {
  static const List<CountryCode> all = [
    CountryCode(name: 'Afghanistan', code: '+93', flag: '🇦🇫', digits: 9),
    CountryCode(name: 'Albania', code: '+355', flag: '🇦🇱', digits: 9),
    CountryCode(name: 'Algeria', code: '+213', flag: '🇩🇿', digits: 9),
    CountryCode(name: 'Argentina', code: '+54', flag: '🇦🇷', digits: 10),
    CountryCode(name: 'Armenia', code: '+374', flag: '🇦🇲', digits: 8),
    CountryCode(name: 'Australia', code: '+61', flag: '🇦🇺', digits: 9),
    CountryCode(name: 'Austria', code: '+43', flag: '🇦🇹', digits: 10),
    CountryCode(name: 'Azerbaijan', code: '+994', flag: '🇦🇿', digits: 9),
    CountryCode(name: 'Bahrain', code: '+973', flag: '🇧🇭', digits: 8),
    CountryCode(name: 'Bangladesh', code: '+880', flag: '🇧🇩', digits: 10),
    CountryCode(name: 'Belarus', code: '+375', flag: '🇧🇾', digits: 9),
    CountryCode(name: 'Belgium', code: '+32', flag: '🇧🇪', digits: 9),
    CountryCode(name: 'Bhutan', code: '+975', flag: '🇧🇹', digits: 8),
    CountryCode(name: 'Bolivia', code: '+591', flag: '🇧🇴', digits: 8),
    CountryCode(name: 'Brazil', code: '+55', flag: '🇧🇷', digits: 11),
    CountryCode(name: 'Brunei', code: '+673', flag: '🇧🇳', digits: 7),
    CountryCode(name: 'Bulgaria', code: '+359', flag: '🇧🇬', digits: 9),
    CountryCode(name: 'Cambodia', code: '+855', flag: '🇰🇭', digits: 9),
    CountryCode(name: 'Cameroon', code: '+237', flag: '🇨🇲', digits: 9),
    CountryCode(name: 'Canada', code: '+1', flag: '🇨🇦', digits: 10),
    CountryCode(name: 'Chile', code: '+56', flag: '🇨🇱', digits: 9),
    CountryCode(name: 'China', code: '+86', flag: '🇨🇳', digits: 11),
    CountryCode(name: 'Colombia', code: '+57', flag: '🇨🇴', digits: 10),
    CountryCode(name: 'Costa Rica', code: '+506', flag: '🇨🇷', digits: 8),
    CountryCode(name: 'Croatia', code: '+385', flag: '🇭🇷', digits: 9),
    CountryCode(name: 'Cuba', code: '+53', flag: '🇨🇺', digits: 8),
    CountryCode(name: 'Cyprus', code: '+357', flag: '🇨🇾', digits: 8),
    CountryCode(name: 'Czech Republic', code: '+420', flag: '🇨🇿', digits: 9),
    CountryCode(name: 'Denmark', code: '+45', flag: '🇩🇰', digits: 8),
    CountryCode(name: 'Ecuador', code: '+593', flag: '🇪🇨', digits: 9),
    CountryCode(name: 'Egypt', code: '+20', flag: '🇪🇬', digits: 10),
    CountryCode(name: 'Estonia', code: '+372', flag: '🇪🇪', digits: 8),
    CountryCode(name: 'Ethiopia', code: '+251', flag: '🇪🇹', digits: 9),
    CountryCode(name: 'Fiji', code: '+679', flag: '🇫🇯', digits: 7),
    CountryCode(name: 'Finland', code: '+358', flag: '🇫🇮', digits: 10),
    CountryCode(name: 'France', code: '+33', flag: '🇫🇷', digits: 9),
    CountryCode(name: 'Georgia', code: '+995', flag: '🇬🇪', digits: 9),
    CountryCode(name: 'Germany', code: '+49', flag: '🇩🇪', digits: 10),
    CountryCode(name: 'Ghana', code: '+233', flag: '🇬🇭', digits: 9),
    CountryCode(name: 'Greece', code: '+30', flag: '🇬🇷', digits: 10),
    CountryCode(name: 'Guatemala', code: '+502', flag: '🇬🇹', digits: 8),
    CountryCode(name: 'Honduras', code: '+504', flag: '🇭🇳', digits: 8),
    CountryCode(name: 'Hong Kong', code: '+852', flag: '🇭🇰', digits: 8),
    CountryCode(name: 'Hungary', code: '+36', flag: '🇭🇺', digits: 9),
    CountryCode(name: 'Iceland', code: '+354', flag: '🇮🇸', digits: 7),
    CountryCode(name: 'India', code: '+91', flag: '🇮🇳', digits: 10),
    CountryCode(name: 'Indonesia', code: '+62', flag: '🇮🇩', digits: 10),
    CountryCode(name: 'Iran', code: '+98', flag: '🇮🇷', digits: 10),
    CountryCode(name: 'Iraq', code: '+964', flag: '🇮🇶', digits: 10),
    CountryCode(name: 'Ireland', code: '+353', flag: '🇮🇪', digits: 9),
    CountryCode(name: 'Israel', code: '+972', flag: '🇮🇱', digits: 9),
    CountryCode(name: 'Italy', code: '+39', flag: '🇮🇹', digits: 10),
    CountryCode(name: 'Jamaica', code: '+1876', flag: '🇯🇲', digits: 7),
    CountryCode(name: 'Japan', code: '+81', flag: '🇯🇵', digits: 10),
    CountryCode(name: 'Jordan', code: '+962', flag: '🇯🇴', digits: 9),
    CountryCode(name: 'Kazakhstan', code: '+7', flag: '🇰🇿', digits: 10),
    CountryCode(name: 'Kenya', code: '+254', flag: '🇰🇪', digits: 9),
    CountryCode(name: 'Kuwait', code: '+965', flag: '🇰🇼', digits: 8),
    CountryCode(name: 'Kyrgyzstan', code: '+996', flag: '🇰🇬', digits: 9),
    CountryCode(name: 'Laos', code: '+856', flag: '🇱🇦', digits: 10),
    CountryCode(name: 'Latvia', code: '+371', flag: '🇱🇻', digits: 8),
    CountryCode(name: 'Lebanon', code: '+961', flag: '🇱🇧', digits: 8),
    CountryCode(name: 'Libya', code: '+218', flag: '🇱🇾', digits: 10),
    CountryCode(name: 'Lithuania', code: '+370', flag: '🇱🇹', digits: 8),
    CountryCode(name: 'Luxembourg', code: '+352', flag: '🇱🇺', digits: 9),
    CountryCode(name: 'Macau', code: '+853', flag: '🇲🇴', digits: 8),
    CountryCode(name: 'Malaysia', code: '+60', flag: '🇲🇾', digits: 9),
    CountryCode(name: 'Maldives', code: '+960', flag: '🇲🇻', digits: 7),
    CountryCode(name: 'Malta', code: '+356', flag: '🇲🇹', digits: 8),
    CountryCode(name: 'Mauritius', code: '+230', flag: '🇲🇺', digits: 8),
    CountryCode(name: 'Mexico', code: '+52', flag: '🇲🇽', digits: 10),
    CountryCode(name: 'Moldova', code: '+373', flag: '🇲🇩', digits: 8),
    CountryCode(name: 'Mongolia', code: '+976', flag: '🇲🇳', digits: 8),
    CountryCode(name: 'Montenegro', code: '+382', flag: '🇲🇪', digits: 8),
    CountryCode(name: 'Morocco', code: '+212', flag: '🇲🇦', digits: 9),
    CountryCode(name: 'Mozambique', code: '+258', flag: '🇲🇿', digits: 9),
    CountryCode(name: 'Myanmar', code: '+95', flag: '🇲🇲', digits: 9),
    CountryCode(name: 'Nepal', code: '+977', flag: '🇳🇵', digits: 10),
    CountryCode(name: 'Netherlands', code: '+31', flag: '🇳🇱', digits: 9),
    CountryCode(name: 'New Zealand', code: '+64', flag: '🇳🇿', digits: 9),
    CountryCode(name: 'Nicaragua', code: '+505', flag: '🇳🇮', digits: 8),
    CountryCode(name: 'Nigeria', code: '+234', flag: '🇳🇬', digits: 10),
    CountryCode(name: 'North Macedonia', code: '+389', flag: '🇲🇰', digits: 8),
    CountryCode(name: 'Norway', code: '+47', flag: '🇳🇴', digits: 8),
    CountryCode(name: 'Oman', code: '+968', flag: '🇴🇲', digits: 8),
    CountryCode(name: 'Pakistan', code: '+92', flag: '🇵🇰', digits: 10),
    CountryCode(name: 'Palestine', code: '+970', flag: '🇵🇸', digits: 9),
    CountryCode(name: 'Panama', code: '+507', flag: '🇵🇦', digits: 8),
    CountryCode(name: 'Paraguay', code: '+595', flag: '🇵🇾', digits: 9),
    CountryCode(name: 'Peru', code: '+51', flag: '🇵🇪', digits: 9),
    CountryCode(name: 'Philippines', code: '+63', flag: '🇵🇭', digits: 10),
    CountryCode(name: 'Poland', code: '+48', flag: '🇵🇱', digits: 9),
    CountryCode(name: 'Portugal', code: '+351', flag: '🇵🇹', digits: 9),
    CountryCode(name: 'Qatar', code: '+974', flag: '🇶🇦', digits: 8),
    CountryCode(name: 'Romania', code: '+40', flag: '🇷🇴', digits: 9),
    CountryCode(name: 'Russia', code: '+7', flag: '🇷🇺', digits: 10),
    CountryCode(name: 'Rwanda', code: '+250', flag: '🇷🇼', digits: 9),
    CountryCode(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦', digits: 9),
    CountryCode(name: 'Senegal', code: '+221', flag: '🇸🇳', digits: 9),
    CountryCode(name: 'Serbia', code: '+381', flag: '🇷🇸', digits: 9),
    CountryCode(name: 'Singapore', code: '+65', flag: '🇸🇬', digits: 8),
    CountryCode(name: 'Slovakia', code: '+421', flag: '🇸🇰', digits: 9),
    CountryCode(name: 'Slovenia', code: '+386', flag: '🇸🇮', digits: 8),
    CountryCode(name: 'Somalia', code: '+252', flag: '🇸🇴', digits: 8),
    CountryCode(name: 'South Africa', code: '+27', flag: '🇿🇦', digits: 9),
    CountryCode(name: 'South Korea', code: '+82', flag: '🇰🇷', digits: 10),
    CountryCode(name: 'Spain', code: '+34', flag: '🇪🇸', digits: 9),
    CountryCode(name: 'Sri Lanka', code: '+94', flag: '🇱🇰', digits: 9),
    CountryCode(name: 'Sudan', code: '+249', flag: '🇸🇩', digits: 9),
    CountryCode(name: 'Sweden', code: '+46', flag: '🇸🇪', digits: 9),
    CountryCode(name: 'Switzerland', code: '+41', flag: '🇨🇭', digits: 9),
    CountryCode(name: 'Syria', code: '+963', flag: '🇸🇾', digits: 9),
    CountryCode(name: 'Taiwan', code: '+886', flag: '🇹🇼', digits: 9),
    CountryCode(name: 'Tajikistan', code: '+992', flag: '🇹🇯', digits: 9),
    CountryCode(name: 'Tanzania', code: '+255', flag: '🇹🇿', digits: 9),
    CountryCode(name: 'Thailand', code: '+66', flag: '🇹🇭', digits: 9),
    CountryCode(name: 'Trinidad & Tobago', code: '+1868', flag: '🇹🇹', digits: 7),
    CountryCode(name: 'Tunisia', code: '+216', flag: '🇹🇳', digits: 8),
    CountryCode(name: 'Turkey', code: '+90', flag: '🇹🇷', digits: 10),
    CountryCode(name: 'Turkmenistan', code: '+993', flag: '🇹🇲', digits: 8),
    CountryCode(name: 'UAE', code: '+971', flag: '🇦🇪', digits: 9),
    CountryCode(name: 'Uganda', code: '+256', flag: '🇺🇬', digits: 9),
    CountryCode(name: 'Ukraine', code: '+380', flag: '🇺🇦', digits: 9),
    CountryCode(name: 'United Kingdom', code: '+44', flag: '🇬🇧', digits: 10),
    CountryCode(name: 'United States', code: '+1', flag: '🇺🇸', digits: 10),
    CountryCode(name: 'Uruguay', code: '+598', flag: '🇺🇾', digits: 8),
    CountryCode(name: 'Uzbekistan', code: '+998', flag: '🇺🇿', digits: 9),
    CountryCode(name: 'Venezuela', code: '+58', flag: '🇻🇪', digits: 10),
    CountryCode(name: 'Vietnam', code: '+84', flag: '🇻🇳', digits: 9),
    CountryCode(name: 'Yemen', code: '+967', flag: '🇾🇪', digits: 9),
    CountryCode(name: 'Zambia', code: '+260', flag: '🇿🇲', digits: 9),
    CountryCode(name: 'Zimbabwe', code: '+263', flag: '🇿🇼', digits: 9),
  ];

  /// Find country code info by dial code string (e.g. '+91')
  static CountryCode? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Get expected digit count for a dial code
  static int getExpectedDigits(String code) {
    return findByCode(code)?.digits ?? 10;
  }

  /// Search countries by name or code
  static List<CountryCode> search(String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((c) => c.name.toLowerCase().contains(q) || c.code.contains(q)).toList();
  }
}
