import 'package:flutter/material.dart';

class AppColors {
  // Brand Medical & Cardiology Palette
  static const Color primary = Color(0xFF0D5C75); // Deep Medical Cyan / Teal
  static const Color primaryDark = Color(0xFF063A4B);
  static const Color primaryLight = Color(0xFF1982A2);
  static const Color primarySurface = Color(0xFFE8F4F8);

  // Heart & Accent
  static const Color heartRed = Color(0xFFE63946); // Pulse / Urgent / Cardiology Red
  static const Color heartRedLight = Color(0xFFFFECEE);

  // Secondary Accents
  static const Color accentGold = Color(0xFFF4A261);
  static const Color successGreen = Color(0xFF2A9D8F);
  static const Color successLight = Color(0xFFE6F7F5);
  static const Color warningOrange = Color(0xFFE76F51);
  static const Color warningLight = Color(0xFFFFF1EE);

  // Neutral Colors
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A4F64), Color(0xFF107393)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heartGradient = LinearGradient(
    colors: [Color(0xFFE63946), Color(0xFFFA5A68)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF9FBFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
