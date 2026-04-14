import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE91E63);
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color primaryLight = Color(0xFFF48FB1);
  static const Color secondaryPink = Color(0xFFFF80AB);
  static const Color background = Color(0xFFFFF1F5);
  static const Color accent = Color(0xFFF8BBD0);
  static const Color accentLight = Color(0xFFFFE4EC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF3E2530);
  static const Color textMuted = Color(0xFF8B6E7C);
  static const Color botBubble = Color(0xFFF3F3F6);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color ovulationColor = Color(0xFF9C27B0);
  static const Color periodColor = Color(0xFFE91E63);

  // Phase colors
  static const Color menstrualPhase = Color(0xFFE91E63);
  static const Color follicularPhase = Color(0xFFFF9800);
  static const Color ovulationPhase = Color(0xFF9C27B0);
  static const Color lutealPhase = Color(0xFF2196F3);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondaryPink],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAD1457), primary, secondaryPink],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE0EC), Color(0xFFFFF1F5)],
  );

  static const LinearGradient cycleCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFFFF4081)],
  );

  static const LinearGradient insightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
  );
}
