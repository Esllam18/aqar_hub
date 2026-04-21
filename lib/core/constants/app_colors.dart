import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF1B4D9B);
  static const Color primaryDark = Color(0xFF12366D);
  static const Color secondary = Color(0xFF4DA3FF);

  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F4FA);
  static const Color border = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);
}

abstract final class AppRadii {
  static const double xs = 10;
  static const double sm = 14;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x140F172A), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x1A0F172A), blurRadius: 24, offset: Offset(0, 10)),
  ];
}
