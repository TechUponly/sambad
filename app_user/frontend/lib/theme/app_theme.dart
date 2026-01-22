import 'package:flutter/material.dart';

class AppTheme {
  // Modern B2C Colors - Vibrant & Friendly
  static const Color primaryBlue = Color(0xFF0066FF);      // Bright, energetic
  static const Color accentPurple = Color(0xFF7C3AED);     // Premium feel
  static const Color freshGreen = Color(0xFF00C853);       // Success/positive
  static const Color warmOrange = Color(0xFFFF6B35);       // Call to action
  
  // Neutral & Backgrounds
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color lightText = Color(0xFF666666);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  
  // Gradients for premium feel
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get intuitiveTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'SF Pro Display', // iOS-like, familiar
      
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: accentPurple,
        tertiary: freshGreen,
        surface: cardWhite,
        background: bgLight,
      ),
      
      scaffoldBackgroundColor: bgLight,
      
      // App Bar - Minimal, clean
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false, // Left-aligned like modern apps
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      
      // Cards - Soft shadows, rounded
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: cardWhite,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      
      // Buttons - Bold, impossible to miss
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text buttons - Subtle but clear
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Inputs - Large, friendly, clear focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: lightText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Bottom Nav - Icon-first, intuitive
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: lightText,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        elevation: 12,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Floating Action Button - Bold & obvious
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Dividers - Subtle
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// Spacing System - Consistent, rhythmic
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// Animation Durations - Feel responsive
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve defaultCurve = Curves.easeInOutCubic;
}

// Text Styles - Clear hierarchy
class AppTextStyles {
  static const TextStyle hero = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: -1,
    height: 1.2,
  );
  
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.lightText,
  );
}
