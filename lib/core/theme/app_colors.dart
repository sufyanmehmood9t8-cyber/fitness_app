import 'package:flutter/material.dart';

/// Flow's single source of colour truth.
abstract final class AppColors {
  static const Color primary = Color(0xFF4299E1);
  static const Color primaryDark = Color(0xFF2B6CB0);
  static const Color primarySoft = Color(0xFFEBF6FF);
  static const Color primaryBorder = Color(0xFFBFDBFE);
  static const Color primaryFaint = Color(0xFFF4FAFF);

  static const Color coral = Color(0xFFF58A6B);
  static const Color coralSoft = Color(0xFFFFF4EF);
  static const Color coralBorder = Color(0xFFF9B7A3);

  static const Color urgent = Color(0xFFE5484D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color chip = Color(0xFFE5E7EB);
  static const Color chipText = Color(0xFF4B5563);
  static const Color divider = Color(0xFFEEF0F4);
  static const Color border = Color(0xFFE5E7EB);
  static const Color field = Color(0xFFF7F8FA);

  static const Color backgroundTop = Color(0xFFF1EEFF);
  static const Color backgroundMid = Color(0xFFF6F7FF);
  static const Color backgroundBottom = Color(0xFFFFFFFF);

  static const Color shadow = Color(0x1A4299E1);
  static const Color shadowStrong = Color(0x294299E1);
  static const Color overlay = Color(0x661A1A1A);
  static const Color overlayLight = Color(0x1A1A1A1A);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF6AD55);
  static const Color star = Color(0xFFF6AD55);
  static const Color transparent = Color(0x00000000);

  static const Color peachCircle = Color(0xFFFFE6DC);
  static const Color blueCircle = Color(0xFFE7F3FF);
  static const Color purple = Color(0xFF8B7CF6);
  static const Color completionStart = Color(0xFFEBF4FF);
  static const Color completionEnd = Color(0xFFFFFFFF);
  static const Color confettiBlue = Color(0xFF4299E1);
  static const Color confettiCoral = Color(0xFFF58A6B);
  static const Color confettiYellow = Color(0xFFF6E05E);
  static const Color confettiPurple = Color(0xFFB794F4);

  static const Color wheelFade = Color(0xFFF4F9FF);
  static const List<Color> screenGradient = <Color>[
    backgroundTop,
    backgroundMid,
    backgroundBottom,
  ];
  static const List<Color> completeGradient = <Color>[
    completionStart,
    completionEnd,
  ];
}
