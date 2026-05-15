import 'package:flutter/material.dart';

/// Palette du design BBCMS (sober institutional + futurist).
/// Référence: Design/styles.css :root tokens.
class AppColors {
  AppColors._();

  // Texte
  static const Color ink = Color(0xFF0B1E4A); // deep navy
  static const Color ink2 = Color(0xFF14306B);
  static const Color muted = Color(0xFF6B7385);
  static const Color muted2 = Color(0xFF9AA0B0);

  // Hairlines
  static const Color hair = Color(0xFFE7E8EE);
  static const Color hair2 = Color(0xFFF0F1F5);

  // Surfaces
  static const Color bg = Color(0xFFF6F5F1); // warm cream canvas
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFFAF9F5);

  // Accents
  static const Color accent = Color(0xFF2A5FFF); // azure
  static const Color accentSoft = Color(0xFFE6EDFF);
  static const Color gold = Color(0xFFB89456); // serif accent — sacred

  // Status
  static const Color positive = Color(0xFF2F6B4A);
  static const Color warn = Color(0xFFB8732A);
  static const Color danger = Color(0xFFB84035);

  // Dark surfaces (cards on ink hero)
  static const Color darkSurface = Color(0xFF0B1E4A);
  static const Color darkHair = Color(0x26FFFFFF); // rgba(255,255,255,0.15)
  static const Color darkMuted = Color(0x8CFFFFFF); // rgba(255,255,255,0.55)
}
