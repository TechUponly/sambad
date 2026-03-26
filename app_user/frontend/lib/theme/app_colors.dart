import 'package:flutter/material.dart';

/// Centralized color constants for the entire app.
/// Import this file instead of redefining colors in every screen.
class AppColors {
  // Primary
  static const Color primaryBlue = Color(0xFF5B7FFF);
  static const Color accentGreen = Color(0xFF00C853);

  // Backgrounds
  static const Color bgDark = Color(0xFF181A20);
  static const Color bgCard = Color(0xFF23272F);
  static const Color bgGradientMid = Color(0xFF232B3E);

  // Text
  static const Color textWhite = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;
  static const Color textHint = Colors.white38;

  // Status
  static const Color error = Colors.redAccent;
  static const Color success = Color(0xFF00C853);
  static const Color warning = Colors.orangeAccent;

  // Message bubbles
  static const Color sentBubbleStart = Color(0xFF3A3DFF);
  static const Color sentBubbleEnd = Color(0xFF7C3AED);
  static const Color receivedBubbleStart = Color(0xFF232B3E);
  static const Color receivedBubbleEnd = Color(0xFF181A20);

  /// Generate a consistent color for a contact based on their name
  static Color avatarColor(String name) {
    if (name.isEmpty) return primaryBlue;
    final colors = [
      const Color(0xFF5B7FFF), // Blue
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF009688), // Teal
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFFCDDC39), // Lime
    ];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
