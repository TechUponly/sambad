import 'package:flutter/material.dart';

/// Theme-aware color system.
/// Use `AppColors.of(context)` for theme-dependent colors,
/// or static constants for fixed colors.
class AppColors {
  // ── Fixed brand colors (same in both themes) ─────────
  static const Color primaryBlue = Color(0xFF5B7FFF);
  static const Color accentGreen = Color(0xFF00C853);
  static const Color error = Colors.redAccent;
  static const Color success = Color(0xFF00C853);
  static const Color warning = Colors.orangeAccent;

  // Message bubble gradients (same in both themes)
  static const Color sentBubbleStart = Color(0xFF3A3DFF);
  static const Color sentBubbleEnd = Color(0xFF7C3AED);

  // ── Dark theme colors ───────────────────────────────
  static const Color bgDark = Color(0xFF181A20);
  static const Color bgCard = Color(0xFF23272F);
  static const Color bgGradientMid = Color(0xFF232B3E);
  static const Color textWhite = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white54;
  static const Color textHint = Colors.white38;
  static const Color receivedBubbleStart = Color(0xFF232B3E);
  static const Color receivedBubbleEnd = Color(0xFF181A20);

  // ── Light theme colors ──────────────────────────────
  static const Color bgLight = Color(0xFFF5F6FA);
  static const Color bgCardLight = Color(0xFFFFFFFF);
  static const Color bgGradientMidLight = Color(0xFFE8EAF0);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color textMutedLight = Color(0xFF888888);
  static const Color textHintLight = Color(0xFFAAAAAA);
  static const Color receivedBubbleStartLight = Color(0xFFE8EAF0);
  static const Color receivedBubbleEndLight = Color(0xFFF5F6FA);

  /// Get theme-aware colors from context
  static AppColorSet of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? _darkSet : _lightSet;
  }

  static const _darkSet = AppColorSet(
    bg: bgDark,
    card: bgCard,
    gradientMid: bgGradientMid,
    text: textWhite,
    textSecondary: textSecondary,
    textMuted: textMuted,
    textHint: textHint,
    receivedBubbleStart: receivedBubbleStart,
    receivedBubbleEnd: receivedBubbleEnd,
  );

  static const _lightSet = AppColorSet(
    bg: bgLight,
    card: bgCardLight,
    gradientMid: bgGradientMidLight,
    text: textDark,
    textSecondary: textSecondaryLight,
    textMuted: textMutedLight,
    textHint: textHintLight,
    receivedBubbleStart: receivedBubbleStartLight,
    receivedBubbleEnd: receivedBubbleEndLight,
  );

  /// Generate a consistent color for a contact based on their name
  static Color avatarColor(String name) {
    if (name.isEmpty) return primaryBlue;
    final colors = [
      const Color(0xFF5B7FFF),
      const Color(0xFF7C3AED),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF009688),
      const Color(0xFF3F51B5),
      const Color(0xFFCDDC39),
    ];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}

/// A set of theme-dependent colors
class AppColorSet {
  final Color bg;
  final Color card;
  final Color gradientMid;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color textHint;
  final Color receivedBubbleStart;
  final Color receivedBubbleEnd;

  const AppColorSet({
    required this.bg,
    required this.card,
    required this.gradientMid,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.textHint,
    required this.receivedBubbleStart,
    required this.receivedBubbleEnd,
  });
}
